import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/utils/module_date_format.dart';
import 'package:pickup_supervisor/core/widgets/module_date_range_sheet.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/features/trips_plan/model/trips_plan_mock_data.dart';
import 'package:pickup_supervisor/features/trips_plan/model/trips_plan_models.dart';
import 'package:pickup_supervisor/features/trips_plan/widgets/trips_plan_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// PS-M04 Trips plan.
///
/// * Today / Tomorrow: the real trips (cards open the route).
/// * This week: one card per day. Today and tomorrow open their trips; later
///   days open the expected view (trips are made the day before).
/// * Calendar: Pick dates → Chosen dates. A day with no trips (warehouse
///   holiday) opens No trips.
class TripsPlanScreen extends StatelessWidget {
  const TripsPlanScreen({
    super.key,
    this.initialChoice = TripsPlanChoice.today,
    this.initialRange,
    this.initialDay,
  });

  final TripsPlanChoice initialChoice;

  /// Chosen dates for [TripsPlanChoice.date]; defaults to 26 – 31 Oct.
  final DateTimeRange? initialRange;

  /// Open straight on one later day (expected view or No trips), as an
  /// offset from today.
  final int? initialDay;

  @override
  Widget build(BuildContext context) => DriverLocalizationScope(
    child: _TripsPlanView(
      initialChoice: initialChoice,
      initialRange: initialRange,
      initialDay: initialDay,
    ),
  );
}

class _TripsPlanView extends StatefulWidget {
  const _TripsPlanView({
    required this.initialChoice,
    required this.initialRange,
    required this.initialDay,
  });

  final TripsPlanChoice initialChoice;
  final DateTimeRange? initialRange;
  final int? initialDay;

  @override
  State<_TripsPlanView> createState() => _TripsPlanViewState();
}

class _TripsPlanViewState extends State<_TripsPlanView> {
  late TripsPlanChoice _choice = widget.initialChoice;
  late DateTimeRange _range =
      widget.initialRange ?? TripsPlanMockData.defaultRange;

  /// A single later day opened from This week or Chosen dates.
  late int? _day = widget.initialDay;

  String _dayMonth(DriverLocalizations l10n, DateTime d) =>
      '${l10n.calWeekdayShort('${d.weekday}')} ${l10n.dayMonth(d)}';

  String _dayMonthYear(DriverLocalizations l10n, DateTime d) =>
      '${_dayMonth(l10n, d)} ${d.year}';

  String _dayTitle(DriverLocalizations l10n, TripsPlanDay day) {
    final date = _dayMonth(l10n, TripsPlanMockData.dateOf(day.dayIndex));
    if (day.dayIndex == 0) return l10n.tpTodaySuffix(date);
    if (day.closed) return l10n.tpWarehouseClosed(date);
    return date;
  }

  String _daySummary(DriverLocalizations l10n, TripsPlanDay day) => day.closed
      ? l10n.tpNoTripsHoliday
      : [
          l10n.tpTripsStops(day.trips, day.stops),
          if (day.extraPickups > 0) l10n.tpExtraPickups(day.extraPickups),
          if (day.pausedSources > 0) l10n.tpSourcePaused(day.pausedSources),
        ].join(' · ');

  void _select(TripsPlanChoice choice) {
    if (choice == TripsPlanChoice.date) {
      _pickDates();
      return;
    }
    setState(() {
      _choice = choice;
      _day = null;
    });
  }

  Future<void> _pickDates() async {
    final range = await showModuleDateRangeSheet(
      context,
      initialRange: _choice == TripsPlanChoice.date ? _range : null,
      firstDate: TripsPlanMockData.today,
      today: TripsPlanMockData.today,
      initialMonth: _range.start,
      weekdayInSummary: true,
    );
    if (range == null || !mounted) return;
    setState(() {
      _choice = TripsPlanChoice.date;
      _range = range;
      _day = null;
    });
  }

