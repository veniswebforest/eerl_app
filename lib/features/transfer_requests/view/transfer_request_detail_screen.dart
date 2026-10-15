import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';
import 'package:eerl_app/shared/widgets/app_message_banner.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../model/transfer_request_detail_state.dart';
import '../widgets/transfer_request_detail_widgets.dart';
import 'supervisor_transfer_approval_screen.dart';
import 'supervisor_transfer_reject_screen.dart';
import 'transfer_dispatch_flow_screen.dart';

typedef TransferRequestDetailData = ({
  TransferModel? transfer,
  List<TransferItemModel> items,
});
typedef TransferRequestDetailLoader =
    Future<TransferRequestDetailData> Function(String transferId);
typedef TransferRequestRejectHandler =
    Future<void> Function(String transferId, String reason, String? remarks);

class TransferRequestDetailScreen extends StatefulWidget {
  const TransferRequestDetailScreen({
    super.key,
    required this.transferId,
    this.detailLoader,
    this.roleLoader,
    this.rejectHandler,
  });

  final String transferId;
  final TransferRequestDetailLoader? detailLoader;
  final Future<String?> Function()? roleLoader;
  final TransferRequestRejectHandler? rejectHandler;

  @override
  State<TransferRequestDetailScreen> createState() =>
      _TransferRequestDetailScreenState();
}

