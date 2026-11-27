import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/features/driver/data/driver_live_data.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// One trip as the Pickup Supervisor's Trip details shows it, from SQLite
/// (outbound doc, Pickup Supervisor screens · Trip Details).
class LiveTripDetail {
  const LiveTripDetail({
    required this.tripId,
    required this.routeId,
    required this.tripDate,
    required this.tripDateLabel,
    required this.status,
    required this.state,
    required this.summary,
    required this.stops,
    required this.cancelReason,
    required this.driverNotUsingApp,
    required this.routeActive,
    required this.changedForToday,
    required this.warehouseResult,
  });

  /// An approved trip's weighbridge result; null before approval.
  final WarehouseResult? warehouseResult;

  final String tripId;
  final String routeId;

  /// `YYYY-MM-DD`.
  final String tripDate;

  /// "Fri 27 Nov".
  final String tripDateLabel;

  /// PLANNED | ON_ROUTE | AT_WAREHOUSE | CHECKING | APPROVED | CANCELLED.
  final String status;
  final TripState state;
  final RouteSummary summary;
  final List<RouteStop> stops;
  final String? cancelReason;
  final bool driverNotUsingApp;
  final bool routeActive;
  final bool changedForToday;

  static Future<LiveTripDetail?> load(
    OutboundLiveSession session,
    String tripId,
    DriverLocalizations l10n,
  ) async {
    final q = session.queries;
    final trip = await q.driverTrip(tripId);
    if (trip == null) return null;
    final routeId = trip['route_id']! as String;
    final tripDate = trip['trip_date'] as String? ?? session.clock.today;
    final status = trip['status'] as String? ?? 'PLANNED';

    // The stops with their display state, the pickups the source called off
    // ahead of the day, and the route's paused or switched-off points.
    final stopRows = await q.tripStopsWithState(tripId);
    final cancelledAhead = await q.tripCancelledBySource(tripId);
    final inactive = await q.tripInactiveSources(tripId);
    final categories = <String?, int>{
      for (final row in await q.tripCategoryCounts(tripId))
        row['pickup_category'] as String?: (row['stops'] as num?)?.toInt() ?? 0,
    };
    final routeSources = await q.routeSources(routeId);
    final routeCards = await q.routeCards();
    final route = routeCards.where((r) => r['id'] == routeId).firstOrNull;
    final notUsing = (await q.driverNotUsingApp()).any(
      (row) => row['id'] == tripId && row['vehicle_kind'] == 'OWN',
    );

    var nextMarked = false;
    final stops = <RouteStop>[];
    for (final row in stopRows) {
      final state = row['display_state'] as String?;
      var stopStatus = switch (state) {
        'COLLECTED' => StopStatus.collected,
        'ZERO_KG' => StopStatus.zeroKg,
        'MISSED' => StopStatus.missed,
        'SOURCE_CANCELLED' => StopStatus.cancelledBySource,
        _ => StopStatus.pending,
      };
      // The next stop only on a trip under way.
      if (state == 'PENDING' && status == 'ON_ROUTE' && !nextMarked) {
        stopStatus = StopStatus.nextStop;
        nextMarked = true;
      }
      final summary = (await q.stopDetail(
        row['id']! as String,
      ))?['schedule_summary'];
      stops.add(
        RouteStop(
          id: row['id']! as String,
          name: row['source_name'] as String? ?? '',
          type: row['material_mode'] == 'SORTED'
              ? StopType.sorted
              : StopType.mixed,
          address: row['source_address'] as String? ?? '',
          schedule: StopSchedule(
            StopScheduleKind.text,
            time: summary as String? ?? _window(row) ?? '',
          ),
          status: stopStatus,
          amountKg: stopStatus == StopStatus.collected
              ? formatKg(_kg(row))
              : null,
          noteText: state == 'AT_GATE'
              ? l10n.liveAtGate
              : reasonLabel(
                  l10n,
                  (row['zero_kg_reason'] ?? row['source_cancel_reason'])
                      as String?,
                ),
          contact: row['contact_name'] == null
              ? null
              : StopContact(
                  row['contact_name']! as String,
                  ContactRole.manager,
                  row['contact_phone'] as String? ?? '',
                  roleText: row['contact_role'] as String?,
                ),
        ),
      );
    }
    for (final row in cancelledAhead) {
      stops.add(
        RouteStop(
          id: row['id']! as String,
          name: row['source_name'] as String? ?? '',
          type: StopType.mixed,
          address: '',
          schedule: const StopSchedule(StopScheduleKind.text),
          status: StopStatus.cancelledBySource,
          noteText:
              row['source_cancel_note'] as String? ??
              reasonLabel(l10n, row['source_cancel_reason'] as String?),
        ),
      );
    }
    for (final row in inactive) {
      stops.add(
        RouteStop(
          name: row['name'] as String? ?? '',
          type: StopType.mixed,
          address: '',
          schedule: StopSchedule(
            StopScheduleKind.text,
            time: row['paused_until'] == null
                ? ''
                : l10n.rdSchedPausedTill(row['paused_until']! as String),
          ),
          status: StopStatus.inactive,
        ),
      );
    }

    final shiftStart = trip['shift_start'] as String? ?? '';
    final contract = trip['vehicle_kind'] == 'CONTRACT';
    final day = DateTime.tryParse(tripDate) ?? DateTime.now();
    return LiveTripDetail(
      tripId: tripId,
      routeId: routeId,
      tripDate: tripDate,
      tripDateLabel: DateFormat('EEE d MMM').format(day),
      status: status,
      state: switch (status) {
        'PLANNED' || 'CANCELLED' => TripState.planned,
        'APPROVED' => TripState.approved,
        _ => TripState.onRoute,
      },
      summary: RouteSummary(
        name: trip['route_name'] as String? ?? '',
        plate:
            (contract ? trip['rented_vehicle_number'] : trip['vehicle_plate'])
                as String? ??
            '',
        shiftTime:
            '${formatClock(shiftStart)} – ${formatClock(trip['shift_end'] as String? ?? '')}',
        assignedSources: routeSources.length,
        pausedSources: inactive.length,
        warehouse: trip['warehouse_name'] as String? ?? '',
        driverName:
            (trip['driver_name'] ?? trip['rented_driver_name']) as String? ??
            '',
        driverPhone:
            (trip['driver_phone'] ?? trip['rented_driver_phone']) as String? ??
            '',
        labourName: trip['labour_name'] as String? ?? '',
        daily: categories['DAILY'] ?? 0,
        weekly: categories['WEEKLY'] ?? 0,
        biWeekly: categories['BI_WEEKLY'] ?? 0,
        monthly: categories['MONTHLY'] ?? 0,
        onCall: categories['ON_CALL'] ?? 0,
        contractVehicle: contract,
        startedAt: trip['started_at'] == null
            ? null
            : _clock(trip['started_at']! as String),
        shift: (int.tryParse(shiftStart.split(':').first) ?? 0) >= 12
            ? RouteShift.evening
            : RouteShift.morning,
      ),
      stops: stops,
      cancelReason: status == 'CANCELLED'
          ? (trip['cancel_reason'] as String? ?? '')
          : null,
      driverNotUsingApp: notUsing,
      routeActive: (route?['is_active'] as num?) != 0,
      changedForToday: trip['changed_for_today'] == 1,
      warehouseResult: status != 'APPROVED'
          ? null
          : WarehouseResult(
              netKg: formatKg((trip['net_kg'] as num?)?.toDouble() ?? 0),
              driverKg: formatKg((trip['driver_kg'] as num?)?.toDouble() ?? 0),
              differenceKg: formatKg(
                (trip['variance_kg'] as num?)?.toDouble() ?? 0,
              ),
              differencePct: formatKg(
                (trip['variance_pct'] as num?)?.toDouble() ?? 0,
              ),
              bags: (trip['bags_received'] as num?)?.toInt() ?? 0,
              approvedBy: trip['approved_by_name'] as String? ?? '',
              approvedAt: trip['approved_at'] == null
                  ? ''
                  : _clock(trip['approved_at']! as String),
            ),
    );
  }
}

