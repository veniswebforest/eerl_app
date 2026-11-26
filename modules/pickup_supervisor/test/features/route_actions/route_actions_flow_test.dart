import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_routes_screen.dart';
import 'package:pickup_supervisor/features/route_actions/model/route_actions_mock_data.dart';
import 'package:pickup_supervisor/features/route_actions/model/route_actions_models.dart';
import 'package:pickup_supervisor/features/route_actions/view/ask_collection_head_screen.dart';
import 'package:pickup_supervisor/features/route_actions/view/change_team_screen.dart';
import 'package:pickup_supervisor/features/route_actions/view/move_stops_screen.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_mock_data.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';
import 'package:pickup_supervisor/features/route_detail/view/route_detail_screen.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('packages/pickup_supervisor/Manrope');
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      loader.addFont(rootBundle.load('assets/font/Manrope-$w.ttf'));
    }
    await loader.load();
  });

  setUp(RouteSwitchStore.reset);

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    Locale? locale,
    Size size = const Size(375, 1600),
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

  Future<void> tap(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  Future<void> openAction(WidgetTester tester, String key) async {
    await tap(tester, find.byKey(const Key('route-detail-more')));
    await tap(tester, find.byKey(Key('route-action-$key')));
  }

  Future<void> clearToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  }

  testWidgets('planned ⋮ lists the five trip actions', (tester) async {
    await pump(tester, const RouteDetailScreen(tripState: TripState.planned));
    await tap(tester, find.byKey(const Key('route-detail-more')));
    for (final t in [
      'Adajan Morning · Fri 23 Oct',
      'Changes here are for this trip only. The route stays as it is.',
      'Change driver or labour',
      'Move stops to another vehicle',
      'Ask the Collection Head',
      'Cancel this trip',
      'No trip on Fri 23 Oct. The route stays on.',
      'Switch off the route',
    ]) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
  });

  testWidgets('change driver for this trip shows Changed for today', (
    tester,
  ) async {
    await pump(tester, const RouteDetailScreen(tripState: TripState.planned));
    await openAction(tester, 'change-team');
    expect(find.byType(ChangeTeamScreen), findsOneWidget);
    expect(find.text('Suresh Kumar (••• 3310) · Free today'), findsOneWidget);
    await tap(tester, find.byKey(const Key('change-team-driver')));
    expect(find.text('Busy at this time'), findsOneWidget);
    await tap(tester, find.byKey(const Key('team-person-2458')));
    expect(find.text('Rakesh Sharma (••• 2458) · Free today'), findsOneWidget);
    await tap(tester, find.byKey(const Key('change-team-labour')));
    expect(find.text('Labour for this trip'), findsWidgets);
    await tap(tester, find.byKey(const Key('team-person-9510')));
    expect(find.textContaining('Busy: Pal Gam Morning'), findsOneWidget);
    await tap(tester, find.byKey(const Key('change-team-save')));
    expect(find.byType(ChangeTeamScreen), findsNothing);
    expect(find.text('Saved for this trip!'), findsOneWidget);
    expect(find.byKey(const Key('route-detail-changed')), findsOneWidget);
    expect(
      find.text('Driver : Rakesh Sharma (for Vikram Singh)'),
      findsOneWidget,
    );
    await clearToast(tester);
  });

  testWidgets('on-route trip changed before it started', (tester) async {
    await pump(
      tester,
      const RouteDetailScreen(
        teamChange: RouteActionsMockData.adajanTodayChange,
      ),
    );
    expect(
      find.text('Driver : Suresh Kumar (today, for Vikram Singh)'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Tomorrow the route’s own team'),
      findsOneWidget,
    );
  });

  testWidgets('move stops removes them from the trip', (tester) async {
    await pump(tester, const RouteDetailScreen(tripState: TripState.planned));
    await openAction(tester, 'move-stops');
    expect(find.byType(MoveStopsScreen), findsOneWidget);
    expect(find.text('Stops to move (3 ticked)'), findsOneWidget);
    await tap(tester, find.byKey(const Key('move-stop-0')));
    expect(find.text('Move 4 stops'), findsOneWidget);
    await tap(tester, find.byKey(const Key('move-stop-0')));
    await tap(tester, find.byKey(const Key('move-target-2')));
    await tap(tester, find.byKey(const Key('move-stops-submit')));
    expect(find.text('3 Stops Moved'), findsOneWidget);
    expect(
      find.textContaining('Om Sweets, Navratri Ground and Hotel Rajdhani'),
      findsOneWidget,
    );
    await tap(tester, find.text('Back to the trip'));
    expect(find.byType(MoveStopsScreen), findsNothing);
    expect(find.textContaining('Om Sweets'), findsNothing);
    expect(find.textContaining('Shree Sai Dairy'), findsWidgets);
  });

  testWidgets('ask the Collection Head: For, Dates and Send', (tester) async {
    await pump(tester, const RouteDetailScreen(tripState: TripState.planned));
    await openAction(tester, 'ask-head');
    expect(find.byType(AskCollectionHeadScreen), findsOneWidget);
    expect(find.text('Adajan Morning · GJ-05-BX-1234'), findsOneWidget);
    expect(find.text('Sat 24 Oct – Sun 25 Oct'), findsOneWidget);
    await tap(tester, find.byKey(const Key('ask-head-for')));
    expect(find.text('Which trip or route?'), findsOneWidget);
    await tap(tester, find.byKey(const Key('ask-target-1')));
    expect(find.text('Pal Gam Morning · GJ-05-BX-5678'), findsOneWidget);
    await tap(tester, find.byKey(const Key('ask-need-pausePickups')));
    await tap(tester, find.byKey(const Key('ask-head-for')));
    expect(find.text('Which pickup point?'), findsOneWidget);
    await tap(tester, find.byKey(const Key('ask-target-0')));
    expect(find.text('ABC Textile Mills'), findsOneWidget);
    await tap(tester, find.byKey(const Key('ask-head-dates')));
    expect(find.text('Apply'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tap(tester, find.byKey(const Key('ask-head-send')));
    expect(find.text('Request sent'), findsNothing);
    await tester.enterText(
      find.byKey(const Key('ask-head-details')),
      'Pause for renovation',
    );
    await tester.pump();
    await tap(tester, find.byKey(const Key('ask-head-send')));
    expect(find.text('Request sent'), findsOneWidget);
    await tap(tester, find.text('Back to home'));
    expect(find.byType(AskCollectionHeadScreen), findsNothing);
  });

  testWidgets('cancel this trip needs a reason', (tester) async {
    await pump(tester, const RouteDetailScreen(tripState: TripState.planned));
    await openAction(tester, 'cancel-trip');
    expect(find.text('Cancel this trip?'), findsOneWidget);
    await tap(tester, find.byKey(const Key('confirm-popup-confirm')));
    expect(find.text('Cancel this trip?'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('cancel-trip-reason')),
      'Warehouse asked: the unloading bay is closed for repairs.',
    );
    await tester.pump();
    await tap(tester, find.byKey(const Key('confirm-popup-confirm')));
    expect(find.text('Trip Cancelled!'), findsOneWidget);
    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.byKey(const Key('route-detail-cancelled')), findsOneWidget);
    expect(find.byKey(const Key('route-detail-more')), findsNothing);
    expect(find.byKey(const Key('route-detail-add-sources')), findsNothing);
    await clearToast(tester);
  });

  testWidgets('switch off lands on Routes with a toast, then switch on', (
    tester,
  ) async {
    await pump(
      tester,
      const PickupSupervisorRoutesScreen(showBottomNavigation: false),
    );
    expect(find.text('Switched off'), findsOneWidget);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(
      MaterialPageRoute<void>(
        builder: (_) => const RouteDetailScreen(tripState: TripState.planned),
      ),
    );
    await tester.pumpAndSettle();
    await openAction(tester, 'switch-off');
    expect(find.text('Switch off the route?'), findsOneWidget);
    await tap(tester, find.byKey(const Key('confirm-popup-confirm')));
    expect(find.byType(RouteDetailScreen), findsNothing);
    expect(find.text('Route Switched Off!'), findsOneWidget);
    expect(find.text('Switched off'), findsNWidgets(2));
    await clearToast(tester);
    expect(find.text('Route Switched Off!'), findsNothing);

    // Rander Evening: the switched-off route opens its own detail.
    await tap(tester, find.byKey(const Key('route-card-rander')));
    expect(find.byKey(const Key('route-detail-switched-off')), findsOneWidget);
    expect(find.text('Driver : Jignesh (Khodiyar Transport)'), findsOneWidget);
    expect(find.text('Evening (04:00 PM – 08:00 PM)'), findsOneWidget);
    await tap(tester, find.byKey(const Key('route-detail-switch-on')));
    expect(find.text('Switch on the route?'), findsOneWidget);
    await tap(tester, find.byKey(const Key('confirm-popup-confirm')));
    expect(find.text('Route Switched On!'), findsOneWidget);
    expect(RouteSwitchStore.off.value, {RouteSwitchStore.adajan});
    await clearToast(tester);
  });

  for (final locale in const [Locale('gu'), Locale('hi')]) {
    testWidgets('new screens use ${locale.languageCode}', (tester) async {
      for (final screen in [
        const ChangeTeamScreen(routeName: 'Adajan Morning'),
        MoveStopsScreen(
          routeName: 'Adajan Morning',
          stops: RouteDetailMockData.plannedStops,
        ),
        const AskCollectionHeadScreen(),
        const RouteDetailScreen(
          tripState: TripState.planned,
          switchedOff: true,
          summary: RouteActionsMockData.randerSummary,
        ),
      ]) {
        await pump(tester, screen, locale: locale);
        expect(find.text('Change for this trip'), findsNothing);
        expect(find.text('Move stops'), findsNothing);
        expect(find.text('Send request'), findsNothing);
        expect(find.text('Switch on this route'), findsNothing);
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('new screens fit a small phone with large text', (tester) async {
    for (final screen in [
      const ChangeTeamScreen(routeName: 'Adajan Morning'),
      MoveStopsScreen(
        routeName: 'Adajan Morning',
        stops: RouteDetailMockData.plannedStops,
      ),
      const AskCollectionHeadScreen(),
      const RouteDetailScreen(
        tripState: TripState.planned,
        switchedOff: true,
        summary: RouteActionsMockData.randerSummary,
      ),
    ]) {
      await pump(tester, screen, size: const Size(320, 568), textScale: 1.3);
      expect(tester.takeException(), isNull);
    }
  });
}
