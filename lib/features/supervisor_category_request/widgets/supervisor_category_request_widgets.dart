import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/supervisor_category_request/model/supervisor_category_request.dart';
import 'package:eerl_app/features/wallet/widgets/wallet_assets.dart';

class SupervisorCategoryRequestCard extends StatelessWidget {
  const SupervisorCategoryRequestCard({
    super.key,
    required this.item,
    required this.statusLabel,
    required this.onTap,
    this.cardKey,
  });

  final SupervisorCategoryRequest item;
  final String statusLabel;
  final VoidCallback onTap;
  final Key? cardKey;

  @override
  Widget build(BuildContext context) {
    final (foreground, background, icon) = switch (item.status) {
      SupervisorCategoryRequestStatus.pending => (
        AppColors.yellow600,
        AppColors.yellow50,
        WalletAssets.statusPending,
      ),
      SupervisorCategoryRequestStatus.resolved => (
        AppColors.primary500,
        AppColors.primary50,
        WalletAssets.statusVerified,
      ),
      SupervisorCategoryRequestStatus.rejected => (
        AppColors.red500,
        AppColors.red50,
        WalletAssets.categoryRequestRejected,
      ),
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [HomeStyles.cardShadow],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: cardKey ?? ValueKey('category-request-${item.status.name}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(
                        'assets/images/category_request_rahul.png',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: item.agent,
                              style: AppTextStyles.semiboldH9_14,
                            ),
                            TextSpan(
                              text: ' (${item.facility})',
                              style: AppTextStyles.semiboldH9_14,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SvgPicture.asset(
                      WalletAssets.openDetails,
                      width: 24,
                      height: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // color: AppColors.cool100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.category, style: AppTextStyles.mediumSH8_14),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: AppTextStyles.regularB8_12.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(icon, width: 20, height: 20),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  statusLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.semiboldH10_12.copyWith(
                                    color: foreground,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.date,
                      maxLines: 1,
                      style: AppTextStyles.regularB8_12.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SupervisorCategoryStatusChip extends StatelessWidget {
  const SupervisorCategoryStatusChip({
    super.key,
    required this.status,
    required this.label,
  });

  final SupervisorCategoryRequestStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (foreground, background, icon) = switch (status) {
      SupervisorCategoryRequestStatus.pending => (
        AppColors.yellow600,
        AppColors.yellow50,
        WalletAssets.statusPending,
      ),
      SupervisorCategoryRequestStatus.resolved => (
        AppColors.primary500,
        AppColors.primary50,
        WalletAssets.statusVerified,
      ),
      SupervisorCategoryRequestStatus.rejected => (
        AppColors.red500,
        AppColors.red50,
        WalletAssets.categoryRequestRejected,
      ),
    };
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(icon, width: 20, height: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.semiboldH10_12.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
