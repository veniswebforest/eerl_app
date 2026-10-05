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
    this.color,
  });

  final int index;
  final String label;
  final String? color;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _parseMaterialColor(color);
    final foregroundColor = backgroundColor.computeLuminance() < 0.35
        ? Colors.white
        : AppColors.neutral900;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            backgroundColor.withValues(alpha: 0.35),
          ],
        ),
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
                color: AppColors.cool300,
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
                // color: foregroundColor,
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
                side: BorderSide(color: foregroundColor),
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

  Color _parseMaterialColor(String? value) {
    if (value == null) return Colors.white;
    var hex = value.trim();
    if (hex.isEmpty) return Colors.white;
    if (hex.startsWith('#')) hex = hex.substring(1);
    if (hex.toLowerCase().startsWith('0x')) hex = hex.substring(2);
    if (hex.length == 3) {
      hex = hex.split('').map((digit) => '$digit$digit').join();
    }
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return Colors.white;
    final parsed = int.tryParse(hex, radix: 16);
    return parsed == null ? Colors.white : Color(parsed);
  }
}
