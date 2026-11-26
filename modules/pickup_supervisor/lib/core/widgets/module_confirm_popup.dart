import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_button.dart';

/// Popup body: centred title and message, optional [child] (a reason field),
/// then Cancel and a confirm button side by side.
class ModuleConfirmPopup extends StatelessWidget {
  const ModuleConfirmPopup({
    super.key,
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onConfirm,
    this.danger = false,
    this.child,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;

  /// Null keeps the confirm button disabled (reason still empty).
  final VoidCallback? onConfirm;
  final bool danger;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(4),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        if (child != null) ...[const SizedBox(height: 24), child!],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ModuleButton(
                key: const Key('confirm-popup-cancel'),
                label: cancelLabel,
                variant: ModuleButtonVariant.neutral,
                semibold: true,
                height: 52,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Opacity(
                opacity: onConfirm == null ? .5 : 1,
                child: IgnorePointer(
                  ignoring: onConfirm == null,
                  child: ModuleButton(
                    key: const Key('confirm-popup-confirm'),
                    label: confirmLabel,
                    variant: danger
                        ? ModuleButtonVariant.danger
                        : ModuleButtonVariant.primary,
                    semibold: true,
                    height: 52,
                    onPressed: onConfirm ?? () {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// Popup body: green tick, title, message and one neutral button that pops
/// the popup (Request sent, Payment recorded).
class ModuleSuccessPopup extends StatelessWidget {
  const ModuleSuccessPopup({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
  });

  final String title;
  final String message;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(4),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: DriverColors.primary100,
              shape: BoxShape.circle,
            ),
            child: Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: DriverColors.primary500,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/icons/route_actions/check_white.svg',
                package: 'pickup_supervisor',
                width: 34,
                height: 34,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
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
          key: const Key('success-popup-button'),
          label: buttonLabel,
          variant: ModuleButtonVariant.neutral,
          semibold: true,
          height: 52,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
