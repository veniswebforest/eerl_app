import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'home_assets.dart';
import 'home_styles.dart';

/// Quick Actions section with Start Collection and Wallet & Log Expense cards.
class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    this.onAddCollectionTap,
    this.onTasksTap,
    this.onLogExpenseTap,
  });

  final VoidCallback? onAddCollectionTap;
  final VoidCallback? onTasksTap;
  final VoidCallback? onLogExpenseTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.quickActions, style: HomeStyles.sectionTitle),
        const SizedBox(height: 16),
        QuickActionCard(
          key: const Key('home-start-collection-card'),
          iconAsset: HomeAssets.startCollection,
          iconColor: AppColors.orange,
          iconBg: AppColors.orangeLight,
          title: context.l10n.startCollection,
          subtitle: context.l10n.recordWeightProof,
          buttonLabel: context.l10n.addCollection,
          onTap: onAddCollectionTap ?? () {},
        ),
        const SizedBox(height: 16),
        QuickActionCard(
          key: const Key('home-pending-task-card'),
          iconAsset: 'assets/icons/profile/sync_pending_collection.svg',
          iconColor: AppColors.yellow600,
          iconBg: AppColors.yellow50,
          title: context.l10n.homePendingTask,
          subtitle: context.l10n.homePendingTaskSubtitle,
          buttonLabel: context.l10n.viewTask,
          badge: '3',
          onTap: onTasksTap ?? () {},
        ),
        const SizedBox(height: 16),
        QuickActionCard(
          key: const Key('home-wallet-expense-card'),
          iconAsset: HomeAssets.walletExpense,
          iconColor: AppColors.secondary500,
          iconBg: AppColors.secondary100,
          title: context.l10n.walletLogExpense,
          subtitle: context.l10n.trackFieldSpending,
          buttonLabel: context.l10n.logExpense,
          onTap: onLogExpenseTap ?? () {},
        ),
      ],
    );
  }
}

/// Reusable action card used inside [QuickActions].
class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    this.iconAsset,
    this.iconData,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
    this.badge,
  });

  final String? iconAsset;
  final IconData? iconData;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [HomeStyles.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + title row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: iconAsset != null
                    ? SvgPicture.asset(iconAsset!, width: 24, height: 24)
                    : Icon(iconData, size: 24, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.semiboldH8_16.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.yellow600,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge!,
                    style: AppTextStyles.semiboldH10_12.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTextStyles.regularB8_12.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 16),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: AppColors.neutral50,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                textStyle: AppTextStyles.boldH7_16,
              ),
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}
