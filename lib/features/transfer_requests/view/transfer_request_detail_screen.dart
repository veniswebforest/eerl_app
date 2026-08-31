import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../model/transfer_request_detail_state.dart';
import '../widgets/transfer_request_detail_widgets.dart';

class TransferRequestDetailScreen extends StatelessWidget {
  const TransferRequestDetailScreen({
    super.key,
    required this.state,
    required this.onBack,
  });

  final TransferRequestDetailState state;
  final VoidCallback onBack;

  bool get _isRejected => state == TransferRequestDetailState.rejected;

  bool get _isCompleted => state == TransferRequestDetailState.completed;

  bool get _isLoading => state == TransferRequestDetailState.waitingForLoading;

  bool get _hasVehicle =>
      state != TransferRequestDetailState.vehicleUnavailable && !_isRejected;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    appBar: CustomAppBar(
      title: context.l10n.transferDetailTitle,
      onBackTap: onBack,
      backIconAsset: 'assets/icons/records/back.svg',
    ),
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
                _RejectReasonCard(),
                const SizedBox(height: 12),
              ],
              _RequestIdCard(),
              const SizedBox(height: 12),
              _InformationCard(
                state: state,
                hasVehicle: _hasVehicle,
                isRejected: _isRejected,
                isCompleted: _isCompleted,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 12),
              const _ItemsCard(),
              const SizedBox(height: 12),
              _TimelineCard(state: state),
            ],
          ),
        ),
      ),
    ),
  );
}

class _RequestIdCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => TransferDetailCard(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Row(
      children: [
        Container(
          width: 30,
          height: 30,
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: AppColors.primary50,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            'assets/icons/home/transfer.svg',
            colorFilter: const ColorFilter.mode(
              AppColors.primary500,
              BlendMode.srcIn,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          context.l10n.transferDetailRequestId,
          style: AppTextStyles.semiboldH8_16.copyWith(
            color: AppColors.neutral900,
          ),
        ),
      ],
    ),
  );
}

class _RejectReasonCard extends StatelessWidget {
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
          context.l10n.transferRejectReason,
          style: AppTextStyles.regularB8_12,
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.transferRejectRemarks,
          style: AppTextStyles.regularB8_12,
        ),
      ],
    ),
  );
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({
    required this.state,
    required this.hasVehicle,
    required this.isRejected,
    required this.isCompleted,
    required this.isLoading,
  });

  final TransferRequestDetailState state;
  final bool hasVehicle;
  final bool isRejected;
  final bool isCompleted;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final (status, color, background, icon) = isRejected
        ? (
            context.l10n.transferDetailRejected,
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
            context.l10n.transferDetailWaitingLoading,
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
            label: context.l10n.transferDetailVehicle,
            values: [
              hasVehicle
                  ? context.l10n.transferDetailVehicleNumber
                  : context.l10n.transferDetailVehicleUnavailable,
              context.l10n.transferDetailVehicleCapacity,
            ],
            valueColor: hasVehicle ? null : AppColors.yellow600,
          ),
          TransferDetailRow(
            label: context.l10n.transferDetailFromLocation,
            values: [context.l10n.transferDetailFromLocationValue],
          ),
          TransferDetailRow(
            label: context.l10n.transferDetailToLocation,
            values: [context.l10n.transferDetailToLocationValue],
          ),
          TransferDetailRow(
            label: context.l10n.transferDetailAvailableStock,
            values: [context.l10n.transferDetailAvailableStockValue],
          ),
          TransferDetailRow(
            label: context.l10n.transferDetailDateTime,
            values: [context.l10n.transferDetailDateTimeValue],
          ),
          TransferDetailRow(
            label: context.l10n.transferDetailRequestedBy,
            values: [context.l10n.transferDetailRequestedByValue],
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

class _ItemsCard extends StatelessWidget {
  const _ItemsCard();

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
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.transferDetailPetBottles,
                style: AppTextStyles.boldH8_14.copyWith(
                  color: AppColors.primary500,
                ),
              ),
            ),
            Text(
              context.l10n.transferDetailQuantityValue,
              style: AppTextStyles.boldH8_14.copyWith(
                color: AppColors.primary500,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.state});

  final TransferRequestDetailState state;

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
            subtitle: context.l10n.transferDetailDateTimeValue,
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
