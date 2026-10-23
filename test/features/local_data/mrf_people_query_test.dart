import 'dart:convert';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_data_source.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/supervisor_mrf_people/view/supervisor_mrf_people_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.instance;
  late String databasePath;
  late EerlLocalDataSource local;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(await getDatabasesPath(), 'mrf_people_query.db');
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
    local = EerlLocalDataSource(database: database);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.accessTokenKey: 'mrf-token',
    });
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Active Center',
    });
    await database.insert(DatabaseTables.centers, {
      'id': 'center-2',
      'name': 'Other Center',
    });
    await database.insert(DatabaseTables.myCenters, {
      'center_id': 'center-1',
      'is_primary': 1,
    });
    await database.setSyncMeta('active_center_id', 'center-1');
    await _insertPerson(
      database,
      id: 'labor-a',
      centerId: 'center-1',
      name: 'A Labor',
      role: 'LABOR',
    );
    await _insertPerson(
      database,
      id: 'supervisor-z',
      centerId: 'center-1',
      name: 'Z Supervisor',
      role: 'SUPERVISOR',
    );
    await _insertPerson(
      database,
      id: 'inactive-supervisor',
      centerId: 'center-1',
      name: 'Inactive Supervisor',
      role: 'SUPERVISOR',
      active: false,
    );
    await _insertPerson(
      database,
      id: 'other-center-supervisor',
      centerId: 'center-2',
      name: 'Other Supervisor',
      role: 'SUPERVISOR',
    );
    await _insertPerson(
      database,
      id: 'other-center-labor',
      centerId: 'center-2',
      name: 'Other Labor',
      role: 'LABOR',
    );
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('filters by active center and tab with supervisor first', () async {
    final active = await local.getMrfPeople(isActive: true);
    final inactive = await local.getMrfPeople(isActive: false);

    expect(active.map((person) => person.id), ['supervisor-z', 'labor-a']);
    expect(inactive.map((person) => person.id), ['inactive-supervisor']);
  });

  test('finds another active supervisor only at the same center', () async {
    final conflict = await local.getOtherActiveMrfSupervisor(
      centerId: 'center-1',
      personId: 'new-person',
    );
    final selfExcluded = await local.getOtherActiveMrfSupervisor(
      centerId: 'center-1',
      personId: 'supervisor-z',
    );

    expect(conflict?.id, 'supervisor-z');
    expect(selfExcluded, isNull);
  });

  test('loads MRF people from every center containing MRF people', () async {
    final people = await local.getMrfPeople(isActive: true, allCenters: true);

    expect(people.map((person) => person.id), [
      'supervisor-z',
      'labor-a',
      'other-center-supervisor',
      'other-center-labor',
    ]);
    expect((await local.getMrfCenters()).map((center) => center.id), [
      'center-1',
      'center-2',
    ]);
  });

  test(
    'add stores MRF person locally before queuing exact PUT payload',
    () async {
      const person = MrfPersonModel(
        id: 'new-labour',
        centerId: 'center-2',
        name: 'Hardik Pandya',
        phone: '9700000002',
        isActive: true,
        role: 'LABOR',
        syncState: 'pending',
      );

      await local.saveMrfPerson(person, isNew: true);

      final stored = (await database.query(
        DatabaseTables.mrfPeople,
        where: 'id = ?',
        whereArgs: const ['new-labour'],
      )).single;
      final queued = (await database.query(
        DatabaseTables.outbox,
        where: 'entity_id = ?',
        whereArgs: const ['new-labour'],
      )).single;
      final body =
          jsonDecode(queued['body']! as String) as Map<String, dynamic>;

      expect(stored['phone'], '9700000002');
      expect(stored['role'], 'LABOUR');
      expect(stored['sync_state'], 'pending');
      expect(queued['method'], 'PUT');
      expect(queued['path'], '/mrf-people/new-labour');
      expect(body, {
        'centerId': 'center-2',
        'name': 'Hardik Pandya',
        'phone': '9700000002',
        'role': 'LABOUR',
      });
    },
  );

  test(
    'edit queues PATCH without centerId and remove queues status POST',
    () async {
      const edited = MrfPersonModel(
        id: 'labor-a',
        number: 'MRF-labor-a',
        centerId: 'center-1',
        name: 'A Labor Updated',
        phone: '+919700000012',
        idNumber: 'XXXX-XXXX-3390',
        photoUrl: 'https://example.com/labor.jpg',
        isActive: true,
        role: 'LABOUR',
        syncState: 'pending',
      );

      await local.saveMrfPerson(edited, isNew: false);
      await local.setMrfPersonActive(edited, false);

      final queued = await database.query(
        DatabaseTables.outbox,
        where: 'entity_id = ?',
        whereArgs: const ['labor-a'],
        orderBy: 'seq',
      );
      final patchBody =
          jsonDecode(queued.first['body']! as String) as Map<String, dynamic>;
      final statusBody =
          jsonDecode(queued.last['body']! as String) as Map<String, dynamic>;

      expect(queued.first['method'], 'PATCH');
      expect(queued.first['path'], '/mrf-people/labor-a');
      expect(patchBody.containsKey('centerId'), isFalse);
      expect(patchBody['phone'], '9700000012');
      expect(patchBody['idNumber'], 'XXXX-XXXX-3390');
      expect(patchBody['photoUrl'], 'https://example.com/labor.jpg');
      expect(queued.last['method'], 'POST');
      expect(queued.last['path'], '/mrf-people/labor-a/status');
      expect(statusBody, {'isActive': false});
    },
  );

  test('outgoing sync sends queued MRF API and applies response', () async {
    const person = MrfPersonModel(
      id: 'synced-labour',
      centerId: 'center-2',
      name: 'Hardik Pandya',
      phone: '9700000002',
      isActive: true,
      role: 'LABOUR',
      syncState: 'pending',
    );
    await local.saveMrfPerson(person, isNew: true);
    late http.Request sent;
    final sync = OutgoingSyncService(
      database: database,
      internetAccessChecker: () async => true,
      client: MockClient((request) async {
        sent = request;
        return http.Response(
          jsonEncode({
            'data': {
              'id': person.id,
              'number': 'MRF-2026-101',
              'centerId': person.centerId,
              'name': person.name,
              'phone': '9700000002',
              'isActive': true,
              'role': 'LABOUR',
            },
          }),
          200,
        );
      }),
    );

    await sync.drain();

    expect(sent.method, 'PUT');
    expect(sent.url.path, '/api/v1/mobile/mrf-people/synced-labour');
    expect(sent.headers['authorization'], 'Bearer mrf-token');
    expect(jsonDecode(sent.body), {
      'centerId': 'center-2',
      'name': 'Hardik Pandya',
      'phone': '9700000002',
      'role': 'LABOUR',
    });
    expect(await database.query(DatabaseTables.outbox), isEmpty);
    final stored = (await database.query(
      DatabaseTables.mrfPeople,
      where: 'id = ?',
      whereArgs: const ['synced-labour'],
    )).single;
    expect(stored['number'], 'MRF-2026-101');
    expect(stored['sync_state'], 'synced');
  });

  testWidgets('screen renders table rows and selected row details', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SupervisorMrfPeopleScreen(
          teamLoader: () async => (
            centers: const [
              CenterModel(id: 'center-1', name: 'Active Center'),
              CenterModel(id: 'center-2', name: 'Other Center'),
            ],
            active: const [
              MrfPersonModel(
                id: 'supervisor-z',
                number: 'MRF-supervisor-z',
                centerId: 'center-1',
                name: 'Z Supervisor',
                phone: '9999999999',
                idNumber: 'ID-supervisor-z',
                isActive: true,
                role: 'SUPERVISOR',
                syncState: 'synced',
              ),
              MrfPersonModel(
                id: 'labor-a',
                number: 'MRF-labor-a',
                centerId: 'center-1',
                name: 'A Labor',
                phone: '9999999999',
                idNumber: 'ID-labor-a',
                isActive: true,
                role: 'LABOR',
                syncState: 'synced',
              ),
              MrfPersonModel(
                id: 'other-center-supervisor',
                number: 'MRF-other-center-supervisor',
                centerId: 'center-2',
                name: 'Other Supervisor',
                phone: '8888888888',
                idNumber: 'ID-other-center-supervisor',
                isActive: true,
                role: 'SUPERVISOR',
                syncState: 'synced',
              ),
              MrfPersonModel(
                id: 'other-center-labor',
                number: 'MRF-other-center-labor',
                centerId: 'center-2',
                name: 'Other Labor',
                phone: '7777777777',
                idNumber: 'ID-other-center-labor',
                isActive: true,
                role: 'LABOR',
                syncState: 'synced',
              ),
            ],
            inactive: const [
              MrfPersonModel(
                id: 'inactive-supervisor',
                number: 'MRF-inactive-supervisor',
                centerId: 'center-1',
                name: 'Inactive Supervisor',
                phone: '9999999999',
                idNumber: 'ID-inactive-supervisor',
                isActive: false,
                role: 'SUPERVISOR',
                syncState: 'synced',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    for (var attempt = 0; attempt < 50; attempt++) {
      if (find.text('Z Supervisor').evaluate().isNotEmpty) break;
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byKey(const Key('supervisor-mrf-active-tab')), findsNothing);
    expect(find.byKey(const Key('supervisor-mrf-inactive-tab')), findsNothing);
    expect(find.text('Z Supervisor'), findsOneWidget);
    expect(find.text('Other Supervisor'), findsOneWidget);
    expect(find.text('1 Labour assigned'), findsNWidgets(2));
    expect(find.text('A Labor'), findsNothing);
    expect(find.byKey(const Key('supervisor-mrf-add-person')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('supervisor-mrf-search'))),
      const Size(335, 55),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('supervisor-mrf-Z Supervisor'))),
      const Size(335, 120),
    );
    expect(
      tester.getSize(find.byKey(const Key('supervisor-mrf-add-person'))),
      const Size(335, 52),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('supervisor-mrf-Z Supervisor')));
    await tester.pump();
    expect(tester.takeException(), isNull);

    expect(
      find.byKey(const Key('supervisor-mrf-remove-person')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('supervisor-mrf-edit-person')), findsOneWidget);
    expect(find.text('#MRF-supervisor-z'), findsOneWidget);
    expect(find.textContaining('9999999999'), findsWidgets);
    expect(find.textContaining('Active Center'), findsOneWidget);
    expect(find.text('Labor 1'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -350));
    await tester.pump();
    expect(find.textContaining('A Labor'), findsOneWidget);
    expect(find.textContaining('Other Labor'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, 350));
    await tester.pump();
    await tester.tap(find.byKey(const Key('supervisor-mrf-back')));
    await tester.pump();
    expect(find.text('Z Supervisor'), findsOneWidget);
    expect(find.text('Inactive Supervisor'), findsNothing);
  });

  testWidgets('screen matches the Figma empty state when no team exists', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SupervisorMrfPeopleScreen(
          teamLoader: () async => (
            centers: const [CenterModel(id: 'center-1', name: 'Active Center')],
            active: const <MrfPersonModel>[],
            inactive: const <MrfPersonModel>[],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final illustration = find.byKey(
      const Key('supervisor-mrf-empty-illustration'),
    );
    expect(illustration, findsOneWidget);
    final illustrationSize = tester.getSize(illustration);
    expect(illustrationSize.width, closeTo(227.483, 0.01));
    expect(illustrationSize.height, closeTo(233, 0.01));
    expect(find.text('No Team Members Registered'), findsOneWidget);
    expect(find.byKey(const Key('supervisor-mrf-add-person')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('supervisor-mrf-add-person'))),
      const Size(335, 52),
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _insertPerson(
  AppDatabase database, {
  required String id,
  required String centerId,
  required String name,
  required String role,
  bool active = true,
}) => database.insert(DatabaseTables.mrfPeople, {
  'id': id,
  'number': 'MRF-$id',
  'center_id': centerId,
  'name': name,
  'phone': '9999999999',
  'id_number': 'ID-$id',
  'photo_url': null,
  'is_active': active ? 1 : 0,
  'role': role,
  'sync_state': 'synced',
});
