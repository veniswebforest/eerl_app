import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

/// Figma-matched claim type and date filters used by the wallet screen.
class ExpenseSearchFilters extends StatelessWidget {
  const ExpenseSearchFilters({
    super.key,
    required this.typeLabels,
    required this.selectedTypeIndex,
    required this.onTypeSelected,
    required this.filters,
    required this.selectedIndex,
    required this.onFilterSelected,
  });

  final List<String> typeLabels;
  final int selectedTypeIndex;
  final ValueChanged<int> onTypeSelected;
  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: List.generate(typeLabels.length, (index) {
              final selected = selectedTypeIndex == index;
              return Expanded(
                child: InkWell(
                  key: ValueKey('expense-type-$index'),
                  onTap: () => onTypeSelected(index),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary500
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      typeLabels[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.mediumSH8_14.copyWith(
                        color: selected
                            ? AppColors.neutral50
                            : AppColors.neutral900,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final selected = selectedIndex == index;
              return ChoiceChip(
                key: ValueKey('expense-date-filter-$index'),
                selected: selected,
                showCheckmark: false,
                label: Text(filters[index]),
                onSelected: (_) => onFilterSelected(index),
                backgroundColor: AppColors.cool200,
                selectedColor: AppColors.primary500,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                labelStyle: AppTextStyles.mediumSH8_14.copyWith(
                  color: selected ? AppColors.neutral50 : AppColors.neutral700,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
