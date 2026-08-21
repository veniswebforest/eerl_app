import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class RecordsSegmentedControl extends StatelessWidget {
  const RecordsSegmentedControl({
    super.key,
    required this.isDrafts,
    required this.historyLabel,
    required this.draftsLabel,
    required this.onChanged,
  });

  final bool isDrafts;
  final String historyLabel;
  final String draftsLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _Segment(
            label: historyLabel,
            selected: !isDrafts,
            onTap: () => onChanged(false),
          ),
          _Segment(
            label: draftsLabel,
            selected: isDrafts,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
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
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary500 : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 5,
                      offset: Offset(2, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style:
                (selected
                        ? AppTextStyles.boldH8_14
                        : AppTextStyles.mediumSH8_14)
                    .copyWith(
                      color: selected
                          ? AppColors.primary50
                          : AppColors.neutral900,
                    ),
          ),
        ),
      ),
    );
  }
}
