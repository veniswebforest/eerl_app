import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/shared/widgets/cached_app_image.dart';

class CollectionMaterialCard extends StatelessWidget {
  const CollectionMaterialCard({
    super.key,
    required this.item,
    required this.collectionWeightLabel,
    required this.verifiedWeightLabel,
    required this.rateLabel,
    required this.totalLabel,
    this.thumbnailPath,
    this.matchSummaryDesign = false,
    this.onPhotoTap,
  });

  final CollectionItemModel item;
  final String collectionWeightLabel;
  final String verifiedWeightLabel;
  final String rateLabel;
  final String totalLabel;
  final String? thumbnailPath;
  final bool matchSummaryDesign;
  final ValueChanged<String>? onPhotoTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.cool200,
                borderRadius: BorderRadius.circular(5),
              ),
              child: thumbnailPath == null
                  ? const Icon(Icons.recycling, color: AppColors.primary500)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CachedAppImage(
                        source: thumbnailPath!,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.name ?? item.itemId,
                style: AppTextStyles.boldH8_14.copyWith(
                  color: AppColors.cool950,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _WeightBox(
                label: collectionWeightLabel,
                color: AppColors.cool200,
                value: _quantity(item.qty),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _WeightBox(
                label: verifiedWeightLabel,
                color: AppColors.primary100,
                value: _quantity(item.verifiedQty ?? item.qty),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                matchSummaryDesign
                    ? '$rateLabel ₹${item.rate?.toStringAsFixed(2) ?? '-'}/$_rateUnit'
                    : '$rateLabel ${item.rate?.toStringAsFixed(2) ?? '-'}',
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.mediumSH9_12.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                matchSummaryDesign
                    ? '$totalLabel ₹${item.amount == null ? '-' : NumberFormat('#,##0.00').format(item.amount)}'
                    : '$totalLabel ${item.amount?.toStringAsFixed(2) ?? '-'}',
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.mediumSH9_12.copyWith(
                  color: AppColors.primary500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (item.photoUrls.isNotEmpty)
          Row(
            children: item.photoUrls
                .take(2)
                .map(
                  (path) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _MaterialPhoto(
                        path: path,
                        onTap: onPhotoTap == null
                            ? null
                            : () => onPhotoTap!(path),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
      ],
    );
  }

  String _quantity(double value) {
    final unit = item.unitCode ?? '';
    return matchSummaryDesign
        ? '$unit   ${value.toStringAsFixed(2)}'
        : '${value.toStringAsFixed(2)} $unit';
  }

  String get _rateUnit =>
      (item.unitCode ?? '').toUpperCase() == 'PCS' ? 'Piece' : 'KG';
}

class _WeightBox extends StatelessWidget {
  const _WeightBox({
    required this.label,
    required this.color,
    required this.value,
  });
  final String label;
  final Color color;
  final String value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.mediumSH9_12.copyWith(color: AppColors.neutral950),
      ),
      const SizedBox(height: 5),
      Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          value,
          style: AppTextStyles.mediumSH9_12.copyWith(
            color: AppColors.neutral900,
          ),
        ),
      ),
    ],
  );
}

class _MaterialPhoto extends StatelessWidget {
  const _MaterialPhoto({required this.path, this.onTap});
  final String path;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: onTap != null,
    child: GestureDetector(
      key: ValueKey('collection-material-photo-$path'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: AspectRatio(
          aspectRatio: 1.45,
          child: CachedAppImage(source: path, fit: BoxFit.cover),
        ),
      ),
    ),
  );
}
