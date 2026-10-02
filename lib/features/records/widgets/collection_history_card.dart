import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'records_assets.dart';

class CollectionHistoryCard extends StatelessWidget {
  const CollectionHistoryCard({
    super.key,
    required this.item,
    required this.statusLabel,
    this.onTap,
  });
  final CollectionModel item;
  final String statusLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = item.status.toUpperCase();
    final rejected = normalizedStatus == 'REJECTED';
    final verified = const {'VERIFIED', 'APPROVED'}.contains(normalizedStatus);
    final pending = !rejected && !verified;
    final statusColor = rejected
        ? AppColors.red600
        : verified
        ? AppColors.green700
        : AppColors.yellow600;
    final statusBackground = rejected
        ? AppColors.red50
        : verified
        ? AppColors.primary50
        : AppColors.yellow50;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: pending ? Border.all(color: AppColors.primary400) : null,
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.channel,
                    style: AppTextStyles.semiboldH7_18.copyWith(
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  RecordsAssets.openDetails,
                  width: 14,
                  height: 14,
                  colorFilter: ColorFilter.mode(
                    pending ? AppColors.primary500 : AppColors.cool400,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cool100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _Info(
                    icon: RecordsAssets.receipt,
                    text: item.slipNumber ?? item.id,
                  ),
                  const SizedBox(width: 16),
                  _Info(
                    icon: RecordsAssets.weight,
                    text: '${item.totalQty.toStringAsFixed(2)} kg',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: statusBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusLabel,
                style: AppTextStyles.mediumSH9_12.copyWith(color: statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.text});
  final String icon;
  final String text;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Row(
      children: [
        Container(
          width: 28,
          height: 28,
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: AppColors.neutral50,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(icon),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.mediumSH9_12.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ),
      ],
    ),
  );
}
