import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/wallet/widgets/wallet_assets.dart';

import '../model/recent_collection_item_model.dart';
import 'collection_assets.dart';

class RecentCollectionCard extends StatelessWidget {
  const RecentCollectionCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final RecentCollectionItemModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusStyle = _styleFor(item.status);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(      color: Colors.white,

            borderRadius: BorderRadius.circular(12),
            border: item.status == RecentCollectionStatus.pending
                ? Border.all(color: AppColors.primary500)
                : null,
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: AppTextStyles.semiboldH7_18.copyWith(
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        // color: AppColors.cool100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _CollectionMetric(
                            icon: CollectionAssets.receipt,
                            value: item.receiptNumber,
                          ),
                          _CollectionMetric(
                            icon: CollectionAssets.weight,
                            value: item.weight,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 260),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: statusStyle.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            statusStyle.icon,
                            width: 20,
                            height: 20,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              item.statusLabel,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.semiboldH10_12.copyWith(
                                color: statusStyle.foreground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: SvgPicture.asset(
                  CollectionAssets.openDetails,
                  width: 12,
                  height: 12,
                  colorFilter: ColorFilter.mode(
                    item.status == RecentCollectionStatus.pending
                        ? AppColors.primary500
                        : AppColors.cool400,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _CollectionStatusStyle _styleFor(RecentCollectionStatus status) {
    return switch (status) {
      RecentCollectionStatus.pending => const _CollectionStatusStyle(
        icon: WalletAssets.statusPending,
        foreground: AppColors.yellow600,
        background: AppColors.yellow50,
      ),
      RecentCollectionStatus.verified => const _CollectionStatusStyle(
        icon: WalletAssets.statusVerified,
        foreground: AppColors.primary500,
        background: AppColors.primary50,
      ),
      RecentCollectionStatus.rejected => const _CollectionStatusStyle(
        icon: WalletAssets.statusFlagged,
        foreground: AppColors.red600,
        background: AppColors.red50,
      ),
    };
  }
}

class _CollectionMetric extends StatelessWidget {
  const _CollectionMetric({required this.icon, required this.value});

  final String icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(icon, width: 20, height: 20),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: AppTextStyles.mediumSH8_14.copyWith(
            color: AppColors.neutral700,
          ),
        ),
      ],
    );
  }
}

class _CollectionStatusStyle {
  const _CollectionStatusStyle({
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final String icon;
  final Color foreground;
  final Color background;
}
