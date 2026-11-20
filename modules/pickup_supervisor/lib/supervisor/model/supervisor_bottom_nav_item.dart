import 'package:flutter/widgets.dart';

enum SupervisorModuleRole { pickupSupervisor }

class SupervisorBottomNavItem {
  const SupervisorBottomNavItem({
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
  final Set<SupervisorModuleRole> roles;
  final String? permission;

  bool isVisibleFor(SupervisorModuleRole role, Set<String> grantedPermissions) {
    if (!roles.contains(role)) return false;
    return permission == null ||
        grantedPermissions.isEmpty ||
        grantedPermissions.contains(permission);
  }
}
