import 'dart:io';

import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';

class CollectionMaterialCard extends StatelessWidget {
  const CollectionMaterialCard({
    super.key,
    required this.item,
    required this.collectionWeightLabel,
    required this.verifiedWeightLabel,
    required this.rateLabel,
    required this.totalLabel,
  });

  final CollectionItemModel item;
  final String collectionWeightLabel;
  final String verifiedWeightLabel;
  final String rateLabel;
  final String totalLabel;

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
              child: const Icon(Icons.recycling, color: AppColors.primary500),
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
                value: '${item.qty.toStringAsFixed(2)} ${item.unitCode ?? ''}',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _WeightBox(
                label: verifiedWeightLabel,
                color: AppColors.primary100,
                value:
                    '${(item.verifiedQty ?? item.qty).toStringAsFixed(2)} ${item.unitCode ?? ''}',
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
                '$rateLabel ${item.rate?.toStringAsFixed(2) ?? '-'}',
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.mediumSH9_12.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$totalLabel ${item.amount?.toStringAsFixed(2) ?? '-'}',
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
                      child: _MaterialPhoto(path: path),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
      ],
    );
  }
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
  const _MaterialPhoto({required this.path});
  final String path;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(5),
    child: AspectRatio(
      aspectRatio: 1.45,
      child: path.startsWith('http://') || path.startsWith('https://')
          ? Image.network(path, fit: BoxFit.cover)
          : path.startsWith('assets/')
          ? Image.asset(path, fit: BoxFit.cover)
          : Image.file(File(path), fit: BoxFit.cover),
    ),
  );
}
