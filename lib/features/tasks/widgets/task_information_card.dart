import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class TaskInformationCard extends StatelessWidget {
  const TaskInformationCard({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.cool200,
      border: Border.all(color: AppColors.cool100),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.semiboldH9_14.copyWith(
            color: AppColors.neutral950,
          ),
        ),
        SizedBox(height: 8,),
        Divider(color: AppColors.cool400,),
        child,
      ],
    ),
  );
}
