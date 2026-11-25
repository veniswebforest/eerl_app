import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/utils/module_date_format.dart';
import 'package:pickup_supervisor/core/widgets/module_date_range_sheet.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_mock_data.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_models.dart';
import 'package:pickup_supervisor/features/collection_report/view/collection_report_screen.dart';
import 'package:pickup_supervisor/features/collection_report/view/stops_to_look_at_screen.dart';
import 'package:pickup_supervisor/features/issues/view/issues_screen.dart';
import 'package:pickup_supervisor/features/collection_report/widgets/collection_report_text.dart';
import 'package:pickup_supervisor/features/collection_report/widgets/collection_report_widgets.dart';
import 'package:pickup_supervisor/features/trips_plan/view/trips_plan_screen.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_attention_screens.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_flags_screens.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_sources_screens.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/model/pickup_supervisor_bottom_nav_item.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/widgets/pickup_supervisor_bottom_navigation.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/widgets/pickup_supervisor_home_drawer.dart';

const _assetRoot = 'assets/icons/supervisor/home';
const _assetPackage = 'pickup_supervisor';
const _cardShadow = <BoxShadow>[
  BoxShadow(color: Color(0x1F000000), blurRadius: 5, offset: Offset(0, 2)),
];

List<PickupSupervisorBottomNavItem> _standaloneNavigationItems(
  DriverLocalizations l10n,
) => [
  PickupSupervisorBottomNavItem(
    title: l10n.supervisorHome,
    selectedIcon: '$_assetRoot/nav_home.svg',
    unselectedIcon: '$_assetRoot/nav_home.svg',
    page: const SizedBox.shrink(),
    pageKey: 'home',
    roles: const {PickupSupervisorModuleRole.pickupSupervisor},
  ),
  PickupSupervisorBottomNavItem(
    title: l10n.sourcesNavLabel,
    selectedIcon: '$_assetRoot/nav_trips.svg',
    unselectedIcon: '$_assetRoot/nav_trips.svg',
    page: const SizedBox.shrink(),
    pageKey: 'sources',
    roles: const {PickupSupervisorModuleRole.pickupSupervisor},
  ),
  PickupSupervisorBottomNavItem(
    title: l10n.sourcesRoutesNavLabel,
    selectedIcon: '$_assetRoot/nav_sources.svg',
    unselectedIcon: '$_assetRoot/nav_sources.svg',
    page: const SizedBox.shrink(),
    pageKey: 'routes',
    roles: const {PickupSupervisorModuleRole.pickupSupervisor},
  ),
  PickupSupervisorBottomNavItem(
    title: l10n.sourcesProfileNavLabel,
    selectedIcon: '$_assetRoot/nav_profile.svg',
    unselectedIcon: '$_assetRoot/nav_profile.svg',
    page: const SizedBox.shrink(),
    pageKey: 'profile',
    roles: const {PickupSupervisorModuleRole.pickupSupervisor},
  ),
];

/// Static Pickup Supervisor dashboard represented by the two selected Figma
/// frames. [initialSummaryExpanded] exposes both design states while the eye
/// action lets the user switch between them.
class PickupSupervisorHomeScreen extends StatelessWidget {
  const PickupSupervisorHomeScreen({
    super.key,
    this.initialSummaryExpanded = true,
    this.onNavigationSelected,
    this.showBottomNavigation = true,
    this.selectedNavigationIndex = 0,
    this.onMenuPressed,
  });

  final bool initialSummaryExpanded;
  final ValueChanged<int>? onNavigationSelected;
  final bool showBottomNavigation;
  final int selectedNavigationIndex;
  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: _PickupSupervisorHomePage(
        initialSummaryExpanded: initialSummaryExpanded,
        onNavigationSelected: onNavigationSelected,
        showBottomNavigation: showBottomNavigation,
        selectedNavigationIndex: selectedNavigationIndex,
        onMenuPressed: onMenuPressed,
      ),
    );
  }
}

