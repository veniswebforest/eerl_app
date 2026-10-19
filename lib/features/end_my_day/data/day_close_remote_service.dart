import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/network/app_http_client.dart';
import 'package:eerl_app/features/end_my_day/model/day_close_response.dart';
import 'package:http/http.dart' as http;

class DayCloseApiException implements Exception {
  const DayCloseApiException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => message;
}

class DayCloseRemoteService {
  DayCloseRemoteService({http.Client? client})
    : _client = client ?? AppHttpClient.instance.client;

  static final DayCloseRemoteService instance = DayCloseRemoteService();
  static const _timeout = Duration(seconds: 30);

  final http.Client _client;

  Future<DayCloseResponse> fetch({
    required String centerId,
    required String accessToken,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.apiBaseUrl}/mobile/centers/$centerId/day-close',
    );
    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'accept': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(_timeout);
      final body = _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = _map(body['error']);
        throw DayCloseApiException(
          error['message']?.toString() ?? 'Unable to load day-close data.',
          statusCode: response.statusCode,
          code: error['code']?.toString(),
        );
      }
      return DayCloseResponse.fromJson(body);
    } on DayCloseApiException {
      rethrow;
    } on TimeoutException {
      throw const DayCloseApiException('The day-close request timed out.');
    } on SocketException {
      throw const DayCloseApiException('No internet connection.');
    } on FormatException catch (error) {
      throw DayCloseApiException(error.message);
    }
  }

  Future<void> close({
    required String centerId,
    required String accessToken,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.apiBaseUrl}/mobile/centers/$centerId/day-close',
    );
    final request = http.Request('POST', uri)
      ..headers.addAll({
        'accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });
    try {
      final streamed = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      final body = _decode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = _map(body['error']);
        throw DayCloseApiException(
          error['message']?.toString() ?? 'Unable to close the day.',
          statusCode: response.statusCode,
          code: error['code']?.toString(),
        );
      }
    } on DayCloseApiException {
      rethrow;
    } on TimeoutException {
      throw const DayCloseApiException('The day-close request timed out.');
    } on SocketException {
      throw const DayCloseApiException('No internet connection.');
    } on FormatException catch (error) {
      throw DayCloseApiException(error.message);
    }
  }

  Map<String, dynamic> _decode(String source) {
    if (source.trim().isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(source);
    if (decoded is! Map) throw const FormatException('Expected JSON object');
    return Map<String, dynamic>.from(decoded);
  }
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const <String, dynamic>{};
