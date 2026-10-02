import 'dart:async';
import 'dart:io';

import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/local_database/app_database.dart';
import 'core/providers/app_lock_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/network_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_session_storage.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/bootstrap/service/bootstrap_sync_service.dart';
import 'shared/widgets/network_status_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Open (or create) the local database before the app starts. Sqflite calls
  // onCreate only when eerl_local.db does not exist; subsequent launches reuse
  // the same database and do not recreate its tables.
  await AppDatabase.instance.database;

  // Debug-only startup check. Never prints the access token in release builds.
  if (kDebugMode) {
    final storedAccessToken = await AuthSessionStorage().getAccessToken();
    debugPrint(
      '🔐 [EERL_AUTH][APP_OPEN] accessToken='
      '${storedAccessToken == null || storedAccessToken.isEmpty ? '[NOT_FOUND]' : storedAccessToken}',
    );
  }

  // Initialise providers and load persisted preferences.
  final themeProvider = ThemeProvider();
  final localeProvider = LocaleProvider();
  final authProvider = AuthProvider();
  final networkProvider = NetworkProvider();
  final appLockProvider = AppLockProvider();
  final bootstrapSyncService = BootstrapSyncService.instance;

  var wasOffline = networkProvider.isOffline;
  networkProvider.addListener(() {
    final isOffline = networkProvider.isOffline;
    if (wasOffline && !isOffline) {
      unawaited(
        bootstrapSyncService.triggerBootstrap(
          trigger: BootstrapTrigger.reconnect,
        ),
      );
    }
    wasOffline = isOffline;
  });
  bootstrapSyncService.addListener(() {
    if (bootstrapSyncService.sessionExpired) {
      AppRouter.router.go(AppRoutes.login);
    }
  });

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Future.wait([
    themeProvider.loadTheme(),
    localeProvider.loadLocale(),
    appLockProvider.loadLockSetting(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: networkProvider),
        ChangeNotifierProvider.value(value: appLockProvider),
        ChangeNotifierProvider.value(value: bootstrapSyncService),
      ],
      child: const EerlApp(),
    ),
  );
}

/// Root widget of the EERL application.
class EerlApp extends StatefulWidget {
  const EerlApp({super.key});

  @override
  State<EerlApp> createState() => _EerlAppState();
}

class _EerlAppState extends State<EerlApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(
        BootstrapSyncService.instance.triggerBootstrap(
          trigger: BootstrapTrigger.appResume,
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp.router(
      builder: (context, child) {
        return NetworkStatusOverlay(child: SafeAreaWrapper(child: child!));
      },
      // ── App Info ─────────────────────────────────────────────────
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,

      // ── Theme ───────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      // ── Localization ────────────────────────────────────────────
      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // ── Router ──────────────────────────────────────────────────
      routerConfig: AppRouter.router,
    );
  }
}

class SafeAreaWrapper extends StatelessWidget {
  final Widget child;

  const SafeAreaWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: Platform.isAndroid ? true : false,
      top: false, // top safe area avoid kariye (AppBar handle kare che)
      child: child,
    );
  }
}
