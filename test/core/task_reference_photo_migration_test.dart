import 'dart:convert';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'version 12 separates queued assignment photos from completion proof',
    () async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final path = p.join(
        await getDatabasesPath(),
        'task_reference_photo_migration_test.db',
      );
      await deleteDatabase(path);
      addTearDown(() async {
        await AppDatabase.instance.closeForTesting();
        AppDatabase.setDatabasePathForTesting(null);
        await deleteDatabase(path);
      });

      final legacy = await openDatabase(
        path,
        version: 11,
        onCreate: (db, _) async {
          await db.execute('''
          CREATE TABLE tasks (
            id TEXT PRIMARY KEY,
            photo_urls TEXT NOT NULL DEFAULT '[]'
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
            refs TEXT NOT NULL DEFAULT '[]',
            status TEXT NOT NULL,
            attempts INTEGER NOT NULL DEFAULT 0,
            last_error TEXT,
            next_attempt_at TEXT,
            created_at TEXT NOT NULL
          )
        ''');
          await db.execute('''
          CREATE TABLE photos (
            id TEXT PRIMARY KEY,
            owner_table TEXT NOT NULL,
            owner_id TEXT NOT NULL,
            field TEXT NOT NULL
          )
        ''');
        },
      );
      await legacy.insert('tasks', {
        'id': 'task-1',
        'photo_urls': jsonEncode(['/tmp/reference.jpg']),
      });
      await legacy.insert('photos', {
        'id': 'photo-1',
        'owner_table': 'tasks',
        'owner_id': 'task-1',
        'field': 'assignment',
      });
      await legacy.insert('outbox', {
        'method': 'PUT',
        'path': '/tasks/task-1',
        'body': '{}',
        'entity': 'tasks',
        'entity_id': 'task-1',
        'kind': 'assign',
        'status': 'failed',
        'attempts': 1,
        'last_error': '400 UNRECOGNIZED_KEYS photoUrls',
        'created_at': '2026-10-30T09:00:00.000Z',
      });
      await legacy.close();

      AppDatabase.setDatabasePathForTesting(path);
      final database = AppDatabase.instance;
      final task = (await database.query(DatabaseTables.tasks)).single;
      final photo = (await database.query(DatabaseTables.photos)).single;
      final outbox = (await database.query(DatabaseTables.outbox)).single;

      expect(task['photo_urls'], '[]');
      expect(jsonDecode(task['reference_photo_urls']! as String), [
        '/tmp/reference.jpg',
      ]);
      expect(photo['field'], 'reference');
      expect(outbox['status'], 'queued');
      expect(outbox['attempts'], 0);
      expect(outbox['last_error'], isNull);
      expect(
        (await database.rawQuery('PRAGMA user_version')).single['user_version'],
        AppDatabase.databaseVersion,
      );
    },
  );
}
