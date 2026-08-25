import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class ConfigurableMaterialTile extends StatelessWidget {
  const ConfigurableMaterialTile({
    super.key,
    required this.index,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final int index;
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    height: 64,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(
        color: selected ? AppColors.primary500 : AppColors.cool200,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        ReorderableDragStartListener(
          index: index,
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.cool200,
              borderRadius: BorderRadius.circular(6),
            ),
            child: SvgPicture.asset(
              'assets/icons/home/menu.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.cool600,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.regularB7_14.copyWith(
              color: AppColors.neutral900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 24,
          height: 24,
          child: Material(
            type: MaterialType.transparency,
            child: Checkbox(
              value: selected,
              onChanged: (value) => onSelected(value ?? false),
              activeColor: AppColors.primary500,
              checkColor: Colors.white,
              side: const BorderSide(color: AppColors.cool400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
