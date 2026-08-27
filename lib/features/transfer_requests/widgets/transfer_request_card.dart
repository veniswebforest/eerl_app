import 'package:eerl_app/features/home/widgets/home_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/transfer_request_item.dart';

class TransferRequestCard extends StatelessWidget {
  const TransferRequestCard({
    super.key,
    required this.item,
    this.highlighted = false,
    this.onTap,
  });

  final TransferRequestItem item;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlighted ? AppColors.primary500 : AppColors.cool100,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.id,
                  style: AppTextStyles.semiboldH9_14.copyWith(
                    color: AppColors.neutral900,
                  ),
                ),
              ),
              SvgPicture.asset(
                'assets/icons/wallet/open_details.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  highlighted ? AppColors.primary500 : AppColors.neutral400,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: HomeAssets.location,
            label: context.l10n.transferDestination,
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: 'assets/icons/home/collection_weight.svg',
            label: context.l10n.transferTotalWeight(item.totalWeight),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DetailRow(
                  icon: 'assets/icons/wallet/status_verified.svg',
                  label: context.l10n.transferDateTime(item.date, item.time),
                  compact: true,
                ),
              ),
              const SizedBox(width: 8),
              _TransferStatus(status: item.status),
            ],
          ),
        ],
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    this.compact = false,
  });

  final String icon;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
    children: [
      SvgPicture.asset(
        icon,
        width: 18,
        height: 18,
        colorFilter: const ColorFilter.mode(
          AppColors.primary700,
          BlendMode.srcIn,
        ),
      ),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.semiboldH9_14.copyWith(
            color: AppColors.neutral950,
          ),
        ),
      ),
    ],
  );
}

class _TransferStatus extends StatelessWidget {
  const _TransferStatus({required this.status});

  final TransferRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, background, icon) = switch (status) {
      TransferRequestStatus.pending => (
        context.l10n.transferStatusPending,
        AppColors.yellow600,
        AppColors.yellow50,
        'assets/icons/records/status_pending.svg',
      ),
      TransferRequestStatus.approved => (
        context.l10n.transferStatusApproved,
        AppColors.primary500,
        AppColors.primary50,
        'assets/icons/wallet/status_verified.svg',
      ),
      TransferRequestStatus.dispatch => (
        context.l10n.transferStatusDispatch,
        AppColors.secondary500,
        AppColors.secondary50,
        'assets/icons/home/transfer.svg',
      ),
      TransferRequestStatus.rejected => (
        context.l10n.transferStatusRejected,
        AppColors.red600,
        AppColors.red50,
        'assets/icons/profile/logout_warning.svg',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            icon,
            width: 15,
            height: 15,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.mediumSH9_12.copyWith(color: color)),
        ],
      ),
    );
  }
}
