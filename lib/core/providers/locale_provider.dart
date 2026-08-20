import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Manages the application locale and persists the user's choice
/// to [SharedPreferences].
class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  /// Current locale. `null` means "follow the system".
  Locale? get locale => _locale;

  /// Load the persisted locale preference.
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.localeKey);

    if (saved != null && AppConstants.supportedLocaleCodes.contains(saved)) {
      _locale = Locale(saved);
      notifyListeners();
    }
  }

  /// Update and persist the locale.
  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;

    if (!AppConstants.supportedLocaleCodes.contains(newLocale.languageCode)) {
      return;
    }

    _locale = newLocale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.localeKey, newLocale.languageCode);
  }

  /// Clear the saved locale and fall back to system default.
  Future<void> clearLocale() async {
    _locale = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.localeKey);
  }
}
