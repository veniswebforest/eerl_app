import 'dart:async';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/utils/image_compressor.dart';
import 'package:eerl_app/core/utils/ist_date_time.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';

enum RaiseRequestViewMode { empty, filled }

enum _RequestPriority { low, normal, high }

class RaiseRequestScreen extends StatefulWidget {
  const RaiseRequestScreen({
    super.key,
    this.viewMode = RaiseRequestViewMode.empty,
  });

  final RaiseRequestViewMode viewMode;

  @override
  State<RaiseRequestScreen> createState() => _RaiseRequestScreenState();
}

class _RaiseRequestScreenState extends State<RaiseRequestScreen> {
  late final TextEditingController _descriptionController;
  final List<String> _photoPaths = [];
  _RequestPriority _priority = _RequestPriority.low;
  DateTime? _followupDateTime;
  bool _submitting = false;

  bool get _canSubmit =>
      _photoPaths.isNotEmpty &&
      _followupDateTime != null &&
      _descriptionController.text.trim().isNotEmpty &&
      !_submitting;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFollowupDateTime() async {
    final now = IstDateTime.now();
    final initial = _followupDateTime ?? now.add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;
    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!selected.isAfter(IstDateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.requestFollowupFutureError)),
      );
      return;
    }
    setState(() => _followupDateTime = selected);
  }

  Future<void> _capturePhoto() async {
    if (_photoPaths.length >= 2) return;
    final photo = await ImageCompressor.pickAndCompress(
      source: ImageSource.camera,
    );
    if (photo == null || !mounted) return;
    setState(() => _photoPaths.add(photo.path));
  }

  void _previewPhoto(String path) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _RequestPhotoPreviewScreen(path: path),
      ),
    );
  }

  Future<void> _submitRequest() async {
    final followUpAt = _followupDateTime;
    if (!_canSubmit || followUpAt == null) return;
    setState(() => _submitting = true);
    try {
      await EerlLocalRepository.instance.raiseRequest(
        body: _descriptionController.text,
        priority: _priority.name,
        followUpAt: IstDateTime.toUtc(followUpAt),
        photoPaths: _photoPaths,
      );
      unawaited(BootstrapSyncService.instance.triggerAfterLocalMutation());
      if (!mounted) return;
      await _showRequestSentDialog();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.requestSubmitFailed)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    appBar: CustomAppBar(
      title: context.l10n.requestRaiseTitle,
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    const _SupervisorCard(),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.requestPriorityLevel,
                      style: AppTextStyles.mediumSH8_14,
                    ),
                    const SizedBox(height: 8),
                    _PrioritySelector(
                      selected: _priority,
                      onChanged: (value) => setState(() => _priority = value),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.requestFollowupDateTime,
                      style: AppTextStyles.mediumSH8_14,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      key: const Key('request-followup-date'),
                      onTap: _pickFollowupDateTime,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.neutral50,
                          border: Border.all(
                            color: AppColors.cool400,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _followupDateTime == null
                                    ? context.l10n.requestSelectDateTime
                                    : DateFormat(
                                        'dd MMM yyyy, hh:mm a',
                                      ).format(_followupDateTime!),
                                style: AppTextStyles.regularB7_14.copyWith(
                                  color: _followupDateTime == null
                                      ? AppColors.cool500
                                      : AppColors.neutral950,
                                ),
                              ),
                            ),
                            SvgPicture.asset(
                              'assets/icons/home/calendar.svg',
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                AppColors.primary500,
                                BlendMode.srcIn,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.requestDescriptionLabel,
                      style: AppTextStyles.mediumSH8_14,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      key: const Key('request-description-container'),
                      height: 142,
                      child: TextField(
                        key: const Key('request-description-field'),
                        controller: _descriptionController,
                        maxLength: 150,
                        minLines: 5,
                        maxLines: 5,
                        textAlignVertical: TextAlignVertical.top,
                        onChanged: (_) => setState(() {}),
                        style: AppTextStyles.regularB7_14,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.neutral50,
                          hintText: context.l10n.requestDescriptionHint,
                          hintStyle: AppTextStyles.regularB7_14.copyWith(
                            color: AppColors.cool500,
                          ),
                          counterText: context.l10n.requestDescriptionCounter,
                          counterStyle: AppTextStyles.regularB8_12.copyWith(
                            color: AppColors.neutral600,
                          ),
                          contentPadding: const EdgeInsets.fromLTRB(
                            14,
                            14,
                            14,
                            10,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppColors.cool400,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: AppColors.primary500,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.requestAddPhoto,
                      style: AppTextStyles.mediumSH8_14,
                    ),
                    const SizedBox(height: 8),
                    DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        radius: const Radius.circular(8),
                        color: _photoPaths.isEmpty
                            ? AppColors.primary500
                            : AppColors.cool300,
                        dashPattern: const [5, 4],
                      ),
                      child: Material(
                        color: _photoPaths.isEmpty
                            ? AppColors.primary50
                            : AppColors.cool100,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          key: const Key('request-capture-photo'),
                          onTap: _photoPaths.length < 2 ? _capturePhoto : null,
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            height: 80,
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/wallet/expense_camera.svg',
                                  width: 24,
                                  height: 24,
                                  colorFilter: ColorFilter.mode(
                                    _photoPaths.isEmpty
                                        ? AppColors.primary500
                                        : AppColors.cool400,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  context.l10n.requestCapturePhoto,
                                  style: AppTextStyles.mediumSH8_14.copyWith(
                                    color: _photoPaths.isEmpty
                                        ? AppColors.neutral900
                                        : AppColors.neutral400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_photoPaths.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (
                            var index = 0;
                            index < _photoPaths.length;
                            index++
                          ) ...[
                            Expanded(
                              child: _RequestPhoto(
                                index: index,
                                path: _photoPaths[index],
                                onPreview: () =>
                                    _previewPhoto(_photoPaths[index]),
                                onRemove: () =>
                                    setState(() => _photoPaths.removeAt(index)),
                              ),
                            ),
                            if (index < _photoPaths.length - 1)
                              const SizedBox(width: 8),
                          ],
                          if (_photoPaths.length == 1) const Spacer(),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.requestPhotoSupport,
                      style: AppTextStyles.regularB8_12.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    key: const Key('submit-request-button'),
                    onPressed: _canSubmit ? _submitRequest : null,
                    child: _submitting
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(context.l10n.requestSubmitButton),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _showRequestSentDialog() => showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (dialogContext) => Dialog(
      key: const Key('request-sent-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/expense_submitted_success.png',
              key: const Key('request-sent-success-image'),
              width: 135,
              height: 135,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.requestSentTitle,
              style: AppTextStyles.semiboldH7_18.copyWith(
                color: AppColors.neutral950,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.requestSentMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.mediumSH8_14.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                key: const Key('request-back-to-list-button'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cool100,
                  foregroundColor: AppColors.neutral950,
                ),
                child: Text(
                  context.l10n.requestBackToList,
                  style: AppTextStyles.semiboldH8_16.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SupervisorCard extends StatelessWidget {
  const _SupervisorCard();

  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [HomeStyles.cardShadow],
    ),
    child: Center(
      child: Text(
        context.l10n.requestToSupervisor,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.semiboldH9_14,
      ),
    ),
  );
}

class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({required this.selected, required this.onChanged});

  final _RequestPriority selected;
  final ValueChanged<_RequestPriority> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: _RequestPriority.values
        .map(
          (priority) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              key: Key('request-priority-${priority.name}'),
              onTap: () => onChanged(priority),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 40,
                constraints: const BoxConstraints(minWidth: 58),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: selected == priority
                      ? AppColors.primary500
                      : AppColors.cool200,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  switch (priority) {
                    _RequestPriority.low => context.l10n.requestPriorityLow,
                    _RequestPriority.normal =>
                      context.l10n.requestPriorityNormal,
                    _RequestPriority.high => context.l10n.requestPriorityHigh,
                  },
                  style: AppTextStyles.regularB8_12.copyWith(
                    color: selected == priority
                        ? AppColors.neutral50
                        : AppColors.neutral950,
                  ),
                ),
              ),
            ),
          ),
        )
        .toList(growable: false),
  );
}

class _RequestPhoto extends StatelessWidget {
  const _RequestPhoto({
    required this.index,
    required this.path,
    required this.onPreview,
    required this.onRemove,
  });

  final int index;
  final String path;
  final VoidCallback onPreview;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 143.5 / 92,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Material(
            color: AppColors.cool100,
            child: InkWell(
              key: ValueKey('preview-request-photo-$index'),
              onTap: onPreview,
              child: Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.cool500,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              key: ValueKey('remove-request-photo-$index'),
              onTap: onRemove,
              child: SvgPicture.asset(
                'assets/icons/wallet/expense_remove.svg',
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _RequestPhotoPreviewScreen extends StatelessWidget {
  const _RequestPhotoPreviewScreen({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const Key('request-photo-preview-screen'),
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: Image.file(
                  File(path),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.broken_image_outlined,
                    size: 48,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton.filled(
              key: const Key('request-photo-preview-close'),
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.55),
              ),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}
