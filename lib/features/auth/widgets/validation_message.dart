import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';

/// Inline validation message widget.
///
/// Displays an error or success message with an appropriate icon
/// below an input field.
class ValidationMessage extends StatelessWidget {
  const ValidationMessage({
    super.key,
    required this.message,
    this.type = ValidationType.error,
    this.showIcon = true,
  });

  final String message;
  final ValidationType type;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final color = type == ValidationType.error
        ? AppColors.error
        : AppColors.success;

    final icon = type == ValidationType.error
        ? Icons.error_outline
        : Icons.check_circle_outline;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum ValidationType { error, success }
