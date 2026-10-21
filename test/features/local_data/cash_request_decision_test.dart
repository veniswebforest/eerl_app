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
      'cash_request_decision_test.db',
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
    await _insertCashRequest(database, id: 'cash-1', centerId: 'center-1');
    await _insertCashRequest(database, id: 'cash-2', centerId: 'center-2');
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('reject stores reason and remarks and queues exact request', () async {
    await repository.decideCashRequest(
      requestId: 'cash-1',
      outcome: 'REJECTED',
      reason: 'Sufficient Existing Balance, Exceeds Advance Limit',
      remarks: 'Already holds ₹12,000 for this week.',
    );

    final request = (await database.query(
      DatabaseTables.cashRequests,
      where: 'id = ?',
      whereArgs: ['cash-1'],
    )).single;
    expect(request['status'], 'REJECTED');
    expect(request['decided_by_name'], 'Supervisor One');
    expect(
      request['decision_note'],
      'Sufficient Existing Balance, Exceeds Advance Limit',
    );
    expect(request['decision_remarks'], 'Already holds ₹12,000 for this week.');
    expect(request['sync_state'], 'pending');

    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(outbox['method'], 'POST');
    expect(outbox['path'], '/cash-requests/cash-1/decide');
    expect(outbox['entity'], DatabaseTables.cashRequests);
    expect(jsonDecode(outbox['body']! as String), {
      'outcome': 'REJECTED',
      'reason': 'Sufficient Existing Balance, Exceeds Advance Limit',
      'remarks': 'Already holds ₹12,000 for this week.',
    });
  });

  test('approve sends no reason or remarks', () async {
    await repository.decideCashRequest(
      requestId: 'cash-1',
      outcome: 'APPROVED',
    );

    final request = (await database.query(
      DatabaseTables.cashRequests,
      where: 'id = ?',
      whereArgs: ['cash-1'],
    )).single;
    expect(request['decision_note'], isNull);
    expect(request['decision_remarks'], isNull);
    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(jsonDecode(outbox['body']! as String), {'outcome': 'APPROVED'});
  });

  test('cannot decide a cash request outside the active center', () async {
    await expectLater(
      repository.decideCashRequest(requestId: 'cash-2', outcome: 'APPROVED'),
      throwsA(isA<StateError>()),
    );
    expect(await database.query(DatabaseTables.outbox), isEmpty);
  });

  test('sync posts decision and stores returned remarks', () async {
    await repository.decideCashRequest(
      requestId: 'cash-1',
      outcome: 'REJECTED',
      reason: 'Sufficient Existing Balance',
      remarks: 'Already has an advance.',
    );
    late http.Request sent;
    final service = OutgoingSyncService(
      database: database,
      internetAccessChecker: () async => true,
      client: MockClient((request) async {
        sent = request;
        return http.Response(
          jsonEncode({
            'data': {
              'id': 'cash-1',
              'status': 'REJECTED',
              'updatedAt': '2026-10-21T11:00:00.000Z',
              'decision': {
                'reason': 'Sufficient Existing Balance',
                'remarks': 'Already has an advance.',
                'by': {'name': 'Supervisor One'},
              },
            },
          }),
          200,
        );
      }),
    );

    await service.drain();

    expect(sent.method, 'POST');
    expect(sent.url.path, '/api/v1/mobile/cash-requests/cash-1/decide');
    expect(jsonDecode(sent.body), {
      'outcome': 'REJECTED',
      'reason': 'Sufficient Existing Balance',
      'remarks': 'Already has an advance.',
    });
    final stored = (await database.query(
      DatabaseTables.cashRequests,
      where: 'id = ?',
      whereArgs: ['cash-1'],
    )).single;
    expect(stored['decision_note'], 'Sufficient Existing Balance');
    expect(stored['decision_remarks'], 'Already has an advance.');
    expect(stored['sync_state'], 'synced');
  });
}

Future<void> _insertCashRequest(
  AppDatabase database, {
  required String id,
  required String centerId,
}) => database.insert(DatabaseTables.cashRequests, {
  'id': id,
  'number': 'CASH-001',
  'center_id': centerId,
  'requested_by': 'agent-1',
  'requested_by_name': 'Agent One',
  'amount': 12000.0,
  'reason': 'Fuel advance',
  'status': 'PENDING',
  'created_at': '2026-10-21T10:00:00.000Z',
  'updated_at': '2026-10-21T10:00:00.000Z',
  'sync_state': 'synced',
});
