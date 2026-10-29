import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_data_source.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.instance;
  late String databasePath;
  late EerlLocalDataSource local;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(
      await getDatabasesPath(),
      'supervisor_todays_summary_test.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
    local = EerlLocalDataSource(database: database);
  });

  setUp(() async {
    await database.clearDatabaseOnLogout();

    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center 1',
    });
    await database.insert(DatabaseTables.centers, {
      'id': 'center-2',
      'name': 'Center 2',
    });
    await database.insert(DatabaseTables.myCenters, {
      'center_id': 'center-1',
      'is_primary': 1,
    });
    await database.insert(DatabaseTables.myCenters, {
      'center_id': 'center-2',
      'is_primary': 0,
    });
    EerlLocalRepository.instance.activeCenterNotifier.value = null;
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test(
    'supervisor summary active agents counts only active agents of current center',
    () async {
      final today = DateTime.now().toUtc().toIso8601String();

      // Center 1 agents: agent-1a (active), agent-1b (offline)
      await _insertPerson(database, userId: 'agent-1a', centerId: 'center-1');
      await _insertPerson(database, userId: 'agent-1b', centerId: 'center-1');

      // Center 2 agents: agent-2a (active), agent-2b (active), agent-2c (offline)
      await _insertPerson(database, userId: 'agent-2a', centerId: 'center-2');
      await _insertPerson(database, userId: 'agent-2b', centerId: 'center-2');
      await _insertPerson(database, userId: 'agent-2c', centerId: 'center-2');

      // Collections today:
      // agent-1a collected at center-1 (active for center-1)
      await _insertCollection(
        database,
        id: 'c-1a',
        centerId: 'center-1',
        agentId: 'agent-1a',
        collectedAt: today,
        status: 'SUBMITTED',
      );

      // agent-2a and agent-2b collected at center-2 (active for center-2)
      await _insertCollection(
        database,
        id: 'c-2a',
        centerId: 'center-2',
        agentId: 'agent-2a',
        collectedAt: today,
        status: 'APPROVED',
      );
      await _insertCollection(
        database,
        id: 'c-2b',
        centerId: 'center-2',
        agentId: 'agent-2b',
        collectedAt: today,
        status: 'VERIFIED',
      );

      // Check center-1 summary: should only count 1 active agent (agent-1a)
      await EerlLocalRepository.instance.selectCenter('center-1');
      final summary1 = await local.getSupervisorHomeSummary(centerId: 'center-1');
      expect(summary1.activeAgents, 1);

      // Default with active center selected as center-1
      final defaultSummary1 = await local.getSupervisorHomeSummary();
      expect(defaultSummary1.activeAgents, 1);

      // Check center-2 summary: should only count 2 active agents (agent-2a, agent-2b)
      await EerlLocalRepository.instance.selectCenter('center-2');
      final summary2 = await local.getSupervisorHomeSummary(centerId: 'center-2');
      expect(summary2.activeAgents, 2);

      // Default with active center selected as center-2
      final defaultSummary2 = await local.getSupervisorHomeSummary();
      expect(defaultSummary2.activeAgents, 2);

      // Draft collection does not make agent-1b active
      await _insertCollection(
        database,
        id: 'c-1b-draft',
        centerId: 'center-1',
        agentId: 'agent-1b',
        collectedAt: today,
        status: 'DRAFT',
      );
      final summary1AfterDraft = await local.getSupervisorHomeSummary(centerId: 'center-1');
      expect(summary1AfterDraft.activeAgents, 1);

      // When agent-1b submits, count for center-1 becomes 2
      await _insertCollection(
        database,
        id: 'c-1b-submitted',
        centerId: 'center-1',
        agentId: 'agent-1b',
        collectedAt: today,
        status: 'SUBMITTED',
      );
      final summary1AfterSubmit = await local.getSupervisorHomeSummary(centerId: 'center-1');
      expect(summary1AfterSubmit.activeAgents, 2);
    },
  );

  test('activeCenterNotifier notifies listeners when selectCenter is called', () async {
    String? notifiedCenter;
    void listener() {
      notifiedCenter = EerlLocalRepository.instance.activeCenterNotifier.value;
    }

    EerlLocalRepository.instance.activeCenterNotifier.addListener(listener);
    addTearDown(() {
      EerlLocalRepository.instance.activeCenterNotifier.removeListener(listener);
    });

    await EerlLocalRepository.instance.selectCenter('center-2');
    expect(notifiedCenter, 'center-2');

    await EerlLocalRepository.instance.selectCenter('center-1');
    expect(notifiedCenter, 'center-1');
  });

  test('getAgentStatus with centerId returns only current center agents', () async {
    final today = DateTime.now().toUtc().toIso8601String();
    await _insertPerson(database, userId: 'ag-1', centerId: 'center-1');
    await _insertPerson(database, userId: 'ag-2', centerId: 'center-2');
    await _insertCollection(
      database,
      id: 'c-ag-1',
      centerId: 'center-1',
      agentId: 'ag-1',
      collectedAt: today,
      status: 'SUBMITTED',
    );

    final agentsC1 = await local.getAgentStatus(centerId: 'center-1');
    expect(agentsC1.length, 1);
    expect(agentsC1.single.userId, 'ag-1');
    expect(agentsC1.single.lastCollectionAt, isNotNull); // active

    final agentsC2 = await local.getAgentStatus(centerId: 'center-2');
    expect(agentsC2.length, 1);
    expect(agentsC2.single.userId, 'ag-2');
    expect(agentsC2.single.lastCollectionAt, isNull); // offline
  });
}

Future<void> _insertPerson(
  AppDatabase database, {
  required String userId,
  required String centerId,
  bool isAgent = true,
}) => database.insert(DatabaseTables.centerPeople, {
  'user_id': userId,
  'center_id': centerId,
  'name': userId,
  'phone': '9876543210',
  'is_agent': isAgent ? 1 : 0,
});

Future<void> _insertCollection(
  AppDatabase database, {
  required String id,
  required String centerId,
  required String agentId,
  required String collectedAt,
  required String status,
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
