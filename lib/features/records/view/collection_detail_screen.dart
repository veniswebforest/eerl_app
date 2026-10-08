import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';
import 'package:eerl_app/features/bootstrap/service/item_image_cache_service.dart';
import 'package:eerl_app/shared/widgets/app_message_banner.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import 'package:eerl_app/shared/widgets/cached_app_image.dart';
import '../widgets/collection_detail_assets.dart';
import '../widgets/collection_detail_cards.dart';
import '../widgets/collection_material_card.dart';
import '../model/collection_detail_status.dart';

class CollectionDetailScreen extends StatefulWidget {
  const CollectionDetailScreen({super.key, this.collectionId, this.status});
  final String? collectionId;
  final CollectionDetailStatus? status;

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  late final LocalQueryController<
    ({CollectionModel? collection, List<CollectionItemModel> items})
  >
  _controller;

  @override
  void initState() {
    super.initState();
    _controller = LocalQueryController(() async {
      final collectionId = widget.collectionId;
      if (collectionId == null || widget.status != null) {
        return (collection: null, items: const <CollectionItemModel>[]);
      }
      final collection = await EerlLocalRepository.instance.getCollection(
        collectionId,
      );
      final items = await EerlLocalRepository.instance.getCollectionItems(
        collectionId,
      );
      return (collection: collection, items: items);
    })..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    body: SafeArea(
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading && !_controller.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final collection = _controller.data?.collection;
          if (collection == null && widget.status != null) {
            final mock = _mockData(context, widget.status!);
            return _content(context, mock.$1, mock.$2);
          }
          if (_controller.error != null || collection == null) {
            return Center(
              child: TextButton(
                onPressed: _controller.load,
                child: const Text('Retry'),
              ),
            );
          }
          return _content(context, collection, _controller.data!.items);
        },
      ),
    ),
  );

  Widget _content(
    BuildContext context,
    CollectionModel collection,
    List<CollectionItemModel> items,
  ) {
    final isDraft = collection.status.toUpperCase() == 'DRAFT';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        AppScreenHeaderMetrics.topInset,
        20,
        20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppScreenHeader(
                leading: InkWell(
                  key: const Key('collection-detail-back'),
                  onTap: () => Navigator.of(context).maybePop(),
                  borderRadius: BorderRadius.circular(8),
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
              ),
              const SizedBox(height: 24),
              if (!isDraft) _StatusBanner(status: collection.status),
              if (collection.status.toUpperCase() == 'REJECTED' &&
                  collection.rejectionReason != null) ...[
                const SizedBox(height: 10),
                _RejectReasonCard(reason: collection.rejectionReason!),
              ],
              SizedBox(height: isDraft ? 0 : 20),
              CollectionDetailInfoCard(
                label: context.l10n.collectionReceiptId,
                value: collection.slipNumber ?? collection.id,
              ),
              const SizedBox(height: 10),
              CollectionDetailInfoCard(
                label: context.l10n.collectionDetailDateTime,
                value: _date(collection.collectedAt ?? collection.updatedAt),
              ),
              const SizedBox(height: 10),
              CollectionDetailInfoCard(
                label: context.l10n.collectionDetailAgent,
                value: collection.agentName,
              ),
              const SizedBox(height: 10),
              CollectionDetailInfoCard(
                label: context.l10n.collectionDetailType,
                value: collection.channel,
                icon: SvgPicture.asset(
                  CollectionDetailAssets.collectionType,
                  width: 20,
                  height: 20,
                ),
              ),
              const SizedBox(height: 10),
              CollectionDetailInfoCard(
                label: context.l10n.collectionGivenBy,
                value: collection.givenByName?.trim().isNotEmpty == true
                    ? collection.givenByName!
                    : context.l10n.verificationDetailGivenByValue,
              ),
              const SizedBox(height: 10),
              CollectionDetailInfoCard(
                label: context.l10n.collectionReceiptLabor,
                value: collection.handedOverBy?.trim().isNotEmpty == true
                    ? collection.handedOverBy!
                    : context.l10n.verificationDetailGivenByValue,
              ),
              const SizedBox(height: 10),
              _VehiclePhotoCard(
                paths: collection.handoverPhotoUrls,
                onPhotoTap: _openImagePreview,
              ),
              const SizedBox(height: 12),
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
                    if (items.isEmpty)
                      Text(context.l10n.dashboardEmptyMessage)
                    else
                      for (var i = 0; i < items.length; i++) ...[
                        CollectionMaterialCard(
                          item: items[i],
                          thumbnailPath:
                              items[i].itemImageUrl?.trim().isNotEmpty == true
                              ? items[i].itemImageUrl
                              : _fallbackThumbnail(i),
                          matchSummaryDesign: true,
                          collectionWeightLabel:
                              context.l10n.verificationDetailCollected,
                          verifiedWeightLabel:
                              context.l10n.verificationDetailVerified,
                          rateLabel: context.l10n.collectionDetailRate,
                          totalLabel:
                              context.l10n.collectionDetailMaterialTotal,
                          onPhotoTap: _openImagePreview,
                        ),
                        if (i != items.length - 1)
                          const Divider(height: 26, color: AppColors.cool400),
                      ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _UnitSummaryCard(
                items: items,
                totalPrice:
                    collection.totalAmount ??
                    items.fold<double>(
                      0,
                      (sum, item) => sum + (item.amount ?? 0),
                    ),
              ),
              const SizedBox(height: 16),
              if (isDraft) ...[
                _DraftActions(
                  onSave: () => _save(collection, items, submit: false),
                  onSubmit: () => _save(collection, items, submit: true),
                ),
              ],
              if (!isDraft)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    key: const Key('collection-detail-preview-slip'),
                    onPressed: () => context.push<void>(
                      AppRoutes.collectionReceipt,
                      extra: collection.id,
                    ),
                    icon: SvgPicture.asset(
                      CollectionDetailAssets.preview,
                      width: 24,
                      height: 24,
                    ),
                    label: Text(context.l10n.collectionDetailPreviewSlip),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(
    CollectionModel collection,
    List<CollectionItemModel> items, {
    required bool submit,
  }) async {
    await EerlLocalRepository.instance.saveCollection(
      collection: collection,
      items: items,
      submit: submit,
    );
    if (!mounted) return;
    if (submit) {
      context.pushReplacement(
        AppRoutes.collectionReceipt,
        extra: collection.id,
      );
    } else {
      Navigator.of(context).maybePop();
    }
  }

  String _date(String value) {
    final parsed = DateTime.tryParse(value)?.toLocal();
    return parsed == null
        ? value
        : DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
  }

  String _fallbackThumbnail(int index) =>
      'assets/images/collection_detail/figma/raw_${[11, 8, 14][index % 3].toString().padLeft(2, '0')}.png';

  Future<void> _openImagePreview(String source) async {
    final path = source.trim();
    if (path.isEmpty) return;

    ImageProvider imageProvider;
    if (path.startsWith('assets/')) {
      imageProvider = AssetImage(path);
    } else {
      final uri = Uri.tryParse(path);
      final isRemote =
          uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
      if (isRemote) {
        final cachedFile = await ItemImageCacheService.instance.localFileForUrl(
          path,
        );
        imageProvider = cachedFile == null
            ? NetworkImage(path)
            : FileImage(cachedFile);
      } else {
        imageProvider = FileImage(File(path));
      }
    }
    if (!mounted) return;
    await context.push<void>(
      AppRoutes.collectionImagePreview,
      extra: imageProvider,
    );
  }

  (CollectionModel, List<CollectionItemModel>) _mockData(
    BuildContext context,
    CollectionDetailStatus status,
  ) {
    final statusValue = switch (status) {
      CollectionDetailStatus.draft => 'DRAFT',
      CollectionDetailStatus.pending => 'SUBMITTED',
      CollectionDetailStatus.approved => 'APPROVED',
      CollectionDetailStatus.rejected => 'REJECTED',
    };
    final collection = CollectionModel(
      id: '#REC-2026-002',
      centerId: 'preview-center',
      agentId: 'preview-agent',
      agentName: context.l10n.verificationRahulPatel,
      channel: context.l10n.collectionMrfShort,
      status: statusValue,
      collectedAt: '2026-10-24T15:45:00',
      givenByName: 'Chunilal Yadav',
      handedOverBy: context.l10n.verificationDetailGivenByValue,
      totalAmount: 35550,
      totalQty: 890,
      handoverPhotoUrls: const [
        'assets/images/collection_detail/figma/raw_01.png',
      ],
      rejectionReason: status == CollectionDetailStatus.rejected
          ? context.l10n.collectionDetailRemarksValue
          : null,
      updatedAt: '2026-10-24T15:45:00',
      syncState: 'synced',
    );
    final names = [
      context.l10n.collectionDetailPetBottles,
      context.l10n.collectionDetailHdpeRigid,
      context.l10n.collectionDetailPpHardPlastics,
    ];
    final units = ['KG', 'PCS', 'KG'];
    final quantities = [270.0, 80.0, 270.0];
    final items = List.generate(
      3,
      (index) => CollectionItemModel(
        id: 'preview-$index',
        collectionId: collection.id,
        itemId: 'preview-$index',
        name: names[index],
        qty: quantities[index],
        verifiedQty: quantities[index],
        rate: 45,
        amount: 12150,
        photoUrls: [
          'assets/images/collection_detail/figma/raw_${[7, 5, 3][index].toString().padLeft(2, '0')}.png',
          'assets/images/collection_detail/figma/raw_${[7, 5, 3][index].toString().padLeft(2, '0')}.png',
        ],
        sortOrder: index,
        unitCode: units[index],
        itemImageUrl:
            'assets/images/collection_detail/figma/raw_${[11, 8, 14][index].toString().padLeft(2, '0')}.png',
      ),
    );
    return (collection, items);
  }
}

class _VehiclePhotoCard extends StatelessWidget {
  const _VehiclePhotoCard({required this.paths, required this.onPhotoTap});
  final List<String> paths;
  final ValueChanged<String> onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final path =
        paths.firstOrNull ?? 'assets/images/collection_detail/figma/raw_01.png';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _detailCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.verificationDetailVehiclePhoto,
            style: AppTextStyles.semiboldH8_16.copyWith(
              color: AppColors.cool600,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            key: const Key('collection-vehicle-photo'),
            behavior: HitTestBehavior.opaque,
            onTap: () => onPhotoTap(path),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 109,
                height: 70,
                child: CachedAppImage(source: path, fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitSummaryCard extends StatelessWidget {
  const _UnitSummaryCard({required this.items, required this.totalPrice});
  final List<CollectionItemModel> items;
  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, ({double collected, double verified})>{};
    for (final item in items) {
      final unit =
          (item.unitCode?.trim().isNotEmpty == true ? item.unitCode! : 'KG')
              .toUpperCase();
      final current = grouped[unit] ?? (collected: 0.0, verified: 0.0);
      grouped[unit] = (
        collected: current.collected + item.qty,
        verified: current.verified + (item.verifiedQty ?? item.qty),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _detailCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in grouped.entries) ...[
            Text(
              entry.key == 'PCS'
                  ? context.l10n.collectionReceiptPcsBlock
                  : '${entry.key} ${context.l10n.collectionReceiptKgBlock.split(' ').last}',
              style: AppTextStyles.boldH8_14.copyWith(
                color: AppColors.neutral950,
              ),
            ),
            const SizedBox(height: 10),
            _SummaryLine(
              label: context.l10n.collectionReceiptCollectedTotal,
              value: '${_quantity(entry.value.collected)} ${entry.key}',
            ),
            const SizedBox(height: 7),
            _SummaryLine(
              label: context.l10n.collectionReceiptVerifiedTotal,
              value: '${_quantity(entry.value.verified)} ${entry.key}',
            ),
            const SizedBox(height: 7),
            _SummaryLine(
              label: context.l10n.collectionReceiptDifference,
              value:
                  '${_quantity(entry.value.verified - entry.value.collected)} ${entry.key}',
              muted: true,
            ),
            if (entry.key != grouped.keys.last)
              const Divider(height: 24, color: AppColors.primary800),
          ],
          const Divider(height: 26, color: AppColors.primary800),
          _SummaryLine(
            label: context.l10n.collectionDetailTotalPrice,
            value: '₹${NumberFormat('#,##0.00').format(totalPrice)}',
            highlighted: true,
          ),
        ],
      ),
    );
  }

  String _quantity(double value) =>
      value == value.roundToDouble() && value.abs() < 100
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.muted = false,
    this.highlighted = false,
  });
  final String label;
  final String value;
  final bool muted;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style:
              (highlighted
                      ? AppTextStyles.boldH6_20
                      : AppTextStyles.mediumSH9_12)
                  .copyWith(
                    color: highlighted
                        ? AppColors.primary500
                        : muted
                        ? AppColors.neutral500
                        : AppColors.neutral950,
                  ),
        ),
      ),
      Text(
        value,
        style: (highlighted ? AppTextStyles.boldH6_20 : AppTextStyles.boldH8_14)
            .copyWith(
              color: highlighted
                  ? AppColors.primary500
                  : muted
                  ? AppColors.neutral500
                  : AppColors.neutral950,
            ),
      ),
    ],
  );
}

