import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class AppLabeledDropdown extends StatelessWidget {
  const AppLabeledDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.options,
    required this.selectedIndex,
    required this.expanded,
    required this.onToggle,
    required this.onSelected,
    this.requiredField = false,
    this.selectorKey,
    this.optionsKey,
    this.optionKeyPrefix = 'dropdown-option',
  });

  final String label;
  final String hint;
  final List<String> options;
  final int selectedIndex;
  final bool expanded;
  final bool requiredField;
  final VoidCallback onToggle;
  final ValueChanged<int> onSelected;
  final Key? selectorKey;
  final Key? optionsKey;
  final String optionKeyPrefix;

  @override
  Widget build(BuildContext context) {
    final value = selectedIndex >= 0 && !expanded
        ? options[selectedIndex]
        : hint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            children: requiredField
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.red500),
                    ),
                  ]
                : const [],
          ),
          style: AppTextStyles.mediumSH8_14.copyWith(
            color: AppColors.neutral950,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            key: selectorKey,
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.cool400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.regularB7_14.copyWith(
                        color: selectedIndex >= 0 && !expanded
                            ? AppColors.neutral950
                            : AppColors.neutral500,
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: 1.5707963267948966,
                    child: SvgPicture.asset(
                      'assets/icons/tasks/dropdown.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: 8),
          Container(
            key: optionsKey,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.cool400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (var index = 0; index < options.length; index++)
                  InkWell(
                    key: ValueKey('$optionKeyPrefix-$index'),
                    onTap: () => onSelected(index),
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 37,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: [
                            _DropdownRadio(
                              selected:
                                  index ==
                                  (selectedIndex < 0 ? 0 : selectedIndex),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                options[index],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.regularB7_14.copyWith(
                                  color: AppColors.neutral950,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _DropdownRadio extends StatelessWidget {
  const _DropdownRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    width: 19,
    height: 19,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.neutral500),
    ),
    child: selected
        ? const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary500,
            ),
          )
        : null,
  );
}
