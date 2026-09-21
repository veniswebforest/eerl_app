import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class RagpickerFormField extends StatelessWidget {
  const RagpickerFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.readOnly = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool readOnly;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.mediumSH8_14),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: AppTextStyles.regularB7_14.copyWith(color: AppColors.neutral950),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.regularB7_14.copyWith(
            color: AppColors.cool500,
          ),
          filled: true,
          fillColor: readOnly ? AppColors.cool100 : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.cool400),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primary500),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ],
  );
}
