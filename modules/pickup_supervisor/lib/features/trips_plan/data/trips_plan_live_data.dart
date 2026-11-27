import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/features/driver/data/driver_live_data.dart';
import 'package:pickup_supervisor/features/trips_plan/model/trips_plan_models.dart';

/// Trips plan · Today and Tomorrow from SQLite (outbound doc, Pickup
/// Supervisor screens · Trips Plan). Later days are the online plan.
class LiveTripsPlan {
  const LiveTripsPlan({required this.today, required this.tomorrow});

  final List<TripPlanTrip> today;
  final List<TripPlanTrip> tomorrow;

  int stopsOf(List<TripPlanTrip> trips) =>
      trips.fold(0, (sum, t) => sum + t.schedule.stops);

  static Future<LiveTripsPlan> load(OutboundLiveSession session) async =>
      LiveTripsPlan(
        today: await _day(session, session.clock.today),
        tomorrow: await _day(session, session.clock.tomorrow),
      );

  static Future<List<TripPlanTrip>> _day(
    OutboundLiveSession session,
    String day,
  ) async {
    final q = session.queries;
    final notUsing = {
      for (final row in await q.driverNotUsingApp())
        if (row['vehicle_kind'] == 'OWN') row['id'],
    };
    final trips = <TripPlanTrip>[];
    for (final row in await q.tripsPlan(day)) {
      final id = row['id']! as String;
      final categories = <String?, int>{
        for (final c in await q.tripCategoryCounts(id))
          c['pickup_category'] as String?: (c['stops'] as num?)?.toInt() ?? 0,
      };
      final inactive = (await q.tripInactiveSources(id)).length;
      final stops = (row['stops'] as num?)?.toInt() ?? 0;
      final collected = (row['collected'] as num?)?.toInt() ?? 0;
      final status = row['status'] as String?;
      final contract = row['vehicle_kind'] == 'CONTRACT';
      final kg = (row['kg'] as num?)?.toDouble() ?? 0;
      trips.add(
        TripPlanTrip(
          id: id,
          name: row['route_name'] as String? ?? '',
          time:
              '${formatClock(row['shift_start'] as String? ?? '')} – '
              '${formatClock(row['shift_end'] as String? ?? '')}',
          status: switch (status) {
            'PLANNED' => TripStatus.planned,
            'APPROVED' => TripStatus.approved,
            _ => TripStatus.onRoute,
          },
          vehicleKind: contract
              ? TripVehicleKind.contract
              : TripVehicleKind.own,
          plate: row['vehicle'] as String? ?? '',
          crew: TripCrew(
            driver: row['driver_name'] as String? ?? '',
            helper: row['labour_name'] as String?,
            transporter: contract ? row['transporter_name'] as String? : null,
          ),
          schedule: TripSchedule(
            stops: stops,
            daily: categories['DAILY'] ?? 0,
            weekly: categories['WEEKLY'] ?? 0,
            biWeekly: categories['BI_WEEKLY'] ?? 0,
            monthly: categories['MONTHLY'] ?? 0,
            onCall: categories['ON_CALL'] ?? 0,
            paused: inactive,
          ),
          alert: notUsing.contains(id)
              ? TripAlert.driverNotUsingApp
              : row['changed_for_today'] == 1
              ? TripAlert.changedForToday
              : null,
          progress: status == 'PLANNED'
              ? null
              : TripProgress(TripProgressKind.collectedOf, collected, stops),
          weightKg: status == 'PLANNED' ? null : formatKg(kg),
        ),
      );
    }
    return trips;
  }
}
