import 'dart:convert';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_data_source.dart';
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
    for (final channel in const ['D2D', 'MRF', 'RAMP']) {
      await database.insert(DatabaseTables.centerChannels, {
        'center_id': 'center-1',
        'channel': channel,
        'show_price': 1,
        'takes_payment': channel == 'MRF' ? 0 : 1,
      });
    }
    await database.insert(DatabaseTables.items, {
      'id': 'item-1',
      'name': 'PET Bottles',
      'category_name': 'Plastic',
      'material_type': 'PLASTIC',
      'unit_code': 'KG',
      'unit_name': 'Kilogram',
    });
    await database.insert(DatabaseTables.vehicles, {
      'id': 'vehicle-1',
      'center_id': 'center-1',
      'plate_number': 'GJ-05-BX-1234',
      'driver_name': 'Kiran Rathod',
      'is_active': 1,
      'sync_state': 'synced',
    });
    await database.insert(DatabaseTables.mrfPeople, {
      'id': 'supervisor-1',
      'center_id': 'center-1',
      'name': 'MRF Supervisor',
      'is_active': 1,
      'role': 'SUPERVISOR',
      'sync_state': 'synced',
    });
    await database.insert(DatabaseTables.mrfPeople, {
      'id': 'labour-1',
      'center_id': 'center-1',
      'name': 'MRF Labour',
      'is_active': 1,
      'role': 'LABOUR',
      'sync_state': 'synced',
    });
    await database.insert(DatabaseTables.ragpickers, {
      'id': 'ragpicker-1',
      'center_id': 'center-1',
      'name': 'Ramp Ragpicker',
      'is_active': 1,
      'sync_state': 'synced',
    });
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  CollectionItemModel line(String collectionId) => CollectionItemModel(
    id: 'line-$collectionId',
    collectionId: collectionId,
    itemId: 'item-1',
    qty: 10,
    verifiedQty: 9.5,
    rate: 4,
    amount: 38,
    photoUrls: const ['/tmp/item.jpg'],
    sortOrder: 0,
  );

  Future<Map<String, dynamic>> queuedBody(String collectionId) async {
    final outbox = (await database.query(
      DatabaseTables.outbox,
      where: 'entity_id = ?',
      whereArgs: [collectionId],
    )).single;
    expect(outbox['method'], 'POST');
    expect(outbox['path'], '/collections/$collectionId/submit');
    return jsonDecode(outbox['body']! as String) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> queuedDraftBody(String collectionId) async {
    final outbox = (await database.query(
      DatabaseTables.outbox,
      where: 'entity_id = ?',
      whereArgs: [collectionId],
    )).single;
    expect(outbox['method'], 'PUT');
    expect(outbox['path'], '/collections/$collectionId');
    expect(outbox['kind'], 'draft_save');
    return jsonDecode(outbox['body']! as String) as Map<String, dynamic>;
  }

  test('D2D saves locally then queues the complete submit contract', () async {
    const id = 'collection-d2d';
    await repository.saveCollection(
      collection: const CollectionModel(
        id: id,
        centerId: 'center-1',
        agentId: 'agent-1',
        agentName: 'Agent One',
        channel: 'D2D',
        status: 'SUBMITTED',
        collectedAt: '2026-09-30T03:35:00.000Z',
        vehicleId: 'vehicle-1',
        givenByName: 'Kiran Rathod',
        paidBy: 'CASH',
        handoverPhotoUrls: ['/tmp/handover.jpg'],
        gpsLat: 21.1702,
        gpsLng: 72.8311,
        updatedAt: '2026-09-30T03:35:00.000Z',
        syncState: 'pending',
      ),
      items: [line(id)],
      submit: true,
    );

    final row = (await database.query(
      DatabaseTables.collections,
      where: 'id = ?',
      whereArgs: [id],
    )).single;
    expect(row['vehicle_id'], 'vehicle-1');
    expect(row['sync_state'], 'pending');

    final body = await queuedBody(id);
    expect(
      body.keys,
      unorderedEquals(const [
        'centerId',
        'type',
        'slipNumber',
        'collectedAt',
        'vehicleId',
        'givenByName',
        'handoverPhotoUrls',
        'paidBy',
        'lines',
        'gps',
      ]),
    );
    expect(body['type'], 'D2D');
    expect(body['vehicleId'], 'vehicle-1');
    expect(body['givenByName'], 'Kiran Rathod');
    expect(body['paidBy'], 'CASH');
    expect(body['slipNumber'], matches(RegExp(r'^CTR-[0-9]{6}-07-001$')));
    expect((body['handoverPhotoUrls'] as List), hasLength(1));
  });

  test('D2D draft queues and syncs the exact PUT contract', () async {
    const id = 'draft-d2d';
    await repository.saveCollection(
      collection: const CollectionModel(
        id: id,
        centerId: 'center-1',
        agentId: 'agent-1',
        agentName: 'Agent One',
        channel: 'D2D',
        status: 'DRAFT',
        vehicleId: 'vehicle-1',
        givenByName: 'Kiran Rathod',
        paidBy: 'CASH',
        handoverPhotoUrls: ['/tmp/draft-handover.jpg'],
        gpsLat: 21.1702,
        gpsLng: 72.8311,
        updatedAt: '2026-10-27T04:00:00.000Z',
        syncState: 'pending',
      ),
      items: [line(id)],
      submit: false,
    );

    final queued = await queuedDraftBody(id);
    expect(
      queued.keys,
      unorderedEquals(const [
        'centerId',
        'type',
        'vehicleId',
        'givenByName',
        'handoverPhotoUrls',
        'paidBy',
        'lines',
        'gps',
      ]),
    );
    expect(queued['type'], 'D2D');
    expect(queued['vehicleId'], 'vehicle-1');
    expect(queued['givenByName'], 'Kiran Rathod');
    expect(queued['paidBy'], 'CASH');
    expect(queued['gps'], {'lat': 21.1702, 'lng': 72.8311});
    expect(await database.query(DatabaseTables.outboxPhotos), hasLength(2));

    const handoverUrl = 'https://example.test/draft-handover.jpg';
    const itemUrl = 'https://example.test/draft-item.jpg';
    final photos = await database.query(DatabaseTables.photos);
    for (final photo in photos) {
      await database.update(
        DatabaseTables.photos,
        {
          'status': 'uploaded',
          'remote_url': photo['field'] == 'handover' ? handoverUrl : itemUrl,
        },
        where: 'id = ?',
        whereArgs: [photo['id']],
      );
    }

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
    expect(sent.url.path, '/api/v1/mobile/collections/$id');
    expect(jsonDecode(sent.body), {
      'centerId': 'center-1',
      'type': 'D2D',
      'vehicleId': 'vehicle-1',
      'givenByName': 'Kiran Rathod',
      'handoverPhotoUrls': [handoverUrl],
      'paidBy': 'CASH',
      'lines': [
        {
          'itemId': 'item-1',
          'collectedQty': 10.0,
          'verifiedQty': 9.5,
          'rate': 4.0,
          'amount': 38.0,
          'photoUrls': [itemUrl],
        },
      ],
      'gps': {'lat': 21.1702, 'lng': 72.8311},
    });
    expect(await database.query(DatabaseTables.outbox), isEmpty);
    final stored = (await database.query(
      DatabaseTables.collections,
      where: 'id = ?',
      whereArgs: const [id],
    )).single;
    expect(stored['status'], 'DRAFT');
    expect(stored['sync_state'], 'synced');
  });

  test('MRF draft queues the exact PUT contract', () async {
    const id = 'draft-mrf';
    await repository.saveCollection(
      collection: const CollectionModel(
        id: id,
        centerId: 'center-1',
        agentId: 'agent-1',
        agentName: 'Agent One',
        channel: 'MRF',
        status: 'DRAFT',
        mrfPersonId: 'labour-1',
        handoverPhotoUrls: [],
        gpsLat: 21.1702,
        gpsLng: 72.8311,
        updatedAt: '2026-10-27T04:00:00.000Z',
        syncState: 'pending',
      ),
      items: [line(id)],
      submit: false,
    );

    final body = await queuedDraftBody(id);
    expect(
      body.keys,
      unorderedEquals(const [
        'centerId',
        'type',
        'mrfLabourId',
        'lines',
        'gps',
      ]),
    );
    expect(body['mrfLabourId'], 'labour-1');
    expect(body['gps'], {'lat': 21.1702, 'lng': 72.8311});
    expect(await database.query(DatabaseTables.outboxPhotos), hasLength(1));
  });

  test('RAMP draft queues the exact PUT contract', () async {
    const id = 'draft-ramp';
    await repository.saveCollection(
      collection: const CollectionModel(
        id: id,
        centerId: 'center-1',
        agentId: 'agent-1',
        agentName: 'Agent One',
        channel: 'RAMP',
        status: 'DRAFT',
        ragpickerId: 'ragpicker-1',
        paidBy: 'UPI',
        handoverPhotoUrls: ['/tmp/ramp-draft-handover.jpg'],
        gpsLat: 21.1702,
        gpsLng: 72.8311,
        updatedAt: '2026-10-27T04:00:00.000Z',
        syncState: 'pending',
      ),
      items: [line(id)],
      submit: false,
    );

    final body = await queuedDraftBody(id);
    expect(
      body.keys,
      unorderedEquals(const [
        'centerId',
        'type',
        'ragpickerId',
        'handoverPhotoUrls',
        'paidBy',
        'lines',
        'gps',
      ]),
    );
    expect(body['ragpickerId'], 'ragpicker-1');
    expect(body['paidBy'], 'UPI');
    expect(body['gps'], {'lat': 21.1702, 'lng': 72.8311});
    expect(await database.query(DatabaseTables.outboxPhotos), hasLength(2));
  });

  test(
    'second submit of the same collection changes neither local data nor outbox',
    () async {
      const id = 'collection-no-duplicate';
      const collection = CollectionModel(
        id: id,
        centerId: 'center-1',
        agentId: 'agent-1',
        agentName: 'Agent One',
        channel: 'D2D',
        status: 'SUBMITTED',
        collectedAt: '2026-10-27T03:35:00.000Z',
        vehicleId: 'vehicle-1',
        givenByName: 'Kiran Rathod',
        paidBy: 'CASH',
        handoverPhotoUrls: ['/tmp/handover.jpg'],
        gpsLat: 21.1702,
        gpsLng: 72.8311,
        updatedAt: '2026-10-27T03:35:00.000Z',
        syncState: 'pending',
      );

      await repository.saveCollection(
        collection: collection,
        items: [line(id)],
        submit: true,
      );
      final collectionBefore = (await database.query(
        DatabaseTables.collections,
        where: 'id = ?',
        whereArgs: const [id],
      )).single;
      final outboxBefore = (await database.query(
        DatabaseTables.outbox,
        where: 'entity_id = ?',
        whereArgs: const [id],
      )).single;
      final photosBefore = await database.query(
        DatabaseTables.photos,
        orderBy: 'id',
      );

      await expectLater(
        repository.saveCollection(
          collection: collection,
          items: [line(id)],
          submit: true,
        ),
        throwsA(isA<CollectionAlreadySubmittedException>()),
      );
      await expectLater(
        repository.saveCollection(
          collection: collection,
          items: [line(id)],
          submit: false,
        ),
        throwsA(isA<CollectionAlreadySubmittedException>()),
      );

      expect(
        await database.query(
          DatabaseTables.collections,
          where: 'id = ?',
          whereArgs: const [id],
        ),
        [collectionBefore],
      );
      expect(
        await database.query(
          DatabaseTables.outbox,
          where: 'entity_id = ?',
          whereArgs: const [id],
        ),
        [outboxBefore],
      );
      expect(
        await database.query(DatabaseTables.photos, orderBy: 'id'),
        photosBefore,
      );
      final center = (await database.query(
        DatabaseTables.myCenters,
        where: 'center_id = ?',
        whereArgs: const ['center-1'],
      )).single;
      expect(center['slip_last_count'], 1);
    },
  );

  test('MRF queues labour id from mrf_people, not supervisor id', () async {
    const id = 'collection-mrf';
    await repository.saveCollection(
      collection: const CollectionModel(
        id: id,
        centerId: 'center-1',
        agentId: 'agent-1',
        agentName: 'Agent One',
        channel: 'MRF',
        status: 'SUBMITTED',
        collectedAt: '2026-09-29T10:50:00.000Z',
        mrfPersonId: 'labour-1',
        handoverPhotoUrls: [],
        gpsLat: 21.1702,
        gpsLng: 72.8311,
        updatedAt: '2026-09-29T10:50:00.000Z',
        syncState: 'pending',
      ),
      items: [line(id)],
      submit: true,
    );

    final body = await queuedBody(id);
    expect(
      body.keys,
      unorderedEquals(const [
        'centerId',
        'type',
        'slipNumber',
        'collectedAt',
        'mrfLabourId',
        'lines',
        'gps',
      ]),
    );
    expect(body['mrfLabourId'], 'labour-1');
    expect(body.containsKey('paidBy'), isFalse);
    expect(body.containsKey('handoverPhotoUrls'), isFalse);
  });

  test('invalid MRF person rolls back local row and outbox together', () async {
    const id = 'collection-invalid-mrf';
    await expectLater(
      repository.saveCollection(
        collection: const CollectionModel(
          id: id,
          centerId: 'center-1',
          agentId: 'agent-1',
          agentName: 'Agent One',
          channel: 'MRF',
          status: 'SUBMITTED',
          mrfPersonId: 'supervisor-1',
          handoverPhotoUrls: [],
          gpsLat: 21.1702,
          gpsLng: 72.8311,
          updatedAt: '2026-09-29T10:50:00.000Z',
          syncState: 'pending',
        ),
        items: [line(id)],
        submit: true,
      ),
      throwsA(isA<StateError>()),
    );
    expect(
      await database.query(
        DatabaseTables.collections,
        where: 'id = ?',
        whereArgs: [id],
      ),
      isEmpty,
    );
    expect(
      await database.query(
        DatabaseTables.outbox,
        where: 'entity_id = ?',
        whereArgs: [id],
      ),
      isEmpty,
    );
  });

  test('RAMP queues ragpicker id and handover/payment fields', () async {
    const id = 'collection-ramp';
    await repository.saveCollection(
      collection: const CollectionModel(
        id: id,
        centerId: 'center-1',
        agentId: 'agent-1',
        agentName: 'Agent One',
        channel: 'RAMP',
        status: 'SUBMITTED',
        collectedAt: '2026-09-30T05:00:00.000Z',
        ragpickerId: 'ragpicker-1',
        handedOverBy: 'Ramp Ragpicker',
        paidBy: 'CASH',
        handoverPhotoUrls: ['/tmp/ramp-handover.jpg'],
        gpsLat: 21.1702,
        gpsLng: 72.8311,
        updatedAt: '2026-09-30T05:00:00.000Z',
        syncState: 'pending',
      ),
      items: [line(id)],
      submit: true,
    );

    final body = await queuedBody(id);
    expect(
      body.keys,
      unorderedEquals(const [
        'centerId',
        'type',
        'slipNumber',
        'collectedAt',
        'ragpickerId',
        'handoverPhotoUrls',
        'paidBy',
        'lines',
        'gps',
      ]),
    );
    expect(body['ragpickerId'], 'ragpicker-1');
    expect(body['paidBy'], 'CASH');
    expect((body['handoverPhotoUrls'] as List), hasLength(1));
  });

  test('sync repairs a legacy collection submit method and path', () async {
    const id = 'legacy-submit';
    const body = {
      'centerId': 'center-1',
      'type': 'MRF',
      'gps': {'lat': 21.1702, 'lng': 72.8311},
    };
    await database.insert(DatabaseTables.outbox, {
      'method': 'PUT',
      'path': '/collections/$id',
      'body': jsonEncode(body),
      'entity': DatabaseTables.collections,
      'entity_id': id,
      'kind': 'submit',
      'refs': '[]',
      'status': 'queued',
      'attempts': 0,
      'created_at': '2026-10-26T00:00:00.000Z',
    });

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

    expect(sent.method, 'POST');
    expect(sent.url.path, '/api/v1/mobile/collections/$id/submit');
    expect(jsonDecode(sent.body), body);
  });
}
