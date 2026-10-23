import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/supervisor_category_request/model/supervisor_category_request.dart';
import 'package:eerl_app/features/supervisor_category_request/widgets/supervisor_category_request_widgets.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:eerl_app/features/wallet/widgets/expense_detail_cards.dart';
import 'package:eerl_app/features/wallet/widgets/wallet_assets.dart';
import 'package:eerl_app/features/wallet/widgets/wallet_screen_header.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import 'package:eerl_app/shared/widgets/app_message_banner.dart';

enum _CategoryRequestPage { list, detail, reject }

class SupervisorCategoryRequestScreen extends StatefulWidget {
  const SupervisorCategoryRequestScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<SupervisorCategoryRequestScreen> createState() =>
      _SupervisorCategoryRequestScreenState();
}

class _SupervisorCategoryRequestScreenState
    extends State<SupervisorCategoryRequestScreen> {
  _CategoryRequestPage _page = _CategoryRequestPage.list;
  CategoryRequestModel? _selectedRequest;
  bool _closedTab = false;
  bool _showRejectedBanner = false;

  void _openDetail(CategoryRequestModel request) => setState(() {
    _selectedRequest = request;
    _page = _CategoryRequestPage.detail;
  });

  Future<void> _decideSelected(String outcome, {String? reason}) async {
    final request = _selectedRequest;
    if (request == null) return;
    await EerlLocalRepository.instance.decideCategoryRequest(
      requestId: request.id,
      outcome: outcome,
      reason: reason,
    );
    await OutgoingSyncService.instance.drain();
  }

  void _backToClosedList({bool rejected = false}) => setState(() {
    _closedTab = true;
    _showRejectedBanner = rejected;
    _page = _CategoryRequestPage.list;
  });

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _page == _CategoryRequestPage.list,
    onPopInvokedWithResult: (didPop, _) {
      if (didPop) return;
      setState(() {
        _page = _page == _CategoryRequestPage.reject
            ? _CategoryRequestPage.detail
            : _CategoryRequestPage.list;
      });
    },
    child: switch (_page) {
      _CategoryRequestPage.list => _CategoryRequestListScreen(
        closedTab: _closedTab,
        showRejectedBanner: _showRejectedBanner,
        onBack: widget.onBack,
        onTabChanged: (closed) => setState(() {
          _closedTab = closed;
          _showRejectedBanner = false;
        }),
        onDismissBanner: () => setState(() => _showRejectedBanner = false),
        onOpenDetail: _openDetail,
      ),
      _CategoryRequestPage.detail => _CategoryRequestDetailScreen(
        request: _selectedRequest!,
        onBack: () => setState(() => _page = _CategoryRequestPage.list),
        onApprove: () => _decideSelected('APPROVED'),
        onReject: () => setState(() => _page = _CategoryRequestPage.reject),
        onApproved: () => _backToClosedList(),
      ),
      _CategoryRequestPage.reject => _CategoryRequestRejectScreen(
        onBack: () => setState(() => _page = _CategoryRequestPage.detail),
        onConfirm: (reason) async {
          await _decideSelected('REJECTED', reason: reason);
          if (!mounted) return;
          _backToClosedList(rejected: true);
        },
      ),
    },
  );
}

class _CategoryRequestListScreen extends StatefulWidget {
  const _CategoryRequestListScreen({
    required this.closedTab,
    required this.showRejectedBanner,
    required this.onBack,
    required this.onTabChanged,
    required this.onDismissBanner,
    required this.onOpenDetail,
  });

  final bool closedTab;
  final bool showRejectedBanner;
  final VoidCallback onBack;
  final ValueChanged<bool> onTabChanged;
  final VoidCallback onDismissBanner;
  final ValueChanged<CategoryRequestModel> onOpenDetail;

  @override
  State<_CategoryRequestListScreen> createState() =>
      _CategoryRequestListScreenState();
}

