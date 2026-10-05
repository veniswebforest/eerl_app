import 'dart:convert';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/core/local_database/outbox_queue.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
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
      'eerl_outgoing_sync_test.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.accessTokenKey: 'test-access-token',
    });
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await database.insert(DatabaseTables.expenseCategories, {
      'id': 'category-1',
      'center_id': 'center-1',
      'name': 'General',
      'is_active': 1,
    });
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('sends a queued write with bearer auth and removes it on 2xx', () async {
    await database.insert(DatabaseTables.notifications, {
      'id': 'notification-1',
      'type': 'INFO',
      'title': 'Test',
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'sync_state': 'pending',
    });
    await database.insert(DatabaseTables.outbox, {
      'method': 'POST',
      'path': '/notifications/notification-1/read',
      'body': jsonEncode({'read': true}),
      'entity': DatabaseTables.notifications,
      'entity_id': 'notification-1',
      'kind': 'read',
      'status': 'queued',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    late http.Request sent;
    final service = OutgoingSyncService(
      database: database,
      client: MockClient((request) async {
        sent = request;
        return http.Response('{}', 204);
      }),
    );

    await service.drain();

    expect(
      sent.url.toString(),
      '${AppConstants.apiBaseUrl}/mobile/notifications/notification-1/read',
    );
    expect(sent.headers['authorization'], 'Bearer test-access-token');
    expect(await database.query(DatabaseTables.outbox), isEmpty);
    expect(
      (await database.query(DatabaseTables.notifications)).single['sync_state'],
      'synced',
    );
  });

  test('parks a permanent 4xx error and marks its record failed', () async {
    await database.insert(DatabaseTables.expenses, {
      'id': 'expense-1',
      'center_id': 'center-1',
      'user_id': 'user-1',
      'category_id': 'category-1',
      'amount': 10,
      'status': 'PENDING',
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'sync_state': 'pending',
    });
    await database.insert(DatabaseTables.outbox, {
      'method': 'PUT',
      'path': '/expenses/expense-1',
      'body': '{}',
      'entity': DatabaseTables.expenses,
      'entity_id': 'expense-1',
      'kind': 'create',
      'status': 'queued',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    final service = OutgoingSyncService(
      database: database,
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'error': {'code': 'OVER_BALANCE'},
          }),
          400,
        ),
      ),
    );

    await service.drain();

    expect(
      (await database.query(DatabaseTables.outbox)).single['status'],
      'failed',
    );
    expect(
      (await database.query(DatabaseTables.expenses)).single['sync_state'],
      'failed',
    );
  });

  test('sends a dynamic collection graph after resolving photo ids', () async {
    const collectionId = 'collection-outbox-1';
    await database.insert(DatabaseTables.collections, {
      'id': collectionId,
      'center_id': 'center-1',
      'agent_id': 'user-1',
      'agent_name': 'Agent',
      'channel': 'D2D',
      'status': 'SUBMITTED',
      'handover_photo_urls': '[]',
      'updated_at': '2026-10-05T10:00:00.000Z',
      'sync_state': 'pending',
    });
    await database.insert(DatabaseTables.photos, {
      'id': 'line-photo-1',
      'owner_table': DatabaseTables.collectionItems,
      'owner_id': 'line-1',
      'purpose': 'COLLECTION_LINE',
      'content_type': 'image/jpeg',
      'remote_url': 'https://files.example/line-photo-1.jpg',
      'status': 'uploaded',
      'created_at': '2026-10-05T10:00:00.000Z',
    });
    await database.runInTransaction((txn) async {
      await OutboxQueue.enqueue(
        txn,
        method: 'POST',
        path: '/collections/$collectionId/submit',
        entity: DatabaseTables.collections,
        entityId: collectionId,
        kind: 'submit',
        body: {
          'id': collectionId,
          'items': [
            {
              'id': 'line-1',
              'collection_id': collectionId,
              'photo_urls': ['line-photo-1'],
            },
          ],
        },
        refs: const ['line-photo-1'],
        blockingPhotoIds: const ['line-photo-1'],
      );
    });

    late Map<String, Object?> sentBody;
    final service = OutgoingSyncService(
      database: database,
      client: MockClient((request) async {
        sentBody = Map<String, Object?>.from(jsonDecode(request.body) as Map);
        return http.Response('{}', 204);
      }),
    );

    await service.drain();

    final sentItems = sentBody['items']! as List;
    expect(sentBody['id'], collectionId);
    expect((sentItems.single as Map)['collection_id'], collectionId);
    expect((sentItems.single as Map)['photo_urls'], [
      'https://files.example/line-photo-1.jpg',
    ]);
    expect(await database.query(DatabaseTables.outbox), isEmpty);
    expect(await database.query(DatabaseTables.outboxPhotos), isEmpty);
    expect(
      (await database.query(DatabaseTables.collections)).single['sync_state'],
      'synced',
    );
  });
}
