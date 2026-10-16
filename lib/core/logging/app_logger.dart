import 'dart:convert';

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

  /// Prints the final HTTP request as a readable cURL without exposing the
  /// access token. Headers and body must come from the request being sent so
  /// the diagnostic cannot silently omit a request parameter.
  static void apiCurl(
    String method,
    Uri url, {
    Map<String, String> headers = const <String, String>{},
    String? body,
  }) {
    if (!kDebugMode) return;
    final safeHeaders = <String, String>{
      for (final entry in headers.entries)
        entry.key: entry.key.toLowerCase() == 'authorization'
            ? 'Bearer YOUR_ACCESS_TOKEN'
            : entry.value,
    };
    final parts = <String>[
      'curl --location --request ${_shellQuote(method.toUpperCase())}',
      _shellQuote(url.toString()),
      for (final entry in safeHeaders.entries)
        '--header ${_shellQuote('${entry.key}: ${entry.value}')}',
      if (body != null && body.isNotEmpty)
        '--data-raw ${_shellQuote(_prettyJson(body))}',
    ];
    final timestamp = DateTime.now().toUtc().toIso8601String();
    debugPrint(
      '[$timestamp][API][CURL]\n${parts.join(' \\\n  ')}',
      // JSON is pretty-printed above, so every request parameter remains
      // visible instead of a large single Logcat line being truncated.
      wrapWidth: 4000,
    );
  }

  /// Prints the complete HTTP response paired with the request URL. JSON is
  /// formatted for copy/debug use and credentials are redacted recursively.
  static void apiResponse(
    String method,
    Uri url, {
    required int statusCode,
    required Duration duration,
    String? body,
  }) {
    if (!kDebugMode) return;
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final responseBody = body == null || body.isEmpty
        ? '<empty>'
        : _prettyJson(body);
    debugPrint(
      '[$timestamp][API][RESPONSE] ${method.toUpperCase()} $url | '
      'status=$statusCode | duration=${duration.inMilliseconds}ms\n'
      '$responseBody',
      wrapWidth: 4000,
    );
  }

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

  static String _shellQuote(String value) =>
      "'${value.replaceAll("'", "'\"'\"'")}'";

  static String _prettyJson(String value) {
    try {
      return const JsonEncoder.withIndent(
        '  ',
      ).convert(_redactJsonValue(jsonDecode(value)));
    } on FormatException {
      return _redact(value);
    }
  }

  static Object? _redactJsonValue(Object? value, [String? key]) {
    if (key != null && _isSensitiveKey(key)) return '[REDACTED]';
    if (value is Map) {
      return <String, Object?>{
        for (final entry in value.entries)
          entry.key.toString(): _redactJsonValue(
            entry.value,
            entry.key.toString(),
          ),
      };
    }
    if (value is List) {
      return value.map((item) => _redactJsonValue(item)).toList();
    }
    return value;
  }

  static bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return normalized.contains('token') ||
        normalized == 'authorization' ||
        normalized == 'password' ||
        normalized == 'otp';
  }

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
