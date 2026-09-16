import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/home/widgets/home_assets.dart';

class RequestCashReasonSelector extends StatelessWidget {
  const RequestCashReasonSelector({
    super.key,
    required this.placeholder,
    required this.options,
    required this.isOpen,
    required this.onToggle,
    required this.onSelected,
    this.selectedIndex,
  });

  final String placeholder;
  final List<String> options;
  final bool isOpen;
  final VoidCallback onToggle;
  final ValueChanged<int> onSelected;
  final int? selectedIndex;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      InkWell(
        key: const Key('cash-reason-selector'),
        onTap: onToggle,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cool400),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedIndex == null ? placeholder : options[selectedIndex!],
                  maxLines: 1,
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
      if (isOpen) ...[
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cool400),
          ),
          child: Column(
            children: List.generate(options.length, (index) {
              final selected = selectedIndex == index;
              return InkWell(
                key: ValueKey('cash-reason-option-$index'),
                onTap: () => onSelected(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.neutral50,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.neutral400),
                        ),
                        child: selected
                            ? const DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.primary500,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          options[index],
                          style: AppTextStyles.regularB7_14.copyWith(
                            color: AppColors.neutral950,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    ],
  );
}
