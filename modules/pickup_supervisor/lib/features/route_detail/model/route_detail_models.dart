enum RouteDetailPeriod { today, next7Days }

enum RouteDetailView { list, map }

enum StopType { sorted, mixed }

enum StopFrequency { daily, weekly }

enum StopStatus {
  collected,
  zeroKg,
  pending,
  nextStop,
  cancelledBySource,
  inactive,
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
}

enum StopNote { noMaterial, closedForStocktaking, pausedForRenovation }

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

  bool matches(StopFilter filter) => switch (filter) {
    StopFilter.all => true,
    StopFilter.collected => status == StopStatus.collected,
    StopFilter.pending =>
      status == StopStatus.pending || status == StopStatus.nextStop,
    StopFilter.zeroKg => status == StopStatus.zeroKg,
    StopFilter.missed => false,
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
}

/// A numbered stop on the map card.
class MapStopPoint {
  const MapStopPoint(this.number, this.left, this.top, this.status);

  final int number;
  final double left;
  final double top;
  final StopStatus status;
}
