import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/bootstrap/data/bootstrap_database_applier.dart';
import 'package:eerl_app/features/bootstrap/model/bootstrap_response.dart';
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
      'material_active_bootstrap_test.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('keeps inactive items but excludes them from both pickers', () async {
    final data = BootstrapData.fromJson({
      'cursor': 'materials-active-1',
      'hasMore': false,
      'full': true,
      'me': {
        'scopeKey': 'agent-1',
        'user': {'id': 'agent-1', 'name': 'Agent One'},
        'roles': const [],
        'centers': [
          {'id': 'center-1', 'isPrimary': true},
        ],
      },
      'tables': {
        'centers': {
          'replace': [
            {'id': 'center-1', 'name': 'Center One'},
          ],
        },
        'items': {
          'replace': [
            {
              'id': 'active-item',
              'name': 'PET Bottles',
              'category_name': 'Plastic',
              'material_type': 'PLASTIC',
              'unit_code': 'KG',
              'unit_name': 'Kilogram',
              'is_active': 1,
            },
            {
              'id': 'inactive-item',
              'name': 'Old Glass',
              'category_name': 'Glass',
              'material_type': 'NON_PLASTIC',
              'unit_code': 'KG',
              'unit_name': 'Kilogram',
              'is_active': 0,
            },
          ],
        },
        'center_channels': {
          'replace': [
            {
              'center_id': 'center-1',
              'channel': 'D2D',
              'show_price': 1,
              'takes_payment': 0,
            },
          ],
        },
        'center_items': {
          'replace': [
            {
              'center_id': 'center-1',
              'channel': 'D2D',
              'item_id': 'active-item',
              'is_selected': 1,
              'sort_order': 0,
              'rate': 10,
            },
          ],
        },
        'requests': {
          'upserts': [
            {
              'id': 'request-1',
              'center_id': 'center-1',
              'created_by': 'agent-1',
              'created_by_name': 'Agent One',
              'body': 'Check the weighing scale.',
              'priority': 'HIGH',
              'status': 'OPEN',
              'follow_up_at': '2000-01-01T09:30:00.000Z',
              'photo_urls': '[]',
              'created_at': '2000-01-01T08:00:00.000Z',
            },
          ],
        },
      },
    });

    await BootstrapDatabaseApplier(database: database).apply(data);

    final storedItems = await database.query(
      DatabaseTables.items,
      orderBy: 'id',
    );
    expect(storedItems, hasLength(2));
    expect(
      storedItems.singleWhere((row) => row['id'] == 'inactive-item')['name'],
      'Old Glass',
    );
    expect(
      storedItems.singleWhere(
        (row) => row['id'] == 'inactive-item',
      )['is_active'],
      0,
    );

    final configured = await repository.getItems(channel: 'D2D');
    expect(configured.map((item) => item.id), ['active-item']);
    final collection = await repository.getCollectionMaterials(channel: 'D2D');
    expect(collection.map((item) => item.id), ['active-item']);

    final requests = await repository.getRequests(supervisor: true);
    expect(requests.single.followUpAt, '2000-01-01T09:30:00.000Z');
    expect(requests.single.overdue, isTrue);
  });
}
