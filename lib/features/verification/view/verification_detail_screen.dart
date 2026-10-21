import 'dart:async';
import 'package:flutter/material.dart';

import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';
import 'package:eerl_app/features/records/widgets/collection_detail_assets.dart';
import 'package:eerl_app/features/records/widgets/collection_detail_cards.dart';
import 'package:eerl_app/features/records/widgets/collection_material_card.dart';
import 'package:eerl_app/features/verification/model/verification_entry.dart';
import 'package:eerl_app/features/verification/view/reject_collection_screen.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import 'package:eerl_app/shared/widgets/cached_app_image.dart';

class VerificationDetailScreen extends StatefulWidget {
  const VerificationDetailScreen({
    super.key,
    required this.collectionId,
    this.initialStatus,
  });

  final String collectionId;
  final VerificationDetailStatus? initialStatus;

  @override
  State<VerificationDetailScreen> createState() => _State();
}

class _State extends State<VerificationDetailScreen> {
  late final LocalQueryController<
    ({CollectionModel? collection, List<CollectionItemModel> items})
  >
  controller;
  VerificationDetailStatus? statusOverride;
  bool reviewing = false;

  @override
  void initState() {
    super.initState();
    statusOverride = widget.initialStatus;
    controller = LocalQueryController(() async {
      final repository = EerlLocalRepository.instance;
      return (
        collection: await repository.getCollection(widget.collectionId),
        items: await repository.getCollectionItems(widget.collectionId),
      );
    })..load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    body: SafeArea(
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          if (controller.isLoading && !controller.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = _Data.fromLocal(
            context,
            controller.data?.collection,
            controller.data?.items ?? const [],
          );
          final status = statusOverride ?? data.status;
          return Stack(
            children: [
              _Content(data: data, status: status),
              if (status == VerificationDetailStatus.pending)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _Actions(
                    saving: reviewing,
                    onReject: reviewing
                        ? null
                        : () => _reject(data.collectionNumber),
                    onApprove: reviewing ? null : _approve,
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );

  Future<void> _approve() => _saveReview(approved: true);

  Future<void> _reject(String collectionNumber) async {
    final decision = await context.push<CollectionRejectionDecision>(
      AppRoutes.rejectCollection,
      extra: collectionNumber,
    );
    if (decision == null || !mounted) return;
    await _saveReview(
      approved: false,
      reason: decision.reason,
      remarks: decision.remarks,
    );
  }

  Future<void> _saveReview({
    required bool approved,
    String? reason,
    String? remarks,
  }) async {
    if (reviewing) return;
    setState(() => reviewing = true);
    try {
      final repository = EerlLocalRepository.instance;
      if (approved) {
        await repository.approveCollection(widget.collectionId);
      } else {
        await repository.rejectCollection(
          widget.collectionId,
          reason!,
          remarks: remarks,
        );
      }
      if (!mounted) return;
      setState(() {
        statusOverride = approved
            ? VerificationDetailStatus.approved
            : VerificationDetailStatus.rejected;
      });
      unawaited(BootstrapSyncService.instance.triggerAfterLocalMutation());
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Collection review was not saved: $error')),
      );
    } finally {
      if (mounted) setState(() => reviewing = false);
    }
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.data, required this.status});
  final _Data data;
  final VerificationDetailStatus status;

  @override
  Widget build(BuildContext context) {
    final rejected = status == VerificationDetailStatus.rejected;
    final approved = status == VerificationDetailStatus.approved;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        AppScreenHeaderMetrics.topInset,
        20,
        status == VerificationDetailStatus.pending ? 104 : 24,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppScreenHeader(
                leading: _BackButton(
                  onTap: () => Navigator.of(context).maybePop(),
                ),
              ),
              const SizedBox(height: 20),
              if (approved) ...[
                _Banner(
                  text: context.l10n.collectionDetailApproved,
                  color: AppColors.primary500,
                  background: AppColors.primary100,
                  icon: Icons.verified_outlined,
                ),
                const SizedBox(height: 12),
              ],
              if (rejected) ...[
                _Banner(
                  text: context.l10n.verificationRejected,
                  color: AppColors.red600,
                  background: AppColors.red100,
                  icon: Icons.cancel_outlined,
                ),
                const SizedBox(height: 12),
                VerificationRejectReasonCard(
                  reason: data.rejectionReason,
                  remarks: data.rejectionRemarks,
                ),
                const SizedBox(height: 12),
              ],
              CollectionDetailInfoCard(
                label: context.l10n.collectionDetailId,
                value: data.collectionNumber,
              ),
              const SizedBox(height: 10),
              CollectionDetailInfoCard(
                label: context.l10n.verificationDetailCollectionCenter,
                value: data.center,
              ),
              const SizedBox(height: 10),
              CollectionDetailInfoCard(
                label: context.l10n.collectionDetailDateTime,
                value: data.date,
              ),
              const SizedBox(height: 10),
              CollectionDetailInfoCard(
                label: context.l10n.collectionDetailType,
                value: data.channel,
                icon: SvgPicture.asset(
                  CollectionDetailAssets.collectionType,
                  width: 22,
                  height: 22,
                ),
              ),
              const SizedBox(height: 10),
              CollectionDetailInfoCard(
                label: context.l10n.verificationDetailGivenBy,
                value: data.givenBy,
              ),
              const SizedBox(height: 10),
              CollectionDetailInfoCard(
                label: context.l10n.verificationDetailVehicleNumber,
                value: data.vehicle,
              ),
              const SizedBox(height: 10),
              CollectionDetailInfoCard(
                label: context.l10n.collectionDetailAgent,
                value: data.agent,
              ),
              const SizedBox(height: 10),
              CollectionDetailInfoCard(
                label: context.l10n.verificationDetailPaymentType,
                value: data.payment,
              ),
              const SizedBox(height: 10),
              if (data.vehiclePhoto != null) ...[
                _VehiclePhoto(path: data.vehiclePhoto!),
                const SizedBox(height: 12),
              ],
              Container(
                padding: const EdgeInsets.all(14),
                decoration: _decoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.collectionDetailReceivedItems,
                      style: AppTextStyles.mediumSH8_14.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (var index = 0; index < data.items.length; index++) ...[
                      CollectionMaterialCard(
                        item: data.items[index],
                        thumbnailPath:
                            data.items[index].itemImageUrl?.trim().isNotEmpty ==
                                true
                            ? data.items[index].itemImageUrl
                            : _fallbackItemThumbnail(index),
                        collectionWeightLabel: approved || rejected
                            ? context.l10n.verificationDetailCollectedWeight
                            : context.l10n.verificationDetailCollected,
                        verifiedWeightLabel: approved || rejected
                            ? context.l10n.verificationDetailVerifiedWeight
                            : context.l10n.verificationDetailVerified,
                        rateLabel: context.l10n.collectionDetailRate,
                        totalLabel: context.l10n.collectionDetailMaterialTotal,
                        matchSummaryDesign: true,
                      ),
                      if (index != data.items.length - 1)
                        const Divider(height: 28, color: AppColors.cool300),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CollectionSummaryCard(
                collectionLabel: context.l10n.verificationDetailTotalCollected,
                verifiedLabel: context.l10n.verificationDetailTotalVerified,
                comparisonLabel: context.l10n.verificationDetailDifference,
                comparisonHint: context.l10n.collectionDetailComparisonHint,
                totalPriceLabel: context.l10n.collectionDetailTotalPrice,
                collectionValue: '${data.collected.toStringAsFixed(2)} KG',
                verifiedValue: '${data.verified.toStringAsFixed(2)} KG',
                comparisonValue:
                    '${(data.verified - data.collected).toStringAsFixed(2)} KG',
                totalPriceValue:
                    '₹${NumberFormat('#,##0.00').format(data.price)}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    key: const Key('verification-detail-back'),
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary500,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SvgPicture.asset(CollectionDetailAssets.back),
    ),
  );
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.text,
    required this.color,
    required this.background,
    required this.icon,
  });
  final String text;
  final Color color;
  final Color background;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: background,
      border: Border.all(color: color.withValues(alpha: 0.45)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Text(text, style: AppTextStyles.boldH8_14.copyWith(color: color)),
      ],
    ),
  );
}

@visibleForTesting
class VerificationRejectReasonCard extends StatelessWidget {
  const VerificationRejectReasonCard({
    super.key,
    required this.reason,
    this.remarks,
  });
  final String reason;
  final String? remarks;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.red50,
      border: Border.all(color: AppColors.red400),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.collectionDetailReasonForReject,
          style: AppTextStyles.boldH8_14.copyWith(color: AppColors.red600),
        ),
        const SizedBox(height: 10),
        Text('${context.l10n.collectionDetailReasonLabel}:'),
        const SizedBox(height: 3),
        Text(
          reason.isEmpty ? '-' : reason,
          key: const Key('verification-rejection-reason-value'),
          style: AppTextStyles.semiboldH8_16,
        ),
        if (remarks?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 10),
          Text('${context.l10n.verificationRejectRemarksLabel}:'),
          const SizedBox(height: 3),
          Text(remarks!.trim(), style: AppTextStyles.mediumSH8_14),
        ],
      ],
    ),
  );
}

