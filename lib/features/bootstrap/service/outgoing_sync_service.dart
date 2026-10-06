import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/core/network/app_http_client.dart';
import 'package:eerl_app/features/auth/data/auth_session_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

/// Sends locally committed changes in sequence before Bootstrap downloads.
class OutgoingSyncService {
  OutgoingSyncService({
    AppDatabase? database,
    http.Client? client,
    AuthSessionStorage? sessionStorage,
  }) : _database = database ?? AppDatabase.instance,
       _client = client ?? AppHttpClient.instance.client,
       _sessionStorage = sessionStorage ?? AuthSessionStorage();

  static final OutgoingSyncService instance = OutgoingSyncService();
  static const _timeout = Duration(seconds: 30);

  final AppDatabase _database;
  final http.Client _client;
  final AuthSessionStorage _sessionStorage;
  Future<void>? _activeDrain;

  Future<void> drain() {
    final active = _activeDrain;
    if (active != null) return active;
    late final Future<void> run;
    run = _drain().whenComplete(() {
      if (identical(_activeDrain, run)) _activeDrain = null;
    });
    _activeDrain = run;
    return run;
  }

  /// Immediately retries every locally stored mutation during a user-initiated
  /// sync. Automatic sync keeps its backoff, while this path clears retry
  /// delays and re-queues permanent failures because the user explicitly asked
  /// the app to try all pending data again.
  Future<void> retryAllAndDrain() async {
    final active = _activeDrain;
    if (active != null) await active;
    final resetCount = await _database.update(DatabaseTables.outbox, {
      'status': 'queued',
      'attempts': 0,
      'last_error': null,
      'next_attempt_at': null,
    }, where: "status IN ('queued', 'failed')");
    _log('MANUAL sync re-queued $resetCount outbox item(s)');
    await drain();
  }

  Future<void> _drain() async {
    final token = await _sessionStorage.getAccessToken();
    if (token == null || token.trim().isEmpty) {
      _log('Skipped outgoing sync: access token not found');
      return;
    }

    // A process death can leave a row in sending/uploading. Both operations
    // are idempotent and can safely return to their waiting states.
    await _database.update(DatabaseTables.outbox, {
      'status': 'queued',
    }, where: "status = 'sending'");
    await _database.update(DatabaseTables.photos, {
      'status': 'failed',
    }, where: "status = 'uploading'");

    var photoProgress = await _uploadWaitingPhotos(token);
    while (true) {
      final next = await _nextOutboxItem();
      if (next == null) return;
      if ((next['photos_waiting'] as num?)?.toInt() != 0) {
        if (photoProgress == 0) {
          _log('Oldest outgoing item is waiting for photo uploads');
          return;
        }
        photoProgress = await _uploadWaitingPhotos(token);
        final refreshed = await _nextOutboxItem();
        if (refreshed == null ||
            (refreshed['photos_waiting'] as num?)?.toInt() != 0) {
          _log('Oldest outgoing item is waiting for photo uploads');
          return;
        }
        await _send(refreshed, token);
      } else {
        await _send(next, token);
      }
    }
  }

  Future<Map<String, Object?>?> _nextOutboxItem() async {
    final rows = await _database.rawQuery(
      '''
      SELECT o.*,
        (SELECT COUNT(*)
         FROM ${DatabaseTables.outboxPhotos} op
         JOIN ${DatabaseTables.photos} p ON p.id = op.photo_id
         WHERE op.outbox_seq = o.seq AND p.status <> 'uploaded')
          AS photos_waiting
      FROM ${DatabaseTables.outbox} o
      WHERE o.status = 'queued'
        AND (o.next_attempt_at IS NULL OR o.next_attempt_at <= ?)
        AND NOT EXISTS (
          SELECT 1 FROM ${DatabaseTables.outbox} failed
          WHERE failed.status = 'failed'
            AND failed.entity = o.entity
            AND failed.entity_id = o.entity_id
        )
      ORDER BY o.seq
      LIMIT 1
    ''',
      [DateTime.now().toUtc().toIso8601String()],
    );
    return rows.isEmpty ? null : rows.single;
  }

