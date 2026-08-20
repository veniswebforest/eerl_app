import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'home_assets.dart';

/// Top app bar for the home screen.
/// Shows welcome text, date/zone, calendar, and notification icons.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 14),
      child: Row(
        children: [
          // Hamburger menu
          InkWell(
            onTap: () {
              context.go(AppRoutes.profile);

            },
            child: SizedBox(
              width: 28,
              height: 28,
              child: SvgPicture.asset(HomeAssets.menu, width: 28, height: 28),
            ),
          ),
          const SizedBox(width: 16),

          // Welcome text + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.welcomeBack,
                  style: AppTextStyles.semiboldH6_20.copyWith(
                    color: AppColors.primary950,
                  ),
                ),
                Text(
                  context.l10n.homeDateZone,
                  style: AppTextStyles.mediumSH9_12.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),

          // Calendar icon
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.cool50,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                HomeAssets.calendar,
                width: 24,
                height: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Notification icon with red badge
          SvgPicture.asset(HomeAssets.notification, width: 45, height: 45),
        ],
      ),
    );
  }
}