class _PickupSupervisorHomePage extends StatefulWidget {
  const _PickupSupervisorHomePage({
    required this.initialSummaryExpanded,
    required this.onNavigationSelected,
    required this.showBottomNavigation,
    required this.selectedNavigationIndex,
    required this.onMenuPressed,
  });

  final bool initialSummaryExpanded;
  final ValueChanged<int>? onNavigationSelected;
  final bool showBottomNavigation;
  final int selectedNavigationIndex;
  final VoidCallback? onMenuPressed;

  @override
  State<_PickupSupervisorHomePage> createState() =>
      _PickupSupervisorHomePageState();
}

class _PickupSupervisorHomePageState extends State<_PickupSupervisorHomePage> {
  late bool _summaryExpanded = widget.initialSummaryExpanded;

  /// "View sources" opens the Sources tab inside the dashboard shell, or the
  /// sources screen on its own when the home is shown standalone.
  void _openSources() {
    final select = widget.onNavigationSelected;
    if (select != null) {
      select(1);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            const PickupSupervisorSourcesScreen(showBottomNavigation: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);

    return Scaffold(
      key: const Key('supervisor-home-screen'),
      extendBody: true,
      backgroundColor: DriverColors.background,
      drawer: widget.onMenuPressed == null
          ? PickupSupervisorHomeDrawer(
              onItemSelected: (item) {
                if (item == 'issues') {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PickupSupervisorIssuesScreen(),
                    ),
                  );
                }
              },
            )
          : null,
      drawerScrimColor: Colors.black.withValues(alpha: .6),
      // Same page background as the main app's home screen.
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              DriverColors.primary200,
              DriverColors.primary100,
              Colors.white,
              DriverColors.primary100,
              DriverColors.primary200,
            ],
            stops: [0, .16, .76, .92, 1],
          ),
        ),
        child: Stack(
          children: [
            CustomScrollView(
              key: const Key('supervisor-home-scroll'),
              slivers: [
                SliverToBoxAdapter(
                  child: _HeaderArea(
                    l10n: l10n,
                    summaryExpanded: _summaryExpanded,
                    onMenuPressed: widget.onMenuPressed,
                    onToggleSummary: () =>
                        setState(() => _summaryExpanded = !_summaryExpanded),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    MediaQuery.paddingOf(context).bottom + 112,
                  ),
                  sliver: SliverList.list(
                    children: [
                      const SizedBox(height: 24),
                      _TripsCard(l10n: l10n),
                      const SizedBox(height: 24),
                      _PickupPointsCard(l10n: l10n),
                      const SizedBox(height: 24),
                      Text(
                        l10n.supervisorQuickActions,
                        style: DriverTextStyles.semibold18.copyWith(
                          color: DriverColors.neutral950,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _QuickActionCard(
                        icon: '$_assetRoot/unassigned.svg',
                        iconBackground: DriverColors.secondary100,
                        title: l10n.supervisorUnassignedSources,
                        subtitle: l10n.supervisorManageUnassigned,
                        button: l10n.supervisorViewSource,
                        badge: '5',
                        onPressed: _openSources,
                      ),
                      const SizedBox(height: 16),
                      _QuickActionCard(
                        icon: '$_assetRoot/ask_head.svg',
                        iconBackground: DriverColors.red100,
                        title: l10n.supervisorAskCollectionHead,
                        subtitle: l10n.supervisorAskCollectionHeadSubtitle,
                        button: l10n.supervisorNewRequest,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNavigation
          ? PickupSupervisorBottomNavigation(
              items: _standaloneNavigationItems(l10n),
              selectedIndex: widget.selectedNavigationIndex,
              onItemSelected: (index) =>
                  widget.onNavigationSelected?.call(index),
            )
          : null,
    );
  }
}

class _HeaderArea extends StatelessWidget {
  const _HeaderArea({
    required this.l10n,
    required this.summaryExpanded,
    required this.onToggleSummary,
    required this.onMenuPressed,
  });

  final DriverLocalizations l10n;
  final bool summaryExpanded;
  final VoidCallback onToggleSummary;
  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 24,
        20,
        20,
      ),
      // decoration: const BoxDecoration(
      //   borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      //   gradient: LinearGradient(
      //     begin: Alignment.topCenter,
      //     end: Alignment.bottomCenter,
      //     stops: [0, .24, 1],
      //     colors: [
      //       DriverColors.primary400,
      //       Color(0xFFCDEED3),
      //       DriverColors.background,
      //     ],
      //   ),
      // ),
      child: Column(
        children: [
          _DashboardHeader(l10n: l10n, onMenuPressed: onMenuPressed),
          const SizedBox(height: 24),
          _OnlineCard(l10n: l10n),
          const SizedBox(height: 24),
          _AttentionCard(l10n: l10n),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.supervisorCollectionSummary,
                  style: DriverTextStyles.semibold18.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
              ),
              InkResponse(
                key: const Key('supervisor-summary-toggle'),
                onTap: onToggleSummary,
                radius: 24,
                child: _Svg(
                  summaryExpanded
                      ? '$_assetRoot/summary_expanded.svg'
                      : '$_assetRoot/summary_collapsed.svg',
                  size: 28,
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: summaryExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _CollectionSummary(l10n: l10n),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.l10n, required this.onMenuPressed});

  final DriverLocalizations l10n;
  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          child: InkResponse(
            key: const Key('supervisor-menu-button'),
            onTap: onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
            radius: 24,
            child: const SizedBox(
              width: 32,
              height: 32,
              child: Center(child: _Svg('$_assetRoot/menu.svg', size: 28)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.supervisorWelcomeBack,
                style: DriverTextStyles.semibold20.copyWith(
                  color: DriverColors.primary950,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.supervisorHeaderSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DriverTextStyles.medium12.copyWith(
                  color: DriverColors.neutral600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const _Svg('$_assetRoot/notification.svg', size: 45),
      ],
    );
  }
}

class _OnlineCard extends StatelessWidget {
  const _OnlineCard({required this.l10n});

  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const _IconTile(
            asset: '$_assetRoot/online.svg',
            background: DriverColors.primary50,
            rounded: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.supervisorOnline,
                  style: DriverTextStyles.semibold16.copyWith(
                    color: DriverColors.primary500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.supervisorLastSynced,
                  style: DriverTextStyles.medium14.copyWith(
                    color: DriverColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            key: const Key('supervisor-sync-now'),
            onPressed: () {},
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              backgroundColor: DriverColors.primary500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              l10n.supervisorSyncNow,
              style: DriverTextStyles.bold12.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard({required this.l10n});

  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final items = [
      _AttentionData(
        l10n.supervisorApprovals,
        '03',
        '$_assetRoot/check.svg',
        DriverColors.primary50,
        DriverColors.primary500,
        () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const PickupSupervisorApprovalRequestsScreen(),
          ),
        ),
      ),
      _AttentionData(
        l10n.supervisorIssues,
        '02',
        '$_assetRoot/alert.svg',
        DriverColors.red100,
        DriverColors.red600,
        () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const PickupSupervisorIssuesScreen(),
          ),
        ),
      ),
      _AttentionData(
        l10n.supervisorMyRequests,
        '01',
        '$_assetRoot/request.svg',
        DriverColors.pink100,
        DriverColors.pink600,
        () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const PickupSupervisorMyRequestsScreen(),
          ),
        ),
      ),
      _AttentionData(
        l10n.supervisorFlags,
        '03',
        '$_assetRoot/flag_attention.svg',
        DriverColors.yellow50,
        DriverColors.amber800,
        () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (_) => const PickupSupervisorFlagsScreen(),
          ),
        ),
      ),
    ];

    return _SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading(
            icon: '$_assetRoot/attention.svg',
            title: l10n.supervisorNeedsAttention,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.supervisorAttentionSubtitle,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral700,
            ),
          ),
          const SizedBox(height: 16),
          _StatTileGrid(
            tiles: [
              for (final item in items)
                _StatTile(
                  key: Key('supervisor-attention-${item.label}'),
                  label: item.label,
                  value: item.value,
                  asset: item.asset,
                  iconBackground: item.background,
                  valueColor: item.valueColor,
                  onTap: item.onTap,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttentionData {
  const _AttentionData(
    this.label,
    this.value,
    this.asset,
    this.background,
    this.valueColor,
    this.onTap,
  );

  final String label;
  final String value;
  final String asset;
  final Color background;
  final Color valueColor;
  final VoidCallback? onTap;
}

/// Compact stat tile shared by "Needs your attention" and the collection
/// summary outcomes. It draws its own shadow outside the tile, so it must not
/// be placed inside a clipping grid.
class _StatTile extends StatelessWidget {
  const _StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.asset,
    required this.iconBackground,
    required this.valueColor,
    this.onTap,
  });

  final String label;
  final String value;
  final String asset;
  final Color iconBackground;
  final Color valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: _cardShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _IconTile(
                  asset: asset,
                  background: iconBackground,
                  size: 32,
                  iconSize: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DriverTextStyles.medium12.copyWith(
                          color: DriverColors.neutral900,
                        ),
                      ),
                      Text(
                        value,
                        style: DriverTextStyles.semibold18.copyWith(
                          color: valueColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Two-column tile layout without clipping (a GridView would cut the shadows).
/// An odd last tile spans the full width, as in the Figma summary.
class _StatTileGrid extends StatelessWidget {
  const _StatTileGrid({required this.tiles});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 8),
          if (i + 1 < tiles.length)
            Row(
              children: [
                Expanded(child: tiles[i]),
                const SizedBox(width: 8),
                Expanded(child: tiles[i + 1]),
              ],
            )
          else
            tiles[i],
        ],
      ],
    );
  }
}

/// Collection summary on the home screen. The period pills switch the mock
/// figures; View full report and the Collected tile open the report for the
/// chosen period, and the calendar pill opens Pick dates.
class _CollectionSummary extends StatefulWidget {
  const _CollectionSummary({required this.l10n});

  final DriverLocalizations l10n;

  @override
  State<_CollectionSummary> createState() => _CollectionSummaryState();
}

class _CollectionSummaryState extends State<_CollectionSummary> {
  var _period = ReportPeriod.today;
  DateTimeRange? _range;

  CollectionReportData get _data =>
      CollectionReportMockData.forPeriod(_period, customRange: _range);

  void _openReport() => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) =>
          CollectionReportScreen(initialPeriod: _period, initialRange: _range),
    ),
  );

  void _openLookAt(LookAtOutcome outcome) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => StopsToLookAtScreen(data: _data, initialOutcome: outcome),
    ),
  );

  Future<void> _pickDates() async {
    final range = await showModuleDateRangeSheet(
      context,
      initialRange: _range,
      lastDate: CollectionReportMockData.today,
    );
    if (range == null || !mounted) return;
    setState(() {
      _period = ReportPeriod.custom;
      _range = range;
    });
    _openReport();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final data = _data;
    String two(int v) => v.toString().padLeft(2, '0');
    final outcomes = [
      _OutcomeData(
        l10n.supervisorCollected,
        two(data.collected),
        DriverColors.primary500,
        '$_assetRoot/check.svg',
        DriverColors.primary50,
        _openReport,
      ),
      _OutcomeData(
        l10n.supervisorKg,
        two(data.zeroKg),
        DriverColors.slate600,
        '$_assetRoot/scale.svg',
        DriverColors.slate50,
        () => _openLookAt(LookAtOutcome.zeroKg),
      ),
      _OutcomeData(
        l10n.supervisorMissed,
        two(data.missed),
        DriverColors.red600,
        '$_assetRoot/alert.svg',
        DriverColors.red100,
        () => _openLookAt(LookAtOutcome.missed),
      ),
      _OutcomeData(
        l10n.supervisorCancelled,
        two(data.cancelled),
        DriverColors.purple600,
        '$_assetRoot/ban.svg',
        DriverColors.purple50,
        () => _openLookAt(LookAtOutcome.cancelledBySource),
      ),
      _OutcomeData(
        l10n.supervisorTripsToday,
        '05',
        DriverColors.blue600,
        '$_assetRoot/trips_today.svg',
        DriverColors.secondary100,
      ),
    ];

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: ReportPeriodChips(
            keyPrefix: 'supervisor-period',
            selected: _period,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            calendarPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            calendarAsset: '$_assetRoot/calendar.svg',
            onSelected: (p) => setState(() => _period = p),
            onPickDates: _pickDates,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: DriverColors.primary50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DriverColors.summaryBorder),
          ),
          child: Row(
            children: [
              const _IconTile(
                asset: '$_assetRoot/package.svg',
                background: DriverColors.primary50,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      key: const Key('supervisor-summary-label'),
                      l10n.rpCollectedStops(
                        l10n.collectedPeriodLabel(_period),
                        l10n.number(data.collected),
                        l10n.number(data.due),
                      ),
                      style: DriverTextStyles.medium12.copyWith(
                        color: DriverColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.totalText(data),
                      style: DriverTextStyles.bold20.copyWith(
                        color: DriverColors.neutral950,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _StatTileGrid(
          tiles: [
            for (final item in outcomes)
              _StatTile(
                key: Key('supervisor-outcome-${item.asset.split('/').last}'),
                label: item.label,
                value: item.value,
                asset: item.asset,
                iconBackground: item.background,
                valueColor: item.color,
                onTap: item.onTap,
              ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('supervisor-view-full-report'),
            onPressed: _openReport,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: DriverColors.primary500,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              side: const BorderSide(color: DriverColors.primary500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const _Svg('$_assetRoot/chart.svg', size: 20),
            label: Text(
              l10n.supervisorViewFullReport,
              style: DriverTextStyles.bold14,
            ),
          ),
        ),
      ],
    );
  }
}

class _OutcomeData {
  const _OutcomeData(
    this.label,
    this.value,
    this.color,
    this.asset,
    this.background, [
    this.onTap,
  ]);

  final String label;
  final String value;
  final Color color;
  final String asset;
  final Color background;
  final VoidCallback? onTap;
}

class _TripsCard extends StatelessWidget {
  const _TripsCard({required this.l10n});

  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading(
            icon: '$_assetRoot/attention.svg',
            title: l10n.supervisorTodaysTrips,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.supervisorTripsSubtitle,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral700,
            ),
          ),
          const SizedBox(height: 16),
          _TripTile(
            title: l10n.supervisorAdajanMorning,
            progress: l10n.supervisorVikramProgress,
            firstTag: l10n.supervisorOwnVehicle,
            secondTag: l10n.supervisorDailyWeekly,
            secondTagWarning: false,
            button: l10n.supervisorCallDriver,
          ),
          const SizedBox(height: 8),
          _TripTile(
            title: l10n.supervisorPalGamMorning,
            progress: l10n.supervisorAmitProgress,
            firstTag: l10n.supervisorOwnVehicle,
            secondTag: l10n.supervisorDriverNotSetUp,
            secondTagWarning: true,
            button: l10n.supervisorCallDriver,
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('supervisor-see-trips-plan'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const TripsPlanScreen()),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: DriverColors.primary500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              l10n.supervisorSeeTripsPlan,
              style: DriverTextStyles.bold16.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripTile extends StatelessWidget {
  const _TripTile({
    required this.title,
    required this.progress,
    required this.firstTag,
    required this.secondTag,
    required this.secondTagWarning,
    required this.button,
  });

  final String title;
  final String progress;
  final String firstTag;
  final String secondTag;
  final bool secondTagWarning;
  final String button;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: DriverColors.cool100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconTile(
                asset: '$_assetRoot/trip.svg',
                background: Colors.white,
                size: 30,
                iconSize: 20,
                rounded: true,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: DriverTextStyles.semibold16.copyWith(
                    color: DriverColors.primary800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            progress,
            style: DriverTextStyles.regular14.copyWith(
              color: DriverColors.neutral700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _Tag(
                label: firstTag,
                icon: '$_assetRoot/own_vehicle.svg',
                background: DriverColors.secondary100,
                foreground: DriverColors.blue600,
              ),
              _Tag(
                label: secondTag,
                icon: secondTagWarning ? '$_assetRoot/phone_red.svg' : null,
                background: secondTagWarning
                    ? DriverColors.red100
                    : DriverColors.slate50,
                foreground: secondTagWarning
                    ? DriverColors.red600
                    : DriverColors.slate600,
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              backgroundColor: Colors.white,
              foregroundColor: DriverColors.primary500,
              side: const BorderSide(color: DriverColors.primary500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const _Svg('$_assetRoot/phone_green.svg', size: 20),
            label: Text(button, style: DriverTextStyles.bold16),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            _Svg(icon!, size: 14),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DriverTextStyles.semibold12.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupPointsCard extends StatelessWidget {
  const _PickupPointsCard({required this.l10n});

  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (l10n.supervisorDaily, 42, 1.0),
      (l10n.supervisorWeekly, 18, 18 / 42),
      (l10n.supervisorBiWeekly, 6, 6 / 42),
      (l10n.supervisorMonthly, 4, 4 / 42),
      (l10n.supervisorOnCall, 9, 9 / 42),
    ];

    return _SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const _IconTile(
                asset: '$_assetRoot/pin.svg',
                background: DriverColors.primary100,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.supervisorPickupPoints,
                      style: DriverTextStyles.semibold18.copyWith(
                        color: DriverColors.neutral950,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.supervisorPickupPointsSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DriverTextStyles.medium12.copyWith(
                        color: DriverColors.neutral700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final row in rows) ...[
            _ProgressRow(label: row.$1, value: row.$2, fraction: row.$3),
            if (row != rows.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.fraction,
  });

  final String label;
  final int value;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(48),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              color: DriverColors.primary500,
              backgroundColor: DriverColors.slate50,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 24,
          child: Text(
            '$value',
            textAlign: TextAlign.right,
            style: DriverTextStyles.semibold14.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.button,
    this.badge,
    this.onPressed,
  });

  final String icon;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final String button;
  final String? badge;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _IconTile(asset: icon, background: iconBackground),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: DriverTextStyles.semibold18.copyWith(
                        color: DriverColors.neutral950,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: DriverTextStyles.medium14.copyWith(
                  color: DriverColors.neutral700,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: Key('supervisor-quick-action-$button'),
                onPressed: onPressed ?? () {},
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: DriverColors.primary500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  button,
                  style: DriverTextStyles.bold16.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          if (badge != null)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: DriverColors.yellow600,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge!,
                  style: DriverTextStyles.semibold16.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardHeading extends StatelessWidget {
  const _CardHeading({required this.icon, required this.title});

  final String icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconTile(asset: icon, background: DriverColors.primary100),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: DriverTextStyles.semibold18.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
        ),
      ],
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.asset,
    required this.background,
    this.size = 40,
    this.iconSize = 24,
    this.rounded = false,
  });

  final String asset;
  final Color background;
  final double size;
  final double iconSize;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(rounded ? size / 2 : 8),
      ),
      child: _Svg(asset, size: iconSize),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _cardShadow,
      ),
      child: child,
    );
  }
}

class _Svg extends StatelessWidget {
  const _Svg(this.asset, {required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(asset, package: _assetPackage),
    );
  }
}
