import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/supervisor_expense/model/supervisor_expense_item.dart';
import 'package:eerl_app/features/supervisor_expense/widgets/supervisor_expense_widgets.dart';
import 'package:eerl_app/features/supervisor_category_request/view/supervisor_category_request_screen.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/wallet/model/expense_claim_detail_status.dart';
import 'package:eerl_app/features/wallet/widgets/expense_detail_cards.dart';
import 'package:eerl_app/features/wallet/widgets/wallet_assets.dart';
import 'package:eerl_app/features/wallet/widgets/wallet_screen_header.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import 'package:eerl_app/shared/widgets/app_snackbar.dart';
import 'package:eerl_app/shared/widgets/app_top_notification.dart';
import 'package:eerl_app/shared/widgets/cached_app_image.dart';
import 'package:eerl_app/shared/widgets/app_image_preview_dialog.dart';

enum _ExpensePage {
  list,
  expenseDetail,
  expenseReject,
  cashDetail,
  cashReject,
  categoryRequests,
}

class SupervisorExpenseModuleScreen extends StatefulWidget {
  const SupervisorExpenseModuleScreen({super.key, this.syncAfterDecision});

  final Future<void> Function()? syncAfterDecision;

  @override
  State<SupervisorExpenseModuleScreen> createState() =>
      _SupervisorExpenseModuleScreenState();
}

