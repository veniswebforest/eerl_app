import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/home/widgets/home_assets.dart';
import '../model/stock_item.dart';
import '../widgets/stock_stage_card.dart';
import 'package:go_router/go_router.dart';

class FacilityStockScreen extends StatelessWidget {
  const FacilityStockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ColoredBox(
      color: AppColors.backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              key: const PageStorageKey('facility-stock-scroll'),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 112),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.stockTitle,
                            style: AppTextStyles.semiboldH6_20.copyWith(
                              color: AppColors.neutral950,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.startYourCollections,
                            style: AppTextStyles.mediumSH8_14.copyWith(
                              color: AppColors.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SvgPicture.asset(
                      HomeAssets.notification,
                      width: 45,
                      height: 45,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _FacilitySelector(label: l10n.verificationSuratSouth),
                const SizedBox(height: 16),
                _UpdatedBanner(
                  label: l10n.stockLastUpdated,
                  value: l10n.stockLastUpdatedValue,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.stockStageOverview,
                  style: AppTextStyles.semiboldH7_18.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
                const SizedBox(height: 16),
                StockStageCard(
                  key: const Key('stock-stage-rm'),
                  code: l10n.stockRmCode,
                  description: l10n.stockRawMaterial,
                  weight: l10n.stockStageWeight,
                  itemCount: l10n.stockRmItems,
                  icon: 'assets/icons/stock_stage_rm.svg',
                  foreground: AppColors.purple,
                  iconBackground: AppColors.purpleLight,
                  onTap: () => context.push<void>(
                    AppRoutes.stockDetail,
                    extra: StockStage.rawMaterial,
                  ),
                ),
                const SizedBox(height: 16),
                StockStageCard(
                  key: const Key('stock-stage-srm'),
                  code: l10n.stockSrmCode,
                  description: l10n.stockSortedRawMaterial,
                  weight: l10n.stockStageWeight,
                  itemCount: l10n.stockSrmItems,
                  icon: 'assets/icons/stock_stage_srm.svg',
                  foreground: AppColors.secondary500,
                  iconBackground: AppColors.secondary100,
                  onTap: () => context.push<void>(
                    AppRoutes.stockDetail,
                    extra: StockStage.sortedRawMaterial,
                  ),
                ),
                const SizedBox(height: 16),
                StockStageCard(
                  key: const Key('stock-stage-wip'),
                  code: l10n.stockWipCode,
                  description: l10n.stockWorkInProgress,
                  weight: l10n.stockStageWeight,
                  itemCount: l10n.stockWipItems,
                  icon: 'assets/icons/stock_stage_wip.svg',
                  foreground: AppColors.orchid,
                  iconBackground: AppColors.orchidLight,
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                StockStageCard(
                  key: const Key('stock-stage-fg'),
                  code: l10n.stockFgCode,
                  description: l10n.stockFinishedGoods,
                  weight: l10n.stockStageWeight,
                  itemCount: l10n.stockFgItems,
                  icon: 'assets/icons/stock_stage_fg.svg',
                  foreground: AppColors.orange,
                  iconBackground: AppColors.orangeLight,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FacilitySelector extends StatelessWidget {
  const _FacilitySelector({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: 60,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      border: Border.all(color: AppColors.primary500),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.primary50,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset('assets/icons/stock_facility.svg'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.semiboldH9_14.copyWith(
              color: AppColors.neutral950,
            ),
          ),
        ),
        SvgPicture.asset(HomeAssets.chevronDown, width: 24, height: 24),
      ],
    ),
  );
}

class _UpdatedBanner extends StatelessWidget {
  const _UpdatedBanner({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: AppColors.primary50,
      border: Border.all(color: AppColors.primary500),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: AppColors.primary500,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.semiboldH9_14.copyWith(
              color: AppColors.primary500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: AppTextStyles.mediumSH8_14.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ),
      ],
    ),
  );
}
