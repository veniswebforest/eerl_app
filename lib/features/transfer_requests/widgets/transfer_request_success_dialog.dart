import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class TransferRequestSuccessDialog extends StatelessWidget {
  const TransferRequestSuccessDialog({super.key, required this.onBackToList});

  final VoidCallback onBackToList;

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 28),
    backgroundColor: AppColors.neutral50,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.transferSuccessTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.semiboldH6_20.copyWith(
              color: AppColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.transferSuccessSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.mediumSH8_14.copyWith(
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              key: const Key('transfer-back-to-list'),
              onPressed: onBackToList,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary500),
              ),
              child: Text(context.l10n.transferBackToList),
            ),
          ),
        ],
      ),
    ),
  );
}
