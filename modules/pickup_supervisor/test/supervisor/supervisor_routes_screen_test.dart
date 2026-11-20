import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/supervisor/view/supervisor_dashboard_shell.dart';
import 'package:pickup_supervisor/supervisor/view/supervisor_routes_screen.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pumpAndSettle();
  }

  testWidgets('third navigation item opens Routes and preserves search', (
    tester,
  ) async {
    await pumpScreen(tester, const SupervisorDashboardShell());

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
    await pumpScreen(tester, const SupervisorRoutesScreen());

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
    await pumpScreen(tester, const SupervisorRoutesScreen(showEmpty: true));

    expect(
      find.text('No routes yet. Tap + to make your first route'),
      findsOneWidget,
    );
    expect(find.byType(Image), findsOneWidget);
    expect(find.byKey(const Key('add-route-button')), findsOneWidget);
  });
}
