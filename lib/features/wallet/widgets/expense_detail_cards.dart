import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/expense_claim_detail_status.dart';
import 'wallet_assets.dart';

class ExpenseDetailCard extends StatelessWidget {
  const ExpenseDetailCard({super.key, required this.child, this.border});

  final Widget child;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: border == null ? null : Border.all(color: border!),
        boxShadow: border == null
            ? const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

class ExpenseReferenceCard extends StatelessWidget {
  const ExpenseReferenceCard({super.key, required this.reference});

  final String reference;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset(WalletAssets.expenseClaimCurrency),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              reference,
              style: AppTextStyles.semiboldH8_16.copyWith(
                color: AppColors.neutral900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExpenseDetailRow extends StatelessWidget {
  const ExpenseDetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.semiboldH9_14.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '•',
              style: AppTextStyles.semiboldH9_14.copyWith(
                color: AppColors.neutral950,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.semiboldH9_14.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ExpenseDetailStatusChip extends StatelessWidget {
  const ExpenseDetailStatusChip({
    super.key,
    required this.status,
    required this.label,
  });

  final ExpenseClaimDetailStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (icon, foreground, background) = switch (status) {
      ExpenseClaimDetailStatus.pending => (
        WalletAssets.statusPending,
        AppColors.yellow600,
        AppColors.yellow50,
      ),
      ExpenseClaimDetailStatus.verified => (
        WalletAssets.statusVerified,
        AppColors.primary500,
        AppColors.primary100,
      ),
      ExpenseClaimDetailStatus.rejected => (
        WalletAssets.statusFlagged,
        AppColors.red500,
        AppColors.red50,
      ),
    };

    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(icon, width: 20, height: 20),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              style: AppTextStyles.semiboldH10_12.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
