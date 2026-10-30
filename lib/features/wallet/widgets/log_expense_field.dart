import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class LogExpenseField extends StatelessWidget {
  const LogExpenseField({
    super.key,
    required this.label,
    required this.child,
    this.requiredField = false,
  });

  final String label;
  final Widget child;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            children: requiredField
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.red600),
                    ),
                  ]
                : const [],
          ),
          style: AppTextStyles.mediumSH8_14.copyWith(
            color: AppColors.neutral950,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class LogExpenseInput extends StatelessWidget {
  const LogExpenseInput({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.counterText,
    this.errorText,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final String? counterText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasInsideCounter = counterText?.isNotEmpty ?? false;
    final input = TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      style: AppTextStyles.regularB7_14.copyWith(color: AppColors.neutral950),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.regularB7_14.copyWith(
          color: AppColors.cool500,
        ),
        counterText: hasInsideCounter ? '' : null,
        errorText: errorText,
        errorStyle: AppTextStyles.regularB8_12.copyWith(
          color: AppColors.red600,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: hasInsideCounter
            ? const EdgeInsets.fromLTRB(16, 16, 16, 36)
            : const EdgeInsets.all(16),
        enabledBorder: _border,
        focusedBorder: _border.copyWith(
          borderSide: const BorderSide(color: AppColors.primary500),
        ),
        errorBorder: _border.copyWith(
          borderSide: const BorderSide(color: AppColors.red600),
        ),
        focusedErrorBorder: _border.copyWith(
          borderSide: const BorderSide(color: AppColors.red600),
        ),
        border: _border,
      ),
    );

    if (!hasInsideCounter) return input;

    return Stack(
      children: [
        input,
        Positioned(
          right: 16,
          bottom: 12,
          child: IgnorePointer(
            child: Text(
              counterText!,
              style: AppTextStyles.regularB8_12.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static final _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: AppColors.cool400),
  );
}
