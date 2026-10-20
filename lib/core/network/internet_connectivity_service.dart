import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/logging/app_logger.dart';

/// Verifies both a network interface and reachability of the EERL API host.
///
/// `connectivity_plus` alone cannot guarantee internet access (for example, a
/// Wi-Fi network may have no upstream connection), so sync also performs a
/// short TCP probe before any API request is attempted.
class InternetConnectivityService {
  InternetConnectivityService._();

  static final InternetConnectivityService instance =
      InternetConnectivityService._();
  static const _timeout = Duration(seconds: 4);

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

      final uri = Uri.parse(AppConstants.apiBaseUrl);
      final addresses = await InternetAddress.lookup(
        uri.host,
      ).timeout(_timeout);
      if (addresses.isEmpty) {
        _log('API host DNS lookup returned no address');
        return false;
      }
      final port = uri.hasPort ? uri.port : 443;
      for (final address in addresses) {
        try {
          final socket = await Socket.connect(address, port, timeout: _timeout);
          socket.destroy();
          _log('Internet available; API host is reachable');
          return true;
        } on Object {
          // Try the next resolved address (for example IPv4 after IPv6).
        }
      }
      _log('API host could not be reached on port $port');
      return false;
    } on Object catch (error) {
      _log('Internet unavailable: $error');
      return false;
    }
  }

  static void _log(String message) {
    AppLogger.diagnostic('CONNECTIVITY', message);
  }
}
