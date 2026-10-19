import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/network/internet_connectivity_service.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/auth/data/auth_session_storage.dart';
import 'package:eerl_app/features/end_my_day/data/day_close_remote_service.dart';
import 'package:eerl_app/features/end_my_day/model/day_close_response.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../widgets/end_day_activity_card.dart';
import '../widgets/end_day_balance_field.dart';
import '../widgets/end_day_confirm_dialog.dart';
import 'supervisor_end_my_day_view.dart';

class EndMyDayScreen extends StatefulWidget {
  const EndMyDayScreen({
    super.key,
    this.isSupervisor = false,
    this.loadData,
    this.closeDay,
    this.hasInternetAccess,
    this.now,
  });

  final bool isSupervisor;
  final Future<DayCloseScreenData> Function()? loadData;
  final Future<void> Function(String centerId)? closeDay;
  final Future<bool> Function()? hasInternetAccess;
  final DateTime Function()? now;

  @override
  State<EndMyDayScreen> createState() => _EndMyDayScreenState();
}

class _EndMyDayScreenState extends State<EndMyDayScreen> {
  late Future<DayCloseScreenData> _data;
  Timer? _sixPmTimer;
  bool _internetDialogVisible = false;

  @override
  void initState() {
    super.initState();
    _data = _load();
    _scheduleSixPmRefresh();
  }

  Future<DayCloseScreenData> _load() async {
    final hasInternet =
        await (widget.hasInternetAccess ??
            InternetConnectivityService.instance.hasInternetAccess)();
    if (!hasInternet) {
      _queueInternetDialog();
      throw const DayCloseApiException('No internet connection.');
    }
    final customLoader = widget.loadData;
    if (customLoader != null) return customLoader();

    final centerId = await EerlLocalRepository.instance.activeCenterId;
    if (centerId == null || centerId.trim().isEmpty) {
      throw const DayCloseApiException('No collection center is selected.');
    }
    final accessToken = await AuthSessionStorage().getAccessToken();
    if (accessToken == null || accessToken.trim().isEmpty) {
      throw const DayCloseApiException('Your session is unavailable.');
    }
    final response = await DayCloseRemoteService.instance.fetch(
      centerId: centerId,
      accessToken: accessToken,
    );
    final syncStatus = await EerlLocalRepository.instance.getSyncStatus();
    return DayCloseScreenData(
      dayClose: response.data,
      pendingSyncCount: syncStatus.outboxCount,
    );
  }

  DateTime _now() => (widget.now ?? DateTime.now)();

  bool get _isAfterSixPm => _now().hour >= 18;

  void _scheduleSixPmRefresh() {
    final now = _now();
    final sixPm = DateTime(now.year, now.month, now.day, 18);
    if (!now.isBefore(sixPm)) return;
    _sixPmTimer = Timer(sixPm.difference(now), () {
      if (mounted) _retry();
    });
  }

  void _queueInternetDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_showInternetDialog());
    });
  }

  Future<void> _showInternetDialog() async {
    if (_internetDialogVisible) return;
    _internetDialogVisible = true;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('end-day-internet-dialog'),
        title: Text(context.l10n.endDayInternetTitle),
        content: Text(context.l10n.endDayInternetMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.endDayInternetOk),
          ),
        ],
      ),
    );
    _internetDialogVisible = false;
  }

  Future<void> _closeDay(String centerId) async {
    final customCloser = widget.closeDay;
    if (customCloser != null) return customCloser(centerId);
    final accessToken = await AuthSessionStorage().getAccessToken();
    if (accessToken == null || accessToken.trim().isEmpty) {
      throw const DayCloseApiException('Your session is unavailable.');
    }
    await DayCloseRemoteService.instance.close(
      centerId: centerId,
      accessToken: accessToken,
    );
  }

  void _retry() => setState(() => _data = _load());

  @override
  void dispose() {
    _sixPmTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSupervisor) return const SupervisorEndMyDayView();

    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: l10n.endMyDay,
        backIconAsset: 'assets/icons/records/back.svg',
      ),
      body: FutureBuilder<DayCloseScreenData>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary500),
            );
          }
          if (snapshot.hasError || snapshot.data == null) {
            return _DayCloseError(
              message: snapshot.error?.toString(),
              onRetry: _retry,
            );
          }
          return _AgentEndDayContent(
            data: snapshot.data!,
            isAfterSixPm: _isAfterSixPm,
            onCloseDay: _closeDay,
          );
        },
      ),
    );
  }
}

class _AgentEndDayContent extends StatelessWidget {
  const _AgentEndDayContent({
    required this.data,
    required this.isAfterSixPm,
    required this.onCloseDay,
  });