class _CategoryRequestListScreenState
    extends State<_CategoryRequestListScreen> {
  List<CategoryRequestModel> _requests = const [];
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final requests = await EerlLocalRepository.instance.getCategoryRequests(
        supervisor: true,
      );
      if (!mounted) return;
      setState(() {
        _requests = requests;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pendingCount = _requests
        .where(
          (request) =>
              const {'PENDING', 'OPEN'}.contains(request.status.toUpperCase()),
        )
        .length;
    final closedCount = _requests.length - pendingCount;
    final entries = _requests
        .where((request) {
          final pending = const {
            'PENDING',
            'OPEN',
          }.contains(request.status.toUpperCase());
          return widget.closedTab ? !pending : pending;
        })
        .map((request) => (model: request, item: _presentationItem(request)))
        .toList(growable: false);

    Widget listContent({required double topPadding}) => RefreshIndicator(
      key: const Key('supervisor-category-request-refresh'),
      onRefresh: _loadData,
      child: ListView(
        key: const Key('supervisor-category-request-list'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, topPadding, 20, 32),
        children: [
          if (!widget.showRejectedBanner) ...[
            AppScreenHeader(
              leading: WalletBackButton(onPressed: widget.onBack),
              title: l.supervisorCategoryTitle,
            ),
            const SizedBox(height: 24),
          ],
          _CategoryTabs(
            closed: widget.closedTab,
            pendingLabel: l.supervisorCategoryPendingTab(pendingCount),
            closedLabel: l.supervisorCategoryClosedTab(closedCount),
            onChanged: widget.onTabChanged,
          ),
          const SizedBox(height: 24),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Center(
              child: TextButton(
                onPressed: _loadData,
                child: const Text('Try again'),
              ),
            )
          else if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: Text('No category requests found.')),
            ),
          if (!_loading && _error == null)
            for (final entry in entries.asMap().entries) ...[
              SupervisorCategoryRequestCard(
                item: entry.value.item,
                cardKey: ValueKey(
                  'category-request-${entry.value.item.status.name}-${entry.key}',
                ),
                statusLabel: switch (entry.value.item.status) {
                  SupervisorCategoryRequestStatus.pending =>
                    l.supervisorCategoryRequestPending,
                  SupervisorCategoryRequestStatus.resolved =>
                    l.supervisorCategoryRequestResolved,
                  SupervisorCategoryRequestStatus.rejected =>
                    l.supervisorCategoryRequestRejected,
                },
                onTap: () => widget.onOpenDetail(entry.value.model),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: widget.showRejectedBanner
                ? Stack(
                    children: [
                      listContent(topPadding: 82),
                      Positioned(
                        left: 20,
                        right: 20,
                        top: AppScreenHeaderMetrics.topInset,
                        child: AppMessageBanner(
                          title: l.supervisorCategoryRejectedBannerTitle,
                          subtitle: l.supervisorCategoryRejectedBannerMessage,
                          color: AppColors.red500,
                          backgroundColor: AppColors.red50,
                          borderColor: AppColors.cool400,
                          height: 78,
                          iconBackgroundColor: AppColors.red600,
                          iconPadding: const EdgeInsets.all(6),
                          icon: SvgPicture.asset(
                            WalletAssets.categoryRequestRejectedBanner,
                            width: 18,
                            height: 18,
                          ),
                          closeIcon: SvgPicture.asset(
                            WalletAssets.categoryRequestClose,
                            width: 20,
                            height: 20,
                          ),
                          onClose: widget.onDismissBanner,
                        ),
                      ),
                    ],
                  )
                : listContent(topPadding: AppScreenHeaderMetrics.topInset),
          ),
        ),
      ),
    );
  }

  SupervisorCategoryRequest _presentationItem(CategoryRequestModel request) {
    final status = switch (request.status.toUpperCase()) {
      'REJECTED' => SupervisorCategoryRequestStatus.rejected,
      'PENDING' || 'OPEN' => SupervisorCategoryRequestStatus.pending,
      _ => SupervisorCategoryRequestStatus.resolved,
    };
    final createdAt = DateTime.tryParse(request.createdAt)?.toLocal();
    return SupervisorCategoryRequest(
      agent: _displayValue(request.requestedByName, request.requestedBy),
      facility: request.centerId,
      category: request.name,
      description: _displayValue(request.reason, '—'),
      date: createdAt == null
          ? request.createdAt
          : DateFormat('dd MMM yyyy, hh:mm a').format(createdAt),
      status: status,
    );
  }

  String _displayValue(String? value, String fallback) {
    final normalized = value?.trim();
    return normalized?.isNotEmpty == true ? normalized! : fallback;
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.closed,
    required this.pendingLabel,
    required this.closedLabel,
    required this.onChanged,
  });

  final bool closed;
  final String pendingLabel;
  final String closedLabel;
  final ValueChanged<bool> onChanged;

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
          child: _CategoryTab(
            label: pendingLabel,
            selected: !closed,
            onTap: () => onChanged(false),
          ),
        ),
        Expanded(
          child: _CategoryTab(
            label: closedLabel,
            selected: closed,
            onTap: () => onChanged(true),
          ),
        ),
      ],
    ),
  );
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
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
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary500 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.mediumSH8_14.copyWith(
          color: selected ? Colors.white : AppColors.neutral900,
        ),
      ),
    ),
  );
}

class _CategoryRequestDetailScreen extends StatelessWidget {
  const _CategoryRequestDetailScreen({
    required this.request,
    required this.onBack,
    required this.onApprove,
    required this.onReject,
    required this.onApproved,
  });

