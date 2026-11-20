import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';
import 'package:pickup_supervisor/supervisor/model/supervisor_bottom_nav_item.dart';
import 'package:pickup_supervisor/supervisor/view/supervisor_home_screen.dart';
import 'package:pickup_supervisor/supervisor/view/supervisor_routes_screen.dart';
import 'package:pickup_supervisor/supervisor/view/supervisor_sources_screens.dart';
import 'package:pickup_supervisor/supervisor/widgets/supervisor_bottom_navigation.dart';
import 'package:pickup_supervisor/supervisor/widgets/supervisor_home_drawer.dart';

const _assetRoot = 'assets/icons/supervisor/home';

class SupervisorDashboardShell extends StatefulWidget {
  const SupervisorDashboardShell({
    super.key,
    this.activeRole = SupervisorModuleRole.pickupSupervisor,
    this.grantedPermissions = const <String>{},
  });

  final SupervisorModuleRole activeRole;
  final Set<String> grantedPermissions;

  @override
  State<SupervisorDashboardShell> createState() =>
      _SupervisorDashboardShellState();
}

class _SupervisorDashboardShellState extends State<SupervisorDashboardShell> {
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
            drawer: const SupervisorHomeDrawer(),
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
            bottomNavigationBar: SupervisorBottomNavigation(
              items: items,
              selectedIndex: selectedIndex,
              onItemSelected: (index) => setState(() => _selectedIndex = index),
            ),
          );
        },
      ),
    );
  }

  List<SupervisorBottomNavItem> _items(DriverLocalizations l10n) => [
    SupervisorBottomNavItem(
      title: l10n.supervisorHome,
      selectedIcon: '$_assetRoot/nav_home.svg',
      unselectedIcon: '$_assetRoot/nav_home.svg',
      page: SupervisorHomeScreen(
        showBottomNavigation: false,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      pageKey: 'home',
      roles: const {SupervisorModuleRole.pickupSupervisor},
    ),
    SupervisorBottomNavItem(
      title: l10n.sourcesNavLabel,
      selectedIcon: '$_assetRoot/nav_trips.svg',
      unselectedIcon: '$_assetRoot/nav_trips.svg',
      page: const SupervisorSourcesScreen(showBottomNavigation: false),
      pageKey: 'sources',
      roles: const {SupervisorModuleRole.pickupSupervisor},
    ),
    SupervisorBottomNavItem(
      title: l10n.sourcesRoutesNavLabel,
      selectedIcon: '$_assetRoot/nav_sources.svg',
      unselectedIcon: '$_assetRoot/nav_sources.svg',
      page: const SupervisorRoutesScreen(showBottomNavigation: false),
      pageKey: 'routes',
      roles: const {SupervisorModuleRole.pickupSupervisor},
    ),
    SupervisorBottomNavItem(
      title: l10n.sourcesProfileNavLabel,
      selectedIcon: '$_assetRoot/nav_profile.svg',
      unselectedIcon: '$_assetRoot/nav_profile.svg',
      page: _SupervisorTabPlaceholder(title: l10n.sourcesProfileNavLabel),
      pageKey: 'profile',
      roles: const {SupervisorModuleRole.pickupSupervisor},
    ),
  ];
}

class _SupervisorTabPlaceholder extends StatelessWidget {
  const _SupervisorTabPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DriverColors.background,
      child: Center(
        child: Text(
          title,
          style: DriverTextStyles.semibold20.copyWith(
            color: DriverColors.neutral950,
          ),
        ),
      ),
    );
  }
}
