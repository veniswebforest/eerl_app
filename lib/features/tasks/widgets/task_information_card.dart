import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/home/widgets/home_styles.dart';

class TaskInformationCard extends StatelessWidget {
  const TaskInformationCard({
    super.key,
    required this.title,
    required this.child,
    this.backgroundColor = Colors.white,
    this.showShadow = true,
  });

  final String title;
  final Widget child;
  final Color backgroundColor;
  final bool showShadow;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: showShadow ? [HomeStyles.cardShadow] : null,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.semiboldH8_16.copyWith(
            color: AppColors.neutral950,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, thickness: 1, color: AppColors.cool400),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}
