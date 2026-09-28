import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/supervisor_expense/model/supervisor_expense_item.dart';
import 'package:eerl_app/features/wallet/widgets/wallet_assets.dart';

class SupervisorExpenseCard extends StatelessWidget {
  const SupervisorExpenseCard({
    super.key,
    required this.item,
    required this.statusLabel,
    required this.onTap,
  });

  final SupervisorExpenseItem item;
  final String statusLabel;
  final VoidCallback onTap;

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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: ValueKey('supervisor-expense-${item.status.name}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.agentName,
                          style: AppTextStyles.semiboldH8_16.copyWith(
                            color: AppColors.neutral950,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.role,
                          style: AppTextStyles.regularB8_12.copyWith(
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SvgPicture.asset(
                    WalletAssets.openDetails,
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.cool200),
              const SizedBox(height: 12),
              Text(
                item.category,
                style: AppTextStyles.semiboldH9_14.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.date,
                style: AppTextStyles.mediumSH9_12.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.amount,
                      style: AppTextStyles.semiboldH7_18.copyWith(
                        color: item.status == SupervisorExpenseStatus.rejected
                            ? AppColors.red600
                            : AppColors.neutral950,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(icon, width: 18, height: 18),
                        const SizedBox(width: 5),
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
    );
  }
}

class SupervisorExpenseToast extends StatelessWidget {
  const SupervisorExpenseToast({
    super.key,
    required this.approved,
    required this.title,
    required this.message,
  });
  final bool approved;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('supervisor-expense-toast'),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: approved ? AppColors.primary100 : AppColors.red50,
      border: Border.all(
        color: approved ? AppColors.primary500 : AppColors.red500,
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(
          approved ? Icons.check_circle : Icons.cancel,
          color: approved ? AppColors.primary500 : AppColors.red500,
          size: 28,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.semiboldH9_14.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: AppTextStyles.regularB8_12.copyWith(
                  color: AppColors.neutral700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
