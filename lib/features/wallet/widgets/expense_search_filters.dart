import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'wallet_assets.dart';

class ExpenseSearchFilters extends StatelessWidget {
  const ExpenseSearchFilters({
    super.key,
    required this.searchHint,
    required this.filters,
    required this.selectedIndex,
    required this.onFilterSelected,
  });

  final String searchHint;
  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  searchHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.regularB7_14.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(WalletAssets.search, width: 24, height: 24),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final selected = selectedIndex == index;
              return ChoiceChip(
                selected: selected,
                showCheckmark: false,
                label: Text(filters[index]),
                onSelected: (_) => onFilterSelected(index),
                backgroundColor: AppColors.cool200,
                selectedColor: AppColors.primary500,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                labelStyle: AppTextStyles.mediumSH8_14.copyWith(
                  color: selected ? Colors.white : AppColors.neutral700,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
