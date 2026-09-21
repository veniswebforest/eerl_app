import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';

enum RaiseRequestViewMode { empty, filled }

enum _RequestPriority { low, normal, high }

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
  _RequestPriority _priority = _RequestPriority.low;
  String? _followupDate;
  bool _descriptionHasFocus = false;

  bool get _canSubmit =>
      _photoCount > 0 &&
      _followupDate != null &&
      _descriptionController.text.trim().isNotEmpty;

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
      _followupDate = context.l10n.requestFilledFollowupDate;
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
                      onTap: () => setState(
                        () => _followupDate =
                            context.l10n.requestFilledFollowupDate,
                      ),
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
                                _followupDate ??
                                    context.l10n.requestSelectDateTime,
                                style: AppTextStyles.regularB7_14.copyWith(
                                  color: _followupDate == null
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
                    AnimatedContainer(
                      key: const Key('request-description-container'),
                      duration: const Duration(milliseconds: 160),
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.neutral50,
                        border: Border.all(
                          color: _descriptionHasFocus
                              ? AppColors.primary400
                              : AppColors.cool400,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        key: const Key('request-description-field'),
                        controller: _descriptionController,
                        focusNode: _descriptionFocusNode,
                        maxLength: 150,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        onChanged: (_) => setState(() {}),
                        style: AppTextStyles.regularB7_14,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
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
                            12,
                            12,
                            12,
                            8,
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
                        color: _photoCount == 0
                            ? AppColors.primary500
                            : AppColors.cool300,
                        dashPattern: const [5, 4],
                      ),
                      child: Material(
                        color: _photoCount == 0
                            ? AppColors.primary50
                            : AppColors.cool100,
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
                                  colorFilter: ColorFilter.mode(
                                    _photoCount == 0
                                        ? AppColors.primary500
                                        : AppColors.cool400,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  context.l10n.requestCapturePhoto,
                                  style: AppTextStyles.mediumSH8_14.copyWith(
                                    color: _photoCount == 0
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
    height: 56,
    padding: const EdgeInsets.symmetric(horizontal: 16),
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
