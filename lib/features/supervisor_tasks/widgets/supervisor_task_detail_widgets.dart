import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/supervisor_tasks/model/supervisor_task_detail_status.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SupervisorTaskStatusCard extends StatelessWidget {
  const SupervisorTaskStatusCard({super.key, required this.status});

  final SupervisorTaskDetailStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, foreground, background, asset) = switch (status) {
      SupervisorTaskDetailStatus.inProgress => (
        context.l10n.supervisorTaskInProgress,
        AppColors.yellow600,
        AppColors.yellow50,
        SupervisorTaskAssets.pending,
      ),
      SupervisorTaskDetailStatus.completed => (
        context.l10n.supervisorTaskCompletedAt,
        AppColors.primary500,
        AppColors.primary50,
        SupervisorTaskAssets.detailCompleted,
      ),
      SupervisorTaskDetailStatus.cancelled => (
        context.l10n.supervisorTaskCancelled,
        AppColors.red600,
        AppColors.red50,
        SupervisorTaskAssets.detailCancelled,
      ),
    };

    return Container(
      key: const Key('supervisor-task-detail-status'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
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
                  style: AppTextStyles.semiboldH10_12.copyWith(
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupervisorTaskDetailCard extends StatelessWidget {
  const SupervisorTaskDetailCard({
    super.key,
    required this.title,
    this.value,
    this.images = const <String>[],
    this.caption,
    this.emphasized = false,
  });

  final String title;
  final String? value;
  final List<String> images;
  final String? caption;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final foreground = emphasized ? AppColors.neutral950 : AppColors.neutral600;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: emphasized ? Colors.white : AppColors.cool200,
        borderRadius: BorderRadius.circular(12),
        boxShadow: emphasized
            ? const [
                BoxShadow(
                  color: Color(0x1F000000),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.semiboldH8_16.copyWith(color: foreground),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: AppColors.cool400),
          if (value != null) ...[
            const SizedBox(height: 12),
            Text(
              value!,
              style:
                  (emphasized
                          ? AppTextStyles.regularB7_14
                          : AppTextStyles.mediumSH8_14)
                      .copyWith(color: foreground),
            ),
          ],
          if (images.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: List.generate(images.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: index == images.length - 1 ? 0 : 8,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AspectRatio(
                        aspectRatio: 143.5 / 92,
                        child: Image.asset(images[index], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
          if (caption != null) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: foreground,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    caption!,
                    style: AppTextStyles.mediumSH8_14.copyWith(
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class SupervisorCancelTaskDialog extends StatelessWidget {
  const SupervisorCancelTaskDialog({
    super.key,
    required this.onNo,
    required this.onYes,
  });

  final VoidCallback onNo;
  final VoidCallback onYes;

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 20),
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 335),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.supervisorTaskCancelDialogTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.boldH5_24.copyWith(
                color: AppColors.neutral950,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 247),
              child: Text(
                context.l10n.supervisorTaskCancelDialogMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.mediumSH8_14.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      key: const Key('supervisor-task-cancel-no'),
                      onPressed: onNo,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.cool200,
                        foregroundColor: AppColors.neutral950,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        context.l10n.supervisorTaskNo,
                        style: AppTextStyles.semiboldH8_16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      key: const Key('supervisor-task-cancel-yes'),
                      onPressed: onYes,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.red500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        context.l10n.supervisorTaskYes,
                        style: AppTextStyles.boldH7_16,
                      ),
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
}