  Future<void> _send(Map<String, Object?> item, String token) async {
    final seq = (item['seq'] as num).toInt();
    await _database.update(
      DatabaseTables.outbox,
      {'status': 'sending'},
      where: "seq = ? AND status = 'queued'",
      whereArgs: [seq],
    );

    try {
      final body = await _resolvedBody(item['body'] as String?);
      final request =
          http.Request(
              item['method']! as String,
              Uri.parse('${AppConstants.apiBaseUrl}/mobile${item['path']}'),
            )
            ..headers.addAll({
              'accept': 'application/json',
              'Authorization': 'Bearer $token',
              if (body != null) 'content-type': 'application/json',
            });
      if (body != null) request.body = jsonEncode(body);

      _log('SEND #$seq ${item['method']} ${item['path']}');
      final isCollection = item['entity'] == DatabaseTables.collections;
      if (isCollection) {
        _collectionLog(
          'REQUEST',
          '#$seq ${item['method']} ${request.url} '
              'collection_id=${item['entity_id']} body=${request.body}',
        );
      }
      final streamed = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      final responseBody = _decodeObject(response.body);
      if (isCollection) {
        _collectionLog(
          'RESPONSE',
          '#$seq status=${response.statusCode} '
              'collection_id=${item['entity_id']} '
              'body=${response.body.trim().isEmpty ? '{}' : response.body}',
        );
      }
      final code = _errorCode(responseBody);
      if (_isSuccess(response.statusCode, code)) {
        await _complete(item, responseBody);
        _log('DONE #$seq status=${response.statusCode}');
        return;
      }
      if (response.statusCode >= 500 ||
          response.statusCode == 408 ||
          response.statusCode == 429) {
        await _retry(item, 'HTTP ${response.statusCode}');
        return;
      }
      await _fail(
        item,
        'HTTP ${response.statusCode}${code == null ? '' : ' $code'}',
      );
    } on TimeoutException {
      await _retry(item, 'Request timed out');
    } on SocketException catch (error) {
      await _retry(item, error.message);
    } catch (error) {
      await _retry(item, error.toString());
    }
  }

  Future<Object?> _resolvedBody(String? rawBody) async {
    if (rawBody == null || rawBody.trim().isEmpty) return null;
    final decoded = jsonDecode(rawBody);
    final photoRows = await _database.query(
      DatabaseTables.photos,
      columns: const ['id', 'remote_url'],
      where: 'remote_url IS NOT NULL',
    );
    final urls = <String, String>{
      for (final row in photoRows)
        if (row['remote_url'] is String)
          row['id']! as String: row['remote_url']! as String,
    };
    return _replacePhotoIds(decoded, urls);
  }

