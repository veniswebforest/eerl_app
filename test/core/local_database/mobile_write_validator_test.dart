import 'dart:convert';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/core/local_database/mobile_write_validator.dart';
import 'package:eerl_app/core/local_database/outbox_queue.dart';
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
      'mobile_write_validator_test.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(database.clearDatabaseOnLogout);

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test(
    'invalid payload rolls back the local row and outbox together',
    () async {
      await expectLater(
        database.runInTransaction((txn) async {
          await txn.insert(DatabaseTables.syncMeta, {
            'key': 'validation-probe',
            'value': 'must-roll-back',
          });
          await OutboxQueue.enqueue(
            txn,
            method: 'PUT',
            path: '/tasks/task-1',
            entity: DatabaseTables.tasks,
            entityId: 'task-1',
            body: {
              'assignedToId': 'agent-1',
              'centerId': 'center-1',
              'title': 'No',
            },
          );
        }),
        throwsA(isA<LocalWriteValidationException>()),
      );

      expect(await database.getSyncMeta('validation-probe'), isNull);
      expect(await database.query(DatabaseTables.outbox), isEmpty);
    },
  );

  test('valid payload is queued', () async {
    await database.runInTransaction((txn) async {
      await OutboxQueue.enqueue(
        txn,
        method: 'PUT',
        path: '/requests/request-1',
        entity: DatabaseTables.requests,
        entityId: 'request-1',
        body: {
          'centerId': 'center-1',
          'body': 'Please repair the weighing scale.',
          'priority': 'NORMAL',
          'followUpAt': '2026-10-29T10:00:00.000Z',
          'photoUrls': <String>[],
        },
      );
    });

    final queued = (await database.query(DatabaseTables.outbox)).single;
    expect(queued['path'], '/requests/request-1');
    expect(
      jsonDecode(queued['body']! as String),
      containsPair('priority', 'NORMAL'),
    );
  });
}
