import 'dart:convert';
import 'dart:io';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.instance;
  late String databasePath;
  late Directory tempDirectory;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(
      await getDatabasesPath(),
      'outgoing_conflict_reconciliation_test.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
    tempDirectory = await Directory.systemTemp.createTemp(
      'outgoing_conflict_reconciliation_',
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.accessTokenKey: 'conflict-test-token',
    });
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    for (final id in ['item-old', 'item-server']) {
      await database.insert(DatabaseTables.items, {
        'id': id,
        'name': id,
        'category_name': 'Plastic',
        'material_type': 'PLASTIC',
        'unit_code': 'KG',
        'unit_name': 'Kilogram',
        'is_active': 1,
      });
    }
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
    await tempDirectory.delete(recursive: true);
  });

  test('409 CANCELLED drops task completion and its local proof', () async {
    await _insertTask(database, status: 'COMPLETED', syncState: 'pending');
    final proof = await _photoFile(tempDirectory, 'cancelled-task.jpg');
    final photoId = await _insertPhoto(
      database,
      ownerTable: DatabaseTables.tasks,
      ownerId: 'task-1',
      field: 'completion',
      localPath: proof.path,
    );
    final seq = await _insertOutbox(
      database,
      method: 'POST',
      path: '/tasks/task-1/complete',
      entity: DatabaseTables.tasks,
      entityId: 'task-1',
      kind: 'complete',
      body: {
        'note': 'Done',
        'photoUrls': [photoId],
      },
    );
    await _linkPhoto(database, seq, photoId);

    var requests = 0;
    final service = _service(
      database,
      MockClient((_) async {
        requests++;
        return _conflict('CANCELLED');
      }),
    );
    await service.drain();

    expect(requests, 1);
    expect(await database.query(DatabaseTables.outbox), isEmpty);
    expect(await database.query(DatabaseTables.outboxPhotos), isEmpty);
    expect(await database.query(DatabaseTables.photos), isEmpty);
    expect(await proof.exists(), isFalse);
    final task = (await database.query(DatabaseTables.tasks)).single;
    expect(task['status'], 'CANCELLED');
    expect(task['completed_at'], isNull);
    expect(task['photo_urls'], '[]');
    expect(task['sync_state'], 'synced');
    expect(await database.query(DatabaseTables.notifications), hasLength(1));
  });

  test('failed legacy CANCELLED is reconciled without sending again', () async {
    await _insertTask(database, status: 'COMPLETED', syncState: 'failed');
    await _insertOutbox(
      database,
      method: 'POST',
      path: '/tasks/task-1/complete',
      entity: DatabaseTables.tasks,
      entityId: 'task-1',
      kind: 'complete',
      status: 'failed',
      lastError: 'HTTP 409 CANCELLED',
    );
    var requests = 0;
    await _service(
      database,
      MockClient((_) async {
        requests++;
        return http.Response('{}', 500);
      }),
    ).drain();

    expect(requests, 0);
    expect(await database.query(DatabaseTables.outbox), isEmpty);
    final task = (await database.query(DatabaseTables.tasks)).single;
    expect(task['status'], 'CANCELLED');
    expect(task['sync_state'], 'synced');
  });

  test('409 DRAFT_DISCARDED removes an unsubmitted local draft', () async {
    await _insertCollection(database);
    await database.insert(DatabaseTables.collectionItems, {
      'id': 'line-old',
      'collection_id': 'collection-1',
      'item_id': 'item-old',
      'qty': 4.0,
      'photo_urls': '[]',
      'sort_order': 0,
    });
    final proof = await _photoFile(tempDirectory, 'discarded-draft.jpg');
    await _insertPhoto(
      database,
      ownerTable: DatabaseTables.collectionItems,
      ownerId: 'line-old',
      field: 'item',
      localPath: proof.path,
    );
    await _insertOutbox(
      database,
      method: 'PUT',
      path: '/collections/collection-1',
      entity: DatabaseTables.collections,
      entityId: 'collection-1',
      kind: 'draft_save',
      body: {'centerId': 'center-1'},
    );

    await _service(
      database,
      MockClient((_) async => _conflict('DRAFT_DISCARDED')),
    ).drain();

    expect(await database.query(DatabaseTables.outbox), isEmpty);
    expect(await database.query(DatabaseTables.collections), isEmpty);
    expect(await database.query(DatabaseTables.collectionItems), isEmpty);
    expect(await database.query(DatabaseTables.photos), isEmpty);
    expect(await proof.exists(), isFalse);
  });

  test('409 DRAFT_DISCARDED keeps a draft that has a queued submit', () async {
    await _insertCollection(database);
    await _insertOutbox(
      database,
      method: 'PUT',
      path: '/collections/collection-1',
      entity: DatabaseTables.collections,
      entityId: 'collection-1',
      kind: 'draft_save',
      body: {'centerId': 'center-1'},
    );
    final submitSeq = await _insertOutbox(
      database,
      method: 'PUT',
      path: '/collections/collection-1',
      entity: DatabaseTables.collections,
      entityId: 'collection-1',
      kind: 'submit',
      body: {'centerId': 'center-1', 'lines': []},
    );
    await database.update(
      DatabaseTables.outbox,
      {'next_attempt_at': '2999-01-01T00:00:00.000Z'},
      where: 'seq = ?',
      whereArgs: [submitSeq],
    );

    await _service(
      database,
      MockClient((_) async => _conflict('DRAFT_DISCARDED')),
    ).drain();

    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(outbox['seq'], submitSeq);
    expect(outbox['kind'], 'submit');
    expect(await database.query(DatabaseTables.collections), hasLength(1));
  });

  test('409 ALREADY_SUBMITTED restores server collection and lines', () async {
    await _insertCollection(database);
    await database.insert(DatabaseTables.collectionItems, {
      'id': 'line-old',
      'collection_id': 'collection-1',
      'item_id': 'item-old',
      'qty': 4.0,
      'photo_urls': '[]',
      'sort_order': 0,
    });
    await _insertOutbox(
      database,
      method: 'PUT',
      path: '/collections/collection-1',
      entity: DatabaseTables.collections,
      entityId: 'collection-1',
      kind: 'draft_save',
      body: {'centerId': 'center-1'},
    );

    var requests = 0;
    await _service(
      database,
      MockClient((request) async {
        requests++;
        if (request.method == 'PUT') return _conflict('ALREADY_SUBMITTED');
        expect(request.method, 'GET');
        expect(request.url.path, '/api/v1/mobile/collections/collection-1');
        return _submittedCollectionResponse();
      }),
    ).drain();

    expect(requests, 2);
    expect(await database.query(DatabaseTables.outbox), isEmpty);
    final collection = (await database.query(
      DatabaseTables.collections,
    )).single;
    expect(collection['status'], 'SUBMITTED');
    expect(collection['slip_number'], 'COL-001');
    expect(collection['sync_state'], 'synced');
    final lines = await database.query(DatabaseTables.collectionItems);
    expect(lines, hasLength(1));
    expect(lines.single['item_id'], 'item-server');
    expect(lines.single['qty'], 5.0);
    expect(lines.single['verified_qty'], 4.5);
  });

  test(
    '409 ALREADY_SUBMITTED restores a locally discarded collection',
    () async {
      await _insertOutbox(
        database,
        method: 'DELETE',
        path: '/collections/collection-1',
        entity: DatabaseTables.collections,
        entityId: 'collection-1',
        kind: 'discard',
      );

      await _service(
        database,
        MockClient((request) async {
          if (request.method == 'DELETE') {
            return _conflict('ALREADY_SUBMITTED');
          }
          return _submittedCollectionResponse();
        }),
      ).drain();

      expect(await database.query(DatabaseTables.outbox), isEmpty);
      final collection = (await database.query(
        DatabaseTables.collections,
      )).single;
      expect(collection['center_id'], 'center-1');
      expect(collection['agent_id'], 'agent-1');
      expect(collection['channel'], 'D2D');
      expect(collection['status'], 'SUBMITTED');
      expect(collection['sync_state'], 'synced');
      final lines = await database.query(DatabaseTables.collectionItems);
      expect(lines, hasLength(1));
      expect(lines.single['item_id'], 'item-server');
    },
  );

  test(
    'ALREADY_SUBMITTED GET failure still unblocks Bootstrap overwrite',
    () async {
      await _insertCollection(database);
      await _insertOutbox(
        database,
        method: 'PUT',
        path: '/collections/collection-1',
        entity: DatabaseTables.collections,
        entityId: 'collection-1',
        kind: 'draft_save',
      );

      await _service(
        database,
        MockClient(
          (request) async => request.method == 'PUT'
              ? _conflict('ALREADY_SUBMITTED')
              : http.Response('{}', 503),
        ),
      ).drain();

      expect(await database.query(DatabaseTables.outbox), isEmpty);
      final collection = (await database.query(
        DatabaseTables.collections,
      )).single;
      expect(collection['sync_state'], 'synced');
    },
  );

  test('409 REJECTED clears dispatch and restores rejection reason', () async {
    await _insertTransfer(database);
    await database.insert(DatabaseTables.transferItems, {
      'id': 'transfer-line-1',
      'transfer_id': 'transfer-1',
      'item_id': 'item-old',
      'qty': 8.0,
      'dispatched_qty': 7.5,
    });
    final vehiclePhoto = await _photoFile(tempDirectory, 'vehicle.jpg');
    final weighbridgePhoto = await _photoFile(tempDirectory, 'weighbridge.jpg');
    final vehiclePhotoId = await _insertPhoto(
      database,
      ownerTable: DatabaseTables.transfers,
      ownerId: 'transfer-1',
      field: 'vehicle',
      localPath: vehiclePhoto.path,
    );
    final weighbridgePhotoId = await _insertPhoto(
      database,
      ownerTable: DatabaseTables.transfers,
      ownerId: 'transfer-1',
      field: 'weighbridge',
      localPath: weighbridgePhoto.path,
    );
    final seq = await _insertOutbox(
      database,
      method: 'POST',
      path: '/transfers/transfer-1/handover',
      entity: DatabaseTables.transfers,
      entityId: 'transfer-1',
      kind: 'handover',
      body: {
        'vehiclePhotoUrls': [vehiclePhotoId],
        'weighbridgePhotoUrls': [weighbridgePhotoId],
      },
    );
    await _linkPhoto(database, seq, vehiclePhotoId);
    await _linkPhoto(database, seq, weighbridgePhotoId);

    var requests = 0;
    await _service(
      database,
      MockClient((request) async {
        requests++;
        if (request.method == 'POST') return _conflict('REJECTED');
        expect(request.url.path, '/api/v1/mobile/transfers/transfer-1');
        return http.Response(
          jsonEncode({
            'data': {
              'id': 'transfer-1',
              'status': 'REJECTED',
              'rejection': {
                'reason': 'Dispatch was cancelled by the office.',
                'remarks': 'The receiving plant is closed today.',
                'by': {'name': 'Supervisor One'},
                'at': '2026-10-16T07:00:00.000Z',
              },
            },
          }),
          200,
        );
      }),
    ).drain();

    expect(requests, 2);
    expect(await database.query(DatabaseTables.outbox), isEmpty);
    expect(await database.query(DatabaseTables.photos), isEmpty);
    expect(await vehiclePhoto.exists(), isFalse);
    expect(await weighbridgePhoto.exists(), isFalse);
    final transfer = (await database.query(DatabaseTables.transfers)).single;
    expect(transfer['status'], 'REJECTED');
    expect(transfer['vehicle_plate'], isNull);
    expect(transfer['driver_name'], isNull);
    expect(transfer['dispatched_weight'], isNull);
    expect(transfer['vehicle_photo_urls'], '[]');
    expect(transfer['weighbridge_photo_urls'], '[]');
    expect(
      transfer['rejection_reason'],
      'Dispatch was cancelled by the office.',
    );
    expect(
      transfer['rejection_remarks'],
      'The receiving plant is closed today.',
    );
    expect(transfer['decided_by_name'], 'Supervisor One');
    expect(transfer['approved_at'], '2026-10-16T07:00:00.000Z');
    final notification = (await database.query(
      DatabaseTables.notifications,
    )).single;
    expect(notification['title'], 'Transfer refused');
    expect(
      notification['body'],
      'Dispatch was cancelled by the office.\n'
      'Remarks: The receiving plant is closed today.',
    );
    final line = (await database.query(DatabaseTables.transferItems)).single;
    expect(line['dispatched_qty'], isNull);
  });

  test('409 ALREADY_DISPATCHED remains a real failed refusal', () async {
    await _insertTransfer(database);
    await _insertOutbox(
      database,
      method: 'POST',
      path: '/transfers/transfer-1/handover',
      entity: DatabaseTables.transfers,
      entityId: 'transfer-1',
      kind: 'handover',
    );

    await _service(
      database,
      MockClient((_) async => _conflict('ALREADY_DISPATCHED')),
    ).drain();

    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(outbox['status'], 'failed');
    expect(outbox['last_error'], 'HTTP 409 ALREADY_DISPATCHED');
    final transfer = (await database.query(DatabaseTables.transfers)).single;
    expect(transfer['status'], 'DISPATCHED');
    expect(transfer['sync_state'], 'failed');
  });
}

