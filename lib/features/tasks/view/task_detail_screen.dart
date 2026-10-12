import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/utils/image_compressor.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import '../widgets/task_information_card.dart';
import '../widgets/task_photo_grid.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.task,
    this.initiallyFilled = false,
  });

  final TaskModel task;
  final bool initiallyFilled;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late final TextEditingController _descriptionController;
  late List<String> _proofImages;
  bool _isCompleting = false;

  bool get _canComplete =>
      _proofImages.isNotEmpty && _descriptionController.text.trim().isNotEmpty;

  String? get _assignmentDescription {
    final description = widget.task.description?.trim();
    if (description?.isNotEmpty == true) return description;
    if (_isClosed) return null;
    final note = widget.task.note?.trim();
    return note?.isNotEmpty == true ? note : null;
  }

  @override
  void initState() {
    super.initState();
    _proofImages = _isClosed ? [...widget.task.photoUrls] : [];
    _descriptionController = TextEditingController(
      text: _isClosed ? widget.task.note ?? '' : '',
    );
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
    final image = await ImageCompressor.pickAndCompress(
      source: ImageSource.camera,
    );
    if (image != null && mounted) {
      setState(() => _proofImages.add(image.path));
    }
  }

  bool get _isClosed =>
      const {'COMPLETED', 'CLOSED'}.contains(widget.task.status.toUpperCase());

  Future<void> _completeTask() async {
    if (!_canComplete || _isCompleting) return;
    setState(() => _isCompleting = true);
    try {
      await EerlLocalRepository.instance.completeTask(
        taskId: widget.task.id,
        note: _descriptionController.text,
        photoPaths: _proofImages,
      );
      unawaited(BootstrapSyncService.instance.triggerAfterLocalMutation());
      if (!mounted) return;
      await _showCompletedDialog();
    } catch (error) {
      AppLogger.error('TASK_COMPLETE', error.toString());
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isCompleting = false);
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
                    _TaskStatusRow(task: widget.task),
                    if (!_isClosed) ...[
                      const SizedBox(height: 12),
                      TaskInformationCard(
                        title: widget.task.title,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_assignmentDescription != null) ...[
                              Text(
                                _assignmentDescription!,
                                style: AppTextStyles.regularB8_12.copyWith(
                                  color: AppColors.neutral700,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                            _BySupervisor(
                              label:
                                  widget.task.assignedByName ??
                                  widget.task.assignedBy,
                            ),
                          ],
                        ),
                      ),
                      if (widget.task.photoUrls.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        TaskInformationCard(
                          title: context.l10n.taskAttachmentTitle,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TaskPhotoGrid(images: widget.task.photoUrls),
                              const SizedBox(height: 10),
                              _BySupervisor(
                                label:
                                    widget.task.assignedByName ??
                                    widget.task.assignedBy,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      _sectionLabel(context.l10n.taskCompletionProof),
                      const SizedBox(height: 10),
                      _CaptureProof(
                        enabled: _proofImages.isEmpty,
                        onTap: _captureProof,
                      ),
                      if (_proofImages.isNotEmpty) ...[
                        const SizedBox(height: 12),
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
                      const SizedBox(height: 14),
                      _sectionLabel(context.l10n.taskDescriptionLabel),
                      const SizedBox(height: 10),
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
                          contentPadding: const EdgeInsets.all(14),
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

  Widget _sectionLabel(String label) => Text(
    label,
    style: AppTextStyles.semiboldH9_14.copyWith(color: AppColors.neutral950),
  );

  List<Widget> _closedTaskContent(BuildContext context) => [
    if (_proofImages.isNotEmpty) ...[
      const SizedBox(height: 16),
      _sectionLabel(context.l10n.taskCompletionProofPlain),
      const SizedBox(height: 10),
      TaskPhotoGrid(images: _proofImages),
    ],
    if (widget.task.note?.trim().isNotEmpty == true) ...[
      const SizedBox(height: 14),
      _sectionLabel(context.l10n.taskDescriptionPlain),
      const SizedBox(height: 10),
      _ReadOnlyDescription(text: widget.task.note!.trim()),
    ],
    const SizedBox(height: 18),
    _sectionLabel(context.l10n.taskSupervisorDetails),
    const SizedBox(height: 10),
    TaskInformationCard(
      title: widget.task.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_assignmentDescription != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Text(
                _assignmentDescription!,
                style: AppTextStyles.regularB8_12.copyWith(
                  color: AppColors.neutral700,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          _BySupervisor(
            label: widget.task.assignedByName ?? widget.task.assignedBy,
          ),
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
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 5)],
    ),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (const {'COMPLETED', 'CLOSED'}.contains(task.status.toUpperCase()))
          _DetailChip(
            icon: Icons.check_circle_outline_rounded,
            label: _completedLabel(context),
            color: AppColors.primary600,
            background: AppColors.primary50,
          )
        else ...[
          _DetailChip(
            icon: Icons.calendar_today_outlined,
            label: _dueLabel(),
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

  String _dueLabel() {
    final due = DateTime.tryParse(task.dueAt ?? '')?.toLocal();
    return due == null
        ? task.status
        : DateFormat('dd MMM yyyy, hh:mm a').format(due);
  }

  String _completedLabel(BuildContext context) {
    final label = context.l10n.taskCompletedTime.split(':').first.trim();
    final completed = DateTime.tryParse(task.completedAt ?? '')?.toLocal();
    if (completed == null) return label;
    return '$label • '
        '${DateFormat('dd MMM yyyy, hh:mm a').format(completed)}';
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
    constraints: const BoxConstraints(minHeight: 120),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.cool50,
      border: Border.all(color: AppColors.cool400),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: AppTextStyles.regularB7_14.copyWith(
            color: AppColors.neutral600,
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
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.mediumSH9_12.copyWith(color: color)),
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
        style: AppTextStyles.regularB8_12.copyWith(color: AppColors.neutral600),
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
        height: 72,
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
            const SizedBox(height: 6),
            Text(
              context.l10n.capturePhoto,
              style: AppTextStyles.mediumSH9_12.copyWith(
                color: enabled ? AppColors.neutral800 : AppColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
