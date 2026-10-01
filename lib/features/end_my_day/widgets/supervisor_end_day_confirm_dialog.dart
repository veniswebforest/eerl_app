import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'end_day_assets.dart';

Future<bool?> showSupervisorEndDayConfirmDialog(BuildContext context) =>
    showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: context.l10n.cancel,
      barrierColor: Colors.black.withValues(alpha: .6),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, _, _) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: const _SupervisorEndDayConfirmDialog(),
      ),
      transitionBuilder: (_, animation, _, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: .96, end: 1).animate(animation),
          child: child,
        ),
      ),
    );

class _SupervisorEndDayConfirmDialog extends StatelessWidget {
  const _SupervisorEndDayConfirmDialog();

  @override
  Widget build(BuildContext context) => Dialog(
    key: const Key('supervisor-end-day-dialog'),
    insetPadding: const EdgeInsets.symmetric(horizontal: 20),
    backgroundColor: AppColors.neutral50,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 335),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              EndDayAssets.submitShareIllustration,
              width: 194,
              height: 194,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            Text(
              context.l10n.supervisorEndDayShareTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.boldH5_24.copyWith(
                color: AppColors.neutral950,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.supervisorEndDayShareMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.mediumSH8_14.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      key: const Key('supervisor-end-day-cancel'),
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary500,
                        side: const BorderSide(color: AppColors.primary500),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          context.l10n.cancel,
                          maxLines: 1,
                          style: AppTextStyles.boldH7_16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      key: const Key('supervisor-end-day-share'),
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.primary500,
                        foregroundColor: AppColors.neutral50,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            EndDayAssets.shareWhatsapp,
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                context.l10n.supervisorEndDayShare,
                                maxLines: 1,
                                style: AppTextStyles.boldH7_16,
                              ),
                            ),
                          ),
                        ],
                      ),
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
