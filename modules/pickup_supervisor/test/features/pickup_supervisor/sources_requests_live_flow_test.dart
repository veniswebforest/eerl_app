import 'dart:convert';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/features/bootstrap/data/bootstrap_database_applier.dart';
import 'package:eerl_app/features/bootstrap/model/bootstrap_response.dart';
import 'package:eerl_app/features/outbound/data/outbound_clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_attention_screens.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_sources_screens.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _me = 'u-sup';
const _today = '2026-11-27';

/// Unassigned → Assign to a route, Approval requests and My requests, on
/// SQLite.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.instance;
  late String path;
  late OutboundLiveSession session;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    path = p.join(await getDatabasesPath(), 'sources_requests_live_test.db');
    AppDatabase.setDatabasePathForTesting(path);
    await deleteDatabase(path);
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
          'outbound_vehicles': {
            'replace': [
              {
                'id': 'v-1',
                'warehouse_id': 'w-1',
                'plate_number': 'GJ05AB1234',
                'type_name': '',
              },
            ],
          },
          'outbound_sources': {
            'upserts': [
              {
                'id': 's-new',
                'status': 'ACTIVE',
                'name': 'Hotel Rajdhani',
                'material_mode': 'MIXED',
                'address': 'Station Road',
                'contact_phone': '9000000009',
                'pickup_supervisor_id': _me,
              },
              {
                'id': 's-old',
                'status': 'ACTIVE',
                'name': 'City Bakery',
                'material_mode': 'MIXED',
                'pickup_supervisor_id': _me,
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
                'vehicle_id': 'v-1',
                'driver_id': 'u-drv',
                'is_active': true,
                'pickup_route_stops': [
                  {'id': 'rs-1', 'source_id': 's-old', 'stop_order': 1},
                ],
              },
            ],
          },
          'due_pickups': {
            'upserts': [
              {
                'id': 'x-1',
                'source_id': 's-old',
                'origin': 'EXTRA',
                'status': 'REQUESTED',
                'scheduled_for': _today,
                'slot_index': 0,
                'due_date': _today,
                'pickup_supervisor_id': _me,
                'requested_by_name': 'Neha (IEC)',
                'source_name': 'City Bakery',
              },
            ],
          },
          'outbound_requests': {
            'upserts': [
              {
                'id': 'rq-1',
                'kind': 'ENTRY_CORRECTION',
                'raised_by_id': 'u-drv',
                'raised_by_name': 'Ravi',
                'raised_as': 'DRIVER',
                'send_to': 'SUPERVISOR',
                'assignee_id': _me,
                'source_name': 'City Bakery',
                'details': 'It was 12 kg, not 21',
                'status': 'WAITING',
                'raised_at': '2026-11-27T03:00:00.000Z',
              },
              {
                'id': 'rq-2',
                'kind': 'VEHICLE',
                'raised_by_id': _me,
                'raised_by_name': 'Kiran',
                'raised_as': 'PICKUP_SUPERVISOR',
                'send_to': 'COLLECTION_HEAD',
                'route_name': 'Route A',
                'details': 'Need a second van',
                'status': 'APPROVED',
                'decided_by_name': 'Head',
                'decided_at': '2026-11-26T10:00:00.000Z',
                'raised_at': '2026-11-26T08:00:00.000Z',
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

  Widget app(Widget home) => MaterialApp(
    builder: (context, child) =>
        OutboundLiveScope(session: session, child: child!),
    home: home,
  );

  void tall(WidgetTester tester) {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<List<Map<String, Object?>>> outbox(WidgetTester tester) async =>
      (await tester.runAsync(() => db.query('outbox', orderBy: 'seq')))!;

  testWidgets('Unassigned: a pickup point is added to a route', (tester) async {
    tall(tester);
    await tester.pumpWidget(
      app(const PickupSupervisorSourcesScreen(showBottomNavigation: false)),
    );
    await settle(tester);
    expect(find.text('Sources (1)'), findsOneWidget);
    expect(find.textContaining('Hotel Rajdhani'), findsOneWidget);

    await tester.tap(find.textContaining('Hotel Rajdhani'));
    await settle(tester);
    expect(find.textContaining('Station Road'), findsOneWidget);
    await tester.tap(find.byKey(const Key('source-add-to-route')));
    await settle(tester);
    expect(find.text('Route A'), findsOneWidget);
    await tester.tap(find.byKey(const Key('source-assign-anyway')));
    await settle(tester);
    expect(find.byKey(const Key('source-added-dialog')), findsOneWidget);

    final item = (await outbox(tester)).single;
    expect(item['path'], '/pickup-routes/r-1');
    final body = jsonDecode(item['body']! as String) as Map;
    expect(body['sourceIds'], ['s-old', 's-new']);
    expect(body['vehicleId'], 'v-1');
    await tester.runAsync(() => db.delete('outbox'));
  });

  testWidgets('Approvals: accept an extra pickup, decline a correction', (
    tester,
  ) async {
    tall(tester);
    await tester.pumpWidget(
      app(const PickupSupervisorApprovalRequestsScreen()),
    );
    await settle(tester);
    expect(find.textContaining('Correction · from Ravi'), findsOneWidget);
    expect(find.text('Extra pickup'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('approval-request-x-1')),
        matching: find.byKey(const Key('approval-approve')),
      ),
    );
    await settle(tester);
    await tester.tap(find.byKey(const Key('approval-success-back')));
    await settle(tester);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('approval-request-rq-1')),
        matching: find.byKey(const Key('approval-decline')),
      ),
    );
    await settle(tester);
    await tester.enterText(
      find.byKey(const Key('approval-decline-reply')),
      'The slip says 21 kg',
    );
    await tester.tap(find.byKey(const Key('approval-decline-confirm')));
    await settle(tester);

    final items = await outbox(tester);
    expect(items.map((o) => o['path']), [
      '/due-pickups/x-1/accept',
      '/outbound-requests/rq-1/decide',
    ]);
    expect(jsonDecode(items.last['body']! as String), {
      'decision': 'DECLINE',
      'reply': 'The slip says 21 kg',
    });
  });

  testWidgets('My requests lists my answered request', (tester) async {
    tall(tester);
    await tester.pumpWidget(app(const PickupSupervisorMyRequestsScreen()));
    await settle(tester);
    expect(find.text('Vehicle · Route A'), findsOneWidget);
    expect(find.text('Approved 1'), findsOneWidget);
    expect(find.textContaining('Need a second van'), findsOneWidget);
  });
}
