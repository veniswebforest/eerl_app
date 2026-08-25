import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class MaterialSegmentedControl extends StatelessWidget {
  const MaterialSegmentedControl({
    super.key,
    required this.plasticLabel,
    required this.nonPlasticLabel,
    required this.showPlastic,
    required this.onChanged,
  });

  final String plasticLabel;
  final String nonPlasticLabel;
  final bool showPlastic;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x18000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: _Segment(
            label: plasticLabel,
            selected: showPlastic,
            onTap: () => onChanged(true),
          ),
        ),
        Expanded(
          child: _Segment(
            label: nonPlasticLabel,
            selected: !showPlastic,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    ),
  );
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.primary500 : Colors.transparent,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.semiboldH9_14.copyWith(
            color: selected ? Colors.white : AppColors.neutral900,
          ),
        ),
      ),
    ),
  );
}
