import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'end_day_activity_card.dart';

class SupervisorEndDayActivityCard extends StatelessWidget {
  const SupervisorEndDayActivityCard({super.key, required this.items});

  final List<EndDayActivityItem> items;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('supervisor-end-day-summary-card'),
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      border: Border.all(color: AppColors.cool400),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 42),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      items[index].label,
                      style: AppTextStyles.semiboldH9_14.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        items[index].value,
                        textAlign: TextAlign.end,
                        style: AppTextStyles.semiboldH9_14.copyWith(
                          color: items[index].valueColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (index != items.length - 1)
            const Divider(height: 1, color: AppColors.cool400),
        ],
      ],
    ),
  );
}
