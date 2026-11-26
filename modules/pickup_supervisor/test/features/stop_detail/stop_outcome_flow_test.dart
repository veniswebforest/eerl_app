import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_mock_data.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_models.dart';
import 'package:pickup_supervisor/features/collection_report/view/stops_to_look_at_screen.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_mock_data.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';
import 'package:pickup_supervisor/features/stop_detail/view/extra_pickup_screen.dart';
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
    Size size = const Size(375, 2400),
    double textScale = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('en'), Locale('gu'), Locale('hi')],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: home,
      ),
    );
    await tester.pumpAndSettle();
  }

  RouteStop today(String name) =>
      RouteDetailMockData.todayStops.firstWhere((s) => s.name == name);
  RouteStop approved(String name) =>
      RouteDetailMockData.approvedStops.firstWhere((s) => s.name == name);

  StopDetailScreen approvedDetail(String name) => StopDetailScreen(
    stop: approved(name),
    tripState: TripState.approved,
    summary: RouteDetailMockData.approvedSummary,
  );

  void expectTexts(List<String> texts) {
    for (final t in texts) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
  }

  testWidgets('collected sorted stop shows the record, items and totals', (
    tester,
  ) async {
    await pump(tester, StopDetailScreen(stop: today('ABC Textile Mills')));
    expect(find.byKey(const Key('stop-outcome-collected')), findsOneWidget);
    expectTexts([
      'Data entry',
      'Entered in the app',
      'Location matched',
      'View on map',
      'Note from driver',
      'Collected items',
      'KG Block',
      'PCS Block',
      '350.00 KG.',
      '25 PCS',
    ]);
    expect(find.byKey(const Key('stop-collected-items')), findsOneWidget);
    expect(find.byKey(const Key('stop-detail-call')), findsNothing);
  });

  testWidgets('collected mixed at the gate has no GPS', (tester) async {
    await pump(tester, approvedDetail('Shree Sai Dairy'));
    expectTexts([
      'Entered at gate',
      'Not recorded (entered at the gate, not at the source)',
    ]);
    expect(find.textContaining('from the driver’s slip'), findsOneWidget);
    expect(find.textContaining('(Shree Ram Transport)'), findsNothing);
    expect(find.text('Location matched'), findsNothing);
  });

  testWidgets('0 kg opens the extra pickup form and its popup', (tester) async {
    await pump(tester, StopDetailScreen(stop: today('City Bakery')));
    expectTexts([
      '0 kg · No material today',
      'Photo from the driver',
      'Call the person at the pickup point',
      'Add an extra pickup',
    ]);
    await tester.tap(find.byKey(const Key('stop-detail-add-extra')));
    await tester.pumpAndSettle();
    expect(find.byType(ExtraPickupScreen), findsOneWidget);
    expect(find.textContaining('Fri 23 Oct'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('extra-pickup-amount')), '40a');
    expect(find.text('40'), findsOneWidget);
    await tester.tap(find.byKey(const Key('extra-pickup-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Extra pickup added'), findsOneWidget);
    await tester.tap(find.text('Back to the stop'));
    await tester.pumpAndSettle();
    expect(find.byType(ExtraPickupScreen), findsNothing);
    expect(find.byType(StopDetailScreen), findsOneWidget);
  });

  testWidgets('missed stop: call the driver and extra pickup tomorrow', (
    tester,
  ) async {
    await pump(tester, approvedDetail('Sunrise School'));
    expect(find.byKey(const Key('stop-outcome-missed')), findsOneWidget);
    expectTexts([
      'Missed · not recorded',
      'What happened',
      'Call the driver',
      'Add an extra pickup tomorrow',
    ]);
    expect(find.textContaining('Sister Mary · Office'), findsOneWidget);
    expect(
      find.textContaining('vehicle (Shree Ram Transport)'),
      findsOneWidget,
    );
  });

  testWidgets('cancelled stop shows reason, who and next pickup', (
    tester,
  ) async {
    await pump(tester, StopDetailScreen(stop: today('XYZ Textile Mills')));
    expect(find.byKey(const Key('stop-outcome-cancelled')), findsOneWidget);
    expectTexts([
      'Closed for stock-taking',
      'Thu 29 Oct · 10 am – 12 pm',
      'Add an extra pickup',
    ]);
  });

  testWidgets('paused stop asks to restart pickups', (tester) async {
    await pump(tester, StopDetailScreen(stop: today('Sai Kirana Store')));
    expectTexts(['Paused 20 – 30 Oct', 'Renovation', 'Ask to restart pickups']);
    expect(find.byKey(const Key('stop-detail-add-extra')), findsNothing);
  });

  testWidgets('stops to look at cards open the stop detail', (tester) async {
    await pump(
      tester,
      StopsToLookAtScreen(
        data: CollectionReportMockData.forPeriod(ReportPeriod.today),
      ),
    );
    await tester.tap(find.byKey(const Key('look-at-stop-0')));
    await tester.pumpAndSettle();
    expect(find.byType(StopDetailScreen), findsOneWidget);
    expect(find.text('Missed · not recorded'), findsOneWidget);
  });

  for (final entry in {
    'gu': const Locale('gu'),
    'hi': const Locale('hi'),
  }.entries) {
    testWidgets('outcomes and form use ${entry.key} localization', (
      tester,
    ) async {
      await pump(
        tester,
        StopDetailScreen(stop: today('City Bakery')),
        locale: entry.value,
      );
      expect(find.text('0 kg · No material today'), findsNothing);
      await tester.tap(find.byKey(const Key('stop-detail-add-extra')));
      await tester.pumpAndSettle();
      expect(find.text('Add extra pickup'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('outcome screens fit a small phone with large text', (
    tester,
  ) async {
    for (final screen in [
      StopDetailScreen(stop: today('ABC Textile Mills')),
      approvedDetail('Shree Sai Dairy'),
      StopDetailScreen(stop: today('City Bakery')),
      approvedDetail('Sunrise School'),
      StopDetailScreen(stop: today('XYZ Textile Mills')),
      StopDetailScreen(stop: today('Sai Kirana Store')),
      ExtraPickupScreen(
        stopName: 'City Bakery',
        address: 'Adajan',
        time: '10 am – 12 pm',
        routeName: 'Adajan Morning',
        initialDate: DateTime(2026, 10, 23),
      ),
    ]) {
      await pump(tester, screen, size: const Size(320, 568), textScale: 1.3);
      expect(tester.takeException(), isNull);
    }
  });
}
