import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final appDatabase = AppDatabase.instance;
  late String databasePath;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(
      await getDatabasesPath(),
      'app_database_repair_test.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  tearDownAll(() async {
    await appDatabase.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test(
    'removes orphaned outbox photo links before validating on open',
    () async {
      await appDatabase.insert(DatabaseTables.photos, const {
        'id': 'photo-1',
        'owner_table': 'collections',
        'owner_id': 'collection-1',
        'purpose': 'item',
        'content_type': 'image/jpeg',
        'status': 'local',
        'created_at': '2026-10-27T00:00:00.000Z',
      });
      final outboxSequence = await appDatabase
          .insert(DatabaseTables.outbox, const {
            'method': 'POST',
            'path': '/collections/collection-1/submit',
            'entity': 'collections',
            'entity_id': 'collection-1',
            'status': 'queued',
            'created_at': '2026-10-27T00:00:00.000Z',
          });
      await appDatabase.insert(DatabaseTables.outboxPhotos, {
        'outbox_seq': outboxSequence,
        'photo_id': 'photo-1',
      });
      await appDatabase.closeForTesting();

      final rawDatabase = await openDatabase(
        databasePath,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = OFF'),
      );
      await rawDatabase.delete(
        DatabaseTables.outbox,
        where: 'seq = ?',
        whereArgs: [outboxSequence],
      );
      await rawDatabase.close();

      expect(await appDatabase.query(DatabaseTables.outboxPhotos), isEmpty);
      expect(await appDatabase.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    },
  );
}
