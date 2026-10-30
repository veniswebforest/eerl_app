import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:eerl_app/core/network/app_http_client.dart';
import 'package:eerl_app/core/network/internet_connectivity_service.dart';
import 'package:eerl_app/features/auth/data/auth_session_storage.dart';
import 'package:eerl_app/features/bootstrap/service/item_image_cache_service.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

/// Sends locally committed changes in sequence before Bootstrap downloads.
class OutgoingSyncService {
  OutgoingSyncService({
    AppDatabase? database,
    http.Client? client,
    AuthSessionStorage? sessionStorage,
    ItemImageCacheService? imageCache,
    Future<bool> Function()? internetAccessChecker,
  }) : _database = database ?? AppDatabase.instance,
       _client = client ?? AppHttpClient.instance.client,
       _sessionStorage = sessionStorage ?? AuthSessionStorage(),
       _imageCache = imageCache ?? ItemImageCacheService.instance,
       _internetAccessChecker =
           internetAccessChecker ??
           InternetConnectivityService.instance.hasInternetAccess;

  static final OutgoingSyncService instance = OutgoingSyncService();
  static const _timeout = Duration(seconds: 30);

  final AppDatabase _database;
  final http.Client _client;
  final AuthSessionStorage _sessionStorage;
  final ItemImageCacheService _imageCache;
  // Nullable so a singleton retained across Flutter hot reload can safely
  // fall back when this field did not exist on the original instance.
  final Future<bool> Function()? _internetAccessChecker;
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
    await _retryAllAndDrain(reason: 'MANUAL');
  }

  /// Pre-Bootstrap drain ignores automatic retry delays so every retained
  /// local API mutation gets its turn before server state is downloaded.
  Future<void> drainBeforeBootstrap() async {
    await _retryAllAndDrain(reason: 'PRE_BOOTSTRAP');
  }

  Future<void> _retryAllAndDrain({required String reason}) async {
    if (!await _hasInternetAccess()) {
      _log('$reason sync skipped: internet is unavailable');
      return;
    }
    final active = _activeDrain;
    if (active != null) await active;
    final token = await _sessionStorage.getAccessToken();
    if (token == null || token.trim().isEmpty) {
      _log('$reason sync skipped: access token not found');
      return;
    }
    await _reconcileKnownFailedConflicts(token);
    final resetCount = await _database.update(DatabaseTables.outbox, {
      'status': 'queued',
      'attempts': 0,
      'last_error': null,
      'next_attempt_at': null,
    }, where: "status IN ('queued', 'failed')");
    _log('$reason sync re-queued $resetCount outbox item(s)');
    await drain();
  }

  Future<void> _drain() async {
    if (!await _hasInternetAccess()) {
      _log('Outgoing sync skipped: internet is unavailable');
      return;
    }
    final token = await _sessionStorage.getAccessToken();
    if (token == null || token.trim().isEmpty) {
      _log('Skipped outgoing sync: access token not found');
      return;
    }

    await _reconcileKnownFailedConflicts(token);

    // A failed row must stay part of the outgoing queue. Re-queue it once at
    // the beginning of each drain so a later app-open/reconnect/local mutation
    // can retry it. Rows that fail again remain failed until the next drain,
    // which prevents a permanent 4xx response from looping in this run.
    final failedRetryCount = await _database.update(DatabaseTables.outbox, {
      'status': 'queued',
      'next_attempt_at': null,
    }, where: "status = 'failed'");
    if (failedRetryCount > 0) {
      _log('RE-QUEUED $failedRetryCount failed outbox item(s)');
    }

    // A process death can leave a row in sending/uploading. Both operations
    // are idempotent and can safely return to their waiting states.
    await _database.update(DatabaseTables.outbox, {
      'status': 'queued',
    }, where: "status = 'sending'");
    await _database.update(DatabaseTables.photos, {
      'status': 'failed',
    }, where: "status = 'uploading'");

    await _repairUploadedPhotoReferences();
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

  Future<bool> _hasInternetAccess() async {
    try {
      final checker = _internetAccessChecker;
      return await (checker ??
          InternetConnectivityService.instance.hasInternetAccess)();
    } on Object catch (error) {
      _log('Internet check failed safely: $error');
      return false;
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
    final isCollectionRequest = item['entity'] == DatabaseTables.collections;
    final isCollectionSubmit = isCollectionRequest && item['kind'] == 'submit';
    final requestMethod = isCollectionSubmit
        ? 'POST'
        : item['method']! as String;
    final requestPath = isCollectionSubmit
        ? '/collections/${item['entity_id']}/submit'
        : item['path']! as String;
    final stopwatch = Stopwatch();
    var apiSuccessLogged = false;
    await _database.update(
      DatabaseTables.outbox,
      {
        'status': 'sending',
        if (isCollectionSubmit) 'method': requestMethod,
        if (isCollectionSubmit) 'path': requestPath,
      },
      where: "seq = ? AND status = 'queued'",
      whereArgs: [seq],
    );

    try {
      var body = await _resolvedBody(item['body'] as String?);
      if (isCollectionSubmit) {
        body = await _ensureCollectionSubmitGps(item, body);
      }
      final request =
          http.Request(
              requestMethod,
              Uri.parse('${AppConstants.apiBaseUrl}/mobile$requestPath'),
            )
            ..headers.addAll({
              'accept': 'application/json',
              'Authorization': 'Bearer $token',
              if (body != null) 'content-type': 'application/json',
            });
      if (body != null) request.body = jsonEncode(body);

      final isTransfer = item['entity'] == DatabaseTables.transfers;
      AppLogger.apiRequest(
        requestMethod,
        request.url.path,
        message:
            'outboxSeq=$seq | entity=${item['entity']}/${item['entity_id']}',
      );
      stopwatch.start();
      final streamed = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      final responseBody = _decodeObject(response.body);
      final code = _errorCode(responseBody);
      final successful = _isSuccess(response.statusCode, code);
      if (successful) {
        AppLogger.apiSuccess(
          requestMethod,
          request.url.path,
          statusCode: response.statusCode,
          duration: stopwatch.elapsed,
          message: 'outboxSeq=$seq',
        );
        apiSuccessLogged = true;
      } else {
        AppLogger.apiError(
          requestMethod,
          request.url.path,
          statusCode: response.statusCode,
          duration: stopwatch.elapsed,
          error: code,
        );
      }
      if (response.statusCode == 409 &&
          await _handleMovedRecordConflict(item, code, token)) {
        return;
      }
      if (isTransfer &&
          (item['kind'] == 'approve' || item['kind'] == 'reject') &&
          response.statusCode == 409 &&
          code == 'NOT_PENDING') {
        await _refreshTransferAfterConflict(item, token);
        return;
      }
      if (item['entity'] == DatabaseTables.requests &&
          item['kind'] == 'answer' &&
          response.statusCode == 422 &&
          code == 'INVALID_REQUEST' &&
          _hasInvalidPhotoUrlDetail(responseBody) &&
          await _retryRequestAnswerPhotos(item)) {
        return;
      }
      if (successful) {
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
      if (isTransfer &&
          (item['kind'] == 'approve' || item['kind'] == 'reject') &&
          response.statusCode == 404) {
        await _dropTransferDecision(item, 'HTTP 404');
        return;
      }
      await _fail(
        item,
        'HTTP ${response.statusCode}${code == null ? '' : ' $code'}',
      );
    } on TimeoutException catch (error) {
      if (apiSuccessLogged) {
        AppLogger.sync('OUTBOX_APPLY_FAILED', error.toString());
      } else {
        AppLogger.apiError(
          requestMethod,
          requestPath,
          duration: stopwatch.elapsed,
          error: error,
        );
      }
      await _retry(item, 'Request timed out');
    } on SocketException catch (error) {
      if (apiSuccessLogged) {
        AppLogger.sync('OUTBOX_APPLY_FAILED', error.message);
      } else {
        AppLogger.apiError(
          requestMethod,
          requestPath,
          duration: stopwatch.elapsed,
          error: error.message,
        );
      }
      await _retry(item, error.message);
    } catch (error) {
      if (apiSuccessLogged) {
        AppLogger.sync('OUTBOX_APPLY_FAILED', error.toString());
      } else {
        AppLogger.apiError(
          requestMethod,
          requestPath,
          duration: stopwatch.elapsed,
          error: error,
        );
      }
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

  Future<Object?> _ensureCollectionSubmitGps(
    Map<String, Object?> item,
    Object? body,
  ) async {
    if (body is! Map) {
      throw StateError('Collection submit body is unavailable.');
    }
    final resolved = Map<String, Object?>.from(body);
    final collectionId = item['entity_id'] as String?;
    if (collectionId == null || collectionId.isEmpty) {
      throw StateError('Collection submit is missing its collection id.');
    }
    final rows = await _database.query(
      DatabaseTables.collections,
      columns: const ['gps_lat', 'gps_lng'],
      where: 'id = ?',
      whereArgs: [collectionId],
      limit: 1,
    );

    final outboxGps = resolved['gps'];
    final outboxLatitude = outboxGps is Map && outboxGps['lat'] is num
        ? (outboxGps['lat'] as num).toDouble()
        : null;
    final outboxLongitude = outboxGps is Map && outboxGps['lng'] is num
        ? (outboxGps['lng'] as num).toDouble()
        : null;
    if (_isValidGps(outboxLatitude, outboxLongitude)) {
      return resolved;
    }
    final latitude = rows.isEmpty
        ? null
        : (rows.single['gps_lat'] as num?)?.toDouble();
    final longitude = rows.isEmpty
        ? null
        : (rows.single['gps_lng'] as num?)?.toDouble();
    if (!_isValidGps(latitude, longitude)) {
      throw StateError(
        'Collection $collectionId has no valid GPS in the outbox or local table.',
      );
    }

    // Only GPS is repaired from SQLite. Every other request key comes from
    // the queued API payload and must stay exactly as defined by the API.
    resolved['gps'] = {'lat': latitude, 'lng': longitude};
    return resolved;
  }

  bool _isValidGps(double? latitude, double? longitude) =>
      latitude != null &&
      longitude != null &&
      latitude.isFinite &&
      longitude.isFinite &&
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

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
    if (table == DatabaseTables.transfers) {
      return _transferServerValues(data);
    }
    if (table == DatabaseTables.expenses) {
      return _expenseServerValues(data);
    }
    if (table == DatabaseTables.cashRequests) {
      return _cashRequestServerValues(data);
    }
    if (table == DatabaseTables.categoryRequests) {
      return _categoryRequestServerValues(data);
    }
    if (table == DatabaseTables.ragpickers) {
      return _ragpickerServerValues(data);
    }
    if (table == DatabaseTables.mrfPeople) {
      return _mrfPersonServerValues(data);
    }
    if (table == DatabaseTables.vehicles) {
      return _vehicleServerValues(data);
    }
    if (table == DatabaseTables.tasks) {
      return _taskServerValues(data);
    }
    if (table == DatabaseTables.requests) {
      return _requestServerValues(data);
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
      if (review is Map && review.containsKey('remarks'))
        'rejection_remarks': review['remarks'],
      if (reviewBy is Map && reviewBy['name'] != null)
        'verified_by_name': reviewBy['name'],
      if (review is Map && review['at'] != null) 'verified_at': review['at'],
    };
  }

  Map<String, Object?> _mrfPersonServerValues(Map<Object?, Object?> data) {
    final nested = data['mrfPerson'] ?? data['person'] ?? data['mrf_person'];
    final candidate = nested is Map ? nested : data;
    return <String, Object?>{
      if (candidate['number'] != null) 'number': candidate['number'],
      if (candidate['centerId'] != null) 'center_id': candidate['centerId'],
      if (candidate['name'] != null) 'name': candidate['name'],
      if (candidate.containsKey('phone')) 'phone': candidate['phone'],
      if (candidate.containsKey('idNumber')) 'id_number': candidate['idNumber'],
      if (candidate.containsKey('photoUrl')) 'photo_url': candidate['photoUrl'],
      if (candidate['isActive'] != null)
        'is_active': _sqliteValue(candidate['isActive']),
      if (candidate['role'] != null) 'role': candidate['role'],
    };
  }

  Map<String, Object?> _vehicleServerValues(Map<Object?, Object?> data) {
    final nested = data['vehicle'];
    final candidate = nested is Map ? nested : data;
    return <String, Object?>{
      if (candidate['number'] != null) 'number': candidate['number'],
      if (candidate['centerId'] != null) 'center_id': candidate['centerId'],
      if (candidate['plateNumber'] != null)
        'plate_number': candidate['plateNumber'],
      if (candidate.containsKey('driverName'))
        'driver_name': candidate['driverName'],
      if (candidate.containsKey('isActive'))
        'is_active': _sqliteValue(candidate['isActive']),
    };
  }

  Map<String, Object?> _transferServerValues(Map<Object?, Object?> data) {
    final rejection = data['rejection'];
    final decidedBy = rejection is Map ? rejection['by'] : null;
    return {
      if (data['dispatch'] is Map &&
          (data['dispatch'] as Map).containsKey('note'))
        'dispatch_note': (data['dispatch'] as Map)['note'],
      if (data.containsKey('dispatchNote'))
        'dispatch_note': data['dispatchNote'],
      if (data['status'] != null) 'status': data['status'],
      if (data['number'] != null) 'number': data['number'],
      if (data['destinationId'] != null)
        'destination_id': data['destinationId'],
      if (data['destinationName'] != null)
        'destination_name': data['destinationName'],
      if (data['truckExpectedAt'] != null)
        'truck_expected_at': data['truckExpectedAt'],
      if (data.containsKey('transferVehicleId'))
        'transfer_vehicle_id': data['transferVehicleId'],
      if (data.containsKey('plannedVehicleNumber'))
        'planned_vehicle_number': data['plannedVehicleNumber'],
      if (data.containsKey('plannedVehicleOwnership'))
        'planned_vehicle_ownership': data['plannedVehicleOwnership'],
      if (data.containsKey('transporterName'))
        'transporter_name': data['transporterName'],
      if (data.containsKey('transferFee')) 'transfer_fee': data['transferFee'],
      if (data['vehicleNumber'] != null) 'vehicle_plate': data['vehicleNumber'],
      if (data['driverName'] != null) 'driver_name': data['driverName'],
      if (data['handedOverAt'] != null) 'handed_over_at': data['handedOverAt'],
      if (data['dispatchedWeight'] != null)
        'dispatched_weight': data['dispatchedWeight'],
      if (data.containsKey('baleCount')) 'bale_count': data['baleCount'],
      if (data['vehiclePhotoUrls'] is List)
        'vehicle_photo_urls': jsonEncode(data['vehiclePhotoUrls']),
      if (data['weighbridgePhotoUrls'] is List)
        'weighbridge_photo_urls': jsonEncode(data['weighbridgePhotoUrls']),
      if (data.containsKey('vehicleDiffers'))
        'vehicle_differs': _sqliteValue(data['vehicleDiffers']),
      if (rejection is Map && rejection.containsKey('reason'))
        'rejection_reason': rejection['reason'],
      if (rejection is Map && rejection.containsKey('remarks'))
        'rejection_remarks': rejection['remarks'],
      if (decidedBy is Map && decidedBy.containsKey('name'))
        'decided_by_name': decidedBy['name'],
      if (rejection is Map && rejection.containsKey('at'))
        'approved_at': rejection['at'],
      if (data.containsKey('rejectionReason'))
        'rejection_reason': data['rejectionReason'],
      if (data.containsKey('rejectionRemarks'))
        'rejection_remarks': data['rejectionRemarks'],
      if (data['updatedAt'] != null) 'updated_at': data['updatedAt'],
    };
  }

  Map<String, Object?> _expenseServerValues(Map<Object?, Object?> data) => {
    if (data['status'] != null) 'status': data['status'],
    if (data['number'] != null) 'number': data['number'],
    if (data['amount'] != null) 'amount': data['amount'],
    if (data.containsKey('note')) 'note': data['note'],
    if (data['photoUrls'] is List)
      'receipt_photo_urls': jsonEncode(data['photoUrls']),
    if (data['createdAt'] != null) 'created_at': data['createdAt'],
    if (data['updatedAt'] != null) 'updated_at': data['updatedAt'],
    if (data['decision'] is Map &&
        (data['decision'] as Map)['by'] is Map &&
        ((data['decision'] as Map)['by'] as Map)['name'] != null)
      'decided_by_name': ((data['decision'] as Map)['by'] as Map)['name'],
    if (data['decision'] is Map &&
        (data['decision'] as Map).containsKey('reason'))
      'decision_reason': (data['decision'] as Map)['reason'],
    if (data['decision'] is Map &&
        (data['decision'] as Map).containsKey('remarks'))
      'decision_remarks': (data['decision'] as Map)['remarks'],
  };

  Map<String, Object?> _cashRequestServerValues(Map<Object?, Object?> data) {
    final decision = data['decision'];
    final decidedBy = decision is Map ? decision['by'] : null;
    return {
      if (data['number'] != null) 'number': data['number'],
      if (data['amount'] != null) 'amount': data['amount'],
      if (data['reason'] != null) 'reason': data['reason'],
      if (data['status'] != null) 'status': data['status'],
      if (decidedBy is Map && decidedBy['name'] != null)
        'decided_by_name': decidedBy['name'],
      if (decision is Map && decision.containsKey('reason'))
        'decision_note': decision['reason'],
      if (decision is Map && decision.containsKey('remarks'))
        'decision_remarks': decision['remarks'],
      if (data['createdAt'] != null) 'created_at': data['createdAt'],
      if (data['updatedAt'] != null) 'updated_at': data['updatedAt'],
    };
  }

  Map<String, Object?> _categoryRequestServerValues(
    Map<Object?, Object?> data,
  ) {
    final requestedBy = data['requestedBy'];
    final decision = data['decision'];
    final decisionBy = decision is Map ? decision['by'] : null;
    return <String, Object?>{
      if (data['number'] != null) 'number': data['number'],
      if (data['status'] != null) 'status': data['status'],
      if (requestedBy is Map && requestedBy['name'] != null)
        'requested_by_name': requestedBy['name'],
      if (decisionBy is Map && decisionBy['name'] != null)
        'decided_by_name': decisionBy['name'],
      if (decision is Map && decision.containsKey('at'))
        'decided_at': decision['at'],
      if (decision is Map && decision.containsKey('reason'))
        'decision_reason': decision['reason'],
    };
  }

  Map<String, Object?> _ragpickerServerValues(Map<Object?, Object?> data) => {
    if (data['number'] != null) 'number': data['number'],
    if (data['centerId'] != null) 'center_id': data['centerId'],
    if (data['name'] != null) 'name': data['name'],
    if (data.containsKey('phone')) 'phone': data['phone'],
    if (data.containsKey('idNumber')) 'id_number': data['idNumber'],
    if (data.containsKey('photoUrl')) 'photo_url': data['photoUrl'],
    if (data.containsKey('isActive'))
      'is_active': _sqliteValue(data['isActive']),
  };

  Map<String, Object?> _taskServerValues(Map<Object?, Object?> data) => {
    if (data['number'] != null) 'number': data['number'],
    if (data['status'] != null) 'status': data['status'],
    if (data.containsKey('note')) 'note': data['note'],
    if (data['completedAt'] != null) 'completed_at': data['completedAt'],
    if (data['photoUrls'] is List) 'photo_urls': jsonEncode(data['photoUrls']),
    if (data['referencePhotoUrls'] is List)
      'reference_photo_urls': jsonEncode(data['referencePhotoUrls']),
  };

  Map<String, Object?> _requestServerValues(Map<Object?, Object?> data) {
    final answer = data['answer'];
    return <String, Object?>{
      if (data['number'] != null) 'number': data['number'],
      if (data['centerId'] != null) 'center_id': data['centerId'],
      if (data['body'] != null) 'body': data['body'],
      if (data['priority'] != null) 'priority': data['priority'],
      if (data['status'] != null) 'status': data['status'],
      if (data.containsKey('followUpAt')) 'follow_up_at': data['followUpAt'],
      if (answer is Map && answer.containsKey('notes'))
        'answer': answer['notes']
      else if (data.containsKey('answer'))
        'answer': answer,
      if (answer is Map && answer.containsKey('at'))
        'answered_at': answer['at']
      else if (data.containsKey('answeredAt'))
        'answered_at': data['answeredAt'],
      if (data['photoUrls'] is List)
        'photo_urls': jsonEncode(data['photoUrls']),
      if (answer is Map && answer['photoUrls'] is List)
        'answer_photo_urls': jsonEncode(answer['photoUrls']),
      if (data['createdAt'] != null) 'created_at': data['createdAt'],
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

  Future<void> _replaceCollectionResponseLines(
    Transaction txn,
    String collectionId,
    Map<String, Object?> response,
  ) async {
    final data = response['data'];
    if (data is! Map || data['lines'] is! List) return;
    final lines = (data['lines'] as List).whereType<Map>().toList();
    final existingRows = await txn.query(
      DatabaseTables.collectionItems,
      columns: const ['id', 'item_id'],
      where: 'collection_id = ?',
      whereArgs: [collectionId],
    );
    final existingIdByItem = <String, String>{
      for (final row in existingRows)
        if (row['item_id'] is String && row['id'] is String)
          row['item_id']! as String: row['id']! as String,
    };
    final serverItemIds = lines
        .map((line) => line['itemId']?.toString())
        .whereType<String>()
        .toSet();
    for (final row in existingRows) {
      if (serverItemIds.contains(row['item_id'])) continue;
      await txn.delete(
        DatabaseTables.collectionItems,
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      final itemId = line['itemId']?.toString();
      if (itemId == null || itemId.isEmpty) continue;
      final itemExists = Sqflite.firstIntValue(
        await txn.rawQuery(
          'SELECT COUNT(*) FROM ${DatabaseTables.items} WHERE id = ?',
          [itemId],
        ),
      );
      if (itemExists == 0) continue;
      final values = <String, Object?>{
        'collection_id': collectionId,
        'item_id': itemId,
        'qty': line['collectedQty'] ?? line['verifiedQty'] ?? 0,
        'verified_qty': line['verifiedQty'],
        'rate': line['rate'],
        'amount': line['amount'],
        'photo_urls': jsonEncode(
          line['photoUrls'] is List ? line['photoUrls'] : const [],
        ),
        'sort_order': line['sortOrder'] ?? index,
      };
      final existingId = existingIdByItem[itemId];
      if (existingId == null) {
        await txn.insert(DatabaseTables.collectionItems, {
          'id': '$collectionId:$itemId',
          ...values,
        });
      } else {
        await txn.update(
          DatabaseTables.collectionItems,
          values,
          where: 'id = ?',
          whereArgs: [existingId],
        );
      }
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
    AppLogger.syncError('OUTBOX_FAILED', '#${item['seq']}: $error');
  }

  bool _hasInvalidPhotoUrlDetail(Map<String, Object?> response) {
    final error = response['error'];
    if (error is! Map || error['details'] is! List) return false;
    return (error['details'] as List).whereType<Map>().any(
      (detail) => detail['field']?.toString().startsWith('photoUrls.') == true,
    );
  }

  Future<bool> _retryRequestAnswerPhotos(Map<String, Object?> item) async {
    final attempts = (item['attempts'] as num?)?.toInt() ?? 0;
    if (attempts >= 1) return false;
    final seq = (item['seq'] as num).toInt();
    var retried = false;
    await _database.runInTransaction((txn) async {
      final rows = await txn.rawQuery(
        '''
        SELECT p.id
        FROM ${DatabaseTables.photos} p
        JOIN ${DatabaseTables.outboxPhotos} op ON op.photo_id = p.id
        WHERE op.outbox_seq = ?
        ORDER BY p.created_at ASC
        ''',
        [seq],
      );
      final photoIds = rows
          .map((row) => row['id'])
          .whereType<String>()
          .toList(growable: false);
      if (photoIds.isEmpty) return;
      final marks = List.filled(photoIds.length, '?').join(',');
      await txn.rawUpdate('''
        UPDATE ${DatabaseTables.photos}
        SET status = 'failed', remote_url = NULL, uploaded_at = NULL
        WHERE id IN ($marks)
        ''', photoIds);
      final decoded = jsonDecode(item['body']! as String);
      if (decoded is Map) {
        final body = Map<String, Object?>.from(decoded);
        body['photoUrls'] = photoIds;
        await txn.update(
          DatabaseTables.outbox,
          {
            'body': jsonEncode(body),
            'status': 'queued',
            'attempts': attempts + 1,
            'last_error': 'HTTP 422 INVALID_REQUEST photoUrls',
            'next_attempt_at': null,
          },
          where: 'seq = ?',
          whereArgs: [seq],
        );
        retried = true;
      }
    });
    if (!retried) return false;
    _log('REQUEST ANSWER #$seq proof photos queued for one re-upload');
    return true;
  }

  Future<void> _reconcileKnownFailedConflicts(String token) async {
    final failed = await _database.query(
      DatabaseTables.outbox,
      where: "status = 'failed' AND last_error IS NOT NULL",
      orderBy: 'seq ASC',
    );
    for (final row in failed) {
      final code = _knownMovedConflictCode(row['last_error'] as String?);
      if (code == null) continue;
      await _handleMovedRecordConflict(row, code, token);
    }
  }

  String? _knownMovedConflictCode(String? lastError) {
    final normalized = lastError?.toUpperCase() ?? '';
    for (final code in const [
      'CANCELLED',
      'DRAFT_DISCARDED',
      'ALREADY_SUBMITTED',
      'REJECTED',
    ]) {
      if (normalized.contains('409 $code')) return code;
    }
    return null;
  }

  Future<bool> _handleMovedRecordConflict(
    Map<String, Object?> item,
    String? rawCode,
    String token,
  ) async {
    final code = rawCode?.toUpperCase();
    final entity = item['entity'];
    final kind = item['kind'];
    if (code == 'CANCELLED' &&
        entity == DatabaseTables.tasks &&
        kind == 'complete') {
      await _reconcileCancelledTask(item);
      return true;
    }
    if (code == 'DRAFT_DISCARDED' &&
        entity == DatabaseTables.collections &&
        kind == 'draft_save') {
      await _reconcileDiscardedDraft(item);
      return true;
    }
    if (code == 'ALREADY_SUBMITTED' &&
        entity == DatabaseTables.collections &&
        (kind == 'draft_save' || kind == 'discard')) {
      await _reconcileAlreadySubmittedCollection(item, token);
      return true;
    }
    if (code == 'REJECTED' &&
        entity == DatabaseTables.transfers &&
        kind == 'handover') {
      await _reconcileRejectedTransfer(item, token);
      return true;
    }
    return false;
  }

  Future<void> _reconcileCancelledTask(Map<String, Object?> item) async {
    final taskId = item['entity_id']! as String;
    final localPaths = <String>[];
    await _database.runInTransaction((txn) async {
      localPaths.addAll(
        await _photoPaths(
          txn,
          where: 'owner_table = ? AND owner_id = ?',
          whereArgs: [DatabaseTables.tasks, taskId],
        ),
      );
      await _deleteOutboxItem(txn, (item['seq'] as num).toInt());
      await txn.delete(
        DatabaseTables.photos,
        where: 'owner_table = ? AND owner_id = ?',
        whereArgs: [DatabaseTables.tasks, taskId],
      );
      await txn.update(
        DatabaseTables.tasks,
        {
          'status': 'CANCELLED',
          'completed_at': null,
          'photo_urls': '[]',
          'sync_state': 'synced',
        },
        where: 'id = ?',
        whereArgs: [taskId],
      );
      await _insertConflictNotification(
        txn,
        code: 'CANCELLED',
        entity: DatabaseTables.tasks,
        entityId: taskId,
        title: 'Task cancelled',
        body: 'Your supervisor called off this task before completion synced.',
        deepLink: '/tasks',
      );
    });
    await _deleteLocalFiles(localPaths);
    AppLogger.sync('CONFLICT_RECONCILED', 'task_id=$taskId code=CANCELLED');
  }

  Future<void> _reconcileDiscardedDraft(Map<String, Object?> item) async {
    final collectionId = item['entity_id']! as String;
    final localPaths = <String>[];
    var deletedDraft = false;
    await _database.runInTransaction((txn) async {
      final draftRows = await txn.query(
        DatabaseTables.outbox,
        columns: const ['seq'],
        where: 'entity = ? AND entity_id = ? AND kind = ?',
        whereArgs: [DatabaseTables.collections, collectionId, 'draft_save'],
      );
      for (final draftRow in draftRows) {
        await _deleteOutboxItem(txn, (draftRow['seq'] as num).toInt());
      }
      final remaining = Sqflite.firstIntValue(
        await txn.rawQuery(
          'SELECT COUNT(*) FROM ${DatabaseTables.outbox} '
          'WHERE entity = ? AND entity_id = ?',
          [DatabaseTables.collections, collectionId],
        ),
      );
      if (remaining == 0) {
        localPaths.addAll(await _collectionPhotoPaths(txn, collectionId));
        await txn.rawDelete(
          '''
          DELETE FROM ${DatabaseTables.photos}
          WHERE (owner_table = ? AND owner_id = ?)
             OR (owner_table = ? AND owner_id IN (
               SELECT id FROM ${DatabaseTables.collectionItems}
               WHERE collection_id = ?
             ))
          ''',
          [
            DatabaseTables.collections,
            collectionId,
            DatabaseTables.collectionItems,
            collectionId,
          ],
        );
        await txn.delete(
          DatabaseTables.collectionItems,
          where: 'collection_id = ?',
          whereArgs: [collectionId],
        );
        await txn.delete(
          DatabaseTables.collections,
          where: 'id = ?',
          whereArgs: [collectionId],
        );
        deletedDraft = true;
      }
      await _insertConflictNotification(
        txn,
        code: 'DRAFT_DISCARDED',
        entity: DatabaseTables.collections,
        entityId: collectionId,
        title: 'Collection draft discarded',
        body: remaining == 0
            ? 'The office discarded this draft before it could sync.'
            : 'The office discarded an older draft save. Your queued submit is still waiting to sync.',
        deepLink: '/collections',
      );
    });
    await _deleteLocalFiles(localPaths);
    AppLogger.sync(
      'CONFLICT_RECONCILED',
      'collection_id=$collectionId code=DRAFT_DISCARDED '
          'draft_deleted=$deletedDraft',
    );
  }

  Future<void> _reconcileAlreadySubmittedCollection(
    Map<String, Object?> item,
    String token,
  ) async {
    final collectionId = item['entity_id']! as String;
    await _database.runInTransaction((txn) async {
      await _deleteOutboxItem(txn, (item['seq'] as num).toInt());
      if (!await _hasRemainingOutbox(
        txn,
        DatabaseTables.collections,
        collectionId,
      )) {
        await txn.update(
          DatabaseTables.collections,
          {'sync_state': 'synced'},
          where: 'id = ?',
          whereArgs: [collectionId],
        );
      }
      await _insertConflictNotification(
        txn,
        code: 'ALREADY_SUBMITTED',
        entity: DatabaseTables.collections,
        entityId: collectionId,
        title: 'Collection already submitted',
        body:
            'This collection moved on while your local write was waiting. The latest server copy will be restored.',
        deepLink: '/collections',
      );
    });

    final response = await _fetchConflictEntity(
      '/collections/$collectionId',
      token,
    );
    if (response != null) {
      await _database.runInTransaction((txn) async {
        if (await _hasRemainingOutbox(
          txn,
          DatabaseTables.collections,
          collectionId,
        )) {
          return;
        }
        final restored = await _restoreCollectionFromResponse(
          txn,
          collectionId,
          response,
        );
        if (restored) {
          await _replaceCollectionResponseLines(txn, collectionId, response);
        }
      });
    }
    AppLogger.sync(
      'CONFLICT_RECONCILED',
      'collection_id=$collectionId code=ALREADY_SUBMITTED '
          'server_refreshed=${response != null}',
    );
  }

  Future<void> _reconcileRejectedTransfer(
    Map<String, Object?> item,
    String token,
  ) async {
    final transferId = item['entity_id']! as String;
    final localPaths = <String>[];
    await _database.runInTransaction((txn) async {
      localPaths.addAll(
        await _photoPaths(
          txn,
          where:
              'owner_table = ? AND owner_id = ? '
              "AND field IN ('vehicle', 'weighbridge')",
          whereArgs: [DatabaseTables.transfers, transferId],
        ),
      );
      await _deleteOutboxItem(txn, (item['seq'] as num).toInt());
      await txn.delete(
        DatabaseTables.photos,
        where:
            'owner_table = ? AND owner_id = ? '
            "AND field IN ('vehicle', 'weighbridge')",
        whereArgs: [DatabaseTables.transfers, transferId],
      );
      await txn.update(
        DatabaseTables.transferItems,
        {'dispatched_qty': null},
        where: 'transfer_id = ?',
        whereArgs: [transferId],
      );
      await txn.update(
        DatabaseTables.transfers,
        {
          'status': 'REJECTED',
          'handed_over_at': null,
          'vehicle_plate': null,
          'driver_name': null,
          'dispatched_weight': null,
          'bale_count': null,
          'vehicle_photo_urls': '[]',
          'weighbridge_photo_urls': '[]',
          'gps_lat': null,
          'gps_lng': null,
          'sync_state': 'synced',
        },
        where: 'id = ?',
        whereArgs: [transferId],
      );
      await _insertConflictNotification(
        txn,
        code: 'REJECTED',
        entity: DatabaseTables.transfers,
        entityId: transferId,
        title: 'Transfer rejected',
        body: 'This transfer was rejected before the handover could sync.',
        deepLink: '/transfers',
      );
    });
    await _deleteLocalFiles(localPaths);

    final response = await _fetchConflictEntity(
      '/transfers/$transferId',
      token,
    );
    if (response != null) {
      final data = _responseData(response);
      final rejection = data['rejection'];
      final decidedBy = rejection is Map ? rejection['by'] : null;
      await _database.update(
        DatabaseTables.transfers,
        {
          'status': 'REJECTED',
          if (rejection is Map && rejection.containsKey('reason'))
            'rejection_reason': rejection['reason'],
          if (rejection is Map && rejection.containsKey('remarks'))
            'rejection_remarks': rejection['remarks'],
          if (decidedBy is Map && decidedBy.containsKey('name'))
            'decided_by_name': decidedBy['name'],
          if (rejection is Map && rejection.containsKey('at'))
            'approved_at': rejection['at'],
          'sync_state': 'synced',
        },
        where: 'id = ?',
        whereArgs: [transferId],
      );
      final reason = rejection is Map ? rejection['reason']?.toString() : null;
      final remarks = rejection is Map
          ? rejection['remarks']?.toString().trim()
          : null;
      await _database.update(
        DatabaseTables.notifications,
        {
          'title': 'Transfer refused',
          'body': [
            if (reason?.trim().isNotEmpty == true) reason!.trim(),
            if (remarks?.isNotEmpty == true) 'Remarks: $remarks',
          ].join('\n'),
        },
        where: 'id = ?',
        whereArgs: [
          'sync-conflict:REJECTED:${DatabaseTables.transfers}:$transferId',
        ],
      );
    }
    AppLogger.sync(
      'CONFLICT_RECONCILED',
      'transfer_id=$transferId code=REJECTED '
          'server_refreshed=${response != null}',
    );
  }

  Future<Map<String, Object?>?> _fetchConflictEntity(
    String resourcePath,
    String token,
  ) async {
    final logPath = '/api/v1/mobile$resourcePath';
    final stopwatch = Stopwatch()..start();
    AppLogger.apiRequest('GET', logPath, message: 'conflictRefresh=true');
    try {
      final response = await _client
          .get(
            Uri.parse('${AppConstants.apiBaseUrl}/mobile$resourcePath'),
            headers: {
              'accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        AppLogger.apiSuccess(
          'GET',
          logPath,
          statusCode: response.statusCode,
          duration: stopwatch.elapsed,
          message: 'conflictRefresh=true',
        );
        return _decodeObject(response.body);
      }
      AppLogger.apiError(
        'GET',
        logPath,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        error: 'conflictRefresh=true',
      );
    } catch (error) {
      AppLogger.apiError(
        'GET',
        logPath,
        duration: stopwatch.elapsed,
        error: error,
      );
    }
    return null;
  }

  Map<Object?, Object?> _responseData(Map<String, Object?> response) {
    final data = response['data'];
    return data is Map ? data : const <Object?, Object?>{};
  }

  Future<bool> _restoreCollectionFromResponse(
    Transaction txn,
    String collectionId,
    Map<String, Object?> response,
  ) async {
    final data = _responseData(response);
    final values = _collectionServerValues(data)..['sync_state'] = 'synced';
    final existing = await txn.query(
      DatabaseTables.collections,
      columns: const ['id'],
      where: 'id = ?',
      whereArgs: [collectionId],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      await txn.update(
        DatabaseTables.collections,
        values,
        where: 'id = ?',
        whereArgs: [collectionId],
      );
      return true;
    }

    final center = data['center'];
    final agent = data['agent'];
    final centerId = data['centerId'] ?? (center is Map ? center['id'] : null);
    final agentId = data['agentId'] ?? (agent is Map ? agent['id'] : null);
    final agentName =
        data['agentName'] ?? (agent is Map ? agent['name'] : null);
    final channel = data['type'] ?? data['channel'];
    if (centerId == null ||
        agentId == null ||
        agentName == null ||
        channel == null) {
      AppLogger.syncError(
        'CONFLICT_REFRESH_INCOMPLETE',
        'collection_id=$collectionId missing required server fields',
      );
      return false;
    }
    final centerExists = Sqflite.firstIntValue(
      await txn.rawQuery(
        'SELECT COUNT(*) FROM ${DatabaseTables.centers} WHERE id = ?',
        [centerId],
      ),
    );
    if (centerExists == 0) return false;
    await txn.insert(DatabaseTables.collections, {
      'id': collectionId,
      'center_id': centerId,
      'agent_id': agentId,
      'agent_name': agentName,
      'channel': channel,
      'status': data['status'] ?? 'SUBMITTED',
      'handover_photo_urls': '[]',
      'updated_at':
          data['updatedAt'] ?? DateTime.now().toUtc().toIso8601String(),
      'sync_state': 'synced',
      ...values,
    });
    return true;
  }

  Future<void> _deleteOutboxItem(Transaction txn, int seq) async {
    await txn.delete(
      DatabaseTables.outboxPhotos,
      where: 'outbox_seq = ?',
      whereArgs: [seq],
    );
    await txn.delete(DatabaseTables.outbox, where: 'seq = ?', whereArgs: [seq]);
  }

  Future<bool> _hasRemainingOutbox(
    Transaction txn,
    String entity,
    String entityId,
  ) async =>
      Sqflite.firstIntValue(
        await txn.rawQuery(
          'SELECT COUNT(*) FROM ${DatabaseTables.outbox} '
          'WHERE entity = ? AND entity_id = ?',
          [entity, entityId],
        ),
      ) !=
      0;

  Future<List<String>> _photoPaths(
    Transaction txn, {
    required String where,
    required List<Object?> whereArgs,
  }) async => (await txn.query(
    DatabaseTables.photos,
    columns: const ['local_path'],
    where: where,
    whereArgs: whereArgs,
  )).map((row) => row['local_path']).whereType<String>().toList();

  Future<List<String>> _collectionPhotoPaths(
    Transaction txn,
    String collectionId,
  ) async => (await txn.rawQuery(
    '''
        SELECT local_path FROM ${DatabaseTables.photos}
        WHERE (owner_table = ? AND owner_id = ?)
           OR (owner_table = ? AND owner_id IN (
             SELECT id FROM ${DatabaseTables.collectionItems}
             WHERE collection_id = ?
           ))
        ''',
    [
      DatabaseTables.collections,
      collectionId,
      DatabaseTables.collectionItems,
      collectionId,
    ],
  )).map((row) => row['local_path']).whereType<String>().toList();

  Future<void> _insertConflictNotification(
    Transaction txn, {
    required String code,
    required String entity,
    required String entityId,
    required String title,
    required String body,
    required String deepLink,
  }) => txn.insert(DatabaseTables.notifications, {
    'id': 'sync-conflict:$code:$entity:$entityId',
    'type': 'SYNC_CONFLICT',
    'title': title,
    'body': body,
    'deep_link': deepLink,
    'created_at': DateTime.now().toUtc().toIso8601String(),
    'sync_state': 'synced',
  }, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> _deleteLocalFiles(Iterable<String> paths) async {
    for (final path in paths.toSet()) {
      if (path.trim().isEmpty) continue;
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } on FileSystemException catch (error) {
        AppLogger.syncError(
          'PHOTO_FILE_DELETE',
          'path=${error.path ?? '[unknown]'} error=${error.message}',
        );
      }
    }
  }

  Future<void> _refreshTransferAfterConflict(
    Map<String, Object?> item,
    String token,
  ) async {
    final transferId = item['entity_id']! as String;
    final path = '/api/v1/mobile/transfers/$transferId';
    final stopwatch = Stopwatch()..start();
    AppLogger.apiRequest('GET', path, message: 'conflictRefresh=true');
    final response = await _client
        .get(
          Uri.parse('${AppConstants.apiBaseUrl}/mobile/transfers/$transferId'),
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(_timeout);
    final body = _decodeObject(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      AppLogger.apiSuccess(
        'GET',
        path,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        message: 'conflictRefresh=true',
      );
      await _complete(item, body);
      return;
    }
    AppLogger.apiError(
      'GET',
      path,
      statusCode: response.statusCode,
      duration: stopwatch.elapsed,
      error: 'conflictRefresh=true',
    );
    if (response.statusCode >= 500 ||
        response.statusCode == 408 ||
        response.statusCode == 429) {
      await _retry(item, 'Conflict refresh HTTP ${response.statusCode}');
      return;
    }
    await _fail(item, 'Conflict refresh HTTP ${response.statusCode}');
  }

  Future<void> _dropTransferDecision(
    Map<String, Object?> item,
    String error,
  ) async {
    await _database.runInTransaction((txn) async {
      await txn.delete(
        DatabaseTables.outboxPhotos,
        where: 'outbox_seq = ?',
        whereArgs: [item['seq']],
      );
      await txn.delete(
        DatabaseTables.outbox,
        where: 'seq = ?',
        whereArgs: [item['seq']],
      );
      await txn.update(
        DatabaseTables.transfers,
        {'sync_state': 'synced'},
        where: 'id = ?',
        whereArgs: [item['entity_id']],
      );
    });
    AppLogger.sync(
      'DECISION_DROPPED',
      'transfer_id=${item['entity_id']} error=$error',
    );
  }

  Future<int> _uploadWaitingPhotos(String token) async {
    // Repair rows created by the earlier unsupported enum before building the
    // batch request. Do not translate any other purpose values here.
    final repairedRagpickerPhotos = await _database.update(
      DatabaseTables.photos,
      {'purpose': 'RAGPICKER'},
      where: 'purpose = ?',
      whereArgs: ['RAGPICKER_PROFILE'],
    );
    if (repairedRagpickerPhotos > 0) {
      AppLogger.sqlite(
        'PHOTO_PURPOSE_REPAIRED',
        'rows=$repairedRagpickerPhotos RAGPICKER_PROFILE -> RAGPICKER',
      );
    }
    final repairedTaskPhotos = await _database.update(
      DatabaseTables.photos,
      {'purpose': 'TASK_COMPLETION'},
      where: 'purpose = ? AND (owner_table = ? OR field = ?)',
      whereArgs: ['TASK', DatabaseTables.tasks, 'completion'],
    );
    if (repairedTaskPhotos > 0) {
      AppLogger.sqlite(
        'PHOTO_PURPOSE_REPAIRED',
        'rows=$repairedTaskPhotos TASK -> TASK_COMPLETION',
      );
    }
    final repairedRequestPhotos = await _database.update(
      DatabaseTables.photos,
      {'purpose': 'REQUEST'},
      where: 'purpose = ? AND (owner_table = ? OR field = ?)',
      whereArgs: ['TASK', DatabaseTables.requests, 'request'],
    );
    if (repairedRequestPhotos > 0) {
      AppLogger.sqlite(
        'PHOTO_PURPOSE_REPAIRED',
        'rows=$repairedRequestPhotos TASK -> REQUEST',
      );
    }
    // Friday's working flow uploads the oldest pending photos first, then
    // resolves their ids to file URLs when dependent outbox rows are sent.
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
      final contentType = _photoContentType(localPath, row['content_type']);
      row['content_type'] = contentType;
      rows.add(row);
      await _database.update(
        DatabaseTables.photos,
        {'size_bytes': sizeBytes, 'content_type': contentType},
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
      const batchPath = '/api/v1/mobile/uploads/batch';
      final batchStopwatch = Stopwatch()..start();
      AppLogger.apiRequest('POST', batchPath, message: 'count=$rows');
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
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final responseSummary = response.body.length > 1200
            ? '${response.body.substring(0, 1200)}…'
            : response.body;
        AppLogger.apiError(
          'POST',
          batchPath,
          statusCode: response.statusCode,
          duration: batchStopwatch.elapsed,
          error: responseSummary,
        );
        throw HttpException(
          'Upload batch HTTP ${response.statusCode}: ${response.body}',
        );
      }
      AppLogger.apiSuccess(
        'POST',
        batchPath,
        statusCode: response.statusCode,
        duration: batchStopwatch.elapsed,
        message: 'count=${rows.length}',
      );
      final body = _decodeObject(response.body);
      final uploads = _uploadList(body);
      if (uploads.length != rows.length) {
        AppLogger.error(
          'PHOTO_BATCH_MISMATCH',
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
        final request = http.StreamedRequest('PUT', Uri.parse(uploadUrl))
          ..headers['content-type'] = source['content_type']! as String
          ..contentLength = await file.length();
        final uploadStopwatch = Stopwatch()..start();
        AppLogger.apiRequest('PUT', request.url.path, message: 'photoId=$id');
        final responseFuture = _client.send(request).timeout(_timeout);
        await file.openRead().pipe(request.sink);
        final put = await responseFuture;
        if (put.statusCode < 200 || put.statusCode >= 300) {
          AppLogger.apiError(
            'PUT',
            request.url.path,
            statusCode: put.statusCode,
            duration: uploadStopwatch.elapsed,
          );
          continue;
        }
        AppLogger.apiSuccess(
          'PUT',
          request.url.path,
          statusCode: put.statusCode,
          duration: uploadStopwatch.elapsed,
          message: 'photoId=$id',
        );
        await _persistUploadedPhoto(
          photoId: id,
          fileUrl: fileUrl,
          localPath: localPath,
          ownerTable: source['owner_table']! as String,
          ownerId: source['owner_id']! as String,
          photoField: source['field']! as String,
        );
        await _imageCache.storeLocalFileForUrl(fileUrl, file);
        uploadedCount++;
        AppLogger.sync(
          'PHOTO_UPLOADED',
          'photo_id=$id size_bytes=${source['size_bytes']}',
        );
      }
    } catch (error) {
      AppLogger.syncError('PHOTO_BATCH_FAILED', 'Upload will retry');
    } finally {
      await _database.rawUpdate(
        "UPDATE ${DatabaseTables.photos} SET status = 'failed' "
        "WHERE id IN ($marks) AND status = 'uploading'",
        ids,
      );
    }
    return uploadedCount;
  }

  /// Repairs queued rows written by older builds where an already-uploaded
  /// photo URL was only substituted in memory at request-send time.
  Future<void> _repairUploadedPhotoReferences() async {
    final rows = await _database.rawQuery('''
      SELECT DISTINCT p.id, p.remote_url, p.local_path,
        p.owner_table, p.owner_id, p.field
      FROM ${DatabaseTables.photos} p
      JOIN ${DatabaseTables.outboxPhotos} op ON op.photo_id = p.id
      JOIN ${DatabaseTables.outbox} o ON o.seq = op.outbox_seq
      WHERE p.status = 'uploaded'
        AND p.remote_url IS NOT NULL
        AND o.status IN ('queued', 'failed')
      ''');
    for (final row in rows) {
      await _persistUploadedPhoto(
        photoId: row['id']! as String,
        fileUrl: row['remote_url']! as String,
        localPath: row['local_path'] as String? ?? '',
        ownerTable: row['owner_table']! as String,
        ownerId: row['owner_id']! as String,
        photoField: row['field']! as String,
      );
    }
    if (rows.isNotEmpty) {
      AppLogger.sqlite(
        'PHOTO_REFERENCES_REPAIRED',
        'rows=${rows.length} outbox payload(s) now contain remote URLs',
      );
    }
  }

  /// Persists the uploaded URL everywhere before the dependent API call runs.
  ///
  /// Older code only replaced photo ids in memory inside [_resolvedBody]. That
  /// sent the correct value in ideal conditions, but left the SQL outbox body
  /// containing a local UUID. Persisting the replacement makes retries and
  /// process restarts use the exact same URL-bearing payload.
  Future<void> _persistUploadedPhoto({
    required String photoId,
    required String fileUrl,
    required String localPath,
    required String ownerTable,
    required String ownerId,
    required String photoField,
  }) async {
    await _database.runInTransaction((txn) async {
      await txn.update(
        DatabaseTables.photos,
        {
          'status': 'uploaded',
          'remote_url': fileUrl,
          'uploaded_at': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [photoId],
      );

      final linkedOutboxRows = await txn.rawQuery(
        '''
        SELECT o.seq, o.body
        FROM ${DatabaseTables.outbox} o
        JOIN ${DatabaseTables.outboxPhotos} op ON op.outbox_seq = o.seq
        WHERE op.photo_id = ?
        ''',
        [photoId],
      );
      for (final row in linkedOutboxRows) {
        final rawBody = row['body'] as String?;
        if (rawBody == null || rawBody.trim().isEmpty) continue;
        final resolvedBody = _replacePhotoIds(jsonDecode(rawBody), {
          photoId: fileUrl,
        });
        await txn.update(
          DatabaseTables.outbox,
          {'body': jsonEncode(resolvedBody)},
          where: 'seq = ?',
          whereArgs: [row['seq']],
        );
      }

      if (ownerTable != DatabaseTables.requests &&
          ownerTable != DatabaseTables.tasks) {
        return;
      }
      final ownerPhotoColumn = switch ((ownerTable, photoField)) {
        (DatabaseTables.requests, 'answer') => 'answer_photo_urls',
        (DatabaseTables.tasks, 'reference') => 'reference_photo_urls',
        _ => 'photo_urls',
      };
      final ownerRows = await txn.query(
        ownerTable,
        columns: [ownerPhotoColumn],
        where: 'id = ?',
        whereArgs: [ownerId],
        limit: 1,
      );
      if (ownerRows.isEmpty) return;
      final rawUrls = ownerRows.single[ownerPhotoColumn] as String?;
      final decodedUrls = rawUrls == null || rawUrls.trim().isEmpty
          ? <Object?>[]
          : jsonDecode(rawUrls);
      final urls = decodedUrls is List
          ? decodedUrls.map((value) => value.toString()).toList()
          : <String>[];
      var replaced = false;
      for (var index = 0; index < urls.length; index++) {
        if (urls[index] == localPath || urls[index] == photoId) {
          urls[index] = fileUrl;
          replaced = true;
        }
      }
      if (!replaced && !urls.contains(fileUrl)) urls.add(fileUrl);
      await txn.update(
        ownerTable,
        {ownerPhotoColumn: jsonEncode(urls)},
        where: 'id = ?',
        whereArgs: [ownerId],
      );
    });
  }

  String _photoContentType(String path, Object? storedValue) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.endsWith('.png')) return 'image/png';
    if (lowerPath.endsWith('.jpg') || lowerPath.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    final stored = storedValue?.toString().trim().toLowerCase();
    return stored == 'image/png' ? 'image/png' : 'image/jpeg';
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
        return (details.first as Map)['code']?.toString() ??
            error['code']?.toString();
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
    AppLogger.sync('OUTBOX', message);
  }
}
