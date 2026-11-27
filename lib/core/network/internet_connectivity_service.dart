import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eerl_app/core/logging/app_logger.dart';

/// Reports whether Android/iOS currently exposes an active network interface.
///
/// This deliberately does not perform a DNS or raw TCP preflight. Some Android
/// devices block or misroute an unbound raw socket even while normal HTTPS is
/// working. Treating that probe as authoritative prevented the real API call
/// from running at all. API services remain responsible for timeout/socket
/// errors, while the outbox keeps pending writes retryable.
class InternetConnectivityService {
  InternetConnectivityService._();

  static final InternetConnectivityService instance =
      InternetConnectivityService._();
  Stream<void> get connectivityChanges =>
      Connectivity().onConnectivityChanged.map((_) {});

  Future<bool> hasInternetAccess() async {
    try {
      final connections = await Connectivity().checkConnectivity();
      if (connections.isEmpty ||
          connections.every((item) => item == ConnectivityResult.none)) {
        _log('No active network interface');
        return false;
      }
      _log('Active network interface available; allowing HTTPS request');
      return true;
    } on Object catch (error) {
      _log('Internet unavailable: $error');
      return false;
    }
  }

  static void _log(String message) {
    AppLogger.diagnostic('CONNECTIVITY', message);
  }
}
