import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/stock_item.dart';

class StockMaterialCard extends StatelessWidget {
  const StockMaterialCard({super.key, required this.item});

  final StockMaterialItem item;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1F000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            item.image,
            width: 52,
            height: 52,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.semiboldH9_14.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      item.weight,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.boldH8_14.copyWith(
                        fontSize: 16,
                        color: AppColors.primary500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 17, color: AppColors.cool400),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      item.bin,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.mediumSH8_14.copyWith(
                        color: AppColors.neutral950,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          item.updated,
          style: AppTextStyles.mediumSH9_12.copyWith(
            color: AppColors.neutral500,
          ),
        ),
      ],
    ),
  );
}