class _DraftActions extends StatelessWidget {
  const _DraftActions({required this.onSave, required this.onSubmit});
  final VoidCallback onSave;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: SizedBox(
          height: 52,
          child: OutlinedButton(
            key: const Key('collection-detail-save-draft'),
            onPressed: onSave,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary500,
              side: const BorderSide(color: AppColors.primary500),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(context.l10n.collectionSaveDraft),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            key: const Key('collection-detail-submit'),
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.primary500,
              foregroundColor: AppColors.neutral50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(context.l10n.collectionSubmit),
          ),
        ),
      ),
    ],
  );
}

const _detailCardDecoration = BoxDecoration(
  color: AppColors.neutral50,
  borderRadius: BorderRadius.all(Radius.circular(12)),
  boxShadow: [
    BoxShadow(color: Color(0x1F000000), blurRadius: 6, offset: Offset(0, 2)),
  ],
);

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final rejected = normalized == 'REJECTED';
    final approved = const {'VERIFIED', 'APPROVED'}.contains(normalized);
    final color = rejected
        ? AppColors.red600
        : approved
        ? AppColors.primary500
        : AppColors.yellow600;
    final background = rejected
        ? AppColors.red50
        : approved
        ? AppColors.primary50
        : AppColors.yellow50;
    return AppMessageBanner(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      borderRadius: 10,
      title: status,
      color: color,
      backgroundColor: background,
      titleStyle: AppTextStyles.semiboldH9_14.copyWith(color: color),
      icon: SvgPicture.asset(
        CollectionDetailAssets.statusPending,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}

class _RejectReasonCard extends StatelessWidget {
  const _RejectReasonCard({required this.reason});
  final String reason;
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
          style: AppTextStyles.semiboldH7_18,
        ),
        const SizedBox(height: 8),
        Text(reason, style: AppTextStyles.mediumSH8_14),
      ],
    ),
  );
}
