import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickup_supervisor/driver/services/driver_photo_capture.dart';
import 'package:pickup_supervisor/driver/view/driver_location_flow_screen.dart';
import 'package:pickup_supervisor/driver/widgets/driver_pickup_form_widgets.dart';

void main() {
  testWidgets('location flow exposes all Figma popup branches', (tester) async {
    _setDesignSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: DriverLocationFlowScreen(
          autoDetectDuration: Duration(seconds: 1),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Location is off'), findsOneWidget);
    expect(find.text('Turn on location'), findsNWidgets(2));
    await tester.tap(find.byKey(const Key('driver-turn-on-location')));
    await tester.pump();

    expect(find.text('Finding your location…'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.text('Location detected'), findsOneWidget);
    expect(find.text('Shree Sai Dairy'), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-location-not-here')));
    await tester.pump();

    expect(find.text('No stop found here'), findsOneWidget);
    expect(find.text('Gate team will enter'), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-choose-stop')));
    await tester.pump();

    expect(find.text('2 stops nearby'), findsOneWidget);
    expect(find.text('Which stop are you at?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-nearby-stop-1')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('driver-nearby-not-here')));
    await tester.pump();

    expect(find.text('No stop found here'), findsOneWidget);
  });

  testWidgets('gate team route reuses two-photo and note limits', (
    tester,
  ) async {
    _setDesignSize(tester);
    var captureCount = 0;
    await tester.pumpWidget(
      DriverPhotoCaptureScope(
        adapter: DriverPhotoCaptureAdapter(
          capture: (context, {required recoveryId, required title}) async {
            captureCount++;
            return XFile('assets/images/driver/pickup/pet_photo.png');
          },
        ),
        child: const MaterialApp(
          home: DriverLocationFlowScreen(
            initialState: DriverLocationFlowState.notAtStop,
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('driver-no-stop-gate-team')));
    await tester.pumpAndSettle();

    expect(find.text('Gate team will enter'), findsOneWidget);
    expect(find.text('Shree Sai Dairy · Stop 7 of 7'), findsOneWidget);
    expect(find.text('Weight you noted (optional)'), findsOneWidget);
    expect(find.text('Photo (optional)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('driver-gate-capture-photo')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-gate-capture-photo')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-gate-capture-photo')));
    await tester.pumpAndSettle();

    expect(captureCount, 2);
    expect(find.byType(DriverPhotoThumbnail), findsNWidgets(2));

    await tester.scrollUntilVisible(
      find.byKey(const Key('driver-gate-note')),
      300,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('driver-gate-team-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.enterText(
      find.byKey(const Key('driver-gate-note')),
      List.filled(151, 'a').join(),
    );
    final note = tester.widget<TextField>(
      find.byKey(const Key('driver-gate-note')),
    );
    expect(note.controller!.text.length, 150);
  });

  testWidgets('detected stop starts the mixed collection detail', (
    tester,
  ) async {
    _setDesignSize(tester);
    await tester.pumpWidget(
      const MaterialApp(
        home: DriverLocationFlowScreen(
          initialState: DriverLocationFlowState.detected,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('driver-start-collection')));
    await tester.pumpAndSettle();

    expect(find.text('Stop Detail'), findsOneWidget);
    expect(find.text('Shree Sai Dairy'), findsOneWidget);
    expect(find.text('Mixed'), findsOneWidget);
  });
}

void _setDesignSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