  /// From This week, today and tomorrow switch to their chips. From Chosen
  /// dates every day opens in place so the calendar chip stays selected.
  void _openDay(TripsPlanDay day) => setState(() {
    if (_choice == TripsPlanChoice.date) {
      _day = day.dayIndex;
    } else if (day.dayIndex == 0 && !day.closed) {
      _choice = TripsPlanChoice.today;
      _day = null;
    } else if (day.dayIndex == 1 && !day.closed) {
      _choice = TripsPlanChoice.tomorrow;
      _day = null;
    } else {
      _day = day.dayIndex;
    }
  });

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return ModulePage(
      child: ListView(
        key: const Key('trips-plan-scroll'),
        padding: EdgeInsets.zero,
        children: [
          TripsPlanHeader(title: l10n.tpTitle, subtitle: l10n.tpAreas),
          const SizedBox(height: 20),
          TripsPlanChoices(selected: _choice, onChanged: _select),
          const SizedBox(height: 20),
          ..._content(l10n),
        ],
      ),
    );
  }

  List<Widget> _content(DriverLocalizations l10n) {
    final day = _day;
    if (day != null) return _singleDay(l10n, TripsPlanMockData.dayAt(day));
    switch (_choice) {
      case TripsPlanChoice.today:
        return _tripList(
          l10n,
          date: _dayMonthYear(l10n, TripsPlanMockData.dateOf(0)),
          trips: TripsPlanMockData.todayTrips,
          stops: 39,
        );
      case TripsPlanChoice.tomorrow:
        return _tripList(
          l10n,
          date: _dayMonthYear(l10n, TripsPlanMockData.dateOf(1)),
          trips: TripsPlanMockData.tomorrowTrips,
          stops: 31,
        );
      case TripsPlanChoice.week:
        return _dayCards(l10n, TripsPlanMockData.weekDays);
      case TripsPlanChoice.date:
        final first = TripsPlanMockData.indexOf(_range.start);
        final last = TripsPlanMockData.indexOf(_range.end);
        return _dayCards(l10n, [
          for (var i = first; i <= last; i++) TripsPlanMockData.dayAt(i),
        ]);
    }
  }

  List<Widget> _dayCards(DriverLocalizations l10n, List<TripsPlanDay> days) => [
    for (final day in days) ...[
      TripsPlanDayCard(
        key: Key('trips-plan-day-${day.dayIndex}'),
        title: _dayTitle(l10n, day),
        summary: _daySummary(l10n, day),
        ownVehicles: day.ownVehicles,
        contractVehicles: day.contractVehicles,
        showVehicles: !day.closed,
        onTap: () => _openDay(day),
      ),
      const SizedBox(height: 20),
    ],
  ];

  List<Widget> _singleDay(DriverLocalizations l10n, TripsPlanDay day) {
    final date = _dayMonthYear(l10n, TripsPlanMockData.dateOf(day.dayIndex));
    if (!day.closed && day.dayIndex <= 1) {
      // Today / tomorrow have real trips (opened from Chosen dates).
      return _tripList(
        l10n,
        date: date,
        trips: day.dayIndex == 0
            ? TripsPlanMockData.todayTrips
            : TripsPlanMockData.tomorrowTrips,
        stops: day.stops,
      );
    }
    if (day.closed) {
      return [
        TripsPlanDateRow(date: date, summary: l10n.tpNoTrips),
        TripsPlanEmptyState(
          title: l10n.tpEmptyTitle,
          message: l10n.tpEmptyMessage,
        ),
      ];
    }
    return [
      TripsPlanDateRow(
        date: date,
        summary: l10n.tpTripsStops(day.trips, day.stops),
      ),
      const SizedBox(height: 20),
      TripsPlanInfoBanner(message: l10n.tpExpectedInfo),
      const SizedBox(height: 20),
      for (final trip in TripsPlanMockData.expectedTrips.take(day.trips)) ...[
        TripsPlanTripCard(trip: trip),
        const SizedBox(height: 20),
      ],
    ];
  }

  List<Widget> _tripList(
    DriverLocalizations l10n, {
    required String date,
    required List<TripPlanTrip> trips,
    required int stops,
  }) => [
    TripsPlanDateRow(
      date: date,
      summary: l10n.tpTripsStops(trips.length, stops),
    ),
    const SizedBox(height: 20),
    for (final trip in trips) ...[
      TripsPlanTripCard(trip: trip),
      const SizedBox(height: 20),
    ],
  ];
}
