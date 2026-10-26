import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';

/// Renders a trailing required-field asterisk in red while preserving the
/// supplied label style for all other text.
class AppRequiredText extends StatelessWidget {
  const AppRequiredText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final trimmed = text.trimRight();
    final isRequired = trimmed.endsWith('*');
    if (!isRequired) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    final label = trimmed.substring(0, trimmed.length - 1).trimRight();
    return Text.rich(
      TextSpan(
        text: label,
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: AppColors.red600),
          ),
        ],
      ),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
}
