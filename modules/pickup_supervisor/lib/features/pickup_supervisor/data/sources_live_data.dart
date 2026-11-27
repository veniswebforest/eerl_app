import 'package:eerl_app/features/outbound/data/outbound_writes.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/features/driver/data/driver_live_data.dart';

/// A pickup point as Unassigned and Pickup point detail show it.
class LiveSource {
  const LiveSource({
    required this.id,
    required this.name,
    required this.mixed,
    required this.address,
    required this.schedule,
    required this.phone,
    required this.items,
  });

  final String id;
  final String name;
  final bool mixed;
  final String address;
  final String schedule;
  final String phone;
  final List<String> items;

  static Future<LiveSource?> load(
    OutboundLiveSession session,
    String sourceId,
  ) async {
    final q = session.queries;
    final row = await q.pickupPointDetail(sourceId);
    if (row == null) return null;
    final schedule = await q.scheduleInForce(sourceId);
    return LiveSource(
      id: sourceId,
      name: row['name'] as String? ?? '',
      mixed: row['material_mode'] != 'SORTED',
      address: row['address'] as String? ?? '',
      schedule: schedule?['summary'] as String? ?? '',
      phone: row['contact_phone'] as String? ?? '',
      items: [
        for (final i in await q.sourceItems(sourceId))
          i['name'] as String? ?? '',
      ],
    );
  }
}

/// A pickup due today or tomorrow on no trip.
class LiveUnassignedPickup {
  const LiveUnassignedPickup({
    required this.id,
    required this.sourceId,
    required this.name,
    required this.when,
    required this.extra,
  });

  final String id;
  final String sourceId;
  final String name;

  /// "2026-11-27 · 8:00 am – 10:00 am".
  final String when;
  final bool extra;
}

/// Unassigned: your Active and Paused pickup points on no active route,
/// and today's and tomorrow's Due pickups on no trip (outbound doc,
/// Unassigned).
class LiveUnassigned {
  const LiveUnassigned({required this.sources, required this.pickups});

  final List<LiveSource> sources;
  final List<LiveUnassignedPickup> pickups;

  static Future<LiveUnassigned> load(OutboundLiveSession session) async {
    final q = session.queries;
    final sources = <LiveSource>[];
    for (final row in await q.unassignedSources()) {
      final source = await LiveSource.load(session, row['id']! as String);
      if (source != null) sources.add(source);
    }
    return LiveUnassigned(
      sources: sources,
      pickups: [
        for (final p in await q.unassignedPickups())
          LiveUnassignedPickup(
            id: p['id']! as String,
            sourceId: p['source_id'] as String? ?? '',
            name: p['source_name'] as String? ?? '',
            when: [
              p['due_date'] as String? ?? '',
              if (p['window_start'] != null && p['window_end'] != null)
                '${formatClock(p['window_start']! as String)} – '
                    '${formatClock(p['window_end']! as String)}',
            ].join(' · '),
            extra: p['origin'] == 'EXTRA',
          ),
      ],
    );
  }
}

/// A route the pickup point can be added to.
class LiveRouteChoice {
  const LiveRouteChoice({
    required this.id,
    required this.name,
    required this.vehicle,
    required this.time,
    required this.sources,
  });

  final String id;
  final String name;
  final String vehicle;
  final String time;
  final int sources;

  static Future<List<LiveRouteChoice>> loadActive(
    OutboundLiveSession session,
  ) async => [
    for (final r in await session.queries.routeCards())
      if (r['is_active'] == 1)
        LiveRouteChoice(
          id: r['id']! as String,
          name: r['name'] as String? ?? '',
          vehicle: r['vehicle'] as String? ?? '',
          time:
              '${formatClock(r['start_time'] as String? ?? '')} – '
              '${formatClock(r['end_time'] as String? ?? '')}',
          sources: (r['sources'] as num?)?.toInt() ?? 0,
        ),
  ];
}

/// Assign to a route: the whole route is saved again with the pickup point
/// added last (outbound doc, Pickup Supervisor writes · Save a route). A
/// pickup point is on one route at a time, so it leaves any other route.
Future<void> addSourceToRoute(
  OutboundLiveSession session, {
  required String routeId,
  required String sourceId,
}) async {
  final q = session.queries;
  final route = await q.route(routeId);
  if (route == null) return;
  final sourceIds = [
    for (final s in await q.routeSources(routeId))
      if (s['id'] != sourceId) s['id']! as String,
    sourceId,
  ];
  final rented = route['vehicle_kind'] == 'CONTRACT';
  await session.change(
    () => session.writes.saveRoute(
      id: routeId,
      name: route['name'] as String? ?? '',
      warehouseId: route['warehouse_id']! as String,
      shiftId: route['shift_id']! as String,
      sourceIds: sourceIds,
      vehicleId: route['vehicle_id'] as String?,
      driverId: route['driver_id'] as String?,
      labourId: route['labour_id'] as String?,
      rented: rented
          ? RentedVehicle(
              vehicleNumber: route['rented_vehicle_number'] as String? ?? '',
              transporterName: route['transporter_name'] as String?,
              driverName: route['rented_driver_name'] as String?,
              driverPhone: route['rented_driver_phone'] as String?,
              capacityKg: (route['rented_capacity_kg'] as num?)?.toDouble(),
            )
          : null,
    ),
  );
}
