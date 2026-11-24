import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';
import 'package:pickup_supervisor/features/driver_labour/view/driver_labour_directory_screen.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/model/pickup_supervisor_bottom_nav_item.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_home_screen.dart';
import 'package:pickup_supervisor/features/profile/view/pickup_supervisor_profile_screens.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_routes_screen.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_sources_screens.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/widgets/pickup_supervisor_bottom_navigation.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/widgets/pickup_supervisor_home_drawer.dart';

const _assetRoot = 'assets/icons/supervisor/home';

class PickupSupervisorDashboardShell extends StatefulWidget {
  const PickupSupervisorDashboardShell({
    super.key,
    this.activeRole = PickupSupervisorModuleRole.pickupSupervisor,
    this.grantedPermissions = const <String>{},
  });

  final PickupSupervisorModuleRole activeRole;
  final Set<String> grantedPermissions;

  @override
  State<PickupSupervisorDashboardShell> createState() =>
      _PickupSupervisorDashboardShellState();
}

class _PickupSupervisorDashboardShellState
    extends State<PickupSupervisorDashboardShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: Builder(
        builder: (context) {
          final l10n = DriverLocalizations.of(context);
          final items = _items(l10n)
              .where(
                (item) => item.isVisibleFor(
                  widget.activeRole,
                  widget.grantedPermissions,
                ),
              )
              .toList(growable: false);
          final selectedIndex = _selectedIndex.clamp(0, items.length - 1);
          return Scaffold(
            key: _scaffoldKey,
            extendBody: true,
            backgroundColor: DriverColors.background,
            drawer: PickupSupervisorHomeDrawer(
              onItemSelected: (item) {
                if (item == 'notifications') {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DriverLocalizationScope(
                        child: PickupSupervisorNotificationsScreen(),
                      ),
                    ),
                  );
                } else if (item == 'help-support') {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DriverLocalizationScope(
                        child: PickupSupervisorHelpSupportScreen(),
                      ),
                    ),
                  );
                } else if (item == 'drivers-labour') {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DriverLabourDirectoryScreen(),
                    ),
                  );
                } else if (item == 'logout') {
                  setState(() => _selectedIndex = 3);
                }
              },
            ),
            drawerScrimColor: Colors.black.withValues(alpha: .6),
            body: IndexedStack(
              index: selectedIndex,
              children: items
                  .map(
                    (item) => KeyedSubtree(
                      key: PageStorageKey<String>(item.pageKey),
                      child: item.page,
                    ),
                  )
                  .toList(growable: false),
            ),
            bottomNavigationBar: PickupSupervisorBottomNavigation(
              items: items,
              selectedIndex: selectedIndex,
              onItemSelected: (index) => setState(() => _selectedIndex = index),
            ),
          );
        },
      ),
    );
  }

  List<PickupSupervisorBottomNavItem> _items(DriverLocalizations l10n) => [
    PickupSupervisorBottomNavItem(
      title: l10n.supervisorHome,
      selectedIcon: '$_assetRoot/nav_home.svg',
      unselectedIcon: '$_assetRoot/nav_home.svg',
      page: PickupSupervisorHomeScreen(
        showBottomNavigation: false,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      pageKey: 'home',
      roles: const {PickupSupervisorModuleRole.pickupSupervisor},
    ),
    PickupSupervisorBottomNavItem(
      title: l10n.sourcesNavLabel,
      selectedIcon: '$_assetRoot/nav_trips.svg',
      unselectedIcon: '$_assetRoot/nav_trips.svg',
      page: const PickupSupervisorSourcesScreen(showBottomNavigation: false),
      pageKey: 'sources',
      roles: const {PickupSupervisorModuleRole.pickupSupervisor},
    ),
    PickupSupervisorBottomNavItem(
      title: l10n.sourcesRoutesNavLabel,
      selectedIcon: '$_assetRoot/nav_sources.svg',
      unselectedIcon: '$_assetRoot/nav_sources.svg',
      page: const PickupSupervisorRoutesScreen(showBottomNavigation: false),
      pageKey: 'routes',
      roles: const {PickupSupervisorModuleRole.pickupSupervisor},
    ),
    PickupSupervisorBottomNavItem(
      title: l10n.sourcesProfileNavLabel,
      selectedIcon: '$_assetRoot/nav_profile.svg',
      unselectedIcon: '$_assetRoot/nav_profile.svg',
      page: const PickupSupervisorProfileScreen(),
      pageKey: 'profile',
      roles: const {PickupSupervisorModuleRole.pickupSupervisor},
    ),
  ];
}
