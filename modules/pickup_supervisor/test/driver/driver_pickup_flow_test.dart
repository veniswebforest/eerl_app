import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickup_supervisor/driver/model/driver_pickup_stop.dart';
import 'package:pickup_supervisor/driver/services/driver_photo_capture.dart';
import 'package:pickup_supervisor/driver/view/driver_stop_detail_screen.dart';
import 'package:pickup_supervisor/driver/widgets/driver_pickup_form_widgets.dart';

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
    await tester.pumpAndSettle();

    expect(find.text('Pickup Recorded'), findsOneWidget);
    expect(find.text('Successfully!'), findsOneWidget);
    expect(find.text('Back to List'), findsOneWidget);
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

    await tester.drag(
      find.byKey(const Key('driver-stop-detail')),
      const Offset(0, -320),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Pickup'));
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
    await tester.pumpAndSettle();

    expect(find.text('Pickup Recorded'), findsOneWidget);
    expect(find.text('Successfully!'), findsOneWidget);
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
