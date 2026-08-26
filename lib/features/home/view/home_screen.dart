import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import '../widgets/collection_drafts.dart';
import '../widgets/collection_types.dart';
import '../widgets/day_closure.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_drawer.dart';
import '../widgets/online_status_banner.dart';
import '../widgets/quick_actions.dart';
import '../widgets/todays_summary.dart';
import '../widgets/zone_selector.dart';

/// Home screen — composes all home widgets from the widget/ folder.
///
/// Each section is a separate, focused widget for maintainability.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onWalletTap,
    this.onAddCollectionTap,
    this.onHelpSupportTap,
    this.onConfigureMaterialTap,
    this.onTasksTap,
    this.onRequestsTap,
    this.onNotificationTap,
    this.onEndMyDayTap,
    this.onDrawerChanged,
  });

  final VoidCallback? onWalletTap;
  final VoidCallback? onAddCollectionTap;
  final VoidCallback? onHelpSupportTap;
  final VoidCallback? onConfigureMaterialTap;
  final VoidCallback? onTasksTap;
  final VoidCallback? onRequestsTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onEndMyDayTap;
  final ValueChanged<bool>? onDrawerChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 360 ? 16.0 : 20.0;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          extendBody: true,
          drawer: HomeDrawer(
            onWalletTap: onWalletTap,
            onHelpSupportTap: onHelpSupportTap,
            onConfigureMaterialTap: onConfigureMaterialTap,
            onTasksTap: onTasksTap,
            onRequestsTap: onRequestsTap,
          ),
          onDrawerChanged: onDrawerChanged,
          drawerScrimColor: Colors.black.withValues(alpha: 0.6),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary200,
                  AppColors.primary100,
                  AppColors.cool50,
                  AppColors.cool50,
                  AppColors.primary100,
                  AppColors.primary200,
                ],
                stops: [0, .16, .34, .76, .92, 1],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: CustomScrollView(
                key: const Key('home-dashboard-scroll'),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      AppScreenHeaderMetrics.topInset,
                      horizontalPadding,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _CenteredHomeContent(
                        child: HomeAppBar(onNotificationTap: onNotificationTap),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyZoneHeaderDelegate(
                      horizontalPadding: horizontalPadding,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      8,
                      horizontalPadding,
                      148,
                    ),
                    sliver: SliverList.list(
                      children: [
                        const _CenteredHomeContent(child: OnlineStatusBanner()),
                        const SizedBox(height: 24),
                        const _CenteredHomeContent(child: TodaysSummary()),
                        const SizedBox(height: 24),
                        _CenteredHomeContent(
                          child: QuickActions(
                            onAddCollectionTap: onAddCollectionTap,
                            onTasksTap: onTasksTap,
                            onLogExpenseTap: onWalletTap,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const _CenteredHomeContent(child: CollectionTypes()),
                        const SizedBox(height: 24),
                        const _CenteredHomeContent(child: CollectionDrafts()),
                        const SizedBox(height: 24),
                        _CenteredHomeContent(
                          child: DayClosure(onEndMyDayTap: onEndMyDayTap),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CenteredHomeContent extends StatelessWidget {
  const _CenteredHomeContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: child,
    ),
  );
}

class _StickyZoneHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _StickyZoneHeaderDelegate({required this.horizontalPadding});

  final double horizontalPadding;

  @override
  double get minExtent => 76;

  @override
  double get maxExtent => 76;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => DecoratedBox(
    decoration: BoxDecoration(
      color: overlapsContent ? const Color(0xFFF0FAF2) : Colors.transparent,
      boxShadow: overlapsContent
          ? const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ]
          : null,
    ),
    child: Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 8),
      child: const _CenteredHomeContent(child: ZoneSelector()),
    ),
  );

  @override
  bool shouldRebuild(covariant _StickyZoneHeaderDelegate oldDelegate) =>
      horizontalPadding != oldDelegate.horizontalPadding;
}
