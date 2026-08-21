import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'wallet_assets.dart';

enum ExpenseClaimStatus { pending, verified, flagged }

class ExpenseClaimCard extends StatelessWidget {
  const ExpenseClaimCard({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.statusLabel,
    required this.status,
    required this.onTap,
  });

  final String title;
  final String date;
  final String amount;
  final String statusLabel;
  final ExpenseClaimStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(status);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.semiboldH8_16.copyWith(
                        color: AppColors.neutral950,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      date,
                      style: AppTextStyles.mediumSH8_14.copyWith(
                        color: AppColors.neutral800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          amount,
                          style: AppTextStyles.semiboldH7_18.copyWith(
                            color: AppColors.yellow600,
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width - 104,
                          ),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: style.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                style.icon,
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  statusLabel,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.semiboldH10_12.copyWith(
                                    color: style.foreground,
                                  ),
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
              Positioned(
                right: 0,
                top: 0,
                child: SvgPicture.asset(
                  WalletAssets.openDetails,
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _ExpenseStatusStyle _statusStyle(ExpenseClaimStatus status) {
    return switch (status) {
      ExpenseClaimStatus.pending => const _ExpenseStatusStyle(
        icon: WalletAssets.statusPending,
        foreground: AppColors.yellow600,
        background: AppColors.yellow50,
      ),
      ExpenseClaimStatus.verified => const _ExpenseStatusStyle(
        icon: WalletAssets.statusVerified,
        foreground: AppColors.primary500,
        background: AppColors.primary100,
      ),
      ExpenseClaimStatus.flagged => const _ExpenseStatusStyle(
        icon: WalletAssets.statusFlagged,
        foreground: AppColors.red600,
        background: AppColors.red50,
      ),
    };
  }
}

class _ExpenseStatusStyle {
  const _ExpenseStatusStyle({
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final String icon;
  final Color foreground;
  final Color background;
}
