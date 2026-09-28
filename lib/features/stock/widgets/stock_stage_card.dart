import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

import '../../home/widgets/home_styles.dart';

class StockStageCard extends StatelessWidget {
  const StockStageCard({
    super.key,
    required this.code,
    required this.description,
    required this.weight,
    required this.itemCount,
    required this.icon,
    required this.foreground,
    required this.iconBackground,
    required this.onTap,
  });

  final String code;
  final String description;
  final String weight;
  final String itemCount;
  final String icon;
  final Color foreground;
  final Color iconBackground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.neutral50,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [HomeStyles.cardShadow],

        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: code,
                          style: AppTextStyles.semiboldH6_20.copyWith(
                            color: foreground,
                          ),
                        ),
                        TextSpan(
                          text: '  $description',
                          style: AppTextStyles.semiboldH9_14.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.north_east_rounded, size: 20, color: foreground),
              ],
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: weight,
                    style: AppTextStyles.boldH6_20.copyWith(
                      color: AppColors.neutral900,
                    ),
                  ),
                  TextSpan(
                    text: '  $itemCount',
                    style: AppTextStyles.semiboldH9_14.copyWith(
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
