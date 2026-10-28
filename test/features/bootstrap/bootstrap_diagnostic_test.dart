import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/bootstrap/data/bootstrap_database_applier.dart';
import 'package:eerl_app/features/bootstrap/model/bootstrap_response.dart';
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
      'bootstrap_diagnostic_test.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
  });

  setUp(() async {
    await database.closeForTesting();
    await deleteDatabase(databasePath);
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test(
    'missing foreign-key parent is diagnostic and does not block sync',
    () async {
      final data = BootstrapData.fromJson({
        'cursor': 'bad-fk-page',
        'hasMore': false,
        'full': true,
        'tables': {
          'notifications': {
            'upserts': [
              {
                'id': 'notification-bad-center',
                'type': 'TASK_ASSIGNED',
                'title': 'New task',
                'center_id': 'missing-center',
                'created_at': '2026-10-28T09:00:00.000Z',
              },
            ],
          },
        },
      });

      await BootstrapDatabaseApplier(database: database).apply(data);

      final foreignKeySetting = await database.rawQuery('PRAGMA foreign_keys');
      expect(foreignKeySetting.single['foreign_keys'], 0);
      final notification = (await database.query(
        DatabaseTables.notifications,
      )).single;
      expect(notification['id'], 'notification-bad-center');
      expect(notification['center_id'], 'missing-center');
      expect(await database.getSyncMeta('cursor'), 'bad-fk-page');
    },
  );

  test('missing required value is reported before inserting rows', () async {
    final data = BootstrapData.fromJson({
      'cursor': 'bad-required-page',
      'hasMore': false,
      'full': true,
      'tables': {
        'centers': {
          'replace': [
            {'id': 'center-without-name'},
          ],
        },
      },
    });

    await expectLater(
      BootstrapDatabaseApplier(database: database).apply(data),
      throwsA(
        isA<BootstrapDataException>()
            .having(
              (error) => error.message,
              'message',
              contains('table=centers'),
            )
            .having(
              (error) => error.message,
              'message',
              contains('id=center-without-name'),
            )
            .having(
              (error) => error.message,
              'message',
              contains('column=name'),
            )
            .having(
              (error) => error.message,
              'message',
              contains('REQUIRED_COLUMN_MISSING'),
            ),
      ),
    );
    expect(await database.getSyncMeta('cursor'), isNull);
  });
}
