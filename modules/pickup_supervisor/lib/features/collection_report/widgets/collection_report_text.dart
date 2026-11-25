import 'package:pickup_supervisor/core/utils/module_date_format.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_models.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// Localised labels for the collection report model.
extension CollectionReportText on DriverLocalizations {
  String periodChip(ReportPeriod p) => switch (p) {
    ReportPeriod.today => supervisorToday,
    ReportPeriod.yesterday => supervisorYesterday,
    ReportPeriod.week => supervisorWeek,
    ReportPeriod.month => supervisorMonth,
    ReportPeriod.custom => calPickDates,
  };

  /// "Collected this week" etc.
  String collectedPeriodLabel(ReportPeriod p) => switch (p) {
    ReportPeriod.today => rpCollectedToday,
    ReportPeriod.yesterday => rpCollectedYesterday,
    ReportPeriod.week => rpCollectedThisWeek,
    ReportPeriod.month => rpCollectedThisMonth,
    ReportPeriod.custom => rpCollectedTheseDates,
  };

  /// "This week" etc. (PDF header).
  String periodName(ReportPeriod p) => switch (p) {
    ReportPeriod.today => rpPeriodToday,
    ReportPeriod.yesterday => rpPeriodYesterday,
    ReportPeriod.week => rpPeriodThisWeek,
    ReportPeriod.month => rpPeriodThisMonth,
    ReportPeriod.custom => rpPeriodDates,
  };

  String vehicleLabel(RouteVehicle v) =>
      v == RouteVehicle.own ? rpOwn : rpContract;

  String categoryLabel(PickupCategory c) => switch (c) {
    PickupCategory.daily => supervisorDaily,
    PickupCategory.weekly => supervisorWeekly,
    PickupCategory.biWeekly => supervisorBiWeekly,
    PickupCategory.monthly => supervisorMonthly,
    PickupCategory.onCall => supervisorOnCall,
  };

  String outcomeLabel(LookAtOutcome o) => switch (o) {
    LookAtOutcome.missed => supervisorMissed,
    LookAtOutcome.cancelledBySource => rpCancelledBySource,
    LookAtOutcome.zeroKg => supervisorKg,
  };

  String kgText(int kg) => rpKg(number(kg));

  String totalText(CollectionReportData d) =>
      rpTotal(number(d.kg), number(d.pcs));

  /// "Sunrise School, Hotel Rajdhani and 2 more".
  String namesMore(ReportLookAtRow r) => _names(r, short: false);

  /// "Sunrise School, Hotel Rajdhani +2" (PDF table).
  String namesPlus(ReportLookAtRow r) => _names(r, short: true);

  String _names(ReportLookAtRow r, {required bool short}) {
    if (r.count <= 0) return '–';
    if (r.count == 1 || r.names.length < 2) return r.names.first;
    final rest = r.count - 2;
    if (rest <= 0) return '${r.names[0]}, ${r.names[1]}';
    return short
        ? rpNamesPlus(r.names[0], r.names[1], '$rest')
        : rpNamesMore(r.names[0], r.names[1], '$rest');
  }

  /// "Thu 22 Oct"
  String weekdayDayMonth(DateTime d) =>
      '${calWeekdayShort('${d.weekday}')} ${dayMonth(d)}';

  String lookAtFirstLine(LookAtStop s) =>
      lkRouteDate(s.route ?? lkNotOnRoute, weekdayDayMonth(s.date));

  String lookAtDetail(LookAtStop s) => switch (s.detail) {
    LookAtDetail.contractVehicle => lkContractVehicle(s.detailValue),
    LookAtDetail.ownVehicle => lkOwnVehicle(s.detailValue),
    LookAtDetail.extraPickup => lkExtraPickup,
    LookAtDetail.calledOffByIec => lkCalledOffIec,
    LookAtDetail.calledOffAtStop => lkCalledOffAtStop(s.detailValue),
    LookAtDetail.calledOffByYou => lkCalledOffByYou,
  };

  String lookAtReason(LookAtReason r) => switch (r) {
    LookAtReason.notRecorded => lkReasonNotRecorded,
    LookAtReason.tripCancelled => lkReasonTripCancelled,
    LookAtReason.noRoute => lkReasonNoRoute,
    LookAtReason.takenOff => lkReasonTakenOff,
    LookAtReason.closedToday => lkReasonClosedToday,
    LookAtReason.holiday => lkReasonHoliday,
    LookAtReason.shifted => lkReasonShifted,
    LookAtReason.noMaterial => lkReasonNoMaterial,
    LookAtReason.noMaterialToday => lkReasonNoMaterialToday,
    LookAtReason.closed => lkReasonClosed,
    LookAtReason.refused => lkReasonRefused,
    LookAtReason.vehicleFull => lkReasonVehicleFull,
  };

  /// Short tab / tag label: Missed, Cancelled, 0 kg.
  String outcomeTabLabel(LookAtOutcome o) => switch (o) {
    LookAtOutcome.missed => supervisorMissed,
    LookAtOutcome.cancelledBySource => supervisorCancelled,
    LookAtOutcome.zeroKg => supervisorKg,
  };
}
