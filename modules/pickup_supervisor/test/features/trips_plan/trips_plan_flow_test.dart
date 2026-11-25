import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_home_screen.dart';
import 'package:pickup_supervisor/features/trips_plan/model/trips_plan_models.dart';
import 'package:pickup_supervisor/features/trips_plan/view/trips_plan_screen.dart';

void main() {
  // Real Manrope metrics, so overflow checks match the device.
  setUpAll(() async {
    final loader = FontLoader('packages/pickup_supervisor/Manrope');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      loader.addFont(rootBundle.load('assets/font/Manrope-$weight.ttf'));
    }
    await loader.load();
  });

  Future<void> pumpPlan(
    WidgetTester tester, {
    Locale? locale,
    Size size = const Size(375, 812),
    TripsPlanChoice choice = TripsPlanChoice.today,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('en'), Locale('gu'), Locale('hi')],
        home: TripsPlanScreen(initialChoice: choice),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('today lists trips with status, tags and call button', (
    tester,
  ) async {
    await pumpPlan(tester);
    expect(find.text('Trips plan'), findsOneWidget);
    expect(find.text('Adajan, Vesu, Pal'), findsOneWidget);
    expect(find.text('Thu 22 Oct 2026'), findsOneWidget);
    expect(find.text('5 trips · 39 stops'), findsOneWidget);
    expect(find.text('Adajan Morning'), findsOneWidget);
    expect(find.text('On route'), findsWidgets);
    expect(find.text('GJ-05-BX-1234 · Own vehicle'), findsOneWidget);
    expect(find.text('Changed for today'), findsOneWidget);
    expect(
      find.text('Suresh Kumar (for Vikram Singh) · Ravi Bisht'),
      findsOneWidget,
    );
    expect(
      find.text('9 stops · Daily 5 · Weekly 3 · 1 paused'),
      findsOneWidget,
    );
    expect(find.text('3 of 8 collected'), findsOneWidget);
    expect(find.text('740 kg'), findsOneWidget);
    expect(find.text('Call driver'), findsWidgets);
    await tester.drag(
      find.byKey(const Key('trips-plan-scroll')),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    expect(find.text('Driver not using app'), findsOneWidget);
    expect(find.text('Vesu Evening'), findsOneWidget);
    expect(find.text('Shree Ram Transport · Driver Kishan'), findsOneWidget);
  });

  testWidgets('choices switch tomorrow, this week and the empty date', (
    tester,
  ) async {
    await pumpPlan(tester);
    await tester.tap(find.byKey(const Key('trips-plan-choice-tomorrow')));
    await tester.pumpAndSettle();
    expect(find.text('Fri 23 Oct 2026'), findsOneWidget);
    expect(find.text('4 trips · 31 stops'), findsOneWidget);
    expect(find.text('Planned'), findsWidgets);

    await tester.tap(find.byKey(const Key('trips-plan-choice-week')));
    await tester.pumpAndSettle();
    expect(find.text('Thu 22 Oct · Today'), findsOneWidget);
    expect(find.text('4 trips · 33 stops · 2 extra pickups'), findsOneWidget);
    expect(find.text('Own vehicle 3'), findsWidgets);
  });

  testWidgets('a later week day opens the expected view', (tester) async {
    await pumpPlan(tester, choice: TripsPlanChoice.week);
    await tester.tap(find.byKey(const Key('trips-plan-day-2')));
    await tester.pumpAndSettle();
    expect(find.text('Sat 24 Oct 2026'), findsOneWidget);
    expect(find.text('4 trips · 33 stops'), findsOneWidget);
    expect(
      find.textContaining('Trips are made the day before'),
      findsOneWidget,
    );
    expect(find.text('Expected'), findsWidgets);
    expect(
      find.text('9 stops · Daily 5 · On call 2 · Extra 2'),
      findsOneWidget,
    );

    // Tapping a chip leaves the day view.
    await tester.tap(find.byKey(const Key('trips-plan-choice-week')));
    await tester.pumpAndSettle();
    expect(find.text('Thu 22 Oct · Today'), findsOneWidget);
  });

  testWidgets('pick dates shows the chosen days and the holiday', (
    tester,
  ) async {
    await pumpPlan(tester, choice: TripsPlanChoice.week);
    await tester.tap(find.byKey(const Key('trips-plan-choice-date')));
    await tester.pumpAndSettle();
    expect(find.text('October 2026'), findsOneWidget);
    // Past days cannot be picked.
    await tester.tap(find.byKey(const Key('date-range-day-10-20')));
    await tester.pump();
    expect(find.text('Pick dates'), findsOneWidget);

    await tester.tap(find.byKey(const Key('date-range-day-10-26')));
    await tester.tap(find.byKey(const Key('date-range-day-10-31')));
    await tester.pump();
    expect(find.text('Mon 26 Oct – Sat 31 Oct · 6 days'), findsOneWidget);
    await tester.tap(find.byKey(const Key('date-range-apply')));
    await tester.pumpAndSettle();

    expect(find.text('Mon 26 Oct'), findsOneWidget);
    expect(find.text('Thu 29 Oct'), findsOneWidget);
    expect(find.text('Fri 30 Oct · Warehouse closed'), findsOneWidget);
    expect(find.text('No trips · warehouse holiday'), findsOneWidget);
    expect(find.text('Sat 31 Oct'), findsOneWidget);

    await tester.tap(find.byKey(const Key('trips-plan-day-8')));
    await tester.pumpAndSettle();
    expect(find.text('Fri 30 Oct 2026'), findsOneWidget);
    expect(find.text('No trips on this day'), findsOneWidget);
    expect(find.textContaining('holiday rule'), findsOneWidget);
    // The calendar chip stays selected on the day's detail.
    final chip = tester.widget<Material>(
      find
          .descendant(
            of: find.byKey(const Key('trips-plan-choice-date')),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(chip.color, DriverColors.primary500);
  });

  testWidgets('today chosen on the calendar keeps the calendar chip', (
    tester,
  ) async {
    await pumpPlan(tester, choice: TripsPlanChoice.week);
    await tester.tap(find.byKey(const Key('trips-plan-choice-date')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('date-range-day-10-22')));
    await tester.tap(find.byKey(const Key('date-range-day-10-24')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('date-range-apply')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('trips-plan-day-0')));
    await tester.pumpAndSettle();
    expect(find.text('Thu 22 Oct 2026'), findsOneWidget);
    expect(find.text('On route'), findsWidgets);
    expect(find.text('Today'), findsOneWidget);
    final today = tester.widget<Material>(
      find
          .descendant(
            of: find.byKey(const Key('trips-plan-choice-today')),
            matching: find.byType(Material),
          )
          .first,
    );
    final dates = tester.widget<Material>(
      find
          .descendant(
            of: find.byKey(const Key('trips-plan-choice-date')),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(dates.color, DriverColors.primary500);
    expect(today.color, DriverColors.neutral50);
  });

  testWidgets('a week day opens its day list', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        home: TripsPlanScreen(initialChoice: TripsPlanChoice.week),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('trips-plan-day-1')));
    await tester.pumpAndSettle();
    expect(find.text('Fri 23 Oct 2026'), findsOneWidget);
  });

  testWidgets('home See trips plan opens the screen', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 1800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(home: PickupSupervisorHomeScreen()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('supervisor-see-trips-plan')));
    await tester.pumpAndSettle();
    expect(find.text('Trips plan'), findsOneWidget);
  });

  for (final entry in {
    'gu': ['ટ્રિપ પ્લાન', 'આજે', 'ડ્રાઇવરને કૉલ કરો'],
    'hi': ['ट्रिप प्लान', 'आज', 'ड्राइवर को कॉल करें'],
  }.entries) {
    testWidgets('trips plan uses ${entry.key} localization', (tester) async {
      await pumpPlan(tester, locale: Locale(entry.key));
      expect(find.text(entry.value[0]), findsOneWidget);
      expect(find.text(entry.value[1]), findsOneWidget);
      expect(find.text(entry.value[2]), findsWidgets);
    });
  }

  testWidgets('fits a small phone with large text', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);
    for (final choice in TripsPlanChoice.values) {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: TripsPlanScreen(initialChoice: choice),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    for (final day in [2, 8]) {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: TripsPlanScreen(
            initialChoice: TripsPlanChoice.week,
            initialDay: day,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
