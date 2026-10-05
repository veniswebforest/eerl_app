import 'package:eerl_app/core/local_database/database_migrations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('version 2 adds server numbers and outbox photo index safely', () async {
    final db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    for (final table in <String>[
      'my_centers',
      'vehicles',
      'mrf_people',
      'ragpickers',
      'cash_requests',
      'category_requests',
      'tasks',
      'requests',
    ]) {
      await db.execute('CREATE TABLE $table (id TEXT)');
    }
    await db.execute(
      'CREATE TABLE outbox_photos (outbox_seq INTEGER, photo_id TEXT)',
    );

    await DatabaseMigrations.upgrade(db, 1, 2);
    await DatabaseMigrations.upgrade(db, 1, 2);

    expect(await _hasColumn(db, 'my_centers', 'agent_number'), isTrue);
    for (final table in <String>[
      'vehicles',
      'mrf_people',
      'ragpickers',
      'cash_requests',
      'category_requests',
      'tasks',
      'requests',
    ]) {
      expect(await _hasColumn(db, table, 'number'), isTrue, reason: table);
    }
    final indexes = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'index'",
    );
    expect(indexes.map((row) => row['name']), contains('ix_outbox_photos'));
  });

  test('version 3 normalizes legacy queue states and paths', () async {
    final db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    await db.execute('CREATE TABLE outbox (status TEXT, path TEXT)');
    await db.execute('CREATE TABLE photos (status TEXT)');
    await db.insert('outbox', {
      'status': 'pending',
      'path': '/api/v1/mobile/expenses/expense-1',
    });
    await db.insert('photos', {'status': 'queued'});

    await DatabaseMigrations.upgrade(db, 2, 3);

    final outbox = (await db.query('outbox')).single;
    final photo = (await db.query('photos')).single;
    expect(outbox['status'], 'queued');
    expect(outbox['path'], '/expenses/expense-1');
    expect(photo['status'], 'local');
  });

  test('version 4 removes orphan rows before enabling foreign keys', () async {
    final db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    await db.execute('CREATE TABLE collections (id TEXT PRIMARY KEY)');
    await db.execute('CREATE TABLE items (id TEXT PRIMARY KEY)');
    await db.execute('CREATE TABLE transfers (id TEXT PRIMARY KEY)');
    await db.execute('CREATE TABLE outbox (seq INTEGER PRIMARY KEY)');
    await db.execute('CREATE TABLE photos (id TEXT PRIMARY KEY)');
    await db.execute('''
      CREATE TABLE collection_items (
        id TEXT PRIMARY KEY,
        collection_id TEXT NOT NULL,
        item_id TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transfer_items (
        id TEXT PRIMARY KEY,
        transfer_id TEXT NOT NULL,
        item_id TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE outbox_photos (
        outbox_seq INTEGER NOT NULL,
        photo_id TEXT NOT NULL
      )
    ''');

    await db.insert('collections', {'id': 'collection-1'});
    await db.insert('items', {'id': 'item-1'});
    await db.insert('transfers', {'id': 'transfer-1'});
    await db.insert('outbox', {'seq': 1});
    await db.insert('photos', {'id': 'photo-1'});
    await db.insert('collection_items', {
      'id': 'valid-line',
      'collection_id': 'collection-1',
      'item_id': 'item-1',
    });
    await db.insert('collection_items', {
      'id': 'orphan-line',
      'collection_id': 'missing',
      'item_id': 'item-1',
    });
    await db.insert('transfer_items', {
      'id': 'orphan-transfer-line',
      'transfer_id': 'missing',
      'item_id': 'item-1',
    });
    await db.insert('outbox_photos', {'outbox_seq': 1, 'photo_id': 'missing'});

    await DatabaseMigrations.upgrade(db, 3, 4);

    expect((await db.query('collection_items')).map((row) => row['id']), [
      'valid-line',
    ]);
    expect(await db.query('transfer_items'), isEmpty);
    expect(await db.query('outbox_photos'), isEmpty);
  });

  test('version 5 adds the production task note column safely', () async {
    final db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    await db.execute('CREATE TABLE tasks (id TEXT PRIMARY KEY)');

    await DatabaseMigrations.upgrade(db, 4, 5);
    await DatabaseMigrations.upgrade(db, 4, 5);

    expect(await _hasColumn(db, 'tasks', 'note'), isTrue);
  });
}

Future<bool> _hasColumn(Database db, String table, String column) async {
  final rows = await db.rawQuery('PRAGMA table_info("$table")');
  return rows.any((row) => row['name'] == column);
}
