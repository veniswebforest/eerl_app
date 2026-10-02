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
import 'package:eerl_app/shared/widgets/app_message_banner.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
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
      if (collectionId == null) {
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
    final totalVerified = items.fold<double>(
      0,
      (sum, item) => sum + (item.verifiedQty ?? item.qty),
    );
    final difference = totalVerified - collection.totalQty;
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
              _StatusBanner(status: collection.status),
              if (collection.status.toUpperCase() == 'REJECTED' &&
                  collection.rejectionReason != null) ...[
                const SizedBox(height: 10),
                _RejectReasonCard(reason: collection.rejectionReason!),
              ],
              const SizedBox(height: 20),
              CollectionDetailInfoCard(
                label: context.l10n.collectionDetailId,
                value: collection.slipNumber ?? collection.id,
              ),
              const SizedBox(height: 10),
              CollectionDetailInfoCard(
                label: context.l10n.collectionDetailDateTime,
                value: _date(collection.collectedAt ?? collection.updatedAt),
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
                label: context.l10n.collectionDetailAgent,
                value: collection.agentName,
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
                    if (items.isEmpty)
                      Text(context.l10n.dashboardEmptyMessage)
                    else
                      for (var i = 0; i < items.length; i++) ...[
                        CollectionMaterialCard(
                          item: items[i],
                          collectionWeightLabel:
                              context.l10n.collectionDetailCollectionWeight,
                          verifiedWeightLabel:
                              context.l10n.collectionDetailVerifiedWeight,
                          rateLabel: context.l10n.collectionDetailRate,
                          totalLabel:
                              context.l10n.collectionDetailMaterialTotal,
                        ),
                        if (i != items.length - 1)
                          const Divider(height: 26, color: AppColors.cool400),
                      ],
                    if (collection.handoverPhotoUrls.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: collection.handoverPhotoUrls
                            .map(
                              (url) => ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: _CollectionImage(path: url),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              CollectionSummaryCard(
                collectionLabel:
                    context.l10n.collectionDetailTotalCollectionWeight,
                verifiedLabel: context.l10n.collectionDetailTotalVerifiedWeight,
                comparisonLabel: context.l10n.collectionDetailWeightComparison,
                comparisonHint: context.l10n.collectionDetailComparisonHint,
                totalPriceLabel: context.l10n.collectionDetailTotalPrice,
                collectionValue: '${collection.totalQty.toStringAsFixed(2)} kg',
                verifiedValue: '${totalVerified.toStringAsFixed(2)} kg',
                comparisonValue: '${difference.toStringAsFixed(2)} kg',
                totalPriceValue:
                    '₹${(collection.totalAmount ?? 0).toStringAsFixed(2)}',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  key: const Key('collection-detail-preview-slip'),
                  onPressed: () =>
                      context.push<void>(AppRoutes.collectionReceipt),
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

  String _date(String value) {
    final parsed = DateTime.tryParse(value)?.toLocal();
    return parsed == null
        ? value
        : DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
  }
}

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

class _CollectionImage extends StatelessWidget {
  const _CollectionImage({required this.path});
  final String path;
  @override
  Widget build(BuildContext context) {
    final child = path.startsWith('http://') || path.startsWith('https://')
        ? Image.network(path, fit: BoxFit.cover)
        : path.startsWith('assets/')
        ? Image.asset(path, fit: BoxFit.cover)
        : Image.file(File(path), fit: BoxFit.cover);
    return SizedBox(width: 116, height: 88, child: child);
  }
}