class _TransferRequestDetailScreenState
    extends State<TransferRequestDetailScreen> {
  bool _dispatchFlowOpen = false;
  bool _approvalFlowOpen = false;
  bool _rejectionFlowOpen = false;
  bool _showRejectedBanner = false;
  String? _rejectionReasonOverride;
  String? _rejectionRemarksOverride;
  bool _isSupervisor = false;
  bool _roleLoaded = false;
  late final LocalQueryController<TransferRequestDetailData> _controller;

  @override
  void initState() {
    super.initState();
    _controller = LocalQueryController(() {
      final loader = widget.detailLoader;
      if (loader != null) return loader(widget.transferId);
      return _loadLocalDetail(widget.transferId);
    })..load();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role =
        await (widget.roleLoader?.call() ??
            EerlLocalRepository.instance.activeRole);
    if (!mounted) return;
    setState(() {
      _isSupervisor = role?.toUpperCase().contains('SUPERVISOR') == true;
      _roleLoaded = true;
    });
  }

  Future<TransferRequestDetailData> _loadLocalDetail(String transferId) async {
    final values = await Future.wait<Object?>([
      EerlLocalRepository.instance.getTransfer(transferId),
      EerlLocalRepository.instance.getTransferItems(transferId),
    ]);
    return (
      transfer: values[0] as TransferModel?,
      items: values[1]! as List<TransferItemModel>,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_dispatchFlowOpen && !_approvalFlowOpen && !_rejectionFlowOpen,
    child: _rejectionFlowOpen
        ? SupervisorTransferRejectScreen(
            onBack: () => setState(() => _rejectionFlowOpen = false),
            onConfirm: (rejection) =>
                _rejectTransfer(_controller.data!.transfer!, rejection),
          )
        : _approvalFlowOpen
        ? SupervisorTransferApprovalScreen(
            transfer: _controller.data!.transfer!,
            items: _controller.data!.items,
            onBack: () => setState(() => _approvalFlowOpen = false),
            onApproved: () {
              setState(() => _approvalFlowOpen = false);
              _controller.load();
            },
          )
        : _dispatchFlowOpen
        ? TransferDispatchFlowScreen(
            onBack: () => setState(() => _dispatchFlowOpen = false),
            onComplete: () {
              setState(() => _dispatchFlowOpen = false);
              _controller.load();
            },
            transfer: _controller.data!.transfer!,
            items: _controller.data!.items,
          )
        : ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.isLoading && !_controller.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (_controller.error != null ||
                  _controller.data?.transfer == null) {
                return Scaffold(
                  appBar: CustomAppBar(
                    title: context.l10n.transferDetailTitle,
                    backIconAsset: 'assets/icons/records/back.svg',
                    titleStyle: AppTextStyles.semiboldH6_20,
                    backButtonRadius: 12,
                  ),
                  body: Center(
                    child: TextButton(
                      onPressed: _controller.load,
                      child: const Text('Retry'),
                    ),
                  ),
                );
              }
              final transfer = _controller.data?.transfer;
              return _TransferRequestDetailContent(
                state: _rejectionReasonOverride != null
                    ? TransferRequestDetailState.rejected
                    : _detailState(transfer!.status),
                transfer: transfer,
                items: _controller.data?.items ?? const <TransferItemModel>[],
                isSupervisor: _isSupervisor,
                roleLoaded: _roleLoaded,
                onApprove: () => setState(() => _approvalFlowOpen = true),
                onReject: () => setState(() => _rejectionFlowOpen = true),
                onVehicleArrived: () =>
                    setState(() => _dispatchFlowOpen = true),
                showRejectedBanner: _showRejectedBanner,
                onDismissRejectedBanner: () =>
                    setState(() => _showRejectedBanner = false),
                rejectionReasonOverride: _rejectionReasonOverride,
                rejectionRemarksOverride: _rejectionRemarksOverride,
              );
            },
          ),
  );

  Future<void> _rejectTransfer(
    TransferModel transfer,
    TransferRejection rejection,
  ) async {
    final reason = rejection.reasons.join(', ');
    if (reason.isEmpty) return;
    try {
      final handler = widget.rejectHandler;
      if (handler != null) {
        await handler(transfer.id, reason, rejection.remarks);
      } else {
        await EerlLocalRepository.instance.rejectTransfer(
          transferId: transfer.id,
          reason: reason,
          remarks: rejection.remarks,
        );
      }
      if (!mounted) return;
      setState(() {
        _rejectionFlowOpen = false;
        _showRejectedBanner = true;
        _rejectionReasonOverride = reason;
        _rejectionRemarksOverride = rejection.remarks;
      });
      await _controller.load();
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  TransferRequestDetailState _detailState(String value) {
    final status = value.toUpperCase();
    if (status.contains('REJECT')) {
      return TransferRequestDetailState.rejected;
    }
    if (status.contains('UNAVAILABLE') || status.contains('CANCEL')) {
      return TransferRequestDetailState.vehicleUnavailable;
    }
    if (status.contains('COMPLET') ||
        status.contains('CLOSED') ||
        status.contains('HAND') ||
        status.contains('RECEIV')) {
      return TransferRequestDetailState.completed;
    }
    if (status.contains('DISPATCH') ||
        status.contains('LOADING') ||
        status.contains('APPROV')) {
      return TransferRequestDetailState.waitingForLoading;
    }
    return TransferRequestDetailState.pendingVerification;
  }
}

class _TransferRequestDetailContent extends StatelessWidget {
  const _TransferRequestDetailContent({
    required this.state,
    required this.transfer,
    required this.items,
    required this.isSupervisor,
    required this.roleLoaded,
    required this.onApprove,
    required this.onReject,
    required this.onVehicleArrived,
    required this.showRejectedBanner,
    required this.onDismissRejectedBanner,
    this.rejectionReasonOverride,
    this.rejectionRemarksOverride,
  });

  final TransferRequestDetailState state;
  final TransferModel? transfer;
  final List<TransferItemModel> items;
  final bool isSupervisor;
  final bool roleLoaded;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onVehicleArrived;
  final bool showRejectedBanner;
  final VoidCallback onDismissRejectedBanner;
  final String? rejectionReasonOverride;
  final String? rejectionRemarksOverride;

  bool get _isRejected => state == TransferRequestDetailState.rejected;

  bool get _isCompleted => state == TransferRequestDetailState.completed;

  bool get _isLoading => state == TransferRequestDetailState.waitingForLoading;

  bool get _isVehicleUnavailable =>
      state == TransferRequestDetailState.vehicleUnavailable;

  @override
  Widget build(BuildContext context) {
    final supervisorCompleted = isSupervisor && _isCompleted;
    final rejectionReason =
        rejectionReasonOverride ?? transfer?.rejectionReason;
    final rejectionRemarks =
        rejectionRemarksOverride ?? transfer?.rejectionRemarks;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: showRejectedBanner
          ? null
          : CustomAppBar(
              title: isSupervisor && _isRejected
                  ? null
                  : context.l10n.transferDetailTitle,
              backIconAsset: 'assets/icons/records/back.svg',
              titleStyle: AppTextStyles.semiboldH6_20,
              backButtonRadius: 12,
            ),
      bottomNavigationBar:
          roleLoaded &&
              isSupervisor &&
              (transfer?.status.toUpperCase() == 'REQUESTED' ||
                  transfer?.status.toUpperCase() == 'PENDING')
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const Key('supervisor-transfer-reject'),
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          foregroundColor: AppColors.red600,
                          side: const BorderSide(color: AppColors.red600),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(context.l10n.supervisorTransferReject),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        key: const Key('supervisor-transfer-approve'),
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
                        child: Text(context.l10n.supervisorTransferApprove),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : roleLoaded &&
                !isSupervisor &&
                transfer?.status.toUpperCase() == 'APPROVED'
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    key: const Key('transfer-vehicle-arrived'),
                    onPressed: onVehicleArrived,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: AppColors.neutral50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      context.l10n.transferVehicleArrived,
                      style: AppTextStyles.semiboldH9_14,
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: SafeArea(
        top: showRejectedBanner,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Stack(
              children: [
                ListView(
                  key: const Key('transfer-request-detail-scroll'),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    showRejectedBanner ? 82 : 24,
                    20,
                    28,
                  ),
                  children: [
                    if (_isRejected && !isSupervisor) ...[
                      _RejectReasonCard(
                        reason: rejectionReason,
                        remarks: rejectionRemarks,
                      ),
                      const SizedBox(height: 16),
                    ],
                    _RequestIdCard(
                      value:
                          transfer?.number ??
                          transfer?.id ??
                          context.l10n.transferDetailRequestId,
                    ),
                    const SizedBox(height: 16),
                    _InformationCard(
                      state: state,
                      transfer: transfer,
                      items: items,
                      isSupervisor: isSupervisor,
                      isRejected: _isRejected,
                      isCompleted: _isCompleted,
                      isLoading: _isLoading,
                      isVehicleUnavailable: _isVehicleUnavailable,
                    ),
                    const SizedBox(height: 16),
                    if (supervisorCompleted) ...[
                      _ItemsCard(
                        items: items,
                        title: 'Stock in hand at the centre',
                      ),
                      const SizedBox(height: 16),
                      if (transfer != null &&
                          (transfer!.plannedVehicleNumber != null ||
                              transfer!.vehiclePlate != null)) ...[
                        _SupervisorVehicleInformationCard(transfer: transfer!),
                        const SizedBox(height: 16),
                      ],
                      if (transfer != null)
                        _SupervisorDispatchEvidence(transfer: transfer!),
                    ] else ...[
                      if (isSupervisor &&
                          (transfer?.plannedVehicleNumber != null ||
                              transfer?.vehiclePlate != null)) ...[
                        _SupervisorVehicleInformationCard(transfer: transfer!),
                        const SizedBox(height: 16),
                      ] else if (transfer?.truckExpectedAt != null ||
                          transfer?.plannedVehicleNumber != null ||
                          transfer?.dispatchNote?.trim().isNotEmpty ==
                              true) ...[
                        _CollectionManagerCard(transfer: transfer),
                        const SizedBox(height: 16),
                      ],
                      if (!isSupervisor &&
                          transfer?.status.toUpperCase() == 'DISPATCHED') ...[
                        _AgentDispatchCard(transfer: transfer!),
                        const SizedBox(height: 16),
                      ],
                      _ItemsCard(items: items),
                    ],
                    if (_isRejected && isSupervisor) ...[
                      const SizedBox(height: 16),
                      _RejectReasonCard(
                        reason: rejectionReason,
                        remarks: rejectionRemarks,
                      ),
                    ],
                    if (!isSupervisor) ...[
                      const SizedBox(height: 12),
                      _TimelineCard(state: state, transfer: transfer),
                    ],
                  ],
                ),
                if (showRejectedBanner)
                  Positioned(
                    left: 20,
                    right: 20,
                    top: 4,
                    child: AppMessageBanner(
                      key: const Key('supervisor-transfer-rejected-banner'),
                      title: 'Request Rejected!',
                      subtitle:
                          '${transfer?.number ?? transfer?.id ?? ''} rejected.',
                      color: AppColors.red500,
                      backgroundColor: AppColors.red50,
                      borderColor: AppColors.cool300,
                      height: 78,
                      padding: const EdgeInsets.all(16),
                      leadingGap: 12,
                      iconBackgroundColor: AppColors.red500,
                      iconPadding: const EdgeInsets.all(5),
                      icon: SvgPicture.asset(
                        'assets/icons/wallet/category_request_rejected_banner.svg',
                        width: 20,
                        height: 20,
                      ),
                      closeIcon: SvgPicture.asset(
                        'assets/icons/transfer_requests/reject_close.svg',
                        width: 20,
                        height: 20,
                      ),
                      closeButtonKey: const Key(
                        'supervisor-transfer-rejected-banner-close',
                      ),
                      onClose: onDismissRejectedBanner,
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

class _RequestIdCard extends StatelessWidget {
  const _RequestIdCard({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) => TransferDetailCard(
    padding: const EdgeInsets.all(8),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SvgPicture.asset(
            'assets/icons/transfer_requests/request_route.svg',
            key: const Key('transfer-request-route-icon'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.semiboldH8_16.copyWith(
              color: AppColors.neutral900,
            ),
          ),
        ),
      ],
    ),
  );
}

class _RejectReasonCard extends StatelessWidget {
  const _RejectReasonCard({this.reason, this.remarks});

  final String? reason;
  final String? remarks;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      border: Border.all(color: AppColors.red500),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Reason for '),
              TextSpan(
                text: 'Reject',
                style: AppTextStyles.semiboldH7_18.copyWith(
                  color: AppColors.red500,
                ),
              ),
            ],
          ),
          style: AppTextStyles.semiboldH7_18.copyWith(
            color: AppColors.neutral950,
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: AppColors.cool300),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Reason : ',
                style: AppTextStyles.semiboldH9_14,
              ),
              TextSpan(text: reason?.trim().isNotEmpty == true ? reason! : '-'),
            ],
          ),
          style: AppTextStyles.mediumSH8_14.copyWith(
            color: AppColors.neutral950,
          ),
        ),
        if (remarks?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Remarks : ',
                  style: AppTextStyles.semiboldH9_14,
                ),
                TextSpan(text: remarks!.trim()),
              ],
            ),
            style: AppTextStyles.mediumSH8_14.copyWith(
              color: AppColors.neutral950,
            ),
          ),
        ],
      ],
    ),
  );
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({
    required this.state,
    required this.transfer,
    required this.items,
    required this.isSupervisor,
    required this.isRejected,
    required this.isCompleted,
    required this.isLoading,
    required this.isVehicleUnavailable,
  });

  final TransferRequestDetailState state;
  final TransferModel? transfer;
  final List<TransferItemModel> items;
  final bool isSupervisor;
  final bool isRejected;
  final bool isCompleted;
  final bool isLoading;
  final bool isVehicleUnavailable;

  @override
  Widget build(BuildContext context) {
    final freeToSend = items.fold<double>(
      0,
      (total, item) => total + (item.dispatchedQty ?? item.qty),
    );
    final availableStock =
        transfer?.fixedQty ??
        ((transfer?.totalQty ?? 0) > 0 ? transfer!.totalQty : freeToSend);
    final showSupervisorTripCost = isSupervisor && (isRejected || isCompleted);
    final rawStatus = transfer?.status.toUpperCase() ?? '';
    final (status, color, background, icon) = isRejected
        ? (
            isSupervisor
                ? context.l10n.transferStatusRejected
                : context.l10n.transferDetailRejected,
            AppColors.red600,
            AppColors.red50,
            'assets/icons/transfer_requests/status_rejected.svg',
          )
        : isVehicleUnavailable
        ? (
            context.l10n.transferDetailVehicleUnavailable,
            AppColors.red600,
            AppColors.red50,
            'assets/icons/profile/logout_warning.svg',
          )
        : isCompleted
        ? (
            context.l10n.transferDetailCompleted,
            AppColors.primary500,
            AppColors.primary100,
            'assets/icons/transfer_requests/status_completed.svg',
          )
        : isLoading
        ? (
            rawStatus.contains('DISPATCH') && isSupervisor
                ? context.l10n.supervisorTransferDispatchStatus
                : rawStatus.contains('DISPATCH')
                ? context.l10n.transferDetailVehicleDispatched
                : context.l10n.transferDetailWaitingLoading,
            AppColors.secondary500,
            AppColors.secondary50,
            'assets/icons/transfer_requests/status_dispatch.svg',
          )
        : (
            isSupervisor
                ? context.l10n.transferStatusPending
                : context.l10n.transferDetailWaitingManager,
            AppColors.yellow600,
            AppColors.yellow50,
            'assets/icons/records/status_pending.svg',
          );

    return TransferDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.transferRequestInformation,
            style: AppTextStyles.semiboldH7_18.copyWith(
              color: AppColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.cool300),
          const SizedBox(height: 12),
          TransferDetailRow(
            label: context.l10n.transferDetailFromLocation,
            values: [
              transfer?.centerName ??
                  (transfer == null
                      ? context.l10n.transferDetailFromLocationValue
                      : '-'),
            ],
            showDivider: !isSupervisor || isRejected,
          ),
          if (!(isSupervisor && isRejected))
            TransferDetailRow(
              label: context.l10n.transferDetailToLocation,
              values: [
                transfer?.destinationName ??
                    transfer?.destinationId ??
                    (transfer == null
                        ? context.l10n.transferDetailToLocationValue
                        : '-'),
              ],
            ),
          TransferDetailRow(
            label: context.l10n.transferDetailAvailableStock,
            values: [
              transfer == null
                  ? context.l10n.transferDetailAvailableStockValue
                  : '${availableStock.toStringAsFixed(2)} KG',
            ],
            showDivider: !isSupervisor || isCompleted,
          ),
          if (!(isSupervisor && isCompleted))
            TransferDetailRow(
              label: context.l10n.supervisorTransferFreeToSend,
              values: ['${freeToSend.toStringAsFixed(2)} KG'],
            ),
          TransferDetailRow(
            label: context.l10n.transferDetailDateTime,
            values: [
              transfer == null
                  ? context.l10n.transferDetailDateTimeValue
                  : _formatTransferDateTime(transfer!.requestedAt),
            ],
          ),
          TransferDetailRow(
            label: context.l10n.transferDetailRequestedBy,
            values: [
              transfer?.requestedByName ??
                  (transfer == null
                      ? context.l10n.transferDetailRequestedByValue
                      : '-'),
            ],
            showDivider: !showSupervisorTripCost,
          ),
          if (showSupervisorTripCost)
            TransferDetailRow(
              label: 'Estimated trip cost',
              values: [
                transfer?.estimatedExpense == null
                    ? '-'
                    : '₹ ${transfer!.estimatedExpense!.toStringAsFixed(0)}',
              ],
            ),
          Text(
            context.l10n.transferDetailRequestStatus,
            style: AppTextStyles.semiboldH9_14.copyWith(
              color: AppColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),
          TransferStatusChip(
            label: status,
            color: color,
            background: background,
            icon: icon,
            iconWidth: isRejected ? 18.1671 : 20,
            iconHeight: isRejected ? 16.5 : 20,
            borderRadius: isRejected ? 12 : 8,
          ),
        ],
      ),
    );
  }
}

