import 'package:eerl_app/features/auth/data/auth_remote_service.dart';
import 'package:eerl_app/features/auth/data/auth_repository.dart';
import 'package:eerl_app/features/auth/model/auth_api_exception.dart';
import 'package:eerl_app/features/auth/model/send_otp_request.dart';
import 'package:eerl_app/features/auth/model/verify_otp_request.dart';
import 'package:eerl_app/features/auth/presentation/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthRemoteService.sendOtp', () {
    test('parses a successful response and sends the expected request', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          'https://eerl-backend.onrender.com/api/v1/mobile/auth/send-otp',
        );
        expect(request.headers['content-type'], 'application/json');
        expect(request.body, '{"phone":"9876543210"}');

        return http.Response(
          '''{"data":{"message":"Code sent","supervisorName":"Mitesh Dave","supervisorPhone":"+919812345678","expiresInSeconds":299}}''',
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final service = AuthRemoteService(client: client);

      final response = await service.sendOtp(
        const SendOtpRequest(phone: '9876543210'),
      );

      expect(response.message, 'Code sent');
      expect(response.supervisorName, 'Mitesh Dave');
      expect(response.supervisorPhone, '+919812345678');
      expect(response.expiresInSeconds, 299);
    });

    test('uses the field-level backend message for an error response', () async {
      final client = MockClient(
        (_) async => http.Response(
          '''{"error":{"code":"NO_OTP_RECIPIENT","message":"No supervisor","details":[{"field":"phone","code":"INVALID_STRING","message":"Enter a 10-digit Indian mobile number."}]}}''',
          400,
        ),
      );
      final service = AuthRemoteService(client: client);

      await expectLater(
        service.sendOtp(const SendOtpRequest(phone: '9876543210')),
        throwsA(
          isA<AuthApiException>()
              .having(
                (error) => error.message,
                'message',
                'Enter a 10-digit Indian mobile number.',
              )
              .having((error) => error.code, 'code', 'INVALID_STRING')
              .having((error) => error.field, 'field', 'phone')
              .having((error) => error.statusCode, 'statusCode', 400),
        ),
      );
    });
  });

  group('AuthProvider.sendOtp', () {
    test(
      'rejects an invalid Indian mobile number before the API call',
      () async {
        var apiCalled = false;
        final service = AuthRemoteService(
          client: MockClient((_) async {
            apiCalled = true;
            return http.Response('{}', 200);
          }),
        );
        final provider = AuthProvider(
          repository: AuthRepository(remoteService: service),
        );
        provider.setPhoneNumber('1234567890');

        expect(await provider.sendOtp(), isFalse);
        expect(provider.hasLoginError, isTrue);
        expect(apiCalled, isFalse);
        provider.dispose();
      },
    );

    test(
      'stores success data and starts the server-provided countdown',
      () async {
        final service = AuthRemoteService(
          client: MockClient(
            (_) async => http.Response(
              '''{"data":{"message":"Code sent","supervisorName":null,"supervisorPhone":null,"expiresInSeconds":299}}''',
              200,
            ),
          ),
        );
        final provider = AuthProvider(
          repository: AuthRepository(remoteService: service),
        );
        provider.setPhoneNumber('9876543210');

        expect(await provider.sendOtp(), isTrue);
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
        expect(provider.sendOtpResponse?.message, 'Code sent');
        expect(provider.resendSeconds, 299);
        provider.dispose();
      },
    );
  });

  group('OTP verification', () {
    test('sends phone and six-digit OTP and parses the session', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          'https://eerl-backend.onrender.com/api/v1/mobile/auth/verify-otp',
        );
        expect(request.body, '{"phone":"9876543210","otp":"865778"}');
        return http.Response(
          '''{"data":{"accessToken":"header.payload.signature","sessionExpiresAt":"2026-09-29T08:49:23.615Z"}}''',
          200,
        );
      });
      final service = AuthRemoteService(client: client);

      final response = await service.verifyOtp(
        const VerifyOtpRequest(phone: '9876543210', otp: '865778'),
      );

      expect(response.accessToken, 'header.payload.signature');
      expect(
        response.sessionExpiresAt,
        DateTime.parse('2026-09-29T08:49:23.615Z'),
      );
    });

    test('provider stores the session and enters verified state', () async {
      SharedPreferences.setMockInitialValues({});
      final service = AuthRemoteService(
        client: MockClient(
          (_) async => http.Response(
            '''{"data":{"accessToken":"header.payload.signature","sessionExpiresAt":"2026-09-29T08:49:23.615Z"}}''',
            200,
          ),
        ),
      );
      final provider = AuthProvider(
        repository: AuthRepository(remoteService: service),
      );
      provider.setPhoneNumber('9876543210');
      provider.setOtp('865778');

      expect(provider.isOtpComplete, isTrue);
      expect(await provider.verifyOtp(), isTrue);
      expect(provider.isVerified, isTrue);
      expect(provider.isLoading, isFalse);

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString('auth_access_token'),
        'header.payload.signature',
      );
      expect(
        preferences.getString('auth_session_expires_at'),
        '2026-09-29T08:49:23.615Z',
      );
      provider.dispose();
    });

    test('provider rejects incomplete OTP without making a request', () async {
      var apiCalled = false;
      final service = AuthRemoteService(
        client: MockClient((_) async {
          apiCalled = true;
          return http.Response('{}', 200);
        }),
      );
      final provider = AuthProvider(
        repository: AuthRepository(remoteService: service),
      );
      provider.setPhoneNumber('9876543210');
      provider.setOtp('12345');

      expect(await provider.verifyOtp(), isFalse);
      expect(provider.hasOtpError, isTrue);
      expect(apiCalled, isFalse);
      provider.dispose();
    });
  });
}
