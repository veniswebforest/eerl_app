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
        'expense_categories': {
          'replace': [
            {
              'id': 'fuel',
              'center_id': 'center-1',
              'name': 'Fuel',
              'is_active': 1,
            },
          ],
        },
        'collections': {
          'upserts': [
            {
              'id': 'collection-1',
              'center_id': 'center-1',
              'agent_id': 'agent-1',
              'agent_name': 'Agent One',
              'channel': 'D2D',
              'status': 'REJECTED',
              'handover_photo_urls': '[]',
              'rejection_reason': 'Weight Mismatch',
              'rejection_remarks': 'Scale was not calibrated.',
              'updated_at': '2026-10-21T08:00:00.000Z',
            },
          ],
        },
        'expenses': {
          'upserts': [
            {
              'id': 'expense-1',
              'center_id': 'center-1',
              'user_id': 'agent-1',
              'category_id': 'fuel',
              'amount': 500,
              'status': 'REJECTED',
              'receipt_photo_urls': '[]',
              'decision_reason': 'Invalid bill',
              'decision_remarks': 'Bill is from last month.',
              'created_at': '2026-10-21T08:00:00.000Z',
            },
          ],
        },
        'cash_requests': {
          'upserts': [
            {
              'id': 'cash-1',
              'center_id': 'center-1',
              'requested_by': 'agent-1',
              'amount': 12000,
              'status': 'REJECTED',
              'decision_note': 'Sufficient Existing Balance',
              'decision_remarks': 'Already has an advance.',
              'created_at': '2026-10-21T08:00:00.000Z',
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
              'answer_photo_urls':
                  '["https://example.test/supervisor-proof.jpg"]',
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
    expect(requests.single.answerPhotoUrls, [
      'https://example.test/supervisor-proof.jpg',
    ]);
    expect(
      (await database.query(
        DatabaseTables.collections,
      )).single['rejection_remarks'],
      'Scale was not calibrated.',
    );
    expect(
      (await database.query(
        DatabaseTables.expenses,
      )).single['decision_remarks'],
      'Bill is from last month.',
    );
    expect(
      (await database.query(
        DatabaseTables.cashRequests,
      )).single['decision_remarks'],
      'Already has an advance.',
    );
  });
}
