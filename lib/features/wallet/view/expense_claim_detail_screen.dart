import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/expense_claim_detail_status.dart';
import '../widgets/expense_detail_cards.dart';
import '../widgets/wallet_screen_header.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';

class ExpenseClaimDetailScreen extends StatelessWidget {
  const ExpenseClaimDetailScreen({
    super.key,
    required this.status,
    required this.onBack,
  });

  final ExpenseClaimDetailStatus status;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statusLabel = switch (status) {
      ExpenseClaimDetailStatus.pending => l10n.expenseWaitingSupervisor,
      ExpenseClaimDetailStatus.verified => l10n.expenseVerifiedSupervisor,
      ExpenseClaimDetailStatus.rejected => l10n.expenseRejectedSupervisor,
    };

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            AppScreenHeaderMetrics.topInset,
            20,
            32,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppScreenHeader(
                      leading: WalletBackButton(onPressed: onBack),
                    ),
                    const SizedBox(height: 24),
                    ExpenseReferenceCard(reference: l10n.expenseClaimReference),
                    const SizedBox(height: 16),
                    ExpenseDetailCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExpenseDetailRow(
                            label: l10n.expenseDetailCategory,
                            value: l10n.expenseCategoryFuel,
                          ),
                          const _DetailDivider(),
                          ExpenseDetailRow(
                            label: l10n.expenseDetailAmount,
                            value: l10n.expenseDetailAmountValue,
                          ),
                          const _DetailDivider(),
                          ExpenseDetailRow(
                            label: l10n.expenseRequestedBy,
                            value: l10n.expenseRequestedByValue,
                          ),
                          const _DetailDivider(),
                          ExpenseDetailRow(
                            label: l10n.expenseDateTime,
                            value: l10n.expenseFuelDate,
                          ),
                          const _DetailDivider(),
                          Text(
                            l10n.expenseRequestStatus,
                            style: AppTextStyles.semiboldH9_14.copyWith(
                              color: AppColors.neutral950,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ExpenseDetailStatusChip(
                            status: status,
                            label: statusLabel,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ExpenseDetailCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.expenseUploadedPhoto,
                            style: AppTextStyles.semiboldH7_18.copyWith(
                              color: AppColors.neutral950,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: const [
                              _ExpensePhoto(
                                asset:
                                    'assets/images/expense_detail_vehicle.png',
                              ),
                              SizedBox(width: 12),
                              _ExpensePhoto(
                                asset:
                                    'assets/images/expense_detail_receipt.png',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ExpenseDetailCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.expenseDescriptionLabel,
                            style: AppTextStyles.semiboldH7_18.copyWith(
                              color: AppColors.neutral950,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.expenseDetailDescription,
                            style: AppTextStyles.mediumSH9_12.copyWith(
                              color: AppColors.neutral900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (status == ExpenseClaimDetailStatus.rejected) ...[
                      const SizedBox(height: 20),
                      ExpenseDetailCard(
                        border: AppColors.red500,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.expenseRejectReasonTitle,
                              style: AppTextStyles.semiboldH7_18.copyWith(
                                color: AppColors.neutral950,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: AppColors.cool400),
                            const SizedBox(height: 12),
                            _LabeledParagraph(
                              label: l10n.expenseRejectReasonLabel,
                              value: l10n.expenseRejectReasonValue,
                            ),
                            const SizedBox(height: 8),
                            _LabeledParagraph(
                              label: l10n.expenseRejectRemarksLabel,
                              value: l10n.expenseRejectRemarksValue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailDivider extends StatelessWidget {
  const _DetailDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: AppColors.cool400),
    );
  }
}

class _ExpensePhoto extends StatelessWidget {
  const _ExpensePhoto({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(asset, width: 109, height: 70, fit: BoxFit.cover),
    );
  }
}

class _LabeledParagraph extends StatelessWidget {
  const _LabeledParagraph({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '$label : ',
        style: const TextStyle(fontWeight: FontWeight.w600),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
      style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral950),
    );
  }
}
