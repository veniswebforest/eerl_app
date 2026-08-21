import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/collection_record_model.dart';
import 'records_assets.dart';

class CollectionHistoryCard extends StatelessWidget {
  const CollectionHistoryCard({
    super.key,
    required this.item,
    required this.statusLabel,
    this.onTap,
  });
  final CollectionRecordModel item;
  final String statusLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (item.status) {
      CollectionRecordStatus.pending => AppColors.yellow600,
      CollectionRecordStatus.verified => AppColors.green700,
      CollectionRecordStatus.rejected => AppColors.red600,
    };
    final statusBackground = switch (item.status) {
      CollectionRecordStatus.pending => AppColors.yellow50,
      CollectionRecordStatus.verified => AppColors.primary50,
      CollectionRecordStatus.rejected => AppColors.red50,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(12),
          border: item.status == CollectionRecordStatus.pending
              ? Border.all(color: AppColors.primary400)
              : null,
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
                    item.name,
                    style: AppTextStyles.mediumSH7_16.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  RecordsAssets.openDetails,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    item.status == CollectionRecordStatus.pending
                        ? AppColors.primary500
                        : AppColors.cool400,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cool100,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  _Info(icon: RecordsAssets.receipt, text: item.receipt),
                  const SizedBox(width: 16),
                  _Info(icon: RecordsAssets.weight, text: item.weight),
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
