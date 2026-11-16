import 'package:flutter/widgets.dart';

enum DriverRole { driver }

/// Data-only description of a driver dashboard destination.
class DriverBottomNavItem {
  const DriverBottomNavItem({
    required this.title,
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.page,
    required this.pageKey,
    required this.roles,
    this.permission,
  });

  final String title;
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final Widget page;
  final String pageKey;
  final Set<DriverRole> roles;
  final String? permission;

  bool isVisibleFor(DriverRole role, Set<String> grantedPermissions) {
    if (!roles.contains(role)) return false;
    return permission == null ||
        grantedPermissions.isEmpty ||
        grantedPermissions.contains(permission);
  }
}
