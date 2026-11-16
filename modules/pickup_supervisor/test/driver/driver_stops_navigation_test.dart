import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/driver/view/driver_home_screen.dart';
import 'package:pickup_supervisor/driver/view/driver_stops_screen.dart';

void main() {
  testWidgets('Open my stops navigates through list and detail screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: DriverHomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open my stops'));
    await tester.pumpAndSettle();

    expect(find.text('Pending Pickup Stops'), findsOneWidget);
    expect(find.text('ABC Textile Mills · Sorted'), findsOneWidget);
    expect(find.text('Shree Sai Dairy · Mixed'), findsOneWidget);
    expect(find.text('XYZ Textile Mills · Sorted'), findsOneWidget);
    expect(find.text('Pending'), findsNWidgets(2));
    expect(find.text('Skipped'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('driver-stop-0')));
    await tester.pumpAndSettle();

    expect(find.text('Stop Detail'), findsOneWidget);
    expect(find.text('Request Information'), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('driver-stop-detail')),
      const Offset(0, -320),
    );
    await tester.pumpAndSettle();
    expect(find.text('Start Pickup'), findsOneWidget);
  });

  testWidgets('stop list uses Gujarati localization', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('gu'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: [Locale('en'), Locale('gu'), Locale('hi')],
        home: DriverStopsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('બાકી પિકઅપ સ્ટોપ્સ'), findsOneWidget);
    expect(find.text('ABC ટેક્સટાઇલ મિલ્સ · છાંટેલું'), findsOneWidget);
    expect(find.text('છોડેલ'), findsOneWidget);
  });
}
