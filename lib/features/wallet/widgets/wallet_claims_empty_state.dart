import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'wallet_assets.dart';

class WalletClaimsEmptyState extends StatelessWidget {
  const WalletClaimsEmptyState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 31),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            WalletAssets.emptyRequest,
            key: const Key('wallet-claims-empty-illustration'),
            width: 175,
            height: 170,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            key: const Key('wallet-claims-empty-message'),
            textAlign: TextAlign.center,
            style: AppTextStyles.semiboldH8_16.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    ),
  );
}
