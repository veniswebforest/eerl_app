import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/ragpicker_directory_item.dart';

class RagpickerSegmentedControl extends StatelessWidget {
  const RagpickerSegmentedControl({
    super.key,
    required this.status,
    required this.activeLabel,
    required this.deactivatedLabel,
    required this.onChanged,
  });

  final RagpickerStatus status;
  final String activeLabel;
  final String deactivatedLabel;
  final ValueChanged<RagpickerStatus> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.white,
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
        Expanded(
          child: _Segment(
            key: const Key('ragpicker-active-tab'),
            label: activeLabel,
            selected: status == RagpickerStatus.active,
            onTap: () => onChanged(RagpickerStatus.active),
          ),
        ),
        Expanded(
          child: _Segment(
            key: const Key('ragpicker-deactivated-tab'),
            label: deactivatedLabel,
            selected: status == RagpickerStatus.deactivated,
            onTap: () => onChanged(RagpickerStatus.deactivated),
          ),
        ),
      ],
    ),
  );
}

class _Segment extends StatelessWidget {
  const _Segment({
    super.key,
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
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              (selected ? AppTextStyles.boldH8_14 : AppTextStyles.mediumSH8_14)
                  .copyWith(
                    color: selected ? Colors.white : AppColors.neutral900,
                  ),
        ),
      ),
    ),
  );
}
