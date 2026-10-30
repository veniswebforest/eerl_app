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
  late DateTime todayStartUtc;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(
      await getDatabasesPath(),
      'wallet_today_movement_test.db',
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
    todayStartUtc = _startOfIstDayUtc();
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('yesterday expense refund does not reduce today spent', () async {
    await _insertEntry(
      database,
      id: 'expense-yesterday',
      kind: 'EXPENSE',
      amount: -500,
      expenseId: 'expense-1',
      createdAt: todayStartUtc.subtract(const Duration(hours: 1)),
    );
    await _insertEntry(
      database,
      id: 'refund-today',
      kind: 'EXPENSE_REVERSAL',
      amount: 500,
      expenseId: 'expense-1',
      createdAt: todayStartUtc.add(const Duration(hours: 1)),
    );
    await _insertEntry(
      database,
      id: 'expense-today',
      kind: 'EXPENSE',
      amount: -200,
      expenseId: 'expense-2',
      createdAt: todayStartUtc.add(const Duration(hours: 2)),
    );

    final summary = await repository.getWalletSummary(centerId: 'center-1');

    expect(summary.spent, 200);
  });

  test('today expense refund offsets the expense paid today', () async {
    await _insertEntry(
      database,
      id: 'expense-today',
      kind: 'EXPENSE',
      amount: -500,
      expenseId: 'expense-1',
      createdAt: todayStartUtc.add(const Duration(hours: 1)),
    );
    await _insertEntry(
      database,
      id: 'refund-today',
      kind: 'EXPENSE_REVERSAL',
      amount: 500,
      expenseId: 'expense-1',
      createdAt: todayStartUtc.add(const Duration(hours: 2)),
    );

    final summary = await repository.getWalletSummary(centerId: 'center-1');

    expect(summary.spent, 0);
  });

  test(
    'old collection refund is excluded but today repayment is counted',
    () async {
      await _insertEntry(
        database,
        id: 'payment-yesterday',
        kind: 'COLLECTION_PAYMENT',
        amount: -1000,
        collectionId: 'collection-1',
        createdAt: todayStartUtc.subtract(const Duration(hours: 1)),
      );
      await _insertEntry(
        database,
        id: 'refund-today',
        kind: 'COLLECTION_REVERSAL',
        amount: 1000,
        collectionId: 'collection-1',
        createdAt: todayStartUtc.add(const Duration(hours: 1)),
      );
      await _insertEntry(
        database,
        id: 'repayment-today',
        kind: 'COLLECTION_PAYMENT',
        amount: -900,
        collectionId: 'collection-1',
        createdAt: todayStartUtc.add(const Duration(hours: 2)),
      );

      final summary = await repository.getWalletSummary(centerId: 'center-1');

      expect(summary.paidOut, 900);
    },
  );
}

Future<void> _insertEntry(
  AppDatabase database, {
  required String id,
  required String kind,
  required double amount,
  required DateTime createdAt,
  String? collectionId,
  String? expenseId,
}) => database.insert(DatabaseTables.walletEntries, {
  'id': id,
  'center_id': 'center-1',
  'kind': kind,
  'amount': amount,
  'collection_id': collectionId,
  'expense_id': expenseId,
  'created_at': createdAt.toIso8601String(),
  'sync_state': 'synced',
});

DateTime _startOfIstDayUtc() {
  final istNow = DateTime.now().toUtc().add(
    const Duration(hours: 5, minutes: 30),
  );
  return DateTime.utc(
    istNow.year,
    istNow.month,
    istNow.day,
  ).subtract(const Duration(hours: 5, minutes: 30));
}
