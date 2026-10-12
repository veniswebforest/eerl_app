import 'dart:convert';
import 'dart:io';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
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
    databasePath = p.join(await getDatabasesPath(), 'task_complete_test.db');
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.accessTokenKey: 'task-token',
    });
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await database.insert(DatabaseTables.tasks, _pendingTask.toMap());
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test(
    'stores completion then posts exact note and uploaded photoUrls',
    () async {
      final proof = File(p.join(await getDatabasesPath(), 'task-proof.jpg'));
      await proof.writeAsBytes(const [1, 2, 3, 4]);
      addTearDown(() async {
        if (await proof.exists()) await proof.delete();
      });

      await repository.completeTask(
        taskId: _pendingTask.id,
        note: 'All four IDs checked.',
        photoPaths: [proof.path],
      );

      var task = (await database.query(DatabaseTables.tasks)).single;
      expect(task['status'], 'COMPLETED');
      expect(task['note'], 'All four IDs checked.');
      expect(task['completed_at'], isNotNull);
      expect(jsonDecode(task['photo_urls']! as String), [proof.path]);
      expect(task['sync_state'], 'pending');

      final photo = (await database.query(DatabaseTables.photos)).single;
      expect(photo['owner_table'], DatabaseTables.tasks);
      expect(photo['owner_id'], _pendingTask.id);
      expect(photo['field'], 'completion');
      expect(photo['purpose'], 'TASK');

      final outbox = (await database.query(DatabaseTables.outbox)).single;
      expect(outbox['method'], 'POST');
      expect(outbox['path'], '/tasks/${_pendingTask.id}/complete');
      expect(outbox['kind'], 'complete');
      expect(jsonDecode(outbox['body']! as String), {
        'note': 'All four IDs checked.',
        'photoUrls': [photo['id']],
      });
      expect(await database.query(DatabaseTables.outboxPhotos), hasLength(1));

      const remoteUrl = 'https://example.test/task-proof.jpg';
      await database.update(
        DatabaseTables.photos,
        {'status': 'uploaded', 'remote_url': remoteUrl},
        where: 'id = ?',
        whereArgs: [photo['id']],
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
                'id': _pendingTask.id,
                'status': 'COMPLETED',
                'note': 'All four IDs checked.',
                'completedAt': '2026-10-12T09:30:00.000Z',
                'photoUrls': [remoteUrl],
              },
            }),
            200,
          );
        }),
      );

      await service.drain();

      expect(sent.method, 'POST');
      expect(sent.url.path, '/api/v1/mobile/tasks/${_pendingTask.id}/complete');
      expect(sent.headers['authorization'], 'Bearer task-token');
      expect(jsonDecode(sent.body), {
        'note': 'All four IDs checked.',
        'photoUrls': [remoteUrl],
      });
      expect(await database.query(DatabaseTables.outbox), isEmpty);

      task = (await database.query(DatabaseTables.tasks)).single;
      expect(task['sync_state'], 'synced');
      expect(jsonDecode(task['photo_urls']! as String), [remoteUrl]);
    },
  );
}

const _pendingTask = TaskModel(
  id: '9f1b2c3d-4e5f-6071-8293-a4b5c6d7e8f9',
  number: 'TSK-001',
  centerId: 'center-1',
  assignedTo: 'agent-1',
  assignedToName: 'Agent One',
  assignedBy: 'supervisor-1',
  assignedByName: 'Supervisor One',
  title: 'Verify IDs',
  description: 'Verify all four IDs.',
  priority: 'HIGH',
  status: 'PENDING',
  dueAt: '2026-10-12T10:00:00.000Z',
  completedAt: null,
  photoUrls: [],
  createdAt: '2026-10-12T08:00:00.000Z',
  syncState: 'synced',
);
