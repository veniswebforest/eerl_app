import 'dart:convert';

import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/features/driver/model/driver_pickup_stop.dart';

/// A driver's trip as SQLite holds it (outbound SQLite doc, Driver screens).
class DriverTripLive {
  const DriverTripLive({
    required this.id,
    required this.number,
    required this.tripDate,
    required this.routeName,
    required this.warehouseId,
    required this.warehouseName,
    required this.shiftName,
    required this.shiftStart,
    required this.shiftEnd,
    required this.status,
    required this.vehicle,
    required this.labourName,
    required this.labourPhone,
    required this.startedAt,
    required this.netKg,
    required this.stops,
    required this.collected,
    required this.pending,
    required this.zeroKg,
    required this.cancelled,
    required this.atGate,
    required this.collectedKg,
  });

  factory DriverTripLive.fromRow(Map<String, Object?> row) => DriverTripLive(
    id: row['id']! as String,
    number: row['number'] as String?,
    tripDate: row['trip_date'] as String? ?? '',
    routeName: row['route_name'] as String? ?? '',
    warehouseId: row['warehouse_id'] as String? ?? '',
    warehouseName: row['warehouse_name'] as String? ?? '',
    shiftName: row['shift_name'] as String? ?? '',
    shiftStart: row['shift_start'] as String? ?? '',
    shiftEnd: row['shift_end'] as String? ?? '',
    status: row['status'] as String? ?? 'PLANNED',
    vehicle:
        row['vehicle_plate'] as String? ??
        row['rented_vehicle_number'] as String? ??
        '',
    labourName: row['labour_name'] as String?,
    labourPhone: row['labour_phone'] as String?,
    startedAt: row['started_at'] as String?,
    netKg: (row['net_kg'] as num?)?.toDouble(),
    stops: _int(row['stops']),
    collected: _int(row['collected']),
    pending: _int(row['pending']),
    zeroKg: _int(row['zero_kg']),
    cancelled: _int(row['cancelled']),
    atGate: _int(row['at_gate']),
    collectedKg: (row['collected_kg'] as num?)?.toDouble() ?? 0,
  );

  final String id;
  final String? number;
  final String tripDate;
  final String routeName;
  final String warehouseId;
  final String warehouseName;
  final String shiftName;
  final String shiftStart;
  final String shiftEnd;

  /// PLANNED | ON_ROUTE | AT_WAREHOUSE | CHECKING | APPROVED | CANCELLED.
  final String status;
  final String vehicle;
  final String? labourName;
  final String? labourPhone;
  final String? startedAt;
  final double? netKg;
  final int stops;
  final int collected;
  final int pending;
  final int zeroKg;
  final int cancelled;
  final int atGate;
  final double collectedKg;

  /// Start trip shows until the trip is started.
  bool get started => status != 'PLANNED';

  /// Handed over: the driver records nothing more on it.
  bool get handedOver =>
      status == 'AT_WAREHOUSE' || status == 'CHECKING' || status == 'APPROVED';

  int get done => stops - pending;

  double get progress => stops == 0 ? 0 : done / stops;

  /// "Vehicle · labourer", as the trip card shows the crew.
  String get crew => [
    vehicle,
    if (labourName != null && labourName!.isNotEmpty) labourName!,
  ].where((part) => part.isNotEmpty).join(' · ');
}

/// One stop of a trip, with the pickup point's copy the stop carries.
class DriverStopLive {
  const DriverStopLive({
    required this.id,
    required this.tripId,
    required this.stopOrder,
    required this.totalStops,
    required this.sourceName,
    required this.address,
    required this.windowStart,
    required this.windowEnd,
    required this.contactName,
    required this.contactRole,
    required this.contactPhone,
    required this.materialMode,
    required this.status,
    required this.outcome,
    required this.lat,
    required this.lng,
    required this.expectedQtyKg,
    required this.note,
    required this.totalKg,
    required this.recordedAt,
    required this.waitingToSend,
    required this.entryId,
    required this.entryLines,
    required this.photoUrls,
  });

  factory DriverStopLive.fromRow(
    Map<String, Object?> row, {
    required int totalStops,
  }) => DriverStopLive(
    id: row['id']! as String,
    tripId: row['trip_id'] as String? ?? '',
    stopOrder: _int(row['stop_order']),
    totalStops: totalStops,
    sourceName: row['source_name'] as String? ?? '',
    address: row['source_address'] as String? ?? '',
    windowStart: row['window_start'] as String?,
    windowEnd: row['window_end'] as String?,
    contactName: row['contact_name'] as String?,
    contactRole: row['contact_role'] as String?,
    contactPhone: row['contact_phone'] as String?,
    materialMode: row['material_mode'] as String? ?? 'MIXED',
    status: row['status'] as String? ?? 'PLANNED',
    outcome: row['outcome'] as String?,
    lat: (row['lat'] as num?)?.toDouble(),
    lng: (row['lng'] as num?)?.toDouble(),
    expectedQtyKg: (row['expected_qty_kg'] as num?)?.toDouble(),
    note: row['note'] as String?,
    totalKg: (row['total_kg'] as num?)?.toDouble(),
    recordedAt: row['recorded_at'] as String?,
    waitingToSend: row['waiting_to_send'] == 1,
    entryId: row['entry_id'] as String?,
    entryLines: _jsonList(row['entry_lines']),
    photoUrls: _jsonList(row['photo_urls']).whereType<String>().toList(),
  );

