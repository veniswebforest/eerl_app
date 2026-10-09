import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:eerl_app/features/auth/model/verify_otp_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionStorage {
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
    AppLogger.diagnostic('AUTH_SESSION', 'Session saved');
  }

  Future<String?> getAccessToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(AppConstants.accessTokenKey);
  }

  Future<DateTime?> getSessionExpiresAt() async {
    final preferences = await SharedPreferences.getInstance();
    final rawExpiry = preferences.getString(AppConstants.sessionExpiresAtKey);
    return rawExpiry != null ? DateTime.tryParse(rawExpiry) : null;
  }

  /// Checks if access token is not null/empty and sessionExpiresAt is in the future relative to current time.
  Future<bool> isSessionValid() async {
    final token = await getAccessToken();
    final expiresAt = await getSessionExpiresAt();
    if (token == null || token.trim().isEmpty || expiresAt == null) {
      AppLogger.diagnostic('AUTH_SESSION', 'Session is unavailable');
      return false;
    }
    final now = DateTime.now().toUtc();
    final expiryUtc = expiresAt.toUtc();
    final isValid = now.isBefore(expiryUtc);
    AppLogger.diagnostic('AUTH_SESSION', 'Session valid=$isValid');
    return isValid;
  }

  Future<void> clearSession() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.remove(AppConstants.accessTokenKey),
      preferences.remove(AppConstants.sessionExpiresAtKey),
    ]);
    AppLogger.diagnostic('AUTH_SESSION', 'Session cleared');
  }
}
