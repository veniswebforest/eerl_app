import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

/// Home screen — landing page of the application.
///
/// Displays a welcome message and feature cards that demonstrate
/// localization, theming, and navigation.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // ── Welcome Header ──────────────────────────────────────
          _WelcomeHeader(
            title: l10n.welcomeMessage,
            subtitle: l10n.welcomeSubtitle,
            isDark: isDark,
            theme: theme,
          ),

          const SizedBox(height: 28),

          // ── Features Section ────────────────────────────────────
          Text(
            l10n.exploreFeatures,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          _FeatureCard(
            icon: Icons.translate,
            title: l10n.localization,
            description: l10n.localizationDesc,
            gradient: isDark
                ? [const Color(0xFF1A5276), const Color(0xFF2E86C1)]
                : [const Color(0xFF5DADE2), const Color(0xFF3498DB)],
            onTap: () => context.push(
              '${AppRoutes.details}?feature=${l10n.localization}',
            ),
          ),

          _FeatureCard(
            icon: Icons.dark_mode,
            title: l10n.darkMode,
            description: l10n.darkModeDesc,
            gradient: isDark
                ? [const Color(0xFF4A235A), const Color(0xFF7D3C98)]
                : [const Color(0xFFAF7AC5), const Color(0xFF8E44AD)],
            onTap: () => context.push(
              '${AppRoutes.details}?feature=${l10n.darkMode}',
            ),
          ),

          _FeatureCard(
            icon: Icons.palette,
            title: l10n.theming,
            description: l10n.themingDesc,
            gradient: isDark
                ? [const Color(0xFF0E6655), const Color(0xFF1ABC9C)]
                : [const Color(0xFF48C9B0), const Color(0xFF1ABC9C)],
            onTap: () => context.push(
              '${AppRoutes.details}?feature=${l10n.theming}',
            ),
          ),

          _FeatureCard(
            icon: Icons.alt_route,
            title: l10n.navigation,
            description: l10n.navigationDesc,
            gradient: isDark
                ? [const Color(0xFF784212), const Color(0xFFCA6F1E)]
                : [const Color(0xFFF0B27A), const Color(0xFFE67E22)],
            onTap: () => context.push(
              '${AppRoutes.details}?feature=${l10n.navigation}',
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  WELCOME HEADER
// ═══════════════════════════════════════════════════════════════════

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.theme,
  });

  final String title;
  final String subtitle;
  final bool isDark;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.primaryDark.withValues(alpha: 0.25), AppColors.surfaceDark]
              : [AppColors.primaryLight.withValues(alpha: 0.08), AppColors.surfaceLight],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.rocket_launch,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  FEATURE CARD
// ═══════════════════════════════════════════════════════════════════

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
