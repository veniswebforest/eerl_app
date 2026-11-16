import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/driver/model/driver_bottom_nav_item.dart';
import 'package:pickup_supervisor/driver/view/driver_dashboard_shell.dart';
import 'package:pickup_supervisor/driver/view/driver_raise_issue_screen.dart';
import 'package:pickup_supervisor/driver/view/driver_stops_screen.dart';
import 'package:pickup_supervisor/driver/widgets/driver_dashboard_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _assetRoot = 'assets/icons/driver';
const _assetPackage = 'pickup_supervisor';

/// First screen for users whose authenticated role is `DRIVER`.
class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DriverLocalizationScope(child: _LocalizedDriverHome());
  }
}

class _LocalizedDriverHome extends StatelessWidget {
  const _LocalizedDriverHome();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverDashboardShell(
      items: [
        DriverBottomNavItem(
          title: l10n.homeTab,
          selectedIcon: Icons.home_rounded,
          unselectedIcon: Icons.home_outlined,
          page: const _DriverHomePage(),
          pageKey: 'driver-home',
          roles: const {DriverRole.driver},
          permission: 'driver.home.view',
        ),
      ],
    );
  }
}

class _DriverHomePage extends StatefulWidget {
  const _DriverHomePage();

  @override
  State<_DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<_DriverHomePage> {
  bool _showSummary = true;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final topInset = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: DriverColors.background,
        child: Stack(
          children: [
            const Positioned.fill(child: _PageGradient()),
            LayoutBuilder(
              builder: (context, constraints) {
                final pageWidth = math.min(constraints.maxWidth, 480.0);
                return Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: pageWidth,
                    height: constraints.maxHeight,
                    child: CustomScrollView(
                      key: const Key('driver-home-scroll'),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _DashboardHeader(
                            topInset: topInset,
                            showSummary: _showSummary,
                            onToggleSummary: () {
                              setState(() => _showSummary = !_showSummary);
                            },
                          ),
                        ),
                        const SliverPadding(padding: EdgeInsets.only(top: 16)),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            math.max(MediaQuery.paddingOf(context).bottom, 20),
                          ),
                          sliver: SliverList.list(
                            children: [
                              DriverSectionTitle(title: l10n.todaysTrip),
                              const SizedBox(height: 16),
                              _TripCard(isSummaryVisible: _showSummary),
                              const SizedBox(height: 24),
                              DriverSectionTitle(title: l10n.quickAction),
                              const SizedBox(height: 16),
                              const _IssueCard(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PageGradient extends StatelessWidget {
  const _PageGradient();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 200),
        const Spacer(),
        Container(
          height: 140,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00FAFAF8), Color(0xFFD6F3DC)],
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.topInset,
    required this.showSummary,
    required this.onToggleSummary,
  });

  final double topInset;
  final bool showSummary;
  final VoidCallback onToggleSummary;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(20, topInset + 18, 20, 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFC9F1D1), Color(0xFFE7F6EA), Color(0xFFFAFAF8)],
          stops: [0, 0.58, 1],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.welcomeBack,
            key: const Key('driver-home-title'),
            style: DriverTextStyles.semibold20.copyWith(
              color: DriverColors.primary950,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.homeDateAndZone,
            style: DriverTextStyles.medium12.copyWith(
              color: DriverColors.neutral600,
            ),
          ),
          const SizedBox(height: 24),
          _WarehouseCard(label: l10n.warehouseName),
          const SizedBox(height: 12),
          const _OnlineStatusCard(),
          const SizedBox(height: 24),
          DriverSectionTitle(
            title: l10n.todaysSummary,
            trailing: InkResponse(
              key: const Key('driver-summary-toggle'),
              onTap: onToggleSummary,
              radius: 24,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: SvgPicture.asset(
                  showSummary
                      ? '$_assetRoot/summary_visible.svg'
                      : '$_assetRoot/summary_hidden.svg',
                  package: _assetPackage,
                  width: 28,
                  height: 28,
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: showSummary
                ? const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: _SummaryCards(),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _WarehouseCard extends StatelessWidget {
  const _WarehouseCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: DriverColors.surface,
        border: Border.all(color: DriverColors.primary500),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const DriverSvgTile(
            key: Key('driver-home-icon'),
            asset: '$_assetRoot/warehouse.svg',
            backgroundColor: DriverColors.primary50,
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DriverTextStyles.semibold14.copyWith(
                color: DriverColors.neutral950,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlineStatusCard extends StatelessWidget {
  const _OnlineStatusCard();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return SizedBox(
      height: 76,
      child: DriverSurfaceCard(
        child: Row(
          children: [
            const DriverSvgTile(
              asset: '$_assetRoot/online.svg',
              backgroundColor: DriverColors.primary50,
              radius: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.onlineStatus,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DriverTextStyles.semibold16.copyWith(
                      color: DriverColors.primary500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.pendingCollections(3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DriverTextStyles.medium14.copyWith(
                      color: DriverColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 40,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  backgroundColor: DriverColors.primary500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: DriverTextStyles.bold12,
                ),
                child: FittedBox(child: Text(l10n.syncNow)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return SizedBox(
      height: 122,
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: '$_assetRoot/pending_stops.svg',
              iconBackground: DriverColors.yellow50,
              label: l10n.pendingStops,
              value: l10n.pendingStopsCount,
              valueColor: DriverColors.yellow600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SummaryCard(
              icon: '$_assetRoot/collected.svg',
              iconBackground: DriverColors.primary100,
              label: l10n.collected,
              value: l10n.collectedCount,
              valueColor: DriverColors.primary500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.iconBackground,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String icon;
  final Color iconBackground;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return DriverSurfaceCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DriverSvgTile(asset: icon, backgroundColor: iconBackground),
          const SizedBox(height: 8),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: DriverTextStyles.semibold14.copyWith(
                    color: DriverColors.neutral900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: DriverTextStyles.semibold18.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.isSummaryVisible});

  final bool isSummaryVisible;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverSurfaceCard(
      child: Column(
        children: [
          Row(
            children: [
              const DriverSvgTile(
                asset: '$_assetRoot/trip.svg',
                backgroundColor: DriverColors.secondary100,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.vehicleRegistration,
                style: DriverTextStyles.semibold18.copyWith(
                  color: DriverColors.neutral950,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.stopsCompleted(isSummaryVisible ? 3 : 8, 8),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.medium14.copyWith(
                    color: DriverColors.neutral700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isSummaryVisible
                    ? l10n.tripProgress
                    : l10n.completedTripProgress,
                style: DriverTextStyles.semibold14.copyWith(
                  color: DriverColors.primary500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(48),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: isSummaryVisible ? 0.37 : 1,
              color: DriverColors.primary500,
              backgroundColor: DriverColors.cool200,
            ),
          ),
          const SizedBox(height: 16),
          DriverPrimaryButton(
            label: l10n.openMyStops,
            height: 44,
            radius: 10,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                settings: const RouteSettings(
                  name: DriverStopsScreen.routeName,
                ),
                builder: (_) => const DriverStopsScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  const _IssueCard();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const DriverSvgTile(
                asset: '$_assetRoot/issue.svg',
                backgroundColor: DriverColors.red100,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.raiseAnIssue,
                  style: DriverTextStyles.semibold18.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.issueDescription,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral700,
            ),
          ),
          const SizedBox(height: 16),
          DriverPrimaryButton(
            label: l10n.reportIssue,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const DriverRaiseIssueScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