class _SupervisorVehicleInformationCard extends StatelessWidget {
  const _SupervisorVehicleInformationCard({required this.transfer});

  final TransferModel transfer;

  @override
  Widget build(BuildContext context) => TransferDetailCard(
    key: const Key('supervisor-transfer-vehicle-information'),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.transferVehicleInformation,
          style: AppTextStyles.semiboldH7_18.copyWith(
            color: AppColors.neutral950,
          ),
        ),
        const SizedBox(height: 16),
        TransferDetailRow(
          label: context.l10n.transferDetailVehicle,
          values: [
            transfer.plannedVehicleNumber ?? transfer.vehiclePlate ?? '-',
          ],
          showDivider: false,
        ),
        const SizedBox(height: 6),
        TransferDetailRow(
          label: context.l10n.transferEstimateTimeToReach,
          values: [_estimateTimeToReach(context, transfer)],
          showDivider: false,
        ),
      ],
    ),
  );
}

String _estimateTimeToReach(BuildContext context, TransferModel transfer) {
  final requested = DateTime.tryParse(transfer.requestedAt);
  final expected = DateTime.tryParse(transfer.truckExpectedAt ?? '');
  if (requested == null || expected == null || !expected.isAfter(requested)) {
    return context.l10n.transferEstimateTimeValue;
  }
  final minutes = expected.difference(requested).inMinutes;
  final hours = (minutes / 60).ceil();
  return context.l10n.transferEstimateHours(hours);
}

