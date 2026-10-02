import 'dart:async';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/bootstrap/data/bootstrap_database_applier.dart';
import 'package:eerl_app/features/bootstrap/data/bootstrap_remote_service.dart';
import 'package:eerl_app/features/bootstrap/data/bootstrap_repository.dart';
import 'package:eerl_app/features/bootstrap/model/bootstrap_response.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase.instance;
  late String databasePath;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(await getDatabasesPath(), 'eerl_bootstrap_test.db');
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() => database.clearDatabaseOnLogout());

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test(
    'first Bootstrap omits since and stores me, tables, and metadata',
    () async {
      await database.insert(DatabaseTables.myCenters, {
        'center_id': 'center-old',
        'is_primary': 0,
        'slip_date': '2026-10-01',
        'slip_last_count': 1,
      });
      await database.insert(DatabaseTables.myCenters, {
        'center_id': 'center-1',
        'is_primary': 1,
        'slip_date': '2026-10-01',
        'slip_last_count': 15,
      });

      final gateway = _FakeGateway([
        () async => _response(
          cursor: '48216',
          tables: {
            'items': {
              'replace': [_item('item-1', 'Cardboard')],
            },
            'collections': {
              'upserts': [_collection('collection-1', amount: 1145.7)],
              'deletes': <String>[],
            },
            'collection_items': {
              'upserts': [_collectionItem('line-1', 'collection-1')],
              'deletes': <String>[],
            },
          },
        ),
      ]);
      final service = _service(gateway, database);

      await service.triggerBootstrap(trigger: BootstrapTrigger.initialLogin);

      expect(gateway.requestedCursors, [isNull]);
      expect(await database.getSyncMeta('cursor'), '48216');
      expect(await database.getSyncMeta('scope_key'), 'scope-1');
      expect(
        await database.getSyncMeta('last_bootstrap_at'),
        '2026-10-01T12:00:00.000Z',
      );
      expect(await database.getSyncMeta('user_id'), 'user-1');
      expect(await database.getSyncMeta('supervisor_name'), 'Supervisor');
      expect(await database.query(DatabaseTables.myRoles), hasLength(2));
      final centers = await database.query(DatabaseTables.myCenters);
      expect(centers, hasLength(1));
      expect(centers.single['center_id'], 'center-1');
      expect(centers.single['slip_last_count'], 15);
      expect(await database.query(DatabaseTables.items), hasLength(1));
      expect(await database.query(DatabaseTables.collections), hasLength(1));
      expect(
        (await database.query(DatabaseTables.collections)).single['sync_state'],
        'synced',
      );
    },
  );

  test(
    'multi-page sync sends each returned cursor and stores the final one',
    () async {
      final gateway = _FakeGateway([
        () async => _response(cursor: 'A', hasMore: true),
        () async => _response(cursor: 'B', hasMore: true),
        () async => _response(cursor: 'C'),
      ]);

      await _service(
        gateway,
        database,
      ).triggerBootstrap(trigger: BootstrapTrigger.appOpen);

      expect(gateway.requestedCursors, [isNull, 'A', 'B']);
      expect(await database.getSyncMeta('cursor'), 'C');
    },
  );

  test(
    'delta changes only present tables and reference empty means clear',
    () async {
      await database.insert(DatabaseTables.items, _item('item-old', 'Old'));
      await database.insert(DatabaseTables.vehicles, _vehicle('vehicle-1'));
      await database.insert(
        DatabaseTables.expenses,
        _expense('expense-1', amount: 50, syncState: 'synced'),
      );
      await database.setSyncMeta('cursor', 'OLD');

      final firstGateway = _FakeGateway([
        () async => _response(
          cursor: 'NEW',
          tables: {
            'collections': {
              'upserts': [_collection('collection-1', amount: 10)],
            },
            'notifications': {
              'upserts': [_notification('notification-1')],
            },
          },
        ),
      ]);
      await _service(
        firstGateway,
        database,
      ).triggerBootstrap(trigger: BootstrapTrigger.appResume);

      expect(firstGateway.requestedCursors, ['OLD']);
      expect(
        (await database.query(DatabaseTables.items)).single['id'],
        'item-old',
      );
      expect(await database.query(DatabaseTables.vehicles), hasLength(1));
      expect(await database.query(DatabaseTables.expenses), hasLength(1));

      final clearItemsGateway = _FakeGateway([
        () async => _response(
          cursor: 'NEWER',
          tables: {
            'items': {'replace': <Map<String, Object?>>[]},
          },
        ),
      ]);
      await _service(
        clearItemsGateway,
        database,
      ).triggerBootstrap(trigger: BootstrapTrigger.pullToRefresh);
      expect(await database.query(DatabaseTables.items), isEmpty);
    },
  );

  test(
    'pending and failed records survive server upserts and deletes',
    () async {
      await database.insert(
        DatabaseTables.expenses,
        _expense('pending', amount: 500, syncState: 'pending'),
      );
      await database.insert(
        DatabaseTables.expenses,
        _expense('failed', amount: 700, syncState: 'failed'),
      );
      final applier = BootstrapDatabaseApplier(database: database);
      await applier.apply(
        _response(
          cursor: 'P1',
          tables: {
            'expenses': {
              'upserts': [
                _expense('pending', amount: 100)..remove('sync_state'),
                _expense('failed', amount: 100)..remove('sync_state'),
              ],
              'deletes': ['pending', 'failed'],
            },
          },
        ).data,
      );

      final rows = await database.query(DatabaseTables.expenses, orderBy: 'id');
      expect(rows, hasLength(2));
      expect(rows[0]['amount'], 700.0);
      expect(rows[0]['sync_state'], 'failed');
      expect(rows[1]['amount'], 500.0);
      expect(rows[1]['sync_state'], 'pending');
    },
  );

  test(
    'child sets replace synced parents but preserve pending parents',
    () async {
      await database.insert(
        DatabaseTables.collections,
        _collection('synced-parent', syncState: 'synced'),
      );
      await database.insert(
        DatabaseTables.collections,
        _collection('pending-parent', syncState: 'pending'),
      );
      await database.insert(
        DatabaseTables.collectionItems,
        _collectionItem('old-synced', 'synced-parent'),
      );
      await database.insert(
        DatabaseTables.collectionItems,
        _collectionItem('old-pending', 'pending-parent'),
      );

      await BootstrapDatabaseApplier(database: database).apply(
        _response(
          cursor: 'CHILD',
          tables: {
            'collections': {
              'upserts': [
                _collection('synced-parent')..remove('sync_state'),
                _collection('pending-parent')..remove('sync_state'),
              ],
            },
            'collection_items': {
              'upserts': [
                _collectionItem('new-1', 'synced-parent'),
                _collectionItem('new-2', 'synced-parent'),
                _collectionItem('blocked-new', 'pending-parent'),
              ],
            },
          },
        ).data,
      );

      final syncedChildren = await database.query(
        DatabaseTables.collectionItems,
        columns: const ['id'],
        where: 'collection_id = ?',
        whereArgs: const ['synced-parent'],
        orderBy: 'id',
      );
      final pendingChildren = await database.query(
        DatabaseTables.collectionItems,
        columns: const ['id'],
        where: 'collection_id = ?',
        whereArgs: const ['pending-parent'],
      );
      expect(syncedChildren.map((row) => row['id']), ['new-1', 'new-2']);
      expect(pendingChildren.single['id'], 'old-pending');
    },
  );

  test(
    'page failure rolls back table changes and cursor advancement',
    () async {
      await database.setSyncMeta('cursor', 'CURSOR_A');
      await database.insert(DatabaseTables.items, _item('old', 'Old'));

      final badExpense = _expense('bad', amount: 10)..remove('sync_state');
      badExpense['unknown_column'] = 'force rollback';
      final page = _response(
        cursor: 'CURSOR_B',
        tables: {
          'items': {
            'replace': [_item('new', 'New')],
          },
          'expenses': {
            'upserts': [badExpense],
          },
        },
      );

      await expectLater(
        BootstrapDatabaseApplier(database: database).apply(page.data),
        throwsFormatException,
      );
      expect(await database.getSyncMeta('cursor'), 'CURSOR_A');
      expect((await database.query(DatabaseTables.items)).single['id'], 'old');
    },
  );

  test('transfer child sets follow the parent sync state', () async {
    await database.insert(
      DatabaseTables.transfers,
      _transfer('synced-transfer', syncState: 'synced'),
    );
    await database.insert(
      DatabaseTables.transfers,
      _transfer('pending-transfer', syncState: 'pending'),
    );
    await database.insert(
      DatabaseTables.transferItems,
      _transferItem('old-synced', 'synced-transfer'),
    );
    await database.insert(
      DatabaseTables.transferItems,
      _transferItem('old-pending', 'pending-transfer'),
    );

    await BootstrapDatabaseApplier(database: database).apply(
      _response(
        cursor: 'TRANSFER-CHILD',
        tables: {
          'transfers': {
            'upserts': [
              _transfer('synced-transfer')..remove('sync_state'),
              _transfer('pending-transfer')..remove('sync_state'),
            ],
          },
          'transfer_items': {
            'upserts': [
              _transferItem('new-transfer-item', 'synced-transfer'),
              _transferItem('blocked-transfer-item', 'pending-transfer'),
            ],
          },
        },
      ).data,
    );

    final synced = await database.query(
      DatabaseTables.transferItems,
      columns: const ['id'],
      where: 'transfer_id = ?',
      whereArgs: const ['synced-transfer'],
    );
    final pending = await database.query(
      DatabaseTables.transferItems,
      columns: const ['id'],
      where: 'transfer_id = ?',
      whereArgs: const ['pending-transfer'],
    );
    expect(synced.single['id'], 'new-transfer-item');
    expect(pending.single['id'], 'old-pending');
  });

  test(
    'collection deletes clean synced children but preserve local work',
    () async {
      await database.insert(
        DatabaseTables.collections,
        _collection('server-parent', syncState: 'synced'),
      );
      await database.insert(
        DatabaseTables.collections,
        _collection('local-parent', syncState: 'pending'),
      );
      await database.insert(
        DatabaseTables.collectionItems,
        _collectionItem('server-child', 'server-parent'),
      );
      await database.insert(
        DatabaseTables.collectionItems,
        _collectionItem('local-child', 'local-parent'),
      );
      await database.insert(DatabaseTables.photos, {
        'id': 'uploaded-photo',
        'owner_table': DatabaseTables.collections,
        'owner_id': 'server-parent',
        'purpose': 'handover',
        'content_type': 'image/jpeg',
        'status': 'uploaded',
        'created_at': '2026-10-01T10:00:00.000Z',
      });
      await database.insert(DatabaseTables.photos, {
        'id': 'queued-photo',
        'owner_table': DatabaseTables.collections,
        'owner_id': 'server-parent',
        'purpose': 'handover',
        'content_type': 'image/jpeg',
        'status': 'queued',
        'created_at': '2026-10-01T10:00:00.000Z',
      });

      await BootstrapDatabaseApplier(database: database).apply(
        _response(
          cursor: 'DELETED',
          tables: {
            'collections': {
              'deletes': ['server-parent', 'local-parent'],
            },
          },
        ).data,
      );

      expect(
        await database.query(
          DatabaseTables.collections,
          where: 'id = ?',
          whereArgs: const ['server-parent'],
        ),
        isEmpty,
      );
      expect(
        await database.query(
          DatabaseTables.collectionItems,
          where: 'id = ?',
          whereArgs: const ['server-child'],
        ),
        isEmpty,
      );
      expect(
        await database.query(
          DatabaseTables.collections,
          where: 'id = ?',
          whereArgs: const ['local-parent'],
        ),
        hasLength(1),
      );
      expect(
        (await database.query(DatabaseTables.photos)).single['id'],
        'queued-photo',
      );
    },
  );

  test('invalid cursor resets once and retries without since', () async {
    await database.setSyncMeta('cursor', 'INVALID');
    await database.insert(DatabaseTables.items, _item('old', 'Old'));
    final gateway = _FakeGateway([
      () => Future<BootstrapResponse>.error(
        const BootstrapApiException(
          message: 'Invalid cursor',
          code: 'INVALID_CURSOR',
          statusCode: 400,
        ),
      ),
      () async => _response(
        cursor: 'FRESH',
        tables: {
          'items': {
            'replace': [_item('fresh', 'Fresh')],
          },
        },
      ),
    ]);

    await _service(
      gateway,
      database,
    ).triggerBootstrap(trigger: BootstrapTrigger.appOpen);

    expect(gateway.requestedCursors, ['INVALID', isNull]);
    expect(await database.getSyncMeta('cursor'), 'FRESH');
    expect((await database.query(DatabaseTables.items)).single['id'], 'fresh');
  });

  test(
    'different user fully clears old data and refetches without cursor',
    () async {
      await database.setSyncMeta('user_id', 'user-A');
      await database.setSyncMeta('cursor', 'A-CURSOR');
      await database.insert(DatabaseTables.outbox, {
        'method': 'POST',
        'path': '/collections',
        'entity': 'collection',
        'entity_id': 'old-local',
        'status': 'pending',
        'created_at': '2026-10-01T12:00:00.000Z',
      });
      final gateway = _FakeGateway([
        () async => _response(cursor: 'IGNORED', userId: 'user-B'),
        () async => _response(cursor: 'B-CURSOR', userId: 'user-B'),
      ]);

      await _service(
        gateway,
        database,
      ).triggerBootstrap(trigger: BootstrapTrigger.initialLogin);

      expect(gateway.requestedCursors, ['A-CURSOR', isNull]);
      expect(await database.getSyncMeta('user_id'), 'user-B');
      expect(await database.getSyncMeta('cursor'), 'B-CURSOR');
      expect(await database.query(DatabaseTables.outbox), isEmpty);
    },
  );

  test(
    'scope change preserves pending work and refetches without cursor',
    () async {
      await database.setSyncMeta('user_id', 'user-1');
      await database.setSyncMeta('scope_key', 'old-scope');
      await database.setSyncMeta('cursor', 'OLD-SCOPE-CURSOR');
      await database.insert(DatabaseTables.items, _item('old-item', 'Old'));
      await database.insert(
        DatabaseTables.expenses,
        _expense('pending-expense', amount: 42, syncState: 'pending'),
      );
      final gateway = _FakeGateway([
        () async => _response(cursor: 'IGNORED', scopeKey: 'new-scope'),
        () async => _response(
          cursor: 'NEW-SCOPE-CURSOR',
          scopeKey: 'new-scope',
          tables: {
            'items': {
              'replace': [_item('new-item', 'New')],
            },
          },
        ),
      ]);

      await _service(
        gateway,
        database,
      ).triggerBootstrap(trigger: BootstrapTrigger.appResume);

      expect(gateway.requestedCursors, ['OLD-SCOPE-CURSOR', isNull]);
      expect(await database.getSyncMeta('scope_key'), 'new-scope');
      expect(
        (await database.query(DatabaseTables.items)).single['id'],
        'new-item',
      );
      expect(
        (await database.query(DatabaseTables.expenses)).single['id'],
        'pending-expense',
      );
    },
  );

  test('401 expires the session without clearing offline data', () async {
    await database.insert(DatabaseTables.items, _item('cached-item', 'Cached'));
    var sessionExpired = false;
    final gateway = _FakeGateway([
      () => Future<BootstrapResponse>.error(
        const BootstrapApiException(
          message: 'Session expired',
          statusCode: 401,
        ),
      ),
    ]);
    final service = BootstrapSyncService.forTesting(
      gateway: gateway,
      database: database,
      accessTokenProvider: () async => 'expired-token',
      onSessionExpired: () async => sessionExpired = true,
    );

    await service.triggerBootstrap(trigger: BootstrapTrigger.appOpen);

    expect(sessionExpired, isTrue);
    expect(service.sessionExpired, isTrue);
    expect(
      (await database.query(DatabaseTables.items)).single['id'],
      'cached-item',
    );
  });

  test(
    'concurrent triggers run serially and coalesce into one extra run',
    () async {
      final firstPage = Completer<BootstrapResponse>();
      final gateway = _FakeGateway([
        () => firstPage.future,
        () async => _response(cursor: 'SECOND'),
      ]);
      final service = _service(gateway, database);

      final first = service.triggerBootstrap(trigger: BootstrapTrigger.appOpen);
      await Future<void>.delayed(Duration.zero);
      final second = service.triggerBootstrap(
        trigger: BootstrapTrigger.reconnect,
      );
      final third = service.triggerBootstrap(
        trigger: BootstrapTrigger.appResume,
      );
      firstPage.complete(_response(cursor: 'FIRST'));
      await Future.wait([first, second, third]);

      expect(gateway.calls, 2);
      expect(gateway.maximumConcurrentCalls, 1);
      expect(gateway.requestedCursors, [isNull, 'FIRST']);
      expect(await database.getSyncMeta('cursor'), 'SECOND');
    },
  );
}

