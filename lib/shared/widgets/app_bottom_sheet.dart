import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';

/// Reusable themed bottom sheet.
///
/// Call [AppBottomSheet.show] to display a consistent bottom sheet
/// that automatically adapts to the current theme and uses localized text.
class AppBottomSheet {
  AppBottomSheet._();

  /// Shows a themed bottom sheet with a [title], [message],
  /// and optional [actions].
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    List<Widget>? actions,
    Widget? content,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final theme = ctx.theme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                // Optional custom content
                if (content != null) ...[const SizedBox(height: 16), content],

                const SizedBox(height: 24),

                // Actions
                if (actions != null && actions.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children:
                        actions
                            .expand((w) => [w, const SizedBox(width: 12)])
                            .toList()
                          ..removeLast(),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(context.l10n.close),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
