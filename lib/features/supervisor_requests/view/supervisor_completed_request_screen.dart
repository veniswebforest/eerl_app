import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/supervisor_requests/widgets/supervisor_request_detail_widgets.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_header.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:flutter/material.dart';

class SupervisorCompletedRequestScreen extends StatelessWidget {
  const SupervisorCompletedRequestScreen({super.key, required this.request});

  final RequestModel request;

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const Key('supervisor-completed-request-screen'),
    backgroundColor: AppColors.backgroundColor,
    appBar: SupervisorTaskHeader(
      title: context.l10n.requestDetailsTitle,
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              SupervisorRequestStatusCard(
                completed: true,
                time: request.answeredAt,
              ),
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
                value: request.answer?.trim().isNotEmpty == true
                    ? request.answer!.trim()
                    : '—',
              ),
              FutureBuilder<List<String>>(
                future: EerlLocalRepository.instance
                    .getRequestAnswerPhotoSources(request.id),
                initialData: request.answerPhotoUrls,
                builder: (context, snapshot) {
                  final images = snapshot.data ?? const <String>[];
                  if (images.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.requestCompletionProof,
                          style: AppTextStyles.mediumSH8_14.copyWith(
                            color: AppColors.neutral950,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SupervisorRequestPhotoPair(images: images),
                      ],
                    ),
                  );
                },
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
                value: request.body,
                caption: request.createdByName ?? request.createdBy,
                muted: true,
              ),
              FutureBuilder<List<String>>(
                future: EerlLocalRepository.instance.getRequestPhotoSources(
                  request.id,
                ),
                initialData: request.photoUrls,
                builder: (context, snapshot) {
                  final images = snapshot.data ?? const <String>[];
                  if (images.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SupervisorRequestInfoCard(
                      title: context.l10n.supervisorAgentRequestAttachment,
                      images: images,
                      caption: request.createdByName ?? request.createdBy,
                      muted: true,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
