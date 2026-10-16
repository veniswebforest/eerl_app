import 'dart:convert';

import 'package:eerl_app/core/network/app_http_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'logs cURL and response while preserving response for the caller',
    () async {
      final messages = <String>[];
      final original = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        if (message != null) messages.add(message);
      };
      addTearDown(() => debugPrint = original);

      final client = ApiLoggingHttpClient(
        MockClient((request) async {
          expect(jsonDecode(request.body), {'collectionId': 'collection-1'});
          return http.Response(
            '{"data":{"id":"collection-1","status":"SYNCED"}}',
            200,
            headers: const {'content-type': 'application/json'},
          );
        }),
      );
      addTearDown(client.close);

      final response = await client.post(
        Uri.parse('https://api.example.test/mobile/collections/collection-1'),
        headers: const {
          'authorization': 'Bearer real-token',
          'content-type': 'application/json',
        },
        body: '{"collectionId":"collection-1"}',
      );

      expect(response.statusCode, 200);
      expect(jsonDecode(response.body), {
        'data': {'id': 'collection-1', 'status': 'SYNCED'},
      });
      expect(
        messages.where((message) => message.contains('[API][CURL]')),
        hasLength(1),
      );
      expect(
        messages.where((message) => message.contains('[API][RESPONSE]')),
        hasLength(1),
      );
      expect(messages.join('\n'), contains('"collectionId": "collection-1"'));
      expect(messages.join('\n'), contains('"status": "SYNCED"'));
      expect(messages.join('\n'), isNot(contains('real-token')));
    },
  );
}
