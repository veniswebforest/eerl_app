import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/features/records/model/collection_material_model.dart';
import 'package:eerl_app/features/records/widgets/collection_detail_assets.dart';
import 'package:eerl_app/features/records/widgets/collection_detail_cards.dart';
import 'package:eerl_app/features/records/widgets/collection_material_card.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import 'package:eerl_app/shared/widgets/app_message_banner.dart';
import '../model/verification_entry.dart';

class VerificationDetailScreen extends StatefulWidget {
  const VerificationDetailScreen({super.key, required this.status});

  final VerificationDetailStatus status;

  @override
  State<VerificationDetailScreen> createState() =>
      _VerificationDetailScreenState();
}

class _VerificationDetailScreenState extends State<VerificationDetailScreen> {
  late VerificationDetailStatus _status = widget.status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final materials = [
      CollectionMaterialModel(
        name: l10n.collectionDetailPetBottles,
        thumbnail: CollectionDetailAssets.petThumbnail,
        collectionPhoto: CollectionDetailAssets.petCollection,
        verifiedPhoto: CollectionDetailAssets.petVerified,
      ),
      CollectionMaterialModel(
        name: l10n.collectionDetailHdpeRigid,
        thumbnail: CollectionDetailAssets.hdpeCollection,
        collectionPhoto: CollectionDetailAssets.hdpeCollection,
        verifiedPhoto: CollectionDetailAssets.hdpeVerified,
      ),
      CollectionMaterialModel(
        name: l10n.collectionDetailPpHardPlastics,
        thumbnail: CollectionDetailAssets.ppCollection,
        collectionPhoto: CollectionDetailAssets.ppCollection,
        verifiedPhoto: CollectionDetailAssets.ppVerified,
      ),
    ];
    final approved = _status == VerificationDetailStatus.approved;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                AppScreenHeaderMetrics.topInset,
                20,
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppScreenHeader(
                    leading: _BackButton(
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  if (_status != VerificationDetailStatus.pending) ...[
                    const SizedBox(height: 24),
                    _VerificationResultBanner(status: _status),
                    if (_status == VerificationDetailStatus.rejected) ...[
                      const SizedBox(height: 12),
                      const _RejectReasonCard(),
                    ],
                  ],
                  const SizedBox(height: 24),
                  CollectionDetailInfoCard(
                    label: l10n.collectionDetailId,
                    value: l10n.verificationDetailCollectionIdValue,
                  ),
                  if (_status != VerificationDetailStatus.rejected) ...[
                    const SizedBox(height: 12),
                    CollectionDetailInfoCard(
                      label: l10n.verificationDetailCollectionCenter,
                      value: l10n.verificationSuratSouth,
                    ),
                  ],
                  const SizedBox(height: 12),
                  CollectionDetailInfoCard(
                    label: l10n.collectionDetailDateTime,
                    value: l10n.collectionDetailDateValue,
                  ),
                  const SizedBox(height: 12),
                  CollectionDetailInfoCard(
                    label: l10n.collectionDetailType,
                    value: l10n.verificationFilterD2d,
                    icon: SvgPicture.asset(
                      CollectionDetailAssets.collectionType,
                      width: 20,
                      height: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CollectionDetailInfoCard(
                    label: l10n.verificationDetailGivenBy,
                    value: l10n.verificationDetailGivenByValue,
                  ),
                  const SizedBox(height: 12),
                  CollectionDetailInfoCard(
                    label: l10n.verificationDetailVehicleNumber,
                    value: l10n.verificationDetailVehicleValue,
                  ),
                  const SizedBox(height: 12),
                  CollectionDetailInfoCard(
                    label: l10n.collectionDetailAgent,
                    value: l10n.verificationRahulPatel,
                  ),
                  const SizedBox(height: 12),
                  CollectionDetailInfoCard(
                    label: l10n.verificationDetailPaymentType,
                    value: l10n.verificationDetailCash,
                  ),
                  const SizedBox(height: 12),
                  _VehiclePhotoCard(title: l10n.verificationDetailVehiclePhoto),
                  const SizedBox(height: 12),
                  _ReceivedItemsCard(
                    materials: materials,
                    collectionLabel: approved
                        ? l10n.verificationDetailCollectedWeight
                        : l10n.verificationDetailCollected,
                    verifiedLabel: approved
                        ? l10n.verificationDetailVerifiedWeight
                        : l10n.verificationDetailVerified,
                  ),
                  const SizedBox(height: 12),
                  CollectionSummaryCard(
                    collectionLabel: approved
                        ? l10n.collectionDetailTotalCollectionWeight
                        : l10n.verificationDetailTotalCollected,
                    verifiedLabel: approved
                        ? l10n.collectionDetailTotalVerifiedWeight
                        : l10n.verificationDetailTotalVerified,
                    comparisonLabel: l10n.verificationDetailDifference,
                    comparisonHint: l10n.collectionDetailComparisonHint,
                    totalPriceLabel: l10n.collectionDetailTotalPrice,
                    collectionValue: l10n.verificationDetailCollectedTotalValue,
                    verifiedValue: l10n.verificationDetailVerifiedTotalValue,
                    comparisonValue: l10n.verificationDetailDifferenceValue,
                    totalPriceValue: l10n.verificationDetailTotalPriceValue,
                  ),
                  if (_status == VerificationDetailStatus.pending) ...[
                    const SizedBox(height: 32),
                    _DecisionButtons(
                      rejectLabel: l10n.verificationDetailReject,
                      approveLabel: l10n.verificationDetailApprove,
                      onReject: _reject,
                      onApprove: () => setState(
                        () => _status = VerificationDetailStatus.approved,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _reject() async {
    final rejected = await context.push<bool>(AppRoutes.rejectCollection);
    if (mounted && rejected == true) {
      setState(() => _status = VerificationDetailStatus.rejected);
    }
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    key: const Key('verification-detail-back'),
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary500,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SvgPicture.asset(CollectionDetailAssets.back),
    ),
  );
}

class _VerificationResultBanner extends StatelessWidget {
  const _VerificationResultBanner({required this.status});

  final VerificationDetailStatus status;

  @override
  Widget build(BuildContext context) {
    final approved = status == VerificationDetailStatus.approved;
    final color = approved ? AppColors.primary500 : AppColors.red600;
    return AppMessageBanner(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      borderRadius: 10,
      title: approved
          ? context.l10n.collectionDetailApproved
          : context.l10n.verificationRejected,
      color: color,
      backgroundColor: approved ? AppColors.primary50 : AppColors.red50,
      titleStyle: AppTextStyles.semiboldH9_14.copyWith(color: color),
      icon: SvgPicture.asset(
        approved
            ? 'assets/icons/wallet/status_verified.svg'
            : 'assets/icons/wallet/status_flagged.svg',
        width: 20,
        height: 20,
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
      border: Border.all(color: AppColors.red500),
      borderRadius: BorderRadius.circular(10),
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
        const Divider(height: 18, color: AppColors.cool400),
        Text(
          context.l10n.collectionDetailReasonLabel,
          style: AppTextStyles.semiboldH9_14,
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.collectionDetailReasonValue,
          style: AppTextStyles.mediumSH8_14,
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.collectionDetailRemarksLabel,
          style: AppTextStyles.semiboldH9_14,
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.collectionDetailRemarksValue,
          style: AppTextStyles.mediumSH8_14,
        ),
      ],
    ),
  );
}

class _VehiclePhotoCard extends StatelessWidget {
  const _VehiclePhotoCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
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
          title,
          style: AppTextStyles.semiboldH8_16.copyWith(color: AppColors.cool600),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            'assets/images/verification/vehicle.png',
            width: 109,
            height: 70,
            fit: BoxFit.cover,
          ),
        ),
      ],
    ),
  );
}

class _ReceivedItemsCard extends StatelessWidget {
  const _ReceivedItemsCard({
    required this.materials,
    required this.collectionLabel,
    required this.verifiedLabel,
  });

