import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// What raised a flag (PS-M06).
enum PickupSupervisorFlagDetailType {
  /// A saved route reaches a stop after its pickup window.
  timeClash,

  /// A stop is more than 2 km off its route.
  offRoute,

  /// A schedule change was approved.
  scheduleChanged,

  /// A pause was approved.
  sourcePaused,

  /// Closes by itself once the point is on a route.
  newSource,

  /// Closes by itself once the point is on a route.
  extraPickup,

  /// An area change moved a pickup point to you.
  sourceMoved,
}

/// The follow-up button beside Mark done.
enum FlagAction { openRoutes, checkRoute, addToRoute }

/// A flag with its texts already localised.
class PickupFlag {
  const PickupFlag({
    required this.type,
    required this.name,
    required this.address,
    required this.summary,
    required this.title,
    required this.rows,
    required this.whatToDo,
    required this.action,
    this.closesByItself = false,
  });

  final PickupSupervisorFlagDetailType type;
  final String name;
  final String address;

  /// One line on the Flags list ("Time clash · gets there about …").
  final String summary;

  /// Detail screen title ("Time clash").
  final String title;

  /// (label, value) rows in the grey box.
  final List<(String, String)> rows;
  final String whatToDo;
  final FlagAction action;
  final bool closesByItself;

  /// Icon file and tile colour on the list.
  (String, Color) get icon => switch (type) {
    PickupSupervisorFlagDetailType.timeClash => (
      'type_clock',
      DriverColors.flagAmberTile,
    ),
    PickupSupervisorFlagDetailType.offRoute => (
      'type_pin',
      DriverColors.flagAmberTile,
    ),
    PickupSupervisorFlagDetailType.scheduleChanged => (
      'type_cal',
      DriverColors.flagBlueTile,
    ),
    PickupSupervisorFlagDetailType.sourcePaused => (
      'type_pause',
      DriverColors.tagGrey,
    ),
    PickupSupervisorFlagDetailType.newSource => (
      'type_route',
      DriverColors.red50,
    ),
    PickupSupervisorFlagDetailType.extraPickup => (
      'type_calplus',
      DriverColors.red50,
    ),
    PickupSupervisorFlagDetailType.sourceMoved => (
      'type_swap',
      DriverColors.primary50,
    ),
  };
}

/// Mock flags until they come from SQLite, in the Figma order.
abstract final class PickupFlagsMockData {
  static const _adajan = 'Adajan Morning';

  /// "Mon, Thu" in the current language (1 = Monday).
  static String _days(DriverLocalizations l10n, List<int> days) =>
      days.map((d) => l10n.calWeekdayShort('$d')).join(', ');

