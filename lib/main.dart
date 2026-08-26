import 'dart:io';

import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'features/auth/presentation/auth_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise providers and load persisted preferences.
  final themeProvider = ThemeProvider();
  final localeProvider = LocaleProvider();
  final authProvider = AuthProvider();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Future.wait([themeProvider.loadTheme(), localeProvider.loadLocale()]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: const EerlApp(),
    ),
  );
}

/// Root widget of the EERL application.
class EerlApp extends StatelessWidget {
  const EerlApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp.router(
      builder: (context, child) {
        return SafeAreaWrapper(child: child!);
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
