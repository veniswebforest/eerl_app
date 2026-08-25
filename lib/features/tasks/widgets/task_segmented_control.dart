import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/task_list_item.dart';

class TaskSegmentedControl extends StatelessWidget {
  const TaskSegmentedControl({
    super.key,
    required this.status,
    required this.openLabel,
    required this.closedLabel,
    required this.onChanged,
  });

  final TaskListStatus status;
  final String openLabel;
  final String closedLabel;
  final ValueChanged<TaskListStatus> onChanged;

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
            label: openLabel,
            selected: status == TaskListStatus.open,
            onTap: () => onChanged(TaskListStatus.open),
          ),
        ),
        Expanded(
          child: _Segment(
            label: closedLabel,
            selected: status == TaskListStatus.closed,
            onTap: () => onChanged(TaskListStatus.closed),
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
          style: AppTextStyles.mediumSH8_14.copyWith(
            color: selected ? Colors.white : AppColors.neutral900,
          ),
        ),
      ),
    ),
  );
}
