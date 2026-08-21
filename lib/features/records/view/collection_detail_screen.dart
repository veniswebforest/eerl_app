import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/collection_detail_status.dart';
import '../model/collection_material_model.dart';
import '../widgets/collection_detail_assets.dart';
import '../widgets/collection_detail_cards.dart';
import '../widgets/collection_material_card.dart';

class CollectionDetailScreen extends StatelessWidget {
  const CollectionDetailScreen({
    super.key,
    required this.status,
    required this.onBack,
  });
  final CollectionDetailStatus status;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final materials = <CollectionMaterialModel>[
      CollectionMaterialModel(
        name: context.l10n.collectionDetailPetBottles,
        thumbnail: CollectionDetailAssets.petThumbnail,
        collectionPhoto: CollectionDetailAssets.petCollection,
        verifiedPhoto: CollectionDetailAssets.petVerified,
      ),
      CollectionMaterialModel(
        name: context.l10n.collectionDetailHdpeRigid,
        thumbnail: CollectionDetailAssets.hdpeCollection,
        collectionPhoto: CollectionDetailAssets.hdpeCollection,
        verifiedPhoto: CollectionDetailAssets.hdpeVerified,
      ),
      CollectionMaterialModel(
        name: context.l10n.collectionDetailPpHardPlastics,
        thumbnail: CollectionDetailAssets.ppCollection,
        collectionPhoto: CollectionDetailAssets.ppCollection,
        verifiedPhoto: CollectionDetailAssets.ppVerified,
      ),
    ];
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    key: const Key('collection-detail-back'),
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(7),
                    child: Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary500,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SvgPicture.asset(CollectionDetailAssets.back),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _StatusBanner(status: status),
                  if (status == CollectionDetailStatus.rejected) ...[
                    const SizedBox(height: 10),
                    const _RejectReasonCard(),
                  ],
                  const SizedBox(height: 20),
                  CollectionDetailInfoCard(
                    label: context.l10n.collectionDetailId,
                    value: '#COL-2026-089',
                  ),
                  const SizedBox(height: 10),
                  CollectionDetailInfoCard(
                    label: context.l10n.collectionDetailDateTime,
                    value: context.l10n.collectionDetailDateValue,
                  ),
                  const SizedBox(height: 10),
                  CollectionDetailInfoCard(
                    label: context.l10n.collectionDetailType,
                    value: 'D2D',
                    icon: SvgPicture.asset(
                      CollectionDetailAssets.collectionType,
                      width: 20,
                      height: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CollectionDetailInfoCard(
                    label: context.l10n.collectionDetailAgent,
                    value: context.l10n.drawerUserName,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.neutral50,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x17000000),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.collectionDetailReceivedItems,
                          style: AppTextStyles.mediumSH8_14.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        for (var i = 0; i < materials.length; i++) ...[
                          CollectionMaterialCard(
                            item: materials[i],
                            collectionWeightLabel:
                                context.l10n.collectionDetailCollectionWeight,
                            verifiedWeightLabel:
                                context.l10n.collectionDetailVerifiedWeight,
                            rateLabel: context.l10n.collectionDetailRate,
                            totalLabel:
                                context.l10n.collectionDetailMaterialTotal,
                          ),
                          if (i != materials.length - 1)
                            const Divider(height: 26, color: AppColors.cool400),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.collectionDetailRampPersonPhoto,
                          style: AppTextStyles.mediumSH8_14.copyWith(
                            color: AppColors.neutral950,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.asset(
                            CollectionDetailAssets.rampPerson,
                            width: 116,
                            height: 88,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  CollectionSummaryCard(
                    collectionLabel:
                        context.l10n.collectionDetailTotalCollectionWeight,
                    verifiedLabel:
                        context.l10n.collectionDetailTotalVerifiedWeight,
                    comparisonLabel:
                        context.l10n.collectionDetailWeightComparison,
                    comparisonHint: context.l10n.collectionDetailComparisonHint,
                    totalPriceLabel: context.l10n.collectionDetailTotalPrice,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        CollectionDetailAssets.preview,
                        width: 24,
                        height: 24,
                      ),
                      label: Text(context.l10n.collectionDetailPreviewSlip),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary500,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});
  final CollectionDetailStatus status;
  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      CollectionDetailStatus.pending => AppColors.yellow600,
      CollectionDetailStatus.approved => AppColors.primary500,
      CollectionDetailStatus.rejected => AppColors.red600,
    };
    final background = switch (status) {
      CollectionDetailStatus.pending => AppColors.yellow50,
      CollectionDetailStatus.approved => AppColors.primary50,
      CollectionDetailStatus.rejected => AppColors.red50,
    };
    final label = switch (status) {
      CollectionDetailStatus.pending => context.l10n.collectionDetailPending,
      CollectionDetailStatus.approved => context.l10n.collectionDetailApproved,
      CollectionDetailStatus.rejected =>
        context.l10n.collectionRejectedSupervisor,
    };
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            CollectionDetailAssets.statusPending,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.semiboldH9_14.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _RejectReasonCard extends StatelessWidget {
  const _RejectReasonCard();
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.red500),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.collectionDetailReasonForReject,
          style: AppTextStyles.semiboldH7_18.copyWith(
            color: AppColors.neutral950,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          context.l10n.collectionDetailReasonLabel,
          style: AppTextStyles.semiboldH9_14.copyWith(
            color: AppColors.neutral950,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.collectionDetailReasonValue,
          style: AppTextStyles.mediumSH8_14.copyWith(
            color: AppColors.neutral950,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.collectionDetailRemarksLabel,
          style: AppTextStyles.semiboldH9_14.copyWith(
            color: AppColors.neutral950,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.collectionDetailRemarksValue,
          style: AppTextStyles.mediumSH8_14.copyWith(
            color: AppColors.neutral950,
          ),
        ),
      ],
    ),
  );
}
