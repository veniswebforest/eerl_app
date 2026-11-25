import 'package:flutter/material.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_models.dart';

/// Static report figures (no backend yet). "Today" is Thu 22 Oct 2026, the
/// same day the home screen shows.
abstract final class CollectionReportMockData {
  static final today = DateTime(2026, 10, 22);
  static const supervisorName = 'Kiran Patel';
  static final madeAt = DateTime(2026, 10, 23, 18, 10);

  static const _lookAtNames = {
    LookAtOutcome.missed: ['Sunrise School', 'Hotel Rajdhani'],
    LookAtOutcome.cancelledBySource: ['XYZ Textile Mills', 'Om Fabrics'],
    LookAtOutcome.zeroKg: ['City Bakery', 'Gokul Society'],
  };

  static List<ReportLookAtRow> _lookAt(int missed, int cancelled, int zero) => [
    ReportLookAtRow(
      LookAtOutcome.missed,
      _lookAtNames[LookAtOutcome.missed]!,
      missed,
    ),
    ReportLookAtRow(
      LookAtOutcome.cancelledBySource,
      _lookAtNames[LookAtOutcome.cancelledBySource]!,
      cancelled,
    ),
    ReportLookAtRow(
      LookAtOutcome.zeroKg,
      _lookAtNames[LookAtOutcome.zeroKg]!,
      zero,
    ),
  ];

  static CollectionReportData forPeriod(
    ReportPeriod period, {
    DateTimeRange? customRange,
  }) => switch (period) {
    ReportPeriod.today => _today,
    ReportPeriod.yesterday => _yesterday,
    ReportPeriod.week => _week,
    ReportPeriod.month => _month,
    ReportPeriod.custom => _custom(customRange ?? _week.range),
  };

  static final _today = CollectionReportData(
    range: DateTimeRange(start: today, end: today),
    kg: 320,
    pcs: 125,
    due: 16,
    collected: 12,
    zeroKg: 2,
    missed: 1,
    cancelled: 1,
    trips: 5,
    routes: const [
      ReportRouteRow('Adajan Morning', RouteVehicle.own, 3, 6, 140),
      ReportRouteRow('Punagam FullDay', RouteVehicle.contract, 4, 4, 95),
      ReportRouteRow('Pal Gam Morning', RouteVehicle.own, 1, 2, 0),
      ReportRouteRow('Rander Evening', RouteVehicle.contract, 4, 4, 85),
    ],
    categories: const [
      ReportCategoryRow(PickupCategory.daily, 10, 210),
      ReportCategoryRow(PickupCategory.weekly, 3, 70),
      ReportCategoryRow(PickupCategory.biWeekly, 1, 15),
      ReportCategoryRow(PickupCategory.monthly, 1, 20),
      ReportCategoryRow(PickupCategory.onCall, 1, 5),
    ],
    lookAt: _lookAt(1, 1, 2),
  );

  static final _yesterday = CollectionReportData(
    range: DateTimeRange(
      start: DateTime(2026, 10, 21),
      end: DateTime(2026, 10, 21),
    ),
    kg: 298,
    pcs: 90,
    due: 15,
    collected: 13,
    zeroKg: 1,
    missed: 0,
    cancelled: 1,
    trips: 4,
    routes: const [
      ReportRouteRow('Adajan Morning', RouteVehicle.own, 6, 6, 130),
      ReportRouteRow('Punagam FullDay', RouteVehicle.contract, 4, 4, 92),
      ReportRouteRow('Pal Gam Morning', RouteVehicle.own, 2, 3, 46),
      ReportRouteRow('Rander Evening', RouteVehicle.contract, 1, 2, 30),
    ],
    categories: const [
      ReportCategoryRow(PickupCategory.daily, 10, 205),
      ReportCategoryRow(PickupCategory.weekly, 3, 63),
      ReportCategoryRow(PickupCategory.biWeekly, 0, 0),
      ReportCategoryRow(PickupCategory.monthly, 1, 22),
      ReportCategoryRow(PickupCategory.onCall, 1, 8),
    ],
    lookAt: _lookAt(0, 1, 1),
  );

  static final _week = CollectionReportData(
    range: DateTimeRange(start: DateTime(2026, 10, 16), end: today),
    kg: 2140,
    pcs: 610,
    due: 105,
    collected: 86,
    zeroKg: 9,
    missed: 4,
    cancelled: 6,
    trips: 31,
    routes: const [
      ReportRouteRow('Adajan Morning', RouteVehicle.own, 40, 45, 820),
      ReportRouteRow('Punagam FullDay', RouteVehicle.contract, 27, 30, 690),
      ReportRouteRow('Pal Gam Morning', RouteVehicle.own, 12, 18, 410),
      ReportRouteRow('Rander Evening', RouteVehicle.contract, 7, 12, 220),
    ],
    categories: const [
      ReportCategoryRow(PickupCategory.daily, 64, 1420),
      ReportCategoryRow(PickupCategory.weekly, 15, 480),
      ReportCategoryRow(PickupCategory.biWeekly, 2, 90),
      ReportCategoryRow(PickupCategory.monthly, 3, 120),
      ReportCategoryRow(PickupCategory.onCall, 2, 30),
    ],
    lookAt: _lookAt(4, 6, 9),
  );

