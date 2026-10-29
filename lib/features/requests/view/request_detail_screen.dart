import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/utils/ist_date_time.dart';
import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/shared/widgets/app_image_preview_dialog.dart';
import 'package:eerl_app/shared/widgets/cached_app_image.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';

import '../widgets/request_detail_section_card.dart';

typedef RequestDetailLoader = Future<RequestModel?> Function(String requestId);
typedef RequestPhotoLoader = Future<List<String>> Function(String requestId);

class RequestDetailScreen extends StatefulWidget {
  const RequestDetailScreen({
    super.key,
    required this.request,
    this.detailLoader,
    this.answerPhotoLoader,
    this.requestPhotoLoader,
  });

  final RequestModel request;
  final RequestDetailLoader? detailLoader;
  final RequestPhotoLoader? answerPhotoLoader;
  final RequestPhotoLoader? requestPhotoLoader;

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  late Future<RequestModel?> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadRequest();
  }

  @override
  void didUpdateWidget(covariant RequestDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.request.id != widget.request.id ||
        oldWidget.detailLoader != widget.detailLoader) {
      _detailFuture = _loadRequest();
    }
  }

  Future<RequestModel?> _loadRequest() =>
      (widget.detailLoader ?? EerlLocalRepository.instance.getRequest)(
        widget.request.id,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const Key('agent-request-detail-screen'),
    backgroundColor: AppColors.backgroundColor,
    appBar: CustomAppBar(
      title: context.l10n.requestDetailsTitle,
      backIconAsset: 'assets/icons/records/back.svg',
      titleStyle: AppTextStyles.semiboldH6_20,
      backButtonRadius: 12,
    ),
    body: SafeArea(
      top: false,
      child: FutureBuilder<RequestModel?>(
        future: _detailFuture,
        initialData: widget.request,
        builder: (context, snapshot) {
          final request = snapshot.data ?? widget.request;
          final isClosed = _isClosed(request.status);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                key: const Key('request-detail-scroll'),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  _RequestDetailStatus(request: request, closed: isClosed),
                  const SizedBox(height: 24),
                  if (isClosed)
                    _ClosedRequestDetails(
                      request: request,
                      answerPhotoLoader:
                          widget.answerPhotoLoader ??
                          EerlLocalRepository
                              .instance
                              .getRequestAnswerPhotoSources,
                      requestPhotoLoader:
                          widget.requestPhotoLoader ??
                          EerlLocalRepository.instance.getRequestPhotoSources,
                    )
                  else
                    _OpenRequestDetails(
                      request: request,
                      requestPhotoLoader:
                          widget.requestPhotoLoader ??
                          EerlLocalRepository.instance.getRequestPhotoSources,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );

  bool _isClosed(String status) =>
      const {'ANSWERED', 'RESOLVED', 'CLOSED'}.contains(status.toUpperCase());
}

class _RequestDetailStatus extends StatelessWidget {
  const _RequestDetailStatus({required this.request, required this.closed});

  final RequestModel request;
  final bool closed;

  @override
  Widget build(BuildContext context) {
    final foreground = closed ? AppColors.primary500 : AppColors.yellow600;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [HomeStyles.cardShadow],
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: closed ? AppColors.primary50 : AppColors.yellow50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                closed
                    ? 'assets/icons/supervisor_requests/completed.svg'
                    : 'assets/icons/records/status_pending.svg',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  closed
                      ? _completedLabel(context, request.answeredAt)
                      : context.l10n.requestAwaitingResponse,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.semiboldH10_12.copyWith(
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _completedLabel(BuildContext context, String? value) {
    final parsed = value == null ? null : DateTime.tryParse(value);
    if (parsed == null) return context.l10n.requestCompletedLabel;
    final completed = IstDateTime.fromUtc(parsed);
    final now = IstDateTime.now();
    final time = DateFormat('hh:mm a').format(completed);
    final dateTime = DateUtils.isSameDay(completed, now)
        ? context.l10n.requestTodayTime(time)
        : DateFormat(
            'dd MMM yyyy, hh:mm a',
            Localizations.localeOf(context).toLanguageTag(),
          ).format(completed);
    return context.l10n.requestCompletedValue(dateTime);
  }
}

class _OpenRequestDetails extends StatelessWidget {
  const _OpenRequestDetails({
    required this.request,
    required this.requestPhotoLoader,
  });

  final RequestModel request;
  final RequestPhotoLoader requestPhotoLoader;

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
      FutureBuilder<List<String>>(
        future: requestPhotoLoader(request.id),
        initialData: request.photoUrls,
        builder: (context, snapshot) {
          final images = snapshot.data ?? const <String>[];
          if (images.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RequestDetailSectionCard(
              title: context.l10n.requestAttachmentByYou,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RequestPhotoGrid(images: images),
                  const SizedBox(height: 12),
                  _RequestAuthor(name: _agentName),
                ],
              ),
            ),
          );
        },
      ),
    ],
  );

  String get _supervisorName {
    final name = request.supervisorName?.trim();
    return name == null || name.isEmpty ? '—' : name;
  }

  String get _agentName {
    final name = request.createdByName?.trim();
    return name == null || name.isEmpty ? request.createdBy : name;
  }
}

class _ClosedRequestDetails extends StatelessWidget {
  const _ClosedRequestDetails({
    required this.request,
    required this.answerPhotoLoader,
    required this.requestPhotoLoader,
  });

  final RequestModel request;
  final RequestPhotoLoader answerPhotoLoader;
  final RequestPhotoLoader requestPhotoLoader;

  String get _agentName {
    final name = request.createdByName?.trim();
    return name == null || name.isEmpty ? request.createdBy : name;
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.requestResolveDetails,
        style: AppTextStyles.mediumSH7_16.copyWith(color: AppColors.neutral950),
      ),
      const SizedBox(height: 16),
      Text(
        context.l10n.requestDescriptionPlain,
        style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral950),
      ),
      const SizedBox(height: 8),
      _ResolvedDescription(value: request.answer),
      FutureBuilder<List<String>>(
        future: answerPhotoLoader(request.id),
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
                _RequestPhotoGrid(images: images),
                const SizedBox(height: 8),
                Text(
                  context.l10n.requestPhotoSupport,
                  style: AppTextStyles.regularB8_12.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      const SizedBox(height: 24),
      Text(
        context.l10n.requestCollectionAgentDetails,
        style: AppTextStyles.mediumSH7_16.copyWith(color: AppColors.neutral950),
      ),
      const SizedBox(height: 16),
      RequestDetailSectionCard(
        title: context.l10n.requestDescriptionPlain,
        titleStyle: AppTextStyles.semiboldH8_16,
        borderRadius: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.body,
              style: AppTextStyles.mediumSH8_14.copyWith(
                color: AppColors.neutral950,
              ),
            ),
            const SizedBox(height: 12),
            _RequestAuthor(name: _agentName),
          ],
        ),
      ),
      FutureBuilder<List<String>>(
        future: requestPhotoLoader(request.id),
        initialData: request.photoUrls,
        builder: (context, snapshot) {
          final images = snapshot.data ?? const <String>[];
          if (images.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: RequestDetailSectionCard(
              title: context.l10n.supervisorAgentRequestAttachment,
              titleStyle: AppTextStyles.semiboldH8_16,
              borderRadius: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RequestPhotoGrid(images: images),
                  const SizedBox(height: 12),
                  _RequestAuthor(name: _agentName),
                ],
              ),
            ),
          );
        },
      ),
    ],
  );
}

class _ResolvedDescription extends StatelessWidget {
  const _ResolvedDescription({required this.value});

  final String? value;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    constraints: const BoxConstraints(minHeight: 114),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cool100,
      border: Border.all(color: AppColors.cool400),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            value?.trim().isNotEmpty == true ? value!.trim() : '—',
            style: AppTextStyles.regularB7_14.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.requestDescriptionCounter,
          style: AppTextStyles.regularB8_12.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    ),
  );
}

class _RequestAuthor extends StatelessWidget {
  const _RequestAuthor({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) => Text(
    '•  $name',
    style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral700),
  );
}

class _RequestPhotoGrid extends StatelessWidget {
  const _RequestPhotoGrid({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = (constraints.maxWidth - 8) / 2;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (var index = 0; index < images.length; index++)
            SizedBox(
              key: ValueKey('request-detail-photo-$index'),
              width: width,
              height: 92,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Material(
                  color: AppColors.cool100,
                  child: InkWell(
                    key: ValueKey('preview-request-detail-photo-$index'),
                    onTap: () => AppImagePreviewDialog.showSource(
                      context,
                      images[index],
                    ),
                    child: CachedAppImage(
                      source: images[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}
