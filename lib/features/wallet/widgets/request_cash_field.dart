import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class RequestCashField extends StatelessWidget {
  const RequestCashField({
    super.key,
    required this.label,
    required this.child,
    this.requiredField = false,
  });

  final String label;
  final Widget child;
  final bool requiredField;

  @override
  Widget build(BuildContext context) => Column(
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
        style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral950),
      ),
      const SizedBox(height: 8),
      child,
    ],
  );
}

class RequestCashInput extends StatelessWidget {
  const RequestCashInput({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.prefixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.counterText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final int maxLines;
  final int? maxLength;
  final String? counterText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final hasInsideCounter = counterText?.isNotEmpty ?? false;
    final input = TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      style: AppTextStyles.regularB7_14.copyWith(color: AppColors.neutral950),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon,
        prefixIconConstraints: prefixIcon == null
            ? null
            : const BoxConstraints(minWidth: 36, minHeight: 24),
        hintStyle: AppTextStyles.regularB7_14.copyWith(
          color: AppColors.cool500,
        ),
        // The custom counter is positioned inside the outlined field below.
        counterText: hasInsideCounter ? '' : null,
        filled: true,
        fillColor: AppColors.neutral50,
        contentPadding: hasInsideCounter
            ? const EdgeInsets.fromLTRB(16, 0, 16, 36)
            : const EdgeInsets.all(16),
        enabledBorder: _border,
        focusedBorder: _border.copyWith(
          borderSide: const BorderSide(color: AppColors.primary500),
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
          bottom: 6,
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
