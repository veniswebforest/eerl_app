import 'package:eerl_app/core/router/app_route_data.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/features/dashboard/model/bottom_nav_item_model.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Sends each authenticated role to the dashboard owned by that role.
void goToRoleHome(
  BuildContext context,
  DashboardUserRole role, {
  bool showInitialLoginLoader = false,
}) {
  switch (role) {
    case DashboardUserRole.driver:
      context.go(AppRoutes.driverHome);
      return;
    case DashboardUserRole.pickupSupervisor:
      context.go(AppRoutes.pickupSupervisorHome);
      return;
    case DashboardUserRole.collectionAgent:
    case DashboardUserRole.collectionManager:
    case DashboardUserRole.iecAgent:
    case DashboardUserRole.supervisor:
    case DashboardUserRole.admin:
      context.go(
        AppRoutes.home,
        extra: HomeRouteData(
          role: role,
          showInitialLoginLoader: showInitialLoginLoader,
        ),
      );
      return;
  }
}

String homeLocationForRole(DashboardUserRole role) => switch (role) {
  DashboardUserRole.driver => AppRoutes.driverHome,
  DashboardUserRole.pickupSupervisor => AppRoutes.pickupSupervisorHome,
  _ => AppRoutes.home,
};
