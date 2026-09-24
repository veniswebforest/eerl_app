import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'home_assets.dart';
import 'home_styles.dart';
import 'quick_actions.dart';

class SupervisorQuickActions extends StatelessWidget {
  const SupervisorQuickActions({
    super.key,
    this.onAssignTaskTap,
    this.onAgentsStatusTap,
    this.onCheckStockTap,
    this.onApprovalsTap,
  });

  final VoidCallback? onAssignTaskTap;
  final VoidCallback? onAgentsStatusTap;
  final VoidCallback? onCheckStockTap;
  final VoidCallback? onApprovalsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.quickActions, style: HomeStyles.sectionTitle),
        const SizedBox(height: 16),
        _AssignedTasksCard(onTap: onAssignTaskTap ?? () {}),
        const SizedBox(height: 16),
        QuickActionCard(
          key: const Key('supervisor-agents-status-card'),
          iconAsset: HomeAssets.supervisorAgentsStatus,
          iconColor: AppColors.secondary500,
          iconBg: AppColors.secondary100,
          title: context.l10n.supervisorAgentsStatus,
          subtitle: context.l10n.supervisorAgentsStatusSubtitle,
          buttonLabel: context.l10n.supervisorViewStatus,
          height: 166,
          titleStyle: AppTextStyles.semiboldH7_18.copyWith(
            color: AppColors.neutral950,
          ),
          subtitleStyle: AppTextStyles.mediumSH8_14.copyWith(
            color: AppColors.neutral600,
          ),
          onTap: onAgentsStatusTap ?? () {},
        ),
        const SizedBox(height: 16),
        QuickActionCard(
          key: const Key('supervisor-check-stock-card'),
          iconAsset: HomeAssets.supervisorCheckStock,
          iconColor: AppColors.purple,
          iconBg: AppColors.purpleLight,
          title: context.l10n.supervisorCheckStock,
          subtitle: context.l10n.supervisorCheckStockSubtitle,
          buttonLabel: context.l10n.supervisorViewStock,
          height: 166,
          titleStyle: AppTextStyles.semiboldH7_18.copyWith(
            color: AppColors.neutral950,
          ),
          subtitleStyle: AppTextStyles.mediumSH8_14.copyWith(
            color: AppColors.neutral600,
          ),
          onTap: onCheckStockTap ?? () {},
        ),
        const SizedBox(height: 16),
        QuickActionCard(
          key: const Key('supervisor-approvals-card'),
          iconAsset: HomeAssets.supervisorApprovalsClaims,
          iconColor: AppColors.orange,
          iconBg: AppColors.orangeLight,
          title: context.l10n.supervisorApprovalsClaims,
          subtitle: context.l10n.supervisorApprovalsSubtitle,
          buttonLabel: context.l10n.supervisorManageApprovals,
          height: 166,
          titleStyle: AppTextStyles.semiboldH7_18.copyWith(
            color: AppColors.neutral950,
          ),
          subtitleStyle: AppTextStyles.mediumSH8_14.copyWith(
            color: AppColors.neutral600,
          ),
          iconWidth: 15.7107,
          iconHeight: 20.299,
          badge: '12',
          onTap: onApprovalsTap ?? () {},
        ),
      ],
    );
  }
}

class _AssignedTasksCard extends StatelessWidget {
  const _AssignedTasksCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 218,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [HomeStyles.cardShadow],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.orchidLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(HomeAssets.supervisorAssignedTasks),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.supervisorAssignedTasks,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.semiboldH7_18.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _TaskCount(
                  value: '03',
                  label: context.l10n.supervisorPending,
                  background: AppColors.yellow50,
                  valueColor: AppColors.yellow600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TaskCount(
                  value: '05',
                  label: context.l10n.supervisorCompleted,
                  background: AppColors.primary50,
                  valueColor: AppColors.primary500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              key: const Key('supervisor-assign-task-button'),
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                context.l10n.supervisorAssignNewTask,
                style: AppTextStyles.boldH7_16.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCount extends StatelessWidget {
  const _TaskCount({
    required this.value,
    required this.label,
    required this.background,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color background;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.semiboldH5_24.copyWith(color: valueColor),
          ),
          Text(
            label,
            style: AppTextStyles.semiboldH9_14.copyWith(
              color: AppColors.neutral700,
            ),
          ),
        ],
      ),
    );
  }
}