class _CollectionManagerCard extends StatelessWidget {
  const _CollectionManagerCard({required this.transfer});

  final TransferModel? transfer;

  @override
  Widget build(BuildContext context) {
    final status = transfer?.status.toUpperCase() ?? '';
    final dispatchNote = transfer?.dispatchNote?.trim();
    final showDispatchNote =
        dispatchNote?.isNotEmpty == true &&
        (status.contains('APPROV') ||
            status.contains('DISPATCH') ||
            status.contains('LOAD') ||
            status.contains('HAND') ||
            status.contains('RECEIV') ||
            status.contains('COMPLET') ||
            status.contains('CLOSED'));

    return FutureBuilder<String?>(
      future: EerlLocalRepository.instance.activeRole,
      builder: (context, snapshot) {
        final isSupervisor =
            snapshot.data?.toUpperCase().contains('SUPERVISOR') == true;
        final isSale = transfer?.type.toUpperCase().contains('SALE') == true;
        final showApprovedBy =
            showDispatchNote &&
            isSupervisor &&
            transfer?.decidedByName?.trim().isNotEmpty == true;
        return TransferDetailCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.transferFromCollectionManager,
                style: AppTextStyles.semiboldH7_18.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1, color: AppColors.cool300),
              const SizedBox(height: 12),
              TransferDetailRow(
                label: 'Arranged truck',
                values: [
                  transfer?.plannedVehicleNumber == null
                      ? '-'
                      : '${transfer!.plannedVehicleNumber} · '
                            '${transfer!.plannedVehicleOwnership == 'COMPANY' ? 'Company truck' : 'Hired'}',
                ],
              ),
              TransferDetailRow(
                label: 'Truck arrives',
                values: [
                  transfer?.truckExpectedAt == null
                      ? (transfer == null
                            ? context.l10n.transferEstimateTimeValue
                            : '-')
                      : _formatTransferDateTime(transfer!.truckExpectedAt!),
                ],
                showDivider: showApprovedBy || showDispatchNote,
              ),
              if (showApprovedBy)
                TransferDetailRow(
                  label: 'Approved by',
                  values: [transfer!.decidedByName!.trim()],
                  showDivider: true,
                ),
              if (showDispatchNote)
                TransferDetailRow(
                  key: const Key('transfer-dispatch-note'),
                  label: isSupervisor
                      ? 'Note for the agent'
                      : isSale
                      ? 'Note'
                      : 'Note from supervisor',
                  values: [dispatchNote!],
                  showDivider: false,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DispatchPhotos extends StatelessWidget {
  const _DispatchPhotos({required this.transfer});

  final TransferModel transfer;

  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<TransferDispatchDraftModel>(
    future: EerlLocalRepository.instance.getTransferDispatchDraft(transfer.id),
    builder: (context, snapshot) {
      final localById = {
        for (final photo
            in snapshot.data?.photos ?? const <TransferDispatchPhotoModel>[])
          photo.id: photo,
      };
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _photoGroup('Vehicle photos', transfer.vehiclePhotoUrls, localById),
          if (transfer.weighbridgePhotoUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            _photoGroup(
              'Weighbridge photos',
              transfer.weighbridgePhotoUrls,
              localById,
            ),
          ],
        ],
      );
    },
  );

  Widget _photoGroup(
    String label,
    List<String> values,
    Map<String, TransferDispatchPhotoModel> localById,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.semiboldH9_14),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final value in values)
            _photo(value, localById[value]?.localPath),
        ],
      ),
    ],
  );

  Widget _photo(String value, String? localPath) => ClipRRect(
    borderRadius: BorderRadius.circular(6),
    child: localPath != null
        ? Image.file(
            File(localPath),
            width: 76,
            height: 58,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _photoPlaceholder(),
          )
        : Image.network(
            value,
            width: 76,
            height: 58,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _photoPlaceholder(),
          ),
  );

  Widget _photoPlaceholder() => Container(
    width: 76,
    height: 58,
    color: AppColors.cool200,
    child: const Icon(Icons.image_outlined),
  );
}

