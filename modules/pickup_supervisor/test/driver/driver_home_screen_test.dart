import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/driver/view/driver_home_screen.dart';

void main() {
  testWidgets('matches the expanded driver home content', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DriverHomeScreen()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('driver-home-title')), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Magdalla Warehouse'), findsOneWidget);
    expect(find.text('You’re Online'), findsOneWidget);
    expect(find.text('Todays Summary'), findsOneWidget);
    expect(find.text('Pending Stops'), findsOneWidget);
    expect(find.text('Collected'), findsOneWidget);
    expect(find.text('Today’s Trip'), findsOneWidget);
    expect(find.byKey(const Key('driver-home-icon')), findsOneWidget);
  });

  testWidgets('summary visibility control preserves the page shell', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DriverHomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('driver-summary-toggle')));
    await tester.pumpAndSettle();

    expect(find.text('Todays Summary'), findsOneWidget);
    expect(find.text('Pending Stops'), findsNothing);
    expect(find.text('8 of 8 stops completed'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.byKey(const Key('driver-home-scroll')), findsOneWidget);
  });

  testWidgets('uses Gujarati localization without widget hardcoding', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('gu'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: [Locale('en'), Locale('gu'), Locale('hi')],
        home: DriverHomeScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ફરી સ્વાગત છે'), findsOneWidget);
    expect(find.text('આજનો સારાંશ'), findsOneWidget);
    expect(find.text('મગદલ્લા વેરહાઉસ'), findsOneWidget);
  });
}
