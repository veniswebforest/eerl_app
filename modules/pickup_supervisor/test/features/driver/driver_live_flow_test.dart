import 'dart:convert';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/features/bootstrap/data/bootstrap_database_applier.dart';
import 'package:eerl_app/features/bootstrap/model/bootstrap_response.dart';
import 'package:eerl_app/features/outbound/data/outbound_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/features/driver/view/driver_home_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _driver = 'u-drv';
const _today = '2026-11-27';

/// The driver screens on a real SQLite database: Home reads today's trip,
/// Start trip and a 0 kg stop are queued in the outbox.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.instance;
  late String path;
  late OutboundLiveSession session;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    path = p.join(await getDatabasesPath(), 'driver_live_flow_test.db');
    AppDatabase.setDatabasePathForTesting(path);
    await deleteDatabase(path);
  });

  tearDownAll(() async {
    await db.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(path);
  });

  Map<String, Object?> stop(String id, int order, String mode) => {
    'id': id,
    'trip_id': 't-1',
    'stop_order': order,
    'source_id': 's-$id',
    'status': 'PLANNED',
    'due_date': _today,
    'source_name': 'Shop $id',
    'source_address': 'Ring Road, Surat',
    'window_start': '08:00',
    'window_end': '10:00',
    'contact_name': 'Rakesh',
    'contact_role': 'Owner',
    'contact_phone': '9000000009',
    'material_mode': mode,
    'item_ids': <String>[],
  };

  /// Lets SQLite work finish, then rebuilds.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 15)),
      );
      await tester.pump();
    }
  }

  testWidgets('Home, Start trip, Nothing to collect from SQLite', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.runAsync(() async {
      await BootstrapDatabaseApplier(database: db).apply(
        BootstrapData.fromJson({
          'cursor': 'c-1',
          'me': {
            'user': {'id': _driver, 'name': 'Ravi'},
            'roles': <Object>[],
            'centers': <Object>[],
            'supervisor': {'name': 'Sunil Patel', 'phone': '9000000002'},
            'outbound': {'gpsRadiusM': 100},
          },
          'tables': {
            'pickup_trips': {
              'upserts': [
                {
                  'id': 't-1',
                  'route_id': 'r-1',
                  'route_name': 'Route A',
                  'trip_date': _today,
                  'supervisor_id': 'u-sup',
                  'warehouse_id': 'w-1',
                  'warehouse_name': 'Sachin Warehouse',
                  'shift_id': 'sh-1',
                  'shift_name': 'Morning',
                  'shift_start': '06:00',
                  'shift_end': '14:00',
                  'vehicle_kind': 'OWN',
                  'vehicle_plate': 'GJ05AB1234',
                  'driver_id': _driver,
                  'driver_name': 'Ravi',
                  'status': 'PLANNED',
                  'trip_stops': [
                    stop('p-1', 1, 'MIXED'),
                    stop('p-2', 2, 'MIXED'),
                  ],
                },
              ],
            },
          },
        }),
      );
      session = OutboundLiveSession.forTesting(
        actor: const OutboundActor(id: _driver, name: 'Ravi'),
        database: db,
        clock: OutboundClock(now: () => DateTime.utc(2026, 11, 27, 4, 30)),
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) =>
            OutboundLiveScope(session: session, child: child!),
        home: const DriverHomeScreen(),
      ),
    );
    await settle(tester);

    expect(find.text('Sunil Patel'), findsOneWidget);
    expect(find.text('Trip 1 · Morning'), findsOneWidget);
    expect(find.text('6:00 am – 2:00 pm · 2 stops'), findsOneWidget);
    expect(find.text('Drop at Sachin Warehouse'), findsOneWidget);
    expect(find.text('See all 2 stops'), findsOneWidget);

    // Start trip: queued, and the trip shows On the way.
    final start = find.byKey(const Key('driver-start-trip'));
    await tester.ensureVisible(start);
    await tester.tap(start);
    await settle(tester);
    expect(find.byKey(const Key('driver-start-trip')), findsNothing);

    // The next stop: Enter collection opens its detail, then 0 kg.
    final enter = find.text('Enter collection').first;
    await tester.ensureVisible(enter);
    await tester.tap(enter);
    await settle(tester);
    expect(find.text('Shop p-1'), findsWidgets);

    final nothing = find.byKey(const Key('driver-nothing-to-collect'));
    await tester.ensureVisible(nothing);
    await tester.tap(nothing);
    await settle(tester);
    final save = find.text('Save as 0 kg');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await settle(tester);

    final rows = await tester.runAsync(() async {
      final outbox = await db.query('outbox', orderBy: 'seq');
      final stop = await db.query('trip_stops', where: "id = 'p-1'");
      final trip = await db.query('pickup_trips', where: "id = 't-1'");
      return (outbox, stop.single, trip.single);
    });
    final (outbox, savedStop, trip) = rows!;
    expect(outbox.map((row) => row['kind']), ['start', 'entry']);
    expect(outbox.first['path'], '/pickup-trips/t-1/start');
    final entry = jsonDecode(outbox.last['body']! as String) as Map;
    expect(entry['outcome'], 'ZERO_KG');
    expect(entry['zeroKgReason'], 'NO_MATERIAL');
    expect(entry['duePickupId'], 'p-1');
    expect(savedStop['status'], 'NOT_COLLECTED');
    expect(trip['status'], 'ON_ROUTE');
    expect(trip['sync_state'], 'pending');
  });
}
