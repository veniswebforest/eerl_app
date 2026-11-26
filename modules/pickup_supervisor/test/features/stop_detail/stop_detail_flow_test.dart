import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_mock_data.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';
import 'package:pickup_supervisor/features/route_detail/view/route_detail_screen.dart';
import 'package:pickup_supervisor/features/stop_detail/model/stop_detail_models.dart';
import 'package:pickup_supervisor/features/stop_detail/view/skip_source_screen.dart';
import 'package:pickup_supervisor/features/stop_detail/view/stop_detail_screen.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('packages/pickup_supervisor/Manrope');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      loader.addFont(rootBundle.load('assets/font/Manrope-$weight.ttf'));
    }
    await loader.load();
  });

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    Locale? locale,
    Size size = const Size(375, 1400),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('en'), Locale('gu'), Locale('hi')],
        home: home,
      ),
    );
    await tester.pumpAndSettle();
  }

  RouteStop today(String name) =>
      RouteDetailMockData.todayStops.firstWhere((s) => s.name == name);

  testWidgets('pending stop on an on-route trip has no skip', (tester) async {
    await pump(
      tester,
      StopDetailScreen(
        stop: today('Hotel Rajdhani'),
        stopNumber: 8,
        totalStops: 9,
      ),
    );
    for (final text in [
      'Stop detail',
      'Hotel Rajdhani · Sorted',
      'Station Road, Adajan',
      'Every day · 11 am – 1 pm',
      'Adajan Morning · GJ-05-BX-1234 · own vehicle',
      'Kunal Shah · Manager · 98791 33445',
      'Nisha Mehta · 98250 11223',
      'Pending',
      'Today · 11 am – 1 pm',
      'Stop 8 of 9',
      'Call the person at the pickup point',
      'The trip has started. The driver records what happens at this stop.',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.byKey(const Key('stop-detail-skip')), findsNothing);
  });

  testWidgets('next stop shows its distance and no skip', (tester) async {
    await pump(
      tester,
      StopDetailScreen(stop: today('Om Sweets'), stopNumber: 6, totalStops: 9),
    );
    expect(find.text('Next stop'), findsOneWidget);
    expect(
      find.text('Stop 6 of 9 · 1.2 km from the last stop'),
      findsOneWidget,
    );
    expect(find.text('Pinal Joshi · Manager · 98980 22110'), findsOneWidget);
    expect(find.byKey(const Key('stop-detail-skip')), findsNothing);
  });

  testWidgets('skip form needs a reason, and Other needs a note', (
    tester,
  ) async {
    await pump(tester, const SkipSourceScreen(sourceName: 'Shree Sai Dairy'));
    expect(find.text('Skip this pickup'), findsOneWidget);
    expect(find.text('Capacity full at warehouse'), findsOneWidget);
    FilledButton confirm() => tester.widget(
      find.descendant(
        of: find.byKey(const Key('skip-source-confirm')),
        matching: find.byType(FilledButton),
      ),
    );
    expect(confirm().onPressed, isNull);
    await tester.tap(find.byKey(const Key('skip-reason-other')));
    await tester.pump();
    expect(confirm().onPressed, isNull);
    await tester.enterText(find.byKey(const Key('skip-remarks')), 'Gate shut');
    await tester.pump();
    expect(confirm().onPressed, isNotNull);
  });

  testWidgets('planned trip: skip a pickup removes it and shows a toast', (
    tester,
  ) async {
    await pump(
      tester,
      const RouteDetailScreen(tripState: TripState.planned),
      size: const Size(375, 2200),
    );
    expect(find.text('Planned'), findsOneWidget);
    expect(find.text('Fri, 23 Oct 2026'), findsOneWidget);
    expect(find.byKey(const Key('route-detail-view-0')), findsNothing);
    await tester.tap(find.text('Shree Sai Dairy · Mixed'));
    await tester.pumpAndSettle();
    expect(
      find.text('Adajan Morning · Fri 23 Oct · GJ-05-BX-1234'),
      findsOneWidget,
    );
    expect(find.text('Mahesh Desai · Owner · 12345 67890'), findsOneWidget);
    expect(find.text('Fri 23 Oct · 9–11 am'), findsOneWidget);
    expect(find.text('Stop 1 of 7'), findsOneWidget);

    await tester.tap(find.byKey(const Key('stop-detail-skip')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('skip-reason-sourceClosed')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('skip-source-confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Pickup Skipped!'), findsOneWidget);
    expect(
      find.text(
        'Shree Sai Dairy is off Fri 23 Oct’s trip. Next visit: Sat 24 Oct.',
      ),
      findsOneWidget,
    );
    expect(find.text('Shree Sai Dairy · Mixed'), findsNothing);
    expect(find.text('6'), findsWidgets);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('on-route ⋮ opens the on-route actions', (tester) async {
    await pump(tester, const RouteDetailScreen());
    expect(find.text('Trip details'), findsOneWidget);
    expect(find.text('Started 8:05 am (Start trip)'), findsOneWidget);
    await tester.tap(find.byKey(const Key('route-detail-more')));
    await tester.pumpAndSettle();
    expect(find.text('Adajan Morning · on route'), findsOneWidget);
    expect(find.text('Complete trip for the driver'), findsOneWidget);
    expect(find.text('Ask the Collection Head'), findsOneWidget);
    await tester.tap(find.byKey(const Key('route-actions-cancel')));
    await tester.pumpAndSettle();
    expect(find.text('Complete trip for the driver'), findsNothing);
  });

  testWidgets('planned ⋮ opens the today actions', (tester) async {
    await pump(tester, const RouteDetailScreen(tripState: TripState.planned));
    await tester.tap(find.byKey(const Key('route-detail-more')));
    await tester.pumpAndSettle();
    expect(find.text('Change driver or labour'), findsOneWidget);
    expect(find.text('Move stops to another vehicle'), findsOneWidget);
    expect(find.text('Cancel this trip'), findsOneWidget);
    expect(find.text('Switch off the route'), findsOneWidget);
  });

  testWidgets('approved trip is read only with the warehouse result', (
    tester,
  ) async {
    await pump(
      tester,
      const RouteDetailScreen(tripState: TripState.approved),
      size: const Size(375, 3000),
    );
    expect(find.text('Approved'), findsOneWidget);
    expect(find.text('Punagam FullDay'), findsOneWidget);
    expect(find.text('Contract vehicle'), findsOneWidget);
    expect(find.text('Labour : None'), findsOneWidget);
    expect(find.text('At the warehouse'), findsOneWidget);
    expect(find.byKey(const Key('route-detail-more')), findsNothing);
    expect(find.byKey(const Key('route-detail-add-sources')), findsNothing);
    expect(find.text('Entered at gate · 2:05 pm'), findsOneWidget);
    expect(find.text('Missed'), findsWidgets);
    expect(find.text('Not recorded by the driver'), findsOneWidget);
  });

  for (final entry in {
    'gu': ['સ્ટોપ વિગત', 'પિકઅપ પોઇન્ટ પરની વ્યક્તિને કૉલ કરો'],
    'hi': ['स्टॉप विवरण', 'पिकअप पॉइंट वाले व्यक्ति को कॉल करें'],
  }.entries) {
    testWidgets('stop detail uses ${entry.key} localization', (tester) async {
      await pump(
        tester,
        StopDetailScreen(stop: today('Om Sweets')),
        locale: Locale(entry.key),
      );
      for (final text in entry.value) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
    });
  }

  testWidgets('screens fit a small phone with large text', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);
    for (final screen in <Widget>[
      StopDetailScreen(stop: today('Hotel Rajdhani')),
      StopDetailScreen(
        stop: RouteDetailMockData.plannedStops.first,
        tripState: TripState.planned,
      ),
      const SkipSourceScreen(
        sourceName: 'Shree Sai Dairy',
        initialReasons: {SkipReason.sourceClosed, SkipReason.sourceAsked},
        initialRemarks: 'Owner called: the shop is closed tomorrow.',
      ),
      const RouteDetailScreen(tripState: TripState.planned),
      const RouteDetailScreen(tripState: TripState.approved),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: screen,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
