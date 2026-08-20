import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'home_assets.dart';

/// Dropdown card showing the currently selected EERL zone.
class ZoneSelector extends StatelessWidget {
  const ZoneSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary500),
        ),
        child: Row(
          children: [
            // Location icon
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary100,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(HomeAssets.zone, width: 24, height: 24),
            ),
            const SizedBox(width: 10),

            // Zone label
            Expanded(
              child: Text(
                context.l10n.zoneName,
                style: AppTextStyles.semiboldH9_14.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
            ),

            // Dropdown arrow
            SvgPicture.asset(HomeAssets.chevronDown, width: 24, height: 24),
          ],
        ),
      ),
    );
  }
}
