import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_mock_data.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_models.dart';
import 'package:pickup_supervisor/features/collection_report/view/collection_report_pdf_screen.dart';
import 'package:pickup_supervisor/features/collection_report/view/collection_report_screen.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_home_screen.dart';

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

  testWidgets('week report matches the Figma figures', (tester) async {
    await pump(tester, const CollectionReportScreen());
    for (final text in [
      'Collection report',
      '16 – 22 Oct 2026',
      'Collected this week',
      '2,140 kg + 610 pcs',
      '105 stops due',
      '86',
      'By route',
      '40 of 45 stops',
      '820 kg',
      'By pickup category',
      '1,420 kg',
      'Stops to look at',
      'Sunrise School, Hotel Rajdhani and 2 more',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('Own'), findsNWidgets(2));
    expect(find.text('Contract'), findsNWidgets(2));
  });

  testWidgets('period pills switch the figures', (tester) async {
    await pump(tester, const CollectionReportScreen());
    await tester.tap(find.byKey(const Key('report-period-today')));
    await tester.pumpAndSettle();
    expect(find.text('Collected today'), findsOneWidget);
    expect(find.text('320 kg + 125 pcs'), findsOneWidget);
    expect(find.text('22 Oct 2026'), findsOneWidget);

    await tester.tap(find.byKey(const Key('report-period-month')));
    await tester.pumpAndSettle();
    expect(find.text('Collected this month'), findsOneWidget);
    expect(find.text('6,480 kg + 1,820 pcs'), findsOneWidget);
    expect(find.text('1 – 22 Oct 2026'), findsOneWidget);
  });

  testWidgets('pick dates applies a custom range', (tester) async {
    await pump(tester, const CollectionReportScreen());
    await tester.tap(find.byKey(const Key('report-period-dates')));
    await tester.pumpAndSettle();
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('16 Oct – 22 Oct · 7 days'), findsOneWidget);

    await tester.tap(find.byKey(const Key('date-range-clear')));
    await tester.pump();
    expect(find.text('Pick dates'), findsOneWidget);
    await tester.tap(find.byKey(const Key('date-range-day-10-5')));
    await tester.tap(find.byKey(const Key('date-range-day-10-9')));
    await tester.pump();
    expect(find.text('5 Oct – 9 Oct · 5 days'), findsOneWidget);

    // Days after today are disabled.
    await tester.tap(find.byKey(const Key('date-range-day-10-25')));
    await tester.pump();
    expect(find.text('5 Oct – 9 Oct · 5 days'), findsOneWidget);

    await tester.tap(find.byKey(const Key('date-range-apply')));
    await tester.pumpAndSettle();
    expect(find.text('5 – 9 Oct 2026'), findsOneWidget);
    expect(find.text('Collected on these dates'), findsOneWidget);
  });

  testWidgets('share opens the PDF preview', (tester) async {
    await pump(tester, const CollectionReportScreen());
    await tester.tap(find.byKey(const Key('report-share')));
    await tester.pumpAndSettle();
    expect(find.text('Report PDF'), findsOneWidget);
    expect(find.text('Collection report · 16 – 22 Oct 2026'), findsOneWidget);
    expect(find.text('Ecovision Environmental Resources LLP'), findsOneWidget);
    expect(
      find.text('Pickup Supervisor: Kiran Patel · This week, 16 – 22 Oct 2026'),
      findsOneWidget,
    );
    expect(find.text('Sunrise School, Hotel Rajdhani +2'), findsOneWidget);
    expect(
      find.text('Made 23 Oct 2026, 6:10 PM · Page 1 of 1'),
      findsOneWidget,
    );
    expect(find.text('Share PDF'), findsOneWidget);
  });

  testWidgets('home summary pills, view full report and calendar', (
    tester,
  ) async {
    await pump(
      tester,
      const PickupSupervisorHomeScreen(),
      size: const Size(375, 2200),
    );
    expect(find.text('Collected today · 12 of 16 stops'), findsOneWidget);
    await tester.tap(find.byKey(const Key('supervisor-period-week')));
    await tester.pumpAndSettle();
    expect(find.text('Collected this week · 86 of 105 stops'), findsOneWidget);
    expect(find.text('2,140 kg + 610 pcs'), findsOneWidget);

    await tester.tap(find.byKey(const Key('supervisor-view-full-report')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('collection-report-screen')), findsOneWidget);
    expect(find.text('Collected this week'), findsOneWidget);
    Navigator.of(tester.element(find.text('Collection report'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('supervisor-period-dates')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('date-range-day-10-20')));
    await tester.tap(find.byKey(const Key('date-range-day-10-21')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('date-range-apply')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('collection-report-screen')), findsOneWidget);
    expect(find.text('20 – 21 Oct 2026'), findsOneWidget);
  });

  for (final entry in {
    'gu': ['કલેક્શન રિપોર્ટ', 'આ અઠવાડિયે એકત્રિત', '16 – 22 ઑક્ટો 2026'],
    'hi': ['कलेक्शन रिपोर्ट', 'इस हफ़्ते एकत्रित', '16 – 22 अक्टू 2026'],
  }.entries) {
    testWidgets('report uses ${entry.key} localization', (tester) async {
      await pump(
        tester,
        const CollectionReportScreen(),
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
    final week = CollectionReportMockData.forPeriod(ReportPeriod.week);
    for (final screen in <Widget>[
      const CollectionReportScreen(),
      CollectionReportPdfScreen(period: ReportPeriod.week, data: week),
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
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: const CollectionReportScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('report-period-dates')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
