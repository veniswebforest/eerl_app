import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../model/task_list_item.dart';
import '../widgets/task_information_card.dart';
import '../widgets/task_photo_grid.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.onBack,
    this.initiallyFilled = false,
  });

  final TaskListItem task;
  final VoidCallback onBack;
  final bool initiallyFilled;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late final TextEditingController _descriptionController;
  late List<String> _proofImages;

  static const _supervisorImages = [
    'assets/images/collection_detail/pet_collection.png',
    'assets/images/collection_detail/hdpe_collection.png',
  ];
  static const _mockProofImages = [
    'assets/images/collection_detail/pp_collection.png',
    'assets/images/collection_detail/pet_thumbnail.png',
  ];

  bool get _canComplete =>
      _proofImages.isNotEmpty && _descriptionController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _proofImages = widget.initiallyFilled ? [..._mockProofImages] : [];
    _descriptionController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.initiallyFilled && _descriptionController.text.isEmpty) {
      _descriptionController.text = context.l10n.taskFilledDescription;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _addMockProof() {
    if (_proofImages.isNotEmpty) return;
    setState(() {
      _proofImages = [..._mockProofImages];
      _descriptionController.text = context.l10n.taskFilledDescription;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    appBar: CustomAppBar(
      title: context.l10n.taskResolveTitle,
      onBackTap: widget.onBack,
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
                    const SizedBox(height: 12),
                    TaskInformationCard(
                      title: context.l10n.taskOverviewTitle,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.taskOverviewDescription,
                            style: AppTextStyles.regularB8_12.copyWith(
                              color: AppColors.neutral700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _BySupervisor(label: context.l10n.taskSupervisorName),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TaskInformationCard(
                      title: context.l10n.taskAttachmentTitle,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TaskPhotoGrid(images: _supervisorImages),
                          const SizedBox(height: 10),
                          _BySupervisor(label: context.l10n.taskSupervisorName),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _sectionLabel(context.l10n.taskCompletionProof),
                    const SizedBox(height: 10),
                    _CaptureProof(
                      enabled: _proofImages.isEmpty,
                      onTap: _addMockProof,
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
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                color: Colors.white,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    key: const Key('mark-task-completed-button'),
                    onPressed: _canComplete ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      disabledBackgroundColor: AppColors.neutral400,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
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
}

class _TaskStatusRow extends StatelessWidget {
  const _TaskStatusRow({required this.task});

  final TaskListItem task;

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
        _DetailChip(
          icon: Icons.calendar_today_outlined,
          label: context.l10n.taskDueToday,
          color: AppColors.purple,
          background: const Color(0xFFF1EDFF),
        ),
        _DetailChip(
          icon: Icons.schedule_rounded,
          label: context.l10n.taskPriorityHigh,
          color: AppColors.red600,
          background: AppColors.red50,
        ),
      ],
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
