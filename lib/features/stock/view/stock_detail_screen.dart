import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/records/widgets/collection_detail_assets.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import '../model/stock_item.dart';
import '../widgets/stock_material_card.dart';

class StockDetailScreen extends StatelessWidget {
  const StockDetailScreen({
    super.key,
    required this.stage,
    required this.onBack,
  });

  final StockStage stage;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final sorted = stage == StockStage.sortedRawMaterial;
    final items = _items(context, sorted);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                20,
                AppScreenHeaderMetrics.topInset,
                20,
                24,
              ),
              itemCount: items.length + 1,
              separatorBuilder: (_, index) =>
                  SizedBox(height: index == 0 ? 24 : 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppScreenHeader(leading: _BackButton(onTap: onBack)),
                      const SizedBox(height: 24),
                      Text(
                        sorted
                            ? context.l10n.stockSrmDetail
                            : context.l10n.stockRmDetail,
                        style: AppTextStyles.semiboldH6_20.copyWith(
                          color: AppColors.neutral950,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.stockCenterValue,
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  );
                }
                return StockMaterialCard(item: items[index - 1]);
              },
            ),
          ),
        ),
      ),
    );
  }

  List<StockMaterialItem> _items(BuildContext context, bool sorted) {
    final l10n = context.l10n;
    final prefixes = sorted
        ? [
            l10n.stockSortedBinA,
            l10n.stockSortedBinB,
            l10n.stockSortedBinC,
            l10n.stockSortedBinD,
            l10n.stockSortedBinE,
          ]
        : List.filled(5, l10n.stockRawBinPrefix);
    return [
      StockMaterialItem(
        name: l10n.collectionDetailPetBottles,
        weight: sorted ? l10n.stockWeight98050 : l10n.stockWeight980,
        bin: l10n.stockBinValue(prefixes[0], '01'),
        image: 'assets/images/stock/rm_2.png',
        updated: l10n.stockUpdatedAgo,
      ),
      StockMaterialItem(
        name: l10n.collectionDetailHdpeRigid,
        weight: sorted ? l10n.stockWeight98050 : l10n.stockWeight980,
        bin: l10n.stockBinValue(prefixes[1], '02'),
        image: 'assets/images/stock/rm_1.png',
        updated: l10n.stockUpdatedAgo,
      ),
      StockMaterialItem(
        name: l10n.configureMetals,
        weight: sorted ? l10n.stockWeight72050 : l10n.stockWeight720,
        bin: l10n.stockBinValue(prefixes[2], '03'),
        image: 'assets/images/stock/rm_3.png',
        updated: l10n.stockUpdatedAgo,
      ),
      StockMaterialItem(
        name: l10n.configureGlass,
        weight: sorted ? l10n.stockWeight210050 : l10n.stockWeight2100,
        bin: l10n.stockBinValue(prefixes[3], '04'),
        image: 'assets/images/stock/rm_4.png',
        updated: l10n.stockUpdatedAgo,
      ),
      StockMaterialItem(
        name: l10n.configurePaperCardboard,
        weight: sorted ? l10n.stockWeight45050 : l10n.stockWeight450,
        bin: l10n.stockBinValue(prefixes[4], '05'),
        image: 'assets/images/stock/rm_5.png',
        updated: l10n.stockUpdatedAgo,
      ),
    ];
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    key: const Key('stock-detail-back'),
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary500,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SvgPicture.asset(CollectionDetailAssets.back),
    ),
  );
}
