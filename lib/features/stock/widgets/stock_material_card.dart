import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/shared/widgets/cached_app_image.dart';

class StockMaterialCard extends StatelessWidget {
  const StockMaterialCard({
    super.key,
    required this.item,
    required this.fallbackImage,
    this.updatedLabel,
  });

  final StockModel item;
  final String fallbackImage;

  /// How fresh the figure is, e.g. "10m ago" (time of the last sync).
  final String? updatedLabel;

  /// "Just now", "10m ago", "3h ago" or "2d ago" for [at] seen from [now].
  static String agoLabel(DateTime at, DateTime now) {
    final minutes = now.difference(at).inMinutes;
    if (minutes < 1) return 'Just now';
    if (minutes < 60) return '${minutes}m ago';
    if (minutes < 1440) return '${minutes ~/ 60}h ago';
    return '${minutes ~/ 1440}d ago';
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [HomeStyles.cardShadow],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                item.displayName ?? item.itemId,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.semiboldH9_14.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
              if (item.standardNameBeneathAlias != null)
                Text(
                  item.standardNameBeneathAlias!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.mediumSH9_12.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: NumberFormat('#,##0.00').format(item.qty),
                            style: AppTextStyles.boldH8_14.copyWith(
                              fontSize: 16,
                              color: AppColors.primary500,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' ${item.unitCode?.trim().isNotEmpty == true ? item.unitCode!.trim() : 'KG'}',
                            style: AppTextStyles.semiboldH9_14.copyWith(
                              color: AppColors.neutral900,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.binLabel?.trim().isNotEmpty == true) ...[
                    const SizedBox(width: 8),
                    Container(
                      key: const Key('stock-bin-divider'),
                      width: 1,
                      height: 17,
                      color: AppColors.neutral950,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Bin: ${item.binLabel!.trim()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.neutral950,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (updatedLabel != null) ...[
          const SizedBox(width: 8),
          Text(
            updatedLabel!,
            key: const Key('stock-updated-ago'),
            style: AppTextStyles.mediumSH9_12.copyWith(
              color: AppColors.neutral500,
            ),
          ),
        ],
      ],
    ),
  );
}
