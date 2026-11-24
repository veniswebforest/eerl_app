import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_dashboard_shell.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_routes_screen.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pumpAndSettle();
  }

  testWidgets('tapping a route card opens the Trips plan screen', (
    tester,
  ) async {
    await pumpScreen(tester, const PickupSupervisorDashboardShell());
    await tester.tap(find.byKey(const Key('supervisor-nav-routes')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('route-card-pal-gam')));
    await tester.pumpAndSettle();
    expect(find.text('Trips plan'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);

    await tester.tap(find.byKey(const Key('module-back-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('supervisor-routes-screen')), findsOneWidget);
  });

  testWidgets('third navigation item opens Routes and preserves search', (
    tester,
  ) async {
    await pumpScreen(tester, const PickupSupervisorDashboardShell());

    await tester.tap(find.byKey(const Key('supervisor-nav-routes')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('supervisor-routes-screen')), findsOneWidget);
    expect(find.text('Routes'), findsOneWidget);
    expect(find.text('Route'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('supervisor-route-search')),
      'Adajan',
    );
    await tester.tap(find.byKey(const Key('supervisor-nav-home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('supervisor-nav-routes')));
    await tester.pumpAndSettle();

    expect(find.text('Adajan'), findsOneWidget);
    expect(find.text('Adajan Morning'), findsOneWidget);
    expect(find.text('Pal Gam Morning'), findsNothing);
  });

  testWidgets('saved Routes frame renders cards and vehicle filters', (
    tester,
  ) async {
    await pumpScreen(tester, const PickupSupervisorRoutesScreen());

    expect(find.text('Pal Gam Morning'), findsOneWidget);
    expect(find.text('Adajan Morning'), findsOneWidget);
    expect(find.byKey(const Key('add-route-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('route-filter-2')));
    await tester.pumpAndSettle();
    expect(find.text('Pal Gam Morning'), findsNothing);
    expect(find.text('Punagam FullDay'), findsOneWidget);
    expect(find.text('Rander Evening'), findsOneWidget);
  });

  testWidgets('empty Routes frame renders exported Figma illustration', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const PickupSupervisorRoutesScreen(showEmpty: true),
    );

    expect(
      find.text('No routes yet. Tap + to make your first route'),
      findsOneWidget,
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.byKey(const Key('add-route-button')), findsOneWidget);
  });
}
