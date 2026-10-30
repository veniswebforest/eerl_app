import 'dart:ui';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/utils/ist_date_time.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/supervisor_tasks/model/supervisor_task_detail_status.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_assets.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_detail_widgets.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_header.dart';
import 'package:flutter/material.dart';

class SupervisorTaskDetailScreen extends StatefulWidget {
  const SupervisorTaskDetailScreen({
    super.key,
    this.status,
    this.task,
    this.taskLoader,
  });

  final SupervisorTaskDetailStatus? status;
  final TaskModel? task;
  final Future<TaskModel?> Function(String taskId)? taskLoader;

  @override
  State<SupervisorTaskDetailScreen> createState() =>
      _SupervisorTaskDetailScreenState();
}

class _SupervisorTaskDetailScreenState
    extends State<SupervisorTaskDetailScreen> {
  TaskModel? _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _reloadTask();
  }

  Future<void> _reloadTask() async {
    final taskId = widget.task?.id;
    if (taskId == null) return;
    final freshTask =
        await (widget.taskLoader?.call(taskId) ??
            EerlLocalRepository.instance.getTask(taskId));
    if (!mounted || freshTask == null) return;
    setState(() => _task = freshTask);
  }

  SupervisorTaskDetailStatus get _status {
    final normalized = _task?.status.toUpperCase();
    if (const {'PENDING', 'OPEN', 'IN_PROGRESS'}.contains(normalized)) {
      return SupervisorTaskDetailStatus.inProgress;
    }
    if (normalized == 'CANCELLED') return SupervisorTaskDetailStatus.cancelled;
    if (const {'COMPLETED', 'CLOSED', 'RESOLVED'}.contains(normalized)) {
      return SupervisorTaskDetailStatus.completed;
    }
    return widget.status ?? SupervisorTaskDetailStatus.completed;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStatus = _status;
    final task = _task;
    final isInProgress =
        effectiveStatus == SupervisorTaskDetailStatus.inProgress;
    final isCompleted = effectiveStatus == SupervisorTaskDetailStatus.completed;
    final completionImages = _completionImages(task, isCompleted);
    final attachmentImages = _attachmentImages(task);

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
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    children: [
                      SupervisorTaskStatusCard(
                        status: effectiveStatus,
                        label: _statusLabel(context, task, effectiveStatus),
                      ),
                      const SizedBox(height: 24),
                      if (isCompleted && completionImages.isNotEmpty) ...[
                        SupervisorTaskDetailCard(
                          title: context.l10n.supervisorTaskCompletionProof,
                          images: completionImages,
                          caption: _completionOwner(context, task),
                          emphasized: true,
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (isCompleted) ...[
                        SupervisorTaskDetailCard(
                          title: context.l10n.supervisorTaskDescriptionLabel,
                          value: task?.note?.trim().isNotEmpty == true
                              ? task!.note!.trim()
                              : context
                                    .l10n
                                    .supervisorTaskCompletionDescription,
                          caption: _completionOwner(context, task),
                          emphasized: true,
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (isCompleted) ...[
                        Text(
                          context.l10n.supervisorTaskSentDetails,
                          style: AppTextStyles.semiboldH9_14.copyWith(
                            color: AppColors.neutral950,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      SupervisorTaskDetailCard(
                        title: context.l10n.supervisorTaskAssignToLabel,
                        value:
                            _assigneeLabel(task) ??
                            context.l10n.supervisorTaskAgentRahul,
                      ),
                      const SizedBox(height: 16),
                      SupervisorTaskDetailCard(
                        title: context.l10n.supervisorTaskDescriptionLabel,
                        value: task?.description?.trim().isNotEmpty == true
                            ? task!.description!.trim()
                            : context.l10n.supervisorTaskDetailDescription,
                      ),
                      const SizedBox(height: 16),
                      SupervisorTaskDetailCard(
                        title: context.l10n.supervisorTaskPriority,
                        value: _priorityLabel(context, task?.priority),
                      ),
                      const SizedBox(height: 16),
                      SupervisorTaskDetailCard(
                        title: context.l10n.supervisorTaskFollowupDateTime,
                        value: task?.dueAt?.trim().isNotEmpty == true
                            ? IstDateTime.formatUtc(
                                task!.dueAt!,
                                'dd MMM yyyy, hh:mm a',
                              )
                            : context.l10n.supervisorTaskFilledDate,
                      ),
                      if (attachmentImages.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        SupervisorTaskDetailCard(
                          title: context.l10n.supervisorTaskAttachmentByYou,
                          images: attachmentImages,
                          caption: _attachmentOwner(context, task),
                        ),
                      ],
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

  String? _assigneeLabel(TaskModel? task) {
    if (task == null) return null;
    final agent = task.assignedToName?.trim().isNotEmpty == true
        ? task.assignedToName!.trim()
        : task.assignedTo;
    final center = task.centerName?.trim();
    return center?.isNotEmpty == true ? '$agent ($center)' : agent;
  }

  List<String> _completionImages(TaskModel? task, bool isCompleted) {
    if (!isCompleted) return const [];
    if (task?.photoUrls.isNotEmpty == true) return task!.photoUrls;
    return const [
      SupervisorTaskAssets.completionProofOne,
      SupervisorTaskAssets.completionProofTwo,
    ];
  }

  List<String> _attachmentImages(TaskModel? task) {
    if (task != null) return task.referencePhotoUrls;
    return const [
      SupervisorTaskAssets.referencePhoto,
      SupervisorTaskAssets.referencePhoto,
    ];
  }

  String _completionOwner(BuildContext context, TaskModel? task) =>
      task?.assignedToName?.trim().isNotEmpty == true
      ? task!.assignedToName!.trim()
      : task?.assignedTo.trim().isNotEmpty == true
      ? task!.assignedTo.trim()
      : context.l10n.supervisorTaskAgentName;

  String _attachmentOwner(BuildContext context, TaskModel? task) =>
      task?.assignedByName?.trim().isNotEmpty == true
      ? task!.assignedByName!.trim()
      : task?.assignedBy.trim().isNotEmpty == true
      ? task!.assignedBy.trim()
      : context.l10n.supervisorTaskAttachmentOwner;

  String _priorityLabel(BuildContext context, String? priority) =>
      switch (priority?.trim().toUpperCase()) {
        'HIGH' => context.l10n.taskPriorityHigh,
        'NORMAL' => context.l10n.taskPriorityNormal,
        _ => context.l10n.taskPriorityLow,
      };

  String _statusLabel(
    BuildContext context,
    TaskModel? task,
    SupervisorTaskDetailStatus status,
  ) {
    if (status == SupervisorTaskDetailStatus.inProgress) {
      return context.l10n.supervisorTaskInProgress;
    }
    if (status == SupervisorTaskDetailStatus.cancelled) {
      return context.l10n.supervisorTaskCancelled;
    }
    final completedAt = task?.completedAt;
    if (completedAt?.trim().isNotEmpty != true) {
      return context.l10n.supervisorTaskCompletedAt;
    }
    final parsed = DateTime.tryParse(completedAt!);
    if (parsed == null) {
      return context.l10n.supervisorTaskCompletedValue(completedAt);
    }
    final completed = IstDateTime.fromUtc(parsed);
    final today = IstDateTime.now();
    final isToday =
        completed.year == today.year &&
        completed.month == today.month &&
        completed.day == today.day;
    final value = isToday
        ? '${context.l10n.filterToday}, '
              '${IstDateTime.formatUtc(completedAt, 'hh:mm a')}'
        : IstDateTime.formatUtc(completedAt, 'dd MMM yyyy, hh:mm a');
    return context.l10n.supervisorTaskCompletedValue(value);
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
            onYes: () async {
              Navigator.of(dialogContext).pop();
              final taskId = _task?.id;
              if (taskId == null) {
                Navigator.of(context).pop(true);
                return;
              }
              try {
                await EerlLocalRepository.instance.cancelTask(taskId);
                await OutgoingSyncService.instance.drain();
                if (context.mounted) Navigator.of(context).pop(true);
              } catch (_) {
                if (!context.mounted) return;
                await showDialog<void>(
                  context: context,
                  builder: (errorContext) => AlertDialog(
                    title: Text(context.l10n.error),
                    content: Text(context.l10n.supervisorTaskCancelError),
                    actions: [
                      FilledButton(
                        onPressed: () => Navigator.of(errorContext).pop(),
                        child: Text(context.l10n.confirm),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      );
}
