import 'dart:ui';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/supervisor_tasks/model/supervisor_task_detail_status.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_assets.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_detail_widgets.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_header.dart';
import 'package:flutter/material.dart';

class SupervisorTaskDetailScreen extends StatelessWidget {
  const SupervisorTaskDetailScreen({super.key, required this.status});

  final SupervisorTaskDetailStatus status;

  @override
  Widget build(BuildContext context) {
    final isInProgress = status == SupervisorTaskDetailStatus.inProgress;

    return Scaffold(
      key: const Key('supervisor-task-detail-screen'),
      backgroundColor: AppColors.backgroundColor,
      appBar: SupervisorTaskHeader(
        title: context.l10n.supervisorTaskDetailsTitle,
        backAsset: SupervisorTaskAssets.detailBack,
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    children: [
                      SupervisorTaskStatusCard(status: status),
                      const SizedBox(height: 24),
                      if (status == SupervisorTaskDetailStatus.completed) ...[
                        SupervisorTaskDetailCard(
                          title: context.l10n.supervisorTaskCompletionProof,
                          images: const [
                            SupervisorTaskAssets.completionProofOne,
                            SupervisorTaskAssets.completionProofTwo,
                          ],
                          caption: context.l10n.supervisorTaskAgentName,
                          emphasized: true,
                        ),
                        const SizedBox(height: 16),
                        SupervisorTaskDetailCard(
                          title: context.l10n.supervisorTaskDescriptionLabel,
                          value:
                              context.l10n.supervisorTaskCompletionDescription,
                          caption: context.l10n.supervisorTaskAgentName,
                          emphasized: true,
                        ),
                        const SizedBox(height: 24),
                      ],
                      Text(
                        context.l10n.supervisorTaskSentDetails,
                        style: AppTextStyles.semiboldH9_14.copyWith(
                          color: AppColors.neutral950,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SupervisorTaskDetailCard(
                        title: context.l10n.supervisorTaskAssignToLabel,
                        value: context.l10n.supervisorTaskAgentRahul,
                      ),
                      const SizedBox(height: 16),
                      SupervisorTaskDetailCard(
                        title: context.l10n.supervisorTaskDescriptionLabel,
                        value: context.l10n.supervisorTaskDetailDescription,
                      ),
                      const SizedBox(height: 16),
                      SupervisorTaskDetailCard(
                        title: context.l10n.supervisorTaskPriority,
                        value: context.l10n.supervisorTaskPriorityLow,
                      ),
                      const SizedBox(height: 16),
                      SupervisorTaskDetailCard(
                        title: context.l10n.supervisorTaskFollowupDateTime,
                        value: context.l10n.supervisorTaskFilledDate,
                      ),
                      const SizedBox(height: 16),
                      SupervisorTaskDetailCard(
                        title: context.l10n.supervisorTaskAttachmentByYou,
                        images: const [
                          SupervisorTaskAssets.referencePhoto,
                          SupervisorTaskAssets.referencePhoto,
                        ],
                        caption: context.l10n.supervisorTaskAttachmentOwner,
                      ),
                    ],
                  ),
                ),
                if (isInProgress)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        key: const Key('supervisor-task-cancel-button'),
                        onPressed: () => _showCancelDialog(context),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.red600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          context.l10n.supervisorTaskCancelButton,
                          style: AppTextStyles.boldH7_16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCancelDialog(BuildContext context) =>
      showGeneralDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierLabel: context.l10n.supervisorTaskCancelDialogTitle,
        barrierColor: Colors.black.withValues(alpha: 0.6),
        pageBuilder: (dialogContext, _, _) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: SupervisorCancelTaskDialog(
            onNo: () => Navigator.of(dialogContext).pop(),
            onYes: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop(true);
            },
          ),
        ),
      );
}