  final List<CollectionMaterialModel> materials;
  final String collectionLabel;
  final String verifiedLabel;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
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
        for (var index = 0; index < materials.length; index++) ...[
          CollectionMaterialCard(
            item: materials[index],
            collectionWeightLabel: collectionLabel,
            verifiedWeightLabel: verifiedLabel,
            rateLabel: context.l10n.collectionDetailRate,
            totalLabel: context.l10n.collectionDetailMaterialTotal,
            weightValue: context.l10n.verificationDetailWeightValue,
          ),
          if (index != materials.length - 1)
            const Divider(height: 26, color: AppColors.cool400),
        ],
      ],
    ),
  );
}

class _DecisionButtons extends StatelessWidget {
  const _DecisionButtons({
    required this.rejectLabel,
    required this.approveLabel,
    required this.onReject,
    required this.onApprove,
  });

  final String rejectLabel;
  final String approveLabel;
  final VoidCallback onReject;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          key: const Key('verification-reject-button'),
          onPressed: onReject,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            foregroundColor: AppColors.red600,
            side: const BorderSide(color: AppColors.red600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(rejectLabel, style: AppTextStyles.boldH7_16),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton(
          key: const Key('verification-approve-button'),
          onPressed: onApprove,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            elevation: 0,
            backgroundColor: AppColors.primary500,
            foregroundColor: AppColors.neutral50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(approveLabel, style: AppTextStyles.boldH7_16),
        ),
      ),
    ],
  );
}
