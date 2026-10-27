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
      'notification_role_migration.db',
    );
    await deleteDatabase(databasePath);
    final legacy = await openDatabase(
      databasePath,
      version: 10,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) async {
        await db.execute('CREATE TABLE centers (id TEXT PRIMARY KEY)');
        await db.execute('''
          CREATE TABLE notifications (
            id TEXT PRIMARY KEY,
            type TEXT NOT NULL,
            title TEXT NOT NULL,
            body TEXT,
            deep_link TEXT,
            role TEXT,
            center_id TEXT NOT NULL REFERENCES centers (id),
            created_at TEXT NOT NULL,
            read_at TEXT,
            sync_state TEXT NOT NULL DEFAULT 'synced'
          )
        ''');
        await db.execute(
          'CREATE INDEX ix_notifications_time ON notifications (created_at)',
        );
        await db.execute('CREATE TABLE photos (id TEXT PRIMARY KEY)');
        await db.execute(
          'CREATE TABLE outbox (seq INTEGER PRIMARY KEY AUTOINCREMENT)',
        );
        await db.execute('''
          CREATE TABLE outbox_photos (
            outbox_seq INTEGER NOT NULL REFERENCES outbox (seq),
            photo_id TEXT NOT NULL REFERENCES photos (id),
            PRIMARY KEY (outbox_seq, photo_id)
          )
        ''');
        await db.insert('centers', {'id': 'center-1'});
        await db.insert('notifications', {
          'id': 'existing-notification',
          'type': 'TASK',
          'title': 'Existing',
          'role': 'AGENT',
          'center_id': 'center-1',
          'created_at': '2026-10-20T08:00:00.000Z',
          'sync_state': 'pending',
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
    'version 11 keeps rows and makes notification center optional',
    () async {
      final columns = await database.rawQuery(
        'PRAGMA table_info("${DatabaseTables.notifications}")',
      );
      final centerColumn = columns.singleWhere(
        (row) => row['name'] == 'center_id',
      );
      final existing = (await database.query(
        DatabaseTables.notifications,
        where: 'id = ?',
        whereArgs: const ['existing-notification'],
      )).single;

      expect(centerColumn['notnull'], 0);
      expect(existing['role'], 'AGENT');
      expect(existing['center_id'], 'center-1');
      expect(existing['sync_state'], 'pending');
      expect(
        await database.getExistingIndexNames(),
        contains('ix_notifications_role'),
      );

      await database.insert(DatabaseTables.notifications, {
        'id': 'no-center',
        'type': 'SYSTEM',
        'title': 'No center',
        'created_at': '2026-10-20T09:00:00.000Z',
      });
      final noCenter = (await database.query(
        DatabaseTables.notifications,
        where: 'id = ?',
        whereArgs: const ['no-center'],
      )).single;
      expect(noCenter['center_id'], isNull);
    },
  );
}
