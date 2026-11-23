import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/network/app_http_client.dart';
import 'package:eerl_app/features/bootstrap/model/bootstrap_response.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_log.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class BootstrapApiException implements Exception {
  const BootstrapApiException({
    required this.message,
    this.code,
    this.statusCode,
  });

  final String message;
  final String? code;
  final int? statusCode;

  bool get isInvalidCursor => statusCode == 400 && code == 'INVALID_CURSOR';

  @override
  String toString() =>
      'BootstrapApiException(code: $code, statusCode: $statusCode)';
}

class BootstrapRemoteService {
  BootstrapRemoteService({
    http.Client? client,
    Future<String> Function()? appBuildProvider,
  }) : _client = client ?? AppHttpClient.instance.client,
       _appBuildProvider = appBuildProvider ?? _loadAppBuild;

  static const _timeout = Duration(seconds: 30);

  final http.Client _client;
  final Future<String> Function() _appBuildProvider;

  static Future<String> _loadAppBuild() async {
    final info = await PackageInfo.fromPlatform();
    final value = '${info.version}+${info.buildNumber}'.trim();
    return value.length <= 40 ? value : value.substring(0, 40);
  }

  Future<BootstrapResponse> fetchBootstrap({
    required String accessToken,
    String? since,
  }) async {
    final requestId = BootstrapLog.nextRequestId();
    final stopwatch = Stopwatch()..start();
    final query = <String, String>{};
    final appBuild = await _appBuildProvider();
    if (appBuild.trim().isNotEmpty) query['appBuild'] = appBuild.trim();
    if (since != null && since.isNotEmpty) {
      query['since'] = since;
    }
    final baseUri = Uri.parse(
      '${AppConstants.apiBaseUrl}${AppConstants.bootstrapPath}',
    );
    final uri = query.isEmpty
        ? baseUri
        : baseUri.replace(queryParameters: query);

    BootstrapLog.httpRequest(
      requestId: requestId,
      uri: uri,
      hasCursor: since != null && since.isNotEmpty,
    );

    try {
      final response = await _client
          .get(
            uri,
            headers: <String, String>{
              'accept': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(_timeout);
      final body = _decodeBody(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _errorFromResponse(body, response.statusCode);
      }
      BootstrapLog.httpResponse(
        requestId: requestId,
        statusCode: response.statusCode,
        elapsedMilliseconds: stopwatch.elapsedMilliseconds,
      );
      return BootstrapResponse.fromJson(body);
    } on BootstrapApiException catch (error) {
      BootstrapLog.httpError(
        requestId: requestId,
        statusCode: error.statusCode,
        code: error.code,
        error: error,
      );
      rethrow;
    } on TimeoutException catch (error) {
      BootstrapLog.httpError(requestId: requestId, error: error);
      throw const BootstrapApiException(
        message: 'Bootstrap request timed out.',
      );
    } on SocketException catch (error) {
      BootstrapLog.httpError(requestId: requestId, error: error);
      throw const BootstrapApiException(message: 'No internet connection.');
    } on FormatException catch (error) {
      BootstrapLog.httpError(requestId: requestId, error: error);
      throw BootstrapApiException(message: error.message);
    } catch (error) {
      BootstrapLog.httpError(requestId: requestId, error: error);
      throw const BootstrapApiException(
        message: 'Unable to synchronize offline data.',
      );
    }
  }

  Map<String, dynamic> _decodeBody(String responseBody) {
    if (responseBody.trim().isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map) throw const FormatException('Expected JSON object');
    return Map<String, dynamic>.from(decoded);
  }

  BootstrapApiException _errorFromResponse(
    Map<String, dynamic> body,
    int statusCode,
  ) {
    final rawError = body['error'];
    final error = rawError is Map
        ? Map<String, dynamic>.from(rawError)
        : <String, dynamic>{};
    final rawDetails = error['details'];
    Map<String, dynamic>? detail;
    if (rawDetails is List &&
        rawDetails.isNotEmpty &&
        rawDetails.first is Map) {
      detail = Map<String, dynamic>.from(rawDetails.first as Map);
    }
    return BootstrapApiException(
      message:
          detail?['message'] as String? ??
          error['message'] as String? ??
          'Unable to synchronize offline data.',
      code: (detail?['code'] ?? error['code']) as String?,
      statusCode: statusCode,
    );
  }
}