  final CategoryRequestModel request;
  final VoidCallback onBack;
  final Future<void> Function() onApprove;
  final VoidCallback onReject;
  final VoidCallback onApproved;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final status = switch (request.status.toUpperCase()) {
      'REJECTED' => SupervisorCategoryRequestStatus.rejected,
      'PENDING' || 'OPEN' => SupervisorCategoryRequestStatus.pending,
      _ => SupervisorCategoryRequestStatus.resolved,
    };
    final pending = status == SupervisorCategoryRequestStatus.pending;
    final statusLabel = switch (status) {
      SupervisorCategoryRequestStatus.pending =>
        l.supervisorCategoryRequestPending,
      SupervisorCategoryRequestStatus.resolved =>
        l.supervisorCategoryRequestResolved,
      SupervisorCategoryRequestStatus.rejected =>
        l.supervisorCategoryRequestRejected,
    };
    return Scaffold(
      key: const Key('supervisor-category-request-detail'),
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
                      ExpenseDetailCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ExpenseDetailRow(
                              label: l.supervisorCategoryCollectionAgent,
                              value:
                                  request.requestedByName?.trim().isNotEmpty ==
                                      true
                                  ? request.requestedByName!.trim()
                                  : request.requestedBy,
                            ),
                            const _CategoryDivider(),
                            ExpenseDetailRow(
                              label: l.supervisorCategoryTitle,
                              value: request.name,
                            ),
                            const _CategoryDivider(),
                            Text(
                              l.expenseRequestStatus,
                              style: AppTextStyles.semiboldH9_14,
                            ),
                            const SizedBox(height: 6),
                            SupervisorCategoryStatusChip(
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
                              l.expenseDescriptionLabel,
                              style: AppTextStyles.semiboldH7_18,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              request.reason?.trim().isNotEmpty == true
                                  ? request.reason!.trim()
                                  : '—',
                              style: AppTextStyles.mediumSH9_12.copyWith(
                                color: AppColors.neutral900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (status ==
                          SupervisorCategoryRequestStatus.rejected) ...[
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
                                '${l.expenseRejectReasonLabel} : ${request.decisionReason?.trim().isNotEmpty == true ? request.decisionReason!.trim() : '—'}',
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
                            key: const Key('category-request-reject'),
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
                            key: const Key('category-request-approve'),
                            onPressed: () => _showApprovedDialog(context),
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

  Future<void> _showApprovedDialog(BuildContext context) async {
    final l = context.l10n;
    try {
      await onApprove();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
      return;
    }
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/category_request_approved.gif',
                width: 130,
                height: 130,
              ),
              const SizedBox(height: 8),
              Text(
                l.supervisorCategoryApprovedTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.semiboldH5_24,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  key: const Key('category-request-back-to-list'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    onApproved();
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.cool200,
                    foregroundColor: AppColors.neutral950,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l.supervisorCategoryBackToList,
                    style: AppTextStyles.semiboldH8_16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryRequestRejectScreen extends StatefulWidget {
  const _CategoryRequestRejectScreen({
    required this.onBack,
    required this.onConfirm,
  });

  final VoidCallback onBack;
  final Future<void> Function(String reason) onConfirm;

  @override
  State<_CategoryRequestRejectScreen> createState() =>
      _CategoryRequestRejectScreenState();
}

class _CategoryRequestRejectScreenState
    extends State<_CategoryRequestRejectScreen> {
  final TextEditingController _reasonController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty || _submitting) return;
    setState(() => _submitting = true);
    try {
      await widget.onConfirm(reason);
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      key: const Key('category-request-reject-screen'),
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
                          l.supervisorCategoryRejectScreenTitle,
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
                          TextFormField(
                            key: const Key('category-request-reject-reason'),
                            controller: _reasonController,
                            maxLength: 150,
                            minLines: 5,
                            maxLines: 5,
                            onChanged: (_) => setState(() {}),
                            style: AppTextStyles.mediumSH8_14,
                            decoration: InputDecoration(
                              hintText: l.expenseRejectReasonLabel,
                              hintStyle: AppTextStyles.mediumSH8_14.copyWith(
                                color: AppColors.neutral400,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              counterStyle: AppTextStyles.regularB8_12.copyWith(
                                color: AppColors.neutral500,
                              ),
                              contentPadding: const EdgeInsets.all(14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.cool400,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.cool400,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.primary500,
                                ),
                              ),
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
                      key: const Key('category-request-confirm-reject'),
                      onPressed:
                          _reasonController.text.trim().isEmpty || _submitting
                          ? null
                          : _confirm,
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

class _CategoryDivider extends StatelessWidget {
  const _CategoryDivider();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 12),
    child: Divider(height: 1, color: AppColors.cool400),
  );
}
