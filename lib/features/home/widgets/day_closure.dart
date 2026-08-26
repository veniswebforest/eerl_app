import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'home_assets.dart';
import 'home_styles.dart';

/// Day Closure section with End My Day card and button.
class DayClosure extends StatelessWidget {
  const DayClosure({super.key, this.onEndMyDayTap});

  final VoidCallback? onEndMyDayTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.dayClosure, style: HomeStyles.sectionTitle),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [HomeStyles.cardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + description row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      // color: AppColors.primary100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SvgPicture.asset(
                      HomeAssets.dayClosure,
                      width: 24,
                      height: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.endMyDay,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.semiboldH7_18.copyWith(
                        color: AppColors.neutral950,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Text(
                context.l10n.reviewCloseDay,
                style: AppTextStyles.mediumSH8_14.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 12),

              // End My Day button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('home-end-my-day-button'),
                  onPressed: onEndMyDayTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary500,
                    foregroundColor: AppColors.neutral50,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    textStyle: AppTextStyles.boldH7_16,
                  ),
                  child: Text(context.l10n.endMyDay),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
