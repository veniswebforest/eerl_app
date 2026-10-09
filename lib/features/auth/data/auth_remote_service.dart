import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:eerl_app/core/network/app_http_client.dart';
import 'package:eerl_app/features/auth/model/auth_api_exception.dart';
import 'package:eerl_app/features/auth/model/send_otp_request.dart';
import 'package:eerl_app/features/auth/model/send_otp_response.dart';
import 'package:eerl_app/features/auth/model/verify_otp_request.dart';
import 'package:eerl_app/features/auth/model/verify_otp_response.dart';
import 'package:http/http.dart' as http;

class AuthRemoteService {
  AuthRemoteService({http.Client? client})
    : _client = client ?? AppHttpClient.instance.client;

  static const _timeout = Duration(seconds: 30);

  final http.Client _client;

  Future<SendOtpResponse> sendOtp(SendOtpRequest request) async {
    final uri = Uri.parse(
      '${AppConstants.apiBaseUrl}${AppConstants.sendOtpPath}',
    );
    final body = await _postJson(
      uri: uri,
      requestBody: request.toJson(),
      fallbackError: 'Unable to send the login code. Please try again.',
    );
    final data = _responseData(body);
    final result = SendOtpResponse.fromJson(data);
    return result;
  }

  Future<VerifyOtpResponse> verifyOtp(VerifyOtpRequest request) async {
    final uri = Uri.parse(
      '${AppConstants.apiBaseUrl}${AppConstants.verifyOtpPath}',
    );
    final body = await _postJson(
      uri: uri,
      requestBody: request.toJson(),
      fallbackError: 'Unable to verify the login code. Please try again.',
    );
    final result = VerifyOtpResponse.fromJson(_responseData(body));
    if (!result.hasValidSession) {
      throw const AuthApiException(
        message: 'The server returned an invalid session. Please try again.',
      );
    }
    return result;
  }

  Future<Map<String, dynamic>> _postJson({
    required Uri uri,
    required Map<String, dynamic> requestBody,
    required String fallbackError,
  }) async {
    const headers = <String, String>{
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final stopwatch = Stopwatch()..start();
    AppLogger.apiRequest('POST', uri.path);

    try {
      final response = await _client
          .post(uri, headers: headers, body: jsonEncode(requestBody))
          .timeout(_timeout);

      final body = _decodeBody(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _errorFromResponse(body, response.statusCode, fallbackError);
      }
      AppLogger.apiSuccess(
        'POST',
        uri.path,
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
      );
      return body;
    } on AuthApiException catch (error) {
      AppLogger.apiError(
        'POST',
        uri.path,
        statusCode: error.statusCode,
        duration: stopwatch.elapsed,
        error: error.code,
      );
      rethrow;
    } on TimeoutException catch (error) {
      AppLogger.apiError(
        'POST',
        uri.path,
        duration: stopwatch.elapsed,
        error: error,
      );
      throw const AuthApiException(
        message:
            'The request timed out. Please check your connection and try again.',
      );
    } on SocketException catch (error) {
      AppLogger.apiError(
        'POST',
        uri.path,
        duration: stopwatch.elapsed,
        error: error.message,
      );
      throw const AuthApiException(
        message:
            'No internet connection. Please check your network and try again.',
      );
    } on FormatException catch (error) {
      AppLogger.apiError(
        'POST',
        uri.path,
        duration: stopwatch.elapsed,
        error: error,
      );
      throw const AuthApiException(
        message: 'The server returned an invalid response. Please try again.',
      );
    } catch (error) {
      AppLogger.apiError(
        'POST',
        uri.path,
        duration: stopwatch.elapsed,
        error: error,
      );
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

  void close() {}
}
