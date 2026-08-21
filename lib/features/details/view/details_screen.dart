import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/shared/widgets/app_bottom_sheet.dart';
import 'package:eerl_app/shared/widgets/app_dialog.dart';
import 'package:eerl_app/shared/widgets/app_snackbar.dart';

/// Details screen — demonstrates route navigation with arguments
/// and showcases bottom sheet, dialog, and snackbar components.
class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key, required this.featureName});

  /// The feature name passed via route query parameter.
  final String featureName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = context.theme;
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.featureDetail),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // ── Feature Info Card ────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceContainerDark
                  : AppColors.surfaceContainerLight,
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
                    Icons.info_outline,
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.featureName(featureName),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.featureDetailBody,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Quick Actions ───────────────────────────────────────
          Text(
            l10n.quickActions,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Bottom Sheet
          _ActionButton(
            icon: Icons.vertical_align_bottom,
            label: l10n.showBottomSheet,
            theme: theme,
            isDark: isDark,
            onTap: () {
              AppBottomSheet.show(
                context: context,
                title: l10n.sampleBottomSheetTitle,
                message: l10n.sampleBottomSheetMessage,
              );
            },
          ),
          const SizedBox(height: 8),

          // Dialog
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: l10n.showDialog,
            theme: theme,
            isDark: isDark,
            onTap: () async {
              final result = await AppDialog.show(
                context: context,
                title: l10n.sampleDialogTitle,
                message: l10n.sampleDialogMessage,
              );
              if (result == true && context.mounted) {
                AppSnackbar.success(context, message: '${l10n.confirm} ✓');
              }
            },
          ),
          const SizedBox(height: 8),

          // Snackbar
          _ActionButton(
            icon: Icons.notifications_active_outlined,
            label: l10n.showSnackbar,
            theme: theme,
            isDark: isDark,
            onTap: () {
              AppSnackbar.show(context, message: l10n.sampleSnackbarMessage);
            },
          ),

          const SizedBox(height: 32),

          // ── Go Back Button ──────────────────────────────────────
          OutlinedButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: Text(l10n.goBack),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ACTION BUTTON
// ═══════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.theme,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final ThemeData theme;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark
          ? AppColors.surfaceContainerDark
          : AppColors.surfaceContainerLight,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 22, color: theme.colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
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