OutgoingSyncService _service(AppDatabase database, http.Client client) =>
    OutgoingSyncService(
      database: database,
      client: client,
      internetAccessChecker: () async => true,
    );

http.Response _conflict(String code) => http.Response(
  jsonEncode({
    'error': {'code': code, 'message': code},
  }),
  409,
);

http.Response _submittedCollectionResponse() => http.Response(
  jsonEncode({
    'data': {
      'id': 'collection-1',
      'center': {'id': 'center-1', 'name': 'Center One'},
      'type': 'D2D',
      'status': 'SUBMITTED',
      'slipNumber': 'COL-001',
      'collectedAt': '2026-10-16T06:00:00.000Z',
      'updatedAt': '2026-10-16T06:05:00.000Z',
      'agent': {'id': 'agent-1', 'name': 'Agent One'},
      'takesPayment': true,
      'paidBy': 'CASH',
      'totals': {'amount': 90.0},
      'gps': {'lat': 21.17, 'lng': 72.83},
      'lines': [
        {
          'itemId': 'item-server',
          'collectedQty': 5.0,
          'verifiedQty': 4.5,
          'rate': 20.0,
          'amount': 90.0,
          'photoUrls': ['https://example.test/line.jpg'],
          'sortOrder': 0,
        },
      ],
    },
  }),
  200,
);

