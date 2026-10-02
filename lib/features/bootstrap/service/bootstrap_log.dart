import 'package:flutter/foundation.dart';

/// Search Logcat for `EERL_BOOTSTRAP` to see the complete sync timeline.
abstract final class BootstrapLog {
  static int _requestSequence = 0;

  static String nextRequestId() {
    _requestSequence++;
    return 'B${_requestSequence.toString().padLeft(4, '0')}';
  }

  static void sync(String message) => _write('🔄', 'SYNC', message);

  static void database(String message) => _write('🗄️', 'SQLITE', message);

  static void warning(String message) => _write('⚠️', 'WARNING', message);

  static void error(String message) => _write('🛑', 'ERROR', message);

  static void httpRequest({
    required String requestId,
    required Uri uri,
    required bool hasCursor,
  }) {
    _write('➡️', 'HTTP][$requestId', 'REQUEST GET ${uri.path}');
    _write('  ', 'HTTP][$requestId', 'Query: ${uri.queryParameters}');
    _write('  ', 'HTTP][$requestId', 'Cursor supplied: $hasCursor');
    _write(
      '  ',
      'HTTP][$requestId',
      'Headers: {accept: application/json, Authorization: Bearer [REDACTED]}',
    );
  }

  static void httpResponse({
    required String requestId,
    required int statusCode,
    required int elapsedMilliseconds,
    required Map<String, Object?> summary,
  }) {
    _write(
      '⬅️',
      'HTTP][$requestId',
      'RESPONSE $statusCode (${elapsedMilliseconds}ms)',
    );
    _write('  ', 'HTTP][$requestId', 'Safe response: $summary');
  }

  static void httpError({
    required String requestId,
    int? statusCode,
    String? code,
    required Object error,
  }) {
    _write(
      '🛑',
      'HTTP][$requestId',
      'FAILED status=${statusCode ?? '-'} code=${code ?? '-'} error=$error',
    );
  }

  static void _write(String icon, String area, String message) {
    if (!kDebugMode) return;
    debugPrint('$icon [EERL_BOOTSTRAP][$area] $message');
  }
}
