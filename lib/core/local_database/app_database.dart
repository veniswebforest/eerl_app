import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'database_migrations.dart';
import 'database_schema.dart';
import 'database_tables.dart';

class AppDatabase {
  AppDatabase._internal();

  static final AppDatabase instance = AppDatabase._internal();

  static const _logTag = '[AppDatabase]';
  static const databaseName = 'eerl_local.db';
  static const databaseVersion = 1;

  static Database? _database;
  static Future<Database>? _openingDatabase;
  static String? _databasePathOverride;

  Future<Database> get database async {
    final currentDatabase = _database;
    if (currentDatabase != null) {
      return currentDatabase;
    }

    final currentOpening = _openingDatabase;
    if (currentOpening != null) {
      return currentOpening;
    }

    final openingDatabase = _initDatabase();
    _openingDatabase = openingDatabase;

    try {
      final openedDatabase = await openingDatabase;
      _database = openedDatabase;
      return openedDatabase;
    } finally {
      _openingDatabase = null;
    }
  }

  Future<Database> _initDatabase() async {
    final databaseDirectory = await getDatabasesPath();
    final databasePath =
        _databasePathOverride ?? p.join(databaseDirectory, databaseName);

    _log('Opening database at $databasePath');

    final db = await openDatabase(
      databasePath,
      version: databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    _log('Database initialized successfully (version $databaseVersion)');
    return db;
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = OFF');
    _log('Database configured with foreign keys disabled');
  }

  Future<void> _onCreate(Database db, int version) async {
    _log('Creating database schema version $version');
    final batch = db.batch();

    for (final sql in DatabaseSchema.createTableQueries) {
      batch.execute(sql);
    }

    for (final sql in DatabaseSchema.createIndexQueries) {
      batch.execute(sql);
    }

    await batch.commit(noResult: true);
    _log(
      'Database created with ${DatabaseTables.values.length} tables and '
      '${DatabaseSchema.indexNames.length} indexes',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) {
    return DatabaseMigrations.upgrade(db, oldVersion, newVersion);
  }

  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final db = await database;
    return db.insert(table, values, conflictAlgorithm: conflictAlgorithm);
  }

  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, arguments);
  }

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return db.transaction(action);
  }

  Future<T> runInTransaction<T>(Future<T> Function(Transaction txn) callback) {
    return transaction(callback);
  }

  Future<String?> getSyncMeta(String key) async {
    final rows = await query(
      DatabaseTables.syncMeta,
      columns: const ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first['value'] as String?;
  }

  Future<void> setSyncMeta(String key, String? value) async {
    final db = await database;
    await db.rawInsert(
      'INSERT OR REPLACE INTO ${DatabaseTables.syncMeta} (key, value) '
      'VALUES (?, ?)',
      [key, value],
    );
  }

  Future<void> scopeReset() {
    _log('Scope reset started; pending/failed and queued data will be kept');
    return runInTransaction((txn) async {
      const fullyServerOwnedTables = <String>[
        DatabaseTables.myRoles,
        DatabaseTables.myCenters,
        DatabaseTables.centers,
        DatabaseTables.items,
        DatabaseTables.centerChannels,
        DatabaseTables.vehicleTypes,
        DatabaseTables.expenseCategories,
        DatabaseTables.centerPeople,
        DatabaseTables.destinations,
        DatabaseTables.dayCloses,
        DatabaseTables.centerBalances,
        DatabaseTables.stock,
      ];

      for (final table in fullyServerOwnedTables) {
        await txn.delete(table);
      }

      // Child rows belonging to locally pending/failed parents must survive a
      // scope refresh because foreign keys are intentionally disabled.
      await txn.rawDelete('''
        DELETE FROM ${DatabaseTables.collectionItems}
        WHERE collection_id IN (
          SELECT id FROM ${DatabaseTables.collections}
          WHERE sync_state = 'synced'
        )
      ''');
      await txn.rawDelete('''
        DELETE FROM ${DatabaseTables.transferItems}
        WHERE transfer_id IN (
          SELECT id FROM ${DatabaseTables.transfers}
          WHERE sync_state = 'synced'
        )
      ''');

      const tablesWithLocalChanges = <String>[
        DatabaseTables.centerItems,
        DatabaseTables.vehicles,
        DatabaseTables.mrfPeople,
        DatabaseTables.ragpickers,
        DatabaseTables.collections,
        DatabaseTables.expenses,
        DatabaseTables.cashRequests,
        DatabaseTables.categoryRequests,
        DatabaseTables.transfers,
        DatabaseTables.tasks,
        DatabaseTables.requests,
        DatabaseTables.walletEntries,
        DatabaseTables.notifications,
      ];
      for (final table in tablesWithLocalChanges) {
        await txn.delete(
          table,
          where: 'sync_state = ?',
          whereArgs: const ['synced'],
        );
      }

      await txn.delete(
        DatabaseTables.photos,
        where: 'status = ?',
        whereArgs: const ['uploaded'],
      );
      await txn.delete(
        DatabaseTables.syncMeta,
        where: 'key IN (?, ?)',
        whereArgs: const ['cursor', 'scope_key'],
      );
      _log('Scope reset transaction completed');
    });
  }

  Future<void> clearDatabaseOnLogout() {
    _log('Full logout database reset started');
    return runInTransaction((txn) async {
      const tablesToClear = <String>[
        DatabaseTables.outboxPhotos,
        DatabaseTables.outbox,
        DatabaseTables.photos,
        DatabaseTables.myRoles,
        DatabaseTables.myCenters,
        DatabaseTables.centers,
        DatabaseTables.items,
        DatabaseTables.centerChannels,
        DatabaseTables.centerItems,
        DatabaseTables.vehicleTypes,
        DatabaseTables.vehicles,
        DatabaseTables.mrfPeople,
        DatabaseTables.ragpickers,
        DatabaseTables.expenseCategories,
        DatabaseTables.centerPeople,
        DatabaseTables.destinations,
        DatabaseTables.collections,
        DatabaseTables.collectionItems,
        DatabaseTables.expenses,
        DatabaseTables.cashRequests,
        DatabaseTables.categoryRequests,
        DatabaseTables.transfers,
        DatabaseTables.transferItems,
        DatabaseTables.tasks,
        DatabaseTables.requests,
        DatabaseTables.walletEntries,
        DatabaseTables.dayCloses,
        DatabaseTables.notifications,
        DatabaseTables.centerBalances,
        DatabaseTables.stock,
        DatabaseTables.syncMeta,
      ];

      for (final table in tablesToClear) {
        await txn.delete(table);
      }
      _log('Full logout database reset completed');
    });
  }

  Future<List<String>> getExistingTableNames() async {
    final rows = await rawQuery('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
      ORDER BY name
    ''');
    return rows.map((row) => row['name']! as String).toList(growable: false);
  }

  Future<List<String>> getExistingIndexNames() async {
    final rows = await rawQuery('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'index'
        AND name NOT LIKE 'sqlite_%'
      ORDER BY name
    ''');
    return rows.map((row) => row['name']! as String).toList(growable: false);
  }

  Future<bool> validateSchema() async {
    final tableNames = (await getExistingTableNames()).toSet();
    final indexNames = (await getExistingIndexNames()).toSet();

    return tableNames.containsAll(DatabaseTables.values) &&
        indexNames.containsAll(DatabaseSchema.indexNames);
  }

  Future<void> debugPrintTableNames() async {
    if (!kDebugMode) {
      return;
    }

    final tableNames = await getExistingTableNames();
    debugPrint('SQLite tables: ${tableNames.join(', ')}');
  }

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('🗄️ [EERL_DATABASE] $_logTag $message');
    }
  }

  @visibleForTesting
  Future<void> closeForTesting() async {
    final db = _database;
    _database = null;
    _openingDatabase = null;
    await db?.close();
  }

  @visibleForTesting
  static void setDatabasePathForTesting(String? path) {
    if (_database != null || _openingDatabase != null) {
      throw StateError('Close the database before changing its test path.');
    }
    _databasePathOverride = path;
  }
}
