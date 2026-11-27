import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/driver/view/driver_home_screen.dart';

void main() {
  testWidgets('app start: trip not started, Start trip puts it on the way', (
    tester,
  ) async {
    _setDesignSize(tester);
    await tester.pumpWidget(const MaterialApp(home: DriverHomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Thu, 22 Oct · Adajan'), findsOneWidget);
    expect(find.text('Everything is synced'), findsOneWidget);
    expect(find.text('0 kg so far'), findsOneWidget);
    expect(find.text('13'), findsOneWidget);

    final start = find.byKey(const Key('driver-start-trip'));
    await tester.ensureVisible(start);
    await tester.pumpAndSettle();
    for (final t in [
      'Not started',
      '8:00 am – 2:00 pm · 7 stops',
      'GJ-05-BX-1234 · Vikram, Ravi',
      'Drop at Adajan Central Warehouse',
      '0 of 7 stops done',
      'Start trip',
      'Tap when you leave the warehouse. Your supervisor sees the time and place.',
      'See all 7 stops',
    ]) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
    expect(find.text('Starts 2:00 pm'), findsOneWidget);

    await tester.tap(start);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('driver-start-trip')), findsNothing);
    expect(find.text('On the way'), findsOneWidget);
  });

  testWidgets('renders the Figma morning dashboard state', (tester) async {
    _setDesignSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: DriverHomeScreen(viewMode: DriverHomeViewMode.morning),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('driver-home-title')), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Kiran Shah'), findsOneWidget);
    expect(find.text('You’re Online'), findsOneWidget);
    expect(find.text('Todays Summary'), findsOneWidget);
    expect(find.text('420 kg so far'), findsOneWidget);

    await _scrollHomeToBottom(tester);
    expect(find.text('Today’s Trips (2)'), findsOneWidget);
    expect(find.text('Trip 1 · Morning'), findsOneWidget);
    expect(find.text('Report Issue'), findsOneWidget);
  });

  testWidgets('renders the later-in-day dashboard state', (tester) async {
    _setDesignSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: DriverHomeScreen(viewMode: DriverHomeViewMode.laterInDay),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Todays Summary'), findsOneWidget);
    expect(find.text('420 kg so far'), findsNothing);
    expect(find.text('Trip 2 · Afternoon'), findsOneWidget);
    expect(find.text('180 kg'), findsOneWidget);
    expect(find.text('33%'), findsOneWidget);
  });

  testWidgets('renders the Figma no-trip state', (tester) async {
    _setDesignSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: DriverHomeScreen(viewMode: DriverHomeViewMode.noTrip),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0 kg'), findsNWidgets(2));
    await _scrollHomeToBottom(tester);
    expect(find.text('No trip today'), findsOneWidget);
    expect(
      find.text(
        'Kiran Shah hasn’t put you on a trip today. '
        'You’ll get a message when one is added.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('summary visibility control preserves the page shell', (
    tester,
  ) async {
    _setDesignSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: DriverHomeScreen(viewMode: DriverHomeViewMode.laterInDay),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('driver-summary-toggle')));
    await tester.pumpAndSettle();

    expect(find.text('420 kg so far'), findsOneWidget);
    expect(find.byKey(const Key('driver-home-scroll')), findsOneWidget);
  });

  testWidgets('uses Gujarati localization without widget hardcoding', (
    tester,
  ) async {
    _setDesignSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('gu'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: [Locale('en'), Locale('gu'), Locale('hi')],
        home: DriverHomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ફરી સ્વાગત છે'), findsOneWidget);
    expect(find.text('કિરણ શાહ'), findsOneWidget);
    expect(find.text('આજનો સારાંશ'), findsOneWidget);
  });
}

Future<void> _scrollHomeToBottom(WidgetTester tester) async {
  await tester.drag(
    find.byKey(const Key('driver-home-scroll')),
    const Offset(0, -3000),
  );
  await tester.pumpAndSettle();
}

void _setDesignSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
