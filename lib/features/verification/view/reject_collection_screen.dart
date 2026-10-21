import 'package:flutter/material.dart';

import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/records/widgets/collection_detail_assets.dart';

class CollectionRejectionDecision {
  const CollectionRejectionDecision({required this.reason, this.remarks});

  final String reason;
  final String? remarks;
}

class RejectCollectionScreen extends StatefulWidget {
  const RejectCollectionScreen({super.key, this.collectionNumber});

  final String? collectionNumber;

  @override
  State<RejectCollectionScreen> createState() => _RejectCollectionScreenState();
}

class _RejectCollectionScreenState extends State<RejectCollectionScreen> {
  final Set<int> _selectedReasons = {};
  final TextEditingController _otherController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  @override
  void dispose() {
    _otherController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reasons = [
      context.l10n.verificationRejectWeightMismatch,
      context.l10n.verificationRejectInvalidPhoto,
      context.l10n.verificationRejectIncorrectCategory,
      context.l10n.verificationRejectOther,
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Row(
                  children: [
                    _BackButton(onTap: () => Navigator.of(context).maybePop()),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        context.l10n.verificationRejectTitle,
                        style: AppTextStyles.semiboldH6_20.copyWith(
                          color: AppColors.neutral950,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _CollectionNumberCard(
                  value: widget.collectionNumber?.startsWith('#') == true
                      ? widget.collectionNumber!
                      : '#${widget.collectionNumber ?? ''}',
                ),
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: context.l10n.verificationRejectReason),
                      TextSpan(
                        text: context.l10n.verificationRequiredIndicator,
                        style: const TextStyle(color: AppColors.red600),
                      ),
                    ],
                  ),
                  style: AppTextStyles.mediumSH8_14.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
                const SizedBox(height: 8),
                for (var index = 0; index < reasons.length; index++) ...[
                  _ReasonOption(
                    key: ValueKey('verification-reject-reason-$index'),
                    label: reasons[index],
                    selected: _selectedReasons.contains(index),
                    onTap: () => setState(() {
                      if (!_selectedReasons.remove(index)) {
                        _selectedReasons.add(index);
                      }
                    }),
                  ),
                  if (index != reasons.length - 1) const SizedBox(height: 8),
                ],
                if (_selectedReasons.contains(reasons.length - 1)) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('verification-reject-other'),
                    controller: _otherController,
                    maxLength: 150,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: context.l10n.verificationRejectOther,
                      filled: true,
                      fillColor: AppColors.neutral50,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  context.l10n.verificationRejectRemarksLabel,
                  style: AppTextStyles.mediumSH8_14.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('verification-reject-remarks'),
                  controller: _remarksController,
                  maxLength: 150,
                  minLines: 5,
                  maxLines: 5,
                  style: AppTextStyles.regularB7_14.copyWith(
                    color: AppColors.neutral950,
                  ),
                  decoration: InputDecoration(
                    helper: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        context.l10n.verificationRejectMinimum,
                        style: AppTextStyles.regularB8_12.copyWith(
                          color: AppColors.neutral400,
                        ),
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    filled: true,
                    fillColor: AppColors.neutral50,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.cool400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.red400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    key: const Key('verification-confirm-rejection'),
                    onPressed:
                        _selectedReasons.isEmpty ||
                            (_selectedReasons.contains(reasons.length - 1) &&
                                _otherController.text.trim().isEmpty)
                        ? null
                        : () {
                            final selected = _selectedReasons.toList()..sort();
                            final reasonParts = [
                              for (final index in selected)
                                index == reasons.length - 1
                                    ? _otherController.text.trim()
                                    : reasons[index],
                            ];
                            final remarks = _remarksController.text.trim();
                            Navigator.of(context).pop(
                              CollectionRejectionDecision(
                                reason: reasonParts.join(', '),
                                remarks: remarks.isEmpty ? null : remarks,
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.red500,
                      foregroundColor: AppColors.neutral50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      context.l10n.verificationRejectConfirm,
                      style: AppTextStyles.boldH7_16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    key: const Key('verification-cancel-rejection'),
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.neutral400,
                      side: const BorderSide(color: AppColors.neutral400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      context.l10n.verificationRejectCancel,
                      style: AppTextStyles.boldH7_16,
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
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    key: const Key('verification-reject-back'),
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary500,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SvgPicture.asset(CollectionDetailAssets.back),
    ),
  );
}

class _CollectionNumberCard extends StatelessWidget {
  const _CollectionNumberCard({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [HomeStyles.cardShadow],
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SvgPicture.asset('assets/icons/reject_collection.svg'),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: AppTextStyles.semiboldH8_16.copyWith(
            color: AppColors.neutral900,
          ),
        ),
      ],
    ),
  );
}

class _ReasonOption extends StatelessWidget {
  const _ReasonOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.neutral50,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.red400 : AppColors.cool400,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: selected ? AppColors.red600 : AppColors.neutral50,
                border: Border.all(
                  color: selected ? AppColors.red600 : AppColors.neutral400,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: selected
                  ? SvgPicture.asset('assets/icons/reject_check.svg')
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.regularB7_14.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
