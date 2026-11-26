enum RouteDetailPeriod { today, next7Days }

enum RouteDetailView { list, map }

/// Which trip the route detail shows.
///
/// * [onRoute] – started: List | Map, ⋮ on-route actions, no skipping.
/// * [planned] – not started: ⋮ today actions, pending stops can be skipped.
/// * [approved] – done and approved: read only, shows the warehouse result.
enum TripState { onRoute, planned, approved }

enum StopType { sorted, mixed }

enum StopFrequency { daily, weekly, monthly, onCall }

enum StopStatus {
  collected,
  zeroKg,
  pending,
  nextStop,
  cancelledBySource,
  inactive,
  missed,
}

/// Filter pills above the stop list. Pending includes the next stop.
enum StopFilter { all, collected, pending, zeroKg, missed, cancelled, inactive }

enum StopScheduleKind {
  everyDay,
  days,
  exceptSunday,
  secondWednesday,
  once,
  pausedTill,
  firstOfMonth,

  /// On-call pickup booked for today ("Called in · today 2–4 pm").
  calledIn,

  /// "Every day except Sun · 12–2 pm".
  everyDayExceptSun,
}

enum StopNote {
  noMaterial,
  closedForStocktaking,
  pausedForRenovation,
  notRecordedByDriver,
  noMaterialPerDriver,
  askedToSkipToday,
}

enum ContactRole { manager, owner, storeManager, office }

/// Person at the pickup point.
class StopContact {
  const StopContact(this.name, this.role, this.phone);

  final String name;
  final ContactRole role;
  final String phone;
}

class StopSchedule {
  const StopSchedule(
    this.kind, {
    this.time = '',
    this.date = '',
    this.days = const [],
  });

  final StopScheduleKind kind;
  final String time;
  final String date;

  /// For [StopScheduleKind.days]: 1 = Monday … 7 = Sunday.
  final List<int> days;
}

class RouteStop {
  const RouteStop({
    required this.name,
    required this.type,
    required this.address,
    required this.schedule,
    required this.status,
    this.frequency,
    this.amountKg,
    this.amountPcs,
    this.note,
    this.collectedAt,
    this.visitedAt,
    this.voiceNote,
    this.hasDriverNote = false,
    this.gateEntryAt,
    this.nextVisits,
    this.visitsThisWeek,
    this.contact,
    this.distanceKm,
    this.record,
  });

  final String name;
  final StopType type;
  final String address;
  final StopSchedule schedule;
  final StopStatus status;
  final StopFrequency? frequency;
  final String? amountKg;
  final String? amountPcs;
  final StopNote? note;
  final String? collectedAt;
  final String? visitedAt;
  final String? voiceNote;
  final bool hasDriverNote;

  /// Approved trips: when the stop's load was entered at the warehouse gate.
  final String? gateEntryAt;

  /// Next 7 Days: the coming visit dates ("Mon 26, Thu 29 Oct") …
  final String? nextVisits;

  /// … or, for a daily stop, how many visits in the week.
  final int? visitsThisWeek;

  final StopContact? contact;

  /// Next stop: distance from the last stop.
  final String? distanceKm;

  /// What was recorded at the stop (collected, 0 kg, missed, cancelled,
  /// paused); shown on the stop detail.
  final StopRecord? record;

  RouteStop copyWith({String? name, StopStatus? status}) => RouteStop(
    name: name ?? this.name,
    type: type,
    address: address,
    schedule: schedule,
    status: status ?? this.status,
    frequency: frequency,
    amountKg: amountKg,
    amountPcs: amountPcs,
    note: note,
    collectedAt: collectedAt,
    visitedAt: visitedAt,
    voiceNote: voiceNote,
    hasDriverNote: hasDriverNote,
    gateEntryAt: gateEntryAt,
    nextVisits: nextVisits,
    visitsThisWeek: visitsThisWeek,
    contact: contact,
    distanceKm: distanceKm,
    record: record,
  );

  bool matches(StopFilter filter) => switch (filter) {
    StopFilter.all => true,
    StopFilter.collected => status == StopStatus.collected,
    StopFilter.pending =>
      status == StopStatus.pending || status == StopStatus.nextStop,
    StopFilter.zeroKg => status == StopStatus.zeroKg,
    StopFilter.missed => status == StopStatus.missed,
    StopFilter.cancelled => status == StopStatus.cancelledBySource,
    StopFilter.inactive => status == StopStatus.inactive,
  };
}

