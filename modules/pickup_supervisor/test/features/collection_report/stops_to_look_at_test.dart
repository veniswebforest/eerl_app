import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_mock_data.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_models.dart';
import 'package:pickup_supervisor/features/collection_report/view/collection_report_screen.dart';
import 'package:pickup_supervisor/features/collection_report/view/stops_to_look_at_screen.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_home_screen.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('packages/pickup_supervisor/Manrope');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      loader.addFont(rootBundle.load('assets/font/Manrope-$weight.ttf'));
    }
    await loader.load();
  });

  final week = CollectionReportMockData.forPeriod(ReportPeriod.week);

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

  testWidgets('missed tab matches the Figma list', (tester) async {
    await pump(tester, StopsToLookAtScreen(data: week));
    for (final text in [
      'Stops to look at',
      '16 – 22 Oct 2026',
      'Sunrise School',
      'Punagam FullDay · Thu 22 Oct',
      'Contract vehicle · GJ-05-EE-1002',
      'Not recorded by the driver or the gate',
      'Not on a route · Sat 17 Oct',
      'Extra pickup',
      'Own vehicle · driver Amit Patel',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    // Tab + four tags.
    expect(find.text('Missed'), findsNWidgets(5));
  });

  testWidgets('tabs switch to cancelled and 0 kg', (tester) async {
    await pump(tester, StopsToLookAtScreen(data: week));
    await tester.tap(find.byKey(const Key('look-at-tab-cancelledBySource')));
    await tester.pumpAndSettle();
    expect(find.text('XYZ Textile Mills'), findsOneWidget);
    expect(find.text('Called off by you'), findsOneWidget);
    expect(find.text('Shifted to another day'), findsOneWidget);

    await tester.tap(find.byKey(const Key('look-at-tab-zeroKg')));
    await tester.pumpAndSettle();
    expect(find.text('Mehta Medicals'), findsOneWidget);
    expect(find.text('Vehicle full'), findsOneWidget);
  });

  testWidgets('a period with no missed stops shows the empty message', (
    tester,
  ) async {
    await pump(
      tester,
      StopsToLookAtScreen(
        data: CollectionReportMockData.forPeriod(ReportPeriod.yesterday),
      ),
    );
    expect(find.text('Nothing to look at for these dates'), findsOneWidget);
  });

  testWidgets('report rows open the matching tab', (tester) async {
    await pump(tester, const CollectionReportScreen());
    await tester.tap(find.text('Cancelled by source'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('stops-to-look-at-screen')), findsOneWidget);
    expect(find.text('Om Fabrics'), findsOneWidget);
  });

  testWidgets('home tiles open the matching tab', (tester) async {
    await pump(
      tester,
      const PickupSupervisorHomeScreen(),
      size: const Size(375, 2200),
    );
    await tester.tap(find.byKey(const Key('supervisor-period-week')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('supervisor-outcome-scale.svg')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('stops-to-look-at-screen')), findsOneWidget);
    expect(find.text('City Bakery'), findsOneWidget);
  });

  for (final entry in {
    'gu': [
      'ધ્યાન આપવાના સ્ટોપ',
      'ડ્રાઇવર કે ગેટે નોંધ્યું નથી',
      'ગુરુ 22 ઑક્ટો',
    ],
    'hi': [
      'ध्यान देने वाले स्टॉप',
      'ड्राइवर या गेट ने दर्ज नहीं किया',
      'गुरु 22 अक्टू',
    ],
  }.entries) {
    testWidgets('look at uses ${entry.key} localization', (tester) async {
      await pump(
        tester,
        StopsToLookAtScreen(data: week),
        locale: Locale(entry.key),
      );
      for (final text in entry.value) {
        expect(find.textContaining(text), findsWidgets, reason: text);
      }
    });
  }

  testWidgets('fits a small phone with large text', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);
    for (final o in LookAtOutcome.values) {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: StopsToLookAtScreen(data: week, initialOutcome: o),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
