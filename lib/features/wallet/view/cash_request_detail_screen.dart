import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/wallet/model/cash_request_detail_status.dart';
import 'package:eerl_app/features/wallet/widgets/cash_request_detail_status_chip.dart';
import 'package:eerl_app/features/wallet/widgets/expense_detail_cards.dart';
import 'package:eerl_app/features/wallet/widgets/wallet_screen_header.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';

class CashRequestDetailScreen extends StatelessWidget {
  const CashRequestDetailScreen({
    super.key,
    required this.status,
    required this.cashRequest,
  });

  final CashRequestDetailStatus status;
  final CashRequestModel cashRequest;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reference = _valueOrFallback(
      cashRequest.number,
      fallback: cashRequest.id,
    );
    final category = _valueOrFallback(cashRequest.reason);
    final statusLabel = switch (status) {
      CashRequestDetailStatus.pending => l10n.cashDetailWaitingApproval,
      CashRequestDetailStatus.approved => l10n.cashDetailApprovedSupervisor,
      CashRequestDetailStatus.rejected => l10n.expenseRejectedSupervisor,
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
                      leading: WalletBackButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ExpenseReferenceCard(reference: reference),
                    const SizedBox(height: 16),
                    ExpenseDetailCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExpenseDetailRow(
                            label: status == CashRequestDetailStatus.pending
                                ? l10n.cashDetailRequestReason
                                : l10n.expenseDetailCategory,
                            value: category,
                          ),
                          const _DetailDivider(),
                          ExpenseDetailRow(
                            label: l10n.expenseDetailAmount,
                            value: NumberFormat.currency(
                              locale: 'en_IN',
                              symbol: '₹',
                              decimalDigits: 2,
                            ).format(cashRequest.amount),
                          ),
                          const _DetailDivider(),
                          ExpenseDetailRow(
                            label: l10n.expenseRequestedBy,
                            value: _valueOrFallback(
                              cashRequest.requestedByName,
                              fallback: cashRequest.requestedBy,
                            ),
                          ),
                          const _DetailDivider(),
                          ExpenseDetailRow(
                            label: l10n.expenseDateTime,
                            value: _formattedDate(cashRequest.createdAt),
                          ),
                          const _DetailDivider(),
                          Text(
                            l10n.expenseRequestStatus,
                            style: AppTextStyles.semiboldH9_14.copyWith(
                              color: AppColors.neutral950,
                            ),
                          ),
                          const SizedBox(height: 6),
                          CashRequestDetailStatusChip(
                            status: status,
                            label: statusLabel,
                          ),
                          if (status == CashRequestDetailStatus.approved) ...[
                            const SizedBox(height: 8),
                            Text(
                              l10n.cashDetailApprovedNote(
                                NumberFormat.currency(
                                  locale: 'en_IN',
                                  symbol: '₹',
                                  decimalDigits: 2,
                                ).format(cashRequest.amount),
                              ),
                              style: AppTextStyles.mediumSH9_12.copyWith(
                                color: AppColors.neutral700,
                              ),
                            ),
                          ],
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
                            _valueOrFallback(cashRequest.reason),
                            style: AppTextStyles.mediumSH9_12.copyWith(
                              color: AppColors.neutral900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (status == CashRequestDetailStatus.rejected) ...[
                      const SizedBox(height: 16),
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
                              value: _valueOrFallback(cashRequest.decisionNote),
                            ),
                            if (cashRequest.decisionRemarks
                                    ?.trim()
                                    .isNotEmpty ==
                                true) ...[
                              const SizedBox(height: 8),
                              _LabeledParagraph(
                                label: l10n.expenseRejectRemarksLabel,
                                value: cashRequest.decisionRemarks!.trim(),
                              ),
                            ],
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

  String _valueOrFallback(String? value, {String? fallback}) {
    final normalized = value?.trim();
    if (normalized?.isNotEmpty == true) return normalized!;
    final normalizedFallback = fallback?.trim();
    return normalizedFallback?.isNotEmpty == true ? normalizedFallback! : '—';
  }

  String _formattedDate(String? value) {
    final date = value == null ? null : DateTime.tryParse(value)?.toLocal();
    if (date == null) return _valueOrFallback(value);
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }
}

class _DetailDivider extends StatelessWidget {
  const _DetailDivider();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 12),
    child: Divider(height: 1, color: AppColors.cool400),
  );
}

class _LabeledParagraph extends StatelessWidget {
  const _LabeledParagraph({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Text.rich(
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
