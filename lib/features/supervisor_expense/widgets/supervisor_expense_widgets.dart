import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/supervisor_expense/model/supervisor_expense_item.dart';
import 'package:eerl_app/features/wallet/widgets/wallet_assets.dart';
import 'package:eerl_app/shared/widgets/app_message_banner.dart';

import '../../home/widgets/home_styles.dart';

class SupervisorExpenseCard extends StatelessWidget {
  const SupervisorExpenseCard({
    super.key,
    required this.item,
    required this.statusLabel,
    required this.onTap,
    this.cardKey,
  });

  final SupervisorExpenseItem item;
  final String statusLabel;
  final VoidCallback onTap;
  final Key? cardKey;

  @override
  Widget build(BuildContext context) {
    final (foreground, background, icon) = switch (item.status) {
      SupervisorExpenseStatus.pending => (
        AppColors.yellow600,
        AppColors.yellow50,
        WalletAssets.statusPending,
      ),
      SupervisorExpenseStatus.approved => (
        AppColors.primary500,
        AppColors.primary100,
        WalletAssets.statusVerified,
      ),
      SupervisorExpenseStatus.rejected => (
        AppColors.red600,
        AppColors.red50,
        WalletAssets.statusFlagged,
      ),
    };
    final amountColor = switch (item.status) {
      SupervisorExpenseStatus.pending => AppColors.yellow600,
      SupervisorExpenseStatus.approved => AppColors.primary500,
      SupervisorExpenseStatus.rejected => AppColors.neutral600,
    };
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [HomeStyles.cardShadow],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: cardKey ?? ValueKey('supervisor-expense-${item.status.name}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: item.agentName,
                              style: AppTextStyles.semiboldH8_16,
                            ),
                            TextSpan(
                              text: ' (${item.role})',
                              style: AppTextStyles.mediumSH9_12,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SvgPicture.asset(
                      WalletAssets.openDetails,
                      width: 24,
                      height: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.category,
                  style: AppTextStyles.semiboldH9_14.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.date,
                  style: AppTextStyles.mediumSH9_12.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.amount,
                        style: AppTextStyles.semiboldH7_18.copyWith(
                          color: amountColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(icon, width: 20, height: 20),
                          const SizedBox(width: 6),
                          Text(
                            statusLabel,
                            style: AppTextStyles.semiboldH10_12.copyWith(
                              color: foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SupervisorExpenseToast extends StatelessWidget {
  const SupervisorExpenseToast({
    super.key,
    required this.approved,
    required this.title,
    required this.message,
    required this.onClose,
  });
  final bool approved;
  final String title;
  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => AppMessageBanner(
    key: const Key('supervisor-expense-toast'),
    title: title,
    subtitle: message,
    color: approved ? AppColors.primary500 : AppColors.red500,
    backgroundColor: approved ? AppColors.primary50 : AppColors.red50,
    borderColor: AppColors.cool400,
    iconBackgroundColor: approved ? AppColors.primary500 : AppColors.red500,
    iconPadding: const EdgeInsets.all(5),
    icon: Icon(
      approved ? Icons.check_rounded : Icons.block_rounded,
      color: Colors.white,
      size: 20,
    ),
    onClose: onClose,
  );
}
