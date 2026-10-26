import 'dart:convert';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.instance;
  late String databasePath;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(
      await getDatabasesPath(),
      'vehicle_capacity_migration.db',
    );
    await deleteDatabase(databasePath);

    final legacy = await openDatabase(
      databasePath,
      version: 8,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async {
        await db.execute('CREATE TABLE centers (id TEXT PRIMARY KEY)');
        await db.execute(
          'CREATE TABLE vehicle_types (id TEXT PRIMARY KEY, name TEXT NOT NULL)',
        );
        await db.execute('''
          CREATE TABLE vehicles (
            id TEXT PRIMARY KEY,
            number TEXT,
            center_id TEXT REFERENCES centers (id),
            plate_number TEXT NOT NULL,
            type_id TEXT NOT NULL REFERENCES vehicle_types (id),
            type_name TEXT NOT NULL,
            capacity_kg REAL,
            driver_name TEXT,
            is_active INTEGER NOT NULL,
            sync_state TEXT NOT NULL DEFAULT 'synced'
          )
        ''');
        await db.execute(
          'CREATE INDEX ix_vehicles_center ON vehicles (center_id, is_active)',
        );
        await db.execute('''
          CREATE TABLE collections (
            id TEXT PRIMARY KEY,
            vehicle_id TEXT REFERENCES vehicles (id)
          )
        ''');
        await db.execute('''
          CREATE TABLE outbox (
            seq INTEGER PRIMARY KEY AUTOINCREMENT,
            method TEXT NOT NULL,
            path TEXT NOT NULL,
            body TEXT,
            entity TEXT NOT NULL,
            entity_id TEXT NOT NULL,
            kind TEXT,
            refs TEXT,
            status TEXT NOT NULL,
            attempts INTEGER NOT NULL DEFAULT 0,
            last_error TEXT,
            next_attempt_at TEXT,
            created_at TEXT NOT NULL
          )
        ''');
        await db.insert('centers', {'id': 'center-1'});
        await db.insert('vehicle_types', {
          'id': 'type-1',
          'name': 'Mini Truck',
        });
        await db.insert('vehicles', {
          'id': 'pending-vehicle',
          'number': null,
          'center_id': 'center-1',
          'plate_number': 'GJ-05-AB-1234',
          'type_id': 'type-1',
          'type_name': 'Mini Truck',
          'capacity_kg': 1250,
          'driver_name': 'Ketan Patel',
          'is_active': 1,
          'sync_state': 'pending',
        });
        await db.insert('collections', {
          'id': 'collection-1',
          'vehicle_id': 'pending-vehicle',
        });
        await db.insert('outbox', {
          'method': 'PUT',
          'path': '/vehicles/pending-vehicle',
          'body': jsonEncode({
            'centerId': 'center-1',
            'plateNumber': 'GJ-05-AB-1234',
            'typeId': 'type-1',
            'capacityKg': 1250,
            'driverName': 'Ketan Patel',
          }),
          'entity': 'vehicles',
          'entity_id': 'pending-vehicle',
          'kind': 'upsert',
          'refs': jsonEncode(['center-1', 'type-1']),
          'status': 'queued',
          'created_at': '2026-10-25T10:00:00.000Z',
        });
      },
    );
    await legacy.close();
    AppDatabase.setDatabasePathForTesting(databasePath);
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test(
    'version 10 removes D2D type tables and preserves pending rows',
    () async {
      final columns = await database.rawQuery(
        'PRAGMA table_info("${DatabaseTables.vehicles}")',
      );
      final vehicle = (await database.query(
        DatabaseTables.vehicles,
        where: 'id = ?',
        whereArgs: const ['pending-vehicle'],
      )).single;
      final collection = (await database.query(
        DatabaseTables.collections,
        where: 'id = ?',
        whereArgs: const ['collection-1'],
      )).single;
      final foreignKeyErrors = await database.rawQuery(
        'PRAGMA foreign_key_check',
      );
      final indexes = await database.getExistingIndexNames();
      final version = await database.rawQuery('PRAGMA user_version');
      final queued = (await database.query('outbox')).single;
      final queuedBody = jsonDecode(queued['body']! as String) as Map;

      expect(columns.map((row) => row['name']), isNot(contains('capacity_kg')));
      expect(columns.map((row) => row['name']), isNot(contains('type_id')));
      expect(columns.map((row) => row['name']), isNot(contains('type_name')));
      expect(
        await database.getExistingTableNames(),
        isNot(contains('vehicle_types')),
      );
      expect(vehicle['plate_number'], 'GJ-05-AB-1234');
      expect(vehicle['driver_name'], 'Ketan Patel');
      expect(vehicle['sync_state'], 'pending');
      expect(collection['vehicle_id'], 'pending-vehicle');
      expect(foreignKeyErrors, isEmpty);
      expect(indexes, contains('ix_vehicles_center'));
      expect(version.single['user_version'], AppDatabase.databaseVersion);
      expect(queuedBody, {
        'centerId': 'center-1',
        'plateNumber': 'GJ-05-AB-1234',
        'driverName': 'Ketan Patel',
      });
    },
  );
}
