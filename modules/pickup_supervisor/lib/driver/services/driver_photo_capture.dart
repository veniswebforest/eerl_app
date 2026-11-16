import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

typedef DriverCapturePhoto =
    Future<XFile?> Function(
      BuildContext context, {
      required String recoveryId,
      required String title,
    });

typedef DriverRecoverPhoto = Future<XFile?> Function(String recoveryId);

/// Camera integration supplied by the host app.
///
/// The EERL host uses its existing in-app camera and lost-data recovery. The
/// module keeps an [ImagePicker] fallback so it also remains runnable alone.
class DriverPhotoCaptureAdapter {
  const DriverPhotoCaptureAdapter({required this.capture, this.recover});

  final DriverCapturePhoto capture;
  final DriverRecoverPhoto? recover;
}

class DriverPhotoCaptureScope extends InheritedWidget {
  const DriverPhotoCaptureScope({
    super.key,
    required this.adapter,
    required super.child,
  });

  final DriverPhotoCaptureAdapter adapter;

  static DriverPhotoCaptureAdapter of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<DriverPhotoCaptureScope>()
            ?.adapter ??
        _fallbackAdapter;
  }

  static final DriverPhotoCaptureAdapter _fallbackAdapter =
      DriverPhotoCaptureAdapter(
        capture: (context, {required recoveryId, required title}) async {
          try {
            return await ImagePicker().pickImage(
              source: ImageSource.camera,
              maxWidth: 1080,
              maxHeight: 1920,
              imageQuality: 70,
              requestFullMetadata: false,
            );
          } catch (_) {
            return null;
          }
        },
      );

  @override
  bool updateShouldNotify(DriverPhotoCaptureScope oldWidget) {
    return oldWidget.adapter != adapter;
  }
}
