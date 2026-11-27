import 'dart:convert';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/mobile_write_validator.dart';
import 'package:eerl_app/core/local_database/outbound/named_sql.dart';
import 'package:eerl_app/core/local_database/outbound/outbound_tables.dart';
import 'package:eerl_app/features/bootstrap/data/bootstrap_database_applier.dart';
import 'package:eerl_app/features/bootstrap/model/bootstrap_response.dart';
import 'package:eerl_app/features/outbound/data/outbound_clock.dart';
import 'package:eerl_app/features/outbound/data/outbound_queries.dart';
import 'package:eerl_app/features/outbound/data/outbound_sync_applier.dart';
import 'package:eerl_app/features/outbound/data/outbound_writes.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _supervisor = 'u-sup';
const _driver = 'u-drv';

// 2026-11-27 10:00 IST.
final _clock = OutboundClock(now: () => DateTime.utc(2026, 11, 27, 4, 30));
const _today = '2026-11-27';
const _yesterday = '2026-11-26';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase.instance;
  late String path;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    path = p.join(await getDatabasesPath(), 'outbound_offline_flow_test.db');
    AppDatabase.setDatabasePathForTesting(path);
    await deleteDatabase(path);
  });

  tearDownAll(() async {
    await db.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(path);
  });

  setUp(() async {
    await db.clearDatabaseOnLogout();
  });

  Future<void> applyPage(Map<String, Object?> page) => BootstrapDatabaseApplier(
    database: db,
  ).apply(BootstrapData.fromJson({'cursor': 'c-${page.hashCode}', ...page}));

  Map<String, Object?> trip({
    required String id,
    String date = _today,
    String status = 'PLANNED',
    String driverId = _driver,
    List<Map<String, Object?>>? stops,
  }) => {
    'id': id,
    'number': 'SCH-TRP-$id',
    'route_id': 'r-1',
    'route_name': 'Route A',
    'trip_date': date,
    'supervisor_id': _supervisor,
    'warehouse_id': 'w-1',
    'warehouse_name': 'Sachin',
    'shift_id': 'sh-1',
    'shift_name': 'Morning',
    'shift_start': '06:00',
    'shift_end': '14:00',
    'vehicle_kind': 'OWN',
    'vehicle_id': 'v-1',
    'vehicle_plate': 'GJ05AB1234',
    'driver_id': driverId,
    'driver_name': 'Ravi',
    'driver_phone': '9000000001',
    'status': status,
    'changed_for_today': false,
    'slip_photo_urls': <String>[],
    'driver_kg': 0,
    'variance_flagged': false,
    'trip_stops': ?stops,
  };

  Map<String, Object?> stop(
    String id,
    String tripId,
    int order, {
    String status = 'PLANNED',
    String due = _today,
  }) => {
    'id': id,
    'trip_id': tripId,
    'stop_order': order,
    'source_id': 's-$id',
    'status': status,
    'due_date': due,
    'source_name': 'Shop $id',
    'lat': 21.17,
    'lng': 72.83,
    'material_mode': 'SORTED',
    'item_ids': ['item-1'],
    'entry_lines': <Object>[],
    'photo_urls': <Object>[],
  };

  Map<String, Object?> duePickup(
    String id, {
    String status = 'DUE',
    String? tripId,
    String due = _today,
  }) => {
    'id': id,
    'source_id': 's-$id',
    'origin': 'SCHEDULE',
    'status': status,
    'scheduled_for': due,
    'slot_index': 0,
    'due_date': due,
    'pickup_supervisor_id': _supervisor,
    'skip_reasons': <String>[],
    'source_name': 'Shop $id',
    'item_ids': ['item-1'],
    'trip_id': tripId,
    'stop_order': tripId == null ? null : 1,
  };

  Future<int> count(String table, [String where = '1']) async =>
      (await db.rawQuery('SELECT COUNT(*) AS n FROM $table WHERE $where')).single['n']! as int;

  group('schema', () {
    test('creates every outbound table and index', () async {
      expect(await db.validateSchema(), isTrue);
      final tables = await db.getExistingTableNames();
      expect(tables, containsAll(OutboundTables.values));
    });
  });

  group('NamedSql', () {
    test('binds names in order and leaves quoted text alone', () {
      final bound = NamedSql(
        "SELECT strftime('%H:%M', :a), :b, ':c', :a -- :zz\nFROM x",
        {'a': 1, 'b': 2},
      );
      expect(
        bound.sql,
        "SELECT strftime('%H:%M', ?), ?, ':c', ? -- :zz\nFROM x",
      );
      expect(bound.arguments, [1, 2, 1]);
      expect(() => NamedSql('SELECT :missing', {}), throwsArgumentError);
    });
  });

  group('bootstrap', () {
    test('step me stores settings, warehouses, cash and dues', () async {
      await applyPage({
        'me': {
          'user': {'id': _supervisor, 'name': 'Sunil'},
          'roles': <Object>[],
          'centers': <Object>[],
          'warehouses': [
            {'id': 'w-1', 'isPrimary': true},
          ],
          'outbound': {
            'gpsRadiusM': 100,
            'tolerancePct': 3,
            'speedKmh': 20,
            'mixedItemId': 'mixed-1',
            'collectionHead': {'userId': 'ch', 'name': 'Head', 'phone': '99'},
            'cash': {
              'balance': 5000,
              'dues': [
                {'sourceId': 's-1', 'earned': 900, 'paid': 100, 'balance': 800},
              ],
            },
          },
        },
      });
      expect(await db.getSyncMeta('outbound_gps_radius_m'), '100');
      expect(await db.getSyncMeta('outbound_mixed_item_id'), 'mixed-1');
      expect(await db.getSyncMeta('outbound_cash_balance'), '5000');
      expect(await count('my_warehouses'), 1);
      expect(await count('source_dues'), 1);
      final head = await OutboundQueries(
        actorId: _supervisor,
        clock: _clock,
      ).collectionHead();
      expect(head, {'name': 'Head', 'phone': '99'});

      // me.outbound null: every outbound key, cash and dues go.
      await applyPage({
        'me': {'roles': <Object>[], 'centers': <Object>[]},
      });
      expect(await db.getSyncMeta('outbound_gps_radius_m'), isNull);
      expect(await db.getSyncMeta('outbound_cash_balance'), isNull);
      expect(await count('source_dues'), 0);
      expect(await count('my_warehouses'), 0);
    });

    test('reference replace, records with children, protected rows', () async {
      await applyPage({
        'tables': {
          'warehouses': {
            'replace': [
              {
                'id': 'w-1',
                'name': 'Sachin',
                'code': 'SCH',
                'in_charge_phone': '98',
              },
            ],
          },
          'pickup_trips': {
            'upserts': [
              trip(
                id: 't-1',
                stops: [stop('p-1', 't-1', 1), stop('p-2', 't-1', 2)],
              ),
            ],
          },
          'outbound_sources': {
            'upserts': [
              {
                'id': 's-p-1',
                'status': 'ACTIVE',
                'name': 'Shop p-1',
                'is_event': false,
                'pickup_supervisor_id': _supervisor,
                'photo_urls': <String>[],
                'pickup_schedules': [
                  {
                    'id': 'sc-1',
                    'pattern': 'DAILY',
                    'weekdays': <int>[],
                    'except_weekdays': <int>[],
                    'month_days': <int>[],
                    'nth_weekdays': <Object>[],
                    'slots': [
                      {'start': '08:00', 'end': '10:00'},
                    ],
                    'starts_on': '2026-11-01',
                    'holiday_rule': 'SKIP',
                    'allows_extra': true,
                    'effective_from': '2026-11-01',
                    'summary': 'Every day, 08:00–10:00',
                  },
                ],
                'source_payment_terms': [
                  {
                    'id': 'pt-1',
                    'type': 'PER_KG',
                    'per_kg_mode': 'PER_ITEM',
                    'effective_from': '2026-11-01',
                    'summary': 'Per item',
                    'source_item_rates': [
                      {'id': 'ir-1', 'item_id': 'item-1', 'rate_per_kg': 12},
                    ],
                  },
                ],
              },
            ],
          },
        },
      });
      expect(await count('warehouses'), 1);
      expect(await count('trip_stops', "trip_id = 't-1'"), 2);
      expect(await count('pickup_schedules'), 1);
      expect(await count('source_item_rates', "terms_id = 'pt-1'"), 1);

      // A pending trip keeps its own copy and stops.
      await db.rawUpdate(
        "UPDATE pickup_trips SET status = 'ON_ROUTE', sync_state = 'pending' WHERE id = 't-1'",
      );
      await applyPage({
        'tables': {
          'pickup_trips': {
            'upserts': [
              trip(id: 't-1', stops: [stop('p-1', 't-1', 1)]),
            ],
            'deletes': ['t-1'],
          },
        },
      });
      final kept = await db.query('pickup_trips', where: "id = 't-1'");
      expect(kept.single['status'], 'ON_ROUTE');
      expect(await count('trip_stops', "trip_id = 't-1'"), 2);

      // Synced again: a cancelled trip comes with no stops.
      await db.rawUpdate("UPDATE pickup_trips SET sync_state = 'synced'");
      await applyPage({
        'tables': {
          'pickup_trips': {
            'upserts': [trip(id: 't-1', status: 'CANCELLED')],
          },
        },
      });
      expect(await count('trip_stops', "trip_id = 't-1'"), 0);

      // Deletes remove the parent and its children.
      await applyPage({
        'tables': {
          'outbound_sources': {
            'deletes': ['s-p-1'],
          },
        },
      });
      expect(await count('outbound_sources'), 0);
      expect(await count('source_item_rates'), 0);
    });
  });

  group('pickup supervisor', () {
    late OutboundWrites writes;
    late OutboundQueries queries;

    setUp(() async {
      writes = OutboundWrites(
        actor: const OutboundActor(id: _supervisor, name: 'Sunil'),
        database: db,
        clock: _clock,
      );
      queries = OutboundQueries(
        actorId: _supervisor,
        database: db,
        clock: _clock,
      );
      await applyPage({
        'tables': {
          'pickup_trips': {
            'upserts': [
              trip(
                id: 't-1',
                stops: [stop('p-1', 't-1', 1), stop('p-2', 't-1', 2)],
              ),
              trip(
                id: 't-old',
                date: _yesterday,
                status: 'AT_WAREHOUSE',
                stops: [stop('p-old', 't-old', 1, due: _yesterday)],
              ),
            ],
          },
          'due_pickups': {
            'upserts': [
              duePickup('p-1', status: 'PLANNED', tripId: 't-1'),
              duePickup('p-2', status: 'PLANNED', tripId: 't-1'),
              duePickup('p-3'),
              duePickup(
                'p-old',
                status: 'PLANNED',
                tripId: 't-old',
                due: _yesterday,
              ),
            ],
          },
        },
      });
    });

    test('home tiles, missed and stop display states', () async {
      final tiles = await queries.supervisorHomeTiles();
      expect(tiles!['trips_today'], 1);
      expect(tiles['due_today'], 3);
      expect(tiles['missed'], 1);
      final states = await queries.tripStopsWithState('t-old');
      expect(states.single['display_state'], 'MISSED');
      expect((await queries.unassignedPickups()).single['id'], 'p-3');
    });

    test('skip takes the pickup off its trip and queues one item', () async {
      expect(
        () => writes.decidePickup(
          duePickupId: 'p-1',
          action: PickupDecision.skip,
          skipReasons: const ['OTHER'],
        ),
        throwsA(isA<LocalWriteValidationException>()),
      );
      await writes.decidePickup(
        duePickupId: 'p-1',
        action: PickupDecision.skip,
        skipReasons: const ['HOLIDAY'],
      );
      final pickup = (await db.query(
        'due_pickups',
        where: "id = 'p-1'",
      )).single;
      expect(pickup['status'], 'SKIPPED');
      expect(pickup['trip_id'], isNull);
      expect(pickup['sync_state'], 'pending');
      expect(await count('trip_stops', "id = 'p-1'"), 0);
      final item = (await db.query('outbox')).single;
      expect(item['path'], '/due-pickups/p-1/skip');
      expect(jsonDecode(item['body']! as String), {
        'reasons': ['HOLIDAY'],
        'note': null,
      });
    });

    test(
      'route save merges an unsent save and keeps one route per source',
      () async {
        for (final name in ['First', 'Second']) {
          await writes.saveRoute(
            id: 'r-9',
            name: name,
            warehouseId: 'w-1',
            shiftId: 'sh-1',
            vehicleId: 'v-1',
            driverId: _driver,
            sourceIds: const ['s-a', 's-b'],
          );
        }
        expect(await count('outbox', "kind = 'route_save'"), 1);
        final body =
            jsonDecode((await db.query('outbox')).single['body']! as String)
                as Map;
        expect(body['name'], 'Second');
        expect(await count('pickup_route_stops', "route_id = 'r-9'"), 2);
      },
    );

    test('change for today needs a reason when the team changes', () async {
      expect(
        () => writes.changeTripForToday(
          tripId: 't-1',
          team: const TripTeam(vehicleId: 'v-2', driverId: _driver),
          stopIds: const ['p-2', 'p-3'],
        ),
        throwsA(isA<LocalWriteValidationException>()),
      );
      await writes.changeTripForToday(
        tripId: 't-1',
        team: const TripTeam(
          vehicleId: 'v-1',
          driverId: _driver,
          driverName: 'Ravi',
        ),
        stopIds: const ['p-3', 'p-2'],
      );
      final stops = await db.query(
        'trip_stops',
        where: "trip_id = 't-1'",
        orderBy: 'stop_order',
      );
      expect(stops.map((s) => s['id']), ['p-3', 'p-2']);
      final p1 = (await db.query('due_pickups', where: "id = 'p-1'")).single;
      expect(p1['status'], 'DUE');
      expect(p1['trip_id'], isNull);
    });

    test('pay a pickup point is capped by cash and dues', () async {
      await db.setSyncMeta('outbound_cash_balance', '500');
      await db.insert('source_dues', {
        'source_id': 's-1',
        'earned': 300,
        'paid': 0,
        'balance': 300,
      });
      expect(
        () => writes.paySource(
          id: 'pay-1',
          sourceId: 's-1',
          amount: 400,
          method: 'CASH',
          paidOn: _today,
        ),
        throwsA(isA<LocalWriteValidationException>()),
      );
      await writes.paySource(
        id: 'pay-1',
        sourceId: 's-1',
        amount: 200,
        method: 'CASH',
        paidOn: _today,
      );
      expect(await queries.cashInHand(), 300);
      final due = (await db.query('source_dues')).single;
      expect(due['balance'], 100);
    });
  });

  group('driver', () {
    late OutboundWrites writes;
    late OutboundQueries queries;

    setUp(() async {
      writes = OutboundWrites(
        actor: const OutboundActor(
          id: _driver,
          name: 'Ravi',
          phone: '9000000001',
        ),
        database: db,
        clock: _clock,
      );
      queries = OutboundQueries(actorId: _driver, database: db, clock: _clock);
      await applyPage({
        'tables': {
          'pickup_trips': {
            'upserts': [
              trip(
                id: 't-1',
                stops: [stop('p-1', 't-1', 1), stop('p-2', 't-1', 2)],
              ),
            ],
          },
        },
      });
    });

    test(
      'a stop entry starts the trip, counts on Home, hand-over, answer',
      () async {
        await writes.recordStop(
          const StopEntry(
            entryId: 'e-1',
            tripId: 't-1',
            duePickupId: 'p-1',
            outcome: StopOutcome.collected,
            recordedAt: '2026-11-27T04:30:00.000Z',
            photoIds: ['photo-1'],
            lines: [
              EntryLine(
                itemId: 'item-1',
                itemName: 'Paper',
                quantity: 12.5,
                unit: 'KG',
              ),
            ],
          ),
        );
        final home = (await queries.driverHomeTrips()).single;
        expect(home['status'], 'ON_ROUTE');
        expect(home['collected'], 1);
        expect(home['collected_kg'], 12.5);
        expect((await queries.nextStop('t-1'))!['id'], 'p-2');
        final stops = await queries.driverTripStops('t-1');
        expect(stops.first['waiting_to_send'], 1);
        expect(await count('outbox_photos'), 1);

        await writes.handOver(tripId: 't-1', bags: 3);
        expect(await count('trip_stops', "status = 'AT_GATE'"), 1);
        expect(await count('outbox', "entity = 'pickup_trips'"), 2);

        // The server answers the last write: the trip is written and synced.
        await db.runInTransaction((txn) async {
          await txn.delete('outbox_photos');
          await txn.delete('outbox');
          await OutboundSyncApplier.applyAnswer(
            txn,
            entity: 'pickup_trips',
            entityId: 't-1',
            data: {
              'id': 't-1',
              'status': 'AT_WAREHOUSE',
              'bagCount': 3,
              'number': 'SCH-TRP-1',
            },
          );
        });
        final saved = (await db.query(
          'pickup_trips',
          where: "id = 't-1'",
        )).single;
        expect(saved['sync_state'], 'synced');
        expect(saved['number'], 'SCH-TRP-1');
        expect(saved['bag_count'], 3);
      },
    );

    test(
      'collected needs a photo; a correction request is limited by role',
      () async {
        expect(
          () => writes.recordStop(
            const StopEntry(
              entryId: 'e-2',
              tripId: 't-1',
              duePickupId: 'p-2',
              outcome: StopOutcome.collected,
              recordedAt: '2026-11-27T04:30:00.000Z',
            ),
          ),
          throwsA(isA<LocalWriteValidationException>()),
        );
        expect(
          () => writes.askRequest(
            const OutboundRequestDraft(
              id: 'rq-1',
              kind: 'VEHICLE',
              raisedAs: 'DRIVER',
              sendTo: 'SUPERVISOR',
              details: 'x',
            ),
          ),
          throwsA(isA<LocalWriteValidationException>()),
        );
        await writes.askRequest(
          const OutboundRequestDraft(
            id: 'rq-2',
            kind: 'ENTRY_CORRECTION',
            raisedAs: 'DRIVER',
            sendTo: 'SUPERVISOR',
            details: 'Wrong weight',
            tripId: 't-1',
            entryId: 'e-1',
            duePickupId: 'p-1',
            correction: {'totalKg': 10},
          ),
        );
        expect(await queries.correctionRequested('p-1'), isTrue);
      },
    );
  });
}