class _AgentDispatchCard extends StatelessWidget {
  const _AgentDispatchCard({required this.transfer});

  final TransferModel transfer;

  @override
  Widget build(BuildContext context) => TransferDetailCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Agent dispatch', style: AppTextStyles.semiboldH7_18),
        const SizedBox(height: 8),
        const Divider(height: 1, color: AppColors.cool300),
        const SizedBox(height: 12),
        TransferDetailRow(
          label: context.l10n.transferDetailVehicle,
          values: [transfer.vehiclePlate ?? '-'],
        ),
        TransferDetailRow(
          label: 'Driver',
          values: [transfer.driverName ?? '-'],
        ),
        TransferDetailRow(
          label: 'Loaded weight',
          values: [
            transfer.dispatchedWeight == null
                ? '-'
                : '${transfer.dispatchedWeight!.toStringAsFixed(2)} KG',
          ],
        ),
        if (transfer.baleCount != null)
          TransferDetailRow(
            label: 'Bales / boris',
            values: ['${transfer.baleCount}'],
          ),
        TransferDetailRow(
          label: 'Dispatched at',
          values: [
            transfer.handedOverAt == null
                ? '-'
                : _formatTransferDateTime(transfer.handedOverAt!),
          ],
          showDivider: false,
        ),
        if (transfer.vehiclePhotoUrls.isNotEmpty ||
            transfer.weighbridgePhotoUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          _DispatchPhotos(transfer: transfer),
        ],
      ],
    ),
  );
}

