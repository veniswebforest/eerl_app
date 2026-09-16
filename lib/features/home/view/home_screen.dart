import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/features/collection/model/collection_entry_state.dart';
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
    this.onCollectionTap,
    this.onReceiptsTap,
    this.onContinueDraftTap,
    this.onSyncStatusTap,
    this.onSyncNowTap,
    this.onWalletTap,
    this.onAddCollectionTap,
    this.onCollectionTypeTap,
    this.onHelpSupportTap,
    this.onConfigureMaterialTap,
    this.onTasksTap,
    this.onRequestsTap,
    this.onTransferRequestsTap,
    this.onNotificationTap,
    this.onLogoutTap,
    this.onEndMyDayTap,
    this.onDrawerChanged,
  });

  final VoidCallback? onCollectionTap;
  final VoidCallback? onReceiptsTap;
  final VoidCallback? onContinueDraftTap;
  final VoidCallback? onSyncStatusTap;
  final VoidCallback? onSyncNowTap;
  final VoidCallback? onWalletTap;
  final VoidCallback? onAddCollectionTap;
  final ValueChanged<CollectionType>? onCollectionTypeTap;
  final VoidCallback? onHelpSupportTap;
  final VoidCallback? onConfigureMaterialTap;
  final VoidCallback? onTasksTap;
  final VoidCallback? onRequestsTap;
  final VoidCallback? onTransferRequestsTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onLogoutTap;
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
            onCollectionTap: onCollectionTap,
            onReceiptsTap: onReceiptsTap,
            onSyncStatusTap: onSyncStatusTap,
            onNotificationTap: onNotificationTap,
            onLogoutTap: onLogoutTap,
            onWalletTap: onWalletTap,
            onHelpSupportTap: onHelpSupportTap,
            onConfigureMaterialTap: onConfigureMaterialTap,
            onTasksTap: onTasksTap,
            onRequestsTap: onRequestsTap,
            onTransferRequestsTap: onTransferRequestsTap,
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
                        child: HomeAppBar(
                          onNotificationTap: onNotificationTap,
                          onWalletTap: onWalletTap,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    sliver: const SliverToBoxAdapter(
                      child: _CenteredHomeContent(child: ZoneSelector()),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      12,
                      horizontalPadding,
                      148,
                    ),
                    sliver: SliverList.list(
                      children: [
                        _CenteredHomeContent(
                          child: OnlineStatusBanner(onSyncNowTap: onSyncNowTap),
                        ),
                        const SizedBox(height: 24),
                        _CenteredHomeContent(
                          child: TodaysSummary(onWalletTap: onWalletTap),
                        ),
                        const SizedBox(height: 24),

                        _CenteredHomeContent(
                          child: CollectionDrafts(
                            onViewAllTap: onReceiptsTap,
                            onContinueCollectionTap: onContinueDraftTap,
                          ),
                        ),
                        const SizedBox(height: 24),_CenteredHomeContent(
                          child: CollectionTypes(
                            onTypeTap: onCollectionTypeTap,
                          ),
                        ),

                        const SizedBox(height: 24),
                        _CenteredHomeContent(
                          child: QuickActions(
                            onAddCollectionTap: onAddCollectionTap,
                            onTasksTap: onTasksTap,
                            onLogExpenseTap: onWalletTap,
                          ),
                        ),

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
