import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Manages real-time network connectivity state across the application.
class NetworkProvider extends ChangeNotifier {
  NetworkProvider({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _initConnectivity();
  }

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOffline = false;
  bool _showRestoredBanner = false;
  bool _isBannerDismissed = false;
  Timer? _restoredBannerTimer;

  bool get isOffline => _isOffline;
  bool get showRestoredBanner => _showRestoredBanner;
  bool get isBannerDismissed => _isBannerDismissed;

  bool get shouldShowBanner =>
      (_isOffline && !_isBannerDismissed) || _showRestoredBanner;

  void _initConnectivity() async {
    try {
      final initialResults = await _connectivity.checkConnectivity();
      _updateConnectionStatus(initialResults, isInitial: true);
    } catch (e) {
      debugPrint('[NetworkProvider] Error checking initial connectivity: $e');
    }

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });
  }

  void _updateConnectionStatus(
    List<ConnectivityResult> results, {
    bool isInitial = false,
  }) {
    final offline =
        results.isEmpty ||
        results.every((result) => result == ConnectivityResult.none);

    if (_isOffline == offline && !isInitial) return;

    final wasOffline = _isOffline;
    _isOffline = offline;
    _isBannerDismissed = false;

    if (wasOffline && !_isOffline && !isInitial) {
      // Connection restored!
      _showRestoredBanner = true;
      _restoredBannerTimer?.cancel();
      _restoredBannerTimer = Timer(const Duration(seconds: 3), () {
        _showRestoredBanner = false;
        notifyListeners();
      });
    } else if (_isOffline) {
      _showRestoredBanner = false;
    }

    debugPrint(
      '[NetworkProvider] Connection status updated: isOffline=$_isOffline, showRestored=$_showRestoredBanner',
    );
    notifyListeners();
  }

  void dismissBanner() {
    _isBannerDismissed = true;
    _showRestoredBanner = false;
    _restoredBannerTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _restoredBannerTimer?.cancel();
    super.dispose();
  }
}
