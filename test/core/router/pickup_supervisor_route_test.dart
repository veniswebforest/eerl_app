import 'package:eerl_app/core/router/app_router.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/router/role_home_navigation.dart';
import 'package:eerl_app/features/dashboard/model/bottom_nav_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pickup supervisor has a dedicated home location', () {
    expect(
      homeLocationForRole(DashboardUserRole.pickupSupervisor),
      AppRoutes.pickupSupervisorHome,
    );
    expect(homeLocationForRole(DashboardUserRole.supervisor), AppRoutes.home);
  });

  testWidgets('pickup supervisor route opens its module dashboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final router = AppRouter.createRouter(
      initialLocation: AppRoutes.pickupSupervisorHome,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Needs your attention'), findsOneWidget);
    expect(find.text('You’re Online'), findsOneWidget);
  });
}
