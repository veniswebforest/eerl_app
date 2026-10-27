import 'dart:convert';
import 'dart:typed_data';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';

/// Builds a diagnostic export containing rows from only the `outbox` table.
class OutboxExportService {
  OutboxExportService({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<Uint8List> buildTextExport() async {
    final rows = await _database.query(
      DatabaseTables.outbox,
      orderBy: 'seq ASC',
    );
    final json = const JsonEncoder.withIndent('  ').convert(rows);
    return Uint8List.fromList(utf8.encode(json));
  }
}
