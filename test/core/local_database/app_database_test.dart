import 'dart:convert';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_schema.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String databasePath;
  final appDatabase = AppDatabase.instance;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(await getDatabasesPath(), AppDatabase.databaseName);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    await appDatabase.clearDatabaseOnLogout();
  });

  tearDownAll(() async {
    await appDatabase.closeForTesting();
    await deleteDatabase(databasePath);
  });

  test('creates the complete schema and reuses one connection', () async {
    final firstConnection = await appDatabase.database;
    final secondConnection = await appDatabase.database;

    expect(identical(firstConnection, secondConnection), isTrue);
    expect(await appDatabase.validateSchema(), isTrue);

    final tables = (await appDatabase.getExistingTableNames()).toSet();
    final indexes = (await appDatabase.getExistingIndexNames()).toSet();
    expect(tables.intersection(DatabaseTables.values.toSet()), hasLength(31));
    expect(
      indexes.intersection(DatabaseSchema.indexNames.toSet()),
      hasLength(21),
    );

    final pragma = await firstConnection.rawQuery('PRAGMA foreign_keys');
    expect(pragma.single.values.single, 0);
  });

  test('stores sync metadata, integer booleans, and encoded JSON', () async {
    await appDatabase.setSyncMeta('cursor', 'next-page');
    expect(await appDatabase.getSyncMeta('cursor'), 'next-page');

    final modules = <String>['collections', 'wallet'];
    await appDatabase.insert(DatabaseTables.myRoles, {
      'role_key': 'agent',
      'role_name': 'Agent',
      'modules': jsonEncode(modules),
    });
    await appDatabase.insert(DatabaseTables.myCenters, {
      'center_id': 'center-1',
      'is_primary': 1,
      'slip_last_count': 0,
    });

    final role = (await appDatabase.query(DatabaseTables.myRoles)).single;
    final center = (await appDatabase.query(DatabaseTables.myCenters)).single;
    expect(jsonDecode(role['modules']! as String), modules);
    expect((center['is_primary']! as int) == 1, isTrue);
  });

  test('rolls back every write when a transaction fails', () async {
    await expectLater(
      appDatabase.runInTransaction<void>((txn) async {
        await txn.insert(DatabaseTables.syncMeta, {
          'key': 'rollback-key',
          'value': 'must-not-persist',
        });
        throw StateError('Force rollback');
      }),
      throwsStateError,
    );

    expect(await appDatabase.getSyncMeta('rollback-key'), isNull);
  });

  test('scope reset keeps offline queues and non-uploaded photos', () async {
    await appDatabase.insert(DatabaseTables.myRoles, {
      'role_key': 'agent',
      'role_name': 'Agent',
      'modules': '[]',
    });
    await appDatabase.insert(DatabaseTables.photos, {
      'id': 'uploaded-photo',
      'owner_table': 'collections',
      'owner_id': 'collection-1',
      'purpose': 'handover',
      'content_type': 'image/jpeg',
      'status': 'uploaded',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    await appDatabase.insert(DatabaseTables.photos, {
      'id': 'queued-photo',
      'owner_table': 'collections',
      'owner_id': 'collection-2',
      'purpose': 'handover',
      'content_type': 'image/jpeg',
      'status': 'queued',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    await appDatabase.insert(DatabaseTables.outbox, {
      'method': 'POST',
      'path': '/collections',
      'entity': 'collection',
      'entity_id': 'collection-2',
      'status': 'pending',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    await appDatabase.insert(DatabaseTables.expenses, {
      'id': 'pending-expense',
      'center_id': 'center-1',
      'user_id': 'user-1',
      'category_id': 'category-1',
      'amount': 25.0,
      'status': 'PENDING',
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'sync_state': 'pending',
    });
    await appDatabase.setSyncMeta('cursor', 'cursor-value');
    await appDatabase.setSyncMeta('scope_key', 'scope-value');
    await appDatabase.setSyncMeta('user_id', 'user-1');

    await appDatabase.scopeReset();

    expect(await appDatabase.query(DatabaseTables.myRoles), isEmpty);
    expect(
      await appDatabase.query(DatabaseTables.photos, columns: const ['id']),
      [containsPair('id', 'queued-photo')],
    );
    expect(await appDatabase.query(DatabaseTables.outbox), hasLength(1));
    expect(await appDatabase.query(DatabaseTables.expenses), hasLength(1));
    expect(await appDatabase.getSyncMeta('cursor'), isNull);
    expect(await appDatabase.getSyncMeta('scope_key'), isNull);
    expect(await appDatabase.getSyncMeta('user_id'), 'user-1');
  });

  test('logout clear removes data from every application table', () async {
    await appDatabase.setSyncMeta('user_id', 'user-1');
    await appDatabase.insert(DatabaseTables.photos, {
      'id': 'photo-1',
      'owner_table': 'collections',
      'owner_id': 'collection-1',
      'purpose': 'handover',
      'content_type': 'image/jpeg',
      'status': 'queued',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    await appDatabase.insert(DatabaseTables.outbox, {
      'method': 'POST',
      'path': '/collections',
      'entity': 'collection',
      'entity_id': 'collection-1',
      'status': 'pending',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });

    await appDatabase.clearDatabaseOnLogout();

    for (final table in DatabaseTables.values) {
      expect(
        await appDatabase.query(table),
        isEmpty,
        reason: '$table should be empty after logout',
      );
    }
  });
}
