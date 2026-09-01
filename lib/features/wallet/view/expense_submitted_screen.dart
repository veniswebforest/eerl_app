import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class ExpenseSubmittedScreen extends StatelessWidget {
  const ExpenseSubmittedScreen({super.key, required this.onBackToWallet});

  final VoidCallback onBackToWallet;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: Stack(
      fit: StackFit.expand,
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: ColoredBox(color: Colors.black.withValues(alpha: .60)),
        ),
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 335),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/expense_submitted_success.png',
                        width: 122,
                        height: 122,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        context.l10n.expenseSubmittedTitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.boldH5_24.copyWith(
                          color: AppColors.neutral950,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.expenseSubmittedDeduction,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.expenseSubmittedBalance,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          key: const Key('expense-back-to-wallet'),
                          onPressed: onBackToWallet,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.cool200,
                            foregroundColor: AppColors.neutral950,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: AppTextStyles.semiboldH8_16,
                          ),
                          child: Text(context.l10n.expenseBackToWallet),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