class _SupervisorDispatchEvidence extends StatelessWidget {
  const _SupervisorDispatchEvidence({required this.transfer});

  final TransferModel transfer;

  @override
  Widget build(BuildContext context) => Column(
    key: const Key('supervisor-transfer-dispatch-evidence'),
    children: [
      _SupervisorEvidenceCard(
        label: 'Vehicle number',
        value: transfer.vehiclePlate ?? '-',
      ),
      const SizedBox(height: 16),
      _SupervisorEvidenceCard(
        label: 'Driver Detail',
        value: transfer.driverName ?? '-',
      ),
      const SizedBox(height: 16),
      _SupervisorEvidenceCard(
        label: 'Loaded Weight',
        value: transfer.dispatchedWeight == null
            ? '-'
            : 'KG   ${transfer.dispatchedWeight!.toStringAsFixed(2)}',
      ),
      const SizedBox(height: 16),
      _SupervisorEvidenceCard(
        label: 'Bales / boris',
        value: transfer.baleCount?.toString() ?? '-',
      ),
      const SizedBox(height: 16),
      _SupervisorEvidenceCard(
        label: 'Loaded at',
        value: transfer.handedOverAt == null
            ? '-'
            : _formatTransferDateTime(transfer.handedOverAt!),
      ),
      if (transfer.vehiclePhotoUrls.isNotEmpty) ...[
        const SizedBox(height: 16),
        _SupervisorVehiclePhotoCard(transfer: transfer),
      ],
    ],
  );
}

