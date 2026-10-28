import 'dart:async';

import 'package:eerl_app/features/auth/data/auth_repository.dart';
import 'package:eerl_app/features/auth/model/send_otp_response.dart';
import 'package:eerl_app/features/auth/model/verify_otp_response.dart';
import 'package:eerl_app/features/auth/presentation/auth_provider.dart';
import 'package:eerl_app/features/auth/view/otp_screen.dart';
import 'package:eerl_app/features/dashboard/model/bottom_nav_item_model.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'navigates after OTP verification without awaiting initial sync',
    (tester) async {
      final syncCompleter = Completer<void>();
      final events = <String>[];
      final authProvider = AuthProvider(repository: _SuccessfulAuthRepository())
        ..setPhoneNumber('9876543210')
        ..setOtp('123456');
      addTearDown(authProvider.dispose);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: OtpScreen(
              phoneNumber: '9876543210',
              loadInitialRole: () async => DashboardUserRole.collectionAgent,
              onAuthenticated: (_) => events.add('home'),
              startInitialSync: () {
                events.add('sync');
                return syncCompleter.future;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Verify'));
      await tester.pump();
      await tester.pump();

      expect(events, ['home', 'sync']);
      expect(syncCompleter.isCompleted, isFalse);

      syncCompleter.complete();
      await tester.pump();
    },
  );

  testWidgets('verify dismisses the OTP keyboard before awaiting the API', (
    tester,
  ) async {
    _usePhoneSurface(tester);
    final repository = _PendingVerifyRepository();
    final authProvider = AuthProvider(repository: repository)
      ..setPhoneNumber('9876543210')
      ..setOtp('123456');
    addTearDown(authProvider.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: authProvider,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OtpScreen(
            phoneNumber: '9876543210',
            loadInitialRole: () async => DashboardUserRole.collectionAgent,
            onAuthenticated: (_) {},
          ),
        ),
      ),
    );

    await tester.showKeyboard(find.byKey(const Key('otp-digit-5')));
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.tap(find.text('Verify'));
    await tester.pump();

    final fields = tester.widgetList<TextField>(find.byType(TextField));
    expect(fields.every((field) => field.focusNode?.hasFocus == false), isTrue);
    expect(tester.testTextInput.isVisible, isFalse);

    repository.verifyCompleter.complete(_validVerifyResponse());
    await tester.pump();
  });

  testWidgets('resend calls API, clears old OTP and restarts countdown', (
    tester,
  ) async {
    _usePhoneSurface(tester);
    final repository = _ResendAuthRepository();
    final authProvider = AuthProvider(repository: repository)
      ..setPhoneNumber('9876543210')
      ..setOtp('123456')
      ..startResendTimer(seconds: 0);
    addTearDown(authProvider.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: authProvider,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const OtpScreen(phoneNumber: '9876543210'),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 700));
    await tester.tap(find.byKey(const Key('otp-resend-button')));
    await tester.pump();
    await tester.pump();

    expect(repository.sendCalls, 1);
    expect(authProvider.otp, isEmpty);
    expect(authProvider.resendSeconds, 45);
    for (var index = 0; index < 6; index++) {
      final field = tester.widget<TextField>(
        find.byKey(Key('otp-digit-$index')),
      );
      expect(field.controller?.text, isEmpty);
    }
    expect(find.text('A new login code has been sent.'), findsOneWidget);
    authProvider.cancelTimer();
  });
}

class _SuccessfulAuthRepository extends AuthRepository {
  @override
  Future<VerifyOtpResponse> verifyOtp({
    required String phone,
    required String otp,
  }) async => VerifyOtpResponse(
    accessToken: 'valid-test-token',
    sessionExpiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
  );
}

class _PendingVerifyRepository extends AuthRepository {
  final verifyCompleter = Completer<VerifyOtpResponse>();

  @override
  Future<VerifyOtpResponse> verifyOtp({
    required String phone,
    required String otp,
  }) => verifyCompleter.future;
}

class _ResendAuthRepository extends AuthRepository {
  int sendCalls = 0;

  @override
  Future<SendOtpResponse> sendOtp(String phone) async {
    sendCalls++;
    return const SendOtpResponse(
      message: 'Sent',
      supervisorName: null,
      supervisorPhone: null,
      expiresInSeconds: 45,
    );
  }
}

VerifyOtpResponse _validVerifyResponse() => VerifyOtpResponse(
  accessToken: 'valid-test-token',
  sessionExpiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
);

void _usePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
