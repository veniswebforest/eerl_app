import 'dart:convert';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:flutter_test/flutter_test.dart';
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
      'transfer_request_optional_expense.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.accessTokenKey: 'transfer-token',
    });
    await database.clearDatabaseOnLogout();
    await database.setSyncMeta('user_id', 'agent-1');
    await database.setSyncMeta('user_name', 'Agent One');
    await database.setSyncMeta('active_center_id', 'center-1');
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await database.insert(DatabaseTables.items, {
      'id': 'plastic',
      'name': 'Plastic',
      'category_name': 'Dry waste',
      'material_type': 'RECYCLABLE',
      'unit_code': 'KG',
      'unit_name': 'Kilogram',
      'is_active': 1,
    });
    await database.insert(DatabaseTables.stock, {
      'id': 'stock-1',
      'center_id': 'center-1',
      'item_id': 'plastic',
      'stage': 'RM',
      'qty': 25.0,
    });
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('estimated expense may be left out (PUT /transfers optional)', () async {
    final id = await repository.saveTransferRequest(
      itemQuantities: const {'plastic': 10},
    );

    final transfer = (await database.query(
      DatabaseTables.transfers,
      where: 'id = ?',
      whereArgs: [id],
    )).single;
    expect(transfer['estimated_expense'], isNull);
    final outbox = (await database.query(DatabaseTables.outbox)).single;
    final body = jsonDecode(outbox['body']! as String) as Map<String, Object?>;
    expect(body['estimatedExpense'], isNull);
  });

  test('estimated expense above 9,999,999 is still refused', () async {
    expect(
      () => repository.saveTransferRequest(
        itemQuantities: const {'plastic': 10},
        estimatedExpense: 10000000,
      ),
      throwsArgumentError,
    );
  });
}
