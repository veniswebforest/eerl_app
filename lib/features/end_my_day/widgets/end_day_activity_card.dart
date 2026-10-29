import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class EndDayActivityItem {
  const EndDayActivityItem({
    required this.label,
    required this.value,
    this.valueColor = AppColors.neutral950,
  });

  final String label;
  final String value;
  final Color valueColor;
}

class EndDayActivityCard extends StatelessWidget {
  const EndDayActivityCard({super.key, required this.items});

  final List<EndDayActivityItem> items;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.cool400),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          ConstrainedBox(

            constraints: const BoxConstraints(minHeight: 46),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      items[index].label,
                      style: AppTextStyles.regularB7_14.copyWith(
                        color: AppColors.neutral700,
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
                        style: AppTextStyles.mediumSH8_14.copyWith(
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
            const Divider(height: 1, color: AppColors.cool300),
        ],
      ],
    ),
  );
}
