import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/features/trips_plan/model/trips_plan_mock_data.dart';
import 'package:pickup_supervisor/features/trips_plan/model/trips_plan_models.dart';
import 'package:pickup_supervisor/features/trips_plan/widgets/trips_plan_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// PS-M04 Trips plan: Today, Tomorrow, This week and a picked date.
class TripsPlanScreen extends StatelessWidget {
  const TripsPlanScreen({
    super.key,
    this.initialChoice = TripsPlanChoice.today,
  });

  final TripsPlanChoice initialChoice;

  @override
  Widget build(BuildContext context) => DriverLocalizationScope(
    child: _TripsPlanView(initialChoice: initialChoice),
  );
}

class _TripsPlanView extends StatefulWidget {
  const _TripsPlanView({required this.initialChoice});

  final TripsPlanChoice initialChoice;

  @override
  State<_TripsPlanView> createState() => _TripsPlanViewState();
}

class _TripsPlanViewState extends State<_TripsPlanView> {
  late TripsPlanChoice _choice = widget.initialChoice;

  String _dayTitle(DriverLocalizations l10n, int index) => switch (index) {
    0 => l10n.tpDay0,
    1 => l10n.tpDay1,
    2 => l10n.tpDay2,
    3 => l10n.tpDay3,
    4 => l10n.tpDay4,
    5 => l10n.tpDay5,
    _ => l10n.tpDay6,
  };

  String _daySummary(DriverLocalizations l10n, TripsPlanDay day) => [
    l10n.tpTripsStops(day.trips, day.stops),
    if (day.extraPickups > 0) l10n.tpExtraPickups(day.extraPickups),
    if (day.pausedSources > 0) l10n.tpSourcePaused(day.pausedSources),
  ].join(' · ');

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
          TripsPlanChoices(
            selected: _choice,
            onChanged: (value) => setState(() => _choice = value),
          ),
          const SizedBox(height: 20),
          ..._content(l10n),
        ],
      ),
    );
  }

  List<Widget> _content(DriverLocalizations l10n) {
    switch (_choice) {
      case TripsPlanChoice.today:
        return _tripList(
          l10n,
          date: l10n.tpDateToday,
          trips: TripsPlanMockData.todayTrips,
          stops: 39,
        );
      case TripsPlanChoice.tomorrow:
        return _tripList(
          l10n,
          date: l10n.tpDateTomorrow,
          trips: TripsPlanMockData.tomorrowTrips,
          stops: 31,
        );
      case TripsPlanChoice.week:
        return [
          for (final day in TripsPlanMockData.weekDays) ...[
            TripsPlanDayCard(
              key: Key('trips-plan-day-${day.dayIndex}'),
              title: _dayTitle(l10n, day.dayIndex),
              summary: _daySummary(l10n, day),
              ownVehicles: day.ownVehicles,
              contractVehicles: day.contractVehicles,
              onTap: day.dayIndex <= 1
                  ? () => setState(
                      () => _choice = day.dayIndex == 0
                          ? TripsPlanChoice.today
                          : TripsPlanChoice.tomorrow,
                    )
                  : null,
            ),
            const SizedBox(height: 20),
          ],
        ];
      case TripsPlanChoice.date:
        return [
          TripsPlanDateRow(date: l10n.tpDateNoTrips, summary: l10n.tpNoTrips),
          TripsPlanEmptyState(
            title: l10n.tpEmptyTitle,
            message: l10n.tpEmptyMessage,
          ),
        ];
    }
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
