import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/app_required_text.dart';
import 'package:eerl_app/core/utils/image_compressor.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import 'package:eerl_app/shared/widgets/app_snackbar.dart';
import 'package:eerl_app/shared/widgets/in_app_camera_screen.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/tasks/model/task_list_item.dart';
import '../widgets/task_information_card.dart';
import '../widgets/task_photo_grid.dart';

typedef TaskDetailLoader = Future<TaskModel?> Function(String taskId);

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.task,
    this.initiallyFilled = false,
    this.taskLoader,
  });

  final TaskModel task;
  final bool initiallyFilled;
  final TaskDetailLoader? taskLoader;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late final TextEditingController _descriptionController;
  late List<String> _proofImages;
  late TaskModel _task;
  bool _isCompleting = false;

  bool get _canComplete =>
      _proofImages.isNotEmpty && _descriptionController.text.trim().isNotEmpty;

  String get _cameraRecoveryId => 'task.resolve.${_task.id}';

  String? get _assignmentDescription {
    final description = _task.description?.trim();
    if (description?.isNotEmpty == true) return description;
    if (_isClosed) return null;
    final note = _task.note?.trim();
    return note?.isNotEmpty == true ? note : null;
  }

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _proofImages = _isClosed ? [..._task.photoUrls] : [];
    _descriptionController = TextEditingController(
      text: _isClosed ? _task.note ?? '' : '',
    );
    unawaited(_loadLatestTask());
    _restoreCameraResult();
  }

  Future<void> _loadLatestTask() async {
    try {
      final loader = widget.taskLoader;
      final task = loader != null
          ? await loader(_task.id)
          : await EerlLocalRepository.instance.getTask(_task.id);
      if (task == null || !mounted) return;
      final wasClosed = _isClosed;
      setState(() {
        _task = task;
        if (!wasClosed && _isClosed) {
          _proofImages = [...task.photoUrls];
          _descriptionController.text = task.note ?? '';
        }
      });
    } catch (error) {
      AppLogger.error('TASK_DETAIL_LOAD', error.toString());
    }
  }

  Future<void> _restoreCameraResult() async {
    final image = await ImageCompressor.claimRecoveredImage(_cameraRecoveryId);
    if (image == null || !mounted || _isClosed) return;
    setState(() => _proofImages.add(image.path));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Presentation formatting is initialized from the SQLite-backed model.
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _captureProof() async {
    final image = await InAppCameraScreen.capture(
      context,
      recoveryId: _cameraRecoveryId,
      title: 'Capture Task Proof',
    );
    if (image != null && mounted) {
      setState(() => _proofImages.add(image.path));
    }
  }

  bool get _isClosed => isClosedTaskStatus(_task.status);

  Future<void> _completeTask() async {
    if (!_canComplete || _isCompleting) return;
    setState(() => _isCompleting = true);
    try {
      await EerlLocalRepository.instance.completeTask(
        taskId: _task.id,
        note: _descriptionController.text,
        photoPaths: _proofImages,
      );
      unawaited(BootstrapSyncService.instance.triggerAfterLocalMutation());
      if (!mounted) return;
      // The user-facing save is complete once the task and its outbox item are
      // committed locally. Do not keep the button loader running while the
      // background photo upload/API sync or the success dialog is active.
      setState(() => _isCompleting = false);
      await _showCompletedDialog();
    } catch (error) {
      AppLogger.error('TASK_COMPLETE', error.toString());
      if (mounted) {
        AppSnackbar.error(context, message: error.toString());
      }
    } finally {
      if (mounted && _isCompleting) {
        setState(() => _isCompleting = false);
      }
    }
  }

  Future<void> _showCompletedDialog() async {
    final completed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _TaskCompletedDialog(),
    );
    if (completed == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    appBar: CustomAppBar(
      title: _isClosed
          ? context.l10n.taskDetailsTitle
          : context.l10n.taskResolveTitle,
      backIconAsset: 'assets/icons/records/back.svg',
      titleStyle: AppTextStyles.semiboldH6_20,
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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  children: [
                    _TaskStatusRow(task: _task),
                    if (!_isClosed) ...[
                      const SizedBox(height: 16),
                      TaskInformationCard(
                        title: _task.title,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_assignmentDescription != null) ...[
                              Text(
                                _assignmentDescription!,
                                style: AppTextStyles.mediumSH8_14.copyWith(
                                  color: AppColors.neutral950,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            _BySupervisor(
                              label: _task.assignedByName ?? _task.assignedBy,
                            ),
                          ],
                        ),
                      ),
                      if (_task.photoUrls.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        TaskInformationCard(
                          title: context.l10n.taskAttachmentTitle,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TaskPhotoGrid(
                                key: const Key('supervisor-task-attachments'),
                                images: _task.photoUrls,
                              ),
                              const SizedBox(height: 12),
                              _BySupervisor(
                                label: _task.assignedByName ?? _task.assignedBy,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _sectionLabel(
                        context.l10n.taskCompletionProof,
                        style: AppTextStyles.mediumSH8_14,
                      ),
                      const SizedBox(height: 8),
                      _CaptureProof(
                        enabled: _proofImages.isEmpty,
                        onTap: _captureProof,
                      ),
                      if (_proofImages.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        TaskPhotoGrid(
                          images: _proofImages,
                          removable: true,
                          onRemove: (index) =>
                              setState(() => _proofImages.removeAt(index)),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.taskProofSupported,
                        style: AppTextStyles.regularB8_12.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _sectionLabel(
                        context.l10n.taskDescriptionLabel,
                        style: AppTextStyles.mediumSH8_14,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        key: const Key('task-description-field'),
                        controller: _descriptionController,
                        minLines: 5,
                        maxLines: 5,
                        maxLength: 150,
                        onChanged: (_) => setState(() {}),
                        style: AppTextStyles.regularB7_14,
                        decoration: InputDecoration(
                          hintText: context.l10n.taskDescriptionHint,
                          hintStyle: AppTextStyles.regularB7_14.copyWith(
                            color: AppColors.neutral400,
                          ),
                          counterText: context.l10n.taskDescriptionMinimum,
                          counterStyle: AppTextStyles.regularB8_12.copyWith(
                            color: AppColors.neutral400,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppColors.cool400,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppColors.primary500,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ] else ...[
                      ..._closedTaskContent(context),
                    ],
                  ],
                ),
              ),
              if (!_isClosed)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  color: Colors.white,
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      key: const Key('mark-task-completed-button'),
                      onPressed: _canComplete && !_isCompleting
                          ? _completeTask
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        disabledBackgroundColor: AppColors.neutral400,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isCompleting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              context.l10n.taskMarkCompleted,
                              style: AppTextStyles.semiboldH9_14,
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

  Widget _sectionLabel(String label, {TextStyle? style}) => AppRequiredText(
    label,
    style: (style ?? AppTextStyles.mediumSH7_16).copyWith(
      color: AppColors.neutral950,
    ),
  );

  List<Widget> _closedTaskContent(BuildContext context) => [
    if (!isCancelledTaskStatus(_task.status)) ...[
      const SizedBox(height: 24),
      _sectionLabel(context.l10n.taskCompletionProofPlain),
      const SizedBox(height: 16),
      _CaptureProof(enabled: false, onTap: () {}),
      if (_proofImages.isNotEmpty) ...[
        const SizedBox(height: 8),
        TaskPhotoGrid(images: _proofImages),
      ],
      const SizedBox(height: 8),
      Text(
        context.l10n.taskProofSupported,
        style: AppTextStyles.regularB8_12.copyWith(color: AppColors.neutral600),
      ),
      const SizedBox(height: 16),
      _sectionLabel(
        context.l10n.taskDescriptionPlain,
        style: AppTextStyles.mediumSH8_14,
      ),
      const SizedBox(height: 8),
      _ReadOnlyDescription(text: _task.note?.trim() ?? ''),
    ],
    const SizedBox(height: 24),
    _sectionLabel(context.l10n.taskSupervisorDetails),
    const SizedBox(height: 16),
    TaskInformationCard(
      title: context.l10n.taskDescriptionPlain,
      backgroundColor: AppColors.cool200,
      showShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_assignmentDescription != null) ...[
            Text(
              _assignmentDescription!,
              style: AppTextStyles.mediumSH8_14.copyWith(
                color: AppColors.neutral950,
              ),
            ),
            const SizedBox(height: 12),
          ],
          _BySupervisor(label: _task.assignedByName ?? _task.assignedBy),
        ],
      ),
    ),
  ];
}

class _TaskStatusRow extends StatelessWidget {
  const _TaskStatusRow({required this.task});

  final TaskModel task;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [HomeStyles.cardShadow],
    ),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (isCancelledTaskStatus(task.status))
          _DetailChip(
            icon: Icons.cancel_outlined,
            label: context.l10n.supervisorTaskCancelled,
            color: AppColors.red600,
            background: AppColors.red50,
          )
        else if (isClosedTaskStatus(task.status))
          _DetailChip(
            icon: Icons.check_circle_outline_rounded,
            label: _completedLabel(context),
            color: AppColors.primary600,
            background: AppColors.primary50,
          )
        else ...[
          _DetailChip(
            icon: Icons.calendar_today_outlined,
            label: _dueLabel(context),
            color: AppColors.purple,
            background: const Color(0xFFF1EDFF),
          ),
          _DetailChip(
            icon: Icons.schedule_rounded,
            label: _priorityLabel(context),
            color: _priorityColor,
            background: _priorityBackground,
          ),
        ],
      ],
    ),
  );

  String _dueLabel(BuildContext context) {
    final due = DateTime.tryParse(task.dueAt ?? '')?.toLocal();
    if (due == null) return task.status;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(due.year, due.month, due.day);
    final time = DateFormat('h:mm a').format(due);
    if (dueDay == today) return context.l10n.taskDueTodayAt(time);
    if (dueDay == today.add(const Duration(days: 1))) {
      return context.l10n.taskDueTomorrowAt(time);
    }
    return context.l10n.taskDueAt(
      DateFormat('dd MMM yyyy, h:mm a').format(due),
    );
  }

  String _completedLabel(BuildContext context) {
    final completed = DateTime.tryParse(task.completedAt ?? '')?.toLocal();
    if (completed == null) return context.l10n.taskCompletedLabel;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completedDay = DateTime(
      completed.year,
      completed.month,
      completed.day,
    );
    if (completedDay == today) {
      return context.l10n.taskCompletedTodayAt(
        DateFormat('h:mm a').format(completed),
      );
    }
    return context.l10n.taskCompletedAt(
      DateFormat('dd MMM yyyy, h:mm a').format(completed),
    );
  }

  String _priorityLabel(BuildContext context) =>
      switch (task.priority.toUpperCase()) {
        'HIGH' => context.l10n.taskPriorityHigh,
        'NORMAL' || 'MEDIUM' => context.l10n.taskPriorityNormal,
        _ => context.l10n.taskPriorityLow,
      };

  Color get _priorityColor => switch (task.priority.toUpperCase()) {
    'HIGH' => AppColors.red600,
    'NORMAL' || 'MEDIUM' => AppColors.yellow600,
    _ => AppColors.secondary500,
  };

  Color get _priorityBackground => switch (task.priority.toUpperCase()) {
    'HIGH' => AppColors.red50,
    'NORMAL' || 'MEDIUM' => const Color(0xFFFFFBEB),
    _ => AppColors.secondary50,
  };
}

class _ReadOnlyDescription extends StatelessWidget {
  const _ReadOnlyDescription({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: 123,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cool100,
      border: Border.all(color: AppColors.cool400),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Stack(
      children: [
        Positioned.fill(
          bottom: 22,
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              text,
              style: AppTextStyles.regularB7_14.copyWith(
                color: AppColors.neutral400,
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Text(
            context.l10n.taskDescriptionMinimum,
            style: AppTextStyles.regularB8_12.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ),
      ],
    ),
  );
}

class _TaskCompletedDialog extends StatelessWidget {
  const _TaskCompletedDialog();

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 32),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 42, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.taskCompletedTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.boldH6_20.copyWith(
              color: AppColors.neutral950,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.taskCompletedMessage,
            textAlign: TextAlign.center,
            style: AppTextStyles.regularB7_14.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              key: const Key('task-back-to-list-button'),
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.cool200,
                foregroundColor: AppColors.neutral950,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                context.l10n.taskBackToList,
                style: AppTextStyles.semiboldH9_14,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String label;
  final Color color;
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
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.semiboldH10_12.copyWith(color: color),
          ),
        ),
      ],
    ),
  );
}

class _BySupervisor extends StatelessWidget {
  const _BySupervisor({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Text('•', style: TextStyle(color: AppColors.neutral500)),
      const SizedBox(width: 5),
      Text(
        label,
        style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral700),
      ),
    ],
  );
}

class _CaptureProof extends StatelessWidget {
  const _CaptureProof({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    key: const Key('capture-task-proof'),
    onTap: enabled ? onTap : null,
    borderRadius: BorderRadius.circular(10),
    child: DottedBorder(
      options: RoundedRectDottedBorderOptions(
        radius: const Radius.circular(10),
        color: enabled ? AppColors.primary500 : AppColors.cool400,
        dashPattern: const [4, 3],
        strokeWidth: 1,
        padding: EdgeInsets.zero,
      ),
      child: Container(
        height: 82,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary50 : AppColors.cool100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/collection/capture_camera.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                enabled ? AppColors.primary600 : AppColors.cool500,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.capturePhoto,
              style: AppTextStyles.mediumSH8_14.copyWith(
                color: enabled ? AppColors.neutral800 : AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
