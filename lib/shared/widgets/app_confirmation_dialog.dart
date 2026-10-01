import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class AppConfirmationDialog extends StatelessWidget {
  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.confirmColor,
    this.cancelButtonKey,
    this.confirmButtonKey,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final Color confirmColor;
  final Key? cancelButtonKey;
  final Key? confirmButtonKey;

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    required String cancelLabel,
    required String confirmLabel,
    required Color confirmColor,
    Key? dialogKey,
    Key? cancelButtonKey,
    Key? confirmButtonKey,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: title,
      barrierColor: Colors.black.withValues(alpha: .5),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, _, _) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: AppConfirmationDialog(
          key: dialogKey,
          title: title,
          message: message,
          cancelLabel: cancelLabel,
          confirmLabel: confirmLabel,
          confirmColor: confirmColor,
          cancelButtonKey: cancelButtonKey,
          confirmButtonKey: confirmButtonKey,
        ),
      ),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: .96, end: 1).animate(animation),
          child: child,
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 20),
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 335),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.boldH6_20.copyWith(
                color: AppColors.neutral950,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.regularB8_12.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      key: cancelButtonKey,
                      onPressed: () => Navigator.of(context).pop(false),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.cool200,
                        foregroundColor: AppColors.neutral950,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: AppTextStyles.semiboldH9_14,
                      ),
                      child: Text(cancelLabel),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      key: confirmButtonKey,
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: confirmColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: AppTextStyles.semiboldH9_14,
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
  );
}
