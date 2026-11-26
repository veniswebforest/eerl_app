import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_button.dart';

const _package = 'pickup_supervisor';
const _iconRoot = 'assets/icons/supervisor/approvals';
const approvalSuccessImage =
    'assets/images/supervisor/approvals/approved_success.gif';

enum ApprovalStatus { approved, declined }

/// Approved / Declined pill shown on "Done" requests.
class ApprovalStatusTag extends StatelessWidget {
  const ApprovalStatusTag({
    super.key,
    required this.status,
    required this.label,
  });

  final ApprovalStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final approved = status == ApprovalStatus.approved;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: approved ? DriverColors.primary50 : DriverColors.red100,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            '$_iconRoot/${approved ? 'approved' : 'declined'}.svg',
            package: _package,
            width: 14,
            height: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: DriverTextStyles.semibold12.copyWith(
              color: approved ? DriverColors.primary500 : DriverColors.red600,
            ),
          ),
        ],
      ),
    );
  }
}

/// One approval request: title (+ optional status tag), source, detail, time
/// and optional Decline / Approve actions.
class ApprovalRequestCard extends StatelessWidget {
  const ApprovalRequestCard({
    super.key,
    required this.title,
    required this.source,
    required this.detail,
    required this.time,
    this.tag,
    this.declineLabel,
    this.approveLabel,
    this.onDecline,
    this.onApprove,
  });

  final String title;
  final String source;
  final String detail;
  final String time;
  final Widget? tag;
  final String? declineLabel;
  final String? approveLabel;
  final VoidCallback? onDecline;
  final VoidCallback? onApprove;

  @override
  Widget build(BuildContext context) {
    final hasActions = declineLabel != null && approveLabel != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DriverColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: DriverColors.shadow,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: DriverTextStyles.semibold16.copyWith(
                    color: DriverColors.neutral950,
                    height: 1.37,
                  ),
                ),
              ),
              if (tag != null) ...[const SizedBox(width: 8), tag!],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            source,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral900,
              height: 1.37,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: DriverTextStyles.medium12.copyWith(
              color: DriverColors.neutral600,
              height: 16 / 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: DriverTextStyles.medium12.copyWith(
              color: DriverColors.mutedText,
              height: 16 / 12,
            ),
          ),
          if (hasActions) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: ModuleButton(
                    key: const Key('approval-decline'),
                    label: declineLabel!,
                    variant: ModuleButtonVariant.outline,
                    height: 44,
                    radius: 10,
                    onPressed: onDecline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModuleButton(
                    key: const Key('approval-approve'),
                    label: approveLabel!,
                    height: 44,
                    radius: 10,
                    onPressed: onApprove,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Body of the "Decline the …" bottom sheet.
class ApprovalDeclineSheet extends StatefulWidget {
  const ApprovalDeclineSheet({
    super.key,
    required this.title,
    required this.message,
    required this.initialReply,
    required this.hint,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String title;
  final String message;
  final String initialReply;
  final String hint;
  final String confirmLabel;
  final String cancelLabel;

  @override
  State<ApprovalDeclineSheet> createState() => _ApprovalDeclineSheetState();
}

class _ApprovalDeclineSheetState extends State<ApprovalDeclineSheet> {
  late final _reply = TextEditingController(text: widget.initialReply);

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: DriverTextStyles.semibold18.copyWith(
            color: DriverColors.neutral950,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.message,
          style: DriverTextStyles.medium12.copyWith(
            color: DriverColors.neutral600,
            height: 16 / 12,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 96,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: DriverColors.neutral50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: DriverColors.cool400),
          ),
          child: TextField(
            key: const Key('approval-decline-reply'),
            controller: _reply,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.sentences,
            expands: true,
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
            style: DriverTextStyles.regular14.copyWith(
              color: DriverColors.neutral950,
              height: 22 / 14,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: DriverTextStyles.regular14.copyWith(
                color: DriverColors.neutral500,
              ),
              isDense: true,
              filled: false,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ModuleButton(
          key: const Key('approval-decline-confirm'),
          label: widget.confirmLabel,
          variant: ModuleButtonVariant.danger,
          height: 52,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: 12),
        ModuleButton(
          key: const Key('approval-decline-cancel'),
          label: widget.cancelLabel,
          variant: ModuleButtonVariant.neutral,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}

/// Body of the "… approved" popup: animated success image, title, message
/// and two buttons.
class ApprovalSuccessPopup extends StatelessWidget {
  const ApprovalSuccessPopup({
    super.key,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;

  /// Optional second (neutral) button.
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          approvalSuccessImage,
          package: _package,
          width: 122,
          height: 122,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: DriverTextStyles.bold24.copyWith(
            color: DriverColors.neutral950,
            height: 28 / 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: DriverTextStyles.medium14.copyWith(
            color: DriverColors.neutral600,
            height: 18 / 14,
          ),
        ),
        const SizedBox(height: 24),
        ModuleButton(
          key: const Key('approval-success-back'),
          label: primaryLabel,
          semibold: true,
          onPressed: onPrimary,
        ),
        if (secondaryLabel != null) ...[
          const SizedBox(height: 12),
          ModuleButton(
            key: const Key('approval-success-home'),
            label: secondaryLabel!,
            variant: ModuleButtonVariant.neutral,
            onPressed: onSecondary ?? () {},
          ),
        ],
      ],
    );
  }
}