class _VehiclePhoto extends StatelessWidget {
  const _VehiclePhoto({required this.path});
  final String path;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: _decoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.verificationDetailVehiclePhoto,
          style: AppTextStyles.mediumSH9_12.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 109,
            height: 70,
            child: CachedAppImage(source: path, fit: BoxFit.cover),
          ),
        ),
      ],
    ),
  );
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.onReject,
    required this.onApprove,
    required this.saving,
  });
  final VoidCallback? onReject;
  final VoidCallback? onApprove;
  final bool saving;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
    decoration: const BoxDecoration(
      color: AppColors.neutral50,
      boxShadow: [HomeStyles.cardShadow],
    ),
    child: Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              key: const Key('verification-reject-button'),
              onPressed: onReject,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.red600,
                side: const BorderSide(color: AppColors.red600),
              ),
              child: Text(context.l10n.verificationDetailReject),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              key: const Key('verification-approve-button'),
              onPressed: onApprove,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary500,
                foregroundColor: AppColors.neutral50,
              ),
              child: saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.neutral50,
                      ),
                    )
                  : Text(context.l10n.verificationDetailApprove),
            ),
          ),
        ),
      ],
    ),
  );
}

class _Data {
  const _Data({
    required this.collectionNumber,
    required this.center,
    required this.date,
    required this.channel,
    required this.givenBy,
    required this.vehicle,
    required this.agent,
    required this.payment,
    required this.vehiclePhoto,
    required this.items,
    required this.collected,
    required this.verified,
    required this.price,
    required this.status,
    required this.rejectionReason,
    required this.rejectionRemarks,
  });
  final String collectionNumber;
  final String center;
  final String date;
  final String channel;
  final String givenBy;
  final String vehicle;
  final String agent;
  final String payment;
  final String? vehiclePhoto;
  final List<CollectionItemModel> items;
  final double collected;
  final double verified;
  final double price;
  final VerificationDetailStatus status;
  final String rejectionReason;
  final String rejectionRemarks;

