import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/features/bootstrap/data/bootstrap_database_applier.dart';
import 'package:eerl_app/features/bootstrap/model/bootstrap_response.dart';
import 'package:eerl_app/features/outbound/data/outbound_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_flags_screens.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_home_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _me = 'u-sup';
const _today = '2026-11-27';

/// The Pickup Supervisor screens on a real SQLite database.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.instance;
  late String path;
  late OutboundLiveSession session;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    path = p.join(await getDatabasesPath(), 'supervisor_live_flow_test.db');
    AppDatabase.setDatabasePathForTesting(path);
    await deleteDatabase(path);
  });

  tearDownAll(() async {
    await db.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(path);
  });

  /// Lets SQLite work finish (until no loader shows), then rebuilds.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 200; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 15)),
      );
      await tester.pump();
      if (i > 10 && find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        return;
      }
    }
  }

  Map<String, Object?> pickup(String id, String status) => {
    'id': id,
    'source_id': 's-1',
    'origin': status == 'REQUESTED' ? 'EXTRA' : 'SCHEDULE',
    'status': status,
    'scheduled_for': _today,
    'slot_index': 0,
    'due_date': _today,
    'pickup_supervisor_id': _me,
    'source_name': 'Hotel Rajdhani',
  };

  testWidgets('Home counts and Mark done on a flag', (tester) async {
    tester.view.physicalSize = const Size(375, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.runAsync(() async {
      await BootstrapDatabaseApplier(database: db).apply(
        BootstrapData.fromJson({
          'cursor': 'c-1',
          'tables': {
            'outbound_sources': {
              'upserts': [
                {
                  'id': 's-1',
                  'status': 'ACTIVE',
                  'name': 'Hotel Rajdhani',
                  'address': 'Station Road, Adajan',
                  'pickup_category': 'DAILY',
                  'pickup_supervisor_id': _me,
                },
              ],
            },
            'due_pickups': {
              'upserts': [pickup('p-1', 'DUE'), pickup('p-2', 'REQUESTED')],
            },
            'trip_issues': {
              'upserts': [
                {
                  'id': 'i-1',
                  'raised_by_id': 'u-drv',
                  'raised_by_name': 'Ravi',
                  'raised_by_phone': '9000000001',
                  'supervisor_id': _me,
                  'types': ['VEHICLE_BREAKDOWN'],
                  'status': 'OPEN',
                  'raised_at': '2026-11-27T04:00:00.000Z',
                },
              ],
            },
            'supervisor_flags': {
              'upserts': [
                {
                  'id': 'f-1',
                  'type': 'SCHEDULE_CHANGED',
                  'source_id': 's-1',
                  'message': 'Now every Mon and Thu',
                },
              ],
            },
          },
        }),
      );
      session = OutboundLiveSession.forTesting(
        actor: const OutboundActor(id: _me, name: 'Kiran Patel'),
        database: db,
        clock: OutboundClock(now: () => DateTime.utc(2026, 11, 27, 4, 30)),
      );
    });

    Widget app(Widget home) => MaterialApp(
      builder: (context, child) =>
          OutboundLiveScope(session: session, child: child!),
      home: home,
    );

    await tester.pumpWidget(
      app(const PickupSupervisorHomeScreen(showBottomNavigation: false)),
    );
    await settle(tester);

    String tile(String label) => (tester.widget<Text>(
      find
          .descendant(
            of: find.byKey(Key('supervisor-attention-$label')),
            matching: find.byType(Text),
          )
          .last,
    )).data!;
    expect(tile('Approvals'), '01');
    expect(tile('Issues'), '01');
    expect(tile('Flags'), '01');

    // Flags: the flag names its pickup point and says what happened.
    await tester.pumpWidget(app(const PickupSupervisorFlagsScreen()));
    await settle(tester);
    expect(find.text('Hotel Rajdhani'), findsOneWidget);
    expect(find.text('Now every Mon and Thu'), findsOneWidget);

    await tester.tap(find.text('Hotel Rajdhani'));
    await settle(tester);
    await tester.tap(find.byKey(const Key('supervisor-flag-mark-done')));
    await settle(tester);

    final rows = await tester.runAsync(
      () async => (
        await db.query('outbox'),
        (await db.query('supervisor_flags')).single,
      ),
    );
    final (outbox, flag) = rows!;
    expect(outbox.single['path'], '/supervisor-flags/f-1/done');
    expect(flag['done_at'], isNotNull);
    expect(flag['sync_state'], 'pending');
    expect(find.byKey(const Key('supervisor-flags-empty')), findsOneWidget);
    // Let the "Marked done" toast close.
    await tester.pump(const Duration(seconds: 6));
  });
}
