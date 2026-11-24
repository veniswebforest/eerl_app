import 'package:flutter/widgets.dart';

enum PickupSupervisorModuleRole { pickupSupervisor }

class PickupSupervisorBottomNavItem {
  const PickupSupervisorBottomNavItem({
    required this.title,
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.page,
    required this.pageKey,
    required this.roles,
    this.permission,
  });

  final String title;
  final String selectedIcon;
  final String unselectedIcon;
  final Widget page;
  final String pageKey;
  final Set<PickupSupervisorModuleRole> roles;
  final String? permission;

  bool isVisibleFor(
    PickupSupervisorModuleRole role,
    Set<String> grantedPermissions,
  ) {
    if (!roles.contains(role)) return false;
    return permission == null ||
        grantedPermissions.isEmpty ||
        grantedPermissions.contains(permission);
  }
}
