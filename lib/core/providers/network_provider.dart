import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:eerl_app/core/network/internet_connectivity_service.dart';
import 'package:flutter/foundation.dart';

/// Manages real-time network connectivity state across the application.
class NetworkProvider extends ChangeNotifier {
  NetworkProvider({
    Connectivity? connectivity,
    Future<bool> Function()? internetAccessChecker,
    this.reachabilityInterval = const Duration(seconds: 15),
  }) : _connectivity = connectivity ?? Connectivity(),
       _internetAccessChecker =
           internetAccessChecker ??
           InternetConnectivityService.instance.hasInternetAccess {
    _initConnectivity();
  }

  final Connectivity _connectivity;
  final Future<bool> Function() _internetAccessChecker;
  final Duration reachabilityInterval;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _reachabilityTimer;
  int _checkGeneration = 0;

  bool _isOffline = false;
  bool _showRestoredBanner = false;
  bool _isBannerDismissed = false;
  Timer? _restoredBannerTimer;
  bool _disposed = false;

  bool get isOffline => _isOffline;
  bool get showRestoredBanner => _showRestoredBanner;
  bool get isBannerDismissed => _isBannerDismissed;

  bool get shouldShowBanner =>
      (_isOffline && !_isBannerDismissed) || _showRestoredBanner;

  void _initConnectivity() async {
    try {
      final initialResults = await _connectivity.checkConnectivity();
      if (_disposed) return;
      await _refreshConnectionStatus(initialResults, isInitial: true);
    } catch (e) {
      AppLogger.error('CONNECTIVITY', 'Initial check failed: $e');
      _setOffline(true, isInitial: true);
    }

    if (_disposed) return;
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      if (_disposed) return;
      unawaited(_refreshConnectionStatus(results));
    });
    _reachabilityTimer = Timer.periodic(
      reachabilityInterval,
      (_) => unawaited(_refreshCurrentConnection()),
    );
  }

  Future<void> _refreshCurrentConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      if (_disposed) return;
      await _refreshConnectionStatus(results);
    } catch (error) {
      AppLogger.error('CONNECTIVITY', 'Periodic check failed: $error');
      _setOffline(true);
    }
  }

  Future<void> _refreshConnectionStatus(
    List<ConnectivityResult> results, {
    bool isInitial = false,
  }) async {
    final generation = ++_checkGeneration;
    final hasNoInterface =
        results.isEmpty ||
        results.every((result) => result == ConnectivityResult.none);
    if (hasNoInterface) {
      _setOffline(true, isInitial: isInitial);
      return;
    }

    bool hasInternet;
    try {
      hasInternet = await _internetAccessChecker();
    } catch (error) {
      AppLogger.error('CONNECTIVITY', 'Reachability check failed: $error');
      hasInternet = false;
    }
    if (_disposed || generation != _checkGeneration) return;
    _setOffline(!hasInternet, isInitial: isInitial);
  }

  void _setOffline(bool offline, {bool isInitial = false}) {
    if (_isOffline == offline && !isInitial) return;

    final wasOffline = _isOffline;
    _isOffline = offline;
    _isBannerDismissed = false;

    if (wasOffline && !_isOffline && !isInitial) {
      // Connection restored!
      _showRestoredBanner = true;
      _restoredBannerTimer?.cancel();
      _restoredBannerTimer = Timer(const Duration(seconds: 3), () {
        if (_disposed) return;
        _showRestoredBanner = false;
        notifyListeners();
      });
    } else if (_isOffline) {
      _showRestoredBanner = false;
    }

    AppLogger.diagnostic(
      'CONNECTIVITY',
      'offline=$_isOffline restoredBanner=$_showRestoredBanner',
    );
    notifyListeners();
  }

  void dismissBanner() {
    if (_isBannerDismissed && !_showRestoredBanner) return;
    _isBannerDismissed = true;
    _showRestoredBanner = false;
    _restoredBannerTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _reachabilityTimer?.cancel();
    _restoredBannerTimer?.cancel();
    super.dispose();
  }
}