BootstrapSyncService _service(_FakeGateway gateway, AppDatabase database) =>
    BootstrapSyncService.forTesting(
      gateway: gateway,
      database: database,
      accessTokenProvider: () async => 'test-token',
    );

class _FakeGateway implements BootstrapGateway {
  _FakeGateway(this._responses);

  final List<Future<BootstrapResponse> Function()> _responses;
  final List<String?> requestedCursors = [];
  int calls = 0;
  int _activeCalls = 0;
  int maximumConcurrentCalls = 0;

  @override
  Future<BootstrapResponse> fetch({
    required String accessToken,
    String? since,
  }) async {
    calls++;
    requestedCursors.add(since);
    _activeCalls++;
    if (_activeCalls > maximumConcurrentCalls) {
      maximumConcurrentCalls = _activeCalls;
    }
    try {
      if (_responses.isEmpty) throw StateError('No fake response queued');
      return await _responses.removeAt(0)();
    } finally {
      _activeCalls--;
    }
  }
}

BootstrapResponse _response({
  required String cursor,
  bool hasMore = false,
  String userId = 'user-1',
  String scopeKey = 'scope-1',
  Map<String, Object?> tables = const {},
}) {
  return BootstrapResponse.fromJson({
    'data': {
      'cursor': cursor,
      'hasMore': hasMore,
      'full': false,
      'serverTime': '2026-10-01T12:00:00.000Z',
      'me': {
        'scopeKey': scopeKey,
        'user': {
          'id': userId,
          'name': 'Test User',
          'phone': '+919800000000',
          'photoUrl': null,
        },
        'roles': [
          {
            'key': 'AGENT',
            'name': 'Collection Point Agent',
            'modules': ['HOME', 'COLLECTION'],
          },
          {
            'key': 'SUPERVISOR',
            'name': 'Collection Supervisor',
            'modules': ['HOME', 'VERIFICATION'],
          },
        ],
        'centers': [
          {
            'id': 'center-1',
            'isPrimary': true,
            'agentNumber': 1,
            'slipCounter': {'date': '2026-10-01', 'lastCount': 12},
          },
        ],
        'supervisor': {'name': 'Supervisor', 'phone': '+919811111111'},
        'session': {'expiresAt': '2026-10-08T12:00:00.000Z'},
      },
      'tables': tables,
    },
  });
}

