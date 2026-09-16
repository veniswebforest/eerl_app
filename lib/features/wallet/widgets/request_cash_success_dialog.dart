import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class RequestCashSuccessDialog extends StatelessWidget {
  const RequestCashSuccessDialog({
    super.key,
    required this.amount,
    required this.onBackToWallet,
  });

  final String amount;
  final VoidCallback onBackToWallet;

  @override
  Widget build(BuildContext context) => Dialog(
    key: const Key('cash-request-success-dialog'),
    insetPadding: const EdgeInsets.symmetric(horizontal: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 66),
          Text(
            context.l10n.cashRequestSubmittedTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.semiboldH6_20.copyWith(
              color: AppColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.cashRequestSubmittedMessage(amount),
            textAlign: TextAlign.center,
            style: AppTextStyles.regularB8_12.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              key: const Key('cash-request-back-to-wallet'),
              onPressed: onBackToWallet,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.cool200,
                foregroundColor: AppColors.neutral950,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: AppTextStyles.semiboldH9_14,
              ),
              child: Text(context.l10n.cashRequestBackToWallet),
            ),
          ),
        ],
      ),
    ),
  );
}
