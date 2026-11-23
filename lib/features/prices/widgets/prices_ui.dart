import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/prices/model/price_ui_models.dart';

const pricesAssetPath = 'assets/icons/prices';

class PricesPageFrame extends StatelessWidget {
  const PricesPageFrame({
    required this.title,
    required this.child,
    super.key,
    this.subtitle,
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              children: [
                PricesHeader(title: title, subtitle: subtitle),
                const SizedBox(height: 24),
                Expanded(child: child),
                if (bottom case final bottom?) ...[
                  const SizedBox(height: 16),
                  bottom,
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class PricesHeader extends StatelessWidget {
  const PricesHeader({required this.title, super.key, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: subtitle == null ? 40 : 46,
    child: Row(
      children: [
        InkWell(
          key: const Key('prices-back-button'),
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary500,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset('$pricesAssetPath/back.svg'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.semiboldH6_20.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
              if (subtitle case final subtitle?)
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.mediumSH8_14.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class PriceCentreSelector extends StatelessWidget {
  const PriceCentreSelector({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary500),
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
            child: SvgPicture.asset('$pricesAssetPath/centre.svg'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.pricesCentreSuratSouth,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.semiboldH9_14.copyWith(
                color: AppColors.neutral950,
              ),
            ),
          ),
          RotatedBox(
            quarterTurns: 1,
            child: SvgPicture.asset(
              '$pricesAssetPath/chevron.svg',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
    ),
  );
}

class PriceRequestsBanner extends StatelessWidget {
  const PriceRequestsBanner({required this.onTap, super.key});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    key: const Key('open-price-requests'),
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary500),
      ),
      child: Row(
        children: [
          SvgPicture.asset('$pricesAssetPath/status_dot.svg', width: 10),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.pricesYourRequests,
              style: AppTextStyles.semiboldH9_14.copyWith(
                color: AppColors.primary500,
              ),
            ),
          ),
          Text(
            context.l10n.pricesWaitingCount(1),
            style: AppTextStyles.mediumSH8_14.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    ),
  );
}

class PriceMaterialCard extends StatelessWidget {
  const PriceMaterialCard({
    required this.material,
    required this.onTap,
    super.key,
  });
  final PriceMaterialUiModel material;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = switch (material.kind) {
      PriceMaterialKind.pet => l10n.pricesPetBottles,
      PriceMaterialKind.hdpe => l10n.pricesHdpeRigid,
      PriceMaterialKind.pp => l10n.pricesPpHardPlastics,
      PriceMaterialKind.cardboard => l10n.pricesCardboard,
    };
    final type = material.kind == PriceMaterialKind.cardboard
        ? l10n.pricesPaperType
        : l10n.pricesPlasticType;
    final source = switch (material.kind) {
      PriceMaterialKind.pet => l10n.pricesFromSmc,
      PriceMaterialKind.hdpe => l10n.pricesOwnPrice,
      PriceMaterialKind.pp => l10n.pricesFromEvsk,
      PriceMaterialKind.cardboard => l10n.pricesAskForOne,
    };
    return Material(
      color: AppColors.neutral50,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: .18),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: material.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(material.iconAsset),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: name,
                                style: AppTextStyles.semiboldH6_20.copyWith(
                                  color: AppColors.neutral950,
                                ),
                              ),
                              TextSpan(
                                text: ' $type',
                                style: AppTextStyles.semiboldH9_14.copyWith(
                                  color: AppColors.neutral900,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 18),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        material.amount == null
                            ? l10n.pricesNoPrice
                            : l10n.pricesAmountPerKg(material.amount!),
                        style: AppTextStyles.boldH6_20.copyWith(
                          color: AppColors.neutral900,
                        ),
                      ),
                      Text(
                        source,
                        style: AppTextStyles.semiboldH9_14.copyWith(
                          color: material.accent,
                        ),
                      ),
                    ],
                  ),
                  if (material.waitingAmount case final waiting?) ...[
                    const SizedBox(height: 8),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2D9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        child: Text(
                          l10n.pricesAskedWaiting(waiting),
                          style: const TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB8730D),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              PositionedDirectional(
                end: 0,
                top: 0,
                child: SvgPicture.asset(
                  material.openIconAsset,
                  width: 14,
                  height: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PriceRequestTabs extends StatelessWidget {
  const PriceRequestTabs({
    required this.index,
    required this.onChanged,
    super.key,
  });
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .15),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: _PriceRequestTab(
            label: context.l10n.priceRequestsWaitingTab(1),
            selected: index == 0,
            onTap: () => onChanged(0),
          ),
        ),
        Expanded(
          child: _PriceRequestTab(
            label: context.l10n.priceRequestsDecidedTab(2),
            selected: index == 1,
            onTap: () => onChanged(1),
          ),
        ),
      ],
    ),
  );
}

class _PriceRequestTab extends StatelessWidget {
  const _PriceRequestTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary500 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: (selected ? AppTextStyles.boldH8_14 : AppTextStyles.mediumSH8_14)
            .copyWith(
              color: selected ? AppColors.neutral50 : AppColors.neutral900,
            ),
      ),
    ),
  );
}

class PrimaryPriceButton extends StatelessWidget {
  const PrimaryPriceButton({
    required this.label,
    required this.onPressed,
    super.key,
  });
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary500,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: AppTextStyles.boldH7_16.copyWith(color: AppColors.neutral50),
      ),
    ),
  );
}
