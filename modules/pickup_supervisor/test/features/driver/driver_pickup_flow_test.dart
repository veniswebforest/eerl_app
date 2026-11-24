import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickup_supervisor/features/driver/model/driver_pickup_stop.dart';
import 'package:pickup_supervisor/features/driver/service/driver_photo_capture.dart';
import 'package:pickup_supervisor/features/driver/view/driver_sorted_waste_form_screen.dart';
import 'package:pickup_supervisor/features/driver/view/driver_stop_detail_screen.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_pickup_form_widgets.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_voice_note_recorder.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';

void main() {
  testWidgets('sorted detail opens empty, filled, and success states', (
    tester,
  ) async {
    _setDesignSize(tester, const Size(375, 1800));
    var captureCount = 0;
    await tester.pumpWidget(
      _cameraHost(
        onCapture: () {
          captureCount++;
          return XFile(
            captureCount.isOdd
                ? 'assets/images/driver/pickup/pet_photo.png'
                : 'assets/images/driver/pickup/scale_photo.png',
          );
        },
        child: const MaterialApp(
          home: DriverStopDetailScreen(pickupType: DriverPickupType.sorted),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ABC Textile Mills'), findsOneWidget);
    await tester.tap(find.text('Start Pickup'));
    await tester.pumpAndSettle();

    expect(find.text('Sorted Waste Form'), findsOneWidget);
    expect(find.text('PET Bottles  •  KG'), findsOneWidget);
    expect(find.text('ex 123.00'), findsNWidgets(3));
    final saveButton = tester.widget<FilledButton>(
      find.byKey(const Key('driver-save-pickup')),
    );
    expect(saveButton.onPressed, isNull);

    await tester.tap(find.byKey(const Key('driver-capture-photo-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-capture-photo-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-capture-photo-0')));
    await tester.pumpAndSettle();
    expect(captureCount, 2);
    expect(find.byType(DriverPhotoThumbnail), findsNWidgets(2));

    await tester.tap(find.byKey(const Key('driver-capture-photo-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-capture-photo-2')));
    await tester.pumpAndSettle();
    expect(find.text('270.00'), findsNWidgets(2));
    expect(find.text('25'), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('driver-sorted-form')),
      const Offset(0, -1600),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-save-pickup')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Pickup Recorded'), findsOneWidget);
    expect(find.text('Successfully!'), findsOneWidget);
    expect(find.text('NEXT STOP · 7 OF 7'), findsOneWidget);
    expect(find.text('Go to next stop'), findsOneWidget);
    expect(find.text('Back to List'), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-go-next-stop')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Location is off'), findsOneWidget);
  });

  testWidgets('mixed detail opens its dedicated form and success state', (
    tester,
  ) async {
    _setDesignSize(tester, const Size(375, 812));
    var captureCount = 0;
    await tester.pumpWidget(
      _cameraHost(
        onCapture: () {
          captureCount++;
          return XFile(
            captureCount.isOdd
                ? 'assets/images/driver/pickup/mixed_photo_base.png'
                : 'assets/images/driver/pickup/mixed_scale_photo.png',
          );
        },
        child: const MaterialApp(
          home: DriverStopDetailScreen(pickupType: DriverPickupType.mixed),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Shree Sai Dairy'), findsOneWidget);
    expect(find.text('+91 1234567890'), findsOneWidget);
    expect(find.text('Mixed'), findsOneWidget);
    expect(find.text('200 KG'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('driver-start-pickup')),
      400,
      scrollable: find.descendant(
        of: find.byKey(const Key('driver-stop-detail')),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-start-pickup')));
    await tester.pumpAndSettle();

    expect(find.text('Mixed Waste Form'), findsOneWidget);
    expect(find.text('300.00'), findsOneWidget);
    expect(find.text('Supported: JPG, PNG (Max 5MB).'), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-capture-photo-mixed')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-capture-photo-mixed')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-capture-photo-mixed')));
    await tester.pumpAndSettle();
    expect(captureCount, 2);
    expect(find.byType(DriverPhotoThumbnail), findsNWidgets(2));
    await tester.tap(find.byKey(const Key('driver-save-pickup')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Pickup Recorded'), findsOneWidget);
    expect(find.text('Successfully!'), findsOneWidget);
    expect(find.text('ALL 7 STOPS OF TRIP 1 DONE'), findsOneWidget);
    expect(find.text('Take the load to Magdalla Warehouse'), findsOneWidget);
    expect(find.text('1,260 kg + 25 pcs on the vehicle'), findsOneWidget);
    expect(find.text('View trip summary'), findsOneWidget);
  });

  testWidgets('nothing to collect opens the 0 kg form', (tester) async {
    _setDesignSize(tester, const Size(375, 812));
    var captureCount = 0;
    await tester.pumpWidget(
      _cameraHost(
        onCapture: () {
          captureCount++;
          return XFile('assets/images/driver/pickup/pet_photo.png');
        },
        child: const MaterialApp(home: DriverStopDetailScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Stop 6 of 7 · Trip 1'), findsOneWidget);
    expect(find.text('Person at the pickup point'), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('driver-stop-detail')),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-nothing-to-collect')));
    await tester.pumpAndSettle();

    expect(find.text('Nothing to collect'), findsOneWidget);
    expect(find.text('ABC Textile Mills · Stop 6 of 7'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('driver-zero-reason-label')),
      200,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('driver-nothing-collect-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.textContaining('Why was nothing collected?'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('driver-zero-reason-closed')),
      300,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('driver-nothing-collect-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('No material today'), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-zero-reason-closed')));
    await tester.scrollUntilVisible(
      find.byKey(const Key('driver-zero-capture-photo')),
      300,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('driver-nothing-collect-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Photo (optional)'), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-zero-capture-photo')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-zero-capture-photo')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('driver-zero-capture-photo')));
    await tester.pumpAndSettle();

    expect(captureCount, 2);
    expect(find.byType(DriverPhotoThumbnail), findsNWidgets(2));
    await tester.scrollUntilVisible(
      find.byKey(const Key('driver-zero-note')),
      300,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('driver-nothing-collect-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.enterText(
      find.byKey(const Key('driver-zero-note')),
      List.filled(151, 'a').join(),
    );
    await tester.pump();
    final note = tester.widget<TextField>(
      find.byKey(const Key('driver-zero-note')),
    );
    expect(note.controller!.text.length, 150);
  });

  testWidgets('waste form supports mismatch, editable values, and voice note', (
    tester,
  ) async {
    _setDesignSize(tester, const Size(375, 1800));
    await tester.pumpWidget(
      _cameraHost(
        onCapture: () => XFile('assets/images/driver/pickup/pet_photo.png'),
        child: const MaterialApp(
          home: DriverSortedWasteFormScreen(locationMatched: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Location not matched'), findsOneWidget);
    expect(find.textContaining('Recorded later:'), findsOneWidget);
    expect(find.byType(DriverVoiceNoteRecorder), findsOneWidget);
    expect(find.byKey(const Key('driver-voice-note-recorder')), findsOneWidget);

    final collectedFields = find.byType(DriverEditableValueField);
    expect(collectedFields, findsNWidgets(3));
    final firstTextField = find.descendant(
      of: collectedFields.first,
      matching: find.byType(TextField),
    );
    expect(
      find.descendant(of: collectedFields.first, matching: find.text('KG')),
      findsOneWidget,
    );
    final collectedInput = tester.widget<TextField>(firstTextField);
    expect(collectedInput.decoration?.prefixText, isNull);
    expect(collectedInput.decoration?.focusedBorder, InputBorder.none);
    await tester.enterText(firstTextField, '125.50');
    expect(find.text('125.50'), findsOneWidget);
  });

  testWidgets('recorded voice note exposes playback and remove actions', (
    tester,
  ) async {
    var playTaps = 0;
    var removeTaps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: DriverLocalizationScope(
          child: Scaffold(
            body: DriverVoicePlaybackCard(
              isPlaying: false,
              position: const Duration(seconds: 5),
              duration: const Duration(seconds: 12),
              onPlayPause: () => playTaps++,
              onRemove: () => removeTaps++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('driver-voice-playback-card')), findsOneWidget);
    expect(find.text('0:05 / 0:12'), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-voice-play-pause')));
    await tester.tap(find.byKey(const Key('driver-voice-remove')));
    expect(playTaps, 1);
    expect(removeTaps, 1);
  });
}

Widget _cameraHost({
  required XFile Function() onCapture,
  required Widget child,
}) {
  return DriverPhotoCaptureScope(
    adapter: DriverPhotoCaptureAdapter(
      capture: (context, {required recoveryId, required title}) async {
        return onCapture();
      },
    ),
    child: child,
  );
}

void _setDesignSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