Future<File> _photoFile(Directory directory, String name) async {
  final file = File(p.join(directory.path, name));
  await file.writeAsBytes(const [1, 2, 3, 4]);
  return file;
}

Future<String> _insertPhoto(
  AppDatabase database, {
  required String ownerTable,
  required String ownerId,
  required String field,
  required String localPath,
}) async {
  final id = '$ownerId-$field-photo';
  await database.insert(DatabaseTables.photos, {
    'id': id,
    'owner_table': ownerTable,
    'owner_id': ownerId,
    'field': field,
    'purpose': field == 'completion'
        ? 'TASK_COMPLETION'
        : field == 'item'
        ? 'COLLECTION_LINE'
        : 'TRANSFER_HANDOVER',
    'content_type': 'image/jpeg',
    'local_path': localPath,
    'remote_url': 'https://example.test/$id.jpg',
    'status': 'uploaded',
    'size_bytes': 4,
    'created_at': '2026-10-16T05:00:00.000Z',
    'uploaded_at': '2026-10-16T05:01:00.000Z',
  });
  return id;
}

Future<int> _insertOutbox(
  AppDatabase database, {
  required String method,
  required String path,
  required String entity,
  required String entityId,
  required String kind,
  Map<String, Object?>? body,
  String status = 'queued',
  String? lastError,
}) => database.insert(DatabaseTables.outbox, {
  'method': method,
  'path': path,
  'body': body == null ? null : jsonEncode(body),
  'entity': entity,
  'entity_id': entityId,
  'kind': kind,
  'status': status,
  'attempts': 0,
  'last_error': lastError,
  'created_at': '2026-10-16T05:00:00.000Z',
});

