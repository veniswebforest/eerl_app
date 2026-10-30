import 'dart:convert';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.instance;
  final repository = EerlLocalRepository.instance;
  late String databasePath;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(await getDatabasesPath(), 'task_assign_test.db');
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await database.insert(DatabaseTables.myCenters, {
      'center_id': 'center-1',
      'is_primary': 1,
    });
    await database.insert(DatabaseTables.centerPeople, {
      'user_id': 'agent-1',
      'center_id': 'center-1',
      'name': 'Agent One',
      'phone': '9000000001',
      'is_agent': 1,
    });
    await database.setSyncMeta('user_id', 'supervisor-1');
    await database.setSyncMeta('user_name', 'Supervisor One');
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test(
    'stores a pending task and queues the exact assignment request',
    () async {
      final dueDate = DateTime.now().toUtc().add(const Duration(days: 1));

      final taskId = await repository.assignTask(
        centerId: 'center-1',
        assignedToId: 'agent-1',
        title: 'Check ID cards',
        description: 'Bring copies to the office.',
        priority: 'high',
        dueDate: dueDate,
        photoPaths: const ['/tmp/reference.jpg'],
      );

      final task = (await database.query(DatabaseTables.tasks)).single;
      expect(task['id'], taskId);
      expect(task['center_id'], 'center-1');
      expect(task['assigned_to'], 'agent-1');
      expect(task['assigned_to_name'], 'Agent One');
      expect(task['assigned_by'], 'supervisor-1');
      expect(task['assigned_by_name'], 'Supervisor One');
      expect(task['status'], 'PENDING');
      expect(task['priority'], 'HIGH');
      expect(task['due_at'], dueDate.toIso8601String());
      expect(jsonDecode(task['photo_urls']! as String), ['/tmp/reference.jpg']);
      expect(task['sync_state'], 'pending');

      final detail = await repository.getTask(taskId);
      expect(detail, isNotNull);
      expect(detail!.centerName, 'Center One');
      expect(detail.title, 'Check ID cards');
      expect(detail.assignedToName, 'Agent One');

      final outbox = (await database.query(DatabaseTables.outbox)).single;
      expect(outbox['method'], 'PUT');
      expect(outbox['path'], '/tasks/$taskId');
      expect(outbox['entity'], DatabaseTables.tasks);
      expect(outbox['entity_id'], taskId);
      expect(outbox['kind'], 'assign');
      expect(outbox['status'], 'queued');
      final photos = await database.query(
        DatabaseTables.photos,
        where: 'owner_table = ? AND owner_id = ? AND field = ?',
        whereArgs: [DatabaseTables.tasks, taskId, 'assignment'],
      );
      expect(photos, hasLength(1));
      expect(photos.single['local_path'], '/tmp/reference.jpg');
      expect(photos.single['purpose'], 'TASK_COMPLETION');
      final outboxPhotos = await database.query(
        DatabaseTables.outboxPhotos,
        where: 'outbox_seq = ?',
        whereArgs: [outbox['seq']],
      );
      expect(outboxPhotos, hasLength(1));
      expect(outboxPhotos.single['photo_id'], photos.single['id']);
      expect(jsonDecode(outbox['body']! as String), {
        'assignedToId': 'agent-1',
        'centerId': 'center-1',
        'title': 'Check ID cards',
        'description': 'Bring copies to the office.',
        'priority': 'HIGH',
        'dueDate': dueDate.toIso8601String(),
        'photoUrls': [photos.single['id']],
      });
    },
  );

  test('rejects past dates without creating task or outbox rows', () async {
    await expectLater(
      repository.assignTask(
        centerId: 'center-1',
        assignedToId: 'agent-1',
        title: 'Check ID cards',
        description: 'Bring copies to the office.',
        priority: 'HIGH',
        dueDate: DateTime.now().subtract(const Duration(minutes: 1)),
        photoPaths: const ['/tmp/reference.jpg'],
      ),
      throwsArgumentError,
    );

    expect(await database.query(DatabaseTables.tasks), isEmpty);
    expect(await database.query(DatabaseTables.outbox), isEmpty);
  });

  test(
    'rejects an agent that does not belong to the selected center',
    () async {
      await expectLater(
        repository.assignTask(
          centerId: 'center-1',
          assignedToId: 'agent-missing',
          title: 'Check ID cards',
          description: 'Bring copies to the office.',
          priority: 'HIGH',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          photoPaths: const ['/tmp/reference.jpg'],
        ),
        throwsStateError,
      );

      expect(await database.query(DatabaseTables.tasks), isEmpty);
      expect(await database.query(DatabaseTables.outbox), isEmpty);
    },
  );

  test('cancels a pending task and queues the cancel endpoint', () async {
    final taskId = await repository.assignTask(
      centerId: 'center-1',
      assignedToId: 'agent-1',
      title: 'Check ID cards',
      description: 'Bring copies to the office.',
      priority: 'HIGH',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      photoPaths: const ['/tmp/reference.jpg'],
    );
    await database.delete(DatabaseTables.outbox);

    await repository.cancelTask(taskId);

    final task = (await database.query(DatabaseTables.tasks)).single;
    expect(task['status'], 'CANCELLED');
    expect(task['sync_state'], 'pending');
    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(outbox['method'], 'POST');
    expect(outbox['path'], '/tasks/$taskId/cancel');
    expect(outbox['body'], isNull);
    expect(outbox['kind'], 'cancel');
  });
}
