import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../widgets/end_day_activity_card.dart';
import '../widgets/end_day_balance_field.dart';
import '../widgets/end_day_confirm_dialog.dart';

class EndMyDayScreen extends StatelessWidget {
  const EndMyDayScreen({super.key, required this.onBack, this.onEndDay});

  final VoidCallback onBack;
  final VoidCallback? onEndDay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final activities = [
      EndDayActivityItem(
        label: l10n.endDayCompletedCollections,
        value: l10n.endDayCompletedValue,
      ),
      EndDayActivityItem(
        label: l10n.endDayPendingCollections,
        value: l10n.endDayPendingValue,
      ),
      EndDayActivityItem(
        label: l10n.endDayWasteCollected,
        value: l10n.endDayWasteValue,
      ),
      EndDayActivityItem(
        label: l10n.endDayExpensesLogged,
        value: l10n.endDayExpensesCount,
      ),
      EndDayActivityItem(
        label: l10n.endDayVerificationPending,
        value: l10n.endDayPendingValue,
        valueColor: AppColors.yellow600,
      ),
      EndDayActivityItem(
        label: l10n.endDayOfflineSync,
        value: l10n.endDayPendingStatus,
        valueColor: AppColors.yellow600,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: l10n.endMyDay,
        onBackTap: onBack,
        backIconAsset: 'assets/icons/records/back.svg',
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    children: [
                      EndDayBalanceField(
                        label: l10n.endDayOpeningBalance,
                        value: l10n.endDayOpeningBalanceValue,
                      ),
                      const SizedBox(height: 16),
                      EndDayBalanceField(
                        label: l10n.endDayExpensesLogged,
                        value: l10n.endDayExpensesValue,
                      ),
                      const SizedBox(height: 16),
                      EndDayBalanceField(
                        label: l10n.endDayTotalPurchase,
                        value: l10n.endDayPurchaseValue,
                      ),
                      const SizedBox(height: 16),
                      _ClosingBalanceCard(
                        label: l10n.endDayClosingBalance,
                        value: l10n.endDayClosingBalanceValue,
                        hint: l10n.endDayBalanceHint,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.endDayActivitySummary,
                        style: AppTextStyles.semiboldH7_18.copyWith(
                          color: AppColors.neutral950,
                        ),
                      ),
                      const SizedBox(height: 12),
                      EndDayActivityCard(items: activities),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  color: Colors.white,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          key: const Key('confirm-end-my-day-button'),
                          onPressed: () => EndDayConfirmDialog.show(
                            context,
                            onConfirmed: onEndDay,
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.primary500,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            l10n.endMyDay,
                            style: AppTextStyles.semiboldH9_14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.endDayWarning,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.regularB8_12.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClosingBalanceCard extends StatelessWidget {
  const _ClosingBalanceCard({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x16000000),
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(label, style: AppTextStyles.mediumSH8_14),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.semiboldH5_24.copyWith(
                  color: AppColors.primary600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          hint,
          textAlign: TextAlign.center,
          style: AppTextStyles.regularB7_14.copyWith(
            color: AppColors.neutral700,
          ),
        ),
      ],
    ),
  );
}
