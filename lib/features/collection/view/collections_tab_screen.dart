import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import '../model/recent_collection_item_model.dart';
import '../widgets/collection_assets.dart';
import '../widgets/recent_collection_card.dart';
import '../widgets/start_collection_card.dart';

class CollectionsTabScreen extends StatelessWidget {
  const CollectionsTabScreen({
    super.key,
    this.onAddCollection,
    this.onCollectionTap,
    this.onViewAllTap,
    this.onNotificationTap,
  });
  final VoidCallback? onAddCollection;
  final ValueChanged<RecentCollectionStatus>? onCollectionTap;
  final VoidCallback? onViewAllTap;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final recentCollections = [
      RecentCollectionItemModel(
        title: l10n.d2d,
        receiptNumber: l10n.collectionReceipt248,
        weight: l10n.collectionWeight245,
        statusLabel: l10n.expensePendingSupervisor,
        status: RecentCollectionStatus.pending,
      ),
      RecentCollectionItemModel(
        title: l10n.mrfStation,
        receiptNumber: l10n.collectionReceipt247,
        weight: l10n.collectionWeight115,
        statusLabel: l10n.expenseVerified,
        status: RecentCollectionStatus.verified,
      ),
      RecentCollectionItemModel(
        title: l10n.ramp,
        receiptNumber: l10n.collectionReceipt246,
        weight: l10n.collectionWeight320,
        statusLabel: l10n.collectionRejectedSupervisor,
        status: RecentCollectionStatus.rejected,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            AppScreenHeaderMetrics.topInset,
            20,
            120,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppScreenHeader(
                      title: l10n.collections,
                      subtitle: l10n.startYourCollections,
                      actions: [
                        InkWell(
                          key: const Key('collections-notification-button'),
                          onTap: onNotificationTap,
                          borderRadius: BorderRadius.circular(24),
                          child: SvgPicture.asset(
                            CollectionAssets.notification,
                            width: 45,
                            height: 45,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    StartCollectionCard(
                      title: l10n.startCollection,
                      description: l10n.recordWeightProof,
                      buttonLabel: l10n.addCollection,
                      onPressed: onAddCollection ?? () {},
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.recentCollections,
                            style: AppTextStyles.semiboldH7_18.copyWith(
                              color: AppColors.neutral950,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          key: const Key('recent-collections-view-all'),
                          onPressed: onViewAllTap,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary500,
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            l10n.viewAll,
                            style: AppTextStyles.boldH7_16.copyWith(
                              color: AppColors.primary500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(recentCollections.length, (index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == recentCollections.length - 1
                              ? 0
                              : 16,
                        ),
                        child: RecentCollectionCard(
                          key: Key('recent-collection-$index'),
                          item: recentCollections[index],
                          onTap: () => onCollectionTap?.call(
                            recentCollections[index].status,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
