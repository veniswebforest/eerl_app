import 'dart:convert';

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
    databasePath = p.join(
      await getDatabasesPath(),
      'collection_submit_body_test.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.accessTokenKey: 'collection-token',
    });
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
      'code': 'CTR',
    });
    await database.insert(DatabaseTables.myCenters, {
      'center_id': 'center-1',
      'is_primary': 1,
      'agent_number': 7,
      'slip_last_count': 0,
    });
    await database.insert(DatabaseTables.centerChannels, {
      'center_id': 'center-1',
      'channel': 'D2D',
      'show_price': 1,
      'takes_payment': 0,
    });
    await database.insert(DatabaseTables.items, {
      'id': 'item-1',
      'name': 'PET Bottles',
      'category_name': 'Plastic',
      'material_type': 'PLASTIC',
      'unit_code': 'KG',
      'unit_name': 'Kilogram',
    });
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test(
    'keeps every collection submit key when optional values are null',
    () async {
      const collectionId = 'collection-1';
      await repository.saveCollection(
        collection: CollectionModel(
          id: collectionId,
          centerId: 'center-1',
          agentId: 'agent-1',
          agentName: 'Agent One',
          channel: 'D2D',
          status: 'DRAFT',
          handoverPhotoUrls: const [],
          gpsLat: 21.1702,
          gpsLng: 72.8311,
          updatedAt: '2026-10-09T00:00:00.000Z',
          syncState: 'pending',
        ),
        items: const [
          CollectionItemModel(
            id: 'line-1',
            collectionId: collectionId,
            itemId: 'item-1',
            qty: 10,
            verifiedQty: 10,
            photoUrls: [],
            sortOrder: 0,
          ),
        ],
        submit: true,
      );

      final outbox = (await database.query(DatabaseTables.outbox)).single;
      final body =
          jsonDecode(outbox['body']! as String) as Map<String, dynamic>;
      expect(
        body.keys,
        unorderedEquals(<String>[
          'centerId',
          'type',
          'vehicleId',
          'givenByName',
          'mrfLabourId',
          'ragpickerId',
          'handoverPhotoUrls',
          'paidBy',
          'lines',
          'gps',
        ]),
      );
      expect(outbox['method'], 'PUT');
      expect(outbox['path'], '/collections/collection-1');
      expect(body['vehicleId'], isNull);
      expect(body['givenByName'], isNull);
      expect(body['mrfLabourId'], isNull);
      expect(body['ragpickerId'], isNull);
      expect(body['paidBy'], isNull);

      final line = (body['lines'] as List).single as Map<String, dynamic>;
      expect(
        line.keys,
        containsAll(<String>[
          'itemId',
          'collectedQty',
          'verifiedQty',
          'rate',
          'amount',
          'photoUrls',
        ]),
      );
      expect(line['rate'], isNull);
      expect(line['amount'], isNull);
    },
  );

  test('sync keeps queued API keys separate from SQLite columns', () async {
    const collectionId = 'collection-api-keys';
    await repository.saveCollection(
      collection: CollectionModel(
        id: collectionId,
        centerId: 'center-1',
        agentId: 'agent-1',
        agentName: 'Agent One',
        channel: 'D2D',
        status: 'DRAFT',
        handoverPhotoUrls: const [],
        gpsLat: 21.1702,
        gpsLng: 72.8311,
        updatedAt: '2026-10-16T00:00:00.000Z',
        syncState: 'pending',
      ),
      items: const [
        CollectionItemModel(
          id: 'line-api-keys',
          collectionId: collectionId,
          itemId: 'item-1',
          qty: 10,
          verifiedQty: 10,
          photoUrls: [],
          sortOrder: 0,
        ),
      ],
      submit: true,
    );

    final outbox = (await database.query(DatabaseTables.outbox)).single;
    final exactApiBody = Map<String, dynamic>.from(
      jsonDecode(outbox['body']! as String) as Map,
    )..['curlOnlyParameter'] = 'keep-this-key';
    await database.update(
      DatabaseTables.outbox,
      {'body': jsonEncode(exactApiBody)},
      where: 'seq = ?',
      whereArgs: [outbox['seq']],
    );

    late http.Request sent;
    final service = OutgoingSyncService(
      database: database,
      internetAccessChecker: () async => true,
      client: MockClient((request) async {
        sent = request;
        return http.Response('{}', 200);
      }),
    );

    await service.drain();

    expect(sent.method, 'PUT');
    expect(sent.url.path, '/api/v1/mobile/collections/$collectionId');
    expect(jsonDecode(sent.body), exactApiBody);
  });
}
