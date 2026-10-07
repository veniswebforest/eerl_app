import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../model/transfer_request_detail_state.dart';
import '../widgets/transfer_request_detail_widgets.dart';
import 'transfer_dispatch_flow_screen.dart';

typedef TransferRequestDetailData = ({
  TransferModel? transfer,
  List<TransferItemModel> items,
});
typedef TransferRequestDetailLoader =
    Future<TransferRequestDetailData> Function(String transferId);

class TransferRequestDetailScreen extends StatefulWidget {
  const TransferRequestDetailScreen({
    super.key,
    required this.transferId,
    this.detailLoader,
  });

  final String transferId;
  final TransferRequestDetailLoader? detailLoader;

  @override
  State<TransferRequestDetailScreen> createState() =>
      _TransferRequestDetailScreenState();
}

class _TransferRequestDetailScreenState
    extends State<TransferRequestDetailScreen> {
  bool _dispatchFlowOpen = false;
  late final LocalQueryController<TransferRequestDetailData> _controller;

  @override
  void initState() {
    super.initState();
    _controller = LocalQueryController(() {
      final loader = widget.detailLoader;
      if (loader != null) return loader(widget.transferId);
      return _loadLocalDetail(widget.transferId);
    })..load();
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
    canPop: !_dispatchFlowOpen,
    child: _dispatchFlowOpen
        ? TransferDispatchFlowScreen(
            onBack: () => setState(() => _dispatchFlowOpen = false),
            onComplete: () => setState(() => _dispatchFlowOpen = false),
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
                state: _detailState(transfer!.status),
                transfer: transfer,
                items: _controller.data?.items ?? const <TransferItemModel>[],
                onVehicleArrived: () =>
                    setState(() => _dispatchFlowOpen = true),
              );
            },
          ),
  );

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
        status.contains('HAND')) {
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
    required this.onVehicleArrived,
  });

  final TransferRequestDetailState state;
  final TransferModel? transfer;
  final List<TransferItemModel> items;
  final VoidCallback onVehicleArrived;

  bool get _isRejected => state == TransferRequestDetailState.rejected;

  bool get _isCompleted => state == TransferRequestDetailState.completed;

  bool get _isLoading => state == TransferRequestDetailState.waitingForLoading;

  bool get _isVehicleUnavailable =>
      state == TransferRequestDetailState.vehicleUnavailable;

  bool get _hasVehicle {
    if (_isRejected || _isVehicleUnavailable) {
      return false;
    }
    if (transfer == null) return true;
    return transfer!.vehiclePlate?.trim().isNotEmpty == true;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    appBar: CustomAppBar(
      title: context.l10n.transferDetailTitle,
      backIconAsset: 'assets/icons/records/back.svg',
    ),
    bottomNavigationBar: _isLoading && _hasVehicle
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
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            key: const Key('transfer-request-detail-scroll'),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              if (_isRejected) ...[
                _RejectReasonCard(reason: transfer?.rejectionReason),
                const SizedBox(height: 12),
              ],
              _RequestIdCard(
                value:
                    transfer?.number ??
                    transfer?.id ??
                    context.l10n.transferDetailRequestId,
              ),
              const SizedBox(height: 12),
              _InformationCard(
                state: state,
                transfer: transfer,
                items: items,
                isRejected: _isRejected,
                isCompleted: _isCompleted,
                isLoading: _isLoading,
                isVehicleUnavailable: _isVehicleUnavailable,
              ),
              const SizedBox(height: 12),
              if (_hasVehicle) ...[
                _CollectionManagerCard(transfer: transfer),
                const SizedBox(height: 12),
              ],
              _ItemsCard(items: items),
              const SizedBox(height: 12),
              _TimelineCard(state: state, transfer: transfer),
            ],
          ),
        ),
      ),
    ),
  );
}

class _RequestIdCard extends StatelessWidget {
  const _RequestIdCard({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) => TransferDetailCard(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SvgPicture.asset(
            'assets/icons/home/transfer.svg',
            colorFilter: const ColorFilter.mode(
              AppColors.primary500,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          value,
          style: AppTextStyles.semiboldH8_16.copyWith(
            color: AppColors.neutral900,
          ),
        ),
      ],
    ),
  );
}

class _RejectReasonCard extends StatelessWidget {
  const _RejectReasonCard({this.reason});

  final String? reason;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      border: Border.all(color: AppColors.red500),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.transferRejectReasonTitle,
          style: AppTextStyles.semiboldH9_14,
        ),
        const SizedBox(height: 12),
        Text(
          reason?.trim().isNotEmpty == true ? reason! : '-',
          style: AppTextStyles.regularB8_12,
        ),
      ],
    ),
  );
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({
    required this.state,
    required this.transfer,
    required this.items,
    required this.isRejected,
    required this.isCompleted,
    required this.isLoading,
    required this.isVehicleUnavailable,
  });

  final TransferRequestDetailState state;
  final TransferModel? transfer;
  final List<TransferItemModel> items;
  final bool isRejected;
  final bool isCompleted;
  final bool isLoading;
  final bool isVehicleUnavailable;

  @override
  Widget build(BuildContext context) {
    final totalQuantity =
        transfer?.fixedQty ??
        items.fold<double>(
          0,
          (total, item) => total + (item.dispatchedQty ?? item.qty),
        );
    final rawStatus = transfer?.status.toUpperCase() ?? '';
    final (status, color, background, icon) = isRejected
        ? (
            context.l10n.transferDetailRejected,
            AppColors.red600,
            AppColors.red50,
            'assets/icons/profile/logout_warning.svg',
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
            AppColors.primary50,
            'assets/icons/wallet/status_verified.svg',
          )
        : isLoading
        ? (
            rawStatus.contains('DISPATCH')
                ? context.l10n.transferDetailVehicleDispatched
                : context.l10n.transferDetailWaitingLoading,
            AppColors.secondary500,
            AppColors.secondary50,
            'assets/icons/home/transfer.svg',
          )
        : (
            context.l10n.transferDetailWaitingManager,
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
                  transfer?.centerId ??
                  (transfer == null
                      ? context.l10n.transferDetailFromLocationValue
                      : '-'),
            ],
          ),
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
                  : '${totalQuantity.toStringAsFixed(2)} KG',
            ],
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
          ),
        ],
      ),
    );
  }
}

class _CollectionManagerCard extends StatelessWidget {
  const _CollectionManagerCard({required this.transfer});

  final TransferModel? transfer;

  @override
  Widget build(BuildContext context) => TransferDetailCard(
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
          label: context.l10n.transferDetailVehicle,
          values: [
            transfer?.vehiclePlate ??
                (transfer == null
                    ? context.l10n.transferDetailVehicleNumber
                    : '-'),
          ],
        ),
        TransferDetailRow(
          label: context.l10n.transferEstimateTimeToReach,
          values: [
            transfer?.truckExpectedAt == null
                ? (transfer == null
                      ? context.l10n.transferEstimateTimeValue
                      : '-')
                : _formatTransferDateTime(transfer!.truckExpectedAt!),
          ],
          showDivider: false,
        ),
      ],
    ),
  );
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.items});

  final List<TransferItemModel> items;

  @override
  Widget build(BuildContext context) => TransferDetailCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.transferItemsTitle,
          style: AppTextStyles.semiboldH8_16.copyWith(
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
