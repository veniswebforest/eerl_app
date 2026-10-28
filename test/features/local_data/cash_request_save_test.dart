import 'dart:convert';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
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
      'cash_request_save_test.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await database.setSyncMeta('active_center_id', 'center-1');
    await database.setSyncMeta('user_id', 'user-1');
    await database.setSyncMeta('user_name', 'Agent One');
    await database.insert(DatabaseTables.centerBalances, {
      'center_id': 'center-1',
      'balance': 2000,
    });
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('cash request stores locally and queues its PUT API body', () async {
    final requestId = await repository.saveCashRequest(
      amount: 350,
      reason: 'Emergency Fuel: Float for the weekend',
    );

    final request = (await database.query(DatabaseTables.cashRequests)).single;
    expect(request['id'], requestId);
    expect(request['center_id'], 'center-1');
    expect(request['requested_by'], 'user-1');
    expect(request['requested_by_name'], 'Agent One');
    expect(request['amount'], 350.0);
    expect(request['reason'], 'Emergency Fuel: Float for the weekend');
    expect(request['status'], 'PENDING');
    expect(request['sync_state'], 'pending');

    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(outbox['method'], 'PUT');
    expect(outbox['path'], '/cash-requests/$requestId');
    expect(outbox['entity'], DatabaseTables.cashRequests);
    expect(outbox['entity_id'], requestId);
    expect(outbox['kind'], 'create');
    expect(outbox['status'], 'queued');
    expect(jsonDecode(outbox['body']! as String), {
      'centerId': 'center-1',
      'amount': 350.0,
      'reason': 'Emergency Fuel: Float for the weekend',
    });
  });

  test('invalid cash request does not create a partial local row', () async {
    await expectLater(
      repository.saveCashRequest(amount: 0, reason: ''),
      throwsArgumentError,
    );
    expect(await database.query(DatabaseTables.cashRequests), isEmpty);
    expect(await database.query(DatabaseTables.outbox), isEmpty);
  });

  test('cash request is not limited by the current wallet balance', () async {
    await repository.saveCashRequest(
      amount: 2000.01,
      reason: 'Requesting additional center cash',
    );
    expect(await database.query(DatabaseTables.cashRequests), hasLength(1));
    expect(await database.query(DatabaseTables.outbox), hasLength(1));
  });

  test('amount equal to cash balance is allowed', () async {
    await repository.saveCashRequest(
      amount: 2000,
      reason: 'Exactly the available balance',
    );
    expect(await database.query(DatabaseTables.cashRequests), hasLength(1));
    expect(await database.query(DatabaseTables.outbox), hasLength(1));
  });
}
