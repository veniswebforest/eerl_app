import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/supervisor_requests/widgets/supervisor_request_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class SupervisorRequestStatusCard extends StatelessWidget {
  const SupervisorRequestStatusCard({super.key, required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1F000000),
          offset: Offset(0, 2),
          blurRadius: 8,
        ),
      ],
    ),
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: completed ? AppColors.primary50 : AppColors.yellow50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              completed
                  ? SupervisorRequestAssets.completed
                  : SupervisorRequestAssets.awaiting,
              key: ValueKey(
                completed
                    ? 'supervisor-request-completed-icon'
                    : 'supervisor-request-awaiting-icon',
              ),
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                completed
                    ? context.l10n.requestCompletedStatus
                    : context.l10n.requestAwaitingResponse,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.semiboldH10_12.copyWith(
                  color: completed ? AppColors.primary500 : AppColors.yellow600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class SupervisorRequestInfoCard extends StatelessWidget {
  const SupervisorRequestInfoCard({
    super.key,
    required this.title,
    this.value,
    this.images = const <String>[],
    this.caption,
    this.muted = false,
  });

  final String title;
  final String? value;
  final List<String> images;
  final String? caption;
  final bool muted;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: muted ? AppColors.cool200 : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: muted
          ? null
          : const [
              BoxShadow(
                color: Color(0x1F000000),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.semiboldH8_16.copyWith(
            color: AppColors.neutral950,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 1,
          child: SvgPicture.asset(
            SupervisorRequestAssets.divider,
            fit: BoxFit.fill,
          ),
        ),
        if (value != null) ...[
          const SizedBox(height: 12),
          Text(
            value!,
            style: AppTextStyles.mediumSH8_14.copyWith(
              color: AppColors.neutral950,
            ),
          ),
        ],
        if (images.isNotEmpty) ...[
          const SizedBox(height: 12),
          SupervisorRequestPhotoPair(images: images),
        ],
        if (caption != null) ...[
          const SizedBox(height: 12),
          _BulletText(text: caption!),
        ],
      ],
    ),
  );
}

class SupervisorRequestPhotoPair extends StatelessWidget {
  const SupervisorRequestPhotoPair({
    super.key,
    this.images = const <String>[],
    this.filePhotos = const <XFile>[],
    this.onRemove,
  });

  final List<String> images;
  final List<XFile> filePhotos;
  final ValueChanged<int>? onRemove;

  int get _itemCount =>
      filePhotos.isNotEmpty ? filePhotos.length : images.length;

  @override
  Widget build(BuildContext context) {
    final count = _itemCount;
    return Row(
      children: List.generate(count, (index) {
        final isFile = filePhotos.isNotEmpty;
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              end: index == count - 1 ? 0 : 8,
            ),
            child: AspectRatio(
              aspectRatio: 143.5 / 92,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (isFile)
                      Image.file(
                        File(filePhotos[index].path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Image.asset(
                          SupervisorRequestAssets.resolutionProof,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Image.asset(images[index], fit: BoxFit.cover),
                    if (onRemove != null)
                      PositionedDirectional(
                        top: 8,
                        end: 8,
                        child: InkWell(
                          key: ValueKey(
                            'remove-supervisor-request-photo-$index',
                          ),
                          onTap: () => onRemove!(index),
                          child: SvgPicture.asset(
                            SupervisorRequestAssets.remove,
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class SupervisorRequestCaptureBox extends StatelessWidget {
  const SupervisorRequestCaptureBox({
    super.key,
    required this.active,
    this.onTap,
  });

  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => DottedBorder(
    options: RoundedRectDottedBorderOptions(
      radius: const Radius.circular(8),
      color: active ? AppColors.primary500 : AppColors.cool400,
      dashPattern: const [5, 4],
    ),
    child: Material(
      color: active ? AppColors.primary50 : AppColors.cool100,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        key: const Key('supervisor-request-capture-photo'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 80,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                SupervisorRequestAssets.camera,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  active ? AppColors.primary500 : AppColors.cool400,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.requestCapturePhoto,
                style:
                    (active
                            ? AppTextStyles.semiboldH9_14
                            : AppTextStyles.mediumSH8_14)
                        .copyWith(
                          color: active
                              ? AppColors.neutral900
                              : AppColors.neutral400,
                        ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class SupervisorRequestReadOnlyDescription extends StatelessWidget {
  const SupervisorRequestReadOnlyDescription({super.key, required this.value});

  final String value;

  @override
  Widget build(BuildContext context) => Container(
    height: 133,
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cool100,
      border: Border.all(color: AppColors.cool400),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.regularB7_14.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            context.l10n.requestDescriptionCounter,
            style: AppTextStyles.regularB8_12.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ),
      ],
    ),
  );
}

class _BulletText extends StatelessWidget {
  const _BulletText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 7),
        child: Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AppColors.neutral700,
            shape: BoxShape.circle,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: AppTextStyles.mediumSH8_14.copyWith(
            color: AppColors.neutral700,
          ),
        ),
      ),
    ],
  );
}
