import 'dart:async';
import 'dart:convert';

import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// The single long-lived HTTP client shared by application API services.
class AppHttpClient {
  AppHttpClient._();

  static final AppHttpClient instance = AppHttpClient._();

  final http.Client client = ApiLoggingHttpClient(http.Client());
}

/// Debug-only wire logger used by every API service sharing [AppHttpClient].
/// It emits a copyable cURL before the call and the complete response after it.
class ApiLoggingHttpClient extends http.BaseClient {
  ApiLoggingHttpClient(this._inner);

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (!kDebugMode) return _inner.send(request);

    AppLogger.apiCurl(
      request.method,
      request.url,
      headers: request.headers,
      body: request is http.Request && request.body.isNotEmpty
          ? request.body
          : null,
    );
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _inner.send(request);
      final bytes = await response.stream.toBytes();
      AppLogger.apiResponse(
        request.method,
        request.url,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
        body: _responseBodyForLog(response.headers, bytes),
      );
      return http.StreamedResponse(
        Stream<List<int>>.value(bytes),
        response.statusCode,
        contentLength: bytes.length,
        request: request,
        headers: response.headers,
        isRedirect: response.isRedirect,
        persistentConnection: response.persistentConnection,
        reasonPhrase: response.reasonPhrase,
      );
    } catch (error) {
      AppLogger.apiError(
        request.method,
        request.url.toString(),
        duration: stopwatch.elapsed,
        error: error,
      );
      rethrow;
    }
  }

  String? _responseBodyForLog(Map<String, String> headers, List<int> bytes) {
    if (bytes.isEmpty) return null;
    final contentType = headers['content-type']?.toLowerCase() ?? '';
    final isText =
        contentType.isEmpty ||
        contentType.contains('json') ||
        contentType.startsWith('text/') ||
        contentType.contains('xml');
    return isText
        ? utf8.decode(bytes, allowMalformed: true)
        : '<${bytes.length} binary bytes>';
  }

  @override
  void close() => _inner.close();
}
