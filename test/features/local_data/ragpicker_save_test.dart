import 'dart:convert';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/core/local_database/mobile_write_validator.dart';
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
    databasePath = p.join(await getDatabasesPath(), 'ragpicker_save_test.db');
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.accessTokenKey: 'ragpicker-token',
    });
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await database.setSyncMeta('active_center_id', 'center-1');
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('stores ragpicker, camera photo and exact PUT body locally', () async {
    await _save(repository);

    final ragpicker = (await database.query(DatabaseTables.ragpickers)).single;
    expect(ragpicker['id'], 'ragpicker-1');
    expect(ragpicker['center_id'], 'center-1');
    expect(ragpicker['name'], 'Vikram Singh');
    expect(ragpicker['phone'], '9876543210');
    expect(ragpicker['id_number'], 'XXXX-XXXX-4531');
    expect(ragpicker['photo_url'], '/tmp/ragpicker-photo.jpg');
    expect(ragpicker['sync_state'], 'pending');

    final photo = (await database.query(DatabaseTables.photos)).single;
    expect(photo['owner_table'], DatabaseTables.ragpickers);
    expect(photo['owner_id'], 'ragpicker-1');
    expect(photo['field'], 'profile');
    expect(photo['purpose'], 'RAGPICKER');
    expect(photo['status'], 'local');

    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(outbox['method'], 'PUT');
    expect(outbox['path'], '/ragpickers/ragpicker-1');
    expect(outbox['entity'], DatabaseTables.ragpickers);
    expect(outbox['kind'], 'upsert');
    expect(jsonDecode(outbox['body']! as String), {
      'centerId': 'center-1',
      'name': 'Vikram Singh',
      'phone': '9876543210',
      'idNumber': 'XXXX-XXXX-4531',
      'photoUrl': photo['id'],
    });
    expect(await database.query(DatabaseTables.outboxPhotos), hasLength(1));
  });

  test('ragpicker center dropdown source contains only my_centers', () async {
    await database.insert(DatabaseTables.centers, {
      'id': 'center-2',
      'name': 'Other Center',
    });
    await database.insert(DatabaseTables.myCenters, {
      'center_id': 'center-1',
      'is_primary': 1,
      'slip_last_count': 0,
    });

    final centers = await repository.getMyCenters();

    expect(centers.map((center) => center.id), ['center-1']);
    expect(centers.single.name, 'Center One');
    expect(centers.single.isPrimary, isTrue);
  });

  test('requires a mobile number before writing a ragpicker', () async {
    await expectLater(
      repository.saveRagpicker(
        const RagpickerModel(
          id: 'ragpicker-no-phone',
          centerId: 'center-1',
          name: 'Ramesh Yadav',
          isActive: true,
          syncState: 'pending',
        ),
      ),
      throwsA(isA<LocalWriteValidationException>()),
    );

    expect(await database.query(DatabaseTables.ragpickers), isEmpty);
    expect(await database.query(DatabaseTables.outbox), isEmpty);
  });

  test('replaces photo UUID with URL and applies server response', () async {
    await _save(repository);
    final photo = (await database.query(DatabaseTables.photos)).single;
    const remoteUrl = 'https://uploads.example/ragpicker-1.jpg';
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
              'id': 'ragpicker-1',
              'number': 'RAG-001',
              'centerId': 'center-1',
              'name': 'Vikram Singh',
              'phone': '9876543210',
              'idNumber': 'XXXX-XXXX-4531',
              'photoUrl': remoteUrl,
              'isActive': true,
            },
          }),
          200,
        );
      }),
    );

    await service.drain();

    expect(sent.method, 'PUT');
    expect(sent.url.path, '/api/v1/mobile/ragpickers/ragpicker-1');
    expect(sent.headers['authorization'], 'Bearer ragpicker-token');
    expect(jsonDecode(sent.body), {
      'centerId': 'center-1',
      'name': 'Vikram Singh',
      'phone': '9876543210',
      'idNumber': 'XXXX-XXXX-4531',
      'photoUrl': remoteUrl,
    });
    expect(await database.query(DatabaseTables.outbox), isEmpty);
    final stored = (await database.query(DatabaseTables.ragpickers)).single;
    expect(stored['number'], 'RAG-001');
    expect(stored['photo_url'], remoteUrl);
    expect(stored['sync_state'], 'synced');
  });

  test('editing an already local ragpicker still queues PUT', () async {
    await _save(repository);
    await repository.saveRagpicker(
      const RagpickerModel(
        id: 'ragpicker-1',
        centerId: 'center-1',
        name: 'Vikram Singh Updated',
        phone: '9876543210',
        idNumber: 'XXXX-XXXX-4531',
        isActive: true,
        syncState: 'pending',
      ),
    );

    final outboxRows = await database.query(DatabaseTables.outbox);
    expect(outboxRows, hasLength(1));
    expect(outboxRows.single['method'], 'PUT');
    expect(outboxRows.single['path'], '/ragpickers/ragpicker-1');
    expect(jsonDecode(outboxRows.single['body']! as String), {
      'centerId': 'center-1',
      'name': 'Vikram Singh Updated',
      'phone': '9876543210',
      'idNumber': 'XXXX-XXXX-4531',
      'photoUrl': null,
    });
  });

  test('posts ragpicker status with the API isActive parameter', () async {
    const ragpicker = RagpickerModel(
      id: 'ragpicker-1',
      centerId: 'center-1',
      name: 'Vikram Singh',
      isActive: true,
      syncState: 'synced',
    );
    await database.insert(DatabaseTables.ragpickers, ragpicker.toMap());

    await repository.setRagpickerActive(ragpicker, false);

    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(outbox['method'], 'POST');
    expect(outbox['path'], '/ragpickers/ragpicker-1/status');
    expect(jsonDecode(outbox['body']! as String), {'isActive': false});

    late http.Request sent;
    final service = OutgoingSyncService(
      database: database,
      internetAccessChecker: () async => true,
      client: MockClient((request) async {
        sent = request;
        return http.Response('', 200);
      }),
    );

    await service.drain();

    expect(sent.method, 'POST');
    expect(sent.url.path, '/api/v1/mobile/ragpickers/ragpicker-1/status');
    expect(jsonDecode(sent.body), {'isActive': false});
  });

  test('stores ragpicker with 2 photos and retrieves both photo sources', () async {
    await repository.saveRagpicker(
      const RagpickerModel(
        id: 'ragpicker-2',
        centerId: 'center-1',
        name: 'Asha Ben',
        phone: '9898989898',
        isActive: true,
        syncState: 'pending',
      ),
      localPhotoPaths: ['/tmp/ragpicker-photo-1.jpg', '/tmp/ragpicker-photo-2.jpg'],
    );

    final ragpicker = (await database.query(
      DatabaseTables.ragpickers,
      where: 'id = ?',
      whereArgs: ['ragpicker-2'],
    )).single;
    expect(
      ragpicker['photo_url'],
      jsonEncode(['/tmp/ragpicker-photo-1.jpg', '/tmp/ragpicker-photo-2.jpg']),
    );

    final photos = await database.query(
      DatabaseTables.photos,
      where: 'owner_id = ?',
      whereArgs: ['ragpicker-2'],
      orderBy: 'created_at ASC',
    );
    expect(photos, hasLength(2));
    expect(photos[0]['local_path'], '/tmp/ragpicker-photo-1.jpg');
    expect(photos[1]['local_path'], '/tmp/ragpicker-photo-2.jpg');
    expect(photos[0]['purpose'], 'RAGPICKER');
    expect(photos[1]['purpose'], 'RAGPICKER');

    final sources = await repository.getRagpickerPhotoSources('ragpicker-2');
    expect(sources, ['/tmp/ragpicker-photo-1.jpg', '/tmp/ragpicker-photo-2.jpg']);
  });
}

Future<void> _save(EerlLocalRepository repository) => repository.saveRagpicker(
  const RagpickerModel(
    id: 'ragpicker-1',
    centerId: 'center-1',
    name: 'Vikram Singh',
    phone: '9876543210',
    idNumber: 'XXXX-XXXX-4531',
    isActive: true,
    syncState: 'pending',
  ),
  localPhotoPath: '/tmp/ragpicker-photo.jpg',
);