  final String id;
  final String tripId;
  final int stopOrder;
  final int totalStops;
  final String sourceName;
  final String address;
  final String? windowStart;
  final String? windowEnd;
  final String? contactName;
  final String? contactRole;
  final String? contactPhone;

  /// SORTED | MIXED.
  final String materialMode;

  /// PLANNED | AT_GATE | COLLECTED | NOT_COLLECTED | SOURCE_CANCELLED.
  final String status;
  final String? outcome;
  final double? lat;
  final double? lng;
  final double? expectedQtyKg;
  final String? note;
  final double? totalKg;
  final String? recordedAt;
  final bool waitingToSend;
  final String? entryId;
  final List<Object?> entryLines;
  final List<String> photoUrls;

  DriverPickupType get pickupType => materialMode == 'SORTED'
      ? DriverPickupType.sorted
      : DriverPickupType.mixed;

  bool get isOpen => status == 'PLANNED';

  /// "Rakesh · Store manager".
  String get contact => [
    if (contactName != null && contactName!.isNotEmpty) contactName!,
    if (contactRole != null && contactRole!.isNotEmpty) contactRole!,
  ].join(' · ');

  /// The pickup window, or null for any time.
  String? get window => windowStart == null || windowEnd == null
      ? null
      : '${formatClock(windowStart!)} – ${formatClock(windowEnd!)}';
}

/// Everything the driver's Home shows.
class DriverHomeLive {
  const DriverHomeLive({
    required this.trips,
    required this.current,
    required this.nextStop,
    required this.afterStop,
    required this.supervisorName,
    required this.supervisorPhone,
    required this.unsent,
    required this.warehouseName,
    required this.today,
  });

  final List<DriverTripLive> trips;

  /// The trip the driver is on (or about to start): the first not handed
  /// over; null when every trip is done or there is none.
  final DriverTripLive? current;
  final DriverStopLive? nextStop;
  final DriverStopLive? afterStop;
  final String? supervisorName;
  final String? supervisorPhone;
  final int unsent;
  final String? warehouseName;
  final String today;

  int get collected => trips.fold(0, (sum, t) => sum + t.collected);
  int get pending => trips.fold(0, (sum, t) => sum + t.pending);
  int get zeroKg => trips.fold(0, (sum, t) => sum + t.zeroKg);
  int get cancelled => trips.fold(0, (sum, t) => sum + t.cancelled);
  double get collectedKg => trips.fold(0, (sum, t) => sum + t.collectedKg);

  static Future<DriverHomeLive> load(OutboundLiveSession session) async {
    final q = session.queries;
    final trips = (await q.driverHomeTrips())
        .map(DriverTripLive.fromRow)
        .toList(growable: false);
    DriverTripLive? current;
    for (final trip in trips) {
      if (!trip.handedOver) {
        current = trip;
        break;
      }
    }
    DriverStopLive? next;
    DriverStopLive? after;
    if (current != null) {
      final open = (await q.driverTripStops(current.id))
          .where((row) => row['status'] == 'PLANNED')
          .map(
            (row) => DriverStopLive.fromRow({
              ...row,
              'trip_id': current!.id,
            }, totalStops: current.stops),
          )
          .toList();
      if (open.isNotEmpty) next = open.first;
      if (open.length > 1) after = open[1];
    }
    final supervisor = await q.contactSupervisor();
    final warehouse = await q.homeWarehouse();
    return DriverHomeLive(
      trips: trips,
      current: current,
      nextStop: next,
      afterStop: after,
      supervisorName: supervisor?['name'] as String?,
      supervisorPhone: supervisor?['phone'] as String?,
      unsent: await q.unsentChanges(),
      warehouseName: warehouse?['name'] as String?,
      today: session.clock.today,
    );
  }
}

/// A trip's stops, in order (Trip stops).
Future<List<DriverStopLive>> loadDriverTripStops(
  OutboundLiveSession session,
  String tripId,
) async {
  final rows = await session.queries.driverTripStops(tripId);
  return [
    for (final row in rows)
      DriverStopLive.fromRow({
        ...row,
        'trip_id': tripId,
      }, totalStops: rows.length),
  ];
}

/// `HH:MM` (IST) as "8:00 am".
String formatClock(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length < 2) return hhmm;
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = parts[1].padLeft(2, '0');
  final h12 = hour % 12 == 0 ? 12 : hour % 12;
  return '$h12:$minute ${hour < 12 ? 'am' : 'pm'}';
}

/// Weights as the screens show them: no trailing ".0", up to 2 decimals.
String formatKg(double kg) {
  final fixed = kg.toStringAsFixed(2);
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
}

int _int(Object? value) => value is num ? value.toInt() : 0;

List<Object?> _jsonList(Object? value) {
  if (value is! String || value.isEmpty) return const [];
  final decoded = jsonDecode(value);
  return decoded is List ? decoded : const [];
}
