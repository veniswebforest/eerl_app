import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/app_lock_service.dart';

class AppLockProvider extends ChangeNotifier {
  AppLockProvider({AppLockService? lockService})
    : _lockService = lockService ?? AppLockService();

  static const String _prefKey = 'app_lock_enabled';
  final AppLockService _lockService;
  bool _isLockEnabled = false;
  bool _isLoaded = false;

  bool get isLockEnabled => _isLockEnabled;
  bool get isLoaded => _isLoaded;
  AppLockService get lockService => _lockService;

  Future<void> loadLockSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLockEnabled = prefs.getBool(_prefKey) ?? false;
    } catch (_) {
      _isLockEnabled = false;
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<bool> setLockEnabled(bool enabled) async {
    if (_isLockEnabled == enabled) return true;

    if (enabled) {
      // Prompt device lock / biometric check before enabling
      final authenticated = await _lockService.authenticate(
        localizedReason: 'Please authenticate to enable App Lock',
      );
      if (!authenticated) {
        return false;
      }
    }

    _isLockEnabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, enabled);
    } catch (_) {}

    return true;
  }
}
