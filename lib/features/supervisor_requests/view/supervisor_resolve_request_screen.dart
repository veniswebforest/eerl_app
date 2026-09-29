import 'dart:ui';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/supervisor_requests/widgets/supervisor_request_assets.dart';
import 'package:eerl_app/features/supervisor_requests/widgets/supervisor_request_detail_widgets.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_header.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SupervisorResolveRequestScreen extends StatefulWidget {
  const SupervisorResolveRequestScreen({super.key, this.initialFilled = false});

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
  late bool _hasPhotos = widget.initialFilled;
  bool _descriptionHasFocus = false;

  bool get _canResolve =>
      (_capturedPhotos.isNotEmpty || _hasPhotos) &&
      _descriptionController.text.trim().isNotEmpty;

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
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 82,
      );
      if (photo != null && mounted) {
        setState(() {
          _capturedPhotos.add(photo);
          _hasPhotos = true;
        });
        return;
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _hasPhotos = true;
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      if (_capturedPhotos.isNotEmpty && index < _capturedPhotos.length) {
        _capturedPhotos.removeAt(index);
      }
      if (_capturedPhotos.isEmpty && !widget.initialFilled) {
        _hasPhotos = false;
      } else if (_capturedPhotos.isEmpty && widget.initialFilled) {
        _hasPhotos = false;
      }
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
                        value:
                            context.l10n.supervisorAgentRequestLongDescription,
                        caption: context.l10n.requestAgentName,
                      ),
                      const SizedBox(height: 16),
                      SupervisorRequestInfoCard(
                        title: context.l10n.supervisorAgentRequestAttachment,
                        images: const [
                          SupervisorRequestAssets.collectionAttachment,
                          SupervisorRequestAssets.collectionAttachment,
                        ],
                        caption: context.l10n.requestAgentName,
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
                        active: _capturedPhotos.length < 2,
                        onTap: _capturePhoto,
                      ),
                      if (_capturedPhotos.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SupervisorRequestPhotoPair(
                          filePhotos: _capturedPhotos,
                          onRemove: _removePhoto,
                        ),
                      ] else if (_hasPhotos) ...[
                        const SizedBox(height: 8),
                        SupervisorRequestPhotoPair(
                          images: const [
                            SupervisorRequestAssets.resolutionProof,
                            SupervisorRequestAssets.resolutionProof,
                          ],
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
                      onPressed: _canResolve ? _showSuccessDialog : null,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        disabledBackgroundColor: AppColors.neutral400,
                        backgroundColor: AppColors.primary500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
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
