import 'dart:convert';

import 'package:eerl_app/features/end_my_day/data/day_close_remote_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('passes selected center id in the exact day-close path', () async {
    final service = DayCloseRemoteService(
      client: MockClient((request) async {
        expect(request.method, 'GET');
        expect(
          request.url.toString(),
          'https://api.eco-vision.in/api/v1/mobile/centers/'
          'selected-center/day-close',
        );
        expect(request.headers['accept'], 'application/json');
        expect(request.headers['authorization'], 'Bearer session-token');
        return http.Response(
          jsonEncode({
            'data': {
              'centerId': 'selected-center',
              'date': '2026-10-19',
              'lockTime': '18:30:00',
              'canClose': false,
              'blockedReason': 'BEFORE_LOCK_TIME',
              'openDrafts': 1,
              'summary': {
                'wallet': {
                  'opening': 395437,
                  'topUps': 0,
                  'collectionPayments': 120,
                  'expenses': 50,
                  'closing': 395267,
                },
                'collections': {
                  'total': 2,
                  'pendingReview': 1,
                  'rejected': 0,
                  'byUnit': [
                    {'unit': 'KG', 'quantity': 24.5},
                  ],
                },
                'expenses': {'count': 1, 'amount': 50},
              },
              'closedAt': null,
              'closedBy': null,
              'shareText': null,
            },
          }),
          200,
          headers: const {'content-type': 'application/json'},
        );
      }),
    );

    final response = await service.fetch(
      centerId: 'selected-center',
      accessToken: 'session-token',
    );

    expect(response.data.centerId, 'selected-center');
    expect(response.data.summary.wallet.opening, 395437);
    expect(response.data.summary.collections.byUnit.single.quantity, 24.5);
    expect(response.data.summary.expenses.amount, 50);
  });

  test('closes selected center with POST and an empty body', () async {
    final service = DayCloseRemoteService(
      client: MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          'https://api.eco-vision.in/api/v1/mobile/centers/'
          'selected-center/day-close',
        );
        expect(request.headers['accept'], 'application/json');
        expect(request.headers['authorization'], 'Bearer session-token');
        expect(request.bodyBytes, isEmpty);
        return http.Response('', 204);
      }),
    );

    await service.close(
      centerId: 'selected-center',
      accessToken: 'session-token',
    );
  });
}
