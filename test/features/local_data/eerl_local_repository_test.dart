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
    await database.setSyncMeta('active_center_id', 'center-1');
    await database.setSyncMeta('user_id', 'user-1');
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('material configuration updates rows and queues one mutation', () async {
    await database.insert(DatabaseTables.items, _item());
    await database.insert(DatabaseTables.centerItems, {
      'center_id': 'center-1',
      'channel': 'D2D',
      'item_id': 'item-1',
      'is_selected': 0,
      'sort_order': 9,
      'rate': 18.5,
    });
    final item = (await repository.getItems(channel: 'D2D')).single;

    await repository.saveItemConfiguration(
      channel: 'D2D',
      items: [
        ItemModel(
          id: item.id,
          name: item.name,
          categoryName: item.categoryName,
          materialType: item.materialType,
          unitCode: item.unitCode,
          unitName: item.unitName,
          rate: item.rate,
          isSelected: true,
        ),
      ],
    );

    final row = (await database.query(DatabaseTables.centerItems)).single;
    expect(row['is_selected'], 1);
    expect(row['sort_order'], 0);
    expect(row['sync_state'], 'pending');
    expect(await database.query(DatabaseTables.outbox), hasLength(1));
  });

  test('collection write is atomic and links local photos to outbox', () async {
    final now = DateTime.utc(2026, 10, 2).toIso8601String();
    const id = 'local-collection-1';
    await repository.saveCollection(
      collection: CollectionModel(
        id: id,
        centerId: 'center-1',
        agentId: 'user-1',
        agentName: 'Agent',
        channel: 'D2D',
        status: 'PENDING',
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
          photoUrls: ['/tmp/photo.jpg'],
          sortOrder: 0,
        ),
      ],
      submit: true,
    );

    expect(await database.query(DatabaseTables.collections), hasLength(1));
    expect(await database.query(DatabaseTables.collectionItems), hasLength(1));
    expect(await database.query(DatabaseTables.photos), hasLength(1));
    expect(await database.query(DatabaseTables.outbox), hasLength(1));
    expect(await database.query(DatabaseTables.outboxPhotos), hasLength(1));
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