class _SupervisorEvidenceCard extends StatelessWidget {
  const _SupervisorEvidenceCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cool200,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.semiboldH8_16.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: AppColors.cool400),
        const SizedBox(height: 12),
        Text(
          value,
          style: AppTextStyles.mediumSH8_14.copyWith(
            color: AppColors.neutral600,
          ),
        ),
      ],
    ),
  );
}

class _SupervisorVehiclePhotoCard extends StatelessWidget {
  const _SupervisorVehiclePhotoCard({required this.transfer});

  final TransferModel transfer;

  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<TransferDispatchDraftModel>(
    future: EerlLocalRepository.instance.getTransferDispatchDraft(transfer.id),
    builder: (context, snapshot) {
      final localById = {
        for (final photo
            in snapshot.data?.photos ?? const <TransferDispatchPhotoModel>[])
          photo.id: photo.localPath,
      };
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cool200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Photo',
              style: AppTextStyles.semiboldH8_16.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.cool400),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 8) / 2;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final value in transfer.vehiclePhotoUrls)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: localById[value] != null
                            ? Image.file(
                                File(localById[value]!),
                                width: width,
                                height: 92,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _evidencePhotoPlaceholder(width),
                              )
                            : Image.network(
                                value,
                                width: width,
                                height: 92,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _evidencePhotoPlaceholder(width),
                              ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      );
    },
  );

  Widget _evidencePhotoPlaceholder(double width) => Container(
    width: width,
    height: 92,
    color: AppColors.cool300,
    alignment: Alignment.center,
    child: const Icon(Icons.image_outlined, color: AppColors.neutral600),
  );
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.items, this.title});

  final List<TransferItemModel> items;
  final String? title;

  @override
  Widget build(BuildContext context) => TransferDetailCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? context.l10n.transferItemsTitle,
          style: AppTextStyles.semiboldH7_18.copyWith(
            color: AppColors.neutral950,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.transferItemName,
                style: AppTextStyles.semiboldH9_14.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
            ),
            Text(
              context.l10n.transferItemQuantity,
              style: AppTextStyles.semiboldH9_14.copyWith(
                color: AppColors.neutral950,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, color: AppColors.cool300),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Text(
            '-',
            style: AppTextStyles.regularB7_14.copyWith(
              color: AppColors.neutral600,
            ),
          )
        else
          for (var index = 0; index < items.length; index++) ...[
            Row(
              key: ValueKey(items[index].id),
              children: [
                Expanded(
                  child: Text(
                    items[index].name ?? items[index].itemId,
                    style: AppTextStyles.boldH8_14.copyWith(
                      color: AppColors.primary500,
                    ),
                  ),
                ),
                Text(
                  '${(items[index].dispatchedQty ?? items[index].qty).toStringAsFixed(2)} '
                          '${items[index].unitCode ?? ''}'
                      .trim(),
                  style: AppTextStyles.boldH8_14.copyWith(
                    color: AppColors.primary500,
                  ),
                ),
              ],
            ),
            if (index != items.length - 1) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.cool300),
              const SizedBox(height: 10),
            ],
          ],
      ],
    ),
  );
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.state, required this.transfer});

  final TransferRequestDetailState state;
  final TransferModel? transfer;

  @override
  Widget build(BuildContext context) {
    final rejected = state == TransferRequestDetailState.rejected;
    final loading = state == TransferRequestDetailState.waitingForLoading;
    final completed = state == TransferRequestDetailState.completed;
    final verified = loading || completed;

    return TransferDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.transferStatusTimeline,
            style: AppTextStyles.semiboldH8_16,
          ),
          const SizedBox(height: 14),
          TransferTimelineStep(
            title: context.l10n.transferTimelineCreated,
            subtitle: transfer == null
                ? context.l10n.transferTimelineCreatedDate
                : _formatTransferDateTime(transfer!.requestedAt),
            color: AppColors.primary500,
            iconAsset: 'assets/icons/wallet/status_verified.svg',
          ),
          TransferTimelineStep(
            title: rejected
                ? context.l10n.transferTimelineRejected
                : context.l10n.transferTimelinePendingVerification,
            subtitle: rejected
                ? context.l10n.transferTimelineRejectedSubtitle
                : verified
                ? context.l10n.transferTimelineVerificationCompleted
                : context.l10n.transferTimelineWaitingVerification,
            color: rejected
                ? AppColors.red500
                : verified
                ? AppColors.primary500
                : AppColors.yellow600,
            iconAsset: rejected
                ? 'assets/icons/profile/logout_warning.svg'
                : verified
                ? 'assets/icons/wallet/status_verified.svg'
                : 'assets/icons/records/status_pending.svg',
          ),
          TransferTimelineStep(
            title: context.l10n.transferTimelinePendingLoading,
            subtitle: completed
                ? context.l10n.transferTimelineLoadingCompleted
                : context.l10n.transferTimelineWaitingLoading,
            color: completed
                ? AppColors.primary500
                : loading
                ? AppColors.yellow600
                : AppColors.cool400,
            iconAsset: completed
                ? 'assets/icons/wallet/status_verified.svg'
                : loading
                ? 'assets/icons/records/status_pending.svg'
                : 'assets/icons/home/transfer.svg',
          ),
          TransferTimelineStep(
            title: context.l10n.transferTimelineVerified,
            subtitle: completed
                ? context.l10n.transferTimelineCompletedSubtitle
                : context.l10n.transferTimelineVerifiedSubtitle,
            color: completed ? AppColors.primary500 : AppColors.cool400,
            iconAsset: completed
                ? 'assets/icons/wallet/status_verified.svg'
                : 'assets/icons/home/verified.svg',
            showLine: false,
          ),
        ],
      ),
    );
  }
}

String _formatTransferDateTime(String value) {
  final date = DateTime.tryParse(value)?.toLocal();
  return date == null ? value : DateFormat('dd MMM yyyy, hh:mm a').format(date);
}
