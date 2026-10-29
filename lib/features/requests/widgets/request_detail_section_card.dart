import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class RequestDetailSectionCard extends StatelessWidget {
  const RequestDetailSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.titleStyle,
    this.borderRadius = 10,
  });

  final String title;
  final Widget child;
  final EdgeInsets padding;
  final TextStyle? titleStyle;
  final double borderRadius;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: AppColors.cool200,
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: (titleStyle ?? AppTextStyles.mediumSH8_14).copyWith(
            color: AppColors.neutral950,
          ),
        ),
        const SizedBox(height: 10),
        const Divider(height: 1, color: AppColors.cool400),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}
