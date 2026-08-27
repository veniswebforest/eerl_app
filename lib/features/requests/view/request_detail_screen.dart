import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../model/request_list_item.dart';
import '../widgets/request_detail_section_card.dart';

class RequestDetailScreen extends StatelessWidget {
  const RequestDetailScreen({
    super.key,
    required this.status,
    required this.onBack,
  });

  final RequestListStatus status;
  final VoidCallback onBack;

  bool get _isClosed => status == RequestListStatus.closed;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    appBar: CustomAppBar(
      title: _isClosed
          ? context.l10n.requestCompletedDetailsTitle
          : context.l10n.requestDetailsTitle,
      onBackTap: onBack,
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
                const _ClosedRequestDetails()
              else
                const _OpenRequestDetails(),
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
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
  const _OpenRequestDetails();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      RequestDetailSectionCard(
        title: context.l10n.requestAssignTo,
        child: Text(
          context.l10n.requestSupervisorName,
          style: AppTextStyles.regularB8_12.copyWith(
            color: AppColors.neutral600,
          ),
        ),
      ),
      const SizedBox(height: 12),
      RequestDetailSectionCard(
        title: context.l10n.requestVerifyCollectionDetails,
        child: Text(
          context.l10n.requestDetailDescription,
          style: AppTextStyles.regularB8_12.copyWith(
            color: AppColors.neutral600,
          ),
        ),
      ),
      const SizedBox(height: 12),
      RequestDetailSectionCard(
        title: context.l10n.requestAttachmentByYou,
        child: SizedBox(
          height: 108,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              '•  ${context.l10n.requestSupervisorName.split(' (').first}',
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

class _ClosedRequestDetails extends StatelessWidget {
  const _ClosedRequestDetails();

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
        child: Column(crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.requestFilledDescription,
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
      const SizedBox(height: 20),
      Text(
        context.l10n.requestCompletionProof,
        style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral950),
      ),
      const SizedBox(height: 8),
      DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: const Radius.circular(8),
          color: AppColors.cool400,
          dashPattern: const [5, 4],
        ),
        child: SizedBox(
          height: 92,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/icons/wallet/expense_camera.svg',
                width: 24,
                height: 24,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.requestCapturePhoto,
                style: AppTextStyles.regularB7_14.copyWith(
                  color: AppColors.neutral400,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        context.l10n.requestPhotoSupport,
        style: AppTextStyles.regularB8_12.copyWith(color: AppColors.neutral600),
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
