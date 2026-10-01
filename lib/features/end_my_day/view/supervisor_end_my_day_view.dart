import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../widgets/end_day_activity_card.dart';
import '../widgets/end_day_assets.dart';
import '../widgets/supervisor_end_day_activity_card.dart';
import '../widgets/supervisor_end_day_confirm_dialog.dart';

class SupervisorEndMyDayView extends StatelessWidget {
  const SupervisorEndMyDayView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final activities = [
      EndDayActivityItem(
        label: l10n.supervisorActiveAgents,
        value: l10n.supervisorEndDayActiveAgentsValue,
      ),
      EndDayActivityItem(
        label: l10n.supervisorEndDayOfflineAgents,
        value: l10n.supervisorEndDayOfflineAgentsValue,
      ),
      EndDayActivityItem(
        label: l10n.supervisorEndDayPendingVerification,
        value: l10n.supervisorEndDayPendingVerificationValue,
        valueColor: AppColors.yellow600,
      ),
      EndDayActivityItem(
        label: l10n.supervisorEndDayApprovedCollections,
        value: l10n.supervisorEndDayApprovedCollectionsValue,
      ),
      EndDayActivityItem(
        label: l10n.supervisorEndDayRejectedCollections,
        value: l10n.supervisorEndDayRejectedCollectionsValue,
      ),
      EndDayActivityItem(
        label: l10n.endDayOfflineSync,
        value: l10n.endDayPendingStatus,
        valueColor: AppColors.yellow600,
      ),
    ];

    return Scaffold(
      key: const Key('supervisor-end-my-day-screen'),
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: l10n.endMyDay,
        backIconAsset: EndDayAssets.back,
        titleStyle: AppTextStyles.semiboldH6_20,
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.endDayActivitySummary,
                    style: AppTextStyles.semiboldH7_18.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SupervisorEndDayActivityCard(items: activities),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      key: const Key('supervisor-end-my-day-button'),
                      onPressed: () async {
                        final shouldShare =
                            await showSupervisorEndDayConfirmDialog(context);
                        if (context.mounted && shouldShare == true) {
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.primary500,
                        foregroundColor: AppColors.neutral50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.endMyDay,
                        style: AppTextStyles.boldH7_16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      l10n.endDayWarning,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.mediumSH9_12.copyWith(
                        color: AppColors.cool600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
