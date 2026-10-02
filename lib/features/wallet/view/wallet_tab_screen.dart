import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import '../model/cash_request_detail_status.dart';
import '../model/expense_claim_detail_status.dart';
import '../widgets/expense_claim_card.dart';
import '../widgets/expense_search_filters.dart';
import '../widgets/wallet_action_card.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_screen_header.dart';

class WalletTabScreen extends StatefulWidget {
  const WalletTabScreen({super.key});
  @override
  State<WalletTabScreen> createState() => _WalletTabScreenState();
}

class _WalletTabScreenState extends State<WalletTabScreen> {
  int _selectedClaimType = 0;
  int _selectedFilter = 0;
  late final LocalQueryController<
    ({
      WalletSummaryModel summary,
      List<ExpenseModel> expenses,
      List<CashRequestModel> cashRequests,
    })
  >
  _controller;

  @override
  void initState() {
    super.initState();
    _controller = LocalQueryController(() async {
      final values = await Future.wait([
        EerlLocalRepository.instance.getWalletSummary(),
        EerlLocalRepository.instance.getExpenses(),
        EerlLocalRepository.instance.getCashRequests(),
      ]);
      return (
        summary: values[0] as WalletSummaryModel,
        expenses: values[1] as List<ExpenseModel>,
        cashRequests: values[2] as List<CashRequestModel>,
      );
    })..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    body: SafeArea(
      bottom: false,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final data = _controller.data;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              AppScreenHeaderMetrics.topInset,
              20,
              130,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WalletScreenHeader(
                        title: context.l10n.walletFieldExpenses,
                      ),
                      const SizedBox(height: 24),
                      WalletBalanceCard(
                        balanceLabel: context.l10n.availableCashBalance,
                        balance:
                            '₹${(data?.summary.balanceNow ?? 0).toStringAsFixed(2)}',
                        spentLabel: context.l10n.todaysSpent,
                        spent:
                            '₹${(data?.summary.spent ?? 0).toStringAsFixed(2)}',
                        onRequestCash: () =>
                            context.push<void>(AppRoutes.requestCash),
                      ),
                      const SizedBox(height: 24),
                      WalletActionCard(
                        title: context.l10n.fieldSpendingPrompt,
                        description: context.l10n.fieldSpendingDescription,
                        buttonLabel: context.l10n.logExpense,
                        onPressed: () =>
                            context.push<void>(AppRoutes.logExpense),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        context.l10n.recentExpenseClaims,
                        style: AppTextStyles.semiboldH7_18,
                      ),
                      const SizedBox(height: 16),
                      ExpenseSearchFilters(
                        typeLabels: [
                          context.l10n.expenseTypeExpense,
                          context.l10n.expenseTypeCashRequest,
                        ],
                        selectedTypeIndex: _selectedClaimType,
                        onTypeSelected: (index) => setState(() {
                          _selectedClaimType = index;
                          _selectedFilter = 0;
                        }),
                        filters: [
                          context.l10n.filterAll,
                          context.l10n.filterToday,
                          context.l10n.filterYesterday,
                          context.l10n.filterLastWeek,
                        ],
                        selectedIndex: _selectedFilter,
                        onFilterSelected: (index) =>
                            setState(() => _selectedFilter = index),
                      ),
                      const SizedBox(height: 16),
                      if (_controller.isLoading && !_controller.hasData)
                        const Center(child: CircularProgressIndicator())
                      else if (_selectedClaimType == 0)
                        ..._expenseCards(data?.expenses ?? const [])
                      else
                        ..._cashCards(data?.cashRequests ?? const []),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );

  bool _matchesDate(String raw) {
    if (_selectedFilter == 0) return true;
    final date = DateTime.tryParse(raw)?.toLocal();
    if (date == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    return switch (_selectedFilter) {
      1 => day == today,
      2 => day == today.subtract(const Duration(days: 1)),
      _ => !day.isBefore(today.subtract(const Duration(days: 6))),
    };
  }

  List<Widget> _expenseCards(List<ExpenseModel> values) => [
    for (final item in values.where(
      (item) => _matchesDate(item.createdAt),
    )) ...[
      ExpenseClaimCard(
        title: item.categoryName ?? item.categoryId,
        date: _date(item.createdAt),
        amount: '₹${item.amount.toStringAsFixed(2)}',
        statusLabel: item.status,
        status: _claimStatus(item.status),
        onTap: () => _openExpenseClaim(_expenseStatus(item.status)),
      ),
      const SizedBox(height: 12),
    ],
  ];

  List<Widget> _cashCards(List<CashRequestModel> values) => [
    for (final item in values.where(
      (item) => _matchesDate(item.createdAt),
    )) ...[
      ExpenseClaimCard(
        title: item.reason ?? item.id,
        date: _date(item.createdAt),
        amount: '₹${item.amount.toStringAsFixed(2)}',
        statusLabel: item.status,
        status: _claimStatus(item.status),
        onTap: () => _openCashRequest(_cashStatus(item.status)),
      ),
      const SizedBox(height: 12),
    ],
  ];

  String _date(String value) {
    final date = DateTime.tryParse(value)?.toLocal();
    return date == null
        ? value
        : DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  ExpenseClaimStatus _claimStatus(String value) =>
      switch (value.toUpperCase()) {
        'APPROVED' || 'VERIFIED' || 'CREDITED' => ExpenseClaimStatus.verified,
        'REJECTED' || 'FLAGGED' => ExpenseClaimStatus.flagged,
        _ => ExpenseClaimStatus.pending,
      };

  ExpenseClaimDetailStatus _expenseStatus(String value) =>
      switch (value.toUpperCase()) {
        'APPROVED' || 'VERIFIED' => ExpenseClaimDetailStatus.verified,
        'REJECTED' => ExpenseClaimDetailStatus.rejected,
        _ => ExpenseClaimDetailStatus.pending,
      };

  CashRequestDetailStatus _cashStatus(String value) =>
      switch (value.toUpperCase()) {
        'APPROVED' || 'CREDITED' => CashRequestDetailStatus.approved,
        'REJECTED' => CashRequestDetailStatus.rejected,
        _ => CashRequestDetailStatus.pending,
      };

  void _openExpenseClaim(ExpenseClaimDetailStatus status) =>
      context.push<void>(AppRoutes.expenseClaimDetail, extra: status);
  void _openCashRequest(CashRequestDetailStatus status) =>
      context.push<void>(AppRoutes.cashRequestDetail, extra: status);
}
