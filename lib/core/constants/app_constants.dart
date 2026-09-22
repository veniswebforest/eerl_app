class AppConstants {
  AppConstants._();

  static const assetImage = 'assets/images/';
  static const assetIcon = 'assets/icons/';
  static const assetSvg = 'assets/svg/';
  static const assetLottie = 'assets/lottie/';
  static const assetRoot = 'assets/';

  static const String appName = 'EERL App';

  static const String apiBaseUrl = 'https://eerl-backend.onrender.com/api/v1';
  static const String sendOtpPath = '/mobile/auth/send-otp';
  static const String verifyOtpPath = '/mobile/auth/verify-otp';

  // SharedPreferences Keys
  static const String themeKey = 'app_theme_mode';
  static const String localeKey = 'app_locale';
  static const String accessTokenKey = 'auth_access_token';
  static const String sessionExpiresAtKey = 'auth_session_expires_at';

  // Default Values
  static const String defaultLocale = 'en';

  // Supported Locales
  static const List<String> supportedLocaleCodes = ['en', 'gu', 'hi'];
}
