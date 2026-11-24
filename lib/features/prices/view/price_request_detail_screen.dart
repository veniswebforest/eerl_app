import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/prices/model/price_ui_models.dart';
import 'package:eerl_app/features/prices/view/ask_price_change_screen.dart';
import 'package:eerl_app/features/prices/widgets/prices_ui.dart';

class PriceRequestDetailScreen extends StatelessWidget {
  const PriceRequestDetailScreen({required this.request, super.key});

  final PriceRequestModel request;

  @override
  Widget build(BuildContext context) {
    final state = _state(request.status);
    return PricesPageFrame(
      title: context.l10n.priceRequestTitle,
      bottom: state == PriceRequestState.rejected
          ? PrimaryPriceButton(
              label: context.l10n.priceRequestAskAgain,
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => AskPriceChangeScreen(
                    requestContext: PriceRequestContext(
                      itemId: request.itemId,
                      itemName: request.itemName ?? request.itemId,
                      unitCode: request.unitCode ?? 'KG',
                      currentRate: request.currentRate,
                      fromName: request.currentFromName,
                      fromLevel: request.currentFromLevel,
                    ),
                  ),
                ),
              ),
            )
          : null,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          PriceMaterialCard(material: _material(context), onTap: () {}),
          const SizedBox(height: 16),
          _RequestDetailsCard(request: request),
          const SizedBox(height: 16),
          _RequestStatusCard(request: request, state: state),
        ],
      ),
    );
  }

  PriceMaterialUiModel _material(BuildContext context) => PriceMaterialUiModel(
    kind: PriceMaterialKind.pet,
    itemId: request.itemId,
    name: request.itemName ?? request.itemId,
    categoryName: '',
    unitCode: request.unitCode ?? 'KG',
    rate: request.currentRate,
    source: _source(context, request),
    accent: AppColors.purple,
    background: AppColors.purpleLight,
    iconAsset: '$pricesAssetPath/pet.svg',
    openIconAsset: '$pricesAssetPath/open_purple.svg',
  );
}

class _RequestDetailsCard extends StatelessWidget {
  const _RequestDetailsCard({required this.request});
  final PriceRequestModel request;

  @override
  Widget build(BuildContext context) {
    final unit = request.unitCode ?? 'KG';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _DetailRow(
            label: context.l10n.priceRequestPriceNow,
            value: context.l10n.priceRequestCurrentValueDynamic(
              _rate(request.currentRate),
              unit,
              _source(context, request),
            ),
          ),
          _DetailRow(
            label: context.l10n.priceRequestYouAskedFor,
            value: context.l10n.priceRequestAskedValueDynamic(
              _rate(request.requestedRate),
              unit,
              _percent(request.currentRate, request.requestedRate),
            ),
          ),
          _DetailRow(
            label: context.l10n.priceRequestWhy,
            value: request.reason,
          ),
          _DetailRow(
            label: context.l10n.priceRequestAsked,
            value: context.l10n.priceRequestAskedByDynamic(
              request.raisedByName,
              _dateTime(context, request.raisedAt),
            ),
            showDivider: false,
          ),
        ],
      ),
    );
  }
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
  const _RequestStatusCard({required this.request, required this.state});
  final PriceRequestModel request;
  final PriceRequestState state;

  @override
  Widget build(BuildContext context) {
    if (state == PriceRequestState.waiting) {
      return _BorderedStatusCard(
        color: const Color(0xFFEDA833),
        background: const Color(0xFFFFFAF0),
        title: context.l10n.priceRequestWaitingForHead,
        children: [
          context.l10n.priceRequestWaitingMessageDynamic(
            _rate(request.currentRate),
            request.unitCode ?? 'KG',
            request.itemName ?? request.itemId,
          ),
        ],
      );
    }
    if (state == PriceRequestState.approved) {
      return _BorderedStatusCard(
        color: AppColors.primary500,
        background: AppColors.primary50,
        title: context.l10n.priceRequestApproved,
        children: [
          if (request.decidedByName?.trim().isNotEmpty == true)
            context.l10n.priceRequestApprovedByPerson(request.decidedByName!),
        ],
      );
    }
    return _BorderedStatusCard(
      color: AppColors.red500,
      background: AppColors.neutral50,
      title: context.l10n.priceRequestRejected,
      children: [
        if (request.decidedByName?.trim().isNotEmpty == true)
          context.l10n.priceRequestRejectedByPerson(
            request.decidedByName!,
            _dateTime(context, request.decidedAt ?? request.updatedAt),
          ),
        if (request.rejectionReason?.trim().isNotEmpty == true)
          context.l10n.priceRequestReasonValue(request.rejectionReason!),
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

PriceRequestState _state(String value) => switch (value) {
  'PENDING' => PriceRequestState.waiting,
  'APPROVED' => PriceRequestState.approved,
  _ => PriceRequestState.rejected,
};

String _rate(double? value) => value?.toStringAsFixed(2) ?? '0.00';

String _percent(double? current, double requested) {
  if (current == null || current == 0) return '+0.0%';
  final value = ((requested - current) / current) * 100;
  return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}%';
}

String _source(BuildContext context, PriceRequestModel request) {
  final name = request.currentFromName?.trim();
  if (name == null || name.isEmpty) return context.l10n.pricesOwnPrice;
  final level = request.currentFromLevel?.trim().replaceAll('_', ' ') ?? '';
  return context.l10n.pricesFromSource(name, level);
}

String _dateTime(BuildContext context, String value) {
  final parsed = DateTime.tryParse(value)?.toLocal();
  if (parsed == null) return value;
  return DateFormat(
    'd MMM, h:mm a',
    Localizations.localeOf(context).toString(),
  ).format(parsed);
}
