import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_flags_screens.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_home_screen.dart';

void main() {
  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen, {
    Locale? locale,
    Size size = const Size(375, 1000),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
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
        home: screen,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Flags tile on Home opens the list of seven flags', (
    tester,
  ) async {
    await pumpScreen(tester, const PickupSupervisorHomeScreen());
    final scroll = find.byKey(const Key('supervisor-home-scroll'));
    await tester.drag(scroll, const Offset(0, -280));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('supervisor-attention-Flags')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('supervisor-flags-list')), findsOneWidget);
    for (final t in [
      'Hotel Rajdhani',
      'Time clash · gets there about 1:30 pm, the window ends at 1 pm',
      'Sunrise School',
      'Off the route · 4.2 km from Punagam FullDay',
      'ABC Textile Mills',
      'Schedule changed · now Mon, Wed 9–11 am',
      'Sai Kirana Store',
      'Source paused · 20 – 30 Oct, renovation',
      'Patel Packaging',
      'Mahavir Paper Mill',
      'Hotel Annapurna',
      'Source moved to you · Vesu',
    ]) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
  });

  testWidgets('Flags empty state', (tester) async {
    await pumpScreen(
      tester,
      const PickupSupervisorFlagsScreen(showEmpty: true),
    );
    expect(find.byKey(const Key('supervisor-flags-empty')), findsOneWidget);
    expect(find.text('Nothing to check'), findsOneWidget);
    expect(
      find.text(
        'No flags right now. Schedule changes, pauses and pickup points '
        'without a route show up here.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Mark done takes the flag off the list with a toast', (
    tester,
  ) async {
    await pumpScreen(tester, const PickupSupervisorFlagsScreen());
    await tester.tap(find.text('ABC Textile Mills'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('supervisor-flag-detail-scheduleChanged')),
      findsOneWidget,
    );
    for (final t in [
      'Schedule changed',
      'Mon, Thu · 8–10 am',
      'Mon, Wed · 9–11 am',
      'Mon 2 Nov',
      'Check the route',
      'Check that Adajan Morning still reaches it on the new days and in '
          'the new time.',
    ]) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
    await tester.tap(find.byKey(const Key('supervisor-flag-mark-done')));
    await tester.pumpAndSettle();
    expect(find.text('Flag marked done'), findsOneWidget);
    expect(find.text('ABC Textile Mills is off your list'), findsOneWidget);
    expect(find.text('Schedule changed · now Mon, Wed 9–11 am'), findsNothing);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('Each flag type shows its facts and follow-up button', (
    tester,
  ) async {
    const states = <PickupSupervisorFlagDetailType, List<String>>{
      PickupSupervisorFlagDetailType.timeClash: [
        'Time clash',
        'About 1:30 pm, 30 min after the window',
        'Open your routes',
      ],
      PickupSupervisorFlagDetailType.offRoute: [
        '4.2 km off the route',
        'About 20 min more on each trip',
        'Open your routes',
      ],
      PickupSupervisorFlagDetailType.sourcePaused: [
        'Renovation',
        'Check the route',
      ],
      PickupSupervisorFlagDetailType.newSource: [
        '2nd Wed of the month · 10–11 am',
        'This flag closes by itself once it is on a route.',
        'Add to a route',
      ],
      PickupSupervisorFlagDetailType.extraPickup: [
        'Sat 24 Oct · 11 am – 12 pm · about 60 kg',
        'This flag closes by itself once it is on a route.',
      ],
      PickupSupervisorFlagDetailType.sourceMoved: [
        'The Vesu area is now yours',
        'Add to a route',
      ],
    };
    for (final entry in states.entries) {
      await pumpScreen(
        tester,
        PickupSupervisorFlagDetailScreen(type: entry.key),
      );
      for (final t in entry.value) {
        expect(find.text(t), findsOneWidget, reason: '${entry.key}: $t');
      }
      expect(find.text('Mark done'), findsOneWidget);
    }
  });

  testWidgets('Open your routes opens Routes', (tester) async {
    await pumpScreen(
      tester,
      const PickupSupervisorFlagDetailScreen(
        type: PickupSupervisorFlagDetailType.timeClash,
      ),
    );
    await tester.tap(find.byKey(const Key('supervisor-flag-action')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('supervisor-routes-screen')), findsOneWidget);
  });

  for (final locale in const [Locale('gu'), Locale('hi')]) {
    testWidgets('flags use ${locale.languageCode}', (tester) async {
      await pumpScreen(
        tester,
        const PickupSupervisorFlagsScreen(),
        locale: locale,
      );
      expect(find.text('Source moved to you · Vesu'), findsNothing);
      await tester.tap(
        find.byKey(const Key('supervisor-flag-scheduleChanged')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Mark done'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('fits a small phone with large text', (tester) async {
    for (final screen in [
      const PickupSupervisorFlagsScreen(),
      const PickupSupervisorFlagsScreen(showEmpty: true),
      for (final t in PickupSupervisorFlagDetailType.values)
        PickupSupervisorFlagDetailScreen(type: t),
    ]) {
      await pumpScreen(
        tester,
        screen,
        size: const Size(320, 568),
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);
    }
  });
}
