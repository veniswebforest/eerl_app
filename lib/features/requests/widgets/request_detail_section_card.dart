import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class RequestDetailSectionCard extends StatelessWidget {
  const RequestDetailSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final String title;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: AppColors.cool200,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.mediumSH8_14.copyWith(
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
