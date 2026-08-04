import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_text_styles.dart';

/// Mobile number input with separate country code and phone number containers.
class MobileNumberInput extends StatelessWidget {
  const MobileNumberInput({
    super.key,
    required this.controller,
    required this.focusNode,
    this.hasError = false,
    this.countryCode = '+91',
    this.hintText = 'Enter Your Mobile Number',
    this.onChanged,
    this.onCountryCodeTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final String countryCode;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onCountryCodeTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final borderColor = hasError
        ? palette.error
        : focusNode.hasFocus
        ? palette.cool900
        : palette.cool400;

    final textColor = hasError ? palette.error : palette.textPrimary;

    final containerBg = palette.surface;

    return Row(
      children: [
        // ── Country Code Container ──────────────────────────────────
        GestureDetector(
          onTap: onCountryCodeTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 72,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              countryCode,
              style: AppTextStyles.mediumSH8_14.copyWith(
                color: context.palette.neutral900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // ── Number Input Container ──────────────────────────────────
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              onChanged: onChanged,
              style: AppTextStyles.regularB7_14.copyWith(
                color: context.palette.neutral900,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: palette.textDisabled,
                ),
                counterText: '',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.cool400),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.cool400),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.cool900),
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
