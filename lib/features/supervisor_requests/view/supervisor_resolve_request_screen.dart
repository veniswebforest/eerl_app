import 'dart:ui';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/utils/image_compressor.dart';
import 'package:eerl_app/core/utils/ist_date_time.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/supervisor_requests/widgets/supervisor_request_assets.dart';
import 'package:eerl_app/features/supervisor_requests/widgets/supervisor_request_detail_widgets.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_header.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/shared/widgets/app_snackbar.dart';
import 'package:eerl_app/shared/widgets/in_app_camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SupervisorResolveRequestScreen extends StatefulWidget {
  const SupervisorResolveRequestScreen({
    super.key,
    required this.request,
    this.initialFilled = false,
  });

  final RequestModel request;
  final bool initialFilled;

  @override
  State<SupervisorResolveRequestScreen> createState() =>
      _SupervisorResolveRequestScreenState();
}

class _SupervisorResolveRequestScreenState
    extends State<SupervisorResolveRequestScreen> {
  late final TextEditingController _descriptionController;
  late final FocusNode _descriptionFocusNode;
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _capturedPhotos = [];
  final List<String> _capturedPhotoIds = [];
  bool _descriptionHasFocus = false;
  bool _isSubmitting = false;

  bool get _canResolve => _descriptionController.text.trim().length >= 3;

  String get _cameraRecoveryId =>
      'supervisor.request.resolve.${widget.request.id}';

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _descriptionFocusNode = FocusNode();
    _descriptionFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _descriptionHasFocus = _descriptionFocusNode.hasFocus;
        });
      }
    });
    _restoreCameraResult();
  }

  Future<void> _restoreCameraResult() async {
    final photo = await ImageCompressor.claimRecoveredImage(_cameraRecoveryId);
    if (photo == null || !mounted) return;
    await _addCapturedPhoto(photo);
  }

  Future<void> _addCapturedPhoto(XFile photo) async {
    final photoId = await EerlLocalRepository.instance.stageRequestAnswerPhoto(
      requestId: widget.request.id,
      path: photo.path,
    );
    if (!mounted) return;
    setState(() {
      _capturedPhotos.add(photo);
      _capturedPhotoIds.add(photoId);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.initialFilled && _descriptionController.text.isEmpty) {
      _descriptionController.text = context.l10n.requestFilledDescription;
    }
  }

  @override
  void dispose() {
    _descriptionFocusNode.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    try {
      final photo = await InAppCameraScreen.capture(
        context,
        picker: _imagePicker,
        recoveryId: _cameraRecoveryId,
        title: 'Capture Answer Proof',
      );
      if (photo != null && mounted) {
        await _addCapturedPhoto(photo);
      }
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.error(
        context,
        message: context.l10n.supervisorRequestSaveError,
      );
    }
  }

  Future<void> _removePhoto(int index) async {
    if (index >= _capturedPhotoIds.length) return;
    await EerlLocalRepository.instance.removeRequestAnswerPhoto(
      requestId: widget.request.id,
      photoId: _capturedPhotoIds[index],
    );
    if (!mounted) return;
    setState(() {
      _capturedPhotos.removeAt(index);
      _capturedPhotoIds.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    behavior: HitTestBehavior.opaque,
    child: Scaffold(
      key: const Key('supervisor-resolve-request-screen'),
      backgroundColor: AppColors.backgroundColor,
      appBar: SupervisorTaskHeader(
        title: context.l10n.supervisorAgentRequestResolveTitle,
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
                    key: const Key('supervisor-resolve-request-scroll'),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    children: [
                      const SupervisorRequestStatusCard(completed: false),
                      const SizedBox(height: 16),
                      SupervisorRequestInfoCard(
                        title: context.l10n.requestDescriptionPlain,
                        value: widget.request.body,
                        caption:
                            widget.request.createdByName ??
                            widget.request.createdBy,
                      ),
                      if (widget.request.followUpAt != null) ...[
                        const SizedBox(height: 16),
                        _FollowUpCard(request: widget.request),
                      ],
                      const SizedBox(height: 16),
                      FutureBuilder<List<String>>(
                        future: EerlLocalRepository.instance
                            .getRequestPhotoSources(widget.request.id),
                        initialData: widget.request.photoUrls,
                        builder: (context, snapshot) =>
                            SupervisorRequestInfoCard(
                              title:
                                  context.l10n.supervisorAgentRequestAttachment,
                              images: snapshot.data ?? const <String>[],
                              caption:
                                  widget.request.createdByName ??
                                  widget.request.createdBy,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        context.l10n.supervisorAgentRequestProof,
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.neutral950,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SupervisorRequestCaptureBox(
                        active: true,
                        onTap: _capturePhoto,
                      ),
                      if (_capturedPhotos.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SupervisorRequestPhotoPair(
                          filePhotos: _capturedPhotos,
                          onRemove: _removePhoto,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.requestPhotoSupport,
                        style: AppTextStyles.regularB8_12.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: context.l10n.requestDescriptionPlain,
                            ),
                            const TextSpan(
                              text: ' *',
                              style: TextStyle(color: AppColors.red600),
                            ),
                          ],
                        ),
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.neutral950,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        padding: EdgeInsetsDirectional.only(bottom: 6),
                        duration: const Duration(milliseconds: 160),
                        height: 133,
                        decoration: BoxDecoration(
                          // color: Colors.white,
                          border: Border.all(
                            color: _descriptionHasFocus
                                ? AppColors.primary500
                                : AppColors.cool400,
                            width: _descriptionHasFocus ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          key: const Key('supervisor-request-description'),
                          controller: _descriptionController,
                          focusNode: _descriptionFocusNode,
                          expands: true,
                          maxLines: null,
                          maxLength: 150,
                          textAlignVertical: TextAlignVertical.top,
                          onChanged: (_) => setState(() {}),
                          style: AppTextStyles.regularB7_14.copyWith(
                            color: AppColors.neutral950,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            hintText: context.l10n.requestDescriptionHint,
                            hintStyle: AppTextStyles.regularB7_14.copyWith(
                              color: AppColors.cool500,
                            ),
                            counterText: context.l10n.requestDescriptionCounter,
                            counterStyle: AppTextStyles.regularB8_12.copyWith(
                              color: AppColors.neutral400,
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(
                              14,
                              12,
                              14,
                              8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      key: const Key('supervisor-resolve-request-button'),
                      onPressed: _canResolve && !_isSubmitting
                          ? _resolveRequest
                          : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        disabledBackgroundColor: AppColors.neutral400,
                        backgroundColor: AppColors.primary500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              context.l10n.supervisorAgentRequestResolveButton,
                              style: AppTextStyles.boldH7_16.copyWith(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _resolveRequest() async {
    setState(() => _isSubmitting = true);
    try {
      await EerlLocalRepository.instance.answerRequest(
        requestId: widget.request.id,
        notes: _descriptionController.text,
      );
      await OutgoingSyncService.instance.drain();
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await _showSuccessDialog();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppSnackbar.error(context, message: error.toString());
    }
  }

  Future<void> _showSuccessDialog() => showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: context.l10n.supervisorAgentRequestSuccessTitle,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    pageBuilder: (dialogContext, _, _) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        key: const Key('supervisor-request-success-dialog'),
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
                Image.asset(
                  SupervisorRequestAssets.success,
                  width: 122,
                  height: 122,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 24),
                Text(
                  context.l10n.supervisorAgentRequestSuccessTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.boldH5_24.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 231),
                  child: Text(
                    context.l10n.supervisorAgentRequestSuccessMessage,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.mediumSH8_14.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    key: const Key('supervisor-request-back-to-list'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.cool200,
                      foregroundColor: AppColors.neutral950,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      context.l10n.requestBackToList,
                      style: AppTextStyles.semiboldH8_16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _FollowUpCard extends StatelessWidget {
  const _FollowUpCard({required this.request});

  final RequestModel request;

  @override
  Widget build(BuildContext context) {
    final value = IstDateTime.formatUtc(
      request.followUpAt ?? '',
      'dd MMM yyyy, h:mm a',
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: request.overdue ? AppColors.red50 : Colors.white,
        border: Border.all(
          color: request.overdue ? AppColors.red300 : AppColors.cool300,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            color: request.overdue ? AppColors.red600 : AppColors.primary500,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.requestFollowupBy(value),
              style: AppTextStyles.mediumSH8_14.copyWith(
                color: AppColors.neutral900,
              ),
            ),
          ),
          if (request.overdue)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.red100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.l10n.requestOverdue,
                style: AppTextStyles.mediumSH9_12.copyWith(
                  color: AppColors.red600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
