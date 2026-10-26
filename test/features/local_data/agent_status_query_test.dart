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
    databasePath = p.join(await getDatabasesPath(), 'agent_status_query.db');
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
    local = EerlLocalDataSource(database: database);
  });

  setUp(() async {
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-b',
      'name': 'Bhatar',
    });
    await database.insert(DatabaseTables.centers, {
      'id': 'center-a',
      'name': 'Adajan',
    });
    await _insertPerson(
      database,
      userId: 'agent-z',
      centerId: 'center-a',
      name: 'Zara',
      phone: '9876543210',
      isAgent: true,
    );
    await _insertPerson(
      database,
      userId: 'agent-a',
      centerId: 'center-b',
      name: 'Amit',
      phone: '9123456780',
      isAgent: true,
    );
    await _insertPerson(
      database,
      userId: 'supervisor',
      centerId: 'center-a',
      name: 'Supervisor',
      phone: '9988776655',
      isAgent: false,
    );
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('returns agents from every center ordered by center and name', () async {
    final today = _todayAt(hour: 10);
    await _insertCollection(
      database,
      id: 'collection-1',
      centerId: 'center-a',
      agentId: 'agent-z',
      status: 'SUBMITTED',
      collectedAt: today,
    );
    await _insertCollection(
      database,
      id: 'collection-2',
      centerId: 'center-a',
      agentId: 'agent-z',
      status: 'VERIFIED',
      collectedAt: _todayAt(hour: 11),
    );
    await _insertCollection(
      database,
      id: 'collection-draft',
      centerId: 'center-a',
      agentId: 'agent-z',
      status: 'DRAFT',
      collectedAt: _todayAt(hour: 12),
    );
    await _insertCollection(
      database,
      id: 'collection-old',
      centerId: 'center-b',
      agentId: 'agent-a',
      status: 'SUBMITTED',
      collectedAt: _todayAt(hour: 9, daysAgo: 1),
    );

    final rows = await local.getAgentStatus();

    expect(rows.map((row) => row.name), ['Zara', 'Amit']);
    expect(rows.first.centerName, 'Adajan');
    expect(rows.first.phone, '9876543210');
    expect(rows.first.collectionsToday, 2);
    expect(rows.first.waitingReview, 1);
    expect(rows.first.lastCollectionAt, _todayAt(hour: 11));
    expect(rows.last.collectionsToday, 0);
    expect(rows.last.waitingReview, 0);
    expect(rows.last.lastCollectionAt, isNull);
  });

  test('optional center filters the grouped agent rows', () async {
    final rows = await local.getAgentStatus(centerId: 'center-b');

    expect(rows, hasLength(1));
    expect(rows.single.userId, 'agent-a');
    expect(rows.single.centerName, 'Bhatar');
  });
}

Future<void> _insertPerson(
  AppDatabase database, {
  required String userId,
  required String centerId,
  required String name,
  required String phone,
  required bool isAgent,
}) => database.insert(DatabaseTables.centerPeople, {
  'user_id': userId,
  'center_id': centerId,
  'name': name,
  'phone': phone,
  'is_agent': isAgent ? 1 : 0,
});

Future<void> _insertCollection(
  AppDatabase database, {
  required String id,
  required String centerId,
  required String agentId,
  required String status,
  required String collectedAt,
}) => database.insert(DatabaseTables.collections, {
  'id': id,
  'center_id': centerId,
  'agent_id': agentId,
  'agent_name': agentId,
  'channel': 'D2D',
  'status': status,
  'collected_at': collectedAt,
  'updated_at': collectedAt,
  'sync_state': 'synced',
});

String _todayAt({required int hour, int daysAgo = 0}) {
  final nowUtc = DateTime.now().toUtc();
  final nowIst = nowUtc.add(const Duration(hours: 5, minutes: 30));
  return DateTime.utc(nowIst.year, nowIst.month, nowIst.day, hour)
      .subtract(Duration(days: daysAgo))
      .subtract(const Duration(hours: 5, minutes: 30))
      .toIso8601String();
}
