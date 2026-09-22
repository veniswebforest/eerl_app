import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/features/auth/model/auth_api_exception.dart';
import 'package:eerl_app/features/auth/model/send_otp_request.dart';
import 'package:eerl_app/features/auth/model/send_otp_response.dart';
import 'package:eerl_app/features/auth/model/verify_otp_request.dart';
import 'package:eerl_app/features/auth/model/verify_otp_response.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthRemoteService {
  AuthRemoteService({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  static const _timeout = Duration(seconds: 30);

  final http.Client _client;
  final bool _ownsClient;

  Future<SendOtpResponse> sendOtp(SendOtpRequest request) async {
    const tag = '[SendOtpAPI]';
    final uri = Uri.parse(
      '${AppConstants.apiBaseUrl}${AppConstants.sendOtpPath}',
    );
    final body = await _postJson(
      tag: tag,
      uri: uri,
      requestBody: request.toJson(),
      safeRequestBody: request.toSafeLogJson(),
      fallbackError: 'Unable to send the login code. Please try again.',
    );
    final data = _responseData(body);
    final result = SendOtpResponse.fromJson(data);
    debugPrint('$tag Parsed Model: ${result.toSafeLogJson()}');
    return result;
  }

  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    const tag = '[VerifyOtpAPI]';
    final uri = Uri.parse(
      '${AppConstants.apiBaseUrl}${AppConstants.verifyOtpPath}',
    );
    final body = await _postJson(
      tag: tag,
      uri: uri,
      requestBody: request.toJson(),
      safeRequestBody: request.toSafeLogJson(),
      fallbackError: 'Unable to verify the login code. Please try again.',
    );
    final result = VerifyOtpResponse.fromJson(_responseData(body));
    if (!result.hasValidSession) {
      throw const AuthApiException(
        message: 'The server returned an invalid session. Please try again.',
      );
    }
    debugPrint('$tag Parsed Model: ${result.toSafeLogJson()}');
    return result;
  }

  Future<Map<String, dynamic>> _postJson({
    required String tag,
    required Uri uri,
    required Map<String, dynamic> requestBody,
    required Map<String, dynamic> safeRequestBody,
    required String fallbackError,
  }) async {
    const headers = <String, String>{
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };

    debugPrint('$tag API function start');
    debugPrint('$tag Request URL: $uri');
    debugPrint('$tag Request Method: POST');
    debugPrint('$tag Request Headers: $headers');
    debugPrint('$tag Request Body: $safeRequestBody');
    debugPrint('$tag Query Parameters: ${uri.queryParameters}');
    debugPrint('$tag Path Parameters: {}');

    try {
      final response = await _client
          .post(uri, headers: headers, body: jsonEncode(requestBody))
          .timeout(_timeout);

      debugPrint('$tag Response Status: ${response.statusCode}');
      final body = _decodeBody(response.body);
      debugPrint('$tag Response Body: ${_safeResponseLog(body)}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _errorFromResponse(body, response.statusCode, fallbackError);
      }
      return body;
    } on AuthApiException catch (error, stackTrace) {
      debugPrint(
        '$tag API Error: code=${error.code}, status=${error.statusCode}',
      );
      debugPrintStack(label: '$tag Stack Trace', stackTrace: stackTrace);
      rethrow;
    } on TimeoutException catch (error, stackTrace) {
      debugPrint('$tag Timeout Error: $error');
      debugPrintStack(label: '$tag Stack Trace', stackTrace: stackTrace);
      throw const AuthApiException(
        message:
            'The request timed out. Please check your connection and try again.',
      );
    } on SocketException catch (error, stackTrace) {
      debugPrint('$tag Network Error: $error');
      debugPrintStack(label: '$tag Stack Trace', stackTrace: stackTrace);
      throw const AuthApiException(
        message:
            'No internet connection. Please check your network and try again.',
      );
    } on FormatException catch (error, stackTrace) {
      debugPrint('$tag Parse Error: $error');
      debugPrintStack(label: '$tag Stack Trace', stackTrace: stackTrace);
      throw const AuthApiException(
        message: 'The server returned an invalid response. Please try again.',
      );
    } catch (error, stackTrace) {
      debugPrint('$tag Unexpected Error: $error');
      debugPrintStack(label: '$tag Stack Trace', stackTrace: stackTrace);
      throw AuthApiException(message: fallbackError);
    }
  }

  Map<String, dynamic> _responseData(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is! Map) {
      throw const AuthApiException(
        message: 'The server returned an invalid response. Please try again.',
      );
    }
    return Map<String, dynamic>.from(data);
  }

  Map<String, dynamic> _decodeBody(String responseBody) {
    if (responseBody.trim().isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map) throw const FormatException('Expected a JSON object');
    return Map<String, dynamic>.from(decoded);
  }

  AuthApiException _errorFromResponse(
    Map<String, dynamic> body,
    int statusCode,
    String fallbackError,
  ) {
    final rawError = body['error'];
    final error = rawError is Map
        ? Map<String, dynamic>.from(rawError)
        : <String, dynamic>{};
    final rawDetails = error['details'];
    Map<String, dynamic>? firstDetail;
    if (rawDetails is List &&
        rawDetails.isNotEmpty &&
        rawDetails.first is Map) {
      firstDetail = Map<String, dynamic>.from(rawDetails.first as Map);
    }

    return AuthApiException(
      message:
          firstDetail?['message'] as String? ??
          error['message'] as String? ??
          fallbackError,
      code: (firstDetail?['code'] ?? error['code']) as String?,
      field: firstDetail?['field'] as String?,
      statusCode: statusCode,
    );
  }

  Map<String, dynamic> _safeResponseLog(Map<String, dynamic> body) {
    return Map<String, dynamic>.from(_sanitizeForLog(body) as Map);
  }

  dynamic _sanitizeForLog(dynamic value, {String? key}) {
    final normalizedKey = key?.toLowerCase() ?? '';
    if (normalizedKey.contains('phone') ||
        normalizedKey.contains('name') ||
        normalizedKey.contains('message') ||
        normalizedKey.contains('token') ||
        normalizedKey.contains('otp')) {
      return value == null ? null : '[REDACTED]';
    }
    if (value is Map) {
      return value.map(
        (mapKey, mapValue) => MapEntry(
          mapKey.toString(),
          _sanitizeForLog(mapValue, key: mapKey.toString()),
        ),
      );
    }
    if (value is List) {
      return value.map((item) => _sanitizeForLog(item)).toList();
    }
    return value;
  }

  void close() {
    if (_ownsClient) _client.close();
  }
}
