import 'package:eerl_app/core/providers/app_lock_provider.dart';
import 'package:eerl_app/core/providers/locale_provider.dart';
import 'package:eerl_app/core/services/app_lock_service.dart';
import 'package:eerl_app/core/widgets/app_lock_guard.dart';
import 'package:eerl_app/features/auth/view/app_lock_screen.dart';
import 'package:eerl_app/features/profile/view/profile_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAppLockServiceSuccess implements AppLockService {
  @override
  Future<bool> isLockSupported() async => true;

  @override
  Future<bool> authenticate({String localizedReason = ''}) async => true;
}

class _MockAppLockServiceFailure implements AppLockService {
  @override
  Future<bool> isLockSupported() async => true;

  @override
  Future<bool> authenticate({String localizedReason = ''}) async => false;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AppLockGuard unlocks and displays child on successful auth', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppLockGuard(
          lockService: _MockAppLockServiceSuccess(),
          autoPrompt: true,
          child: const Text('Main App Content'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Main App Content'), findsOneWidget);
    expect(find.text('App is Locked'), findsNothing);
  });

  testWidgets(
    'AppLockGuard triggers onAuthFailed callback on failed auth and displays locked screen',
    (tester) async {
      var failedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AppLockGuard(
            lockService: _MockAppLockServiceFailure(),
            autoPrompt: true,
            onAuthFailed: () => failedCalled = true,
            child: const Text('Main App Content'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(failedCalled, isTrue);
      expect(find.text('App is Locked'), findsOneWidget);
      expect(find.byKey(const Key('app-lock-unlock-button')), findsOneWidget);
      expect(find.byKey(const Key('app-lock-exit-button')), findsOneWidget);
      expect(find.text('Main App Content'), findsNothing);
    },
  );

  testWidgets(
    'AppLockGuard bypasses lock when AppLockProvider isLockEnabled is false',
    (tester) async {
      final lockProvider = AppLockProvider(
        lockService: _MockAppLockServiceFailure(),
      );

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: lockProvider,
          child: const MaterialApp(
            home: AppLockGuard(
              autoPrompt: true,
              child: Text('Main App Content Directly Opened'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Main App Content Directly Opened'), findsOneWidget);
      expect(find.text('App is Locked'), findsNothing);
    },
  );

  testWidgets('ProfileScreen displays App Lock toggle and updates state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final appLockProvider = AppLockProvider(
      lockService: _MockAppLockServiceSuccess(),
    );
    final localeProvider = LocaleProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: appLockProvider),
          ChangeNotifierProvider.value(value: localeProvider),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final switchFinder = find.byKey(const Key('profile-app-lock-switch'));
    await tester.ensureVisible(switchFinder);
    expect(switchFinder, findsOneWidget);

    // Initial state: false
    expect(appLockProvider.isLockEnabled, isFalse);

    // Toggle ON
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(appLockProvider.isLockEnabled, isTrue);

    // Toggle OFF
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(appLockProvider.isLockEnabled, isFalse);
  });

  testWidgets('AppLockScreen displays lock UI and triggers onAuthSuccess', (
    tester,
  ) async {
    var successCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: AppLockScreen(
          lockService: _MockAppLockServiceSuccess(),
          autoPrompt: true,
          onAuthSuccess: () => successCalled = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('App is Locked'), findsOneWidget);
    expect(find.byKey(const Key('app-lock-unlock-button')), findsOneWidget);
    expect(find.byKey(const Key('app-lock-exit-button')), findsOneWidget);
    expect(successCalled, isTrue);
  });

  testWidgets('AppLockScreen triggers onAuthFailed when auth fails', (
    tester,
  ) async {
    var failedCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: AppLockScreen(
          lockService: _MockAppLockServiceFailure(),
          autoPrompt: true,
          onAuthFailed: () => failedCalled = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('App is Locked'), findsOneWidget);
    expect(failedCalled, isTrue);
  });
}
