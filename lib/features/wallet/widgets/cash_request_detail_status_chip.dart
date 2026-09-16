import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/wallet/model/cash_request_detail_status.dart';
import 'wallet_assets.dart';

class CashRequestDetailStatusChip extends StatelessWidget {
  const CashRequestDetailStatusChip({
    super.key,
    required this.status,
    required this.label,
  });

  final CashRequestDetailStatus status;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (icon, foreground, background) = switch (status) {
      CashRequestDetailStatus.pending => (
        WalletAssets.statusPending,
        AppColors.yellow600,
        AppColors.yellow50,
      ),
      CashRequestDetailStatus.approved => (
        WalletAssets.statusVerified,
        AppColors.primary500,
        AppColors.primary100,
      ),
      CashRequestDetailStatus.rejected => (
        WalletAssets.statusFlagged,
        AppColors.red500,
        AppColors.red50,
      ),
    };

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(icon, width: 20, height: 20),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.semiboldH10_12.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