/// The route summary card shown at the top of every state.
class RouteSummary {
  const RouteSummary({
    required this.name,
    required this.plate,
    required this.shiftTime,
    required this.assignedSources,
    required this.pausedSources,
    required this.warehouse,
    required this.driverName,
    required this.driverPhone,
    required this.labourName,
    required this.daily,
    required this.weekly,
    this.onCall = 0,
    this.monthly = 0,
    this.contractVehicle = false,
    this.startedAt,
    this.biWeekly = 0,
    this.shift = RouteShift.morning,
  });

  final String name;
  final String plate;
  final String shiftTime;
  final int assignedSources;
  final int pausedSources;
  final String warehouse;
  final String driverName;
  final String driverPhone;
  final String labourName;
  final int daily;
  final int weekly;
  final int onCall;
  final int monthly;
  final bool contractVehicle;

  /// On-route trips: when the driver started the trip.
  final String? startedAt;
  final int biWeekly;
  final RouteShift shift;

  /// Empty when the trip has no labourer.
  bool get hasLabour => labourName.isNotEmpty;
}

/// Which shift label the header uses ("Morning (…)", "Evening (…)").
enum RouteShift { morning, evening }

/// A driver swap for one trip ("Changed for today").
class TripTeamChange {
  const TripTeamChange({required this.driver, required this.replaces});

  final String driver;

  /// The route's own driver, absent for this trip.
  final String replaces;
}

/// What the header badge shows instead of the trip state.
enum TripBadge {
  cancelled,
  switchedOff,

  /// The shift started but the driver's app recorded nothing ("Planned").
  notStarted,
}

/// What the warehouse recorded for an approved trip.
class WarehouseResult {
  const WarehouseResult({
    required this.netKg,
    required this.driverKg,
    required this.differenceKg,
    required this.differencePct,
    required this.bags,
    required this.approvedBy,
    required this.approvedAt,
  });

  final String netKg;
  final String driverKg;
  final String differenceKg;
  final String differencePct;
  final int bags;
  final String approvedBy;
  final String approvedAt;
}

/// A numbered stop on the map card.
class MapStopPoint {
  const MapStopPoint(this.number, this.left, this.top, this.status);

  final int number;
  final double left;
  final double top;
  final StopStatus status;
}

enum CollectedUnit { kg, pcs }

/// One material in "Collected items".
class CollectedItem {
  const CollectedItem({
    required this.name,
    required this.unit,
    required this.amount,
    required this.thumb,
    required this.photos,
  });

  final String name;
  final CollectedUnit unit;

  /// As shown in the box, e.g. "270.00" or "25".
  final String amount;
  final String thumb;
  final List<String> photos;
}

/// How the visit was entered.
enum EntrySource { app, gate }

/// Details recorded for a visited, missed, cancelled or paused stop (mock).
class StopRecord {
  const StopRecord({
    this.time = '',
    this.date = '',
    this.fromSlip = false,
    this.entry = EntrySource.app,
    this.enteredBy = '',
    this.enteredAt = '',
    this.gps,
    this.gpsDistanceM,
    this.note,
    this.voice,
    this.hasPhoto = false,
    this.items = const [],
    this.totalKg,
    this.totalPcs,
    this.warehouse = '',
    this.reachedAt = '',
    this.driverPhone = '',
    this.calledOffBy = '',
    this.calledOffAt = '',
    this.nextPickup = '',
    this.pausedRange = '',
    this.askedOn = '',
    this.regularSchedule,
  });

  // Visit (collected / 0 kg).
  final String time;
  final String date;

  /// Gate entries take the collected time from the driver's slip.
  final bool fromSlip;
  final EntrySource entry;
  final String enteredBy;
  final String enteredAt;
  final String? gps;
  final String? gpsDistanceM;
  final String? note;
  final String? voice;
  final bool hasPhoto;
  final List<CollectedItem> items;
  final String? totalKg;
  final String? totalPcs;

  // Missed.
  final String warehouse;
  final String reachedAt;
  final String driverPhone;

  // Cancelled by source.
  final String calledOffBy;
  final String calledOffAt;
  final String nextPickup;

  // Paused (inactive).
  final String pausedRange;
  final String askedOn;

  /// The stop's usual schedule while the list shows "Paused till …".
  final StopSchedule? regularSchedule;
}
