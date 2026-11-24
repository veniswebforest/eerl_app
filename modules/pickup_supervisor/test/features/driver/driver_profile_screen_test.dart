import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/driver/view/driver_home_screen.dart';

void main() {
  Future<void> openProfile(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 1100);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: DriverHomeScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-home-profile-button')));
    await tester.pumpAndSettle();
  }

  testWidgets('home top-right icon opens the driver profile', (tester) async {
    await openProfile(tester);
    expect(find.text('User Profile'), findsOneWidget);
    expect(find.text('Ramesh Kumar'), findsOneWidget);
    expect(find.text('Magdalla Warehouse'), findsOneWidget);
    expect(find.text('SUR-DRV-0007'), findsOneWidget);
    expect(find.text('Sync Data'), findsOneWidget);
  });

  testWidgets('sync then logout flow matches the popups', (tester) async {
    await openProfile(tester);

    await tester.tap(find.byKey(const Key('driver-profile-logout')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('driver-profile-logout-warning')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('driver-profile-logout-no')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('driver-profile-sync-data')));
    await tester.pumpAndSettle();
    expect(find.text('3 changes not sent yet'), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-profile-sync-now')));
    await tester.pumpAndSettle();
    expect(find.text('Data Already Synced'), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-profile-synced-back')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('driver-profile-logout')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('driver-profile-logout-warning')),
      findsNothing,
    );
  });
}
