import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

/// Modal bottom-sheet style confirmation dialog shown before ending the day.
///
/// Shows two states:
///  - [_ConfirmState] — asks the user to confirm they want to end the day.
///  - [_SuccessState] — shows a success message after confirmation.
class EndDayConfirmDialog extends StatefulWidget {
  const EndDayConfirmDialog({super.key, this.onConfirmed});

  /// Called after the user confirms and the success animation completes.
  final VoidCallback? onConfirmed;

  static Future<void> show(BuildContext context, {VoidCallback? onConfirmed}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => EndDayConfirmDialog(onConfirmed: onConfirmed),
    );
  }

  @override
  State<EndDayConfirmDialog> createState() => _EndDayConfirmDialogState();
}

class _EndDayConfirmDialogState extends State<EndDayConfirmDialog>
    with SingleTickerProviderStateMixin {
  bool _confirmed = false;
  late final AnimationController _scaleController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _confirm() {
    setState(() => _confirmed = true);
    _scaleController.forward();
    // Auto-dismiss after success banner is shown
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onConfirmed?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.viewInsetsOf(context),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _confirmed
            ? _SuccessState(key: const ValueKey('success'), scale: _scale)
            : _ConfirmState(
                key: const ValueKey('confirm'),
                onConfirm: _confirm,
                onCancel: () => Navigator.of(context).pop(),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CONFIRM STATE
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmState extends StatelessWidget {
  const _ConfirmState({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Warning icon
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.yellow100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.yellow600,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            l10n.endDayConfirmTitle,
            style: AppTextStyles.semiboldH7_18.copyWith(
              color: AppColors.neutral950,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Message
          Text(
            l10n.endDayConfirmMessage,
            style: AppTextStyles.regularB7_14.copyWith(
              color: AppColors.neutral600,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              key: const Key('end-day-confirm-yes'),
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.endDayConfirmYes,
                style: AppTextStyles.semiboldH9_14,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Cancel / Go Back button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              key: const Key('end-day-confirm-no'),
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.neutral700,
                side: const BorderSide(color: AppColors.neutral200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.endDayConfirmNo,
                style: AppTextStyles.semiboldH9_14.copyWith(
                  color: AppColors.neutral700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SUCCESS STATE
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessState extends StatelessWidget {
  const _SuccessState({super.key, required this.scale});

  final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: scale,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primary100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary500,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.endDaySuccessTitle,
            style: AppTextStyles.semiboldH6_20.copyWith(
              color: AppColors.neutral950,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.endDaySuccessMessage,
            style: AppTextStyles.regularB7_14.copyWith(
              color: AppColors.neutral600,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Loading progress indicator
          const LinearProgressIndicator(
            color: AppColors.primary500,
            backgroundColor: AppColors.primary100,
            minHeight: 4,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ],
      ),
    );
  }
}
