import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'wallet_assets.dart';

class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({
    super.key,
    required this.balanceLabel,
    required this.balance,
    required this.spentLabel,
    required this.spent,
  });

  final String balanceLabel;
  final String balance;
  final String spentLabel;
  final String spent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 90),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.walletGradientStart, AppColors.walletGradientEnd],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -16,
            top: -16,
            child: SvgPicture.asset(
              WalletAssets.balanceDecoration,
              width: 92,
              height: 90,
            ),
          ),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _BalanceValue(label: balanceLabel, value: balance),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: SvgPicture.asset(
                  WalletAssets.balanceDivider,
                  width: 1,
                  height: 59,
                ),
              ),
              Expanded(
                flex: 2,
                child: _BalanceValue(label: spentLabel, value: spent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceValue extends StatelessWidget {
  const _BalanceValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.mediumSH8_14.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: AppTextStyles.boldH4_28.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
