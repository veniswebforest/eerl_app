import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_dashboard_shell.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_sources_screens.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pumpAndSettle();
  }

  testWidgets('second navigation item opens Sources and preserves state', (
    tester,
  ) async {
    await pumpScreen(tester, const PickupSupervisorDashboardShell());

    await tester.tap(find.byKey(const Key('supervisor-nav-sources')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('supervisor-sources-screen')), findsOneWidget);
    expect(find.text('Sources'), findsOneWidget);

    final search = find.byKey(const Key('supervisor-source-search'));
    await tester.enterText(search, 'Shree');
    await tester.tap(find.byKey(const Key('supervisor-nav-home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('supervisor-nav-sources')));
    await tester.pumpAndSettle();
    expect(find.text('Shree'), findsOneWidget);
  });

  testWidgets('Sources and Extra Pickups tabs match selected frames', (
    tester,
  ) async {
    await pumpScreen(tester, const PickupSupervisorSourcesScreen());

    expect(find.text('Adajan Textile Mill · Sorted'), findsOneWidget);
    await tester.tap(find.byKey(const Key('sources-tab-1')));
    await tester.pumpAndSettle();
    expect(find.text('Mahavir Paper Mill · Sorted'), findsOneWidget);
    expect(find.text('Sat 24 Oct · 11 am–12 pm'), findsOneWidget);
  });

  testWidgets('empty Sources state renders the exported illustration', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const PickupSupervisorSourcesScreen(showEmpty: true),
    );

    expect(find.text('No Unassigned trips available'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('sorted source opens detail, route picker, and success popup', (
    tester,
  ) async {
    await pumpScreen(tester, const PickupSupervisorSourcesScreen());

    await tester.tap(find.text('Adajan Textile Mill · Sorted'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('supervisor-source-detail-sorted')),
      findsOneWidget,
    );
    expect(find.text('Milk Pouch, Card Board'), findsOneWidget);

    await tester.tap(find.byKey(const Key('source-add-to-route')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('supervisor-assign-source-route-screen')),
      findsOneWidget,
    );
    expect(find.text('Pal Gam Morning'), findsOneWidget);

    await tester.tap(find.byKey(const Key('source-assign-anyway')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('source-added-dialog')), findsOneWidget);
    expect(find.text('Source Added to Route'), findsOneWidget);
  });

  testWidgets('mixed source detail uses the mixed material state', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const PickupSupervisorSourceDetailScreen(
        mixed: true,
        sourceName: 'Shree Sai Dairy',
      ),
    );

    expect(
      find.byKey(const Key('supervisor-source-detail-mixed')),
      findsOneWidget,
    );
    expect(find.text('Mixed'), findsOneWidget);
    expect(find.text('Milk Pouch, Card Board'), findsNothing);
  });
}
