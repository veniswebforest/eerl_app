import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/collection_material_model.dart';

class CollectionMaterialCard extends StatelessWidget {
  const CollectionMaterialCard({
    super.key,
    required this.item,
    required this.collectionWeightLabel,
    required this.verifiedWeightLabel,
    required this.rateLabel,
    required this.totalLabel,
  });

  final CollectionMaterialModel item;
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
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                item.thumbnail,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.name,
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
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _WeightBox(
                label: verifiedWeightLabel,
                color: AppColors.primary100,
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
                rateLabel,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.mediumSH9_12.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                totalLabel,
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
        Row(
          children: [
            Expanded(child: _MaterialPhoto(path: item.collectionPhoto)),
            const SizedBox(width: 12),
            Expanded(child: _MaterialPhoto(path: item.verifiedPhoto)),
          ],
        ),
      ],
    );
  }
}

class _WeightBox extends StatelessWidget {
  const _WeightBox({required this.label, required this.color});
  final String label;
  final Color color;
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
          'KG   270.00',
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
      child: Image.asset(path, fit: BoxFit.cover),
    ),
  );
}
