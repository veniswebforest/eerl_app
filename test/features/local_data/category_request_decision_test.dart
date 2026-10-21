import 'dart:convert';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.instance;
  final repository = EerlLocalRepository.instance;
  late String databasePath;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(
      await getDatabasesPath(),
      'category_request_decision_test.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.accessTokenKey: 'supervisor-token',
    });
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await database.insert(DatabaseTables.centers, {
      'id': 'center-2',
      'name': 'Center Two',
    });
    await database.setSyncMeta('active_center_id', 'center-1');
    await database.setSyncMeta('user_id', 'supervisor-1');
    await database.setSyncMeta('user_name', 'Supervisor One');
    await _insertRequest(database, id: 'category-1', centerId: 'center-1');
    await _insertRequest(database, id: 'category-2', centerId: 'center-2');
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('approve updates the row and queues exact decide payload', () async {
    await repository.decideCategoryRequest(
      requestId: 'category-1',
      outcome: 'APPROVED',
    );

    final stored = (await database.query(
      DatabaseTables.categoryRequests,
      where: 'id = ?',
      whereArgs: ['category-1'],
    )).single;
    expect(stored['status'], 'APPROVED');
    expect(stored['decided_by_name'], 'Supervisor One');
    expect(stored['decided_at'], isNotNull);
    expect(stored['decision_reason'], isNull);
    expect(stored['sync_state'], 'pending');
    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(outbox['method'], 'POST');
    expect(outbox['path'], '/expense-categories/requests/category-1/decide');
    expect(jsonDecode(outbox['body']! as String), {'outcome': 'APPROVED'});
  });

  test('reject stores reason and queues exact decide payload', () async {
    await repository.decideCategoryRequest(
      requestId: 'category-1',
      outcome: 'REJECTED',
      reason: 'Use “Vehicle repair” for this.',
    );

    final stored = (await database.query(
      DatabaseTables.categoryRequests,
      where: 'id = ?',
      whereArgs: ['category-1'],
    )).single;
    expect(stored['status'], 'REJECTED');
    expect(stored['decision_reason'], 'Use “Vehicle repair” for this.');
    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(jsonDecode(outbox['body']! as String), {
      'outcome': 'REJECTED',
      'reason': 'Use “Vehicle repair” for this.',
    });
  });

  test('cannot decide a request outside the active center', () async {
    await expectLater(
      repository.decideCategoryRequest(
        requestId: 'category-2',
        outcome: 'APPROVED',
      ),
      throwsA(isA<StateError>()),
    );
    expect(await database.query(DatabaseTables.outbox), isEmpty);
  });

  test('sync posts decision and reconciles the server response', () async {
    await repository.decideCategoryRequest(
      requestId: 'category-1',
      outcome: 'REJECTED',
      reason: 'Use “Vehicle repair” for this.',
    );
    late http.Request sent;
    final service = OutgoingSyncService(
      database: database,
      internetAccessChecker: () async => true,
      client: MockClient((request) async {
        sent = request;
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'data': {
                'id': 'category-1',
                'status': 'REJECTED',
                'decision': {
                  'reason': 'Use “Vehicle repair” for this.',
                  'at': '2026-10-21T11:00:00.000Z',
                  'by': {'name': 'Supervisor One'},
                },
              },
            }),
          ),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    await service.drain();

    expect(sent.method, 'POST');
    expect(
      sent.url.path,
      '/api/v1/mobile/expense-categories/requests/category-1/decide',
    );
    expect(jsonDecode(sent.body), {
      'outcome': 'REJECTED',
      'reason': 'Use “Vehicle repair” for this.',
    });
    final stored = (await database.query(
      DatabaseTables.categoryRequests,
      where: 'id = ?',
      whereArgs: ['category-1'],
    )).single;
    expect(stored['status'], 'REJECTED');
    expect(stored['decision_reason'], 'Use “Vehicle repair” for this.');
    expect(stored['decided_by_name'], 'Supervisor One');
    expect(stored['sync_state'], 'synced');
  });
}

Future<void> _insertRequest(
  AppDatabase database, {
  required String id,
  required String centerId,
}) => database.insert(DatabaseTables.categoryRequests, {
  'id': id,
  'number': 'ECR-001',
  'center_id': centerId,
  'requested_by': 'agent-1',
  'requested_by_name': 'Agent One',
  'name': 'Vehicle tyre',
  'reason': 'Need a category for tyre replacement.',
  'status': 'PENDING',
  'created_at': '2026-10-21T10:00:00.000Z',
  'sync_state': 'synced',
});
