import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../logging/app_logger.dart';
import 'database_schema.dart';
import 'database_tables.dart';

class AppDatabase {
  AppDatabase._internal();

  static final AppDatabase instance = AppDatabase._internal();

  static const _logTag = '[AppDatabase]';
  static const databaseName = 'eerl_local.db';
  static const databaseVersion = 12;

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

    _log('Opening database $databaseName');

    final db = await openDatabase(
      databasePath,
      version: databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );

    _log('Database initialized successfully (version $databaseVersion)');
    return db;
  }

  Future<void> _onConfigure(Database db) async {
    // Bootstrap is the server-owned source of truth and can legitimately send
    // related tables on different pages. Keep enforcement disabled so an
    // incomplete server relation never blocks opening or synchronizing the
    // offline database. Bootstrap still logs relation diagnostics.
    await db.execute('PRAGMA foreign_keys = OFF');
    _log('Database configured with foreign-key enforcement disabled');
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

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _addMissingColumns(db, DatabaseTables.transfers, const {
        'driver_name': 'TEXT',
        'dispatched_weight': 'REAL',
        'bale_count': 'INTEGER',
        'vehicle_photo_urls': "TEXT NOT NULL DEFAULT '[]'",
        'weighbridge_photo_urls': "TEXT NOT NULL DEFAULT '[]'",
      });
      final syncMeta = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
        [DatabaseTables.syncMeta],
      );
      if (syncMeta.isNotEmpty) {
        await db.insert(DatabaseTables.syncMeta, const {
          'key': 'transfer_dispatch_refetch_required',
          'value': '1',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      _log('Upgraded transfer dispatch schema to version 2');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${DatabaseTables.transferVehicles} (
          id TEXT PRIMARY KEY,
          number TEXT NOT NULL,
          ownership TEXT NOT NULL,
          transporter_name TEXT,
          vehicle_type TEXT,
          capacity_kg REAL
        )
      ''');
      await _addMissingColumns(db, DatabaseTables.categoryRequests, const {
        'requested_by_name': 'TEXT',
        'decided_by_name': 'TEXT',
        'decided_at': 'TEXT',
        'decision_reason': 'TEXT',
      });
      await _addMissingColumns(db, DatabaseTables.transfers, const {
        'transfer_vehicle_id': 'TEXT',
        'planned_vehicle_number': 'TEXT',
        'planned_vehicle_ownership': 'TEXT',
        'transporter_name': 'TEXT',
        'transfer_fee': 'REAL',
        'vehicle_differs': 'INTEGER NOT NULL DEFAULT 0',
      });
      _log('Upgraded category audit and transfer vehicle schema to version 3');
    }
    if (oldVersion < 4) {
      await _addMissingColumns(db, DatabaseTables.items, const {
        'is_active': 'INTEGER NOT NULL DEFAULT 1',
      });
      await _addMissingColumns(db, DatabaseTables.requests, const {
        'follow_up_at': 'TEXT',
      });
      _log('Upgraded material and request follow-up schema to version 4');
    }
    if (oldVersion < 5) {
      await _addMissingColumns(db, DatabaseTables.transfers, const {
        'dispatch_note': 'TEXT',
      });
      _log('Upgraded transfer dispatch-note schema to version 5');
    }
    if (oldVersion < 6) {
      await _addMissingColumns(db, DatabaseTables.transfers, const {
        'rejection_remarks': 'TEXT',
      });
      _log('Upgraded transfer rejection remarks schema to version 6');
    }
    if (oldVersion < 7) {
      await _addMissingColumns(db, DatabaseTables.requests, const {
        'answer_photo_urls': "TEXT NOT NULL DEFAULT '[]'",
      });
      _log('Upgraded request answer-proof schema to version 7');
    }
    if (oldVersion < 8) {
      await _addMissingColumns(db, DatabaseTables.collections, const {
        'rejection_remarks': 'TEXT',
      });
      await _addMissingColumns(db, DatabaseTables.expenses, const {
        'decision_remarks': 'TEXT',
      });
      await _addMissingColumns(db, DatabaseTables.cashRequests, const {
        'decision_remarks': 'TEXT',
      });
      _log(
        'Upgraded collection and expense decision remarks schema to version 8',
      );
    }
    if (oldVersion < 10) {
      await _rebuildVehiclesWithoutType(db);
      _log('Removed D2D vehicle type and capacity schema in version 10');
    }
    if (oldVersion < 11) {
      await _rebuildNotificationsWithRoleScope(db);
      _log('Added notification role and optional center scope in version 11');
    }
    if (oldVersion < 12) {
      await _addMissingColumns(db, DatabaseTables.tasks, const {
        'reference_photo_urls': "TEXT NOT NULL DEFAULT '[]'",
      });
      await db.rawUpdate(
        '''
        UPDATE ${DatabaseTables.tasks}
        SET reference_photo_urls = photo_urls,
            photo_urls = '[]'
        WHERE EXISTS (
          SELECT 1 FROM ${DatabaseTables.outbox} o
          WHERE o.entity = ? AND o.entity_id = ${DatabaseTables.tasks}.id
            AND o.kind = 'assign'
        )
          AND photo_urls <> '[]'
      ''',
        [DatabaseTables.tasks],
      );
      await db.update(
        DatabaseTables.photos,
        {'field': 'reference'},
        where: 'owner_table = ? AND field = ?',
        whereArgs: [DatabaseTables.tasks, 'assignment'],
      );
      await db.rawUpdate(
        '''
        UPDATE ${DatabaseTables.outbox}
        SET status = 'queued', attempts = 0, last_error = NULL,
            next_attempt_at = NULL
        WHERE entity = ? AND method = 'PUT' AND status = 'failed'
          AND last_error LIKE '%UNRECOGNIZED_KEYS%'
      ''',
        [DatabaseTables.tasks],
      );
      _log('Added task reference-photo schema in version 12');
    }
  }

  Future<void> _rebuildNotificationsWithRoleScope(Database db) async {
    final columns = await db.rawQuery(
      'PRAGMA table_info("${DatabaseTables.notifications}")',
    );
    if (columns.isEmpty) return;
    final names = columns.map((row) => row['name']).toSet();
    final roleExpression = names.contains('role') ? 'role' : 'NULL';
    final centerExpression = names.contains('center_id') ? 'center_id' : 'NULL';

    await db.execute('PRAGMA defer_foreign_keys = ON');
    await db.execute('''
      CREATE TABLE notifications_new (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT,
        deep_link TEXT,
        role TEXT,
        center_id TEXT REFERENCES ${DatabaseTables.centers} (id),
        created_at TEXT NOT NULL,
        read_at TEXT,
        sync_state TEXT NOT NULL DEFAULT 'synced'
      )
    ''');
    await db.execute('''
      INSERT INTO notifications_new (
        id, type, title, body, deep_link, role, center_id,
        created_at, read_at, sync_state
      )
      SELECT
        id, type, title, body, deep_link, $roleExpression, $centerExpression,
        created_at, read_at, sync_state
      FROM ${DatabaseTables.notifications}
    ''');
    await db.execute('DROP TABLE ${DatabaseTables.notifications}');
    await db.execute(
      'ALTER TABLE notifications_new RENAME TO ${DatabaseTables.notifications}',
    );
    await db.execute(
      'CREATE INDEX ix_notifications_time ON '
      '${DatabaseTables.notifications} (created_at)',
    );
    await db.execute(
      'CREATE INDEX ix_notifications_role ON '
      '${DatabaseTables.notifications} (role, created_at)',
    );
  }

  Future<void> _rebuildVehiclesWithoutType(Database db) async {
    final columns = await db.rawQuery(
      'PRAGMA table_info("${DatabaseTables.vehicles}")',
    );
    if (columns.isEmpty) {
      await db.execute('DROP TABLE IF EXISTS vehicle_types');
      return;
    }
    await db.execute('PRAGMA defer_foreign_keys = ON');
    await db.execute('''
      CREATE TABLE vehicles_new (
        id TEXT PRIMARY KEY,
        number TEXT,
        center_id TEXT REFERENCES ${DatabaseTables.centers} (id),
        plate_number TEXT NOT NULL,
        driver_name TEXT,
        is_active INTEGER NOT NULL,
        sync_state TEXT NOT NULL DEFAULT 'synced'
      )
    ''');
    await db.execute('''
      INSERT INTO vehicles_new (
        id, number, center_id, plate_number, driver_name, is_active, sync_state
      )
      SELECT
        id, number, center_id, plate_number, driver_name, is_active, sync_state
      FROM ${DatabaseTables.vehicles}
    ''');
    await db.execute('DROP TABLE ${DatabaseTables.vehicles}');
    await db.execute(
      'ALTER TABLE vehicles_new RENAME TO ${DatabaseTables.vehicles}',
    );
    await db.execute(
      'CREATE INDEX ix_vehicles_center ON '
      '${DatabaseTables.vehicles} (center_id, is_active)',
    );
    await db.execute('DROP TABLE IF EXISTS vehicle_types');
    await _sanitizeQueuedVehicleWrites(db);
  }

  Future<void> _sanitizeQueuedVehicleWrites(Database db) async {
    final outboxExists = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      [DatabaseTables.outbox],
    );
    if (outboxExists.isEmpty) return;

    final writes = await db.query(
      DatabaseTables.outbox,
      columns: const ['seq', 'body'],
      where: "entity = ? AND kind = 'upsert'",
      whereArgs: const [DatabaseTables.vehicles],
    );
    for (final write in writes) {
      final rawBody = write['body'] as String?;
      if (rawBody == null) continue;
      final decoded = jsonDecode(rawBody);
      if (decoded is! Map) continue;
      final body = Map<String, Object?>.from(decoded);
      final removedType = body.containsKey('typeId');
      final removedCapacity = body.containsKey('capacityKg');
      if (!removedType && !removedCapacity) continue;
      body.remove('typeId');
      body.remove('capacityKg');
      await db.update(
        DatabaseTables.outbox,
        {'body': jsonEncode(body)},
        where: 'seq = ?',
        whereArgs: [write['seq']],
      );
    }
  }

  Future<void> _onOpen(Database db) async {
    await db.execute('PRAGMA foreign_keys = OFF');
    await _ensureVersionOneSchema(db);
    await _removeOrphanedOutboxPhotoLinks(db);
    final foreignKeyErrors = await db.rawQuery('PRAGMA foreign_key_check');
    if (foreignKeyErrors.isNotEmpty) {
      _log(
        'Database opened with ${foreignKeyErrors.length} foreign-key '
        'violation(s); enforcement remains disabled',
      );
    }
  }

  /// Link rows do not contain user data by themselves. If a previous queue
  /// cleanup was interrupted after deleting its parent row, remove only the
  /// unusable links so a recoverable queue inconsistency cannot block startup.
  Future<void> _removeOrphanedOutboxPhotoLinks(Database db) async {
    final requiredTables = await db.rawQuery(
      '''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table' AND name IN (?, ?, ?)
    ''',
      [
        DatabaseTables.outboxPhotos,
        DatabaseTables.outbox,
        DatabaseTables.photos,
      ],
    );
    if (requiredTables.length != 3) return;
    final removed = await db.rawDelete('''
      DELETE FROM ${DatabaseTables.outboxPhotos}
      WHERE NOT EXISTS (
        SELECT 1
        FROM ${DatabaseTables.outbox}
        WHERE ${DatabaseTables.outbox}.seq =
              ${DatabaseTables.outboxPhotos}.outbox_seq
      )
      OR NOT EXISTS (
        SELECT 1
        FROM ${DatabaseTables.photos}
        WHERE ${DatabaseTables.photos}.id =
              ${DatabaseTables.outboxPhotos}.photo_id
      )
    ''');
    if (removed > 0) {
      _log('Removed $removed orphaned outbox photo link(s) during startup');
    }
  }

  Future<void> ensureCurrentSchema() async {
    await _ensureVersionOneSchema(await database);
  }

  Future<void> _ensureVersionOneSchema(Database db) async {
    // The testing database intentionally stays at version 1. Keep an existing
    // version-1 installation aligned with the current baseline schema without
    // introducing numbered migrations or deleting any local data.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseTables.transferVehicles} (
        id TEXT PRIMARY KEY,
        number TEXT NOT NULL,
        ownership TEXT NOT NULL,
        transporter_name TEXT,
        vehicle_type TEXT,
        capacity_kg REAL
      )
    ''');

    const additiveColumns = <String, Map<String, String>>{
      DatabaseTables.myCenters: {'agent_number': 'INTEGER'},
      DatabaseTables.vehicles: {'number': 'TEXT'},
      DatabaseTables.mrfPeople: {'number': 'TEXT'},
      DatabaseTables.ragpickers: {'number': 'TEXT'},
      DatabaseTables.cashRequests: {
        'number': 'TEXT',
        'decision_remarks': 'TEXT',
      },
      DatabaseTables.categoryRequests: {
        'number': 'TEXT',
        'requested_by_name': 'TEXT',
        'decided_by_name': 'TEXT',
        'decided_at': 'TEXT',
        'decision_reason': 'TEXT',
      },
      DatabaseTables.tasks: {
        'number': 'TEXT',
        'note': 'TEXT',
        'reference_photo_urls': "TEXT NOT NULL DEFAULT '[]'",
      },
      DatabaseTables.requests: {
        'number': 'TEXT',
        'follow_up_at': 'TEXT',
        'answer_photo_urls': "TEXT NOT NULL DEFAULT '[]'",
      },
      DatabaseTables.expenses: {'decision_remarks': 'TEXT'},
      DatabaseTables.collections: {
        'gps_lat': 'REAL',
        'gps_lng': 'REAL',
        'rejection_remarks': 'TEXT',
      },
      DatabaseTables.transfers: {
        'note': 'TEXT',
        'dispatch_note': 'TEXT',
        'gps_lat': 'REAL',
        'gps_lng': 'REAL',
        'driver_name': 'TEXT',
        'dispatched_weight': 'REAL',
        'bale_count': 'INTEGER',
        'vehicle_photo_urls': "TEXT NOT NULL DEFAULT '[]'",
        'weighbridge_photo_urls': "TEXT NOT NULL DEFAULT '[]'",
        'transfer_vehicle_id': 'TEXT',
        'planned_vehicle_number': 'TEXT',
        'planned_vehicle_ownership': 'TEXT',
        'transporter_name': 'TEXT',
        'transfer_fee': 'REAL',
        'vehicle_differs': 'INTEGER NOT NULL DEFAULT 0',
        'rejection_remarks': 'TEXT',
      },
      DatabaseTables.items: {
        'image_url': 'TEXT',
        'is_active': 'INTEGER NOT NULL DEFAULT 1',
      },
      DatabaseTables.notifications: {'role': 'TEXT', 'center_id': 'TEXT'},
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

  Future<void> _addMissingColumns(
    DatabaseExecutor db,
    String table,
    Map<String, String> columns,
  ) async {
    final tableInfo = await db.rawQuery('PRAGMA table_info("$table")');
    if (tableInfo.isEmpty) return;
    final existing = tableInfo.map((row) => row['name']).toSet();
    for (final entry in columns.entries) {
      if (existing.contains(entry.key)) continue;
      await db.execute(
        'ALTER TABLE "$table" ADD COLUMN "${entry.key}" ${entry.value}',
      );
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
        DatabaseTables.transferVehicles,
        DatabaseTables.centerItems,
        DatabaseTables.vehicles,
        DatabaseTables.mrfPeople,
        DatabaseTables.ragpickers,
        DatabaseTables.expenseCategories,
        DatabaseTables.centerPeople,
        DatabaseTables.myCenters,
        DatabaseTables.centerChannels,
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
        DatabaseTables.transferVehicles,
        DatabaseTables.centerItems,
        DatabaseTables.vehicles,
        DatabaseTables.mrfPeople,
        DatabaseTables.ragpickers,
        DatabaseTables.expenseCategories,
        DatabaseTables.centerPeople,
        DatabaseTables.myCenters,
        DatabaseTables.centerChannels,
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
    AppLogger.sqlite('TABLES', tableNames.join(', '));
  }

  static void _log(String message) {
    AppLogger.sqlite('DATABASE', '$_logTag $message');
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
