import 'dart:convert';
import 'dart:io';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/core/utils/ist_date_time.dart';
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
    databasePath = p.join(await getDatabasesPath(), 'request_raise_test.db');
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.accessTokenKey: 'request-token',
    });
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await database.setSyncMeta('active_center_id', 'center-1');
    await database.setSyncMeta('user_id', 'agent-1');
    await database.setSyncMeta('user_name', 'Agent One');
    await database.setSyncMeta('supervisor_name', 'Supervisor One');
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('stores follow-up in UTC and sends uploaded request photos', () async {
    final photoFile = File(p.join(await getDatabasesPath(), 'request.jpg'));
    await photoFile.writeAsBytes(const [1, 2, 3, 4]);
    addTearDown(() async {
      if (await photoFile.exists()) await photoFile.delete();
    });
    final followUpAt = DateTime.now().toUtc().add(const Duration(days: 1));

    final requestId = await repository.raiseRequest(
      body: 'Weight scale needs calibration.',
      priority: 'LOW',
      followUpAt: followUpAt,
      photoPaths: [photoFile.path],
    );

    var stored = (await database.query(DatabaseTables.requests)).single;
    expect(stored['id'], requestId);
    expect(stored['status'], 'OPEN');
    expect(stored['follow_up_at'], followUpAt.toIso8601String());
    expect(jsonDecode(stored['photo_urls']! as String), [photoFile.path]);
    expect(stored['sync_state'], 'pending');

    final listedRequest = (await repository.getRequests()).single;
    expect(listedRequest.supervisorName, 'Supervisor One');

    final photo = (await database.query(DatabaseTables.photos)).single;
    expect(photo['owner_table'], DatabaseTables.requests);
    expect(photo['owner_id'], requestId);
    expect(photo['purpose'], 'REQUEST');

    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(outbox['method'], 'PUT');
    expect(outbox['path'], '/requests/$requestId');
    expect(outbox['kind'], 'raise');
    expect(jsonDecode(outbox['body']! as String), {
      'centerId': 'center-1',
      'body': 'Weight scale needs calibration.',
      'priority': 'LOW',
      'followUpAt': followUpAt.toIso8601String(),
      'photoUrls': [photo['id']],
    });

    const remoteUrl = 'https://example.test/request.jpg';
    Map<String, dynamic>? sentBatchBody;
    http.Request? sentRequest;
    Object? persistedOutboxBodyAtSend;
    Object? persistedRequestPhotosAtSend;
    final service = OutgoingSyncService(
      database: database,
      internetAccessChecker: () async => true,
      client: MockClient((request) async {
        if (request.url.path.endsWith('/uploads/batch')) {
          sentBatchBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'data': {
                'items': [
                  {
                    'uploadUrl': 'https://upload.example.test/request.jpg',
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
        sentRequest = request;
        final queuedRow = (await database.query(DatabaseTables.outbox)).single;
        persistedOutboxBodyAtSend = jsonDecode(queuedRow['body']! as String);
        final localRequest = (await database.query(
          DatabaseTables.requests,
        )).single;
        persistedRequestPhotosAtSend = jsonDecode(
          localRequest['photo_urls']! as String,
        );
        return http.Response(
          jsonEncode({
            'data': {
              'id': requestId,
              'number': 'REQ-001',
              'centerId': 'center-1',
              'body': 'Weight scale needs calibration.',
              'priority': 'LOW',
              'status': 'OPEN',
              'followUpAt': followUpAt.toIso8601String(),
              'photoUrls': [remoteUrl],
              'createdAt': '2026-10-12T08:00:00.000Z',
            },
          }),
          200,
        );
      }),
    );

    await service.drain();

    expect(sentBatchBody, {
      'photos': [
        {'purpose': 'REQUEST', 'contentType': 'image/jpeg', 'sizeBytes': 4},
      ],
    });
    expect(sentRequest, isNotNull);
    expect(sentRequest!.method, 'PUT');
    expect(sentRequest!.url.path, '/api/v1/mobile/requests/$requestId');
    expect(jsonDecode(sentRequest!.body), {
      'centerId': 'center-1',
      'body': 'Weight scale needs calibration.',
      'priority': 'LOW',
      'followUpAt': followUpAt.toIso8601String(),
      'photoUrls': [remoteUrl],
    });
    expect(persistedOutboxBodyAtSend, jsonDecode(sentRequest!.body));
    expect(persistedRequestPhotosAtSend, [remoteUrl]);
    expect(await database.query(DatabaseTables.outbox), isEmpty);
    stored = (await database.query(DatabaseTables.requests)).single;
    expect(stored['number'], 'REQ-001');
    expect(stored['follow_up_at'], followUpAt.toIso8601String());
    expect(jsonDecode(stored['photo_urls']! as String), [remoteUrl]);
    expect(stored['sync_state'], 'synced');
  });

  test('converts the IST picker wall time to the required UTC instant', () {
    final ist = DateTime(2026, 8, 16, 15);
    expect(
      IstDateTime.toUtc(ist).toIso8601String(),
      '2026-08-16T09:30:00.000Z',
    );
  });
}
