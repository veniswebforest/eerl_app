import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

/// Mobile number input with country code selector.
///
/// Features:
/// - Integrated country code picker (defaults to +91)
/// - Rounded input field matching EcoVision design
/// - Error/focus state animations
/// - 10-digit number formatting
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = hasError
        ? AppColors.error
        : focusNode.hasFocus
            ? AppColors.primaryLight
            : (isDark ? AppColors.borderDark : AppColors.borderLight);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: hasError || focusNode.hasFocus ? 1.5 : 1,
        ),
        color: isDark ? AppColors.surfaceContainerDark : Colors.white,
      ),
      child: Row(
        children: [
          // ── Country Code ────────────────────────────────────────
          GestureDetector(
            onTap: onCountryCodeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🇮🇳',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    countryCode,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ],
              ),
            ),
          ),

          // ── Number Input ────────────────────────────────────────
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              onChanged: onChanged,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
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
                  color: AppColors.textDisabledLight,
                ),
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
