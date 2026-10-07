import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

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
      onOpen: _onOpen,
    );

    _log('Database initialized successfully (version $databaseVersion)');
    return db;
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    _log('Database configured with foreign keys enabled');
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

  Future<void> _onOpen(Database db) async {
    await _ensureVersionOneSchema(db);
  }

  Future<void> ensureCurrentSchema() async {
    await _ensureVersionOneSchema(await database);
  }

  Future<void> _ensureVersionOneSchema(Database db) async {
    // The testing database intentionally stays at version 1. Keep an existing
    // version-1 installation aligned with the current baseline schema without
    // introducing numbered migrations or deleting any local data.
    const additiveColumns = <String, Map<String, String>>{
      DatabaseTables.myCenters: {'agent_number': 'INTEGER'},
      DatabaseTables.vehicles: {'number': 'TEXT'},
      DatabaseTables.mrfPeople: {'number': 'TEXT'},
      DatabaseTables.ragpickers: {'number': 'TEXT'},
      DatabaseTables.cashRequests: {'number': 'TEXT'},
      DatabaseTables.categoryRequests: {'number': 'TEXT'},
      DatabaseTables.tasks: {'number': 'TEXT', 'note': 'TEXT'},
      DatabaseTables.requests: {'number': 'TEXT'},
      DatabaseTables.collections: {'gps_lat': 'REAL', 'gps_lng': 'REAL'},
      DatabaseTables.transfers: {
        'note': 'TEXT',
        'gps_lat': 'REAL',
        'gps_lng': 'REAL',
      },
      DatabaseTables.items: {'image_url': 'TEXT'},
    };

    for (final tableEntry in additiveColumns.entries) {
      final columns = await db.rawQuery(
        'PRAGMA table_info("${tableEntry.key}")',
      );
      if (columns.isEmpty) continue;
      final existingNames = columns.map((row) => row['name']).toSet();
      for (final columnEntry in tableEntry.value.entries) {
        if (existingNames.contains(columnEntry.key)) continue;
        await db.execute(
          'ALTER TABLE "${tableEntry.key}" '
          'ADD COLUMN "${columnEntry.key}" ${columnEntry.value}',
        );
        _log(
          'Added missing baseline column '
          '${tableEntry.key}.${columnEntry.key}',
        );
      }
    }
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

  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    return db.rawUpdate(sql, arguments);
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
    _log('Scope reset started; outgoing work must already be drained');
    return runInTransaction((txn) async {
      const tablesToClear = <String>[
        DatabaseTables.myRoles,
        DatabaseTables.walletEntries,
        DatabaseTables.collectionItems,
        DatabaseTables.transferItems,
        DatabaseTables.stock,
        DatabaseTables.dayCloses,
        DatabaseTables.centerBalances,
        DatabaseTables.expenses,
        DatabaseTables.cashRequests,
        DatabaseTables.categoryRequests,
        DatabaseTables.tasks,
        DatabaseTables.requests,
        DatabaseTables.collections,
        DatabaseTables.transfers,
        DatabaseTables.centerItems,
        DatabaseTables.vehicles,
        DatabaseTables.mrfPeople,
        DatabaseTables.ragpickers,
        DatabaseTables.expenseCategories,
        DatabaseTables.centerPeople,
        DatabaseTables.myCenters,
        DatabaseTables.centerChannels,
        DatabaseTables.vehicleTypes,
        DatabaseTables.destinations,
        DatabaseTables.notifications,
        DatabaseTables.items,
        DatabaseTables.centers,
      ];

      for (final table in tablesToClear) {
        await txn.delete(table);
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
        DatabaseTables.walletEntries,
        DatabaseTables.collectionItems,
        DatabaseTables.transferItems,
        DatabaseTables.stock,
        DatabaseTables.dayCloses,
        DatabaseTables.centerBalances,
        DatabaseTables.expenses,
        DatabaseTables.cashRequests,
        DatabaseTables.categoryRequests,
        DatabaseTables.tasks,
        DatabaseTables.requests,
        DatabaseTables.collections,
        DatabaseTables.transfers,
        DatabaseTables.centerItems,
        DatabaseTables.vehicles,
        DatabaseTables.mrfPeople,
        DatabaseTables.ragpickers,
        DatabaseTables.expenseCategories,
        DatabaseTables.centerPeople,
        DatabaseTables.myCenters,
        DatabaseTables.centerChannels,
        DatabaseTables.vehicleTypes,
        DatabaseTables.destinations,
        DatabaseTables.notifications,
        DatabaseTables.items,
        DatabaseTables.centers,
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
