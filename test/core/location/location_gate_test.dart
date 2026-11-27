import 'dart:async';

import 'package:eerl_app/core/location/device_location_service.dart';
import 'package:eerl_app/core/location/location_gate.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HomeLocationState current;
  late List<bool> requests;
  late StreamController<bool> service;
  var openedLocation = 0;
  var openedApp = 0;
  var ready = 0;

  setUp(() {
    requests = [];
    service = StreamController<bool>.broadcast();
    openedLocation = 0;
    openedApp = 0;
    ready = 0;
  });
  tearDown(() => service.close());

  Future<void> pump(WidgetTester tester, HomeLocationState start) async {
    current = start;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LocationGate(
          checkAccess: ({bool request = false}) async {
            requests.add(request);
            return current;
          },
          serviceChanges: service.stream,
          openLocationSettings: () async => ++openedLocation > 0,
          openAppSettings: () async => ++openedApp > 0,
          onReady: () => ready++,
          child: const Scaffold(body: Text('app')),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder gate() => find.byKey(const Key('location-gate'));

  testWidgets('asks once at app open and lets the app through when ready', (
    tester,
  ) async {
    await pump(tester, HomeLocationState.ready);
    expect(requests, [true]);
    expect(gate(), findsNothing);
    expect(ready, 1);
  });

  testWidgets('GPS off: blocks, opens location settings, clears on resume', (
    tester,
  ) async {
    await pump(tester, HomeLocationState.serviceDisabled);
    expect(gate(), findsOneWidget);
    expect(find.text('Turn on location'), findsWidgets);

    await tester.tap(find.byKey(const Key('location-gate-action')));
    await tester.pumpAndSettle();
    expect(openedLocation, 1);

    current = HomeLocationState.ready;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(gate(), findsNothing);
    expect(ready, 1);
  });

  testWidgets('GPS switched off while open shows the page at once', (
    tester,
  ) async {
    await pump(tester, HomeLocationState.ready);
    current = HomeLocationState.serviceDisabled;
    service.add(false);
    await tester.pumpAndSettle();
    expect(gate(), findsOneWidget);
  });

  testWidgets('permission denied: Allow asks again', (tester) async {
    await pump(tester, HomeLocationState.permissionDenied);
    expect(find.text('Allow location'), findsOneWidget);
    current = HomeLocationState.ready;
    await tester.tap(find.byKey(const Key('location-gate-action')));
    await tester.pumpAndSettle();
    expect(requests.last, isTrue);
    expect(gate(), findsNothing);
  });

  testWidgets('denied for good: opens app settings', (tester) async {
    await pump(tester, HomeLocationState.permissionDeniedForever);
    await tester.tap(find.byKey(const Key('location-gate-action')));
    await tester.pumpAndSettle();
    expect(openedApp, 1);
    expect(gate(), findsOneWidget);
  });

  testWidgets('a fix that is merely unavailable does not block', (
    tester,
  ) async {
    await pump(tester, HomeLocationState.unavailable);
    expect(gate(), findsNothing);
    expect(find.text('app'), findsOneWidget);
  });
}