/// A 0 kg or Cancelled by source reason code in words.
String? reasonLabel(DriverLocalizations l10n, String? code) => switch (code) {
  null => null,
  'CLOSED' => l10n.reasonClosed,
  'NO_MATERIAL' => l10n.noMaterialToday,
  'REFUSED' => l10n.reasonRefused,
  'NOT_REACHABLE' => l10n.reasonNotReachable,
  'VEHICLE_FULL' => l10n.reasonVehicleFull,
  'HOLIDAY' => l10n.liveReasonHoliday,
  'SHIFTED' => l10n.liveReasonShifted,
  _ => l10n.otherIssue,
};

String? _window(Map<String, Object?> row) {
  final start = row['window_start'] as String?;
  final end = row['window_end'] as String?;
  if (start == null || end == null) return null;
  return '${formatClock(start)} – ${formatClock(end)}';
}

double _kg(Map<String, Object?> row) {
  final total = (row['total_kg'] as num?)?.toDouble();
  if (total != null) return total;
  final raw = row['entry_lines'];
  if (raw is! String) return 0;
  var kg = 0.0;
  for (final line in (jsonDecode(raw) as List).whereType<Map>()) {
    if (line['unit'] == 'KG') kg += (line['quantity'] as num?)?.toDouble() ?? 0;
  }
  return kg;
}

/// An ISO time as the IST clock, "8:05 am".
String _clock(String iso) {
  final at = DateTime.tryParse(iso);
  if (at == null) return '';
  final ist = at.toUtc().add(const Duration(hours: 5, minutes: 30));
  return formatClock(
    '${ist.hour.toString().padLeft(2, '0')}:${ist.minute.toString().padLeft(2, '0')}',
  );
}
