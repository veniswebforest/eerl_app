import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import 'home_assets.dart';
import 'home_styles.dart';

/// Quick Actions section with Start Collection and Wallet & Log Expense cards.
class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.quickActions, style: HomeStyles.sectionTitle),
        const SizedBox(height: 16),
        QuickActionCard(
          iconAsset: HomeAssets.startCollection,
          iconColor: AppColors.orange,
          iconBg: AppColors.orangeLight,
          title: context.l10n.startCollection,
          subtitle: context.l10n.recordWeightProof,
          buttonLabel: context.l10n.addCollection,
          onTap: () {},
        ),
        const SizedBox(height: 16),
        QuickActionCard(
          iconAsset: HomeAssets.walletExpense,
          iconColor: AppColors.secondary500,
          iconBg: AppColors.secondary100,
          title: context.l10n.walletLogExpense,
          subtitle: context.l10n.trackFieldSpending,
          buttonLabel: context.l10n.logExpense,
          onTap: () {},
        ),
      ],
    );
  }
}

/// Reusable action card used inside [QuickActions].
class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.iconAsset,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  final String iconAsset;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

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
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(iconAsset, width: 24, height: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.semiboldH7_18.copyWith(
                        color: AppColors.neutral950,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.mediumSH8_14.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