Map<String, Object?> _item(String id, String name) => {
  'id': id,
  'name': name,
  'category_name': 'CAT-4 Other',
  'material_type': 'NON_PLASTIC',
  'colour': '#7A5BA6',
  'hsn_code': null,
  'unit_code': 'KG',
  'unit_name': 'Kilogram',
};

Map<String, Object?> _vehicle(String id) => {
  'id': id,
  'center_id': 'center-1',
  'plate_number': 'GJ-05-BX-1234',
  'type_id': 'type-1',
  'type_name': 'Mini Truck',
  'capacity_kg': 3000.0,
  'driver_name': 'Driver',
  'is_active': 1,
  'sync_state': 'synced',
};

Map<String, Object?> _collection(
  String id, {
  double amount = 1,
  String? syncState,
}) {
  return {
    'id': id,
    'center_id': 'center-1',
    'agent_id': 'user-1',
    'agent_name': 'Agent',
    'channel': 'RAMP',
    'status': 'APPROVED',
    'slip_number': null,
    'collected_at': '2026-10-01T10:00:00.000Z',
    'vehicle_id': null,
    'mrf_person_id': null,
    'ragpicker_id': null,
    'given_by_name': null,
    'handed_over_by': null,
    'paid_by': 'CASH',
    'takes_payment': 1,
    'total_amount': amount,
    'handover_photo_urls': '[]',
    'rejection_reason': null,
    'verified_by_name': null,
    'verified_at': null,
    'updated_at': '2026-10-01T10:00:00.000Z',
    'sync_state': ?syncState,
  };
}

