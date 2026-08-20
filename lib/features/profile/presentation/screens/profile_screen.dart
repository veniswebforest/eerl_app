import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Profile screen — displays user profile information.
///
/// All text is localized and all colors come from the theme.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    final isDark = context.isDarkMode;
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // ── Avatar & Name ────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.profileName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.profileEmail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.profileBio,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Edit Profile Button ──────────────────────────────────
          OutlinedButton.icon(
            onPressed: () {
              // Placeholder for edit profile action
            },
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(l10n.editProfile),
          ),

          const SizedBox(height: 12),

          // ── Language Button ──────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () => _showLanguagePicker(context, localeProvider),
            icon: const Icon(Icons.language, size: 18),
            label: Text(
              '${l10n.selectLanguage} · ${_localeName(localeProvider.locale, l10n)}',
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 28),

          // ── Account Information ──────────────────────────────────
          Text(
            l10n.accountInfo,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          _InfoTile(
            icon: Icons.calendar_today_outlined,
            label: l10n.memberSince,
            value: l10n.memberSinceDate,
            theme: theme,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _InfoTile(
            icon: Icons.info_outline,
            label: l10n.appVersion,
            value: l10n.appVersionNumber,
            theme: theme,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _InfoTile(
            icon: Icons.verified_outlined,
            label: l10n.status,
            value: l10n.activeStatus,
            valueColor: isDark ? AppColors.successDark : AppColors.success,
            theme: theme,
            isDark: isDark,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _localeName(Locale? locale, dynamic l10n) {
    return switch (locale?.languageCode) {
      'gu' => l10n.gujarati,
      'hi' => l10n.hindi,
      _ => l10n.english,
    };
  }

  void _showLanguagePicker(BuildContext context, LocaleProvider provider) {
    final l10n = context.l10n;
    final theme = context.theme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
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
                  _LanguageOption(
                    label: l10n.english,
                    isSelected:
                        provider.locale == null ||
                        provider.locale?.languageCode == 'en',
                    onTap: () => _selectLocale(
                      sheetContext,
                      provider,
                      const Locale('en'),
                    ),
                  ),
                  _LanguageOption(
                    label: l10n.gujarati,
                    isSelected: provider.locale?.languageCode == 'gu',
                    onTap: () => _selectLocale(
                      sheetContext,
                      provider,
                      const Locale('gu'),
                    ),
                  ),
                  _LanguageOption(
                    label: l10n.hindi,
                    isSelected: provider.locale?.languageCode == 'hi',
                    onTap: () => _selectLocale(
                      sheetContext,
                      provider,
                      const Locale('hi'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _selectLocale(
    BuildContext sheetContext,
    LocaleProvider provider,
    Locale locale,
  ) {
    provider.setLocale(locale);
    Navigator.pop(sheetContext);
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        Icons.translate,
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
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

// ═══════════════════════════════════════════════════════════════════
//  INFO TILE
// ═══════════════════════════════════════════════════════════════════

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    required this.isDark,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final ThemeData theme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceContainerDark
            : AppColors.surfaceContainerLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
