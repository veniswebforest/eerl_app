import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'home_assets.dart';
import 'home_styles.dart';

/// Pending collection drafts section with a "View All" link and draft card.
class CollectionDrafts extends StatelessWidget {
  const CollectionDrafts({
    super.key,
    this.onViewAllTap,
    this.onContinueCollectionTap,
  });

  final VoidCallback? onViewAllTap;
  final VoidCallback? onContinueCollectionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                context.l10n.collectionDrafts,
                style: HomeStyles.sectionTitle,
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              key: const Key('collection-drafts-view-all'),
              onPressed: onViewAllTap,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary500,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                context.l10n.viewAll,
                style: AppTextStyles.boldH7_16.copyWith(
                  color: AppColors.primary500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Draft card
        Container(
          padding: EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [HomeStyles.cardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pending Submission tag
              Text(
                context.l10n.pendingSubmission,
                style: AppTextStyles.semiboldH9_14.copyWith(
                  color: AppColors.yellow600,
                ),
              ),

              // Draft title
              Padding(
                padding: EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Text(
                  context.l10n.draftStationName,
                  style: AppTextStyles.semiboldH7_18.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
              ),

              // Location row
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      HomeAssets.location,
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n.draftLocation,
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.neutral700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Image row
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      HomeAssets.draftWeight,
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '...',
                      style: AppTextStyles.mediumSH8_14.copyWith(
                        color: AppColors.neutral700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Continue Collection button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('continue-draft-collection'),
                  onPressed: onContinueCollectionTap,
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
                  child: Text(context.l10n.continueCollection),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