  static final _month = CollectionReportData(
    range: DateTimeRange(start: DateTime(2026, 10), end: today),
    kg: 6480,
    pcs: 1820,
    due: 318,
    collected: 268,
    zeroKg: 24,
    missed: 11,
    cancelled: 15,
    trips: 96,
    routes: const [
      ReportRouteRow('Adajan Morning', RouteVehicle.own, 124, 136, 2480),
      ReportRouteRow('Punagam FullDay', RouteVehicle.contract, 84, 92, 2090),
      ReportRouteRow('Pal Gam Morning', RouteVehicle.own, 41, 54, 1230),
      ReportRouteRow('Rander Evening', RouteVehicle.contract, 19, 36, 680),
    ],
    categories: const [
      ReportCategoryRow(PickupCategory.daily, 198, 4310),
      ReportCategoryRow(PickupCategory.weekly, 46, 1450),
      ReportCategoryRow(PickupCategory.biWeekly, 6, 270),
      ReportCategoryRow(PickupCategory.monthly, 9, 360),
      ReportCategoryRow(PickupCategory.onCall, 9, 90),
    ],
    lookAt: _lookAt(11, 15, 24),
  );

  /// Picked dates reuse the week's figures with the chosen range (static).
  static CollectionReportData _custom(DateTimeRange range) =>
      CollectionReportData(
        range: range,
        kg: _week.kg,
        pcs: _week.pcs,
        due: _week.due,
        collected: _week.collected,
        zeroKg: _week.zeroKg,
        missed: _week.missed,
        cancelled: _week.cancelled,
        trips: _week.trips,
        routes: _week.routes,
        categories: _week.categories,
        lookAt: _week.lookAt,
      );

  /// Pickup points behind each "Stops to look at" outcome (newest first).
  /// The screen shows as many as the period's count.
  static final lookAtStops = <LookAtOutcome, List<LookAtStop>>{
    LookAtOutcome.missed: [
      LookAtStop(
        name: 'Sunrise School',
        route: 'Punagam FullDay',
        date: DateTime(2026, 10, 22),
        detail: LookAtDetail.contractVehicle,
        detailValue: 'GJ-05-EE-1002',
        reason: LookAtReason.notRecorded,
      ),
      LookAtStop(
        name: 'Hotel Rajdhani',
        route: 'Adajan Morning',
        date: DateTime(2026, 10, 20),
        detail: LookAtDetail.ownVehicle,
        detailValue: 'Vikram Singh',
        reason: LookAtReason.tripCancelled,
      ),
      LookAtStop(
        name: 'Navratri Ground',
        date: DateTime(2026, 10, 17),
        detail: LookAtDetail.extraPickup,
        reason: LookAtReason.noRoute,
      ),
      LookAtStop(
        name: 'Laxmi Provision Store',
        route: 'Pal Gam Morning',
        date: DateTime(2026, 10, 16),
        detail: LookAtDetail.ownVehicle,
        detailValue: 'Amit Patel',
        reason: LookAtReason.takenOff,
      ),
    ],
    LookAtOutcome.cancelledBySource: [
      LookAtStop(
        name: 'XYZ Textile Mills',
        route: 'Adajan Morning',
        date: DateTime(2026, 10, 22),
        detail: LookAtDetail.calledOffByIec,
        reason: LookAtReason.closedToday,
      ),
      LookAtStop(
        name: 'Om Fabrics',
        route: 'Pal Gam Morning',
        date: DateTime(2026, 10, 21),
        detail: LookAtDetail.calledOffAtStop,
        detailValue: 'Amit Patel',
        reason: LookAtReason.holiday,
      ),
      LookAtStop(
        name: 'Shree Sai Dairy',
        route: 'Adajan Morning',
        date: DateTime(2026, 10, 19),
        detail: LookAtDetail.calledOffByYou,
        reason: LookAtReason.shifted,
      ),
      LookAtStop(
        name: 'Green Park Society',
        route: 'Vesu Evening',
        date: DateTime(2026, 10, 17),
        detail: LookAtDetail.calledOffByIec,
        reason: LookAtReason.noMaterial,
      ),
    ],
    LookAtOutcome.zeroKg: [
      LookAtStop(
        name: 'City Bakery',
        route: 'Adajan Morning',
        date: DateTime(2026, 10, 22),
        detail: LookAtDetail.ownVehicle,
        detailValue: 'Vikram Singh',
        reason: LookAtReason.noMaterialToday,
      ),
      LookAtStop(
        name: 'Gokul Society',
        route: 'Vesu Evening',
        date: DateTime(2026, 10, 21),
        detail: LookAtDetail.contractVehicle,
        detailValue: 'GJ-05-EE-1002',
        reason: LookAtReason.closed,
      ),
      LookAtStop(
        name: 'Krishna Traders',
        route: 'Punagam FullDay',
        date: DateTime(2026, 10, 20),
        detail: LookAtDetail.contractVehicle,
        detailValue: 'GJ-05-EE-1002',
        reason: LookAtReason.refused,
      ),
      LookAtStop(
        name: 'Mehta Medicals',
        route: 'Vesu Evening',
        date: DateTime(2026, 10, 19),
        detail: LookAtDetail.ownVehicle,
        detailValue: 'Amit Patel',
        reason: LookAtReason.vehicleFull,
      ),
    ],
  };
}
