import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';

/// Confirmation popup (Deactivate / Reactivate). Resolves to `true` on
/// confirm. Without [cancelLabel] it is a one-button notice ("OK").
Future<bool> showDriverLabourConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? cancelLabel,
  required String confirmLabel,
  required Color confirmColor,
  double confirmRadius = 14,
}) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: title,
    barrierColor: Colors.black.withValues(alpha: .6),
    pageBuilder: (dialogContext, _, _) => Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: const SizedBox.expand(),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 335),
              child: Material(
                color: DriverColors.neutral50,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: DriverTextStyles.bold24.copyWith(
                          color: DriverColors.neutral950,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 247),
                        child: Text(
                          message,
                          textAlign: TextAlign.center,
                          style: DriverTextStyles.medium14.copyWith(
                            color: DriverColors.neutral600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          if (cancelLabel != null) ...[
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: FilledButton(
                                  key: const Key('driver-labour-dialog-cancel'),
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(false),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: DriverColors.cool200,
                                    foregroundColor: DriverColors.neutral950,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: DriverTextStyles.semibold16,
                                  ),
                                  child: Text(cancelLabel),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: FilledButton(
                                key: const Key('driver-labour-dialog-confirm'),
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: confirmColor,
                                  foregroundColor: DriverColors.neutral50,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      confirmRadius,
                                    ),
                                  ),
                                  textStyle: DriverTextStyles.bold16,
                                ),
                                child: Text(confirmLabel),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}
