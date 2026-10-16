import 'dart:async';

import 'package:eerl_app/features/auth/data/auth_repository.dart';
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
