import 'package:flutter/foundation.dart';

/// A driver or labourer offered for one trip.
class TeamPerson {
  const TeamPerson({
    required this.name,
    required this.phoneTail,
    this.freeUntil,
    this.busyWith,
  });

  final String name;

  /// Last four digits, shown as "••• 3310".
  final String phoneTail;

  /// Another trip later that day: (route, time) – free until then.
  final (String, String)? freeUntil;

  /// The trip that clashes: (route, time). Busy people only warn.
  final (String, String)? busyWith;

  bool get busy => busyWith != null;
}

/// Why the team changes for one trip.
enum TeamChangeReason { absent, other }

/// Why stops move to another trip.
enum MoveReason { breakdown, vehicleNotAvailable, driverAbsent, other }

/// A planned trip of the same day and warehouse that can take stops.
class MoveTargetTrip {
  const MoveTargetTrip({
    required this.name,
    required this.plate,
    required this.driver,
    required this.time,
    this.contract = false,
  });

  final String name;
  final String plate;

  /// Driver name, or the transporter for a contract vehicle.
  final String driver;
  final String time;
  final bool contract;
}

/// What the supervisor asks the Collection Head for.
enum AskNeed {
  vehicle,
  labour,
  changeDetails,
  startPickups,
  stopPickups,
  pausePickups;

  bool get forTrip => this == vehicle || this == labour;
}

/// One choice in the "For" sheet: a route, or a pickup point.
class AskTarget {
  const AskTarget({
    required this.name,
    required this.detail,
    this.plate,
    this.contract = false,
    this.time,
  });

  final String name;

  /// Pickup point address (pickup point targets only).
  final String detail;
  final String? plate;
  final bool contract;
  final String? time;

  bool get isRoute => plate != null;
}

/// What a switch on / off on a trip screen tells the Routes tab.
enum RouteSwitchEvent { switchedOff, switchedOn }

/// Static stand-in for the routes' on/off state until the backend lands.
///
/// The Routes tab listens to it; the trip screens change it.
abstract final class RouteSwitchStore {
  static const adajan = 'adajan';
  static const rander = 'rander';

  /// Keys of the routes that are switched off.
  static final off = ValueNotifier<Set<String>>({rander});

  /// The latest change, shown once as a toast on Routes: (route key, event).
  static final event = ValueNotifier<(String, RouteSwitchEvent)?>(null);

  /// Routes switched on during this session go to the top of the list.
  static final switchedOnNow = <String>{};

  static void switchOff(String key) {
    off.value = {...off.value, key};
    switchedOnNow.remove(key);
    event.value = (key, RouteSwitchEvent.switchedOff);
  }

  static void switchOn(String key) {
    off.value = {...off.value}..remove(key);
    switchedOnNow.add(key);
    event.value = (key, RouteSwitchEvent.switchedOn);
  }

  /// Back to the first-launch state (tests).
  static void reset() {
    off.value = {rander};
    event.value = null;
    switchedOnNow.clear();
  }
}
