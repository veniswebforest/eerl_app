import 'dart:io';

import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

class AppLockService {
  AppLockService({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;
  String? lastErrorMessage;

  /// Check if the device has biometric or device credential support.
  Future<bool> isLockSupported() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final available = await _auth.getAvailableBiometrics();
      return isSupported || canCheck || available.isNotEmpty;
    } catch (e) {
      AppLogger.error('APP_LOCK', 'Support check failed: $e');
      return false;
    }
  }

  /// Trigger device lock (Biometrics / PIN / Pattern / Password).
  ///
  /// Returns `true` if authentication succeeded. Returns `false` if authentication failed,
  /// was cancelled, or the device lacks credentials.
  Future<bool> authenticate({
    String localizedReason = 'Please unlock to access the app',
  }) async {
    lastErrorMessage = null;
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final available = await _auth.getAvailableBiometrics();

      final hasAnySupport = isSupported || canCheck || available.isNotEmpty;
      if (!hasAnySupport) {
        lastErrorMessage =
            'Device lock is not supported on this device. Please set up a Screen Lock (PIN, Pattern, or Fingerprint) in device Settings.';
        return false;
      }

      bool authenticated = false;
      try {
        // Attempt 1: Allow biometrics or device credentials (PIN/Pattern/Password)
        authenticated = await _auth.authenticate(
          localizedReason: localizedReason,
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
            useErrorDialogs: true,
          ),
        );
      } on PlatformException catch (pe) {
        AppLogger.diagnostic(
          'APP_LOCK',
          'Credential authentication unavailable; trying biometric fallback '
              '| code=${pe.code}',
        );
        if (canCheck || available.isNotEmpty) {
          // Attempt 2: Biometric only fallback if device credentials failed
          authenticated = await _auth.authenticate(
            localizedReason: localizedReason,
            options: const AuthenticationOptions(
              biometricOnly: true,
              stickyAuth: true,
              useErrorDialogs: true,
            ),
          );
        } else {
          rethrow;
        }
      }

      if (!authenticated) {
        lastErrorMessage = 'Authentication was cancelled or failed.';
      }
      return authenticated;
    } on PlatformException catch (e) {
      AppLogger.error('APP_LOCK', 'Platform error code=${e.code}');
      if (e.code == auth_error.passcodeNotSet ||
          e.code == auth_error.notEnrolled ||
          e.code == 'PasscodeNotSet' ||
          e.code == 'NotEnrolled') {
        lastErrorMessage =
            'No screen lock configured. Please set up a PIN, Pattern, or Fingerprint in your device Settings.';
      } else if (e.code == auth_error.notAvailable ||
          e.code == 'NotAvailable') {
        lastErrorMessage =
            'Security lock is not available on this device. Please configure device security in Settings.';
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut ||
          e.code == 'LockedOut' ||
          e.code == 'PermanentlyLockedOut') {
        lastErrorMessage =
            'Too many failed attempts. Biometrics temporarily locked. Please unlock device first.';
      } else if (e.code == 'UserCancel' || e.code == 'Canceled') {
        lastErrorMessage = 'Authentication was cancelled.';
      } else {
        lastErrorMessage = e.message ?? 'Authentication failed.';
      }
      return false;
    } catch (e) {
      AppLogger.error('APP_LOCK', e.toString());
      lastErrorMessage = 'Authentication failed: $e';
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
