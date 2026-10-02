import 'package:sqflite/sqflite.dart';

abstract final class DatabaseMigrations {
  static Future<void> upgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Add forward-only, non-destructive migrations here as the schema evolves.
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE example ADD COLUMN value TEXT');
    // }
  }
}
