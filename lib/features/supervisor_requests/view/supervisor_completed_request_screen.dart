import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/supervisor_requests/widgets/supervisor_request_assets.dart';
import 'package:eerl_app/features/supervisor_requests/widgets/supervisor_request_detail_widgets.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_header.dart';
import 'package:flutter/material.dart';

class SupervisorCompletedRequestScreen extends StatelessWidget {
  const SupervisorCompletedRequestScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const Key('supervisor-completed-request-screen'),
    backgroundColor: AppColors.backgroundColor,
    appBar: SupervisorTaskHeader(
      title: context.l10n.supervisorTaskDetailsTitle,
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              const SupervisorRequestStatusCard(completed: true),
              const SizedBox(height: 24),
              Text(
                context.l10n.supervisorAgentRequestResolveDetails,
                style: AppTextStyles.mediumSH7_16.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.requestDescriptionPlain,
                style: AppTextStyles.mediumSH8_14.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
              const SizedBox(height: 8),
              SupervisorRequestReadOnlyDescription(
                value: context.l10n.requestFilledDescription,
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.requestCompletionProof,
                style: AppTextStyles.mediumSH8_14.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
              const SizedBox(height: 8),
              const SupervisorRequestCaptureBox(active: false),
              const SizedBox(height: 8),
              const SupervisorRequestPhotoPair(
                images: [
                  SupervisorRequestAssets.resolutionProof,
                  SupervisorRequestAssets.resolutionProof,
                ],
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.requestPhotoSupport,
                style: AppTextStyles.regularB8_12.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.supervisorAgentRequestCollectionAgentDetails,
                style: AppTextStyles.mediumSH7_16.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
              const SizedBox(height: 16),
              SupervisorRequestInfoCard(
                title: context.l10n.requestDescriptionPlain,
                value: context.l10n.supervisorAgentRequestLongDescription,
                caption: context.l10n.requestAgentName,
                muted: true,
              ),
              const SizedBox(height: 16),
              SupervisorRequestInfoCard(
                title:
                    context.l10n.supervisorAgentRequestAttachmentFromSupervisor,
                images: const [
                  SupervisorRequestAssets.collectionAttachment,
                  SupervisorRequestAssets.collectionAttachment,
                ],
                caption: context.l10n.requestAgentName,
                muted: true,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
