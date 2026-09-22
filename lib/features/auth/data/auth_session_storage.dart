import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/features/auth/model/verify_otp_response.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionStorage {
  static const _tag = '[AuthSessionStorage]';

  Future<void> saveSession(VerifyOtpResponse response) async {
    final token = response.accessToken;
    final expiresAt = response.sessionExpiresAt;
    if (token == null || token.isEmpty || expiresAt == null) {
      throw const FormatException('Cannot save an incomplete auth session');
    }

    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setString(AppConstants.accessTokenKey, token),
      preferences.setString(
        AppConstants.sessionExpiresAtKey,
        expiresAt.toIso8601String(),
      ),
    ]);
    debugPrint(
      '$_tag Session saved: token=${_maskToken(token)}, expiresAt=${expiresAt.toIso8601String()}',
    );
  }

  Future<void> clearSession() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.remove(AppConstants.accessTokenKey),
      preferences.remove(AppConstants.sessionExpiresAtKey),
    ]);
    debugPrint('$_tag Session cleared');
  }

  String _maskToken(String token) {
    if (token.length <= 10) return '[REDACTED]';
    return '${token.substring(0, 6)}...${token.substring(token.length - 4)}';
  }
}
