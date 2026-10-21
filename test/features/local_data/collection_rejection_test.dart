import 'dart:convert';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.instance;
  final repository = EerlLocalRepository.instance;
  late String databasePath;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(
      await getDatabasesPath(),
      'collection_rejection_test.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.accessTokenKey: 'supervisor-token',
    });
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await database.setSyncMeta('active_center_id', 'center-1');
    await database.setSyncMeta('user_id', 'supervisor-1');
    await database.setSyncMeta('user_name', 'Supervisor One');
    await database.insert(DatabaseTables.collections, {
      'id': 'collection-1',
      'center_id': 'center-1',
      'agent_id': 'agent-1',
      'agent_name': 'Agent One',
      'channel': 'D2D',
      'status': 'SUBMITTED',
      'handover_photo_urls': '[]',
      'updated_at': '2026-10-21T10:00:00.000Z',
      'sync_state': 'synced',
    });
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test(
    'reject stores separate reasons and remarks in row and outbox',
    () async {
      await repository.rejectCollection(
        'collection-1',
        'Weight Mismatch, Incorrect Material Category',
        remarks: 'Scale shows 200 kg but 410 kg was entered.',
      );

      final collection = (await database.query(
        DatabaseTables.collections,
        where: 'id = ?',
        whereArgs: ['collection-1'],
      )).single;
      expect(collection['status'], 'REJECTED');
      expect(
        collection['rejection_reason'],
        'Weight Mismatch, Incorrect Material Category',
      );
      expect(
        collection['rejection_remarks'],
        'Scale shows 200 kg but 410 kg was entered.',
      );
      expect(collection['verified_by_name'], 'Supervisor One');
      expect(collection['sync_state'], 'pending');

      final outbox = (await database.query(DatabaseTables.outbox)).single;
      expect(outbox['method'], 'POST');
      expect(outbox['path'], '/collections/collection-1/reject');
      expect(jsonDecode(outbox['body']! as String), {
        'reason': 'Weight Mismatch, Incorrect Material Category',
        'remarks': 'Scale shows 200 kg but 410 kg was entered.',
      });
    },
  );

  test('empty remarks are omitted from the rejection body', () async {
    await repository.rejectCollection(
      'collection-1',
      'Weight Mismatch',
      remarks: '   ',
    );

    final collection = (await database.query(
      DatabaseTables.collections,
      where: 'id = ?',
      whereArgs: ['collection-1'],
    )).single;
    expect(collection['rejection_remarks'], isNull);
    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(jsonDecode(outbox['body']! as String), {
      'reason': 'Weight Mismatch',
    });
  });

  test('sync stores review remarks returned by the server', () async {
    await repository.rejectCollection(
      'collection-1',
      'Weight Mismatch',
      remarks: 'Scale was not calibrated.',
    );
    late http.Request sent;
    final service = OutgoingSyncService(
      database: database,
      internetAccessChecker: () async => true,
      client: MockClient((request) async {
        sent = request;
        return http.Response(
          jsonEncode({
            'data': {
              'id': 'collection-1',
              'status': 'REJECTED',
              'updatedAt': '2026-10-21T11:00:00.000Z',
              'review': {
                'reason': 'Weight Mismatch',
                'remarks': 'Scale was not calibrated.',
                'at': '2026-10-21T11:00:00.000Z',
                'by': {'name': 'Supervisor One'},
              },
            },
          }),
          200,
        );
      }),
    );

    await service.drain();

    expect(sent.url.path, '/api/v1/mobile/collections/collection-1/reject');
    expect(jsonDecode(sent.body), {
      'reason': 'Weight Mismatch',
      'remarks': 'Scale was not calibrated.',
    });
    final collection = (await database.query(
      DatabaseTables.collections,
      where: 'id = ?',
      whereArgs: ['collection-1'],
    )).single;
    expect(collection['rejection_remarks'], 'Scale was not calibrated.');
    expect(collection['sync_state'], 'synced');
  });
}