  factory _Data.fromLocal(
    BuildContext context,
    CollectionModel? collection,
    List<CollectionItemModel> localItems,
  ) {
    final items = localItems;
    final collected = items.fold<double>(0, (sum, item) => sum + item.qty);
    final verified = items.fold<double>(
      0,
      (sum, item) => sum + (item.verifiedQty ?? item.qty),
    );
    final normalized = collection?.status.toUpperCase();
    final status = normalized == 'REJECTED'
        ? VerificationDetailStatus.rejected
        : const {'APPROVED', 'VERIFIED'}.contains(normalized)
        ? VerificationDetailStatus.approved
        : VerificationDetailStatus.pending;
    final parsed = DateTime.tryParse(
      collection?.collectedAt ?? collection?.updatedAt ?? '',
    )?.toLocal();
    return _Data(
      collectionNumber:
          collection?.slipNumber ??
          context.l10n.verificationDetailCollectionIdValue,
      center: collection?.centerName ?? context.l10n.verificationSuratSouth,
      date: parsed == null
          ? context.l10n.collectionDetailDateValue
          : DateFormat('dd MMM yyyy, hh:mm a').format(parsed),
      channel: collection?.channel ?? context.l10n.verificationFilterD2d,
      givenBy:
          collection?.givenByName ??
          context.l10n.verificationDetailGivenByValue,
      vehicle:
          collection?.vehicleId ?? context.l10n.verificationDetailVehicleValue,
      agent: collection?.agentName ?? context.l10n.verificationRahulPatel,
      payment: collection?.paidBy ?? context.l10n.verificationDetailCash,
      vehiclePhoto: collection?.handoverPhotoUrls.firstOrNull,
      items: items,
      collected: collection == null || collection.totalQty == 0
          ? collected
          : collection.totalQty,
      verified: verified,
      price:
          collection?.totalAmount ??
          items.fold<double>(0, (sum, item) => sum + (item.amount ?? 0)),
      status: status,
      rejectionReason: collection?.rejectionReason ?? '',
      rejectionRemarks: collection?.rejectionRemarks ?? '',
    );
  }
}

const _decoration = BoxDecoration(
  color: AppColors.neutral50,
  borderRadius: BorderRadius.all(Radius.circular(12)),
  boxShadow: [HomeStyles.cardShadow],
);

String _fallbackItemThumbnail(int index) =>
    'assets/images/collection_detail/figma/'
    'raw_${[11, 8, 14][index % 3].toString().padLeft(2, '0')}.png';
