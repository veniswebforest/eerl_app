import 'package:flutter/foundation.dart';

/// Debug-only, category-based application logging.
///
/// ANSI color starts before the timestamp and resets after the final
/// character, so the complete line receives one category color. Android
/// Studio's Flutter Run/Debug console supports these sequences. Some raw
/// Logcat viewers may display or strip ANSI escapes instead of rendering them.
abstract final class AppLogger {
  static const _reset = '\x1B[0m';
  static const _cyan = '\x1B[36m';
  static const _yellow = '\x1B[33m';
  static const _green = '\x1B[32m';
  static const _red = '\x1B[31m';
  static const _magenta = '\x1B[35m';
  static const _grey = '\x1B[90m';

  static bool ansiColorsEnabled = true;

  static void sqlite(String operation, String message) =>
      _write(_cyan, 'SQLITE', operation, message);

  static void sqliteError(String operation, String message) =>
      _write(_red, 'SQLITE', '${operation}_ERROR', message);

  static void apiRequest(String method, String endpoint, {String? message}) =>
      _write(
        _yellow,
        'API',
        'REQUEST',
        '${method.toUpperCase()} $endpoint${_suffix(message)}',
      );

  static void apiSuccess(
    String method,
    String endpoint, {
    required int statusCode,
    required Duration duration,
    String? message,
  }) => _write(
    _green,
    'API',
    'SUCCESS',
    '${method.toUpperCase()} $endpoint | status=$statusCode | '
        'duration=${duration.inMilliseconds}ms${_suffix(message)}',
  );

  static void apiError(
    String method,
    String endpoint, {
    int? statusCode,
    Duration? duration,
    Object? error,
  }) => _write(
    _red,
    'API',
    'ERROR',
    '${method.toUpperCase()} $endpoint'
        '${statusCode == null ? '' : ' | status=$statusCode'}'
        '${duration == null ? '' : ' | duration=${duration.inMilliseconds}ms'}'
        '${error == null ? '' : ' | error=$error'}',
  );

  static void sync(String operation, String message) =>
      _write(_magenta, 'SYNC', operation, message);

  static void syncError(String operation, String message) =>
      _write(_red, 'SYNC', '${operation}_ERROR', message);

  static void diagnostic(String operation, String message) =>
      _write(_grey, 'DIAGNOSTIC', operation, message);

  static void error(String operation, String message) =>
      _write(_red, 'DIAGNOSTIC', '${operation}_ERROR', message);

  static String _suffix(String? message) =>
      message == null || message.trim().isEmpty ? '' : ' | $message';

  static void _write(
    String color,
    String category,
    String operation,
    String message,
  ) {
    if (!kDebugMode) return;
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final plain =
        '[$timestamp][$category][${operation.toUpperCase()}] ${_redact(message)}';
    debugPrint(
      ansiColorsEnabled ? '$color$plain$_reset' : plain,
      wrapWidth: 1024,
    );
  }

  static String _redact(String value) {
    var safe = value.replaceAll(
      RegExp(r'Bearer\s+[^\s,}\]]+', caseSensitive: false),
      'Bearer [REDACTED]',
    );
    safe = safe.replaceAllMapped(
      RegExp(
        r'((?:access[_-]?token|refresh[_-]?token|authorization|password|otp)\s*[=:]\s*)[^\s,}\]]+',
        caseSensitive: false,
      ),
      (match) => '${match.group(1)}[REDACTED]',
    );
    return safe;
  }
}
