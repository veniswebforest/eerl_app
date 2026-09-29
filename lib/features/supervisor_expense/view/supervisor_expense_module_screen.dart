import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/supervisor_expense/model/supervisor_expense_item.dart';
import 'package:eerl_app/features/supervisor_expense/widgets/supervisor_expense_widgets.dart';
import 'package:eerl_app/features/supervisor_category_request/view/supervisor_category_request_screen.dart';
import 'package:eerl_app/features/wallet/model/expense_claim_detail_status.dart';
import 'package:eerl_app/features/wallet/widgets/expense_detail_cards.dart';
import 'package:eerl_app/features/wallet/widgets/wallet_assets.dart';
import 'package:eerl_app/features/wallet/widgets/wallet_screen_header.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';

enum _ExpensePage {
  list,
  expenseDetail,
  expenseReject,
  cashDetail,
  cashReject,
  categoryRequests,
}

class SupervisorExpenseModuleScreen extends StatefulWidget {
  const SupervisorExpenseModuleScreen({super.key});

  @override
  State<SupervisorExpenseModuleScreen> createState() =>
      _SupervisorExpenseModuleScreenState();
}

class _SupervisorExpenseModuleScreenState
    extends State<SupervisorExpenseModuleScreen> {
  _ExpensePage _page = _ExpensePage.list;
  SupervisorExpenseStatus _detailStatus = SupervisorExpenseStatus.pending;
  SupervisorExpenseStatus _cashDetailStatus = SupervisorExpenseStatus.pending;
  bool? _toastApproved;

  void _openDetail(SupervisorExpenseStatus status) => setState(() {
    _detailStatus = status;
    _page = _ExpensePage.expenseDetail;
    _toastApproved = null;
  });

  void _openCashDetail(SupervisorExpenseStatus status) => setState(() {
    _cashDetailStatus = status;
    _page = _ExpensePage.cashDetail;
    _toastApproved = null;
  });

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _page == _ExpensePage.list,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _handleBack();
    },
    child: switch (_page) {
      _ExpensePage.list => _ExpenseListScreen(
        onTap: _openDetail,
        onCashTap: _openCashDetail,
        onCategoryRequests: () =>
            setState(() => _page = _ExpensePage.categoryRequests),
        toastApproved: _toastApproved,
        onDismissToast: () => setState(() => _toastApproved = null),
      ),
      _ExpensePage.expenseDetail => _ExpenseDetailScreen(
        status: _detailStatus,
        onBack: () => setState(() => _page = _ExpensePage.list),
        onApprove: () => setState(() {
          _toastApproved = true;
          _page = _ExpensePage.list;
        }),
        onReject: () => setState(() => _page = _ExpensePage.expenseReject),
      ),
      _ExpensePage.expenseReject => _RejectExpenseScreen(
        cashRequest: false,
        onBack: () => setState(() => _page = _ExpensePage.expenseDetail),
        onConfirm: () => setState(() {
          _toastApproved = false;
          _page = _ExpensePage.list;
        }),
      ),
      _ExpensePage.cashDetail => _CashRequestDetailScreen(
        status: _cashDetailStatus,
        onBack: () => setState(() => _page = _ExpensePage.list),
        onApprove: () => setState(
          () => _cashDetailStatus = SupervisorExpenseStatus.approved,
        ),
        onReject: () => setState(() => _page = _ExpensePage.cashReject),
      ),
      _ExpensePage.cashReject => _RejectExpenseScreen(
        cashRequest: true,
        onBack: () => setState(() => _page = _ExpensePage.cashDetail),
        onConfirm: () => setState(() {
          _cashDetailStatus = SupervisorExpenseStatus.rejected;
          _page = _ExpensePage.cashDetail;
        }),
      ),
      _ExpensePage.categoryRequests => SupervisorCategoryRequestScreen(
        onBack: () => setState(() => _page = _ExpensePage.list),
      ),
    },
  );

  void _handleBack() => setState(() {
    _page = switch (_page) {
      _ExpensePage.expenseReject => _ExpensePage.expenseDetail,
      _ExpensePage.cashReject => _ExpensePage.cashDetail,
      _ => _ExpensePage.list,
    };
  });
}

