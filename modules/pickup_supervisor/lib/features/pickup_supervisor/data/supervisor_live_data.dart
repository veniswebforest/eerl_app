import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_models.dart';

/// The collection summary of one period chip, worked out on the phone
/// (outbound doc, Pickup Supervisor screens · Home).
class SupervisorSummaryLive {
  const SupervisorSummaryLive({
    required this.trips,
    required this.stops,
    required this.collected,
    required this.zeroKg,
    required this.atGate,
    required this.cancelled,
    required this.missed,
    required this.kg,
    required this.pieces,
  });

  final int trips;
  final int stops;
  final int collected;
  final int zeroKg;
  final int atGate;
  final int cancelled;
  final int missed;
  final double kg;
  final double pieces;

  static Future<SupervisorSummaryLive> load(
    OutboundLiveSession session, {
    required String from,
    required String to,
  }) async {
    final q = session.queries;
    final row = await q.collectionSummary(from: from, to: to) ?? const {};
    var kg = 0.0;
    var pieces = 0.0;
    for (final unit in await q.collectionSummaryByUnit(from: from, to: to)) {
      final total = (unit['total'] as num?)?.toDouble() ?? 0;
      if (unit['unit'] == 'KG') {
        kg = total;
      } else {
        pieces = total;
      }
    }
    int n(String key) => (row[key] as num?)?.toInt() ?? 0;
    return SupervisorSummaryLive(
      trips: n('trips'),
      stops: n('stops'),
      collected: n('collected'),
      zeroKg: n('zero_kg'),
      atGate: n('at_gate'),
      cancelled: n('cancelled_at_stop'),
      missed: n('missed'),
      kg: kg,
      pieces: pieces,
    );
  }
}

/// One trip card on Home · Today's trips.
class SupervisorTripLive {
  const SupervisorTripLive({
    required this.id,
    required this.routeName,
    required this.shiftName,
    required this.status,
    required this.vehicleKind,
    required this.driverName,
    required this.driverPhone,
    required this.stops,
    required this.collected,
    required this.driverNotUsingApp,
  });

  final String id;
  final String routeName;
  final String shiftName;
  final String status;
  final String vehicleKind;
  final String? driverName;
  final String? driverPhone;
  final int stops;
  final int collected;

  /// Not started 30 minutes after its shift began (own van only).
  final bool driverNotUsingApp;
}

/// Everything the Pickup Supervisor's Home shows.
class SupervisorHomeLive {
  const SupervisorHomeLive({
    required this.approvals,
    required this.openIssues,
    required this.myRequests,
    required this.openFlags,
    required this.tripsToday,
    required this.trips,
    required this.categories,
    required this.unassignedSources,
    required this.unsent,
    required this.areas,
    required this.today,
    required this.summaries,
  });

  final int approvals;
  final int openIssues;
  final int myRequests;
  final int openFlags;
  final int tripsToday;
  final List<SupervisorTripLive> trips;

  /// `pickup_category` → number of Active and Paused pickup points.
  final Map<String?, int> categories;
  final int unassignedSources;
  final int unsent;

  /// The areas the supervisor covers, "Adajan, Vesu, Pal".
  final String areas;
  final DateTime today;

  /// The Today, Yesterday, Week and Month chips.
  final Map<ReportPeriod, SupervisorSummaryLive> summaries;

  static Future<SupervisorHomeLive> load(OutboundLiveSession session) async {
    final q = session.queries;
    final attention = await q.supervisorAttention() ?? const {};
    final tiles = await q.supervisorHomeTiles() ?? const {};
    final notUsing = {
      for (final row in await q.driverNotUsingApp())
        if (row['vehicle_kind'] == 'OWN') row['id'],
    };
    final trips = <SupervisorTripLive>[];
    for (final row in await q.supervisorTripsOfDay(session.clock.today)) {
      if (row['status'] == 'CANCELLED') continue;
      final id = row['id']! as String;
      final stops = await q.tripStopsWithState(id);
      trips.add(
        SupervisorTripLive(
          id: id,
          routeName: row['route_name'] as String? ?? '',
          shiftName: row['shift_name'] as String? ?? '',
          status: row['status'] as String? ?? '',
          vehicleKind: row['vehicle_kind'] as String? ?? 'OWN',
          driverName: row['driver_name'] as String?,
          driverPhone: row['driver_phone'] as String?,
          stops: stops.length,
          collected: stops
              .where((s) => s['display_state'] == 'COLLECTED')
              .length,
          driverNotUsingApp: notUsing.contains(id),
        ),
      );
    }
    final today = DateTime.parse(session.clock.today);
    String day(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
    final ranges = <ReportPeriod, DateTimeRange>{
      ReportPeriod.today: DateTimeRange(start: today, end: today),
      ReportPeriod.yesterday: DateTimeRange(
        start: today.subtract(const Duration(days: 1)),
        end: today.subtract(const Duration(days: 1)),
      ),
      ReportPeriod.week: DateTimeRange(
        start: today.subtract(Duration(days: today.weekday - 1)),
        end: today,
      ),
      ReportPeriod.month: DateTimeRange(
        start: DateTime(today.year, today.month),
        end: today,
      ),
    };
    final summaries = <ReportPeriod, SupervisorSummaryLive>{
      for (final entry in ranges.entries)
        entry.key: await SupervisorSummaryLive.load(
          session,
          from: day(entry.value.start),
          to: day(entry.value.end),
        ),
    };
    final areas = await q.supervisorAreas();
    int n(Map<String, Object?> row, String key) =>
        (row[key] as num?)?.toInt() ?? 0;
    return SupervisorHomeLive(
      approvals: n(attention, 'approvals'),
      openIssues: n(tiles, 'open_issues'),
      myRequests: n(attention, 'my_requests'),
      openFlags: n(tiles, 'open_flags'),
      tripsToday: n(tiles, 'trips_today'),
      trips: trips,
      categories: {
        for (final row in await q.pickupCategoryCounts())
          row['pickup_category'] as String?: n(row, 'n'),
      },
      unassignedSources: (await q.unassignedSources()).length,
      unsent: await q.unsentChanges(),
      areas: areas.map((a) => a['name']).join(', '),
      today: today,
      summaries: summaries,
    );
  }
}
