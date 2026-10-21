import 'dart:convert';
import 'dart:io';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
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
  final repository = EerlLocalRepository.instance;
  late String databasePath;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(await getDatabasesPath(), 'request_answer_test.db');
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
    await database.insert(DatabaseTables.myCenters, {
      'center_id': 'center-1',
      'is_primary': 1,
    });
    await database.insert(DatabaseTables.requests, {
      'id': 'request-1',
      'center_id': 'center-1',
      'created_by': 'agent-1',
      'created_by_name': 'Agent One',
      'body': 'Scale is flickering.',
      'priority': 'HIGH',
      'status': 'OPEN',
      'photo_urls': '[]',
      'created_at': '2026-10-20T08:00:00.000Z',
      'sync_state': 'synced',
    });
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('closes an open request and queues its answer', () async {
    await repository.answerRequest(
      requestId: 'request-1',
      notes: 'Recalibrated and verified.',
    );

    final request = (await database.query(DatabaseTables.requests)).single;
    expect(request['status'], 'CLOSED');
    expect(request['answer'], 'Recalibrated and verified.');
    expect(request['answered_at'], isNotNull);
    expect(request['sync_state'], 'pending');

    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(outbox['method'], 'POST');
    expect(outbox['path'], '/requests/request-1/answer');
    expect(outbox['kind'], 'answer');
    expect(jsonDecode(outbox['body']! as String), {
      'notes': 'Recalibrated and verified.',
      'photoUrls': <Object?>[],
    });
  });

  test('uploads supervisor proof separately and syncs answer URLs', () async {
    final proof = File(p.join(await getDatabasesPath(), 'answer-proof.jpg'));
    await proof.writeAsBytes(const [1, 2, 3, 4]);
    addTearDown(() async {
      if (await proof.exists()) await proof.delete();
    });
    final photoId = await repository.stageRequestAnswerPhoto(
      requestId: 'request-1',
      path: proof.path,
    );
    final staged = (await database.query(DatabaseTables.photos)).single;
    expect(staged['field'], 'answer');
    expect(staged['purpose'], 'REQUEST');

    await repository.answerRequest(
      requestId: 'request-1',
      notes: 'Recalibrated and verified.',
    );
    final queued = (await database.query(DatabaseTables.outbox)).single;
    expect(jsonDecode(queued['body']! as String), {
      'notes': 'Recalibrated and verified.',
      'photoUrls': [photoId],
    });
    expect(await database.query(DatabaseTables.outboxPhotos), hasLength(1));

    const remoteUrl = 'https://example.test/answer-proof.jpg';
    http.Request? answerRequest;
    final service = OutgoingSyncService(
      database: database,
      internetAccessChecker: () async => true,
      client: MockClient((request) async {
        if (request.url.path.endsWith('/uploads/batch')) {
          return http.Response(
            jsonEncode({
              'data': {
                'items': [
                  {
                    'uploadUrl': 'https://upload.example.test/proof.jpg',
                    'fileUrl': remoteUrl,
                  },
                ],
              },
            }),
            200,
          );
        }
        if (request.url.host == 'upload.example.test') {
          return http.Response('', 200);
        }
        answerRequest = request;
        return http.Response(
          jsonEncode({
            'data': {
              'id': 'request-1',
              'status': 'CLOSED',
              'answer': {
                'notes': 'Recalibrated and verified.',
                'at': '2026-10-21T10:00:00.000Z',
                'photoUrls': [remoteUrl],
              },
            },
          }),
          200,
        );
      }),
    );

    await service.drain();

    expect(answerRequest!.method, 'POST');
    expect(answerRequest!.url.path, '/api/v1/mobile/requests/request-1/answer');
    expect(jsonDecode(answerRequest!.body), {
      'notes': 'Recalibrated and verified.',
      'photoUrls': [remoteUrl],
    });
    final stored = (await database.query(DatabaseTables.requests)).single;
    expect(jsonDecode(stored['photo_urls']! as String), isEmpty);
    expect(jsonDecode(stored['answer_photo_urls']! as String), [remoteUrl]);
    expect(await repository.getRequestAnswerPhotoSources('request-1'), [
      proof.path,
    ]);
  });

  test('removing a staged proof deletes only its local answer photo', () async {
    final photoId = await repository.stageRequestAnswerPhoto(
      requestId: 'request-1',
      path: '/tmp/proof.jpg',
    );

    await repository.removeRequestAnswerPhoto(
      requestId: 'request-1',
      photoId: photoId,
    );

    expect(await database.query(DatabaseTables.photos), isEmpty);
  });

  test('resolves original request attachments from the photos table', () async {
    await database.insert(DatabaseTables.photos, {
      'id': 'request-photo-1',
      'owner_table': DatabaseTables.requests,
      'owner_id': 'request-1',
      'field': 'request',
      'purpose': 'REQUEST',
      'content_type': 'image/jpeg',
      'local_path': '/tmp/original-request-photo.jpg',
      'status': 'local',
      'created_at': '2026-10-20T08:00:00.000Z',
    });
    await database.update(
      DatabaseTables.requests,
      {
        'photo_urls': jsonEncode(['request-photo-1']),
      },
      where: 'id = ?',
      whereArgs: ['request-1'],
    );

    expect(await repository.getRequestPhotoSources('request-1'), [
      '/tmp/original-request-photo.jpg',
    ]);
  });

  test('422 invalid photo URL re-uploads proof once and resends', () async {
    final proof = File(p.join(await getDatabasesPath(), 'retry-proof.jpg'));
    await proof.writeAsBytes(const [5, 6, 7]);
    addTearDown(() async {
      if (await proof.exists()) await proof.delete();
    });
    await repository.stageRequestAnswerPhoto(
      requestId: 'request-1',
      path: proof.path,
    );
    await repository.answerRequest(
      requestId: 'request-1',
      notes: 'Proof uploaded again.',
    );
    var batchCalls = 0;
    var answerCalls = 0;
    final service = OutgoingSyncService(
      database: database,
      internetAccessChecker: () async => true,
      client: MockClient((request) async {
        if (request.url.path.endsWith('/uploads/batch')) {
          batchCalls++;
          return http.Response(
            jsonEncode({
              'data': {
                'items': [
                  {
                    'uploadUrl':
                        'https://upload.example.test/proof-$batchCalls.jpg',
                    'fileUrl': 'https://example.test/proof-$batchCalls.jpg',
                  },
                ],
              },
            }),
            200,
          );
        }
        if (request.url.host == 'upload.example.test') {
          return http.Response('', 200);
        }
        answerCalls++;
        if (answerCalls == 1) {
          return http.Response(
            jsonEncode({
              'error': {
                'code': 'INVALID_REQUEST',
                'details': [
                  {'field': 'photoUrls.0'},
                ],
              },
            }),
            422,
          );
        }
        return http.Response(
          jsonEncode({
            'data': {
              'status': 'CLOSED',
              'answer': {
                'notes': 'Proof uploaded again.',
                'at': '2026-10-21T10:00:00.000Z',
                'photoUrls': ['https://example.test/proof-2.jpg'],
              },
            },
          }),
          200,
        );
      }),
    );

    await service.drain();

    expect(batchCalls, 2);
    expect(answerCalls, 2);
    expect(await database.query(DatabaseTables.outbox), isEmpty);
    final photo = (await database.query(DatabaseTables.photos)).single;
    expect(photo['status'], 'uploaded');
    expect(photo['remote_url'], 'https://example.test/proof-2.jpg');
  });

  test('does not answer an already closed request', () async {
    await database.update(
      DatabaseTables.requests,
      {'status': 'CLOSED'},
      where: 'id = ?',
      whereArgs: ['request-1'],
    );

    await expectLater(
      repository.answerRequest(requestId: 'request-1', notes: 'Done.'),
      throwsStateError,
    );
    expect(await database.query(DatabaseTables.outbox), isEmpty);
  });
}
