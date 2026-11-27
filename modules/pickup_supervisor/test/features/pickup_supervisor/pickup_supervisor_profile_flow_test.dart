import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_dashboard_shell.dart';
import 'package:pickup_supervisor/features/profile/view/pickup_supervisor_profile_screens.dart';

void main() {
  testWidgets('profile tab opens and sync state controls logout warning', (
    tester,
  ) async {
    _setDesignSize(tester);
    await tester.pumpWidget(
      const MaterialApp(home: PickupSupervisorDashboardShell()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('supervisor-nav-profile')));
    await tester.pumpAndSettle();
    expect(find.text('User Profile'), findsOneWidget);
    expect(find.text('Kiran Shah'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('profile-sync-data')));
    await tester.tap(find.byKey(const Key('profile-sync-data')));
    await tester.pumpAndSettle();
    expect(find.text('Sync Offline Data'), findsOneWidget);
    expect(find.text('3 changes not sent yet'), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile-sync-now')));
    await tester.pumpAndSettle();
    expect(find.text('Data Already Synced'), findsOneWidget);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('profile-logout')));
    await tester.tap(find.byKey(const Key('profile-logout')));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to log out?'), findsOneWidget);
    expect(find.text('Send changes to notify drivers'), findsNothing);
  });

  testWidgets('Logout: No keeps you in, Yes calls the host sign-out', (
    tester,
  ) async {
    _setDesignSize(tester);
    var loggedOut = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: PickupSupervisorDashboardShell(
          onLogout: (_) async => loggedOut++,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('supervisor-nav-profile')));
    await tester.pumpAndSettle();

    Future<void> openLogout() async {
      await tester.ensureVisible(find.byKey(const Key('profile-logout')));
      await tester.tap(find.byKey(const Key('profile-logout')));
      await tester.pumpAndSettle();
    }

    await openLogout();
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
    expect(loggedOut, 0);
    expect(find.text('Are you sure you want to log out?'), findsNothing);

    await openLogout();
    await tester.tap(find.byKey(const Key('profile-logout-yes')));
    await tester.pumpAndSettle();
    expect(loggedOut, 1);
    expect(find.text('Are you sure you want to log out?'), findsNothing);
  });

  testWidgets('notifications list and empty state match both designs', (
    tester,
  ) async {
    _setDesignSize(tester);
    await _pumpLocalized(tester, const PickupSupervisorNotificationsScreen());
    expect(find.text('Offline Mode'), findsOneWidget);
    expect(find.text('Driver Escalation'), findsOneWidget);

    await _pumpLocalized(
      tester,
      const PickupSupervisorNotificationsScreen(showEmpty: true),
    );
    expect(find.text('All Caught Up!'), findsOneWidget);
    expect(find.textContaining('no new notifications'), findsOneWidget);
  });

  testWidgets('help FAQ expands and end-day share dialog opens', (
    tester,
  ) async {
    _setDesignSize(tester);
    await _pumpLocalized(tester, const PickupSupervisorHelpSupportScreen());
    expect(find.text('Frequently Asked Questions'), findsOneWidget);
    expect(
      find.text(
        'Generated automatically each morning from your Master Routes.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('profile-faq-1')));
    await tester.pumpAndSettle();
    expect(
      find.text('Open today\'s route and use the driver edit action.'),
      findsOneWidget,
    );
  });
}

Future<void> _pumpLocalized(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(home: DriverLocalizationScope(child: child)),
  );
  await tester.pumpAndSettle();
}

void _setDesignSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
