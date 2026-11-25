import 'package:flutter/material.dart';

/// Period chips shared by the home summary and the collection report.
enum ReportPeriod { today, yesterday, week, month, custom }

enum RouteVehicle { own, contract }

enum PickupCategory { daily, weekly, biWeekly, monthly, onCall }

enum LookAtOutcome { missed, cancelledBySource, zeroKg }

class ReportRouteRow {
  const ReportRouteRow(this.name, this.vehicle, this.done, this.total, this.kg);

  final String name;
  final RouteVehicle vehicle;
  final int done;
  final int total;
  final int kg;
}

class ReportCategoryRow {
  const ReportCategoryRow(this.category, this.stops, this.kg);

  final PickupCategory category;
  final int stops;
  final int kg;
}

class ReportLookAtRow {
  const ReportLookAtRow(this.outcome, this.names, this.count);

  final LookAtOutcome outcome;

  /// The first two pickup point names; the rest are summarised as "+n".
  final List<String> names;
  final int count;
}

/// Mock collection figures for one period.
class CollectionReportData {
  const CollectionReportData({
    required this.range,
    required this.kg,
    required this.pcs,
    required this.due,
    required this.collected,
    required this.zeroKg,
    required this.missed,
    required this.cancelled,
    required this.trips,
    required this.routes,
    required this.categories,
    required this.lookAt,
  });

  final DateTimeRange range;
  final int kg;
  final int pcs;
  final int due;
  final int collected;
  final int zeroKg;
  final int missed;
  final int cancelled;
  final int trips;
  final List<ReportRouteRow> routes;
  final List<ReportCategoryRow> categories;
  final List<ReportLookAtRow> lookAt;
}

/// Second line on a "Stops to look at" card.
enum LookAtDetail {
  contractVehicle,
  ownVehicle,
  extraPickup,
  calledOffByIec,
  calledOffAtStop,
  calledOffByYou,
}

enum LookAtReason {
  notRecorded,
  tripCancelled,
  noRoute,
  takenOff,
  closedToday,
  holiday,
  shifted,
  noMaterial,
  noMaterialToday,
  closed,
  refused,
  vehicleFull,
}

/// One pickup point on the "Stops to look at" screen.
class LookAtStop {
  const LookAtStop({
    required this.name,
    required this.date,
    required this.detail,
    required this.reason,
    this.route,
    this.detailValue = '',
  });

  final String name;

  /// Null when the stop was not on a route.
  final String? route;
  final DateTime date;
  final LookAtDetail detail;

  /// Vehicle plate or driver name used by [detail].
  final String detailValue;
  final LookAtReason reason;
}
