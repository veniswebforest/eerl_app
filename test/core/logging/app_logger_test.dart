import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('colors the complete line and resets ANSI color', () {
    final messages = <String>[];
    final original = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      if (message != null) messages.add(message);
    };
    addTearDown(() => debugPrint = original);

    AppLogger.ansiColorsEnabled = true;
    AppLogger.apiRequest('POST', '/api/entries', message: 'id=123');

    expect(messages, hasLength(1));
    expect(messages.single, startsWith('\x1B[33m['));
    expect(messages.single, contains('[API][REQUEST] POST /api/entries'));
    expect(messages.single, endsWith('\x1B[0m'));
  });

  test('uses the configured ANSI color for every category', () {
    final messages = <String>[];
    final original = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      if (message != null) messages.add(message);
    };
    addTearDown(() => debugPrint = original);

    AppLogger.sqlite('INSERT', 'saved');
    AppLogger.apiRequest('GET', '/entries');
    AppLogger.apiSuccess(
      'GET',
      '/entries',
      statusCode: 200,
      duration: const Duration(milliseconds: 1),
    );
    AppLogger.apiError('GET', '/entries', statusCode: 500);
    AppLogger.sync('START', 'started');
    AppLogger.diagnostic('STATE', 'ready');

    expect(messages.map((message) => message.substring(0, 5)), [
      '\x1B[36m',
      '\x1B[33m',
      '\x1B[32m',
      '\x1B[31m',
      '\x1B[35m',
      '\x1B[90m',
    ]);
    expect(messages.every((message) => message.endsWith('\x1B[0m')), isTrue);
  });

  test('redacts authorization and token values', () {
    final messages = <String>[];
    final original = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      if (message != null) messages.add(message);
    };
    addTearDown(() => debugPrint = original);

    AppLogger.diagnostic(
      'AUTH',
      'Authorization=Bearer secret-token accessToken=another-secret',
    );

    expect(messages.single, isNot(contains('secret-token')));
    expect(messages.single, isNot(contains('another-secret')));
    expect(messages.single, contains('[REDACTED]'));
  });

  test('prints a copyable cURL with a safe access-token placeholder', () {
    final messages = <String>[];
    final wrapWidths = <int?>[];
    final original = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      if (message != null) messages.add(message);
      wrapWidths.add(wrapWidth);
    };
    addTearDown(() => debugPrint = original);

    AppLogger.apiCurl(
      'PUT',
      Uri.parse('https://api.example.test/mobile/collections/collection-1'),
      headers: const {
        'accept': 'application/json',
        'Authorization': 'Bearer real-secret-token',
        'content-type': 'application/json',
      },
      body:
          '{"centerId":"center-1","vehicleId":null,"lines":[{"itemId":"item-1","collectedQty":10}]}',
    );

    expect(messages, hasLength(1));
    expect(messages.single, contains('[API][CURL]\ncurl --location --request'));
    expect(messages.single, contains("'PUT'"));
    expect(
      messages.single,
      contains("'https://api.example.test/mobile/collections/collection-1'"),
    );
    expect(
      messages.single,
      contains("'Authorization: Bearer YOUR_ACCESS_TOKEN'"),
    );
    expect(messages.single, isNot(contains('real-secret-token')));
    expect(
      messages.single,
      allOf(
        contains('"centerId": "center-1"'),
        contains('"vehicleId": null'),
        contains('"itemId": "item-1"'),
        contains('"collectedQty": 10'),
      ),
    );
    expect(wrapWidths.single, 4000);
  });

  test('prints and redacts a formatted API response body', () {
    final messages = <String>[];
    final original = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      if (message != null) messages.add(message);
    };
    addTearDown(() => debugPrint = original);

    AppLogger.apiResponse(
      'POST',
      Uri.parse('https://api.example.test/mobile/auth/verify-otp'),
      statusCode: 200,
      duration: const Duration(milliseconds: 12),
      body: '{"data":{"accessToken":"secret","name":"Agent"}}',
    );

    expect(messages.single, contains('[API][RESPONSE] POST'));
    expect(messages.single, contains('status=200'));
    expect(messages.single, contains('"name": "Agent"'));
    expect(messages.single, contains('"accessToken": "[REDACTED]"'));
    expect(messages.single, isNot(contains('secret')));
  });
}
