import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/supervisor_category_request/model/supervisor_category_request.dart';
import 'package:eerl_app/features/supervisor_category_request/widgets/supervisor_category_request_widgets.dart';
import 'package:eerl_app/features/wallet/widgets/expense_detail_cards.dart';
import 'package:eerl_app/features/wallet/widgets/wallet_assets.dart';
import 'package:eerl_app/features/wallet/widgets/wallet_screen_header.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import 'package:eerl_app/shared/widgets/app_message_banner.dart';

enum _CategoryRequestPage { list, detail }

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
  SupervisorCategoryRequestStatus _detailStatus =
      SupervisorCategoryRequestStatus.pending;
  bool _closedTab = false;
  bool _showRejectedBanner = false;

  void _openDetail(SupervisorCategoryRequestStatus status) => setState(() {
    _detailStatus = status;
    _page = _CategoryRequestPage.detail;
  });

  void _backToClosedList({bool rejected = false}) => setState(() {
    _closedTab = true;
    _showRejectedBanner = rejected;
    _page = _CategoryRequestPage.list;
  });

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _page == _CategoryRequestPage.list,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) setState(() => _page = _CategoryRequestPage.list);
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
        status: _detailStatus,
        onBack: () => setState(() => _page = _CategoryRequestPage.list),
        onApproved: () => _backToClosedList(),
        onRejected: () => _backToClosedList(rejected: true),
      ),
    },
  );
}

class _CategoryRequestListScreen extends StatelessWidget {
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
  final ValueChanged<SupervisorCategoryRequestStatus> onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    SupervisorCategoryRequest item(SupervisorCategoryRequestStatus status) =>
        SupervisorCategoryRequest(
          agent: l.supervisorCategoryAgent,
          facility: l.supervisorCategoryFacility,
          category: l.supervisorCategoryTyreReplacement,
          description: l.supervisorCategoryDescription,
          date: l.supervisorCategoryTodayTime,
          status: status,
        );
    final pendingItems = List.generate(
      3,
      (_) => item(SupervisorCategoryRequestStatus.pending),
    );
    final closedItems = showRejectedBanner
        ? [
            item(SupervisorCategoryRequestStatus.rejected),
            item(SupervisorCategoryRequestStatus.resolved),
            item(SupervisorCategoryRequestStatus.resolved),
          ]
        : [
            item(SupervisorCategoryRequestStatus.resolved),
            item(SupervisorCategoryRequestStatus.resolved),
            item(SupervisorCategoryRequestStatus.rejected),
          ];
    final items = closedTab ? closedItems : pendingItems;

    Widget listContent({required double topPadding}) => ListView(
      key: const Key('supervisor-category-request-list'),
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 32),
      children: [
        if (!showRejectedBanner) ...[
          AppScreenHeader(
            leading: WalletBackButton(onPressed: onBack),
            title: l.supervisorCategoryTitle,
          ),
          const SizedBox(height: 24),
        ],
        _CategoryTabs(
          closed: closedTab,
          pendingLabel: l.supervisorCategoryPendingTab,
          closedLabel: l.supervisorCategoryClosedTab,
          onChanged: onTabChanged,
        ),
        const SizedBox(height: 24),
        for (final entry in items.asMap().entries) ...[
          SupervisorCategoryRequestCard(
            item: entry.value,
            cardKey: ValueKey(
              'category-request-${entry.value.status.name}-${entry.key}',
            ),
            statusLabel: switch (entry.value.status) {
              SupervisorCategoryRequestStatus.pending =>
                l.supervisorCategoryRequestPending,
              SupervisorCategoryRequestStatus.resolved =>
                l.supervisorCategoryRequestResolved,
              SupervisorCategoryRequestStatus.rejected =>
                l.supervisorCategoryRequestRejected,
            },
            onTap: () => onOpenDetail(entry.value.status),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: showRejectedBanner
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
                          onClose: onDismissBanner,
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
    required this.status,
    required this.onBack,
    required this.onApproved,
    required this.onRejected,
  });

  final SupervisorCategoryRequestStatus status;
  final VoidCallback onBack;
  final VoidCallback onApproved;
  final VoidCallback onRejected;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
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
                              value: l.supervisorCategoryAgent,
                            ),
                            const _CategoryDivider(),
                            ExpenseDetailRow(
                              label: l.supervisorCategoryTitle,
                              value: l.supervisorCategoryTyreReplacement,
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
                              l.supervisorCategoryDescription,
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
                                '${l.expenseRejectReasonLabel} : ${l.supervisorCategoryRejectReason}',
                                style: AppTextStyles.mediumSH8_14,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${l.expenseRejectRemarksLabel} : ${l.supervisorCategoryRejectRemarks}',
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
                            onPressed: () => _showRejectDialog(context),
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

  Future<void> _showRejectDialog(BuildContext context) async {
    final l = context.l10n;
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
              Text(
                l.supervisorCategoryAreYouSure,
                style: AppTextStyles.semiboldH6_20,
              ),
              const SizedBox(height: 12),
              Text(
                l.supervisorCategoryRejectConfirmation,
                textAlign: TextAlign.center,
                style: AppTextStyles.mediumSH8_14.copyWith(
                  color: AppColors.neutral700,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: AppColors.cool200,
                        foregroundColor: AppColors.neutral900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l.recordsCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      key: const Key('category-request-confirm-reject'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        onRejected();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: AppColors.red500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l.supervisorCategoryYes),
                    ),
                  ),
                ],
              ),
            ],
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
