import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class VerificationFilterChips extends StatelessWidget {
  const VerificationFilterChips({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: List.generate(labels.length, (index) {
        final selected = index == selectedIndex;
        return Padding(
          padding: EdgeInsets.only(right: index == labels.length - 1 ? 0 : 8),
          child: Material(
            color: selected ? AppColors.primary500 : AppColors.cool200,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => onSelected(index),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  labels[index],
                  style: AppTextStyles.mediumSH8_14.copyWith(
                    color: selected
                        ? AppColors.neutral50
                        : AppColors.neutral700,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    ),
  );
}
