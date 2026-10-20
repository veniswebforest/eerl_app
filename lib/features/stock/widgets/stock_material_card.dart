import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:flutter/material.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/shared/widgets/cached_app_image.dart';

class StockMaterialCard extends StatelessWidget {
  const StockMaterialCard({
    super.key,
    required this.item,
    required this.fallbackImage,
  });

  final StockModel item;
  final String fallbackImage;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [HomeStyles.cardShadow],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: CachedAppImage(
            source: item.imageUrl?.trim().isNotEmpty == true
                ? item.imageUrl
                : fallbackImage,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name ?? item.itemId,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.semiboldH9_14.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: item.qty.toStringAsFixed(2),
                      style: AppTextStyles.boldH8_14.copyWith(
                        fontSize: 16,

                        color: AppColors.primary500,
                      ),
                    ),
                    TextSpan(
                      text: ' KG',
                      style: AppTextStyles.semiboldH9_14.copyWith(
                        color: AppColors.neutral900,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Text(
              //   '${item.qty.toStringAsFixed(2)} ${item.unitCode ?? ''}',
              //   maxLines: 1,
              //   overflow: TextOverflow.ellipsis,
              //   style: AppTextStyles.boldH8_14.copyWith(
              //     fontSize: 16,
              //     color: AppColors.primary500,
              //   ),
              // ),
            ],
          ),
        ),
      ],
    ),
  );
}
