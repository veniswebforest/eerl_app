import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/core/widgets/module_segmented_switch.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_dashboard_widgets.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_mock_data.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';
import 'package:pickup_supervisor/features/route_detail/widgets/route_detail_header_widgets.dart';
import 'package:pickup_supervisor/features/route_detail/widgets/route_detail_map_widgets.dart';
import 'package:pickup_supervisor/features/route_detail/widgets/route_detail_stop_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// PS-M04 route detail: header, Today / Next 7 Days, and List / Map views.
class RouteDetailScreen extends StatelessWidget {
  const RouteDetailScreen({
    super.key,
    this.initialPeriod = RouteDetailPeriod.today,
    this.initialView = RouteDetailView.list,
  });

  final RouteDetailPeriod initialPeriod;
  final RouteDetailView initialView;

  @override
  Widget build(BuildContext context) => DriverLocalizationScope(
    child: _RouteDetailView(
      initialPeriod: initialPeriod,
      initialView: initialView,
    ),
  );
}

class _RouteDetailView extends StatefulWidget {
  const _RouteDetailView({
    required this.initialPeriod,
    required this.initialView,
  });

  final RouteDetailPeriod initialPeriod;
  final RouteDetailView initialView;

  @override
  State<_RouteDetailView> createState() => _RouteDetailViewState();
}

class _RouteDetailViewState extends State<_RouteDetailView> {
  late RouteDetailPeriod _period = widget.initialPeriod;
  late RouteDetailView _view = widget.initialView;
  StopFilter _filter = StopFilter.all;

  bool get _isToday => _period == RouteDetailPeriod.today;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return ModulePage(
      bottom: _isToday && _view == RouteDetailView.list || !_isToday
          ? DriverPrimaryButton(
              key: const Key('route-detail-add-sources'),
              radius: 12,
              label: l10n.rdAddSources,
              onPressed: () {},
            )
          : null,
      child: ListView(
        key: const Key('route-detail-scroll'),
        padding: EdgeInsets.zero,
        children: [
          const RouteDetailTopBar(),
          const SizedBox(height: 24),
          RouteDetailHeaderCard(
            summary: _isToday
                ? RouteDetailMockData.todaySummary
                : RouteDetailMockData.nextSevenDaysSummary,
          ),
          const SizedBox(height: 24),
          ModuleSegmentedSwitch(
            keyPrefix: 'route-detail-period',
            labels: [l10n.tpChoiceToday, l10n.rdNext7Days],
            selectedIndex: _isToday ? 0 : 1,
            onChanged: (index) => setState(
              () => _period = index == 0
                  ? RouteDetailPeriod.today
                  : RouteDetailPeriod.next7Days,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isToday ? l10n.rdDateToday : l10n.rdDateRange,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 24),
          ..._isToday ? _todayContent(l10n) : _upcomingContent(l10n),
        ],
      ),
    );
  }

  List<Widget> _todayContent(DriverLocalizations l10n) {
    final stops = RouteDetailMockData.todayStops;
    final counts = {
      for (final filter in StopFilter.values)
        filter: stops.where((s) => s.matches(filter)).length,
    };
    final visible = stops.where((s) => s.matches(_filter)).toList();
    return [
      ModuleSegmentedSwitch(
        keyPrefix: 'route-detail-view',
        labels: [l10n.rdList, l10n.rdMap],
        selectedIndex: _view == RouteDetailView.list ? 0 : 1,
        onChanged: (index) => setState(
          () => _view = index == 0 ? RouteDetailView.list : RouteDetailView.map,
        ),
      ),
      const SizedBox(height: 16),
      if (_view == RouteDetailView.map)
        const RouteDetailMapCard(
          points: RouteDetailMockData.mapStops,
          warehouseName: 'Adajan Central Warehouse',
          nextNumber: 6,
          nextName: 'Om Sweets',
          nextTime: '10–12 am',
          nextDistance: '1.2 km',
        )
      else ...[
        RouteDetailFilterChips(
          selected: _filter,
          counts: counts,
          onChanged: (value) => setState(() => _filter = value),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          RouteDetailStopCard(
            key: Key('route-detail-stop-${visible[i].name}-$i'),
            stop: visible[i],
          ),
        ],
      ],
    ];
  }

  List<Widget> _upcomingContent(DriverLocalizations l10n) {
    final stops = RouteDetailMockData.nextSevenDaysStops;
    return [
      for (var i = 0; i < stops.length; i++) ...[
        if (i > 0) const SizedBox(height: 16),
        RouteDetailUpcomingCard(
          stop: stops[i],
          highlighted: i == 0,
          once: stops[i].schedule.kind == StopScheduleKind.once,
        ),
      ],
      const SizedBox(height: 16),
      Center(
        child: SizedBox(
          width: 296,
          child: Text(
            l10n.rdAddedLastHint,
            textAlign: TextAlign.center,
            style: DriverTextStyles.medium12.copyWith(
              color: DriverColors.cool600,
            ),
          ),
        ),
      ),
    ];
  }
}
