import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'home_assets.dart';
import 'home_styles.dart';

/// Green banner showing connectivity status and pending sync count.
class OnlineStatusBanner extends StatelessWidget {
  const OnlineStatusBanner({super.key});

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
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(HomeAssets.online, width: 24, height: 24),
            ),
            const SizedBox(width: 12),

            // Status text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.onlineStatus,
                    style: AppTextStyles.semiboldH8_16.copyWith(
                      color: AppColors.primary500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    context.l10n.pendingCollections(3),
                    style: AppTextStyles.mediumSH8_14.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),

            // Sync Now button
            ElevatedButton(
              onPressed: () {},
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