  final DayCloseScreenData data;
  final bool isAfterSixPm;
  final Future<void> Function(String centerId) onCloseDay;

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹ ',
    decimalDigits: 2,
  );

  String _money(double value) => _currency.format(value);

  String _wasteCollected(DayCloseCollectionsSummary collections) {
    if (collections.byUnit.isEmpty) return '0';
    return collections.byUnit
        .map((item) {
          final quantity = item.quantity == item.quantity.roundToDouble()
              ? item.quantity.toInt().toString()
              : item.quantity.toStringAsFixed(2);
          return '$quantity ${item.unit}'.trim();
        })
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dayClose = data.dayClose;
    final summary = dayClose.summary;
    final canClose = isAfterSixPm && dayClose.canClose;
    final activities = [
      EndDayActivityItem(
        label: l10n.endDayCompletedCollections,
        value: summary.collections.total.toString(),
      ),
      EndDayActivityItem(
        label: l10n.endDayPendingCollections,
        value: dayClose.openDrafts.toString(),
        valueColor: dayClose.openDrafts > 0
            ? AppColors.yellow600
            : AppColors.neutral950,
      ),
      EndDayActivityItem(
        label: l10n.endDayWasteCollected,
        value: _wasteCollected(summary.collections),
      ),
      EndDayActivityItem(
        label: l10n.endDayExpensesLogged,
        value: summary.expenses.count.toString(),
      ),
      EndDayActivityItem(
        label: l10n.endDayVerificationPending,
        value: summary.collections.pendingReview.toString(),
        valueColor: summary.collections.pendingReview > 0
            ? AppColors.yellow600
            : AppColors.neutral950,
      ),
      EndDayActivityItem(
        label: l10n.endDayOfflineSync,
        value: data.pendingSyncCount.toString(),
        valueColor: data.pendingSyncCount > 0
            ? AppColors.yellow600
            : AppColors.neutral950,
      ),
    ];

    return SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  children: [
                    EndDayBalanceField(
                      label: l10n.endDayOpeningBalance,
                      value: _money(summary.wallet.opening),
                    ),
                    const SizedBox(height: 16),
                    EndDayBalanceField(
                      label: l10n.endDayExpensesLogged,
                      value: _money(summary.expenses.amount),
                    ),
                    const SizedBox(height: 16),
                    EndDayBalanceField(
                      label: l10n.endDayTotalPurchase,
                      value: _money(summary.wallet.collectionPayments),
                    ),
                    const SizedBox(height: 16),
                    _ClosingBalanceCard(
                      label: l10n.endDayClosingBalance,
                      value: _money(summary.wallet.closing),
                      hint: l10n.endDayBalanceHint,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.endDayActivitySummary,
                      style: AppTextStyles.semiboldH7_18.copyWith(
                        color: AppColors.neutral950,
                      ),
                    ),
                    const SizedBox(height: 12),
                    EndDayActivityCard(items: activities),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                color: Colors.white,
                child: Column(
                  children: [
                    if (!canClose) ...[
                      Container(
                        key: const Key('end-day-blocked-reason'),
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.yellow50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          !isAfterSixPm
                              ? l10n.endDayCloseAfterTime('6:00 PM')
                              : dayClose.blockedReason == 'BEFORE_LOCK_TIME' &&
                                    dayClose.lockTime.isNotEmpty
                              ? l10n.endDayCloseAfterTime(dayClose.lockTime)
                              : l10n.endDayCloseBlocked,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.mediumSH9_12.copyWith(
                            color: AppColors.yellow600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        key: const Key('confirm-end-my-day-button'),
                        onPressed: canClose
                            ? () async {
                                final confirmed =
                                    await EndDayConfirmDialog.show(
                                      context,
                                      onConfirm: () =>
                                          onCloseDay(dayClose.centerId),
                                    );
                                if (context.mounted && confirmed == true) {
                                  Navigator.of(context).pop();
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primary500,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          l10n.endMyDay,
                          style: AppTextStyles.semiboldH9_14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.endDayWarning,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.regularB8_12.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayCloseError extends StatelessWidget {
  const _DayCloseError({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AppColors.red600,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            context.l10n.endDayLoadError,
            key: const Key('end-day-load-error'),
            textAlign: TextAlign.center,
            style: AppTextStyles.semiboldH8_16,
          ),
          if (message != null && message!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: AppTextStyles.regularB8_12.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton(
            key: const Key('end-day-retry'),
            onPressed: onRetry,
            child: Text(context.l10n.endDayRetry),
          ),
        ],
      ),
    ),
  );
}

class _ClosingBalanceCard extends StatelessWidget {
  const _ClosingBalanceCard({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x16000000),
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(label, style: AppTextStyles.mediumSH8_14),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.semiboldH5_24.copyWith(
                  color: AppColors.primary600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          hint,
          textAlign: TextAlign.center,
          style: AppTextStyles.regularB7_14.copyWith(
            color: AppColors.neutral700,
          ),
        ),
      ],
    ),
  );
}
