import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/supervisor/view/supervisor_dashboard_shell.dart';
import 'package:pickup_supervisor/supervisor/view/supervisor_home_screen.dart';

void main() {
  testWidgets('renders expanded pickup supervisor dashboard', (tester) async {
    _setDesignSize(tester);
    await tester.pumpWidget(const MaterialApp(home: SupervisorHomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Needs your attention'), findsOneWidget);
    expect(find.text('Collection summary'), findsOneWidget);
    expect(find.text('320 kg + 125 pcs'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Today’s trips'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Today’s trips'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('My pickup points'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('My pickup points'), findsOneWidget);
  });

  testWidgets('summary control switches between both Figma states', (
    tester,
  ) async {
    _setDesignSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: SupervisorHomeScreen(initialSummaryExpanded: false),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('320 kg + 125 pcs'), findsNothing);
    await tester.tap(find.byKey(const Key('supervisor-summary-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('320 kg + 125 pcs'), findsOneWidget);

    await tester.tap(find.byKey(const Key('supervisor-summary-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('320 kg + 125 pcs'), findsNothing);
  });

  testWidgets('bottom navigation remains sticky while home content scrolls', (
    tester,
  ) async {
    _setDesignSize(tester);
    await tester.pumpWidget(const MaterialApp(home: SupervisorHomeScreen()));
    await tester.pumpAndSettle();

    final navigation = find.byKey(const Key('supervisor-bottom-navigation'));
    final initialTop = tester.getTopLeft(navigation).dy;

    await tester.drag(
      find.byKey(const Key('supervisor-home-scroll')),
      const Offset(0, -700),
    );
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(navigation).dy, initialTop);
    expect(tester.getSize(navigation), const Size(335, 70));
  });

  testWidgets('bottom navigation forwards item taps to the dashboard shell', (
    tester,
  ) async {
    _setDesignSize(tester);
    int? selectedIndex;
    await tester.pumpWidget(
      MaterialApp(
        home: SupervisorHomeScreen(
          onNavigationSelected: (index) => selectedIndex = index,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('supervisor-nav-profile')));
    expect(selectedIndex, 3);
  });

  testWidgets('menu icon opens the pickup supervisor drawer', (tester) async {
    _setDesignSize(tester, height: 812);
    await tester.pumpWidget(const MaterialApp(home: SupervisorHomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('supervisor-menu-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('supervisor-home-drawer')), findsOneWidget);
    expect(find.text('Kiran Shah'), findsOneWidget);
    expect(find.text('Pickup Supervisor'), findsOneWidget);
    expect(find.text('Unassigned sources'), findsOneWidget);
    expect(find.text('Drivers and labour'), findsOneWidget);
    expect(find.text('Powered by Eco Vision'), findsOneWidget);

    await tester.tap(
      find.byKey(const Key('supervisor-drawer-unassigned-sources')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('supervisor-home-drawer')), findsNothing);
  });

  testWidgets('dashboard shell opens drawer above the sticky navigation', (
    tester,
  ) async {
    _setDesignSize(tester, height: 812);
    await tester.pumpWidget(
      const MaterialApp(home: SupervisorDashboardShell()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('supervisor-menu-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('supervisor-home-drawer')), findsOneWidget);
    expect(find.text('Extra pickup requests'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });
}

void _setDesignSize(WidgetTester tester, {double height = 900}) {
  tester.view.physicalSize = Size(375, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
