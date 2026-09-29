import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/features/collection/view/collections_tab_screen.dart';
import 'package:eerl_app/features/dashboard/provider/dashboard_navigation_provider.dart';
import 'package:eerl_app/features/home/view/home_screen.dart';
import 'package:eerl_app/features/home/widgets/home_assets.dart';
import 'package:eerl_app/features/profile/view/profile_screen.dart';
import 'package:eerl_app/features/records/view/records_tab_screen.dart';
import 'package:eerl_app/features/stock/view/facility_stock_screen.dart';
import 'package:eerl_app/features/verification/view/supervisor_verification_screen.dart';
import 'package:provider/provider.dart';
import '../model/bottom_nav_item_model.dart';
import '../widgets/dynamic_bottom_nav_bar.dart';

const _navIconPath = 'assets/icons/home';

/// Role-aware dashboard shell that preserves each tab's widget state.
class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({
    super.key,
    this.userRole = DashboardUserRole.collectionAgent,
    this.permissions = const <String>{},
    this.initialPageKey = 'home',
  });

  final DashboardUserRole userRole;
  final Set<String> permissions;
  final String initialPageKey;

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  late final DashboardNavigationProvider _navigation;

  @override
  void initState() {
    super.initState();
    _navigation = DashboardNavigationProvider(
      initialRole: widget.userRole,
      initialPageKey: widget.initialPageKey,
    );
    if (widget.initialPageKey == 'wallet') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.push(AppRoutes.wallet);
      });
    }
  }

  @override
  void didUpdateWidget(covariant MainDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _navigation.updateRoleFromParent(widget.userRole);
  }

  @override
  void dispose() {
    _navigation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
    value: _navigation,
    child: Consumer<DashboardNavigationProvider>(
      builder: (context, navigation, _) => _buildDashboard(context, navigation),
    ),
  );

  Widget _buildDashboard(
    BuildContext context,
    DashboardNavigationProvider navigation,
  ) {
    final items = _createItems(context, navigation)
        .where(
          (item) =>
              item.isVisibleFor(navigation.activeRole, widget.permissions),
        )
        .toList(growable: false);
    if (items.isEmpty) {
      return Scaffold(
        body: Center(child: Text(context.l10n.dashboardEmptyMessage)),
      );
    }
    final selectedIndex = items.indexWhere(
      (item) => item.pageKey == navigation.selectedPageKey,
    );
    final safeSelectedIndex = selectedIndex < 0 ? 0 : selectedIndex;

    return PopScope(
      canPop: navigation.selectedPageKey == 'home',
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && navigation.selectedPageKey != 'home') {
          navigation.selectPage('home');
        }
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: safeSelectedIndex,
          children: items.map((item) => item.page).toList(growable: false),
        ),
        bottomNavigationBar: navigation.isDrawerOpen
            ? null
            : DynamicBottomNavBar(
                items: items,
                selectedIndex: safeSelectedIndex,
                onItemSelected: (index) {
                  final selectedItem = items[index];
                  navigation.selectPage(selectedItem.pageKey);
                },
              ),
      ),
    );
  }

  List<BottomNavItemModel> _createItems(
    BuildContext context,
    DashboardNavigationProvider navigation,
  ) {
    const allRoles = <DashboardUserRole>{
      DashboardUserRole.collectionAgent,
      DashboardUserRole.supervisor,
      DashboardUserRole.admin,
    };
    const agentRoles = <DashboardUserRole>{
      DashboardUserRole.collectionAgent,
      DashboardUserRole.admin,
    };
    const supervisorRoles = <DashboardUserRole>{DashboardUserRole.supervisor};

    final l10n = context.l10n;

    return [
      BottomNavItemModel(
        title: l10n.home,
        selectedIcon: navigation.activeRole == DashboardUserRole.supervisor
            ? HomeAssets.supervisorNavHome
            : '$_navIconPath/nav_home.svg',
        unselectedIcon: navigation.activeRole == DashboardUserRole.supervisor
            ? HomeAssets.supervisorNavHome
            : '$_navIconPath/nav_home.svg',
        page: const HomeScreen(),
        pageKey: 'home',
        roles: allRoles,
        permission: 'dashboard.view',
      ),
      BottomNavItemModel(
        title: l10n.drawerCollection,
        selectedIcon: '$_navIconPath/nav_collections.svg',
        unselectedIcon: '$_navIconPath/nav_collections.svg',
        page: const CollectionsTabScreen(),
        pageKey: 'collections',
        roles: agentRoles,
        permission: 'collections.view',
      ),

      BottomNavItemModel(
        title: l10n.records,
        selectedIcon: '$_navIconPath/nav_wallet.svg',
        unselectedIcon: '$_navIconPath/nav_wallet.svg',
        page: RecordsTabScreen(
          key: ValueKey('records-page-${navigation.recordsPageVersion}'),
          initialView: navigation.recordsView,
        ),
        pageKey: 'records',
        roles: agentRoles,
        permission: 'records.view',
      ),
      BottomNavItemModel(
        title: l10n.verificationNav,
        selectedIcon: HomeAssets.supervisorNavTasks,
        unselectedIcon: HomeAssets.supervisorNavTasks,
        page: SupervisorVerificationScreen(
          initialStatus: navigation.verificationStatus,
        ),
        pageKey: 'supervisor-verify',
        roles: supervisorRoles,
      ),
      BottomNavItemModel(
        title: l10n.supervisorStockNav,
        selectedIcon: HomeAssets.supervisorNavStock,
        unselectedIcon: HomeAssets.supervisorNavStock,
        page: const FacilityStockScreen(),
        pageKey: 'supervisor-stock',
        roles: supervisorRoles,
      ),
      BottomNavItemModel(
        title: l10n.profile,
        selectedIcon: navigation.activeRole == DashboardUserRole.supervisor
            ? HomeAssets.supervisorNavProfile
            : '$_navIconPath/nav_profile.svg',
        unselectedIcon: navigation.activeRole == DashboardUserRole.supervisor
            ? HomeAssets.supervisorNavProfile
            : '$_navIconPath/nav_profile.svg',
        page: const ProfileScreen(),
        pageKey: 'profile',
        roles: allRoles,
        permission: 'profile.view',
      ),
    ];
  }
}
