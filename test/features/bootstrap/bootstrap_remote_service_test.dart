import 'dart:convert';

import 'package:eerl_app/features/bootstrap/data/bootstrap_remote_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('uses the mobile Bootstrap endpoint and omits an empty since', () async {
    late http.Request capturedRequest;
    final service = BootstrapRemoteService(
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response(jsonEncode(_body('FIRST')), 200);
      }),
    );

    await service.fetchBootstrap(accessToken: 'secret-token');

    expect(capturedRequest.method, 'GET');
    expect(capturedRequest.url.path, '/api/v1/mobile/bootstrap');
    expect(capturedRequest.url.queryParameters, isEmpty);
    expect(capturedRequest.headers['Authorization'], 'Bearer secret-token');
  });

  test('sends the opaque cursor unchanged in the since query', () async {
    const cursor = '48213.f20260926.p3.9f1b';
    late http.Request capturedRequest;
    final service = BootstrapRemoteService(
      client: MockClient((request) async {
        capturedRequest = request;
        return http.Response(jsonEncode(_body('NEXT')), 200);
      }),
    );

    await service.fetchBootstrap(accessToken: 'secret-token', since: cursor);

    expect(capturedRequest.url.queryParameters, {'since': cursor});
  });

  test('exposes INVALID_CURSOR without losing its status or code', () async {
    final service = BootstrapRemoteService(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'error': {
              'code': 'INVALID_CURSOR',
              'message': 'Cursor is no longer valid',
            },
          }),
          400,
        ),
      ),
    );

    await expectLater(
      service.fetchBootstrap(accessToken: 'secret-token', since: 'invalid'),
      throwsA(
        isA<BootstrapApiException>()
            .having((error) => error.statusCode, 'statusCode', 400)
            .having((error) => error.code, 'code', 'INVALID_CURSOR')
            .having(
              (error) => error.isInvalidCursor,
              'isInvalidCursor',
              isTrue,
            ),
      ),
    );
  });
}

Map<String, Object?> _body(String cursor) => {
  'data': {
    'cursor': cursor,
    'hasMore': false,
    'full': false,
    'serverTime': '2026-10-01T12:00:00.000Z',
    'tables': <String, Object?>{},
  },
};