Map<String, Object?> _collectionItem(String id, String collectionId) => {
  'id': id,
  'collection_id': collectionId,
  'item_id': 'item-1',
  'qty': 1.0,
  'verified_qty': 1.0,
  'rate': 10.0,
  'amount': 10.0,
  'photo_urls': '[]',
  'sort_order': 0,
};

Map<String, Object?> _expense(
  String id, {
  required num amount,
  String? syncState,
}) => {
  'id': id,
  'center_id': 'center-1',
  'user_id': 'user-1',
  'user_name': 'Agent',
  'category_id': 'category-1',
  'amount': amount.toDouble(),
  'note': null,
  'status': 'PENDING',
  'number': null,
  'receipt_photo_urls': '[]',
  'decided_by_name': null,
  'decision_reason': null,
  'created_at': '2026-10-01T10:00:00.000Z',
  'updated_at': null,
  'sync_state': ?syncState,
};

Map<String, Object?> _notification(String id) => {
  'id': id,
  'type': 'COLLECTION_VERIFIED',
  'title': 'Collection approved',
  'body': null,
  'deep_link': null,
  'created_at': '2026-10-01T10:00:00.000Z',
  'read_at': null,
};

Map<String, Object?> _transfer(String id, {String? syncState}) => {
  'id': id,
  'center_id': 'center-1',
  'type': 'STOCK_TRANSFER',
  'status': 'APPROVED',
  'number': null,
  'destination_id': 'destination-1',
  'destination_name': 'Plant',
  'truck_expected_at': null,
  'fixed_qty': null,
  'estimated_expense': null,
  'vehicle_plate': null,
  'requested_by': 'user-1',
  'requested_by_name': 'Agent',
  'requested_at': '2026-10-01T10:00:00.000Z',
  'decided_by_name': null,
  'approved_at': null,
  'rejection_reason': null,
  'handed_over_at': null,
  'photo_urls': '[]',
  'updated_at': null,
  'sync_state': ?syncState,
};

Map<String, Object?> _transferItem(String id, String transferId) => {
  'id': id,
  'transfer_id': transferId,
  'item_id': 'item-1',
  'qty': 10.0,
  'dispatched_qty': 10.0,
};
