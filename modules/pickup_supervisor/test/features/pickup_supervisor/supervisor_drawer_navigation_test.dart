import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_dashboard_shell.dart';

/// The Pickup Supervisor drawer: Unassigned sources and Routes switch the
/// bottom tab, Extra pickup requests opens its form, Sync status opens the
/// profile's sync dialog.
void main() {
  Future<void> openDrawerItem(WidgetTester tester, String item) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 900);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(home: PickupSupervisorDashboardShell()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('supervisor-menu-button')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(Key('supervisor-drawer-$item')));
    await tester.tap(find.byKey(Key('supervisor-drawer-$item')));
    await tester.pumpAndSettle();
  }

  bool onstage(WidgetTester tester, String key) =>
      find.byKey(Key(key)).hitTestable().evaluate().isNotEmpty;

  testWidgets('Unassigned sources opens the Sources tab', (tester) async {
    await openDrawerItem(tester, 'unassigned-sources');
    expect(find.byKey(const Key('supervisor-home-drawer')), findsNothing);
    expect(onstage(tester, 'supervisor-sources-screen'), isTrue);
  });

  testWidgets('Routes opens the Routes tab', (tester) async {
    await openDrawerItem(tester, 'routes');
    expect(onstage(tester, 'supervisor-routes-screen'), isTrue);
  });

  testWidgets('Extra pickup requests opens Sources on Extra pickups', (
    tester,
  ) async {
    await openDrawerItem(tester, 'extra-pickup');
    expect(onstage(tester, 'supervisor-sources-screen'), isTrue);
    // The second tab's list: the extra pickup, not the sources.
    expect(find.text('Mahavir Paper Mill · Sorted'), findsOneWidget);
    expect(find.text('Adajan Textile Mill · Sorted'), findsNothing);

    // Unassigned sources goes back to the first tab.
    await tester.tap(find.byKey(const Key('supervisor-nav-home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('supervisor-menu-button')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('supervisor-drawer-unassigned-sources')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Adajan Textile Mill · Sorted'), findsOneWidget);
  });

  testWidgets('Sync status opens the profile sync dialogs', (tester) async {
    await openDrawerItem(tester, 'sync-status');
    expect(find.text('Sync Offline Data'), findsOneWidget);
    await tester.tap(find.byKey(const Key('profile-sync-now')));
    await tester.pumpAndSettle();
    expect(find.text('Data Already Synced'), findsOneWidget);
  });
}