class _ExpenseListScreen extends StatefulWidget {
  const _ExpenseListScreen({
    required this.onTap,
    required this.onCashTap,
    required this.onCategoryRequests,
    required this.toastApproved,
    required this.onDismissToast,
  });
  final ValueChanged<SupervisorExpenseStatus> onTap;
  final ValueChanged<SupervisorExpenseStatus> onCashTap;
  final VoidCallback onCategoryRequests;
  final bool? toastApproved;
  final VoidCallback onDismissToast;
  @override
  State<_ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<_ExpenseListScreen> {
  int _filter = 0;
  int _type = 0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = [
      SupervisorExpenseItem(
        agentName: l.supervisorExpenseRahul,
        role: l.supervisorExpenseAgentRole,
        category: l.supervisorExpenseLaborCost,
        date: l.supervisorExpenseYesterdayMorning,
        amount: l.supervisorExpenseAmount4000,
        status: SupervisorExpenseStatus.pending,
      ),
      SupervisorExpenseItem(
        agentName: l.supervisorExpenseDarshan,
        role: l.supervisorExpenseAgentRole,
        category: l.expenseFuelDiesel,
        date: l.supervisorExpenseMayDate,
        amount: l.supervisorExpenseAmount1500,
        status: SupervisorExpenseStatus.rejected,
      ),
      SupervisorExpenseItem(
        agentName: l.supervisorExpenseDarshan,
        role: l.supervisorExpenseAgentRole,
        category: l.expenseFuelDiesel,
        date: l.supervisorExpenseYesterdayLate,
        amount: l.supervisorExpenseAmount720,
        status: SupervisorExpenseStatus.approved,
      ),
    ];
    final cashItems = [
      SupervisorExpenseItem(
        agentName: l.supervisorExpenseRahul,
        role: l.supervisorExpenseAgentRole,
        category: l.cashReasonEmergencyFuel,
        date: l.supervisorCashTodayMorning,
        amount: l.supervisorCashAmount350,
        status: SupervisorExpenseStatus.pending,
      ),
      SupervisorExpenseItem(
        agentName: l.supervisorExpenseRahul,
        role: l.supervisorExpenseAgentRole,
        category: l.cashReasonDailyAdvance,
        date: l.supervisorCashTodayMorning,
        amount: l.supervisorCashAmount350,
        status: SupervisorExpenseStatus.pending,
      ),
      SupervisorExpenseItem(
        agentName: l.supervisorCashDarshan,
        role: l.supervisorExpenseAgentRole,
        category: l.cashReasonDailyAdvance,
        date: l.supervisorExpenseMayDate,
        amount: l.supervisorCashAmount2400,
        status: SupervisorExpenseStatus.rejected,
      ),
      SupervisorExpenseItem(
        agentName: l.supervisorExpenseRahul,
        role: l.supervisorExpenseAgentRole,
        category: l.cashReasonBulkPurchase,
        date: l.supervisorCashTodayMorning,
        amount: l.supervisorCashAmount3250,
        status: SupervisorExpenseStatus.approved,
      ),
    ];
    final sourceItems = _type == 0 ? items : cashItems;
    final shown = sourceItems
        .where(
          (e) =>
              _filter == 0 ||
              (_filter == 1
                  ? e.status == SupervisorExpenseStatus.pending
                  : e.status != SupervisorExpenseStatus.pending),
        )
        .toList();
    return Scaffold(
      key: const Key('supervisor-expense-list-screen'),
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                AppScreenHeaderMetrics.topInset,
                20,
                32,
              ),
              children: [
                if (widget.toastApproved == null) ...[
                  AppScreenHeader(
                    leading: WalletBackButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    title: l.supervisorApprovalsClaims,
                  ),
                  const SizedBox(height: 16),
                  _ExpenseSegmentedControl(
                    selectedIndex: _type,
                    expenseLabel: l.expenseTypeExpense,
                    cashRequestLabel: l.expenseTypeCashRequest,
                    onSelected: (value) => setState(() => _type = value),
                  ),
                  const SizedBox(height: 16),
                  _ExpenseSearchField(hint: l.supervisorExpenseSearchHint),
                ] else ...[
                  SupervisorExpenseToast(
                    approved: widget.toastApproved!,
                    title: widget.toastApproved!
                        ? l.supervisorExpenseApprovedTitle
                        : l.supervisorExpenseRejectedTitle,
                    message: widget.toastApproved!
                        ? l.supervisorExpenseApprovedMessage
                        : l.supervisorExpenseRejectedMessage,
                    onClose: widget.onDismissToast,
                  ),
                  const SizedBox(height: 12),
                  _ExpenseSearchField(hint: l.supervisorExpenseSearchHint),
                  const SizedBox(height: 16),
                  _ExpenseSegmentedControl(
                    selectedIndex: _type,
                    expenseLabel: l.expenseTypeExpense,
                    cashRequestLabel: l.expenseTypeCashRequest,
                    onSelected: (value) => setState(() => _type = value),
                  ),
                ],
                const SizedBox(height: 12),
                _ExpenseFilters(
                  labels: [l.filterAll, l.filterPending, l.filterClosed],
                  selectedIndex: _filter,
                  onSelected: (value) => setState(() => _filter = value),
                ),
                const SizedBox(height: 16),
                if (_type == 0) ...[
                  if (widget.toastApproved == null) ...[
                    _CategoryRequestsCard(
                      title: l.supervisorExpenseNewCategories,
                      subtitle: l.supervisorExpenseReviewCategories,
                      buttonLabel: l.supervisorExpenseViewRequests,
                      onPressed: widget.onCategoryRequests,
                    ),
                    const SizedBox(height: 16),
                  ],
                  for (final item in shown) ...[
                    SupervisorExpenseCard(
                      item: item,
                      statusLabel: switch (item.status) {
                        SupervisorExpenseStatus.pending =>
                          l.supervisorExpensePendingReview,
                        SupervisorExpenseStatus.approved =>
                          l.transferStatusApproved,
                        SupervisorExpenseStatus.rejected =>
                          l.transferStatusRejected,
                      },
                      onTap: () => widget.onTap(item.status),
                    ),
                    const SizedBox(height: 12),
                  ],
                ] else ...[
                  for (final entry in shown.asMap().entries) ...[
                    SupervisorExpenseCard(
                      item: entry.value,
                      cardKey: ValueKey(
                        'supervisor-cash-${entry.value.status.name}-${entry.key}',
                      ),
                      statusLabel: switch (entry.value.status) {
                        SupervisorExpenseStatus.pending =>
                          l.supervisorExpensePendingReview,
                        SupervisorExpenseStatus.approved =>
                          l.supervisorCashApprovedCredited,
                        SupervisorExpenseStatus.rejected =>
                          l.transferStatusRejected,
                      },
                      onTap: () => widget.onCashTap(entry.value.status),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpenseSegmentedControl extends StatelessWidget {
  const _ExpenseSegmentedControl({
    required this.selectedIndex,
    required this.expenseLabel,
    required this.cashRequestLabel,
    required this.onSelected,
  });

  final int selectedIndex;
  final String expenseLabel;
  final String cashRequestLabel;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [HomeStyles.cardShadow],
    ),
    child: Row(
      children: [
        Expanded(
          child: _Segment(
            label: expenseLabel,
            selected: selectedIndex == 0,
            onTap: () => onSelected(0),
          ),
        ),
        Expanded(
          child: _Segment(
            label: cashRequestLabel,
            selected: selectedIndex == 1,
            onTap: () => onSelected(1),
          ),
        ),
      ],
    ),
  );
}

class _Segment extends StatelessWidget {
  const _Segment({
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
    child: Container(
      height: 44,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary500 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.semiboldH9_14.copyWith(
          color: selected ? Colors.white : AppColors.neutral950,
        ),
      ),
    ),
  );
}

class _ExpenseSearchField extends StatelessWidget {
  const _ExpenseSearchField({required this.hint});
  final String hint;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 55,
    child: TextField(
      style: AppTextStyles.mediumSH8_14,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(15),
          child: SvgPicture.asset(WalletAssets.search),
        ),
        hintText: hint,
        hintStyle: AppTextStyles.mediumSH8_14.copyWith(
          color: AppColors.neutral400,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cool400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cool400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary500),
        ),
      ),
    ),
  );
}

