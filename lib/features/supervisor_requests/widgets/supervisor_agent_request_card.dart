import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:eerl_app/features/supervisor_requests/model/supervisor_agent_request.dart';
import 'package:eerl_app/features/supervisor_requests/widgets/supervisor_request_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SupervisorAgentRequestCard extends StatelessWidget {
  const SupervisorAgentRequestCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final SupervisorAgentRequest item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [HomeStyles.cardShadow],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: ValueKey('supervisor-agent-request-${item.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      SupervisorRequestAssets.agentPhoto,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.supervisorAgentRequestPerson,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.boldH8_14.copyWith(
                        color: AppColors.neutral950,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    SupervisorRequestAssets.openDetails,
                    key: const Key('supervisor-request-open-icon'),
                    width: 12,
                    height: 12,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.supervisorAgentRequestCardTitle,
                    style: AppTextStyles.semiboldH9_14.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.supervisorAgentRequestCardDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.mediumSH8_14.copyWith(
                      color: AppColors.neutral700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SvgPicture.asset(
                    SupervisorRequestAssets.attachment,
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      context.l10n.requestPhotoAttached,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.mediumSH8_14.copyWith(
                        color: AppColors.cool700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Flexible(child: _RequestStatusChip(status: item.status)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.supervisorAgentRequestTime,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: AppTextStyles.semiboldH10_12.copyWith(
                        color: AppColors.neutral400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _RequestStatusChip extends StatelessWidget {
  const _RequestStatusChip({required this.status});

  final SupervisorAgentRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final isResolved = status == SupervisorAgentRequestStatus.resolved;
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isResolved ? AppColors.primary50 : AppColors.yellow50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            isResolved
                ? SupervisorRequestAssets.resolved
                : SupervisorRequestAssets.pending,
            key: ValueKey(
              isResolved
                  ? 'supervisor-request-resolved-icon'
                  : 'supervisor-request-pending-icon',
            ),
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              isResolved
                  ? context.l10n.supervisorAgentRequestResolved
                  : context.l10n.supervisorAgentRequestPending,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.semiboldH10_12.copyWith(
                color: isResolved ? AppColors.primary500 : AppColors.yellow600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
