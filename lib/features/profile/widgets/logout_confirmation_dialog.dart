import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

import '../model/logout_data_status.dart';
import 'profile_assets.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({
    super.key,
    this.dataStatus = LogoutDataStatus.pending,
    this.onNo,
    this.onYes,
  });

  final LogoutDataStatus dataStatus;
  final VoidCallback? onNo;
  final VoidCallback? onYes;

  @override
  Widget build(BuildContext context) {
    final hasPendingData = dataStatus == LogoutDataStatus.pending;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: AppColors.neutral50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 335),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                ProfileAssets.logoutDialog,
                width: 57.8123,
                height: 55.5,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  context.l10n.logoutConfirmationTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.boldH6_20.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.logoutConfirmationMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.mediumSH8_14.copyWith(
                  color: AppColors.cool950,
                ),
              ),
              if (hasPendingData) ...[
                const SizedBox(height: 16),
                Container(
                  key: const Key('logout-pending-warning'),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.red50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        ProfileAssets.logoutWarning,
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          context.l10n.logoutUnsyncedTripsPending,
                          style: AppTextStyles.boldH8_14.copyWith(
                            color: AppColors.red600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _LogoutButton(
                      key: const Key('logout-no-button'),
                      label: context.l10n.logoutNo,
                      backgroundColor: AppColors.cool200,
                      foregroundColor: AppColors.cool950,
                      onPressed: onNo ?? () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _LogoutButton(
                      key: const Key('logout-yes-button'),
                      label: context.l10n.logoutYes,
                      backgroundColor: AppColors.red500,
                      foregroundColor: AppColors.neutral50,
                      onPressed: onYes ?? () => Navigator.pop(context),
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
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.boldH7_16,
      ),
    ),
  );
}