class _ExpenseFilters extends StatelessWidget {
  const _ExpenseFilters({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Row(
    // spacing: 8,
    // runSpacing: 8,direction: Axis.horizontal,
    children: labels.asMap().entries.map((entry) {
      final selected = selectedIndex == entry.key;
      return InkWell(
        onTap: () => onSelected(entry.key),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: EdgeInsetsGeometry.symmetric(horizontal: 4),
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary500 : AppColors.cool200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            entry.value,
            style: AppTextStyles.semiboldH10_12.copyWith(
              color: selected ? Colors.white : AppColors.neutral950,
            ),
          ),
        ),
      );
    }).toList(),
  );
}

class _CategoryRequestsCard extends StatelessWidget {
  const _CategoryRequestsCard({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [HomeStyles.cardShadow],
    ),
    child: Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondary100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: SvgPicture.asset(
                  WalletAssets.newCategoryRequest,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.semiboldH7_18),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.regularB8_12.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.yellow600,
                shape: BoxShape.circle,
              ),
              child: Text(
                '2',
                style: AppTextStyles.boldH9_12.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(buttonLabel, style: AppTextStyles.semiboldH8_16),
          ),
        ),
      ],
    ),
  );
}

class _ExpenseDetailScreen extends StatelessWidget {
  const _ExpenseDetailScreen({
    required this.status,
    required this.onBack,
    required this.onApprove,
    required this.onReject,
  });
  final SupervisorExpenseStatus status;
  final VoidCallback onBack;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pending = status == SupervisorExpenseStatus.pending;
    final detailStatus = switch (status) {
      SupervisorExpenseStatus.pending => ExpenseClaimDetailStatus.pending,
      SupervisorExpenseStatus.approved => ExpenseClaimDetailStatus.verified,
      SupervisorExpenseStatus.rejected => ExpenseClaimDetailStatus.rejected,
    };
    final statusText = switch (status) {
      SupervisorExpenseStatus.pending => l.expenseWaitingSupervisor,
      SupervisorExpenseStatus.approved => l.expenseVerifiedSupervisor,
      SupervisorExpenseStatus.rejected => l.expenseRejectedSupervisor,
    };
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                AppScreenHeaderMetrics.topInset,
                20,
                24,
              ),
              children: [
                AppScreenHeader(leading: WalletBackButton(onPressed: onBack)),
                const SizedBox(height: 24),
                ExpenseReferenceCard(reference: l.expenseClaimReference),
                const SizedBox(height: 16),
                ExpenseDetailCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExpenseDetailRow(
                        label: l.expenseDetailCategory,
                        value: pending
                            ? l.supervisorExpenseLaborCost
                            : l.expenseCategoryFuel,
                      ),
                      const _Divider(),
                      ExpenseDetailRow(
                        label: l.expenseDetailAmount,
                        value: pending
                            ? l.supervisorExpenseDetailAmount4000
                            : l.expenseDetailAmountValue,
                      ),
                      const _Divider(),
                      ExpenseDetailRow(
                        label: l.expenseRequestedBy,
                        value: l.expenseRequestedByValue,
                      ),
                      const _Divider(),
                      ExpenseDetailRow(
                        label: l.expenseDateTime,
                        value: l.expenseFuelDate,
                      ),
                      const _Divider(),
                      Text(
                        l.expenseRequestStatus,
                        style: AppTextStyles.semiboldH9_14.copyWith(
                          color: AppColors.neutral950,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ExpenseDetailStatusChip(
                        status: detailStatus,
                        label: statusText,
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
                        l.expenseUploadedPhoto,
                        style: AppTextStyles.semiboldH7_18,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          _Photo(
                            asset: 'assets/images/expense_detail_vehicle.png',
                          ),
                          SizedBox(width: 12),
                          _Photo(
                            asset: 'assets/images/expense_detail_receipt.png',
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
                        l.expenseDescriptionLabel,
                        style: AppTextStyles.semiboldH7_18,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.expenseDetailDescription,
                        style: AppTextStyles.mediumSH9_12.copyWith(
                          color: AppColors.neutral900,
                        ),
                      ),
                    ],
                  ),
                ),
                if (status == SupervisorExpenseStatus.rejected) ...[
                  const SizedBox(height: 16),
                  ExpenseDetailCard(
                    border: AppColors.red500,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: l.supervisorExpenseReasonFor,
                                style: AppTextStyles.semiboldH7_18,
                              ),
                              TextSpan(
                                text: l.supervisorExpenseRejectWord,
                                style: AppTextStyles.semiboldH7_18.copyWith(
                                  color: AppColors.red500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        Text(
                          '${l.expenseRejectReasonLabel} : ${l.supervisorExpenseRejectReasonValue}',
                          style: AppTextStyles.mediumSH8_14,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${l.expenseRejectRemarksLabel} : ${l.supervisorExpenseRejectedRemarksValue}',
                          style: AppTextStyles.mediumSH8_14,
                        ),
                      ],
                    ),
                  ),
                ],
                if (pending) ...[
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          key: const Key('supervisor-expense-reject'),
                          onPressed: onReject,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            side: const BorderSide(color: AppColors.red500),
                            foregroundColor: AppColors.red500,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l.verificationDetailReject,
                            style: AppTextStyles.semiboldH8_16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          key: const Key('supervisor-expense-approve'),
                          onPressed: onApprove,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            elevation: 0,
                            backgroundColor: AppColors.primary500,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l.verificationDetailApprove,
                            style: AppTextStyles.semiboldH8_16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.paddingOf(context).bottom + 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CashRequestDetailScreen extends StatelessWidget {
  const _CashRequestDetailScreen({
    required this.status,
    required this.onBack,
    required this.onApprove,
    required this.onReject,
  });

  final SupervisorExpenseStatus status;
  final VoidCallback onBack;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pending = status == SupervisorExpenseStatus.pending;
    final reference = switch (status) {
      SupervisorExpenseStatus.pending => l.supervisorCashPendingReference,
      SupervisorExpenseStatus.approved => l.supervisorCashApprovedReference,
      SupervisorExpenseStatus.rejected => l.supervisorCashRejectedReference,
    };
    final category = switch (status) {
      SupervisorExpenseStatus.pending => l.supervisorExpenseLaborCost,
      SupervisorExpenseStatus.approved => l.expenseFuelDiesel,
      SupervisorExpenseStatus.rejected => l.cashReasonDailyAdvance,
    };
    final amount = status == SupervisorExpenseStatus.rejected
        ? l.supervisorCashDetailAmount2400
        : l.supervisorCashDetailAmount350;
    final requestedBy = status == SupervisorExpenseStatus.rejected
        ? l.supervisorCashDarshanFull
        : l.supervisorExpenseRahul;
    final detailStatus = switch (status) {
      SupervisorExpenseStatus.pending => ExpenseClaimDetailStatus.pending,
      SupervisorExpenseStatus.approved => ExpenseClaimDetailStatus.verified,
      SupervisorExpenseStatus.rejected => ExpenseClaimDetailStatus.rejected,
    };
    final statusText = switch (status) {
      SupervisorExpenseStatus.pending => l.expenseWaitingSupervisor,
      SupervisorExpenseStatus.approved => l.expenseVerifiedSupervisor,
      SupervisorExpenseStatus.rejected => l.expenseRejectedSupervisor,
    };

    return Scaffold(
      key: const Key('supervisor-cash-detail-screen'),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      AppScreenHeaderMetrics.topInset,
                      20,
                      24,
                    ),
                    children: [
                      AppScreenHeader(
                        leading: WalletBackButton(onPressed: onBack),
                      ),
                      const SizedBox(height: 24),
                      ExpenseReferenceCard(reference: reference),
                      const SizedBox(height: 16),
                      ExpenseDetailCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ExpenseDetailRow(
                              label: l.expenseDetailCategory,
                              value: category,
                            ),
                            const _Divider(),
                            ExpenseDetailRow(
                              label: l.expenseDetailAmount,
                              value: amount,
                            ),
                            const _Divider(),
                            ExpenseDetailRow(
                              label: l.expenseRequestedBy,
                              value: requestedBy,
                            ),
                            const _Divider(),
                            ExpenseDetailRow(
                              label: l.expenseDateTime,
                              value: l.supervisorCashTodayMorning,
                            ),
                            const _Divider(),
                            Text(
                              l.expenseRequestStatus,
                              style: AppTextStyles.semiboldH9_14.copyWith(
                                color: AppColors.neutral950,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ExpenseDetailStatusChip(
                              status: detailStatus,
                              label: statusText,
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
                              l.expenseDescriptionLabel,
                              style: AppTextStyles.semiboldH7_18,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l.expenseDetailDescription,
                              style: AppTextStyles.mediumSH9_12.copyWith(
                                color: AppColors.neutral900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (status == SupervisorExpenseStatus.rejected) ...[
                        const SizedBox(height: 20),
                        ExpenseDetailCard(
                          border: AppColors.red500,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: l.supervisorExpenseReasonFor,
                                      style: AppTextStyles.semiboldH7_18,
                                    ),
                                    TextSpan(
                                      text: l.supervisorExpenseRejectWord,
                                      style: AppTextStyles.semiboldH7_18
                                          .copyWith(color: AppColors.red500),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Divider(
                                height: 1,
                                color: AppColors.cool400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${l.expenseRejectReasonLabel} : ${l.supervisorExpenseRejectReasonValue}',
                                style: AppTextStyles.mediumSH8_14,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${l.expenseRejectRemarksLabel} : ${l.supervisorExpenseRejectedRemarksValue}',
                                style: AppTextStyles.mediumSH8_14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (pending)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      MediaQuery.paddingOf(context).bottom + 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('supervisor-cash-reject'),
                            onPressed: onReject,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              side: const BorderSide(color: AppColors.red500),
                              foregroundColor: AppColors.red500,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              l.verificationDetailReject,
                              style: AppTextStyles.semiboldH8_16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            key: const Key('supervisor-cash-approve'),
                            onPressed: onApprove,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              elevation: 0,
                              backgroundColor: AppColors.primary500,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              l.verificationDetailApprove,
                              style: AppTextStyles.semiboldH8_16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 12),
    child: Divider(height: 1, color: AppColors.cool400),
  );
}

class _Photo extends StatelessWidget {
  const _Photo({required this.asset});
  final String asset;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(6),
    child: Image.asset(asset, width: 109, height: 70, fit: BoxFit.cover),
  );
}

class _RejectExpenseScreen extends StatefulWidget {
  const _RejectExpenseScreen({
    required this.cashRequest,
    required this.onBack,
    required this.onConfirm,
  });
  final bool cashRequest;
  final VoidCallback onBack;
  final VoidCallback onConfirm;
  @override
  State<_RejectExpenseScreen> createState() => _RejectExpenseScreenState();
}

class _RejectExpenseScreenState extends State<_RejectExpenseScreen> {
  final Set<int> selected = {0, 2};
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final reasons = widget.cashRequest
        ? [
            l.supervisorCashSufficientBalance,
            l.supervisorCashInvalidPurpose,
            l.supervisorCashExceedsLimit,
            l.verificationRejectOther,
          ]
        : [
            l.supervisorExpenseInvalidBill,
            l.supervisorExpenseDuplicateClaim,
            l.supervisorExpensePolicyViolation,
            l.verificationRejectOther,
          ];
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      WalletBackButton(onPressed: widget.onBack),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.cashRequest
                              ? l.supervisorCashRejectScreenTitle
                              : l.supervisorExpenseRejectScreenTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.semiboldH6_20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: l.supervisorExpenseReasonForRejection,
                                  style: AppTextStyles.mediumSH8_14,
                                ),
                                TextSpan(
                                  text: ' *',
                                  style: AppTextStyles.mediumSH8_14.copyWith(
                                    color: AppColors.red500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          for (var i = 0; i < reasons.length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () => setState(
                                  () => selected.contains(i)
                                      ? selected.remove(i)
                                      : selected.add(i),
                                ),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 52,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: selected.contains(i)
                                          ? AppColors.red500
                                          : AppColors.cool400,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      _RejectCheckbox(
                                        checked: selected.contains(i),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          reasons[i],
                                          style: AppTextStyles.mediumSH8_14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            l.expenseRejectRemarksLabel,
                            style: AppTextStyles.mediumSH8_14,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 134,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: AppColors.cool400),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                TextFormField(
                                  initialValue: widget.cashRequest
                                      ? null
                                      : l.supervisorExpenseInvalidBill,
                                  minLines: 4,
                                  maxLines: 4,
                                  style: AppTextStyles.mediumSH8_14,
                                  decoration: InputDecoration(
                                    hintText: widget.cashRequest
                                        ? l.supervisorCashRemarksHint
                                        : null,
                                    hintStyle: AppTextStyles.mediumSH8_14
                                        .copyWith(color: AppColors.neutral400),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.fromLTRB(
                                      14,
                                      12,
                                      14,
                                      30,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 12,
                                  bottom: 8,
                                  child: Text(
                                    l.expenseDescriptionCounter,
                                    style: AppTextStyles.regularB8_12.copyWith(
                                      color: AppColors.neutral500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      key: Key(
                        widget.cashRequest
                            ? 'supervisor-cash-confirm-rejection'
                            : 'supervisor-expense-confirm-rejection',
                      ),
                      onPressed: selected.isEmpty ? null : widget.onConfirm,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.red500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l.verificationRejectConfirm,
                        style: AppTextStyles.boldH7_16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RejectCheckbox extends StatelessWidget {
  const _RejectCheckbox({required this.checked});
  final bool checked;

  @override
  Widget build(BuildContext context) => Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      color: checked ? AppColors.red500 : Colors.white,
      border: Border.all(
        color: checked ? AppColors.red500 : AppColors.cool600,
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(3),
    ),
    child: checked
        ? const Icon(Icons.check, size: 15, color: Colors.white)
        : null,
  );
}
