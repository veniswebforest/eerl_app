import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'home_assets.dart';
import 'home_styles.dart';

/// 2×2 grid summary section showing today's collection stats.
class TodaysSummary extends StatelessWidget {
  const TodaysSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.todaysSummary, style: HomeStyles.sectionTitle),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 320 ? 1 : 2;
            final cardWidth =
                (constraints.maxWidth - (columns - 1) * 8) / columns;

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SummaryCard(
                  iconAsset: HomeAssets.collected,
                  iconColor: AppColors.orchid,
                  iconBg: AppColors.orchidLight,
                  label: context.l10n.collectedToday,
                  value: context.l10n.weightKg(320),
                  valueColor: AppColors.orchid,
                ),
                SummaryCard(
                  iconAsset: HomeAssets.verified,
                  iconColor: AppColors.primary500,
                  iconBg: AppColors.primary100,
                  label: context.l10n.verifiedEntries,
                  value: '18',
                  valueColor: AppColors.primary500,
                ),
                SummaryCard(
                  iconAsset: HomeAssets.transfer,
                  iconColor: AppColors.purple,
                  iconBg: AppColors.purpleLight,
                  label: context.l10n.transferRequests,
                  value: '04',
                  valueColor: AppColors.purple,
                ),
                SummaryCard(
                  iconAsset: HomeAssets.wallet,
                  iconColor: AppColors.secondary500,
                  iconBg: AppColors.secondary100,
                  label: context.l10n.walletBalance,
                  value: context.l10n.walletAmount('50,000'),
                  valueColor: AppColors.secondary500,
                ),
              ].map((card) => SizedBox(width: cardWidth, child: card)).toList(),
            );
          },
        ),
      ],
    );
  }
}

/// Individual stat card used inside [TodaysSummary].
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.iconAsset,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String iconAsset;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final Color valueColor;

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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Icon bubble
          Container(
            width: 40,
            height: 40,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(iconAsset, width: 24, height: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.semiboldH9_14.copyWith(
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.semiboldH6_20.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
