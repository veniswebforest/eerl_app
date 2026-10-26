import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.instance;
  late String databasePath;
  late EerlLocalDataSource local;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(await getDatabasesPath(), 'home_summary_query.db');
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
    local = EerlLocalDataSource(database: database);
  });

  setUp(() async {
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await database.setSyncMeta('active_center_id', 'center-1');
    await database.setSyncMeta('user_id', 'agent-1');
    await database.insert(DatabaseTables.items, {
      'id': 'item-kg',
      'name': 'Plastic',
      'category_name': 'Plastic',
      'material_type': 'DRY',
      'unit_code': 'KG',
      'unit_name': 'Kilogram',
      'is_active': 1,
    });
    await database.insert(DatabaseTables.items, {
      'id': 'item-piece',
      'name': 'Bottle',
      'category_name': 'Plastic',
      'material_type': 'DRY',
      'unit_code': 'PCS',
      'unit_name': 'Pieces',
      'is_active': 1,
    });
    await database.insert(DatabaseTables.expenseCategories, {
      'id': 'category-1',
      'center_id': 'center-1',
      'name': 'Fuel',
      'is_active': 1,
    });
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test(
    'agent and supervisor summaries use their matching SQLite data',
    () async {
      final today = DateTime.now().toUtc().toIso8601String();
      final old = DateTime.now()
          .toUtc()
          .subtract(const Duration(days: 2))
          .toIso8601String();

      await _insertPerson(database, 'agent-1');
      await _insertPerson(database, 'agent-2');
      await _insertPerson(database, 'supervisor', isAgent: false);
      await _insertCollection(database, 'verified', 'VERIFIED', today);
      await _insertCollection(database, 'submitted', 'SUBMITTED', today);
      await _insertCollection(database, 'old-verified', 'VERIFIED', old);
      await _insertCollectionItem(database, 'line-1', 'verified', 10, 12);
      await _insertCollectionItem(database, 'line-2', 'submitted', 8, null);
      await _insertCollectionItem(database, 'line-old', 'old-verified', 50, 50);

      await _insertTransfer(
        database,
        'requested',
        'REQUESTED',
        today,
        'agent-1',
      );
      await _insertTransfer(
        database,
        'dispatched',
        'DISPATCHED',
        today,
        'agent-1',
      );
      await _insertTransfer(
        database,
        'other-agent',
        'APPROVED',
        today,
        'agent-2',
      );
      await _insertTransfer(
        database,
        'old-transfer',
        'DISPATCHED',
        old,
        'agent-1',
      );

      await database.insert(DatabaseTables.stock, {
        'id': 'stock-kg',
        'center_id': 'center-1',
        'item_id': 'item-kg',
        'stage': 'RM',
        'qty': 40,
      });
      await database.insert(DatabaseTables.stock, {
        'id': 'stock-pieces',
        'center_id': 'center-1',
        'item_id': 'item-piece',
        'stage': 'RM',
        'qty': 99,
      });
      for (final entry in const {
        'pending': 'PENDING',
        'waiting': 'WAITING_SUPERVISOR',
        'review': 'PENDING_REVIEW',
        'approved': 'APPROVED',
      }.entries) {
        await _insertExpense(database, entry.key, entry.value, today);
      }

      final agent = await local.getAgentHomeSummary();
      expect(agent.collectedKg, 20);
      expect(agent.verifiedEntries, 1);
      expect(agent.transferRequests, 2);

      final supervisor = await local.getSupervisorHomeSummary();
      expect(supervisor.activeAgents, 2);
      expect(supervisor.transfersDone, 1);
      expect(supervisor.totalTransfers, 3);
      expect(supervisor.stockKg, 40);
      expect(supervisor.pendingExpenses, 3);
    },
  );
}

Future<void> _insertPerson(
  AppDatabase database,
  String userId, {
  bool isAgent = true,
}) => database.insert(DatabaseTables.centerPeople, {
  'user_id': userId,
  'center_id': 'center-1',
  'name': userId,
  'phone': '9876543210',
  'is_agent': isAgent ? 1 : 0,
});

Future<void> _insertCollection(
  AppDatabase database,
  String id,
  String status,
  String collectedAt,
) => database.insert(DatabaseTables.collections, {
  'id': id,
  'center_id': 'center-1',
  'agent_id': 'agent-1',
  'agent_name': 'Agent One',
  'channel': 'D2D',
  'status': status,
  'collected_at': collectedAt,
  'updated_at': collectedAt,
  'sync_state': 'synced',
});

Future<void> _insertCollectionItem(
  AppDatabase database,
  String id,
  String collectionId,
  double qty,
  double? verifiedQty,
) => database.insert(DatabaseTables.collectionItems, {
  'id': id,
  'collection_id': collectionId,
  'item_id': 'item-kg',
  'qty': qty,
  'verified_qty': verifiedQty,
  'sort_order': 0,
});

Future<void> _insertTransfer(
  AppDatabase database,
  String id,
  String status,
  String requestedAt,
  String requestedBy,
) => database.insert(DatabaseTables.transfers, {
  'id': id,
  'center_id': 'center-1',
  'type': 'MRF',
  'status': status,
  'requested_by': requestedBy,
  'requested_by_name': requestedBy,
  'requested_at': requestedAt,
  'sync_state': 'synced',
});

Future<void> _insertExpense(
  AppDatabase database,
  String id,
  String status,
  String createdAt,
) => database.insert(DatabaseTables.expenses, {
  'id': id,
  'center_id': 'center-1',
  'user_id': 'agent-1',
  'category_id': 'category-1',
  'amount': 100,
  'status': status,
  'created_at': createdAt,
  'sync_state': 'synced',
});
