import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/supervisor_expense/model/supervisor_expense_item.dart';
import 'package:eerl_app/features/supervisor_expense/widgets/supervisor_expense_widgets.dart';
import 'package:eerl_app/features/wallet/model/expense_claim_detail_status.dart';
import 'package:eerl_app/features/wallet/widgets/expense_detail_cards.dart';
import 'package:eerl_app/features/wallet/widgets/wallet_assets.dart';
import 'package:eerl_app/features/wallet/widgets/wallet_screen_header.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';

enum _ExpensePage { list, detail, reject }

class SupervisorExpenseModuleScreen extends StatefulWidget {
  const SupervisorExpenseModuleScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<SupervisorExpenseModuleScreen> createState() =>
      _SupervisorExpenseModuleScreenState();
}

class _SupervisorExpenseModuleScreenState
    extends State<SupervisorExpenseModuleScreen> {
  _ExpensePage _page = _ExpensePage.list;
  SupervisorExpenseStatus _detailStatus = SupervisorExpenseStatus.pending;
  bool? _toastApproved;

  void _openDetail(SupervisorExpenseStatus status) => setState(() {
    _detailStatus = status;
    _page = _ExpensePage.detail;
    _toastApproved = null;
  });

  @override
  Widget build(BuildContext context) => switch (_page) {
    _ExpensePage.list => _ExpenseListScreen(
      onBack: widget.onBack,
      onTap: _openDetail,
      toastApproved: _toastApproved,
      onDismissToast: () => setState(() => _toastApproved = null),
    ),
    _ExpensePage.detail => _ExpenseDetailScreen(
      status: _detailStatus,
      onBack: () => setState(() => _page = _ExpensePage.list),
      onApprove: () => setState(() {
        _toastApproved = true;
        _page = _ExpensePage.list;
      }),
      onReject: () => setState(() => _page = _ExpensePage.reject),
    ),
    _ExpensePage.reject => _RejectExpenseScreen(
      onBack: () => setState(() => _page = _ExpensePage.detail),
      onConfirm: () => setState(() {
        _toastApproved = false;
        _page = _ExpensePage.list;
      }),
    ),
  };
}

class _ExpenseListScreen extends StatefulWidget {
  const _ExpenseListScreen({
    required this.onBack,
    required this.onTap,
    required this.toastApproved,
    required this.onDismissToast,
  });
  final VoidCallback onBack;
  final ValueChanged<SupervisorExpenseStatus> onTap;
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
    final shown = items
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
                32,
              ),
              children: [
                AppScreenHeader(
                  leading: WalletBackButton(onPressed: widget.onBack),
                  title: l.supervisorApprovalsClaims,
                ),
                if (widget.toastApproved != null) ...[
                  const SizedBox(height: 16),
                  SupervisorExpenseToast(
                    approved: widget.toastApproved!,
                    title: widget.toastApproved!
                        ? l.supervisorExpenseApprovedTitle
                        : l.supervisorExpenseRejectedTitle,
                    message: widget.toastApproved!
                        ? l.supervisorExpenseApprovedMessage
                        : l.supervisorExpenseRejectedMessage,
                  ),
                ],
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.cool100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _Segment(
                          label: l.expenseTypeExpense,
                          selected: _type == 0,
                          onTap: () => setState(() => _type = 0),
                        ),
                      ),
                      Expanded(
                        child: _Segment(
                          label: l.expenseTypeCashRequest,
                          selected: _type == 1,
                          onTap: () => setState(() => _type = 1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(13),
                      child: SvgPicture.asset(WalletAssets.search),
                    ),
                    hintText: l.transferSearchHint,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.cool300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.cool300),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [l.filterAll, l.filterPending, l.filterClosed]
                      .asMap()
                      .entries
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(e.value),
                            selected: _filter == e.key,
                            onSelected: (_) => setState(() => _filter = e.key),
                            selectedColor: AppColors.primary500,
                            backgroundColor: Colors.white,
                            labelStyle: AppTextStyles.semiboldH10_12.copyWith(
                              color: _filter == e.key
                                  ? Colors.white
                                  : AppColors.neutral600,
                            ),
                            side: BorderSide(
                              color: _filter == e.key
                                  ? AppColors.primary500
                                  : AppColors.cool300,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                if (_type == 0) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary50,
                      border: Border.all(color: AppColors.primary200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.primary100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.category_outlined,
                            color: AppColors.primary500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.supervisorExpenseNewCategories,
                                style: AppTextStyles.semiboldH9_14,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l.supervisorExpenseReviewCategories,
                                style: AppTextStyles.regularB8_12.copyWith(
                                  color: AppColors.neutral600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.red500,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '2',
                                  style: AppTextStyles.boldH9_12.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l.supervisorExpenseViewRequests,
                                maxLines: 2,
                                textAlign: TextAlign.end,
                                style: AppTextStyles.semiboldH10_12.copyWith(
                                  color: AppColors.primary600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
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
                ] else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Text(
                        l.supervisorExpenseNoCashRequests,
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
    borderRadius: BorderRadius.circular(9),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        boxShadow: selected
            ? const [BoxShadow(color: Color(0x16000000), blurRadius: 4)]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.semiboldH9_14.copyWith(
          color: selected ? AppColors.primary600 : AppColors.neutral500,
        ),
      ),
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
                                  asset:
                                      'assets/images/expense_detail_vehicle.png',
                                ),
                                SizedBox(width: 12),
                                _Photo(
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
                              Text(
                                l.expenseRejectReasonTitle,
                                style: AppTextStyles.semiboldH7_18,
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
                                '${l.expenseRejectRemarksLabel} : ${l.collectionDetailRemarksValue}',
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
              Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  MediaQuery.paddingOf(context).bottom + 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x16000000),
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
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
                        child: Text(l.verificationDetailReject),
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
                        child: Text(l.verificationDetailApprove),
                      ),
                    ),
                  ],
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
  Widget build(BuildContext context) => Expanded(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(asset, height: 94, fit: BoxFit.cover),
    ),
  );
}

class _RejectExpenseScreen extends StatefulWidget {
  const _RejectExpenseScreen({required this.onBack, required this.onConfirm});
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
    final reasons = [
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
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Row(
                  children: [
                    WalletBackButton(onPressed: widget.onBack),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        l.supervisorExpenseRejectScreenTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.semiboldH6_20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ExpenseReferenceCard(reference: l.expenseClaimReference),
                const SizedBox(height: 20),
                Text(
                  '${l.supervisorExpenseReasonForRejection} *',
                  style: AppTextStyles.mediumSH8_14,
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < reasons.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => setState(
                        () => selected.contains(i)
                            ? selected.remove(i)
                            : selected.add(i),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: selected.contains(i)
                                ? AppColors.primary500
                                : AppColors.cool300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected.contains(i)
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color: selected.contains(i)
                                  ? AppColors.primary500
                                  : AppColors.neutral400,
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
                TextFormField(
                  initialValue: l.supervisorExpenseInvalidBill,
                  minLines: 5,
                  maxLines: 5,
                  decoration: InputDecoration(
                    helper: Align(
                      alignment: Alignment.centerRight,
                      child: Text(l.expenseDescriptionCounter),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  key: const Key('supervisor-expense-confirm-rejection'),
                  onPressed: selected.isEmpty ? null : widget.onConfirm,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
