import 'dart:convert';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_data_source.dart';
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
    databasePath = p.join(await getDatabasesPath(), 'expense_decision_test.db');
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.accessTokenKey: 'supervisor-token',
    });
    await database.clearDatabaseOnLogout();
    for (final center in const [
      {'id': 'center-1', 'name': 'Center One'},
      {'id': 'center-2', 'name': 'Center Two'},
    ]) {
      await database.insert(DatabaseTables.centers, center);
    }
    for (final category in const [
      {'id': 'category-1', 'center_id': 'center-1', 'name': 'Fuel'},
      {'id': 'category-2', 'center_id': 'center-2', 'name': 'Repairs'},
    ]) {
      await database.insert(DatabaseTables.expenseCategories, {
        ...category,
        'is_active': 1,
      });
    }
    await database.setSyncMeta('active_center_id', 'center-1');
    await database.setSyncMeta('user_id', 'supervisor-1');
    await database.setSyncMeta('user_name', 'Supervisor One');
    await _insertExpense(database, id: 'expense-1', centerId: 'center-1');
    await _insertExpense(
      database,
      id: 'expense-2',
      centerId: 'center-2',
      categoryId: 'category-2',
    );
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('supervisor list and detail only return the active center', () async {
    final values = await repository.getExpenses(supervisor: true);

    expect(values.map((value) => value.id), ['expense-1']);
    expect(await repository.getExpense('expense-1'), isNotNull);
    expect(await repository.getExpense('expense-2'), isNull);
  });

  test('approve updates locally and queues exact decide request', () async {
    await repository.decideExpense(expenseId: 'expense-1', outcome: 'APPROVED');

    final expense = (await database.query(
      DatabaseTables.expenses,
      where: 'id = ?',
      whereArgs: ['expense-1'],
    )).single;
    expect(expense['status'], 'APPROVED');
    expect(expense['decided_by_name'], 'Supervisor One');
    expect(expense['decision_reason'], isNull);
    expect(expense['decision_remarks'], isNull);
    expect(expense['sync_state'], 'pending');

    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(outbox['method'], 'POST');
    expect(outbox['path'], '/expenses/expense-1/decide');
    expect(outbox['entity'], DatabaseTables.expenses);
    expect(outbox['entity_id'], 'expense-1');
    expect(outbox['kind'], 'decide');
    expect(jsonDecode(outbox['body']! as String), {'outcome': 'APPROVED'});
  });

  test('reject stores reason and queues exact decide request', () async {
    await repository.decideExpense(
      expenseId: 'expense-1',
      outcome: 'REJECTED',
      reason: 'No receipt for this amount.',
      remarks: 'The bill is from last month.',
    );

    final expense = (await database.query(
      DatabaseTables.expenses,
      where: 'id = ?',
      whereArgs: ['expense-1'],
    )).single;
    expect(expense['status'], 'REJECTED');
    expect(expense['decision_reason'], 'No receipt for this amount.');
    expect(expense['decision_remarks'], 'The bill is from last month.');

    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(jsonDecode(outbox['body']! as String), {
      'outcome': 'REJECTED',
      'reason': 'No receipt for this amount.',
      'remarks': 'The bill is from last month.',
    });
  });

  test('reject requires reason and cannot decide another center', () async {
    await expectLater(
      repository.decideExpense(expenseId: 'expense-1', outcome: 'REJECTED'),
      throwsA(isA<ExpenseDecisionValidationException>()),
    );
    await expectLater(
      repository.decideExpense(expenseId: 'expense-2', outcome: 'APPROVED'),
      throwsA(isA<ExpenseDecisionValidationException>()),
    );
    expect(await database.query(DatabaseTables.outbox), isEmpty);
  });

  test('sync posts decision to the mobile expense decide endpoint', () async {
    await repository.decideExpense(
      expenseId: 'expense-1',
      outcome: 'REJECTED',
      reason: 'No receipt for this amount.',
      remarks: 'The bill is from last month.',
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
              'id': 'expense-1',
              'status': 'REJECTED',
              'updatedAt': '2026-10-21T11:00:00.000Z',
              'decision': {
                'reason': 'No receipt for this amount.',
                'remarks': 'The bill is from last month.',
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
    expect(sent.url.path, '/api/v1/mobile/expenses/expense-1/decide');
    expect(sent.headers['authorization'], 'Bearer supervisor-token');
    expect(jsonDecode(sent.body), {
      'outcome': 'REJECTED',
      'reason': 'No receipt for this amount.',
      'remarks': 'The bill is from last month.',
    });
    expect(await database.query(DatabaseTables.outbox), isEmpty);
    final stored = (await database.query(
      DatabaseTables.expenses,
      where: 'id = ?',
      whereArgs: ['expense-1'],
    )).single;
    expect(stored['status'], 'REJECTED');
    expect(stored['decision_reason'], 'No receipt for this amount.');
    expect(stored['decision_remarks'], 'The bill is from last month.');
    expect(stored['decided_by_name'], 'Supervisor One');
    expect(stored['sync_state'], 'synced');
  });
}

Future<void> _insertExpense(
  AppDatabase database, {
  required String id,
  required String centerId,
  String categoryId = 'category-1',
}) => database.insert(DatabaseTables.expenses, {
  'id': id,
  'center_id': centerId,
  'user_id': 'agent-1',
  'user_name': 'Agent One',
  'category_id': categoryId,
  'amount': 350.0,
  'note': 'Diesel receipt',
  'status': 'WAITING_SUPERVISOR',
  'number': 'EXP-001',
  'receipt_photo_urls': '[]',
  'created_at': '2026-10-21T10:00:00.000Z',
  'updated_at': '2026-10-21T10:00:00.000Z',
  'sync_state': 'synced',
});
