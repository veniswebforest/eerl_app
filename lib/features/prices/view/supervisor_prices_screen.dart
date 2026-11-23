import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/prices/model/price_ui_models.dart';
import 'package:eerl_app/features/prices/view/ask_price_change_screen.dart';
import 'package:eerl_app/features/prices/view/price_request_detail_screen.dart';
import 'package:eerl_app/features/prices/view/price_requests_screen.dart';
import 'package:eerl_app/features/prices/widgets/prices_ui.dart';

class SupervisorPricesScreen extends StatelessWidget {
  const SupervisorPricesScreen({super.key});

  static const _materials = <PriceMaterialUiModel>[
    PriceMaterialUiModel(
      kind: PriceMaterialKind.pet,
      amount: '45.00',
      waitingAmount: '48.00',
      accent: AppColors.purple,
      background: AppColors.purpleLight,
      iconAsset: '$pricesAssetPath/pet.svg',
      openIconAsset: '$pricesAssetPath/open_purple.svg',
    ),
    PriceMaterialUiModel(
      kind: PriceMaterialKind.hdpe,
      amount: '32.00',
      accent: AppColors.secondary500,
      background: AppColors.secondary100,
      iconAsset: '$pricesAssetPath/hdpe.svg',
      openIconAsset: '$pricesAssetPath/open_blue.svg',
    ),
    PriceMaterialUiModel(
      kind: PriceMaterialKind.pp,
      amount: '28.50',
      accent: AppColors.orchid,
      background: AppColors.orchidLight,
      iconAsset: '$pricesAssetPath/pp.svg',
      openIconAsset: '$pricesAssetPath/open_orchid.svg',
    ),
    PriceMaterialUiModel(
      kind: PriceMaterialKind.cardboard,
      amount: null,
      accent: AppColors.orange,
      background: AppColors.orangeLight,
      iconAsset: '$pricesAssetPath/cardboard.svg',
      openIconAsset: '$pricesAssetPath/open_orange.svg',
    ),
  ];

  @override
  Widget build(BuildContext context) => PricesPageFrame(
    title: context.l10n.pricesTitle,
    subtitle: context.l10n.pricesSubtitle,
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        const PriceCentreSelector(),
        const SizedBox(height: 16),
        PriceRequestsBanner(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const PriceRequestsScreen(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          context.l10n.pricesMaterials,
          style: AppTextStyles.semiboldH7_18.copyWith(
            color: AppColors.neutral950,
          ),
        ),
        const SizedBox(height: 16),
        for (final material in _materials) ...[
          PriceMaterialCard(
            material: material,
            onTap: () => _openMaterial(context, material),
          ),
          const SizedBox(height: 16),
        ],
      ],
    ),
  );

  void _openMaterial(BuildContext context, PriceMaterialUiModel material) {
    final page = material.waitingAmount == null
        ? const AskPriceChangeScreen()
        : const PriceRequestDetailScreen(state: PriceRequestState.waiting);
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  }
}
