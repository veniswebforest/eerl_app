import 'package:eerl_app/core/logging/app_logger.dart';

/// Search Logcat for `EERL_BOOTSTRAP` to see the complete sync timeline.
abstract final class BootstrapLog {
  static int _requestSequence = 0;

  static String nextRequestId() {
    _requestSequence++;
    return 'B${_requestSequence.toString().padLeft(4, '0')}';
  }

  static void sync(String message) => AppLogger.sync('BOOTSTRAP', message);

  static void database(String message) =>
      AppLogger.sqlite('BOOTSTRAP', message);

  /// Printed only after a Bootstrap page has committed to SQLite.
  /// Search Logcat for `EERL_BOOTSTRAP][SQLITE][COMMIT` to see stored rows.
  static void databaseCommit(String message) =>
      AppLogger.sqlite('COMMIT', 'Bootstrap $message');

  static void warning(String message) =>
      AppLogger.diagnostic('WARNING', message);

  static void error(String message) =>
      AppLogger.syncError('BOOTSTRAP', message);

  static void httpRequest({
    required String requestId,
    required Uri uri,
    required bool hasCursor,
  }) {
    AppLogger.apiRequest(
      'GET',
      uri.path,
      message: 'requestId=$requestId | cursorSupplied=$hasCursor',
    );
  }

  static void httpResponse({
    required String requestId,
    required int statusCode,
    required int elapsedMilliseconds,
  }) {
    AppLogger.apiSuccess(
      'GET',
      '/api/v1/mobile/bootstrap',
      statusCode: statusCode,
      duration: Duration(milliseconds: elapsedMilliseconds),
      message: 'requestId=$requestId',
    );
  }

  static void httpError({
    required String requestId,
    int? statusCode,
    String? code,
    required Object error,
  }) {
    AppLogger.apiError(
      'GET',
      '/api/v1/mobile/bootstrap',
      statusCode: statusCode,
      error: 'requestId=$requestId code=${code ?? '-'} $error',
    );
  }
}
