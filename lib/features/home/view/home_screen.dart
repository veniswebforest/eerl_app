import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_route_data.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/features/collection/model/collection_entry_state.dart';
import 'package:eerl_app/features/dashboard/model/bottom_nav_item_model.dart';
import 'package:eerl_app/features/dashboard/provider/dashboard_navigation_provider.dart';
import 'package:eerl_app/features/profile/widgets/sync_data_dialog.dart';
import 'package:eerl_app/features/role_switcher/widgets/role_switcher_assets.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/collection_drafts.dart';
import '../widgets/collection_types.dart';
import '../widgets/day_closure.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_drawer.dart';
import '../widgets/online_status_banner.dart';
import '../widgets/quick_actions.dart';
import '../widgets/role_switch_card.dart';
import '../widgets/supervisor_quick_actions.dart';
import '../widgets/supervisor_todays_summary.dart';
import '../widgets/todays_summary.dart';
import '../widgets/zone_selector.dart';

/// Home screen — composes all home widgets from the widget/ folder.
///
/// Each section is a separate, focused widget for maintainability.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<DashboardNavigationProvider>();
    final isSupervisor = navigation.activeRole == DashboardUserRole.supervisor;
    final roleTitle = isSupervisor
        ? context.l10n.roleCollectionSupervisor
        : context.l10n.drawerUserRole;
    final roleZone = isSupervisor
        ? context.l10n.homeSuratNorthZone
        : context.l10n.homeSuratSouthZone;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 360 ? 16.0 : 20.0;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          extendBody: true,
          drawer: const HomeDrawer(),
          onDrawerChanged: navigation.setDrawerOpen,
          drawerScrimColor: Colors.black.withValues(alpha: 0.6),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary200,
                  AppColors.primary100,
                  Colors.white,
                  AppColors.primary100,
                  AppColors.primary200,
                ],
                stops: [0, .16, .76, .92, 1],
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
                      AppScreenHeaderMetrics.topInset + 18,
                      horizontalPadding,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: _CenteredHomeContent(
                        child: HomeAppBar(
                          onNotificationTap: () =>
                              context.push(AppRoutes.notifications),
                          onWalletTap: () => context.push(AppRoutes.wallet),
                          showWalletAction: !isSupervisor,
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
                          child: OnlineStatusBanner(
                            onSyncNowTap: () => showSyncDataDialog(context),
                            subtitle: isSupervisor
                                ? context.l10n.supervisorLastSynced
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        RoleSwitchCard(
                          onSwitchRoleTap: () =>
                              _switchRole(context, navigation),
                          roleTitle: roleTitle,
                          zoneName: roleZone,
                          roleIcon: isSupervisor
                              ? RoleSwitcherAssets.supervisor
                              : RoleSwitcherAssets.agent,
                        ),
                        const SizedBox(height: 24),
                        _CenteredHomeContent(
                          child: isSupervisor
                              ? const SupervisorTodaysSummary()
                              : TodaysSummary(
                                  onWalletTap: () =>
                                      context.push(AppRoutes.wallet),
                                ),
                        ),
                        if (!isSupervisor) ...[
                          const SizedBox(height: 24),
                          _CenteredHomeContent(
                            child: CollectionDrafts(
                              onViewAllTap: () =>
                                  navigation.selectPage('records'),
                              onContinueCollectionTap: () => _openCollection(
                                context,
                                navigation,
                                step: CollectionEntryStep.photos,
                                type: CollectionType.mrfStation,
                                selectedItems: const <int>{0, 1, 3},
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _CenteredHomeContent(
                            child: CollectionTypes(
                              onTypeTap: (type) => _openCollection(
                                context,
                                navigation,
                                type: type,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                        _CenteredHomeContent(
                          child: isSupervisor
                              ? SupervisorQuickActions(
                                  onAssignTaskTap: () => context.push(
                                    AppRoutes.assignSupervisorTask,
                                  ),
                                  onAgentsStatusTap: () =>
                                      context.push(AppRoutes.agentStatus),
                                  onCheckStockTap: () =>
                                      navigation.selectPage('supervisor-stock'),
                                  onApprovalsTap: () =>
                                      context.push(AppRoutes.supervisorExpense),
                                )
                              : QuickActions(
                                  onAddCollectionTap: () =>
                                      _openCollection(context, navigation),
                                  onTasksTap: () =>
                                      context.push(AppRoutes.tasks),
                                  onLogExpenseTap: () =>
                                      context.push(AppRoutes.wallet),
                                ),
                        ),

                        const SizedBox(height: 24),
                        _CenteredHomeContent(
                          child: DayClosure(
                            onEndMyDayTap: () => context.push(
                              AppRoutes.endMyDay,
                              extra: isSupervisor,
                            ),
                          ),
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

  Future<void> _switchRole(
    BuildContext context,
    DashboardNavigationProvider navigation,
  ) async {
    final role = await context.push<DashboardUserRole>(
      AppRoutes.roleSwitcher,
      extra: navigation.activeRole,
    );
    if (context.mounted && role != null && role != navigation.activeRole) {
      navigation.changeRole(role);
    }
  }

  Future<void> _openCollection(
    BuildContext context,
    DashboardNavigationProvider navigation, {
    CollectionEntryStep step = CollectionEntryStep.items,
    CollectionType? type,
    Set<int> selectedItems = const <int>{},
  }) async {
    final saved = await context.push<bool>(
      AppRoutes.addCollection,
      extra: AddCollectionRouteData(
        initialStep: step,
        initialType: type,
        initialSelectedItems: selectedItems,
      ),
    );
    if (context.mounted && saved == true) {
      navigation.showSavedCollections();
    }
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
