import 'dart:convert';
import 'dart:io';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_data_source.dart';
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
    databasePath = p.join(await getDatabasesPath(), 'expense_save_test.db');
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await database.insert(DatabaseTables.expenseCategories, {
      'id': 'category-1',
      'center_id': 'center-1',
      'name': 'Fuel / Diesel',
      'is_active': 1,
    });
    await database.setSyncMeta('active_center_id', 'center-1');
    await database.setSyncMeta('user_id', 'user-1');
    await database.setSyncMeta('user_name', 'Agent One');
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('queues the values entered by the agent without dummy fields', () async {
    await database.insert(DatabaseTables.centerBalances, {
      'center_id': 'center-1',
      'balance': 1000,
    });
    final receipt = File(p.join(await getDatabasesPath(), 'receipt.jpg'));
    await receipt.writeAsBytes(const [1, 2, 3, 4]);
    addTearDown(() async {
      if (await receipt.exists()) await receipt.delete();
    });

    final expenseId = await repository.saveExpense(
      categoryId: 'category-1',
      amount: 350,
      receiptPaths: [receipt.path],
      note: 'Refilled 15L diesel',
    );

    final expense = (await database.query(DatabaseTables.expenses)).single;
    expect(expense['id'], expenseId);
    expect(expense['center_id'], 'center-1');
    expect(expense['category_id'], 'category-1');
    expect(expense['amount'], 350.0);
    expect(expense['note'], 'Refilled 15L diesel');

    final photo = (await database.query(DatabaseTables.photos)).single;
    final outbox = (await database.query(DatabaseTables.outbox)).single;
    final body = jsonDecode(outbox['body']! as String) as Map;
    expect(body['centerId'], 'center-1');
    expect(body['categoryId'], 'category-1');
    expect(body['amount'], 350.0);
    expect(body['note'], 'Refilled 15L diesel');
    expect(body['photoUrls'], [photo['id']]);
    expect(body['spentAt'], isNotEmpty);
    expect(body.containsKey('collectionId'), isFalse);
    expect(await repository.getExpenseReceiptSources(expenseId), [
      receipt.path,
    ]);

    const uploadedUrl = 'https://example.test/expense-receipt.jpg';
    await database.update(
      DatabaseTables.photos,
      {'remote_url': uploadedUrl},
      where: 'id = ?',
      whereArgs: [photo['id']],
    );
    await database.update(
      DatabaseTables.expenses,
      {
        'receipt_photo_urls': jsonEncode([uploadedUrl]),
      },
      where: 'id = ?',
      whereArgs: [expenseId],
    );
    expect(await repository.getExpenseReceiptSources(expenseId), [
      receipt.path,
    ]);
  });

  test('does not queue an expense above the available balance', () async {
    await database.insert(DatabaseTables.centerBalances, {
      'center_id': 'center-1',
      'balance': 100,
    });

    await expectLater(
      repository.saveExpense(
        categoryId: 'category-1',
        amount: 350,
        receiptPaths: const ['/tmp/receipt.jpg'],
      ),
      throwsA(isA<ExpenseBalanceUnavailableException>()),
    );

    expect(await database.query(DatabaseTables.expenses), isEmpty);
    expect(await database.query(DatabaseTables.photos), isEmpty);
    expect(await database.query(DatabaseTables.outbox), isEmpty);
    expect(await database.query(DatabaseTables.outboxPhotos), isEmpty);
  });
}
