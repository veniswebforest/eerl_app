import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/shared/widgets/cached_app_image.dart';
import '../model/expense_claim_detail_status.dart';
import '../widgets/expense_detail_cards.dart';
import '../widgets/wallet_screen_header.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';

class ExpenseClaimDetailScreen extends StatefulWidget {
  const ExpenseClaimDetailScreen({
    super.key,
    required this.status,
    this.expense,
  });

  final ExpenseClaimDetailStatus status;
  final ExpenseModel? expense;

  @override
  State<ExpenseClaimDetailScreen> createState() =>
      _ExpenseClaimDetailScreenState();
}

class _ExpenseClaimDetailScreenState extends State<ExpenseClaimDetailScreen> {
  Future<List<String>>? _receiptSources;

  @override
  void initState() {
    super.initState();
    _loadReceiptSources();
  }

  @override
  void didUpdateWidget(covariant ExpenseClaimDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expense?.id != widget.expense?.id) {
      _loadReceiptSources();
    }
  }

  void _loadReceiptSources() {
    final expense = widget.expense;
    _receiptSources = expense == null
        ? null
        : EerlLocalRepository.instance.getExpenseReceiptSources(expense.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final expense = widget.expense;
    final statusLabel = switch (widget.status) {
      ExpenseClaimDetailStatus.pending => l10n.expenseWaitingSupervisor,
      ExpenseClaimDetailStatus.verified => l10n.expenseVerifiedSupervisor,
      ExpenseClaimDetailStatus.rejected => l10n.expenseRejectedSupervisor,
    };
    final category = _valueOrFallback(
      expense?.categoryName,
      fallback: expense?.categoryId,
    );
    final requestedBy = _valueOrFallback(
      expense?.userName,
      fallback: expense?.userId,
    );
    final note = expense?.note?.trim();

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
                    ExpenseReferenceCard(
                      reference: _valueOrFallback(
                        expense?.number,
                        fallback: expense?.id,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ExpenseDetailCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ExpenseDetailRow(
                            label: l10n.expenseDetailCategory,
                            value: category,
                          ),
                          const _DetailDivider(),
                          ExpenseDetailRow(
                            label: l10n.expenseDetailAmount,
                            value: expense == null
                                ? '—'
                                : NumberFormat.currency(
                                    locale: 'en_IN',
                                    symbol: '₹',
                                    decimalDigits: 2,
                                  ).format(expense.amount),
                          ),
                          const _DetailDivider(),
                          ExpenseDetailRow(
                            label: l10n.expenseRequestedBy,
                            value: requestedBy,
                          ),
                          const _DetailDivider(),
                          ExpenseDetailRow(
                            label: l10n.expenseDateTime,
                            value: _formattedDate(expense?.createdAt),
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
                            status: widget.status,
                            label: statusLabel,
                          ),
                        ],
                      ),
                    ),
                    if (_receiptSources != null) ...[
                      const SizedBox(height: 16),
                      _ExpensePhotosCard(sources: _receiptSources!),
                    ],
                    if (note?.isNotEmpty == true) ...[
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
                              note!,
                              style: AppTextStyles.mediumSH9_12.copyWith(
                                color: AppColors.neutral900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (widget.status == ExpenseClaimDetailStatus.rejected &&
                        expense?.decisionReason?.trim().isNotEmpty == true) ...[
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
                              value: expense!.decisionReason!.trim(),
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
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: AppColors.cool400),
    );
  }
}

class _ExpensePhotosCard extends StatelessWidget {
  const _ExpensePhotosCard({required this.sources});

  final Future<List<String>> sources;

  @override
  Widget build(BuildContext context) => FutureBuilder<List<String>>(
    future: sources,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const ExpenseDetailCard(
          child: Center(child: CircularProgressIndicator()),
        );
      }
      final values = snapshot.data ?? const <String>[];
      if (values.isEmpty) return const SizedBox.shrink();
      return ExpenseDetailCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.expenseUploadedPhoto,
              style: AppTextStyles.semiboldH7_18.copyWith(
                color: AppColors.neutral950,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final source in values) _ExpensePhoto(source: source),
              ],
            ),
          ],
        ),
      );
    },
  );
}

class _ExpensePhoto extends StatelessWidget {
  const _ExpensePhoto({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: CachedAppImage(
        source: source,
        width: 109,
        height: 70,
        fit: BoxFit.cover,
      ),
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
