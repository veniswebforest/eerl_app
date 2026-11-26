import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/route_actions/view/complete_trip_screen.dart';
import 'package:pickup_supervisor/features/route_detail/view/route_detail_screen.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('packages/pickup_supervisor/Manrope');
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      loader.addFont(rootBundle.load('assets/font/Manrope-$w.ttf'));
    }
    await loader.load();
  });

  Future<void> pump(
    WidgetTester tester, {
    Locale? locale,
    Size size = const Size(375, 2000),
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
        home: const RouteDetailScreen(driverNotUsingApp: true),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Pal Gam Morning: driver not using app', (tester) async {
    await pump(tester);
    for (final t in [
      'Pal Gam Morning',
      'Planned',
      'Daily 4 · Weekly 3 · On call 1',
      'Driver not using app',
      'Amit Patel hasn’t started the trip in the app. The shift started at 12:00 pm.',
      'Call the driver',
      'Complete trip for the driver',
      'Morning (12:00 PM – 05:00 PM)',
      'Driver : Amit Patel (98250 99510)',
      'Labour : Ram Singh',
      'Thu, 22 Oct 2026',
      'Every day except Sun · 12–2 pm',
      'Called in · today 2–4 pm',
      'Hotel Shivam · Mixed',
      'On call',
      'and 4 more stops, all still pending',
    ]) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
    expect(find.text('List'), findsNothing);
    expect(find.byKey(const Key('route-detail-add-sources')), findsNothing);
    expect(find.byKey(const Key('route-detail-more')), findsOneWidget);
  });

  testWidgets('Complete trip for the driver opens its screen', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('route-detail-complete-for-driver')));
    await tester.pumpAndSettle();
    expect(find.byType(CompleteTripScreen), findsOneWidget);
    expect(find.text('Pal Gam Morning · Thu 22 Oct'), findsOneWidget);
    await tester.tap(find.byKey(const Key('module-back-button')));
    await tester.pumpAndSettle();
    expect(find.byType(CompleteTripScreen), findsNothing);
  });

  for (final locale in const [Locale('gu'), Locale('hi')]) {
    testWidgets('uses ${locale.languageCode}', (tester) async {
      await pump(tester, locale: locale);
      expect(find.text('Driver not using app'), findsNothing);
      expect(
        find.byKey(const Key('route-detail-not-using-app')),
        findsOneWidget,
      );
    });
  }

  testWidgets('fits a small phone with large text', (tester) async {
    await pump(tester, size: const Size(320, 568), textScale: 1.3);
    expect(tester.takeException(), isNull);
  });
}
