import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';

typedef TransferRejection = ({List<String> reasons, String? remarks});
typedef TransferRejectConfirmHandler =
    Future<void> Function(TransferRejection rejection);

class SupervisorTransferRejectScreen extends StatefulWidget {
  const SupervisorTransferRejectScreen({
    super.key,
    required this.onBack,
    required this.onConfirm,
  });

  final VoidCallback onBack;
  final TransferRejectConfirmHandler onConfirm;

  @override
  State<SupervisorTransferRejectScreen> createState() =>
      _SupervisorTransferRejectScreenState();
}

class _SupervisorTransferRejectScreenState
    extends State<SupervisorTransferRejectScreen> {
  static const _reasons = <String>[
    'No Vehicle Available',
    'Insufficient Yard Capacity',
    'Incorrect Material',
    'Other',
  ];

  final Set<int> _selected = <int>{};
  final TextEditingController _remarksController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final indexes = _selected.toList()..sort();
    final remarks = _remarksController.text.trim();
    setState(() => _submitting = true);
    try {
      await widget.onConfirm((
        reasons: [for (final index in indexes) _reasons[index]],
        remarks: remarks.isEmpty ? null : remarks,
      ));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    appBar: CustomAppBar(
      title: 'Reject transfer',
      onBackTap: widget.onBack,
      backIconAsset: 'assets/icons/records/back.svg',
      titleStyle: AppTextStyles.semiboldH6_20,
      backButtonRadius: 12,
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            key: const Key('supervisor-transfer-confirm-rejection'),
            onPressed: _selected.isEmpty || _submitting ? null : _confirm,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              disabledBackgroundColor: AppColors.red200,
              backgroundColor: AppColors.red500,
              foregroundColor: AppColors.neutral50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Confirm Rejection',
                    style: AppTextStyles.boldH7_16,
                  ),
          ),
        ),
      ),
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Reason for Reject '),
                    TextSpan(
                      text: '*',
                      style: AppTextStyles.mediumSH8_14.copyWith(
                        color: AppColors.red600,
                      ),
                    ),
                  ],
                ),
                style: AppTextStyles.mediumSH8_14.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
              const SizedBox(height: 8),
              for (var index = 0; index < _reasons.length; index++) ...[
                _TransferRejectReasonOption(
                  key: ValueKey('supervisor-transfer-reject-reason-$index'),
                  label: _reasons[index],
                  selected: _selected.contains(index),
                  onTap: () => setState(() {
                    if (!_selected.remove(index)) _selected.add(index);
                  }),
                ),
                if (index != _reasons.length - 1) const SizedBox(height: 8),
              ],
              const SizedBox(height: 24),
              Text(
                'Remarks',
                style: AppTextStyles.mediumSH8_14.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('supervisor-transfer-reject-remarks'),
                controller: _remarksController,
                minLines: 5,
                maxLines: 5,
                maxLength: 1000,
                style: AppTextStyles.regularB7_14.copyWith(
                  color: AppColors.neutral950,
                ),
                decoration: InputDecoration(
                  counterText: 'Max 1000 Characters',
                  counterStyle: AppTextStyles.regularB8_12.copyWith(
                    color: AppColors.neutral400,
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
            ],
          ),
        ),
      ),
    ),
  );
}

class _TransferRejectReasonOption extends StatelessWidget {
  const _TransferRejectReasonOption({
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
