import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/driver/view/driver_home_screen.dart';
import 'package:pickup_supervisor/features/driver/view/driver_stops_screen.dart';

void main() {
  testWidgets('See all stops opens the Figma Trip 1 stop list', (tester) async {
    _setDesignSize(tester);
    await tester.pumpWidget(const MaterialApp(home: DriverHomeScreen()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('See all 7 stops'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('See all 7 stops'));
    await tester.pumpAndSettle();

    expect(find.text('Trip 1 stops'), findsOneWidget);
    expect(find.text('Morning · 7:00 – 11:00 am'), findsOneWidget);
    expect(find.text('ABC Textile Mills · Sorted'), findsOneWidget);
    expect(find.text('Shree Sai Dairy · Mixed'), findsOneWidget);
    expect(find.text('Next stop'), findsNWidgets(2));
    expect(find.text('Still to collect (1)'), findsOneWidget);
  });

  testWidgets('pending stop continues to collection entry detail', (
    tester,
  ) async {
    _setDesignSize(tester);
    await tester.pumpWidget(const MaterialApp(home: DriverStopsScreen()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('driver-enter-collection')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-enter-collection')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Location is off'), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-turn-on-location')));
    await tester.pump();
    expect(find.text('Finding your location'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(find.text('Location detected'), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-start-collection')));
    await tester.pumpAndSettle();

    expect(find.text('Stop Detail'), findsOneWidget);
    expect(find.text('Request Information'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('driver-start-pickup')),
      400,
      scrollable: find.descendant(
        of: find.byKey(const Key('driver-stop-detail')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Start Pickup'), findsOneWidget);
  });

  testWidgets('collected stop opens the read-only collection record', (
    tester,
  ) async {
    _setDesignSize(tester);
    await tester.pumpWidget(const MaterialApp(home: DriverStopsScreen()));
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const Key('driver-stops-list')),
      const Offset(0, -1500),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('driver-collected-stop-2')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('driver-collected-stop-2')));
    await tester.pumpAndSettle();

    expect(find.text('Stop 2 · collection'), findsOneWidget);
    expect(find.text('Hotel Rajdhani · Sorted'), findsOneWidget);
    expect(find.text('Saved at 7:52 am · Thu 22 Jul'), findsOneWidget);
    expect(find.text('What you saved'), findsOneWidget);
    expect(find.text('85 kg'), findsOneWidget);
    expect(find.text('PET Bottles'), findsOneWidget);
    expect(find.text('Cardboard'), findsOneWidget);
    expect(find.text('Photos (material and scale)'), findsOneWidget);
    expect(find.text('Ask supervisor to correct'), findsOneWidget);

    await tester.tap(find.text('Ask supervisor to correct'));
    await tester.pumpAndSettle();

    expect(find.text('Ask to correct'), findsOneWidget);
    expect(
      find.byKey(const Key('driver-correction-problem-label')),
      findsOneWidget,
    );
    expect(find.text('Weight'), findsOneWidget);
    expect(find.text('Item'), findsOneWidget);
    expect(find.text('Photo'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    expect(
      find.byKey(const Key('driver-correction-note-label')),
      findsOneWidget,
    );
    expect(find.text('Max 150 Characters'), findsOneWidget);
    expect(find.text('Send to supervisor'), findsOneWidget);

    await tester.tap(find.byKey(const Key('driver-correction-item')));
    await tester.enterText(
      find.byKey(const Key('driver-correction-note')),
      List.filled(151, 'a').join(),
    );
    await tester.pump();
    final note = tester.widget<TextField>(
      find.byKey(const Key('driver-correction-note')),
    );
    expect(note.controller!.text.length, 150);

    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-send-correction')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('driver-correction-sent-modal')),
      findsOneWidget,
    );
    expect(find.text('Request sent'), findsOneWidget);
    expect(find.text('to your supervisor'), findsOneWidget);
    expect(
      find.text('Hotel Rajdhani · weight · 50 kg → 60 kg'),
      findsOneWidget,
    );
    expect(find.text('WHAT HAPPENS NEXT'), findsOneWidget);
    expect(find.text('Back to my stops'), findsOneWidget);
    expect(find.text('Back to home'), findsOneWidget);

    await tester.tap(find.byKey(const Key('driver-correction-back-stops')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('driver-stops-list')), findsOneWidget);
  });

  testWidgets('stop list uses Gujarati localization', (tester) async {
    _setDesignSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('gu'),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: [Locale('en'), Locale('gu'), Locale('hi')],
        home: DriverStopsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ટ્રિપ 1 સ્ટોપ્સ'), findsOneWidget);
    expect(find.text('ABC ટેક્સટાઇલ મિલ્સ · છાંટેલું'), findsOneWidget);
    expect(find.text('હજુ કલેક્શન બાકી (1)'), findsOneWidget);
  });
}

void _setDesignSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
