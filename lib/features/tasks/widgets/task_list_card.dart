import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../../home/widgets/home_styles.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';

class TaskListCard extends StatelessWidget {
  const TaskListCard({super.key, required this.item, this.onTap});

  final TaskModel item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.cool100),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [HomeStyles.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/profile_rahul_patel.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.assignedByName ?? item.assignedBy,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.semiboldH9_14.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  'assets/icons/wallet/open_details.svg',
                  width: 20,
                  height: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // color: AppColors.cool100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.description ?? item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.regularB7_14.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.attach_file_rounded,
                  size: 18,
                  color: AppColors.neutral600,
                ),
                const SizedBox(width: 4),
                Text(
                  context.l10n.taskPhotoAttached(item.photoUrls.length),
                  style: AppTextStyles.regularB8_12.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _isClosed
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: _StatusChip(
                            icon: Icons.check_circle_outline_rounded,
                            label: _scheduleLabel(context),
                            foreground: AppColors.primary500,
                            background: AppColors.primary50,
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _StatusChip(
                              icon: Icons.calendar_today_outlined,
                              label: _scheduleLabel(context),
                              foreground: const Color(0xFF6644DD),
                              background: const Color(0xFFF1EDFF),
                            ),
                            _priorityChip(context),
                          ],
                        ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    _timeLabel(context),
                    key: Key('task-time-${item.id}'),
                    style: AppTextStyles.regularB8_12.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  bool get _isClosed =>
      const {'COMPLETED', 'CLOSED'}.contains(item.status.toUpperCase());

  Widget _priorityChip(BuildContext context) =>
      switch (item.priority.toUpperCase()) {
        'HIGH' => _StatusChip(
          icon: Icons.schedule_rounded,
          label: context.l10n.taskPriorityHigh,
          foreground: AppColors.red600,
          background: AppColors.red50,
        ),
        'NORMAL' || 'MEDIUM' => _StatusChip(
          icon: Icons.schedule_rounded,
          label: context.l10n.taskPriorityNormal,
          foreground: AppColors.yellow600,
          background: const Color(0xFFFFFBEB),
        ),
        _ => _StatusChip(
          icon: Icons.schedule_rounded,
          label: context.l10n.taskPriorityLow,
          foreground: AppColors.secondary500,
          background: AppColors.secondary50,
        ),
      };

  String _scheduleLabel(BuildContext context) {
    if (_isClosed) return context.l10n.taskCompletedTime;
    final due = DateTime.tryParse(item.dueAt ?? '')?.toLocal();
    if (due == null) return item.status;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(due.year, due.month, due.day);
    if (dueDay == today) return context.l10n.taskDueToday;
    if (dueDay == today.add(const Duration(days: 1))) {
      return context.l10n.taskDueTomorrow;
    }
    return DateFormat('dd MMM yyyy').format(due);
  }

  String _timeLabel(BuildContext context) {
    final raw = _isClosed ? item.completedAt : item.dueAt;
    final value = DateTime.tryParse(raw ?? '')?.toLocal();
    return value == null ? '' : DateFormat('hh:mm a').format(value);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.foreground,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: foreground),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.mediumSH9_12.copyWith(color: foreground),
          ),
        ),
      ],
    ),
  );
}
