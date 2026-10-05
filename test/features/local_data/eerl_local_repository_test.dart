import 'dart:convert';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
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
    databasePath = p.join(await getDatabasesPath(), 'eerl_local_repo_test.db');
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
      'code': 'CTR',
    });
    await database.setSyncMeta('active_center_id', 'center-1');
    await database.setSyncMeta('user_id', 'user-1');
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test(
    'material configuration loads items then inserts rows and queues mutation',
    () async {
      await database.insert(DatabaseTables.items, _item());
      await database.insert(DatabaseTables.centerChannels, {
        'center_id': 'center-1',
        'channel': 'D2D',
        'show_price': 1,
        'takes_payment': 1,
      });
      final item = (await repository.getItems(channel: 'D2D')).single;
      expect(item.id, 'item-1');
      expect(item.isSelected, isFalse);
      expect(item.sortOrder, isNull);

      await repository.saveItemConfiguration(
        channel: 'D2D',
        tab: 'PLASTIC',
        items: [
          ItemModel(
            id: item.id,
            name: item.name,
            categoryName: item.categoryName,
            materialType: item.materialType,
            unitCode: item.unitCode,
            unitName: item.unitName,
            rate: 18.5,
            isSelected: true,
          ),
        ],
      );

      final row = (await database.query(DatabaseTables.centerItems)).single;
      expect(row['is_selected'], 1);
      expect(row['sort_order'], 0);
      expect(row['rate'], 18.5);
      expect(row['sync_state'], 'pending');
      final configOutbox = (await database.query(DatabaseTables.outbox)).single;
      expect(configOutbox['status'], 'queued');
      expect(configOutbox['method'], 'PUT');
      expect(configOutbox['path'], '/item-config');
      expect(configOutbox['entity'], DatabaseTables.centerItems);
      expect(configOutbox['entity_id'], 'center-1:D2D:PLASTIC');
      expect(configOutbox['kind'], 'item_config');
      expect(jsonDecode(configOutbox['refs']! as String), [
        'center-1',
        'item-1',
      ]);
      final body = jsonDecode(configOutbox['body']! as String) as Map;
      expect(body['centerId'], 'center-1');
      expect(body['collectionChannel'], 'D2D');
      expect(body['tab'], 'PLASTIC');
      expect((body['items'] as List).single, {
        'itemId': 'item-1',
        'isSelected': true,
        'sortOrder': 0,
        'rate': 18.5,
      });

      // Re-saving the same tab updates its pending mutation instead of adding
      // another server request.
      await repository.saveItemConfiguration(
        channel: 'D2D',
        tab: 'PLASTIC',
        items: [
          ItemModel(
            id: item.id,
            name: item.name,
            categoryName: item.categoryName,
            materialType: item.materialType,
            unitCode: item.unitCode,
            unitName: item.unitName,
            rate: item.rate,
            isSelected: false,
          ),
        ],
      );

      final mergedOutbox = await database.query(DatabaseTables.outbox);
      expect(mergedOutbox, hasLength(1));
      final mergedBody =
          jsonDecode(mergedOutbox.single['body']! as String) as Map;
      expect((mergedBody['items'] as List).single['isSelected'], isFalse);
      expect(
        (await database.query(
          DatabaseTables.centerItems,
        )).single['is_selected'],
        0,
      );
    },
  );

  test(
    'material configuration rolls back when the source item is missing',
    () async {
      await database.insert(DatabaseTables.centerChannels, {
        'center_id': 'center-1',
        'channel': 'D2D',
        'show_price': 1,
        'takes_payment': 1,
      });
      final missing = ItemModel(
        id: 'item-1',
        name: 'Missing configuration',
        categoryName: 'Category',
        materialType: 'PLASTIC',
        unitCode: 'KG',
        unitName: 'Kilogram',
        isSelected: true,
      );

      await expectLater(
        repository.saveItemConfiguration(
          channel: 'D2D',
          tab: 'PLASTIC',
          items: [missing],
        ),
        throwsA(isA<StateError>()),
      );

      expect(await database.query(DatabaseTables.centerItems), isEmpty);
      expect(await database.query(DatabaseTables.outbox), isEmpty);
    },
  );

  test(
    'collection materials only include selected rows for the active center',
    () async {
      await database.insert(DatabaseTables.centers, {
        'id': 'center-2',
        'name': 'Center Two',
      });
      await database.insert(DatabaseTables.items, _item());
      await database.insert(DatabaseTables.items, _item2());
      for (final centerId in ['center-1', 'center-2']) {
        await database.insert(DatabaseTables.centerChannels, {
          'center_id': centerId,
          'channel': 'D2D',
          'show_price': 1,
          'takes_payment': 1,
        });
      }
      await database.insert(DatabaseTables.centerItems, {
        'center_id': 'center-1',
        'channel': 'D2D',
        'item_id': 'item-1',
        'is_selected': 1,
        'sort_order': 0,
        'rate': 10,
      });
      await database.insert(DatabaseTables.centerItems, {
        'center_id': 'center-1',
        'channel': 'D2D',
        'item_id': 'item-2',
        'is_selected': 0,
        'sort_order': 1,
        'rate': 20,
      });
      await database.insert(DatabaseTables.centerItems, {
        'center_id': 'center-2',
        'channel': 'D2D',
        'item_id': 'item-2',
        'is_selected': 1,
        'sort_order': 0,
        'rate': 25,
      });

      final materials = await repository.getCollectionMaterials(channel: 'D2D');

      expect(materials.map((item) => item.id), ['item-1']);
      expect(materials.single.rate, 10);
    },
  );

  test(
    'new D2D vehicle stores locally and queues one server mutation',
    () async {
      await database.insert(DatabaseTables.vehicleTypes, {
        'id': 'vehicle-type-1',
        'name': 'D2D Van',
      });
      const vehicleId = 'local_vehicle_1';
      VehicleModel vehicle(String plate) => VehicleModel(
        id: vehicleId,
        centerId: 'center-1',
        plateNumber: plate,
        typeId: 'vehicle-type-1',
        typeName: 'D2D Van',
        isActive: true,
        syncState: 'pending',
      );

      await repository.saveVehicle(vehicle('GJ-05-AA-1001'), isNew: true);

      final stored = (await database.query(DatabaseTables.vehicles)).single;
      expect(stored['id'], vehicleId);
      expect(stored['plate_number'], 'GJ-05-AA-1001');
      expect(stored['center_id'], 'center-1');
      expect(stored['type_id'], 'vehicle-type-1');
      expect(stored['is_active'], 1);
      expect(stored['sync_state'], 'pending');

      var outbox = await database.query(DatabaseTables.outbox);
      expect(outbox, hasLength(1));
      expect(outbox.single['method'], 'PUT');
      expect(outbox.single['path'], '/vehicles/$vehicleId');
      expect(outbox.single['entity'], DatabaseTables.vehicles);
      expect(outbox.single['entity_id'], vehicleId);
      expect(outbox.single['kind'], 'upsert');
      expect(outbox.single['status'], 'queued');
      expect(jsonDecode(outbox.single['refs']! as String), [
        'center-1',
        'vehicle-type-1',
      ]);
      final firstBody = jsonDecode(outbox.single['body']! as String) as Map;
      expect(firstBody['plate_number'], 'GJ-05-AA-1001');
      expect(firstBody.containsKey('sync_state'), isFalse);

      // Editing before the first upload updates the queued body instead of
      // creating a duplicate request. The original PUT method is preserved.
      await repository.saveVehicle(vehicle('GJ-05-AA-2002'), isNew: false);

      outbox = await database.query(DatabaseTables.outbox);
      expect(outbox, hasLength(1));
      expect(outbox.single['method'], 'PUT');
      final latestBody = jsonDecode(outbox.single['body']! as String) as Map;
      expect(latestBody['plate_number'], 'GJ-05-AA-2002');
      expect(
        (await database.query(DatabaseTables.vehicles)).single['plate_number'],
        'GJ-05-AA-2002',
      );
    },
  );

  test('editing a synced D2D vehicle queues PATCH', () async {
    await database.insert(DatabaseTables.vehicleTypes, {
      'id': 'vehicle-type-1',
      'name': 'D2D Van',
    });
    await database.insert(DatabaseTables.vehicles, {
      'id': 'server-vehicle-1',
      'center_id': 'center-1',
      'plate_number': 'GJ-05-AA-1001',
      'type_id': 'vehicle-type-1',
      'type_name': 'D2D Van',
      'is_active': 1,
      'sync_state': 'synced',
    });

    await repository.saveVehicle(
      const VehicleModel(
        id: 'server-vehicle-1',
        centerId: 'center-1',
        plateNumber: 'GJ-05-AA-2002',
        typeId: 'vehicle-type-1',
        typeName: 'D2D Van',
        isActive: true,
        syncState: 'pending',
      ),
      isNew: false,
    );

    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(outbox['method'], 'PATCH');
    expect(outbox['path'], '/vehicles/server-vehicle-1');
  });

  test('collection write is atomic and links local photos to outbox', () async {
    final now = DateTime.utc(2026, 10, 2).toIso8601String();
    const id = 'local-collection-1';
    await database.insert(DatabaseTables.myCenters, {
      'center_id': 'center-1',
      'is_primary': 1,
      'agent_number': 7,
      'slip_last_count': 0,
    });
    await database.insert(DatabaseTables.items, _item());
    await database.insert(DatabaseTables.items, _item2());
    await repository.saveCollection(
      collection: CollectionModel(
        id: id,
        centerId: 'center-1',
        agentId: 'user-1',
        agentName: 'Agent',
        channel: 'D2D',
        status: 'SUBMITTED',
        collectedAt: now,
        handoverPhotoUrls: const [],
        updatedAt: now,
        syncState: 'pending',
      ),
      items: const [
        CollectionItemModel(
          id: 'line-1',
          collectionId: id,
          itemId: 'item-1',
          qty: 5,
          verifiedQty: 4.5,
          rate: 10,
          amount: 45,
          photoUrls: ['/tmp/photo.jpg'],
          sortOrder: 0,
        ),
        CollectionItemModel(
          id: 'line-2',
          collectionId: id,
          itemId: 'item-2',
          qty: 3,
          verifiedQty: 2.5,
          rate: 8,
          amount: 20,
          photoUrls: [],
          sortOrder: 1,
        ),
      ],
      submit: true,
    );

    expect(await database.query(DatabaseTables.collections), hasLength(1));
    final collection = (await database.query(
      DatabaseTables.collections,
    )).single;
    final lines = await database.query(
      DatabaseTables.collectionItems,
      orderBy: 'sort_order',
    );
    expect(collection['status'], 'SUBMITTED');
    expect(collection['slip_number'], isNotNull);
    expect(collection['sync_state'], 'pending');
    expect(lines, hasLength(2));
    expect(lines.map((line) => line['collection_id']).toSet(), {id});
    expect(lines[0]['qty'], 5);
    expect(lines[0]['verified_qty'], 4.5);
    expect(lines[0]['amount'], 45);
    expect(lines[1]['qty'], 3);
    expect(lines[1]['verified_qty'], 2.5);
    expect(lines[1]['amount'], 20);

    final collectionItems = await repository.getCollectionItems(id);
    expect(collectionItems, hasLength(2));
    expect(collectionItems.map((item) => item.collectionId).toSet(), {id});
    expect(await database.query(DatabaseTables.photos), hasLength(1));
    final submitOutbox = (await database.query(DatabaseTables.outbox)).single;
    expect(submitOutbox['status'], 'queued');
    expect(submitOutbox['method'], 'POST');
    expect(submitOutbox['path'], '/collections/$id/submit');
    expect(submitOutbox['entity'], DatabaseTables.collections);
    expect(submitOutbox['entity_id'], id);
    expect(submitOutbox['kind'], 'submit');
    expect(submitOutbox['attempts'], 0);

    final body = jsonDecode(submitOutbox['body']! as String) as Map;
    final bodyItems = body['items']! as List;
    expect(body['id'], id);
    expect(bodyItems, hasLength(2));
    expect(bodyItems.map((item) => (item as Map)['collection_id']).toSet(), {
      id,
    });
    expect(jsonDecode(submitOutbox['refs']! as String), ['line-1_photo_0']);

    final outboxPhoto = (await database.query(
      DatabaseTables.outboxPhotos,
    )).single;
    expect(outboxPhoto['outbox_seq'], submitOutbox['seq']);
    expect(outboxPhoto['photo_id'], 'line-1_photo_0');
  });

  test('draft saves one SQL graph and merges its queued outbox row', () async {
    const id = 'draft-collection-1';
    final now = DateTime.utc(2026, 10, 5).toIso8601String();
    await database.insert(DatabaseTables.items, _item());
    await database.insert(DatabaseTables.ragpickers, {
      'id': 'ragpicker-1',
      'center_id': 'center-1',
      'name': 'Ragpicker One',
      'is_active': 1,
      'sync_state': 'synced',
    });
    CollectionModel collection() => CollectionModel(
      id: id,
      centerId: 'center-1',
      agentId: 'user-1',
      agentName: 'Agent One',
      channel: 'RAMP',
      status: 'DRAFT',
      ragpickerId: 'ragpicker-1',
      handedOverBy: 'Ragpicker One',
      totalAmount: 20,
      handoverPhotoUrls: const ['/tmp/handover.jpg'],
      updatedAt: now,
      syncState: 'pending',
    );
    List<CollectionItemModel> lines(double qty, {int photoCount = 1}) => [
      CollectionItemModel(
        id: '${id}_item-1',
        collectionId: id,
        itemId: 'item-1',
        qty: qty,
        verifiedQty: qty,
        rate: 10,
        amount: qty * 10,
        photoUrls: [
          for (var index = 0; index < photoCount; index++)
            '/tmp/line-$index.jpg',
        ],
        sortOrder: 0,
      ),
    ];

    await repository.saveCollection(
      collection: collection(),
      items: lines(2),
      submit: false,
    );
    await repository.saveCollection(
      collection: collection(),
      items: lines(3, photoCount: 2),
      submit: false,
    );

    final collections = await database.query(DatabaseTables.collections);
    final items = await database.query(DatabaseTables.collectionItems);
    final outbox = await database.query(DatabaseTables.outbox);
    expect(collections, hasLength(1));
    expect(collections.single['status'], 'DRAFT');
    expect(items, hasLength(1));
    expect(items.single['qty'], 3);
    expect(outbox, hasLength(1));
    expect(outbox.single['kind'], 'draft_save');
    expect(outbox.single['path'], '/collections/$id');
    expect(outbox.single['status'], 'queued');
    expect(jsonDecode(outbox.single['refs']! as String), [
      '${id}_handover_0',
      '${id}_item-1_photo_0',
      '${id}_item-1_photo_1',
    ]);
    final body = jsonDecode(outbox.single['body']! as String) as Map;
    expect(((body['items']! as List).single as Map)['qty'], 3.0);
    expect(await database.query(DatabaseTables.outboxPhotos), isEmpty);
  });
}

Map<String, Object?> _item() => const {
  'id': 'item-1',
  'name': 'PET',
  'category_name': 'Plastic',
  'material_type': 'PLASTIC',
  'unit_code': 'KG',
  'unit_name': 'Kilogram',
};

Map<String, Object?> _item2() => const {
  'id': 'item-2',
  'name': 'HDPE',
  'category_name': 'Plastic',
  'material_type': 'PLASTIC',
  'unit_code': 'KG',
  'unit_name': 'Kilogram',
};
