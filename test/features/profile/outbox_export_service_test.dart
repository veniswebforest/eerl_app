import 'dart:convert';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/profile/service/outbox_export_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.instance;
  late String databasePath;
  late OutboxExportService service;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(
      await getDatabasesPath(),
      'outbox_export_service_test.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
    service = OutboxExportService(database: database);
  });

  setUp(() => database.clearDatabaseOnLogout());

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('exports only outbox rows in sequence order', () async {
    await database.setSyncMeta('private_test_value', 'must-not-be-exported');
    await database.insert(DatabaseTables.outbox, {
      'method': 'PUT',
      'path': '/collections/collection-2',
      'body': '{"type":"RAMP"}',
      'entity': 'collections',
      'entity_id': 'collection-2',
      'kind': 'draft_save',
      'status': 'failed',
      'attempts': 1,
      'last_error': 'offline',
      'created_at': '2026-10-27T02:00:00.000Z',
    });
    await database.insert(DatabaseTables.outbox, {
      'method': 'POST',
      'path': '/tasks/task-1/complete',
      'body': '{"note":"Done"}',
      'entity': 'tasks',
      'entity_id': 'task-1',
      'kind': 'complete',
      'status': 'queued',
      'created_at': '2026-10-27T03:00:00.000Z',
    });

    final encoded = await service.buildTextExport();
    final raw = utf8.decode(encoded);
    final rows = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();

    expect(rows, hasLength(2));
    expect(rows.map((row) => row['seq']), orderedEquals([1, 2]));
    expect(rows.first['entity_id'], 'collection-2');
    expect(rows.last['entity_id'], 'task-1');
    expect(raw, isNot(contains('must-not-be-exported')));
    expect(raw, isNot(contains('private_test_value')));
  });

  test('exports an empty JSON array when outbox has no rows', () async {
    expect(jsonDecode(utf8.decode(await service.buildTextExport())), isEmpty);
  });
}
