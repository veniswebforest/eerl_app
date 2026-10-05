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
    final run = _drain();
    _activeDrain = run;
    return run.whenComplete(() => _activeDrain = null);
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

    await _uploadWaitingPhotos(token);
    while (true) {
      final next = await _nextOutboxItem();
      if (next == null) return;
      if ((next['photos_waiting'] as num?)?.toInt() != 0) {
        await _uploadWaitingPhotos(token);
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
      final streamed = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      final responseBody = _decodeObject(response.body);
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

  Future<void> _uploadWaitingPhotos(String token) async {
    final rows = await _database.query(
      DatabaseTables.photos,
      where: "status IN ('local', 'failed')",
      orderBy: 'created_at',
      limit: 20,
    );
    if (rows.isEmpty) return;
    final ids = rows.map((row) => row['id']! as String).toList();
    final marks = List.filled(ids.length, '?').join(',');
    await _database.rawUpdate(
      "UPDATE ${DatabaseTables.photos} SET status = 'uploading' WHERE id IN ($marks)",
      ids,
    );

    try {
      final response = await _client
          .post(
            Uri.parse('${AppConstants.apiBaseUrl}/mobile/uploads/batch'),
            headers: {
              'accept': 'application/json',
              'content-type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'files': [
                for (final row in rows)
                  {
                    'id': row['id'],
                    'purpose': row['purpose'],
                    'contentType': row['content_type'],
                    'sizeBytes': row['size_bytes'],
                  },
              ],
            }),
          )
          .timeout(_timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('Upload batch HTTP ${response.statusCode}');
      }
      final body = _decodeObject(response.body);
      final uploads = _uploadList(body);
      final byId = {for (final row in rows) row['id']! as String: row};
      for (final upload in uploads) {
        final id = upload['id']?.toString() ?? upload['photoId']?.toString();
        final uploadUrl =
            upload['uploadUrl']?.toString() ?? upload['upload_url']?.toString();
        final fileUrl =
            upload['fileUrl']?.toString() ?? upload['file_url']?.toString();
        if (id == null || uploadUrl == null || fileUrl == null) continue;
        final source = byId[id];
        final localPath = source?['local_path'] as String?;
        if (localPath == null || localPath.isEmpty) continue;
        final file = File(localPath);
        final put = await _client
            .put(
              Uri.parse(uploadUrl),
              headers: {'content-type': source?['content_type']! as String},
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
  }

  List<Map<String, Object?>> _uploadList(Map<String, Object?> body) {
    final data = body['data'];
    final raw = data is Map
        ? (data['uploads'] ?? data['files'])
        : (body['uploads'] ?? body['files']);
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
}
