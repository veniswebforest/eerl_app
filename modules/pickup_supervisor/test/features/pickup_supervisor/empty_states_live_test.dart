import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/features/outbound/data/outbound_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_routes_screen.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_sources_screens.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// With nothing on the phone, Unassigned sources and Routes show their
/// Figma empty states (nodes 7028:5358 and 7028:5709).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.instance;
  late String path;
  late OutboundLiveSession session;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    path = p.join(await getDatabasesPath(), 'empty_states_live_test.db');
    AppDatabase.setDatabasePathForTesting(path);
    await deleteDatabase(path);
    await db.database;
    session = OutboundLiveSession.forTesting(
      actor: const OutboundActor(id: 'u-sup', name: 'Kiran'),
      database: db,
      clock: OutboundClock(now: () => DateTime.utc(2026, 11, 27, 4, 30)),
    );
  });

  tearDownAll(() async {
    await db.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(path);
  });

  Future<void> pump(WidgetTester tester, Widget home) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            OutboundLiveScope(session: session, child: child!),
        home: home,
      ),
    );
    for (var i = 0; i < 40; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 15)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('Unassigned sources with no data', (tester) async {
    await pump(
      tester,
      const PickupSupervisorSourcesScreen(showBottomNavigation: false),
    );
    expect(find.text('Sources (0)'), findsOneWidget);
    expect(find.text('No pickup points waiting for a route'), findsOneWidget);
    expect(find.byKey(const Key('supervisor-sources-list')), findsNothing);

    await tester.tap(find.byKey(const Key('sources-tab-1')));
    await tester.pump();
    expect(find.text('No extra pickups waiting for a trip'), findsOneWidget);
  });

  testWidgets('Routes with no data', (tester) async {
    await pump(
      tester,
      const PickupSupervisorRoutesScreen(showBottomNavigation: false),
    );
    expect(
      find.text('No routes yet. Tap + to make your first route'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('route-filter-0')), findsNothing);
    expect(find.byKey(const Key('supervisor-routes-list')), findsNothing);
  });
}
