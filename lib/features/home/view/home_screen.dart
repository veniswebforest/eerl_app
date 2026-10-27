import 'dart:async';

import 'package:flutter/material.dart';

import 'package:eerl_app/core/location/device_location_service.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/shared/widgets/app_snackbar.dart';
import 'package:eerl_app/core/router/app_route_data.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/features/collection/model/collection_entry_state.dart';
import 'package:eerl_app/features/collection/widgets/collection_draft_saved_notification.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/dashboard/model/bottom_nav_item_model.dart';
import 'package:eerl_app/features/dashboard/provider/dashboard_navigation_provider.dart';
import 'package:eerl_app/features/profile/widgets/sync_data_dialog.dart';
import 'package:eerl_app/features/role_switcher/widgets/role_switcher_assets.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import 'package:eerl_app/shared/widgets/loader_widget.dart';
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
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.showInitialLoginLoader = false,
    this.initialLoginSync,
  });

  final bool showInitialLoginLoader;
  final Future<void> Function()? initialLoginSync;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _locationCheckRunning = false;
  bool _waitingForLocationSettings = false;
  late bool _showInitialLoginLoader = widget.showInitialLoginLoader;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showInitialLoginLoader) {
        unawaited(_runInitialLoginSync());
      } else {
        _ensureLocation();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForLocationSettings) {
      _waitingForLocationSettings = false;
      _ensureLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<DashboardNavigationProvider>();
    // Rebuild and re-query outbox counts when an outgoing/bootstrap run starts
    // or finishes. This hides Sync Now immediately after the queue is drained.
    context.watch<BootstrapSyncService>();
    final isSupervisor = navigation.activeRole == DashboardUserRole.supervisor;
    final roleTitle = isSupervisor
        ? context.l10n.roleCollectionSupervisor
        : context.l10n.drawerUserRole;

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 360 ? 16.0 : 20.0;

        return Stack(
          children: [
            Scaffold(
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
                  child: RefreshIndicator(
                    onRefresh: () =>
                        BootstrapSyncService.instance.triggerBootstrap(
                          trigger: BootstrapTrigger.pullToRefresh,
                        ),
                    child: CustomScrollView(
                      key: const Key('home-dashboard-scroll'),
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            AppScreenHeaderMetrics.topInset+8,
                            horizontalPadding,
                            0,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: FutureBuilder<int>(
                              future: EerlLocalRepository.instance
                                  .getActiveRoleUnreadNotificationCount(),
                              builder: (context, snapshot) =>
                                  _CenteredHomeContent(
                                    child: HomeAppBar(
                                      notificationUnreadCount:
                                          snapshot.data ?? 0,
                                      onNotificationTap: () async {
                                        await context.push(
                                          AppRoutes.notifications,
                                        );
                                        if (mounted) setState(() {});
                                      },
                                      onWalletTap: () =>
                                          context.push(AppRoutes.wallet),
                                      showWalletAction: !isSupervisor,
                                    ),
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
                              FutureBuilder<SyncStatusModel>(
                                future: EerlLocalRepository.instance
                                    .getSyncStatus(),
                                builder: (context, snapshot) {
                                  final status = snapshot.data;
                                  final hasOutbox =
                                      status?.hasOutboxEntries ?? false;
                                  return _CenteredHomeContent(
                                    child: OnlineStatusBanner(
                                      pendingCount: status?.outboxCount ?? 0,
                                      onSyncNowTap: hasOutbox
                                          ? () => showSyncDataDialog(
                                              context,
                                              pendingCount: status!.outboxCount,
                                            )
                                          : null,
                                      subtitle: hasOutbox
                                          ? context.l10n.syncPendingItems(
                                              status!.outboxCount,
                                            )
                                          : isSupervisor
                                          ? context.l10n.supervisorLastSynced
                                          : null,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              FutureBuilder<String>(
                                future: _activeCenterName(),
                                builder: (context, snapshot) => RoleSwitchCard(
                                  onSwitchRoleTap: () =>
                                      _switchRole(context, navigation),
                                  roleTitle: roleTitle,
                                  zoneName: snapshot.data ?? '',
                                  roleIcon: isSupervisor
                                      ? RoleSwitcherAssets.supervisor
                                      : RoleSwitcherAssets.agent,
                                ),
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
                                    onContinueCollectionTap: () =>
                                        _openCollection(
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
                                        onAssignTaskTap: () async {
                                          await context.push(
                                            AppRoutes.assignSupervisorTask,
                                          );
                                        },
                                        onAgentsStatusTap: () =>
                                            context.push(AppRoutes.agentStatus),
                                        onCheckStockTap: () => navigation
                                            .selectPage('supervisor-stock'),
                                        onApprovalsTap: () async {
                                          await context.push(
                                            AppRoutes.supervisorExpense,
                                          );
                                        },
                                      )
                                    : QuickActions(
                                        onAddCollectionTap: () =>
                                            _openCollection(
                                              context,
                                              navigation,
                                            ),
                                        onTasksTap: () async {
                                          await context.push(AppRoutes.tasks);
                                        },
                                        onLogExpenseTap: () =>
                                            context.push(AppRoutes.wallet),
                                      ),
                              ),

                              if (!isSupervisor) ...[
                                const SizedBox(height: 24),
                                _CenteredHomeContent(
                                  child: DayClosure(
                                    onEndMyDayTap: () => context.push(
                                      AppRoutes.endMyDay,
                                      extra: false,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_showInitialLoginLoader)
              Positioned.fill(
                key: const Key('home-initial-login-loader'),
                child: ColoredBox(
                  key: const Key('home-initial-login-loader-overlay'),
                  color: Colors.white.withValues(alpha: 0.86),
                  child: SafeArea(
                    child: LoadingWidget(
                      isLoading: true,
                      message: context.l10n.homeInitialDataSyncing,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _runInitialLoginSync() async {
    final sync =
        widget.initialLoginSync ??
        () => BootstrapSyncService.instance.triggerBootstrap(
          trigger: BootstrapTrigger.initialLogin,
        );
    try {
      await Future.wait<void>([
        sync(),
        Future<void>.delayed(const Duration(milliseconds: 500)),
      ]);
    } finally {
      if (mounted) {
        setState(() => _showInitialLoginLoader = false);
        unawaited(_ensureLocation());
      }
    }
  }

  Future<void> _ensureLocation() async {
    if (_locationCheckRunning || !mounted) return;
    _locationCheckRunning = true;
    final state = await DeviceLocationService.instance.requestOnHomeOpen();
    _locationCheckRunning = false;
    if (!mounted) return;
    switch (state) {
      case HomeLocationState.serviceDisabled:
        await _showLocationSettingsDialog(
          title: context.l10n.locationServiceTitle,
          message: context.l10n.locationServiceMessage,
          openSettings: DeviceLocationService.instance.openLocationSettings,
        );
      case HomeLocationState.permissionDeniedForever:
        await _showLocationSettingsDialog(
          title: context.l10n.locationPermissionTitle,
          message: context.l10n.locationPermissionSettingsMessage,
          openSettings: DeviceLocationService.instance.openAppSettings,
        );
      case HomeLocationState.permissionDenied:
        if (mounted) {
          AppSnackbar.error(
            context,
            message: context.l10n.locationPermissionDenied,
          );
        }
      case HomeLocationState.unavailable:
        if (mounted) {
          AppSnackbar.error(context, message: context.l10n.locationUnavailable);
        }
      case HomeLocationState.ready:
        break;
    }
  }

  Future<void> _showLocationSettingsDialog({
    required String title,
    required String message,
    required Future<bool> Function() openSettings,
  }) async {
    final shouldOpen = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.locationNotNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.locationOpenSettings),
          ),
        ],
      ),
    );
    if (shouldOpen != true || !mounted) return;
    _waitingForLocationSettings = true;
    final opened = await openSettings();
    if (!opened && mounted) {
      _waitingForLocationSettings = false;
      AppSnackbar.error(
        context,
        message: context.l10n.locationSettingsUnavailable,
      );
    }
  }

  Future<String> _activeCenterName() async {
    final repository = EerlLocalRepository.instance;
    final centerId = await repository.activeCenterId;
    final centers = await repository.getCenters();
    for (final center in centers) {
      if (center.id == centerId) return center.name;
    }
    return centers.isEmpty ? '' : centers.first.name;
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
      await AppDatabase.instance.setSyncMeta('active_role', role.syncMetaKey);
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
    final result = await context.push<CollectionRouteResult>(
      AppRoutes.addCollection,
      extra: AddCollectionRouteData(
        initialStep: step,
        initialType: type,
        initialSelectedItems: selectedItems,
      ),
    );
    if (!context.mounted) return;
    switch (result) {
      case CollectionRouteResult.draftSaved:
        navigation.showSavedCollections();
        showCollectionDraftSavedNotification(context);
      case CollectionRouteResult.openCollections:
        navigation.selectPage('collections');
      case null:
        break;
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
