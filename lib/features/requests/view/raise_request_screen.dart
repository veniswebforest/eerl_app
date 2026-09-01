import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';

enum RaiseRequestViewMode { empty, filled }

class RaiseRequestScreen extends StatefulWidget {
  const RaiseRequestScreen({
    super.key,
    required this.onBack,
    this.onBackToList,
    this.viewMode = RaiseRequestViewMode.empty,
  });

  final VoidCallback onBack;
  final VoidCallback? onBackToList;
  final RaiseRequestViewMode viewMode;

  @override
  State<RaiseRequestScreen> createState() => _RaiseRequestScreenState();
}

class _RaiseRequestScreenState extends State<RaiseRequestScreen> {
  late final TextEditingController _descriptionController;
  late final FocusNode _descriptionFocusNode;
  late int _photoCount;
  bool _descriptionHasFocus = false;

  bool get _canSubmit =>
      _photoCount > 0 && _descriptionController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _photoCount = widget.viewMode == RaiseRequestViewMode.filled ? 2 : 0;
    _descriptionController = TextEditingController();
    _descriptionFocusNode = FocusNode()..addListener(_handleDescriptionFocus);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.viewMode == RaiseRequestViewMode.filled &&
        _descriptionController.text.isEmpty) {
      _descriptionController.text = context.l10n.requestFilledDescription;
    }
  }

  @override
  void dispose() {
    _descriptionFocusNode
      ..removeListener(_handleDescriptionFocus)
      ..dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleDescriptionFocus() {
    if (!mounted) return;
    setState(() => _descriptionHasFocus = _descriptionFocusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    appBar: CustomAppBar(
      title: context.l10n.requestRaiseTitle,
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    const _SupervisorCard(),
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.requestAddPhoto,
                      style: AppTextStyles.mediumSH8_14,
                    ),
                    const SizedBox(height: 8),
                    DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        radius: const Radius.circular(8),
                        color: AppColors.cool400,
                        dashPattern: const [5, 4],
                      ),
                      child: Material(
                        color: AppColors.cool100,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          key: const Key('request-capture-photo'),
                          onTap: _photoCount < 2
                              ? () => setState(() => _photoCount++)
                              : null,
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
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  context.l10n.requestCapturePhoto,
                                  style: AppTextStyles.mediumSH8_14.copyWith(
                                    color: AppColors.neutral400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_photoCount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (var index = 0; index < _photoCount; index++) ...[
                            Expanded(
                              child: _RequestPhoto(
                                index: index,
                                onRemove: () => setState(() => _photoCount--),
                              ),
                            ),
                            if (index < _photoCount - 1)
                              const SizedBox(width: 8),
                          ],
                          if (_photoCount == 1) const Spacer(),
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
                    const SizedBox(height: 24),
                    Text(
                      context.l10n.requestDescriptionLabel,
                      style: AppTextStyles.mediumSH8_14,
                    ),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      key: const Key('request-description-container'),
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _descriptionHasFocus
                              ? AppColors.primary400
                              : AppColors.cool400,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: TextField(
                          key: const Key('request-description-field'),
                          controller: _descriptionController,
                          focusNode: _descriptionFocusNode,
                          maxLength: 150,
                          maxLines: 5,
                          minLines: 5,
                          onChanged: (_) => setState(() {}),
                          style: AppTextStyles.regularB7_14,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            hintText: context.l10n.requestDescriptionHint,
                            counterText: context.l10n.requestDescriptionCounter,
                            alignLabelWithHint: true,
                            contentPadding: const EdgeInsets.all(4),
                          ),
                        ),
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
                    onPressed: _canSubmit ? _showRequestSentDialog : null,
                    child: Text(context.l10n.requestSubmitButton),
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
              width: 122,
              height: 122,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.requestSentTitle,
              style: AppTextStyles.boldH5_24.copyWith(
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
                  widget.onBackToList?.call();
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
    height: 64,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1F000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/request_supervisor.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            context.l10n.requestSupervisorName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.boldH8_14,
          ),
        ),
      ],
    ),
  );
}

class _RequestPhoto extends StatelessWidget {
  const _RequestPhoto({required this.index, required this.onRemove});

  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 143.5 / 92,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/request_photo.png', fit: BoxFit.cover),
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
