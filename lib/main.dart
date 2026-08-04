import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/providers/auth_provider.dart';
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

  await Future.wait([
    themeProvider.loadTheme(),
    localeProvider.loadLocale(),
  ]);

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
      // ── App Info ─────────────────────────────────────────────────
      title: 'EERL App',
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
