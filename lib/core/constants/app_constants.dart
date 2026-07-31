/// Application-wide constants for the EERL App.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'EERL App';

  // SharedPreferences Keys
  static const String themeKey = 'app_theme_mode';
  static const String localeKey = 'app_locale';

  // Default Values
  static const String defaultLocale = 'en';

  // Supported Locales
  static const List<String> supportedLocaleCodes = ['en', 'hi'];
}
