import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_mock_data.dart';
import 'package:pickup_supervisor/features/route_detail/view/route_detail_screen.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';
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

  final today = RouteDetailMockData.todayStops;
  RouteStop byName(String name) => today.firstWhere((s) => s.name == name);

  testWidgets('pending stop detail shows every section', (tester) async {
    await pump(tester, StopDetailScreen(stop: byName('Shree Sai Dairy')));
    for (final text in [
      'Address',
      'Open in Google Maps',
      'Schedule',
      'Person at the pickup point',
      'IEC Executive',
      'Pickup category',
      'Material',
      'Pickup Status',
      'Warehouse',
      'Adajan Central Warehouse',
      'Skip For Today',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('Call'), findsNWidgets(2));
  });

  testWidgets('mixed stop shows the chip without a material list', (
    tester,
  ) async {
    await pump(tester, StopDetailScreen(stop: byName('Om Sweets')));
    expect(find.text('Mixed'), findsOneWidget);
    expect(find.text('Milk Pouch, Card Board'), findsNothing);
    expect(find.text('Next Stop'), findsOneWidget);
  });

  testWidgets('confirm skip is disabled until a reason is selected', (
    tester,
  ) async {
    await pump(tester, const SkipSourceScreen(sourceName: 'Hotel Rajdhani'));
    FilledButton button() => tester.widget(
      find.descendant(
        of: find.byKey(const Key('skip-source-confirm')),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button().onPressed, isNull);
    await tester.tap(find.byKey(const Key('skip-reason-sourceClosed')));
    await tester.pump();
    expect(button().onPressed, isNotNull);
    await tester.tap(find.byKey(const Key('skip-reason-sourceClosed')));
    await tester.pump();
    expect(button().onPressed, isNull);
  });

  testWidgets('skip from route detail shows the Source Skipped toast', (
    tester,
  ) async {
    await pump(
      tester,
      const RouteDetailScreen(initialPeriod: RouteDetailPeriod.next7Days),
      size: const Size(375, 2200),
    );
    await tester.tap(find.byType(InkWell).at(2));
    await tester.pumpAndSettle();
    expect(find.text('Skip For Today'), findsOneWidget);
    await tester.tap(find.byKey(const Key('stop-detail-skip')));
    await tester.pumpAndSettle();
    expect(find.text('Skip Source'), findsOneWidget);
    await tester.tap(find.byKey(const Key('skip-reason-vehicleUnavailable')));
    await tester.enterText(
      find.byKey(const Key('skip-remarks')),
      'Shift ending',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('skip-source-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Source Skipped!'), findsOneWidget);
    expect(find.text('Resumes tomorrow automatically.'), findsOneWidget);
    expect(find.text('Next Stop'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Source Skipped!'), findsNothing);
  });

  testWidgets('today list item opens the stop detail', (tester) async {
    await pump(tester, const RouteDetailScreen(), size: const Size(375, 3200));
    await tester.tap(find.text('City Bakery · Sorted'));
    await tester.pumpAndSettle();
    expect(find.text('City Bakery'), findsOneWidget);
    expect(find.text('Skip For Today'), findsOneWidget);
  });

  for (final entry in {
    'gu': ['આજ માટે છોડો', 'સરનામું'],
    'hi': ['आज के लिए छोड़ें', 'पता'],
  }.entries) {
    testWidgets('stop detail uses ${entry.key} localization', (tester) async {
      await pump(
        tester,
        StopDetailScreen(stop: byName('Om Sweets')),
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
      StopDetailScreen(stop: byName('Shree Sai Dairy')),
      SkipSourceScreen(
        sourceName: 'Hotel Rajdhani',
        initialReasons: const {SkipReason.sourceClosed},
        initialRemarks: 'Shift hours ending shortly.',
      ),
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
