import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/request_list_item.dart';

class RequestSegmentedControl extends StatelessWidget {
  const RequestSegmentedControl({
    super.key,
    required this.status,
    required this.openLabel,
    required this.closedLabel,
    required this.onChanged,
  });

  final RequestListStatus status;
  final String openLabel;
  final String closedLabel;
  final ValueChanged<RequestListStatus> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 48,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Color(0x16000000),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: _RequestSegment(
            key: const Key('requests-open-tab'),
            label: openLabel,
            selected: status == RequestListStatus.open,
            onTap: () => onChanged(RequestListStatus.open),
          ),
        ),
        Expanded(
          child: _RequestSegment(
            key: const Key('requests-closed-tab'),
            label: closedLabel,
            selected: status == RequestListStatus.closed,
            onTap: () => onChanged(RequestListStatus.closed),
          ),
        ),
      ],
    ),
  );
}

class _RequestSegment extends StatelessWidget {
  const _RequestSegment({
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
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.mediumSH9_12.copyWith(
            color: selected ? Colors.white : AppColors.neutral900,
          ),
        ),
      ),
    ),
  );
}
