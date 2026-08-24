import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/expense_claim_detail_status.dart';
import '../widgets/expense_claim_card.dart';
import '../widgets/expense_search_filters.dart';
import '../widgets/wallet_action_card.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_screen_header.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';

class WalletTabScreen extends StatefulWidget {
  const WalletTabScreen({
    super.key,
    this.onBack,
    this.onLogExpense,
    this.onClaimTap,
  });

  final VoidCallback? onBack;
  final VoidCallback? onLogExpense;
  final ValueChanged<ExpenseClaimDetailStatus>? onClaimTap;

  @override
  State<WalletTabScreen> createState() => _WalletTabScreenState();
}

class _WalletTabScreenState extends State<WalletTabScreen> {
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: ListView(
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
                      title: l10n.walletFieldExpenses,
                      onBack: widget.onBack ?? () {},
                    ),
                    const SizedBox(height: 24),
                    WalletBalanceCard(
                      balanceLabel: l10n.availableCashBalance,
                      balance: l10n.availableCashBalanceValue,
                      spentLabel: l10n.todaysSpent,
                      spent: l10n.todaysSpentValue,
                    ),
                    const SizedBox(height: 24),
                    WalletActionCard(
                      title: l10n.fieldSpendingPrompt,
                      description: l10n.fieldSpendingDescription,
                      buttonLabel: l10n.logExpense,
                      onPressed: widget.onLogExpense ?? () {},
                    ),
                    const SizedBox(height: 32),
                    Text(
                      l10n.recentExpenseClaims,
                      style: AppTextStyles.semiboldH7_18.copyWith(
                        color: AppColors.neutral950,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ExpenseSearchFilters(
                      searchHint: l10n.expenseSearchHint,
                      filters: [
                        l10n.filterAll,
                        l10n.filterPending,
                        l10n.filterClosed,
                      ],
                      selectedIndex: _selectedFilter,
                      onFilterSelected: (index) {
                        setState(() => _selectedFilter = index);
                      },
                    ),
                    const SizedBox(height: 16),
                    ExpenseClaimCard(
                      title: l10n.expenseFuelDiesel,
                      date: l10n.expenseFuelDate,
                      amount: l10n.expenseFuelAmount,
                      statusLabel: l10n.expensePendingSupervisor,
                      status: ExpenseClaimStatus.pending,
                      onTap: () => widget.onClaimTap?.call(
                        ExpenseClaimDetailStatus.pending,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ExpenseClaimCard(
                      title: l10n.expenseScaleFee,
                      date: l10n.expenseScaleDate,
                      amount: l10n.expenseScaleAmount,
                      statusLabel: l10n.expenseVerified,
                      status: ExpenseClaimStatus.verified,
                      onTap: () => widget.onClaimTap?.call(
                        ExpenseClaimDetailStatus.verified,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ExpenseClaimCard(
                      title: l10n.expenseVehicleMaintenance,
                      date: l10n.expenseVehicleDate,
                      amount: l10n.expenseVehicleAmount,
                      statusLabel: l10n.expenseFlagged,
                      status: ExpenseClaimStatus.flagged,
                      onTap: () => widget.onClaimTap?.call(
                        ExpenseClaimDetailStatus.rejected,
                      ),
                    ),
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
