import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_data_source.dart';
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
    databasePath = p.join(
      await getDatabasesPath(),
      'transfer_dispatch_stock.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await database.insert(DatabaseTables.items, {
      'id': 'plastic',
      'name': 'Plastic',
      'category_name': 'Dry waste',
      'material_type': 'RECYCLABLE',
      'unit_code': 'KG',
      'unit_name': 'Kilogram',
      'is_active': 1,
    });
    await database.insert(DatabaseTables.stock, {
      'id': 'stock-1',
      'center_id': 'center-1',
      'item_id': 'plastic',
      'stage': 'RM',
      'qty': 25.0,
    });
    await _insertTransfer(database, id: 'transfer-1', requestedQty: 20);
    await database.insert(DatabaseTables.photos, {
      'id': 'vehicle-photo-1',
      'owner_table': DatabaseTables.transfers,
      'owner_id': 'transfer-1',
      'field': 'vehicle',
      'purpose': 'TRANSFER_HANDOVER',
      'content_type': 'image/jpeg',
      'local_path': '/tmp/vehicle.jpg',
      'status': 'local',
      'created_at': '2026-10-30T05:00:00.000Z',
    });
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test(
    'loaded weight may exceed requested quantity while stock covers it',
    () async {
      await repository.submitTransferDispatch(
        transferId: 'transfer-1',
        vehicleNumber: 'GJ05AB1234',
        driverName: 'Kiran Rathod',
        dispatchedWeight: 24,
      );

      final transfer = (await database.query(DatabaseTables.transfers)).single;
      expect(transfer['status'], 'DISPATCHED');
      expect(transfer['dispatched_weight'], 24.0);
      final item = (await database.query(DatabaseTables.transferItems)).single;
      expect(item['qty'], 20.0);
      expect(item['dispatched_qty'], 24.0);
      expect(await database.query(DatabaseTables.outbox), hasLength(1));
    },
  );

  test(
    'loaded weight above stock is rejected before local write or outbox',
    () async {
      await expectLater(
        repository.submitTransferDispatch(
          transferId: 'transfer-1',
          vehicleNumber: 'GJ05AB1234',
          driverName: 'Kiran Rathod',
          dispatchedWeight: 25.001,
        ),
        throwsA(
          isA<TransferDispatchStockExceededException>()
              .having((error) => error.itemName, 'item name', 'Plastic')
              .having((error) => error.availableQuantity, 'available', 25.0),
        ),
      );

      final transfer = (await database.query(DatabaseTables.transfers)).single;
      expect(transfer['status'], 'APPROVED');
      expect(transfer['dispatched_weight'], isNull);
      final item = (await database.query(DatabaseTables.transferItems)).single;
      expect(item['dispatched_qty'], isNull);
      expect(await database.query(DatabaseTables.outbox), isEmpty);
    },
  );

  test(
    'stock includes pending collections and excludes other pending dispatches',
    () async {
      await _insertPendingCollection(database, verifiedQty: 5);
      await _insertTransfer(
        database,
        id: 'transfer-2',
        requestedQty: 10,
        status: 'DISPATCHED',
        syncState: 'pending',
        dispatchedQty: 4,
      );

      final stock = await repository.getTransferDispatchStock('transfer-1');

      expect(stock, hasLength(1));
      expect(stock.single.quantityCanGo, 26.0);
    },
  );
}

Future<void> _insertTransfer(
  AppDatabase database, {
  required String id,
  required double requestedQty,
  String status = 'APPROVED',
  String syncState = 'synced',
  double? dispatchedQty,
}) async {
  await database.insert(DatabaseTables.transfers, {
    'id': id,
    'center_id': 'center-1',
    'type': 'STOCK_TRANSFER',
    'status': status,
    'requested_by': 'agent-1',
    'requested_by_name': 'Agent One',
    'requested_at': '2026-10-30T04:00:00.000Z',
    'sync_state': syncState,
  });
  await database.insert(DatabaseTables.transferItems, {
    'id': '$id-item',
    'transfer_id': id,
    'item_id': 'plastic',
    'qty': requestedQty,
    'dispatched_qty': dispatchedQty,
  });
}

Future<void> _insertPendingCollection(
  AppDatabase database, {
  required double verifiedQty,
}) async {
  await database.insert(DatabaseTables.collections, {
    'id': 'collection-1',
    'center_id': 'center-1',
    'agent_id': 'agent-1',
    'agent_name': 'Agent One',
    'channel': 'D2D',
    'status': 'SUBMITTED',
    'handover_photo_urls': '[]',
    'updated_at': '2026-10-30T04:30:00.000Z',
    'sync_state': 'pending',
  });
  await database.insert(DatabaseTables.collectionItems, {
    'id': 'collection-item-1',
    'collection_id': 'collection-1',
    'item_id': 'plastic',
    'qty': verifiedQty,
    'verified_qty': verifiedQty,
    'photo_urls': '[]',
    'sort_order': 0,
  });
}
