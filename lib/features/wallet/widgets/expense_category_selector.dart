import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/home/widgets/home_assets.dart';

class ExpenseCategorySelector extends StatelessWidget {
  const ExpenseCategorySelector({
    super.key,
    required this.placeholder,
    required this.items,
    required this.isOpen,
    required this.onToggle,
    required this.onSelected,
    required this.requestNewCategoryLabel,
    required this.onRequestNewCategory,
    this.selectedIndex,
  });

  final String placeholder;
  final List<String> items;
  final bool isOpen;
  final VoidCallback onToggle;
  final ValueChanged<int> onSelected;
  final String requestNewCategoryLabel;
  final VoidCallback onRequestNewCategory;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final panelHeight = (MediaQuery.sizeOf(context).height * .34).clamp(
      220.0,
      280.0,
    );

    return Column(
      children: [
        InkWell(
          key: const Key('expense-category-selector'),
          onTap: onToggle,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(10),
            bottom: Radius.circular(isOpen ? 0 : 10),
          ),
          child: Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(10),
                bottom: Radius.circular(isOpen ? 0 : 10),
              ),
              border: Border.all(color: AppColors.cool400),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedIndex == null ? placeholder : items[selectedIndex!],
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.regularB7_14.copyWith(
                      color: selectedIndex == null
                          ? AppColors.cool500
                          : AppColors.neutral950,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isOpen ? .5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: SvgPicture.asset(
                    HomeAssets.chevronDown,
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isOpen)
          Container(
            height: panelHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(10),
              ),
              border: Border.all(color: AppColors.cool400),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: items.length > 5,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final selected = selectedIndex == index;
                        return InkWell(
                          key: ValueKey('expense-category-$index'),
                          onTap: () => onSelected(index),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary500
                                          : AppColors.neutral400,
                                    ),
                                  ),
                                  child: selected
                                      ? const DecoratedBox(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.primary500,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    items[index],
                                    style: AppTextStyles.regularB7_14.copyWith(
                                      color: AppColors.neutral950,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    key: const Key('request-new-expense-category'),
                    onPressed: onRequestNewCategory,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primary500,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(9),
                        ),
                      ),
                      textStyle: AppTextStyles.semiboldH9_14,
                    ),
                    icon: SvgPicture.asset(
                      'assets/icons/help_support/add.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: Text(requestNewCategoryLabel),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
