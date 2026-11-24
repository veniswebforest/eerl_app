import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/driver/model/driver_bottom_nav_item.dart';

/// State-preserving shell for driver destinations.
///
/// The selected Figma frame contains only the home destination, so the bar is
/// omitted for a single visible item. Adding another permitted item makes the
/// same model list render the dynamic navigation bar.
class DriverDashboardShell extends StatefulWidget {
  const DriverDashboardShell({
    super.key,
    required this.items,
    this.activeRole = DriverRole.driver,
    this.grantedPermissions = const <String>{},
  });

  final List<DriverBottomNavItem> items;
  final DriverRole activeRole;
  final Set<String> grantedPermissions;

  @override
  State<DriverDashboardShell> createState() => _DriverDashboardShellState();
}

class _DriverDashboardShellState extends State<DriverDashboardShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final visibleItems = widget.items
        .where(
          (item) =>
              item.isVisibleFor(widget.activeRole, widget.grantedPermissions),
        )
        .toList(growable: false);

    assert(visibleItems.isNotEmpty, 'At least one driver page is required.');
    final selectedIndex = _selectedIndex.clamp(0, visibleItems.length - 1);

    return Scaffold(
      backgroundColor: DriverColors.background,
      body: IndexedStack(
        index: selectedIndex,
        children: visibleItems
            .map(
              (item) => KeyedSubtree(
                key: PageStorageKey<String>(item.pageKey),
                child: item.page,
              ),
            )
            .toList(growable: false),
      ),
      bottomNavigationBar: visibleItems.length < 2
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              backgroundColor: DriverColors.surface,
              indicatorColor: DriverColors.primary100,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              destinations: visibleItems
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.unselectedIcon),
                      selectedIcon: Icon(
                        item.selectedIcon,
                        color: DriverColors.primary500,
                      ),
                      label: item.title,
                    ),
                  )
                  .toList(growable: false),
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => DriverTextStyles.medium12.copyWith(
                  color: states.contains(WidgetState.selected)
                      ? DriverColors.primary500
                      : DriverColors.neutral600,
                ),
              ),
            ),
    );
  }
}
