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
    databasePath = p.join(
      await getDatabasesPath(),
      'notification_role_scope.db',
    );
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
    await database.insert(DatabaseTables.myRoles, {
      'role_key': 'AGENT',
      'role_name': 'Agent',
      'modules': '[]',
    });
    await database.insert(DatabaseTables.myRoles, {
      'role_key': 'SUPERVISOR',
      'role_name': 'Supervisor',
      'modules': '[]',
    });
    await database.setSyncMeta('active_role', 'AGENT');
    await _insertNotification(
      database,
      id: 'agent-old',
      role: 'AGENT',
      createdAt: '2026-10-20T08:00:00.000Z',
    );
    await _insertNotification(
      database,
      id: 'legacy-new',
      role: null,
      centerId: null,
      createdAt: '2026-10-20T10:00:00.000Z',
    );
    await _insertNotification(
      database,
      id: 'supervisor-newest',
      role: 'SUPERVISOR',
      createdAt: '2026-10-20T12:00:00.000Z',
    );
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('orders active and legacy rows before other-role rows', () async {
    final rows = await local.getNotifications();

    expect(rows.map((row) => row.id), [
      'legacy-new',
      'agent-old',
      'supervisor-newest',
    ]);
    expect(rows[0].otherRole, isFalse);
    expect(rows[1].otherRole, isFalse);
    expect(rows[2].otherRole, isTrue);
    expect(rows[2].forRoleName, 'Supervisor');
    expect(rows[2].centerId, 'center-1');
  });

  test('returns role-aware unread counts', () async {
    expect(await local.getActiveRoleUnreadNotificationCount(), 2);
    expect(await local.getOtherRoleUnreadNotificationCounts(), {
      'SUPERVISOR': 1,
    });
  });

  test(
    'mark read updates locally and queues the existing read endpoint',
    () async {
      await local.markNotificationRead('agent-old');

      final notification = (await database.query(
        DatabaseTables.notifications,
        where: 'id = ?',
        whereArgs: const ['agent-old'],
      )).single;
      final outbox = (await database.query(DatabaseTables.outbox)).single;
      expect(notification['read_at'], isNotNull);
      expect(notification['sync_state'], 'pending');
      expect(outbox['method'], 'POST');
      expect(outbox['path'], '/notifications/agent-old/read');
      expect(outbox['entity_id'], 'agent-old');
    },
  );
}

Future<void> _insertNotification(
  AppDatabase database, {
  required String id,
  required String? role,
  String? centerId = 'center-1',
  required String createdAt,
}) => database.insert(DatabaseTables.notifications, {
  'id': id,
  'type': 'TEST',
  'title': id,
  'body': 'Body',
  'deep_link': '/tasks',
  'role': role,
  'center_id': centerId,
  'created_at': createdAt,
  'sync_state': 'synced',
});
