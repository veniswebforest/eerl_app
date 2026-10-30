import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/utils/ist_date_time.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../home/widgets/home_styles.dart';
import 'supervisor_task_assets.dart';

class SupervisorTaskCard extends StatelessWidget {
  const SupervisorTaskCard({
    super.key,
    required this.item,
    this.onTap,
    this.showClosedTimestamp = false,
  });

  final TaskModel item;
  final VoidCallback? onTap;
  final bool showClosedTimestamp;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [HomeStyles.cardShadow],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: ValueKey('supervisor-task-${item.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      SupervisorTaskAssets.agentPhoto,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.assignedToName ?? item.assignedTo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.boldH8_14.copyWith(
                        color: AppColors.neutral950,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    SupervisorTaskAssets.openDetails,
                    width: 10,
                    height: 10,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cool100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTextStyles.semiboldH9_14.copyWith(
                        color: AppColors.neutral950,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.description ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.mediumSH8_14.copyWith(
                        color: AppColors.neutral700,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.photoUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    SvgPicture.asset(
                      SupervisorTaskAssets.attachment,
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        context.l10n.taskPhotoAttached(item.photoUrls.length),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.cool700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _TaskStatusChip(status: item.status),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 2,
                    child: Text(
                      _time(context),
                      key: ValueKey('supervisor-task-time-${item.id}'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: AppTextStyles.semiboldH10_12.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  String _time(BuildContext context) {
    final value = showClosedTimestamp
        ? item.completedAt ?? item.createdAt
        : item.dueAt ?? item.createdAt;
    return IstDateTime.formatUtc(value, 'dd MMM, hh:mm a');
  }
}

class _TaskStatusChip extends StatelessWidget {
  const _TaskStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final (label, foreground, background, asset) = switch (normalized) {
      'PENDING' => (
        context.l10n.supervisorTaskPending,
        AppColors.yellow600,
        AppColors.yellow50,
        SupervisorTaskAssets.pending,
      ),
      'COMPLETED' || 'CLOSED' => (
        context.l10n.supervisorTaskResolved,
        AppColors.primary500,
        AppColors.primary50,
        SupervisorTaskAssets.resolved,
      ),
      _ => (
        context.l10n.supervisorTaskCancelled,
        AppColors.red600,
        AppColors.red50,
        SupervisorTaskAssets.cancelled,
      ),
    };

    return Container(
      height: 32,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(asset, width: 20, height: 20),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.semiboldH10_12.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
