import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Settings screen — allows users to switch theme and language.
///
/// Demonstrates the provider-based state management for theme
/// and locale, with all text fully localized.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    final isDark = context.isDarkMode;

    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // ══════════════════════════════════════════════════════════
          //  APPEARANCE SECTION
          // ══════════════════════════════════════════════════════════
          _SectionHeader(title: l10n.appearance, theme: theme),
          const SizedBox(height: 8),

          // ── Theme Picker ────────────────────────────────────────
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: l10n.theme,
            subtitle: _themeModeLabel(themeProvider.themeMode, l10n),
            onTap: () => _showThemePicker(context, themeProvider),
          ),
          const SizedBox(height: 8),

          // ── Language Picker ─────────────────────────────────────
          _SettingsTile(
            icon: Icons.language,
            title: l10n.language,
            subtitle: _localeName(localeProvider.locale, l10n),
            onTap: () => _showLanguagePicker(context, localeProvider),
          ),

          const SizedBox(height: 24),

          // ══════════════════════════════════════════════════════════
          //  GENERAL SECTION
          // ══════════════════════════════════════════════════════════
          _SectionHeader(title: l10n.general, theme: theme),
          const SizedBox(height: 8),

          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: l10n.notifications,
            subtitle: l10n.notificationsDesc,
            trailing: Switch(
              value: true,
              onChanged: (_) {
                // Placeholder
              },
            ),
          ),

          const SizedBox(height: 24),

          // ══════════════════════════════════════════════════════════
          //  ABOUT SECTION
          // ══════════════════════════════════════════════════════════
          _SectionHeader(title: l10n.about, theme: theme),
          const SizedBox(height: 8),

          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyPolicy,
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: l10n.termsOfService,
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.code,
            title: l10n.licenses,
            onTap: () => showLicensePage(
              context: context,
              applicationName: l10n.appTitle,
              applicationVersion: l10n.appVersionNumber,
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  String _themeModeLabel(ThemeMode mode, dynamic l10n) {
    switch (mode) {
      case ThemeMode.system:
        return l10n.systemTheme;
      case ThemeMode.light:
        return l10n.lightTheme;
      case ThemeMode.dark:
        return l10n.darkThemeOption;
    }
  }

  String _localeName(Locale? locale, dynamic l10n) {
    if (locale == null) return l10n.english;
    switch (locale.languageCode) {
      case 'hi':
        return l10n.hindi;
      case 'en':
      default:
        return l10n.english;
    }
  }

  void _showThemePicker(BuildContext context, ThemeProvider provider) {
    final l10n = context.l10n;
    final theme = context.theme;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.selectTheme,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _ThemeOption(
                  icon: Icons.brightness_auto,
                  label: l10n.systemTheme,
                  isSelected: provider.themeMode == ThemeMode.system,
                  onTap: () {
                    provider.setThemeMode(ThemeMode.system);
                    Navigator.pop(ctx);
                  },
                ),
                _ThemeOption(
                  icon: Icons.light_mode,
                  label: l10n.lightTheme,
                  isSelected: provider.themeMode == ThemeMode.light,
                  onTap: () {
                    provider.setThemeMode(ThemeMode.light);
                    Navigator.pop(ctx);
                  },
                ),
                _ThemeOption(
                  icon: Icons.dark_mode,
                  label: l10n.darkThemeOption,
                  isSelected: provider.themeMode == ThemeMode.dark,
                  onTap: () {
                    provider.setThemeMode(ThemeMode.dark);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context, LocaleProvider provider) {
    final l10n = context.l10n;
    final theme = context.theme;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.selectLanguage,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _ThemeOption(
                  icon: Icons.language,
                  label: l10n.english,
                  isSelected:
                      provider.locale == null ||
                      provider.locale?.languageCode == 'en',
                  onTap: () {
                    provider.setLocale(const Locale('en'));
                    Navigator.pop(ctx);
                  },
                ),
                _ThemeOption(
                  icon: Icons.translate,
                  label: l10n.hindi,
                  isSelected: provider.locale?.languageCode == 'hi',
                  onTap: () {
                    provider.setLocale(const Locale('hi'));
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SECTION HEADER
// ═══════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.theme});

  final String title;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.primary,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  SETTINGS TILE
// ═══════════════════════════════════════════════════════════════════

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Material(
      color: context.palette.surfaceContainer,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: theme.colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.bodyLarge),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  THEME / LANGUAGE OPTION
// ═══════════════════════════════════════════════════════════════════

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
