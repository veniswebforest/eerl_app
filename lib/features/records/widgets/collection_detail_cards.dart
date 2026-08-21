import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class CollectionDetailInfoCard extends StatelessWidget {
  const CollectionDetailInfoCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });
  final String label;
  final String value;
  final Widget? icon;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x17000000),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.semiboldH8_16.copyWith(color: AppColors.cool600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 6)],
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.boldH8_14.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class CollectionSummaryCard extends StatelessWidget {
  const CollectionSummaryCard({
    super.key,
    required this.collectionLabel,
    required this.verifiedLabel,
    required this.comparisonLabel,
    required this.comparisonHint,
    required this.totalPriceLabel,
  });
  final String collectionLabel;
  final String verifiedLabel;
  final String comparisonLabel;
  final String comparisonHint;
  final String totalPriceLabel;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x17000000),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        _SummaryRow(collectionLabel, '810.00 KG'),
        const SizedBox(height: 10),
        _SummaryRow(verifiedLabel, '790.00 KG'),
        const Divider(height: 18, color: AppColors.primary800),
        _SummaryRow(comparisonLabel, '-20.00 KG', hint: comparisonHint),
        const Divider(height: 18, color: AppColors.primary800),
        _SummaryRow(totalPriceLabel, '₹35,550.00', highlight: true),
      ],
    ),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(
    this.label,
    this.value, {
    this.hint,
    this.highlight = false,
  });
  final String label;
  final String value;
  final String? hint;
  final bool highlight;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style:
                  (highlight
                          ? AppTextStyles.boldH6_20
                          : AppTextStyles.mediumSH9_12)
                      .copyWith(
                        color: highlight
                            ? AppColors.primary500
                            : AppColors.neutral950,
                      ),
            ),
            if (hint != null)
              Text(
                hint!,
                style: AppTextStyles.mediumSH9_12.copyWith(
                  fontSize: 10,
                  color: AppColors.neutral500,
                ),
              ),
          ],
        ),
      ),
      Text(
        value,
        style: (highlight ? AppTextStyles.boldH6_20 : AppTextStyles.boldH8_14)
            .copyWith(
              color: highlight ? AppColors.primary500 : AppColors.neutral950,
            ),
      ),
    ],
  );
}