  Object? _replacePhotoIds(Object? value, Map<String, String> urls) {
    if (value is String) return urls[value] ?? value;
    if (value is List) {
      return value.map((item) => _replacePhotoIds(item, urls)).toList();
    }
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), _replacePhotoIds(item, urls)),
      );
    }
    return value;
  }

  Future<void> _complete(
    Map<String, Object?> item,
    Map<String, Object?> response,
  ) async {
    final seq = (item['seq'] as num).toInt();
    final entity = item['entity']! as String;
    final entityId = item['entity_id']! as String;
    await _database.runInTransaction((txn) async {
      await txn.delete(
        DatabaseTables.outboxPhotos,
        where: 'outbox_seq = ?',
        whereArgs: [seq],
      );
      await txn.delete(
        DatabaseTables.outbox,
        where: 'seq = ?',
        whereArgs: [seq],
      );

      if (!_tablesWithSyncState.contains(entity)) return;
      final remaining = Sqflite.firstIntValue(
        await txn.rawQuery(
          'SELECT COUNT(*) FROM ${DatabaseTables.outbox} '
          'WHERE entity = ? AND entity_id = ?',
          [entity, entityId],
        ),
      );
      if (remaining != 0) return;

      final values = await _serverValues(txn, entity, response);
      values['sync_state'] = 'synced';
      if (entity == DatabaseTables.centerItems) {
        final parts = entityId.split(':');
        if (parts.length >= 2) {
          final tabCondition = parts.length >= 3 && parts[2] == 'PLASTIC'
              ? "material_type = 'PLASTIC'"
              : "material_type IN ('NON_PLASTIC', 'MIXED')";
          await txn.rawUpdate('''
            UPDATE ${DatabaseTables.centerItems}
            SET sync_state = 'synced'
            WHERE center_id = ? AND channel = ?
              AND item_id IN (
                SELECT id FROM ${DatabaseTables.items} WHERE $tabCondition
              )
            ''', parts.take(2).toList(growable: false));
        }
      } else {
        await txn.update(
          entity,
          values,
          where: 'id = ?',
          whereArgs: [entityId],
        );
        if (entity == DatabaseTables.collections) {
          await _applyCollectionResponseLines(txn, entityId, response);
        }
      }
    });
  }

  Future<Map<String, Object?>> _serverValues(
    Transaction txn,
    String table,
    Map<String, Object?> response,
  ) async {
    final data = response['data'];
    if (data is! Map) return <String, Object?>{};
    if (table == DatabaseTables.collections) {
      return _collectionServerValues(data);
    }
    Object? candidate = data;
    if (data[table] is Map) candidate = data[table];
    if (candidate is! Map) return <String, Object?>{};
    final columns = (await txn.rawQuery(
      'PRAGMA table_info("$table")',
    )).map((row) => row['name']).whereType<String>().toSet();
    return <String, Object?>{
      for (final entry in candidate.entries)
        if (columns.contains(entry.key.toString()) &&
            entry.key != 'id' &&
            entry.key != 'sync_state')
          entry.key.toString(): _sqliteValue(entry.value),
    };
  }

  Map<String, Object?> _collectionServerValues(Map<Object?, Object?> data) {
    final agent = data['agent'];
    final handover = data['handover'];
    final totals = data['totals'];
    final review = data['review'];
    final vehicle = handover is Map ? handover['vehicle'] : null;
    final mrfLabour = handover is Map ? handover['mrfLabour'] : null;
    final ragpicker = handover is Map ? handover['ragpicker'] : null;
    final reviewBy = review is Map ? review['by'] : null;
    return <String, Object?>{
      if (data['status'] != null) 'status': data['status'],
      if (data['slipNumber'] != null) 'slip_number': data['slipNumber'],
      if (data['collectedAt'] != null) 'collected_at': data['collectedAt'],
      if (data['updatedAt'] != null) 'updated_at': data['updatedAt'],
      if (data['takesPayment'] != null)
        'takes_payment': _sqliteValue(data['takesPayment']),
      if (agent is Map && agent['id'] != null) 'agent_id': agent['id'],
      if (agent is Map && agent['name'] != null) 'agent_name': agent['name'],
      if (vehicle is Map && vehicle['id'] != null) 'vehicle_id': vehicle['id'],
      if (mrfLabour is Map && mrfLabour['id'] != null)
        'mrf_person_id': mrfLabour['id'],
      if (ragpicker is Map && ragpicker['id'] != null)
        'ragpicker_id': ragpicker['id'],
      if (handover is Map && handover['givenByName'] != null)
        'given_by_name': handover['givenByName'],
      if (handover is Map && handover['photoUrls'] is List)
        'handover_photo_urls': jsonEncode(handover['photoUrls']),
      if (data['paidBy'] != null) 'paid_by': data['paidBy'],
      if (totals is Map && totals['amount'] != null)
        'total_amount': totals['amount'],
      if (review is Map && review['reason'] != null)
        'rejection_reason': review['reason'],
      if (reviewBy is Map && reviewBy['name'] != null)
        'verified_by_name': reviewBy['name'],
      if (review is Map && review['at'] != null) 'verified_at': review['at'],
    };
  }

  Future<void> _applyCollectionResponseLines(
    Transaction txn,
    String collectionId,
    Map<String, Object?> response,
  ) async {
    final data = response['data'];
    if (data is! Map || data['lines'] is! List) return;
    for (final rawLine in data['lines']! as List) {
      if (rawLine is! Map || rawLine['itemId'] == null) continue;
      await txn.update(
        DatabaseTables.collectionItems,
        {
          if (rawLine['collectedQty'] != null) 'qty': rawLine['collectedQty'],
          if (rawLine['verifiedQty'] != null)
            'verified_qty': rawLine['verifiedQty'],
          if (rawLine['rate'] != null) 'rate': rawLine['rate'],
          if (rawLine['amount'] != null) 'amount': rawLine['amount'],
          if (rawLine['photoUrls'] is List)
            'photo_urls': jsonEncode(rawLine['photoUrls']),
          if (rawLine['sortOrder'] != null) 'sort_order': rawLine['sortOrder'],
        },
        where: 'collection_id = ? AND item_id = ?',
        whereArgs: [collectionId, rawLine['itemId']],
      );
    }
  }

  Object? _sqliteValue(Object? value) {
    if (value is bool) return value ? 1 : 0;
    if (value is List || value is Map) return jsonEncode(value);
    return value;
  }

  Future<void> _retry(Map<String, Object?> item, String error) async {
    final attempts = ((item['attempts'] as num?)?.toInt() ?? 0) + 1;
    final delay = switch (attempts) {
      1 => const Duration(seconds: 30),
      2 => const Duration(minutes: 2),
      3 => const Duration(minutes: 10),
      _ => const Duration(minutes: 30),
    };
    await _database.update(
      DatabaseTables.outbox,
      {
        'status': 'queued',
        'attempts': attempts,
        'last_error': error,
        'next_attempt_at': DateTime.now().toUtc().add(delay).toIso8601String(),
      },
      where: 'seq = ?',
      whereArgs: [item['seq']],
    );
    _log('RETRY #${item['seq']} in ${delay.inSeconds}s: $error');
  }

  Future<void> _fail(Map<String, Object?> item, String error) async {
    await _database.runInTransaction((txn) async {
      await txn.update(
        DatabaseTables.outbox,
        {'status': 'failed', 'last_error': error},
        where: 'seq = ?',
        whereArgs: [item['seq']],
      );
      final entity = item['entity']! as String;
      if (_tablesWithSyncState.contains(entity) &&
          entity != DatabaseTables.centerItems) {
        await txn.update(
          entity,
          {'sync_state': 'failed'},
          where: 'id = ?',
          whereArgs: [item['entity_id']],
        );
      }
    });
    _log('FAILED #${item['seq']}: $error');
  }

  Future<int> _uploadWaitingPhotos(String token) async {
    final waitingRows = await _database.query(
      DatabaseTables.photos,
      where: "status IN ('local', 'failed')",
      orderBy: 'created_at',
      limit: 20,
    );
    if (waitingRows.isEmpty) return 0;
    final rows = <Map<String, Object?>>[];
    for (final waitingRow in waitingRows) {
      final row = Map<String, Object?>.from(waitingRow);
      final id = row['id']! as String;
      final localPath = row['local_path'] as String?;
      if (localPath == null || localPath.trim().isEmpty) {
        _log('PHOTO skipped id=$id: local path is missing');
        continue;
      }
      final file = File(localPath);
      int sizeBytes;
      try {
        sizeBytes = await file.length();
      } on FileSystemException catch (error) {
        _log('PHOTO skipped id=$id: ${error.message}');
        continue;
      }
      if (sizeBytes <= 0) {
        _log('PHOTO skipped id=$id: file is empty');
        continue;
      }
      row['size_bytes'] = sizeBytes;
      rows.add(row);
      await _database.update(
        DatabaseTables.photos,
        {'size_bytes': sizeBytes},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    if (rows.isEmpty) return 0;
    final ids = rows.map((row) => row['id']! as String).toList();
    final marks = List.filled(ids.length, '?').join(',');
    await _database.rawUpdate(
      "UPDATE ${DatabaseTables.photos} SET status = 'uploading' WHERE id IN ($marks)",
      ids,
    );

    var uploadedCount = 0;
    try {
      final batchBody = {
        'photos': [
          for (final row in rows)
            {
              'purpose': row['purpose'],
              'contentType': row['content_type'],
              'sizeBytes': row['size_bytes'],
            },
        ],
      };
      _photoLog(
        'BATCH_REQUEST',
        'count=${rows.length} body=${jsonEncode(batchBody)}',
      );
      final response = await _client
          .post(
            Uri.parse('${AppConstants.apiBaseUrl}/mobile/uploads/batch'),
            headers: {
              'accept': 'application/json',
              'content-type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(batchBody),
          )
          .timeout(_timeout);
      _photoLog(
        'BATCH_RESPONSE',
        'status=${response.statusCode} '
            'body=${response.body.trim().isEmpty ? '{}' : response.body}',
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Upload batch HTTP ${response.statusCode}: ${response.body}',
        );
      }
      final body = _decodeObject(response.body);
      final uploads = _uploadList(body);
      if (uploads.length != rows.length) {
        _photoLog(
          'BATCH_MISMATCH',
          'requested=${rows.length} received=${uploads.length}',
        );
      }
      final uploadCount = uploads.length < rows.length
          ? uploads.length
          : rows.length;
      for (var index = 0; index < uploadCount; index++) {
        final upload = uploads[index];
        final source = rows[index];
        // The API returns data.items without the local photo id. Response
        // items retain request order, so the local rows are paired by index.
        final id = source['id']! as String;
        final uploadUrl =
            upload['uploadUrl']?.toString() ?? upload['upload_url']?.toString();
        final fileUrl =
            upload['fileUrl']?.toString() ?? upload['file_url']?.toString();
        if (uploadUrl == null || fileUrl == null) continue;
        final localPath = source['local_path'] as String?;
        if (localPath == null || localPath.isEmpty) continue;
        final file = File(localPath);
        final put = await _client
            .put(
              Uri.parse(uploadUrl),
              headers: {'content-type': source['content_type']! as String},
              body: await file.readAsBytes(),
            )
            .timeout(_timeout);
        if (put.statusCode < 200 || put.statusCode >= 300) continue;
        await _database.update(
          DatabaseTables.photos,
          {
            'status': 'uploaded',
            'remote_url': fileUrl,
            'uploaded_at': DateTime.now().toUtc().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [id],
        );
        uploadedCount++;
        _photoLog(
          'UPLOADED',
          'photo_id=$id size_bytes=${source['size_bytes']}',
        );
      }
    } catch (error) {
      _log('PHOTO batch failed: $error');
    } finally {
      await _database.rawUpdate(
        "UPDATE ${DatabaseTables.photos} SET status = 'failed' "
        "WHERE id IN ($marks) AND status = 'uploading'",
        ids,
      );
    }
    return uploadedCount;
  }

  List<Map<String, Object?>> _uploadList(Map<String, Object?> body) {
    final data = body['data'];
    final raw = data is Map
        ? (data['items'] ?? data['uploads'] ?? data['files'])
        : (body['items'] ?? body['uploads'] ?? body['files']);
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, Object?>.from(item))
        .toList(growable: false);
  }

  Map<String, Object?> _decodeObject(String raw) {
    if (raw.trim().isEmpty) return <String, Object?>{};
    final decoded = jsonDecode(raw);
    return decoded is Map
        ? Map<String, Object?>.from(decoded)
        : <String, Object?>{};
  }

  String? _errorCode(Map<String, Object?> body) {
    final error = body['error'];
    if (error is Map) {
      final details = error['details'];
      if (details is List && details.isNotEmpty && details.first is Map) {
        return (details.first as Map)['code']?.toString();
      }
      return error['code']?.toString();
    }
    return null;
  }

  bool _isSuccess(int statusCode, String? code) =>
      (statusCode >= 200 && statusCode < 300) ||
      (statusCode == 409 &&
          (code == 'NOT_PENDING' || code == 'ALREADY_CLOSED'));

  static const _tablesWithSyncState = <String>{
    DatabaseTables.centerItems,
    DatabaseTables.vehicles,
    DatabaseTables.mrfPeople,
    DatabaseTables.ragpickers,
    DatabaseTables.collections,
    DatabaseTables.expenses,
    DatabaseTables.cashRequests,
    DatabaseTables.categoryRequests,
    DatabaseTables.transfers,
    DatabaseTables.tasks,
    DatabaseTables.requests,
    DatabaseTables.walletEntries,
    DatabaseTables.notifications,
  };

  static void _log(String message) {
    if (kDebugMode) debugPrint('📤 [EERL_OUTBOX] $message');
  }

  static void _collectionLog(String stage, String message) {
    if (kDebugMode) {
      debugPrint('🌐 [EERL_COLLECTION_API][$stage] $message');
    }
  }

  static void _photoLog(String stage, String message) {
    if (kDebugMode) debugPrint('📸 [EERL_PHOTO_UPLOAD][$stage] $message');
  }
}
