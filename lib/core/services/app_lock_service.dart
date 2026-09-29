import 'dart:io';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AppLockService {
  AppLockService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// Check if the device has biometric or device credential support.
  Future<bool> isLockSupported() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return isSupported || canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Trigger device lock (Biometrics / PIN / Pattern / Password).
  ///
  /// Returns `true` if authentication succeeded or if the device does not
  /// support device locks. Returns `false` if authentication failed or was cancelled.
  Future<bool> authenticate({
    String localizedReason = 'Please unlock to access the app',
  }) async {
    try {
      final supported = await isLockSupported();
      if (!supported) {
        return true;
      }

      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Direct close/exit of the application.
  static void closeApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      exit(0);
    }
  }
}
