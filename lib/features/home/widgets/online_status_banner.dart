import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'home_assets.dart';
import 'home_styles.dart';

/// Green banner showing connectivity status and pending sync count.
class OnlineStatusBanner extends StatelessWidget {
  const OnlineStatusBanner({
    super.key,
    this.onSyncNowTap,
    this.subtitle,
    this.pendingCount = 0,
    this.isOffline = false,
  });

  final VoidCallback? onSyncNowTap;
  final String? subtitle;
  final int pendingCount;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 76),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [HomeStyles.cardShadow],
        ),
        child: Row(
          children: [
            // Wifi icon
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isOffline ? AppColors.red50 : AppColors.primary50,
                shape: BoxShape.circle,
              ),
              child: isOffline
                  ? const Icon(
                      Icons.wifi_off_rounded,
                      color: AppColors.red600,
                      size: 24,
                    )
                  : SvgPicture.asset(HomeAssets.online, width: 24, height: 24),
            ),
            const SizedBox(width: 12),

            // Status text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOffline
                        ? context.l10n.offlineStatus
                        : context.l10n.onlineStatus,
                    style: AppTextStyles.semiboldH8_16.copyWith(
                      color: isOffline
                          ? AppColors.red600
                          : AppColors.primary500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isOffline
                        ? pendingCount > 0
                              ? context.l10n.syncPendingItems(pendingCount)
                              : context.l10n.offlineStatusSubtitle
                        : subtitle ??
                              (pendingCount > 0
                                  ? context.l10n.syncPendingItems(pendingCount)
                                  : context.l10n.syncAlreadySyncedTitle),
                    style: AppTextStyles.mediumSH8_14.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),

            // No outbox rows means there is nothing to upload, so the action
            // is removed rather than displayed as a disabled button.
            if (!isOffline && onSyncNowTap != null)
              ElevatedButton(
                key: const Key('home-sync-now-button'),
                onPressed: onSyncNowTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  foregroundColor: AppColors.neutral50,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  minimumSize: const Size(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  textStyle: AppTextStyles.boldH9_12,
                ),
                child: Text(context.l10n.syncNow),
              ),
          ],
        ),
      ),
    );
  }
}
