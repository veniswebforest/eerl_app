import 'dart:convert';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/features/bootstrap/data/bootstrap_database_applier.dart';
import 'package:eerl_app/features/bootstrap/model/bootstrap_response.dart';
import 'package:eerl_app/features/outbound/data/outbound_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/features/trips_plan/view/trips_plan_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _me = 'u-sup';
const _today = '2026-11-27';

/// Trips plan → Trip details → Skip a stop → Cancel the trip, on SQLite.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.instance;
  late String path;
  late OutboundLiveSession session;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    path = p.join(await getDatabasesPath(), 'trip_live_flow_test.db');
    AppDatabase.setDatabasePathForTesting(path);
    await deleteDatabase(path);
  });

  tearDownAll(() async {
    await db.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(path);
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 200; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 15)),
      );
      await tester.pump(const Duration(milliseconds: 50));
      if (i > 10 && find.byType(CircularProgressIndicator).evaluate().isEmpty) {
        return;
      }
    }
  }

  Map<String, Object?> stop(String id, int order) => {
    'id': id,
    'trip_id': 't-1',
    'stop_order': order,
    'source_id': 's-$id',
    'status': 'PLANNED',
    'due_date': _today,
    'source_name': 'Shop $id',
    'source_address': 'Ring Road',
    'material_mode': 'MIXED',
  };

  Map<String, Object?> pickup(String id, int order) => {
    'id': id,
    'source_id': 's-$id',
    'origin': 'SCHEDULE',
    'status': 'PLANNED',
    'scheduled_for': _today,
    'slot_index': 0,
    'due_date': _today,
    'pickup_supervisor_id': _me,
    'source_name': 'Shop $id',
    'trip_id': 't-1',
    'stop_order': order,
  };

  testWidgets('Trips plan, trip details, skip and cancel from SQLite', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.runAsync(() async {
      await BootstrapDatabaseApplier(database: db).apply(
        BootstrapData.fromJson({
          'cursor': 'c-1',
          'tables': {
            'warehouses': {
              'replace': [
                {'id': 'w-1', 'name': 'Sachin', 'code': 'SCH'},
              ],
            },
            'warehouse_shifts': {
              'replace': [
                {
                  'id': 'sh-1',
                  'warehouse_id': 'w-1',
                  'name': 'Morning',
                  'start_time': '06:00',
                  'end_time': '14:00',
                },
              ],
            },
            'pickup_routes': {
              'upserts': [
                {
                  'id': 'r-1',
                  'name': 'Route A',
                  'supervisor_id': _me,
                  'warehouse_id': 'w-1',
                  'shift_id': 'sh-1',
                  'vehicle_kind': 'OWN',
                  'is_active': true,
                  'pickup_route_stops': [
                    {'id': 'rs-1', 'source_id': 's-p-1', 'stop_order': 1},
                    {'id': 'rs-2', 'source_id': 's-p-2', 'stop_order': 2},
                  ],
                },
              ],
            },
            'pickup_trips': {
              'upserts': [
                {
                  'id': 't-1',
                  'route_id': 'r-1',
                  'route_name': 'Route A',
                  'trip_date': _today,
                  'supervisor_id': _me,
                  'warehouse_id': 'w-1',
                  'warehouse_name': 'Sachin',
                  'shift_id': 'sh-1',
                  'shift_name': 'Morning',
                  'shift_start': '06:00',
                  'shift_end': '14:00',
                  'vehicle_kind': 'OWN',
                  'vehicle_plate': 'GJ05AB1234',
                  'driver_id': 'u-drv',
                  'driver_name': 'Ravi',
                  'status': 'PLANNED',
                  'trip_stops': [stop('p-1', 1), stop('p-2', 2)],
                },
              ],
            },
            'due_pickups': {
              'upserts': [pickup('p-1', 1), pickup('p-2', 2)],
            },
          },
        }),
      );
      // 06:00 IST, before the shift: the trip is simply Planned.
      session = OutboundLiveSession.forTesting(
        actor: const OutboundActor(id: _me, name: 'Kiran Patel'),
        database: db,
        clock: OutboundClock(now: () => DateTime.utc(2026, 11, 27, 0, 15)),
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            OutboundLiveScope(session: session, child: child!),
        home: const TripsPlanScreen(),
      ),
    );
    await settle(tester);
    expect(find.text('Route A'), findsOneWidget);

    await tester.tap(find.text('Route A'));
    await settle(tester);
    expect(find.textContaining('Shop p-1'), findsWidgets);
    expect(find.textContaining('Shop p-2'), findsWidgets);

    // Skip the first stop: it leaves the trip and the skip is queued.
    await tester.tap(find.textContaining('Shop p-1').first);
    await settle(tester);
    await tester.tap(find.byKey(const Key('stop-detail-skip')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('skip-reason-holiday')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('skip-source-confirm')));
    await settle(tester);

    // Let the "Pickup skipped" toast close, then cancel from the ⋮ sheet.
    await tester.pump(const Duration(seconds: 6));
    await settle(tester);
    await tester.tap(find.byKey(const Key('route-detail-more')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('route-action-cancel-trip')));
    await settle(tester);
    await tester.enterText(
      find.byKey(const Key('cancel-trip-reason')),
      'Driver unwell',
    );
    await tester.pump();
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('cancel-trip-popup')),
        matching: find.text('Cancel trip'),
      ),
    );
    await settle(tester);

    final rows = await tester.runAsync(
      () async => (
        await db.query('outbox', orderBy: 'seq'),
        (await db.query('pickup_trips')).single,
        await db.query('due_pickups', orderBy: 'id'),
      ),
    );
    final (outbox, trip, pickups) = rows!;
    expect(outbox.map((o) => o['path']), [
      '/due-pickups/p-1/skip',
      '/pickup-trips/t-1/cancel',
    ]);
    expect(jsonDecode(outbox.first['body']! as String), {
      'reasons': ['HOLIDAY'],
      'note': null,
    });
    expect(trip['status'], 'CANCELLED');
    expect(trip['cancel_reason'], 'Driver unwell');
    expect(pickups.first['status'], 'SKIPPED');
    expect(pickups.last['status'], 'DUE');
    expect(pickups.last['trip_id'], isNull);

    // Let any toast close.
    await tester.pump(const Duration(seconds: 6));
  });
}
