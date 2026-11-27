enum TripsPlanChoice { today, tomorrow, week, date }

/// [expected] is a day after tomorrow: trips are made the day before.
enum TripStatus { onRoute, approved, planned, expected }

enum TripVehicleKind { own, contract }

enum TripAlert { changedForToday, driverNotUsingApp }

enum TripProgressKind { collectedOf, recordedOf, collectedMissed }

/// Who is driving: an own driver (with helper, optionally covering for
/// someone) or a contract transporter's driver.
class TripCrew {
  const TripCrew({
    required this.driver,
    this.helper,
    this.coveringFor,
    this.transporter,
  });

  final String driver;
  final String? helper;
  final String? coveringFor;
  final String? transporter;
}

/// Stop and frequency counts shown in the grey info box.
class TripSchedule {
  const TripSchedule({
    required this.stops,
    this.daily = 0,
    this.weekly = 0,
    this.monthly = 0,
    this.biWeekly = 0,
    this.onCall = 0,
    this.paused = 0,
    this.extra = 0,
  });

  final int stops;
  final int daily;
  final int weekly;
  final int monthly;
  final int biWeekly;
  final int onCall;
  final int paused;

  /// Extra pickups added to the route that day.
  final int extra;
}

class TripProgress {
  const TripProgress(this.kind, this.first, this.second);

  final TripProgressKind kind;
  final int first;
  final int second;
}

class TripPlanTrip {
  const TripPlanTrip({
    this.id,
    required this.name,
    required this.time,
    required this.status,
    required this.vehicleKind,
    required this.plate,
    required this.crew,
    required this.schedule,
    this.alert,
    this.progress,
    this.weightKg,
  });

  /// The live trip id; null in the design samples.
  final String? id;
  final String name;
  final String time;
  final TripStatus status;
  final TripVehicleKind vehicleKind;
  final String plate;
  final TripCrew crew;
  final TripSchedule schedule;
  final TripAlert? alert;
  final TripProgress? progress;
  final String? weightKg;
}

/// One row of the "This week" overview.
class TripsPlanDay {
  const TripsPlanDay({
    required this.dayIndex,
    required this.trips,
    required this.stops,
    required this.ownVehicles,
    required this.contractVehicles,
    this.extraPickups = 0,
    this.pausedSources = 0,
    this.closed = false,
  });

  /// Days from today: 0 = Thu 22 Oct (today), 1 = tomorrow, …
  final int dayIndex;

  /// Warehouse holiday: no trips that day.
  final bool closed;
  final int trips;
  final int stops;
  final int ownVehicles;
  final int contractVehicles;
  final int extraPickups;
  final int pausedSources;
}
