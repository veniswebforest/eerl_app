import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eerl_app/features/auth/view/login_screen.dart';
import 'package:eerl_app/features/auth/view/otp_screen.dart';
import 'package:eerl_app/features/auth/view/splash_screen.dart';
import 'package:eerl_app/features/dashboard/view/main_dashboard_screen.dart';
import 'package:eerl_app/features/details/view/details_screen.dart';
import 'package:eerl_app/features/settings/view/settings_screen.dart';
import 'app_routes.dart';

/// Application router configuration built with [GoRouter].
///
/// Uses a single [GoRoute] for the home shell which houses [MainDashboardScreen].
/// [MainDashboardScreen] self-manages its own bottom-navigation tabs with
/// [IndexedStack] and overlays (wallet, end-my-day, help-support, etc.)
/// via internal state — no separate GoRouter branches needed for sub-tabs.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      // ── Main dashboard shell (owns bottom nav + overlays) ─────────
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MainDashboardScreen(),
      ),

      // ── Auth routes ──────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        name: 'otp',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpScreen(phoneNumber: phone);
        },
      ),

      // ── Miscellaneous standalone routes ──────────────────────────
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.details,
        name: 'details',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final featureName = state.uri.queryParameters['feature'] ?? '';
          return DetailsScreen(featureName: featureName);
        },
      ),
    ],

    // ── Error page ────────────────────────────────────────────────
    errorBuilder: (context, state) => const _ErrorPage(),
  );
}

// ═══════════════════════════════════════════════════════════════════
//  ERROR / 404 PAGE
// ═══════════════════════════════════════════════════════════════════

class _ErrorPage extends StatelessWidget {
  const _ErrorPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                '404',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.pageNotFound, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                l10n.pageNotFoundMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.home),
                label: Text(l10n.returnHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
