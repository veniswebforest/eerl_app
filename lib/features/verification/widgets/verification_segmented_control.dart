import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/verification_entry.dart';

class VerificationSegmentedControl extends StatelessWidget {
  const VerificationSegmentedControl({
    super.key,
    required this.value,
    required this.pendingLabel,
    required this.processedLabel,
    required this.onChanged,
  });

  final VerificationListStatus value;
  final String pendingLabel;
  final String processedLabel;
  final ValueChanged<VerificationListStatus> onChanged;

  @override
  Widget build(BuildContext context) => Container(
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
          label: pendingLabel,
          selected: value == VerificationListStatus.pending,
          onTap: () => onChanged(VerificationListStatus.pending),
        ),
        _Segment(
          label: processedLabel,
          selected: value == VerificationListStatus.processed,
          onTap: () => onChanged(VerificationListStatus.processed),
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
  Widget build(BuildContext context) => Expanded(
    child: Material(
      color: selected ? AppColors.primary500 : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: ValueKey('verification-segment-$label'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                (selected
                        ? AppTextStyles.semiboldH9_14
                        : AppTextStyles.mediumSH8_14)
                    .copyWith(
                      color: selected
                          ? AppColors.neutral50
                          : AppColors.neutral900,
                    ),
          ),
        ),
      ),
    ),
  );
}