  static List<PickupFlag> all(DriverLocalizations l10n) => [
    PickupFlag(
      type: PickupSupervisorFlagDetailType.timeClash,
      name: 'Hotel Rajdhani',
      address: 'Station Road, Adajan',
      summary: l10n.fgTimeClashLine('1:30 pm', '1 pm'),
      title: l10n.fgTimeClash,
      rows: [
        (l10n.fgRoute, l10n.fgRouteVehicle(_adajan, 'GJ-05-BX-1234')),
        (l10n.fgPickupWindow, l10n.rdSchedEveryDay('11 am – 1 pm')),
        (l10n.fgTripGetsThere, l10n.fgArrivalLate('1:30 pm', '30')),
      ],
      whatToDo: l10n.fgDoTimeClash,
      action: FlagAction.openRoutes,
    ),
    PickupFlag(
      type: PickupSupervisorFlagDetailType.offRoute,
      name: 'Sunrise School',
      address: 'Kumbharia Road, Punagam',
      summary: l10n.fgOffRouteLine('4.2', 'Punagam FullDay'),
      title: l10n.fgOffRoute,
      rows: [
        (l10n.fgRoute, l10n.fgRouteVehicle('Punagam FullDay', 'GJ-05-EE-1002')),
        (l10n.fgDistance, l10n.fgKmOffRoute('4.2')),
        (l10n.fgExtraTime, l10n.fgMinutesMore('20')),
      ],
      whatToDo: l10n.fgDoOffRoute,
      action: FlagAction.openRoutes,
    ),
    PickupFlag(
      type: PickupSupervisorFlagDetailType.scheduleChanged,
      name: 'ABC Textile Mills',
      address: 'U 9, 10, Siddhgiri Tower, Adajan',
      summary: l10n.fgScheduleLine('${_days(l10n, [1, 3])} 9–11 am'),
      title: l10n.fgScheduleChanged,
      rows: [
        (l10n.fgWas, l10n.rdSchedDays(_days(l10n, [1, 4]), '8–10 am')),
        (l10n.fgNow, l10n.rdSchedDays(_days(l10n, [1, 3]), '9–11 am')),
        (l10n.fgFrom, 'Mon 2 Nov'),
        (l10n.fgRoute, _adajan),
      ],
      whatToDo: l10n.fgDoSchedule(_adajan),
      action: FlagAction.checkRoute,
    ),
    PickupFlag(
      type: PickupSupervisorFlagDetailType.sourcePaused,
      name: 'Sai Kirana Store',
      address: 'Gaurav Path, Adajan',
      summary: l10n.fgPausedLine('20 – 30 Oct', l10n.fgReasonRenovationLower),
      title: l10n.fgSourcePaused,
      rows: [
        (l10n.fgPaused, '20 – 30 Oct'),
        (l10n.fgReason, l10n.fgReasonRenovation),
        (l10n.fgRoute, _adajan),
      ],
      whatToDo: l10n.fgDoPaused('Thu 5 Nov'),
      action: FlagAction.checkRoute,
    ),
    PickupFlag(
      type: PickupSupervisorFlagDetailType.newSource,
      name: 'Patel Packaging',
      address: 'Plot 42, GIDC, Pandesara',
      summary: l10n.fgNewSourceLine,
      title: l10n.fgNewSource,
      rows: [
        (l10n.fgSchedule, l10n.fgSecondWed('10–11 am')),
        (l10n.fgRoute, l10n.fgNoneYet),
      ],
      whatToDo: l10n.fgDoNewSource,
      action: FlagAction.addToRoute,
      closesByItself: true,
    ),
    PickupFlag(
      type: PickupSupervisorFlagDetailType.extraPickup,
      name: 'Mahavir Paper Mill',
      address: 'Plot 7, Sachin GIDC',
      summary: l10n.fgExtraLine('Sat 24 Oct'),
      title: l10n.fgExtraPickup,
      rows: [
        (
          l10n.fgExtraPickupLabel,
          l10n.fgExtraValue('Sat 24 Oct', '11 am – 12 pm', '60'),
        ),
        (l10n.fgRoute, l10n.fgNoneYet),
      ],
      whatToDo: l10n.fgDoExtra,
      action: FlagAction.addToRoute,
      closesByItself: true,
    ),
    PickupFlag(
      type: PickupSupervisorFlagDetailType.sourceMoved,
      name: 'Hotel Annapurna',
      address: 'Vesu Main Road, Vesu',
      summary: l10n.fgMovedLine('Vesu'),
      title: l10n.fgSourceMoved,
      rows: [
        (l10n.fgWhy, l10n.fgAreaNowYours('Vesu')),
        (l10n.fgSchedule, l10n.rdSchedEveryDay('1–3 pm')),
        (l10n.fgRoute, l10n.fgNoneYet),
      ],
      whatToDo: l10n.fgDoMoved,
      action: FlagAction.addToRoute,
    ),
  ];

  static PickupFlag of(
    DriverLocalizations l10n,
    PickupSupervisorFlagDetailType type,
  ) => all(l10n).firstWhere((f) => f.type == type);
}
