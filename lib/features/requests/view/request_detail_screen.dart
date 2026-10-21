import 'package:flutter/material.dart';

import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/shared/widgets/cached_app_image.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../widgets/request_detail_section_card.dart';

class RequestDetailScreen extends StatelessWidget {
  const RequestDetailScreen({super.key, required this.request});

  final RequestModel request;

  bool get _isClosed => const {
    'ANSWERED',
    'RESOLVED',
    'CLOSED',
  }.contains(request.status.toUpperCase());

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    appBar: CustomAppBar(
      title: _isClosed
          ? context.l10n.requestCompletedDetailsTitle
          : context.l10n.requestDetailsTitle,
      backIconAsset: 'assets/icons/records/back.svg',
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            key: const Key('request-detail-scroll'),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _RequestDetailStatus(closed: _isClosed),
              const SizedBox(height: 20),
              if (_isClosed)
                _ClosedRequestDetails(request: request)
              else
                _OpenRequestDetails(request: request),
            ],
          ),
        ),
      ),
    ),
  );
}

class _RequestDetailStatus extends StatelessWidget {
  const _RequestDetailStatus({required this.closed});

  final bool closed;

  @override
  Widget build(BuildContext context) {
    final foreground = closed ? AppColors.primary500 : AppColors.yellow600;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [HomeStyles.cardShadow],
      ),
      child: Row(
        children: [
          closed
              ? SvgPicture.asset(
                  'assets/icons/wallet/status_verified.svg',
                  width: 20,
                  height: 20,
                )
              : SvgPicture.asset(
                  'assets/icons/records/status_pending.svg',
                  width: 20,
                  height: 20,
                ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              closed
                  ? context.l10n.requestCompletedStatus
                  : context.l10n.requestAwaitingResponse,
              style: AppTextStyles.mediumSH9_12.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenRequestDetails extends StatelessWidget {
  const _OpenRequestDetails({required this.request});
  final RequestModel request;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      RequestDetailSectionCard(
        title: context.l10n.requestAssignTo,
        child: Text(
          _supervisorName,
          style: AppTextStyles.regularB8_12.copyWith(
            color: AppColors.neutral600,
          ),
        ),
      ),
      const SizedBox(height: 12),
      RequestDetailSectionCard(
        title: context.l10n.requestVerifyCollectionDetails,
        child: Text(
          request.body,
          style: AppTextStyles.regularB8_12.copyWith(
            color: AppColors.neutral600,
          ),
        ),
      ),
      const SizedBox(height: 12),
      RequestDetailSectionCard(
        title: context.l10n.requestAttachmentByYou,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (request.photoUrls.isNotEmpty) ...[
              _RequestPhotoGrid(images: request.photoUrls),
              const SizedBox(height: 12),
            ],
            Text(
              '•  ${request.createdByName ?? request.createdBy}',
              style: AppTextStyles.regularB8_12.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  String get _supervisorName {
    final name = request.supervisorName?.trim();
    return name == null || name.isEmpty ? '-' : name;
  }
}

class _RequestPhotoGrid extends StatelessWidget {
  const _RequestPhotoGrid({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: [
      for (var index = 0; index < images.length; index++)
        SizedBox(
          key: ValueKey('request-detail-photo-$index'),
          width: 143.5,
          height: 92,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedAppImage(source: images[index], fit: BoxFit.cover),
          ),
        ),
    ],
  );
}

class _ClosedRequestDetails extends StatelessWidget {
  const _ClosedRequestDetails({required this.request});
  final RequestModel request;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.requestResolveDetails,
        style: AppTextStyles.mediumSH7_16.copyWith(color: AppColors.neutral950),
      ),
      const SizedBox(height: 12),
      Text(
        context.l10n.requestDescriptionPlain,
        style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral950),
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 120),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cool400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              request.answer ?? request.body,
              style: AppTextStyles.regularB7_14,
            ),
            Text(
              "Max 150 Characters",
              style: AppTextStyles.regularB8_12.copyWith(
                color: AppColors.cool400,
              ),
            ),
          ],
        ),
      ),
      FutureBuilder<List<String>>(
        future: EerlLocalRepository.instance.getRequestAnswerPhotoSources(
          request.id,
        ),
        initialData: request.answerPhotoUrls,
        builder: (context, snapshot) {
          final images = snapshot.data ?? const <String>[];
          if (images.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 20),
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
                _RequestPhotoGrid(images: images),
              ],
            ),
          );
        },
      ),
      const SizedBox(height: 24),
      Text(
        context.l10n.requestCollectionAgentDetails,
        style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral950),
      ),
      const SizedBox(height: 12),
      RequestDetailSectionCard(
        title: context.l10n.requestDescriptionPlain,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.requestDetailDescription,
              style: AppTextStyles.regularB8_12.copyWith(
                color: AppColors.neutral950,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '•  ${context.l10n.requestAgentName}',
              style: AppTextStyles.regularB8_12.copyWith(
                color: AppColors.neutral700,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      RequestDetailSectionCard(
        title: context.l10n.requestAttachmentFromSupervisor,
        child: SizedBox(
          height: 96,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              '•  ${context.l10n.requestAgentName}',
              style: AppTextStyles.regularB8_12.copyWith(
                color: AppColors.neutral600,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
