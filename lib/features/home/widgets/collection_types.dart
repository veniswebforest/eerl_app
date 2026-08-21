import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'home_assets.dart';
import 'home_styles.dart';

/// List of available collection types: D2D, MRF Station, Ramp.
class CollectionTypes extends StatelessWidget {
  const CollectionTypes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.collectionTypes, style: HomeStyles.sectionTitle),
        const SizedBox(height: 16),
        CollectionTypeItem(
          iconAsset: HomeAssets.collectionD2d,
          iconColor: AppColors.secondary500,
          iconBg: AppColors.primary100,
          title: context.l10n.d2d,
          subtitle: context.l10n.smcVehicle,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        CollectionTypeItem(
          iconAsset: HomeAssets.collectionMrf,
          iconColor: AppColors.orchid,
          iconBg: AppColors.orchidLight,
          title: context.l10n.mrfStation,
          subtitle: context.l10n.materialRecoveryFacility,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        CollectionTypeItem(
          iconAsset: HomeAssets.collectionRamp,
          iconColor: AppColors.purple,
          iconBg: AppColors.purpleLight,
          title: context.l10n.ramp,
          subtitle: context.l10n.retailDealer,
          onTap: () {},
        ),
      ],
    );
  }
}

/// Single tappable row inside [CollectionTypes].
class CollectionTypeItem extends StatelessWidget {
  const CollectionTypeItem({
    super.key,
    required this.iconAsset,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String iconAsset;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 82),
          child: Container(
            padding: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [HomeStyles.cardShadow],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon bubble
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(iconAsset, width: 24, height: 24),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.semiboldH7_18.copyWith(
                                  color: iconColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.mediumSH8_14.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Green chevron button
                  Container(
                    width: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary500,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        HomeAssets.chevronRight,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