class _SupervisorExpenseModuleScreenState
    extends State<SupervisorExpenseModuleScreen> {
  _ExpensePage _page = _ExpensePage.list;
  int _listType = 0;
  ExpenseModel? _selectedExpense;
  CashRequestModel? _selectedCashRequest;

  void _openDetail(ExpenseModel expense) => setState(() {
    _listType = 0;
    _selectedExpense = expense;
    _page = _ExpensePage.expenseDetail;
  });

  Future<void> _decideExpense(
    String outcome, {
    String? reason,
    String? remarks,
  }) async {
    final expense = _selectedExpense;
    if (expense == null) return;
    await EerlLocalRepository.instance.decideExpense(
      expenseId: expense.id,
      outcome: outcome,
      reason: reason,
      remarks: remarks,
    );
    await (widget.syncAfterDecision ?? OutgoingSyncService.instance.drain)();
  }

  void _openCashDetail(CashRequestModel request) => setState(() {
    _listType = 1;
    _selectedCashRequest = request;
    _page = _ExpensePage.cashDetail;
  });

  void _showDecisionNotification(bool approved, {bool cashRequest = false}) =>
      AppTopNotification.show(
        context,
        key: Key(
          cashRequest
              ? 'supervisor-cash-request-toast'
              : 'supervisor-expense-toast',
        ),
        title: cashRequest
            ? (approved
                  ? context.l10n.supervisorCashApprovedTitle
                  : context.l10n.supervisorCashRejectedTitle)
            : (approved
                  ? context.l10n.supervisorExpenseApprovedTitle
                  : context.l10n.supervisorExpenseRejectedTitle),
        subtitle: cashRequest
            ? (approved
                  ? context.l10n.supervisorCashApprovedMessage
                  : context.l10n.supervisorCashRejectedMessage)
            : (approved
                  ? context.l10n.supervisorExpenseApprovedMessage
                  : context.l10n.supervisorExpenseRejectedMessage),
        tone: approved
            ? AppTopNotificationTone.success
            : AppTopNotificationTone.error,
      );

  Future<void> _decideCashRequest(
    String outcome, {
    String? reason,
    String? remarks,
  }) async {
    final request = _selectedCashRequest;
    if (request == null) return;
    await EerlLocalRepository.instance.decideCashRequest(
      requestId: request.id,
      outcome: outcome,
      reason: reason,
      remarks: remarks,
    );
    await (widget.syncAfterDecision ?? OutgoingSyncService.instance.drain)();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _page == _ExpensePage.list,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _handleBack();
    },
    child: switch (_page) {
      _ExpensePage.list => _ExpenseListScreen(
        initialType: _listType,
        onTap: _openDetail,
        onCashTap: _openCashDetail,
        onCategoryRequests: () =>
            setState(() => _page = _ExpensePage.categoryRequests),
      ),
      _ExpensePage.expenseDetail => _ExpenseDetailScreen(
        expenseId: _selectedExpense!.id,
        onBack: () => setState(() => _page = _ExpensePage.list),
        onApprove: () async {
          await _decideExpense('APPROVED');
          if (!mounted) return;
          setState(() {
            _listType = 0;
            _page = _ExpensePage.list;
          });
          _showDecisionNotification(true);
        },
        onReject: () => setState(() => _page = _ExpensePage.expenseReject),
      ),
      _ExpensePage.expenseReject => _RejectExpenseScreen(
        cashRequest: false,
        onBack: () => setState(() => _page = _ExpensePage.expenseDetail),
        onConfirm: (decision) async {
          await _decideExpense(
            'REJECTED',
            reason: decision.reason,
            remarks: decision.remarks,
          );
          if (!mounted) return;
          setState(() {
            _listType = 0;
            _page = _ExpensePage.list;
          });
          _showDecisionNotification(false);
        },
      ),
      _ExpensePage.cashDetail => _CashRequestDetailScreen(
        request: _selectedCashRequest!,
        onBack: () => setState(() {
          _listType = 1;
          _page = _ExpensePage.list;
        }),
        onApprove: () async {
          await _decideCashRequest('APPROVED');
          if (!mounted) return;
          setState(() {
            _listType = 1;
            _page = _ExpensePage.list;
          });
          _showDecisionNotification(true, cashRequest: true);
        },
        onReject: () => setState(() => _page = _ExpensePage.cashReject),
      ),
      _ExpensePage.cashReject => _RejectExpenseScreen(
        cashRequest: true,
        onBack: () => setState(() => _page = _ExpensePage.cashDetail),
        onConfirm: (decision) async {
          await _decideCashRequest(
            'REJECTED',
            reason: decision.reason,
            remarks: decision.remarks,
          );
          if (!mounted) return;
          setState(() {
            _listType = 1;
            _page = _ExpensePage.list;
          });
          _showDecisionNotification(false, cashRequest: true);
        },
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
    required this.initialType,
    required this.onTap,
    required this.onCashTap,
    required this.onCategoryRequests,
  });

  final int initialType;
  final ValueChanged<ExpenseModel> onTap;
  final ValueChanged<CashRequestModel> onCashTap;
  final VoidCallback onCategoryRequests;

  @override
  State<_ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<_ExpenseListScreen> {
  int _filter = 0;
  late int _type;
  bool _loading = true;
  Object? _error;
  String _search = '';
  List<ExpenseModel> _expenses = const [];
  List<CashRequestModel> _cashRequests = const [];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _loading = true);
    try {
      final values = await Future.wait([
        EerlLocalRepository.instance.getExpenses(supervisor: true),
        EerlLocalRepository.instance.getCashRequests(supervisor: true),
      ]);
      if (!mounted) return;
      setState(() {
        _expenses = values[0] as List<ExpenseModel>;
        _cashRequests = values[1] as List<CashRequestModel>;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final expenseEntries = [
      for (final expense in _expenses)
        (
          model: expense,
          item: SupervisorExpenseItem(
            agentName: _displayValue(expense.userName, expense.userId),
            role: l.supervisorExpenseAgentRole,
            category: _displayValue(expense.categoryName, expense.categoryId),
            date: _formatExpenseDate(expense.createdAt),
            amount: _formatExpenseAmount(expense.amount),
            status: _supervisorExpenseStatus(expense.status),
          ),
        ),
    ];
    final cashEntries = [
      for (final request in _cashRequests)
        (
          model: request,
          item: SupervisorExpenseItem(
            agentName: _displayValue(
              request.requestedByName,
              request.requestedBy,
            ),
            role: l.supervisorExpenseAgentRole,
            category: _displayValue(request.reason, request.number),
            date: _formatExpenseDate(request.createdAt),
            amount: _formatExpenseAmount(request.amount),
            status: _supervisorExpenseStatus(request.status),
          ),
        ),
    ];
    final sourceItems = _type == 0 ? expenseEntries : cashEntries;
    final shown = sourceItems
        .where(
          (e) =>
              (_filter == 0 ||
                  (_filter == 1
                      ? e.item.status == SupervisorExpenseStatus.pending
                      : e.item.status != SupervisorExpenseStatus.pending)) &&
              (_search.isEmpty ||
                  '${e.item.agentName} ${e.item.category} ${e.item.amount}'
                      .toLowerCase()
                      .contains(_search)),
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
            child: RefreshIndicator(
              key: const Key('supervisor-expense-refresh'),
              onRefresh: _loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  AppScreenHeaderMetrics.topInset,
                  20,
                  32,
                ),
                children: [
                  AppScreenHeader(
                    leading: WalletBackButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    title: l.supervisorApprovalsClaims,
                  ),
                  const SizedBox(height: 16),
                  _ExpenseSegmentedControl(
                    key: Key(
                      _type == 1
                          ? 'supervisor-cash-request-tab-active'
                          : 'supervisor-expense-tab-active',
                    ),
                    selectedIndex: _type,
                    expenseLabel: l.expenseTypeExpense,
                    cashRequestLabel: l.expenseTypeCashRequest,
                    onSelected: (value) => setState(() => _type = value),
                  ),
                  const SizedBox(height: 16),
                  _ExpenseSearchField(
                    hint: l.supervisorExpenseSearchHint,
                    onChanged: (value) =>
                        setState(() => _search = value.trim().toLowerCase()),
                  ),
                  const SizedBox(height: 12),
                  _ExpenseFilters(
                    labels: [l.filterAll, l.filterPending, l.filterClosed],
                    selectedIndex: _filter,
                    onSelected: (value) => setState(() => _filter = value),
                  ),
                  const SizedBox(height: 16),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null)
                    _ExpenseLoadError(onRetry: _loadData)
                  else if (_type == 0) ...[
                    _CategoryRequestsCard(
                      title: l.supervisorExpenseNewCategories,
                      subtitle: l.supervisorExpenseReviewCategories,
                      buttonLabel: l.supervisorExpenseViewRequests,
                      onPressed: widget.onCategoryRequests,
                    ),
                    const SizedBox(height: 16),
                    if (shown.isEmpty) const _ExpenseEmptyState(),
                    for (final entry in shown) ...[
                      SupervisorExpenseCard(
                        item: entry.item,
                        statusLabel: switch (entry.item.status) {
                          SupervisorExpenseStatus.pending =>
                            l.supervisorExpensePendingReview,
                          SupervisorExpenseStatus.approved =>
                            l.transferStatusApproved,
                          SupervisorExpenseStatus.rejected =>
                            l.transferStatusRejected,
                        },
                        onTap: () => widget.onTap(entry.model as ExpenseModel),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ] else ...[
                    if (shown.isEmpty) const _ExpenseEmptyState(),
                    for (final entry in shown.asMap().entries) ...[
                      SupervisorExpenseCard(
                        item: entry.value.item,
                        cardKey: ValueKey(
                          'supervisor-cash-${entry.value.item.status.name}-${entry.key}',
                        ),
                        statusLabel: switch (entry.value.item.status) {
                          SupervisorExpenseStatus.pending =>
                            l.supervisorExpensePendingReview,
                          SupervisorExpenseStatus.approved =>
                            l.supervisorCashApprovedCredited,
                          SupervisorExpenseStatus.rejected =>
                            l.transferStatusRejected,
                        },
                        onTap: () => widget.onCashTap(
                          entry.value.model as CashRequestModel,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpenseSegmentedControl extends StatelessWidget {
  const _ExpenseSegmentedControl({
    super.key,
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
  const _ExpenseSearchField({required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 55,
    child: TextField(
      onChanged: onChanged,
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
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Colors.white,
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

class _ExpenseDetailScreen extends StatefulWidget {
  const _ExpenseDetailScreen({
    required this.expenseId,
    required this.onBack,
    required this.onApprove,
    required this.onReject,
  });

  final String expenseId;
  final VoidCallback onBack;
  final Future<void> Function() onApprove;
  final VoidCallback onReject;

  @override
  State<_ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<_ExpenseDetailScreen> {
  late Future<ExpenseModel?> _expense;
  late Future<List<String>> _receipts;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _expense = EerlLocalRepository.instance.getExpense(widget.expenseId);
    _receipts = EerlLocalRepository.instance.getExpenseReceiptSources(
      widget.expenseId,
    );
  }

  void _retry() {
    setState(_load);
  }

  Future<void> _approve() async {
    setState(() => _submitting = true);
    try {
      await widget.onApprove();
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      AppSnackbar.error(context, message: error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: FutureBuilder<ExpenseModel?>(
              future: _expense,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final expense = snapshot.data;
                if (snapshot.hasError || expense == null) {
                  return _ExpenseLoadError(onRetry: _retry);
                }
                return _ExpenseDetailContent(
                  expense: expense,
                  receipts: _receipts,
                  submitting: _submitting,
                  onBack: widget.onBack,
                  onApprove: _approve,
                  onReject: widget.onReject,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpenseDetailContent extends StatelessWidget {
  const _ExpenseDetailContent({
    required this.expense,
    required this.receipts,
    required this.submitting,
    required this.onBack,
    required this.onApprove,
    required this.onReject,
  });

  final ExpenseModel expense;
  final Future<List<String>> receipts;
  final bool submitting;
  final VoidCallback onBack;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final status = _supervisorExpenseStatus(expense.status);
    final pending = status == SupervisorExpenseStatus.pending;
    final detailStatus = switch (status) {
      SupervisorExpenseStatus.pending => ExpenseClaimDetailStatus.pending,
      SupervisorExpenseStatus.approved => ExpenseClaimDetailStatus.verified,
      SupervisorExpenseStatus.rejected => ExpenseClaimDetailStatus.rejected,
    };
    final statusText = switch (status) {
      SupervisorExpenseStatus.pending => l.supervisorExpensePendingReview,
      SupervisorExpenseStatus.approved => l.transferStatusApproved,
      SupervisorExpenseStatus.rejected => l.transferStatusRejected,
    };
    final note = expense.note?.trim();
    final reason = expense.decisionReason?.trim();
    final remarks = expense.decisionRemarks?.trim();
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        20,
        AppScreenHeaderMetrics.topInset,
        20,
        24,
      ),
      children: [
        AppScreenHeader(leading: WalletBackButton(onPressed: onBack)),
        const SizedBox(height: 24),
        ExpenseReferenceCard(
          reference: _displayValue(expense.number, expense.id),
        ),
        const SizedBox(height: 16),
        ExpenseDetailCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExpenseDetailRow(
                label: l.expenseDetailCategory,
                value: _displayValue(expense.categoryName, expense.categoryId),
              ),
              const _Divider(),
              ExpenseDetailRow(
                label: l.expenseDetailAmount,
                value: _formatExpenseAmount(expense.amount),
              ),
              const _Divider(),
              ExpenseDetailRow(
                label: l.expenseRequestedBy,
                value: _displayValue(expense.userName, expense.userId),
              ),
              const _Divider(),
              ExpenseDetailRow(
                label: l.expenseDateTime,
                value: _formatExpenseDate(expense.createdAt),
              ),
              const _Divider(),
              Text(l.expenseRequestStatus, style: AppTextStyles.semiboldH9_14),
              const SizedBox(height: 6),
              ExpenseDetailStatusChip(status: detailStatus, label: statusText),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<String>>(
          future: receipts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ExpenseDetailCard(
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final sources = snapshot.data ?? const <String>[];
            if (sources.isEmpty) return const SizedBox.shrink();
            return ExpenseDetailCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.expenseUploadedPhoto,
                    style: AppTextStyles.semiboldH7_18,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final source in sources) _Photo(source: source),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        if (note?.isNotEmpty == true) ...[
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
                Text(note!, style: AppTextStyles.mediumSH9_12),
              ],
            ),
          ),
        ],
        if (status == SupervisorExpenseStatus.rejected &&
            reason?.isNotEmpty == true) ...[
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
                  '${l.expenseRejectReasonLabel} : $reason',
                  style: AppTextStyles.mediumSH8_14,
                ),
                if (remarks?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${l.expenseRejectRemarksLabel} : $remarks',
                    style: AppTextStyles.mediumSH8_14,
                  ),
                ],
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
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    side: const BorderSide(color: AppColors.red500),
                    foregroundColor: AppColors.red500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  key: const Key('supervisor-expense-reject'),
                  onPressed: submitting ? null : onReject,
                  child: Text(l.verificationDetailReject),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  key: const Key('supervisor-expense-approve'),
                  onPressed: submitting ? null : onApprove,
                  child: submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l.verificationDetailApprove),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CashRequestDetailScreen extends StatelessWidget {
  const _CashRequestDetailScreen({
    required this.request,
    required this.onBack,
    required this.onApprove,
    required this.onReject,
  });

  final CashRequestModel request;
  final VoidCallback onBack;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final status = _supervisorExpenseStatus(request.status);
    final pending = status == SupervisorExpenseStatus.pending;
    final reference = _displayValue(request.number, request.id);
    final category = _displayValue(request.reason, null);
    final amount = _formatExpenseAmount(request.amount);
    final requestedBy = _displayValue(
      request.requestedByName,
      request.requestedBy,
    );
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
                              value: _formatExpenseDate(request.createdAt),
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
                              category,
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
                                '${l.expenseRejectReasonLabel} : ${_displayValue(request.decisionNote, null)}',
                                style: AppTextStyles.mediumSH8_14,
                              ),
                              if (request.decisionRemarks?.trim().isNotEmpty ==
                                  true) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '${l.expenseRejectRemarksLabel} : ${request.decisionRemarks!.trim()}',
                                  style: AppTextStyles.mediumSH8_14,
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
  const _Photo({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(6),
    child: Material(
      color: AppColors.cool100,
      child: InkWell(
        onTap: () => AppImagePreviewDialog.showSource(context, source),
        child: CachedAppImage(
          source: source,
          width: 109,
          height: 70,
          fit: BoxFit.cover,
        ),
      ),
    ),
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
  final Future<void> Function(_ExpenseRejectionDecision decision) onConfirm;

  @override
  State<_RejectExpenseScreen> createState() => _RejectExpenseScreenState();
}

class _RejectExpenseScreenState extends State<_RejectExpenseScreen> {
  final Set<int> selected = {};
  final TextEditingController _otherController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _otherController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _confirm(List<String> reasons) async {
    final otherIndex = reasons.length - 1;
    final sortedSelection = selected.toList()..sort();
    final selectedReasons = [
      for (final index in sortedSelection)
        index == otherIndex ? _otherController.text.trim() : reasons[index],
    ];
    final remarks = _remarksController.text.trim();
    final reason = selectedReasons.join(', ').trim();
    if (reason.isEmpty) return;
    setState(() => _submitting = true);
    try {
      await widget.onConfirm(
        _ExpenseRejectionDecision(
          reason: reason,
          remarks: remarks.isEmpty ? null : remarks,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      AppSnackbar.error(context, message: error.toString());
    }
  }

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
                                key: ValueKey(
                                  widget.cashRequest
                                      ? 'supervisor-cash-reject-reason-$i'
                                      : 'supervisor-expense-reject-reason-$i',
                                ),
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
                          if (selected.contains(reasons.length - 1)) ...[
                            const SizedBox(height: 4),
                            TextFormField(
                              key: Key(
                                widget.cashRequest
                                    ? 'supervisor-cash-reject-other'
                                    : 'supervisor-expense-reject-other',
                              ),
                              controller: _otherController,
                              maxLength: 150,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: l.verificationRejectOther,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
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
                              // border: Border.all(color: AppColors.cool400),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                TextFormField(
                                  controller: _remarksController,
                                  onChanged: (_) => setState(() {}),
                                  maxLength: 150,
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
                                    counterText: '',
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
                                  bottom: 4,
                                  child: Text(
                                    '${_remarksController.text.characters.length}/150',
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
                      onPressed:
                          selected.isEmpty ||
                              (selected.contains(reasons.length - 1) &&
                                  _otherController.text.trim().isEmpty) ||
                              _submitting
                          ? null
                          : () => _confirm(reasons),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.red500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
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

class _ExpenseRejectionDecision {
  const _ExpenseRejectionDecision({required this.reason, this.remarks});

  final String reason;
  final String? remarks;
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

class _ExpenseLoadError extends StatelessWidget {
  const _ExpenseLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.error_outline_rounded,
          size: 40,
          color: AppColors.red500,
        ),
        const SizedBox(height: 12),
        const Text('Unable to load expense data.'),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    ),
  );
}

class _ExpenseEmptyState extends StatelessWidget {
  const _ExpenseEmptyState();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 40),
    child: Center(child: Text('No expenses found.')),
  );
}

SupervisorExpenseStatus _supervisorExpenseStatus(String value) {
  return switch (value.trim().toUpperCase()) {
    'APPROVED' || 'VERIFIED' => SupervisorExpenseStatus.approved,
    'REJECTED' || 'DECLINED' => SupervisorExpenseStatus.rejected,
    _ => SupervisorExpenseStatus.pending,
  };
}

String _displayValue(String? preferred, String? fallback) {
  final normalized = preferred?.trim();
  if (normalized?.isNotEmpty == true) return normalized!;
  final normalizedFallback = fallback?.trim();
  return normalizedFallback?.isNotEmpty == true ? normalizedFallback! : '—';
}

String _formatExpenseAmount(double value) => NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
).format(value);

String _formatExpenseDate(String value) {
  final date = DateTime.tryParse(value)?.toLocal();
  return date == null
      ? _displayValue(value, null)
      : DateFormat('dd MMM yyyy, hh:mm a').format(date);
}