Future<void> _linkPhoto(AppDatabase database, int seq, String photoId) =>
    database.insert(DatabaseTables.outboxPhotos, {
      'outbox_seq': seq,
      'photo_id': photoId,
    });

Future<void> _insertTask(
  AppDatabase database, {
  required String status,
  required String syncState,
}) => database.insert(DatabaseTables.tasks, {
  'id': 'task-1',
  'number': 'TSK-001',
  'center_id': 'center-1',
  'assigned_to': 'agent-1',
  'assigned_to_name': 'Agent One',
  'assigned_by': 'supervisor-1',
  'assigned_by_name': 'Supervisor One',
  'title': 'Check stock',
  'note': 'Completed locally',
  'description': 'Check stock.',
  'priority': 'HIGH',
  'status': status,
  'completed_at': '2026-10-16T05:00:00.000Z',
  'photo_urls': '[]',
  'created_at': '2026-10-16T04:00:00.000Z',
  'sync_state': syncState,
});

Future<void> _insertCollection(AppDatabase database) =>
    database.insert(DatabaseTables.collections, {
      'id': 'collection-1',
      'center_id': 'center-1',
      'agent_id': 'agent-1',
      'agent_name': 'Agent One',
      'channel': 'D2D',
      'status': 'DRAFT',
      'handover_photo_urls': '[]',
      'updated_at': '2026-10-16T05:00:00.000Z',
      'sync_state': 'pending',
    });

Future<void> _insertTransfer(AppDatabase database) =>
    database.insert(DatabaseTables.transfers, {
      'id': 'transfer-1',
      'center_id': 'center-1',
      'type': 'STOCK_TRANSFER',
      'status': 'DISPATCHED',
      'vehicle_plate': 'GJ-05-AB-1234',
      'driver_name': 'Driver One',
      'dispatched_weight': 7.5,
      'bale_count': 2,
      'vehicle_photo_urls': '["vehicle"]',
      'weighbridge_photo_urls': '["weighbridge"]',
      'requested_by': 'agent-1',
      'requested_by_name': 'Agent One',
      'requested_at': '2026-10-16T04:00:00.000Z',
      'handed_over_at': '2026-10-16T05:00:00.000Z',
      'gps_lat': 21.17,
      'gps_lng': 72.83,
      'photo_urls': '[]',
      'sync_state': 'pending',
    });
