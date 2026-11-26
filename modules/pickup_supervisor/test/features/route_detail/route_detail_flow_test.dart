import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';
import 'package:pickup_supervisor/features/route_detail/view/route_detail_screen.dart';
import 'package:pickup_supervisor/features/trips_plan/view/trips_plan_screen.dart';

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
    Size size = const Size(375, 2900),
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

  testWidgets('today list shows the header, filters and every stop state', (
    tester,
  ) async {
    await pump(tester, const RouteDetailScreen());
    expect(find.text('Adajan Morning'), findsOneWidget);
    expect(find.text('On route'), findsOneWidget);
    expect(find.text('GJ-05-BX-1234'), findsOneWidget);
    expect(find.text('Morning (08:00 AM – 02:00 PM)'), findsOneWidget);
    expect(find.text('Assigned Sources : 9 (1 paused)'), findsOneWidget);
    expect(find.text('Driver : Vikram Singh (12345 43210)'), findsOneWidget);
    expect(find.text('Labour : Ravi Bisht'), findsOneWidget);
    expect(find.text('Thu, 22 Oct 2026'), findsOneWidget);
    for (final text in [
      'ABC Textile Mills · Sorted',
      'Shree Sai Dairy · Mixed',
      'City Bakery · Sorted',
      'XYZ Textile Mills · Sorted',
      'Om Sweets · Mixed',
      'Sai Kirana Store · Sorted',
      '350 kg + 25 pcs',
      '270 kg',
      'Mon, Thu · 8–10 am',
      'Collected 8:42 am',
      'Note from driver',
      'Voice note 0:18',
      'Cancelled by source',
      'Next stop',
      'Closed for stock-taking',
      'Paused till 30 Oct',
      'Add sources',
    ]) {
      expect(find.text(text), findsWidgets, reason: text);
    }
  });

  testWidgets('filters narrow the list', (tester) async {
    await pump(tester, const RouteDetailScreen());
    await tester.tap(find.byKey(const Key('route-detail-filter-collected')));
    await tester.pumpAndSettle();
    expect(find.text('ABC Textile Mills · Sorted'), findsOneWidget);
    expect(find.text('City Bakery · Sorted'), findsNothing);
    await tester.tap(find.byKey(const Key('route-detail-filter-pending')));
    await tester.pumpAndSettle();
    expect(find.text('Om Sweets · Mixed'), findsOneWidget);
    expect(find.text('Hotel Rajdhani · Sorted'), findsOneWidget);
    expect(find.text('Shree Sai Dairy · Mixed'), findsNothing);
    await tester.tap(find.byKey(const Key('route-detail-filter-all')));
    await tester.pumpAndSettle();
    expect(find.text('Shree Sai Dairy · Mixed'), findsOneWidget);
  });

  testWidgets('map view shows the legend, next stop and hint', (tester) async {
    await pump(tester, const RouteDetailScreen());
    await tester.tap(find.byKey(const Key('route-detail-view-1')));
    await tester.pumpAndSettle();
    expect(find.text('Warehouse'), findsOneWidget);
    expect(
      find.text('Next: 6 · Om Sweets · 10–12 am · 1.2 km away'),
      findsOneWidget,
    );
    expect(find.textContaining('Tap a stop to open it.'), findsOneWidget);
    expect(find.byKey(const Key('route-detail-map-stop-6')), findsOneWidget);
    expect(find.text('ABC Textile Mills · Sorted'), findsNothing);
    await tester.tap(find.byKey(const Key('route-detail-view-0')));
    await tester.pumpAndSettle();
    expect(find.text('ABC Textile Mills · Sorted'), findsOneWidget);
  });

  testWidgets('next 7 days shows upcoming stops and hint', (tester) async {
    await pump(tester, const RouteDetailScreen());
    await tester.tap(find.byKey(const Key('route-detail-period-1')));
    await tester.pumpAndSettle();
    expect(find.text('Fri 23 Oct – Thu 29 Oct'), findsOneWidget);
    expect(find.text('Assigned Sources : 9 (1 paused)'), findsOneWidget);
    expect(find.text('Started 8:05 am (Start trip)'), findsNothing);
    expect(find.text('Next: Mon 26, Thu 29 Oct'), findsOneWidget);
    expect(find.text('Every day · 7 visits'), findsOneWidget);
    expect(find.text('Next: Thu 29 Oct'), findsNWidgets(2));
    expect(find.text('Inactive'), findsOneWidget);
    expect(
      find.text(
        "It is added as the last stop. You can change the order on the route's page.",
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('route-detail-view-0')), findsNothing);
  });

  testWidgets('a trip in Trips plan opens the route detail', (tester) async {
    await pump(tester, const TripsPlanScreen(), size: const Size(375, 1800));
    await tester.tap(find.text('Adajan Morning').first);
    await tester.pumpAndSettle();
    expect(find.text('Assigned Sources : 9 (1 paused)'), findsOneWidget);
    await tester.tap(find.byKey(const Key('module-back-button')));
    await tester.pumpAndSettle();
    expect(find.text('Trips plan'), findsOneWidget);
  });

  for (final entry in {
    'gu': ['સવાર (08:00 AM – 02:00 PM)', 'લિસ્ટ', 'સોર્સ ઉમેરો'],
    'hi': ['सुबह (08:00 AM – 02:00 PM)', 'सूची', 'सोर्स जोड़ें'],
  }.entries) {
    testWidgets('route detail uses ${entry.key} localization', (tester) async {
      await pump(tester, const RouteDetailScreen(), locale: Locale(entry.key));
      for (final text in entry.value) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
    });
  }

  testWidgets('every state fits a small phone with large text', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);
    for (final screen in const [
      RouteDetailScreen(),
      RouteDetailScreen(initialView: RouteDetailView.map),
      RouteDetailScreen(initialPeriod: RouteDetailPeriod.next7Days),
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
