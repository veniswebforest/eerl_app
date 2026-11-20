import 'package:flutter/widgets.dart';

/// Application roles that can be used to filter dashboard navigation.
enum DashboardUserRole {
  collectionAgent,
  collectionManager,
  iecAgent,
  supervisor,
  pickupSupervisor,
  admin,
  driver,
}

extension DashboardUserRoleX on DashboardUserRole {
  String get syncMetaKey => switch (this) {
    DashboardUserRole.supervisor => 'SUPERVISOR',
    DashboardUserRole.pickupSupervisor => 'PICKUP_SUPERVISOR',
    DashboardUserRole.admin => 'ADMIN',
    DashboardUserRole.collectionManager => 'COLLECTION_MANAGER',
    DashboardUserRole.iecAgent => 'IEC_AGENT',
    DashboardUserRole.collectionAgent => 'AGENT',
    DashboardUserRole.driver => 'DRIVER',
  };

  static DashboardUserRole fromKey(String? key) {
    if (key == null) return DashboardUserRole.collectionAgent;
    final normalized = key
        .trim()
        .toUpperCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    return switch (normalized) {
      'SUPERVISOR' => DashboardUserRole.supervisor,
      'PICKUP_SUPERVISOR' => DashboardUserRole.pickupSupervisor,
      'ADMIN' => DashboardUserRole.admin,
      'COLLECTION_MANAGER' => DashboardUserRole.collectionManager,
      'IEC_AGENT' => DashboardUserRole.iecAgent,
      'DRIVER' => DashboardUserRole.driver,
      'AGENT' || 'COLLECTION_AGENT' => DashboardUserRole.collectionAgent,
      _ => DashboardUserRole.collectionAgent,
    };
  }
}

/// Describes a single dashboard destination independently of its UI.
class BottomNavItemModel {
  const BottomNavItemModel({
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
  final Set<DashboardUserRole> roles;
  final String? permission;

  bool isVisibleFor(DashboardUserRole role, Set<String> grantedPermissions) {
    if (!roles.contains(role)) return false;
    return permission == null ||
        grantedPermissions.isEmpty ||
        grantedPermissions.contains(permission);
  }
}
