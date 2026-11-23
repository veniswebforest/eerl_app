import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/prices/model/price_ui_models.dart';
import 'package:eerl_app/features/prices/view/ask_price_change_screen.dart';
import 'package:eerl_app/features/prices/widgets/prices_ui.dart';

class PriceRequestDetailScreen extends StatelessWidget {
  const PriceRequestDetailScreen({required this.state, super.key});

  final PriceRequestState state;

  static const _pet = PriceMaterialUiModel(
    kind: PriceMaterialKind.pet,
    amount: '45.00',
    accent: AppColors.purple,
    background: AppColors.purpleLight,
    iconAsset: '$pricesAssetPath/pet.svg',
    openIconAsset: '$pricesAssetPath/open_purple.svg',
  );

  @override
  Widget build(BuildContext context) => PricesPageFrame(
    title: context.l10n.priceRequestTitle,
    bottom: state == PriceRequestState.rejected
        ? PrimaryPriceButton(
            label: context.l10n.priceRequestAskAgain,
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const AskPriceChangeScreen(),
              ),
            ),
          )
        : null,
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        PriceMaterialCard(material: _pet, onTap: () {}),
        const SizedBox(height: 16),
        _RequestDetailsCard(),
        const SizedBox(height: 16),
        _RequestStatusCard(state: state),
      ],
    ),
  );
}

class _RequestDetailsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        _DetailRow(
          label: context.l10n.priceRequestPriceNow,
          value: context.l10n.priceRequestCurrentValue,
        ),
        _DetailRow(
          label: context.l10n.priceRequestYouAskedFor,
          value: context.l10n.priceRequestAskedValue,
        ),
        _DetailRow(
          label: context.l10n.priceRequestWhy,
          value: context.l10n.priceRequestPetReason,
        ),
        _DetailRow(
          label: context.l10n.priceRequestAsked,
          value: context.l10n.priceRequestAskedBy,
          showDivider: false,
        ),
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          label,
          style: AppTextStyles.semiboldH9_14.copyWith(
            color: AppColors.neutral600,
          ),
        ),
      ),
      const SizedBox(height: 4),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          value,
          style: AppTextStyles.semiboldH9_14.copyWith(
            color: AppColors.neutral950,
          ),
        ),
      ),
      if (showDivider) ...[
        const SizedBox(height: 12),
        const Divider(height: 1, color: AppColors.cool400),
        const SizedBox(height: 12),
      ],
    ],
  );
}

class _RequestStatusCard extends StatelessWidget {
  const _RequestStatusCard({required this.state});
  final PriceRequestState state;

  @override
  Widget build(BuildContext context) {
    if (state == PriceRequestState.waiting) {
      return _BorderedStatusCard(
        color: const Color(0xFFEDA833),
        background: const Color(0xFFFFFAF0),
        title: context.l10n.priceRequestWaitingForHead,
        children: [context.l10n.priceRequestWaitingMessage],
      );
    }
    if (state == PriceRequestState.approved) {
      return _BorderedStatusCard(
        color: AppColors.primary500,
        background: AppColors.primary50,
        title: context.l10n.priceRequestApproved,
        children: [context.l10n.priceRequestApprovedBy],
      );
    }
    return _BorderedStatusCard(
      color: AppColors.red500,
      background: AppColors.neutral50,
      title: context.l10n.priceRequestRejected,
      children: [
        context.l10n.priceRequestRejectedBy,
        context.l10n.priceRequestRejectedReason,
      ],
    );
  }
}

class _BorderedStatusCard extends StatelessWidget {
  const _BorderedStatusCard({
    required this.color,
    required this.background,
    required this.title,
    required this.children,
  });

  final Color color;
  final Color background;
  final String title;
  final List<String> children;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.semiboldH8_16.copyWith(color: color)),
        if (children.length > 1) ...[
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.cool400),
        ],
        for (final child in children) ...[
          const SizedBox(height: 12),
          Text(
            child,
            style: AppTextStyles.mediumSH8_14.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ],
    ),
  );
}
