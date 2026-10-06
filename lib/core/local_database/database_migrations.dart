import 'package:sqflite/sqflite.dart';

abstract final class DatabaseMigrations {
  static Future<void> upgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2 && newVersion >= 2) {
      await _addColumnIfMissing(db, 'my_centers', 'agent_number', 'INTEGER');
      for (final table in <String>[
        'vehicles',
        'mrf_people',
        'ragpickers',
        'cash_requests',
        'category_requests',
        'tasks',
        'requests',
      ]) {
        await _addColumnIfMissing(db, table, 'number', 'TEXT');
      }
      await db.execute(
        'CREATE INDEX IF NOT EXISTS ix_outbox_photos '
        'ON outbox_photos (photo_id)',
      );
    }
    if (oldVersion < 3 && newVersion >= 3) {
      // Normalize rows queued by the earlier offline implementation to the
      // status vocabulary used by the current outbox/photo state machines.
      await db.rawUpdate(
        "UPDATE outbox SET status = 'queued' WHERE status = 'pending'",
      );
      await db.rawUpdate(
        "UPDATE photos SET status = 'local' WHERE status IN ('pending', 'queued')",
      );
      await db.rawUpdate(
        "UPDATE outbox SET path = substr(path, 15) "
        "WHERE path LIKE '/api/v1/mobile/%'",
      );
    }
    if (oldVersion < 4 && newVersion >= 4) {
      // Foreign-key enforcement was enabled in v4. Remove only legacy child
      // rows that cannot be connected to both of their required parents.
      // Valid collection graphs and every pending parent remain untouched.
      await db.rawDelete('''
        DELETE FROM collection_items
        WHERE NOT EXISTS (
          SELECT 1 FROM collections c WHERE c.id = collection_items.collection_id
        ) OR NOT EXISTS (
          SELECT 1 FROM items i WHERE i.id = collection_items.item_id
        )
      ''');
      await db.rawDelete('''
        DELETE FROM transfer_items
        WHERE NOT EXISTS (
          SELECT 1 FROM transfers t WHERE t.id = transfer_items.transfer_id
        ) OR NOT EXISTS (
          SELECT 1 FROM items i WHERE i.id = transfer_items.item_id
        )
      ''');
      await db.rawDelete('''
        DELETE FROM outbox_photos
        WHERE NOT EXISTS (
          SELECT 1 FROM outbox o WHERE o.seq = outbox_photos.outbox_seq
        ) OR NOT EXISTS (
          SELECT 1 FROM photos p WHERE p.id = outbox_photos.photo_id
        )
      ''');
    }
    if (oldVersion < 5 && newVersion >= 5) {
      // The production Bootstrap payload uses `note` for task details. Keep
      // `description` for locally-created/older rows and store the server key
      // unchanged, as required for response.data.tables fields.
      await _addColumnIfMissing(db, 'tasks', 'note', 'TEXT');
    }
    if (oldVersion < 6 && newVersion >= 6) {
      await _addColumnIfMissing(db, 'collections', 'gps_lat', 'REAL');
      await _addColumnIfMissing(db, 'collections', 'gps_lng', 'REAL');
      await _addColumnIfMissing(db, 'transfers', 'gps_lat', 'REAL');
      await _addColumnIfMissing(db, 'transfers', 'gps_lng', 'REAL');
      await _addColumnIfMissing(db, 'items', 'image_url', 'TEXT');
      await db.insert('sync_meta', {
        'key': 'item_images_refetch_required',
        'value': '1',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  static Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info("$table")');
    if (columns.any((row) => row['name'] == column)) return;
    await db.execute('ALTER TABLE "$table" ADD COLUMN "$column" $type');
  }
}
