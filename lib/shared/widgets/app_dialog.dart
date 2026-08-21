import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';

/// Reusable themed dialog.
///
/// Call [AppDialog.show] to display a consistent dialog that
/// automatically adapts to the current theme with localized text.
class AppDialog {
  AppDialog._();

  /// Shows a themed confirmation dialog with a [title] and [message].
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDangerousAction = false,
  }) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(cancelText ?? l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: isDangerousAction
                  ? ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    )
                  : null,
              child: Text(confirmText ?? l10n.confirm),
            ),
          ],
        );
      },
    );
  }
}
