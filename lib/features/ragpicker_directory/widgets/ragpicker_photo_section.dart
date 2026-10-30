import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/cached_app_image.dart';
import 'package:eerl_app/shared/widgets/app_required_text.dart';
import 'package:eerl_app/shared/widgets/app_image_preview_dialog.dart';

class RagpickerPhotoSection extends StatelessWidget {
  const RagpickerPhotoSection({
    super.key,
    required this.label,
    required this.captureLabel,
    required this.helperText,
    this.photoSource,
    this.photoSources = const <String>[],
    required this.onCapture,
    required this.onRemove,
  });

  final String label;
  final String captureLabel;
  final String helperText;
  final String? photoSource;
  final List<String> photoSources;
  final VoidCallback onCapture;
  final ValueChanged<int> onRemove;

  List<String> get effectivePhotoSources {
    if (photoSources.isNotEmpty) return photoSources;
    if (photoSource?.trim().isNotEmpty == true) return [photoSource!];
    return const <String>[];
  }

  bool get canCapture => effectivePhotoSources.length < 2;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppRequiredText(label, style: AppTextStyles.mediumSH8_14),
      const SizedBox(height: 8),
      GestureDetector(
        key: const Key('ragpicker-photo-capture'),
        onTap: canCapture ? onCapture : null,
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            radius: const Radius.circular(10),
            color: canCapture ? AppColors.primary500 : AppColors.cool400,
            dashPattern: const [4, 4],
          ),
          child: Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: canCapture ? AppColors.primary50 : AppColors.cool100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/ragpicker_camera.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    canCapture ? AppColors.primary500 : AppColors.cool400,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  captureLabel,
                  style:
                      (canCapture
                              ? AppTextStyles.semiboldH9_14
                              : AppTextStyles.mediumSH8_14)
                          .copyWith(
                            color: canCapture
                                ? AppColors.neutral900
                                : AppColors.neutral400,
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
      if (effectivePhotoSources.isNotEmpty) ...[
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var index = 0; index < effectivePhotoSources.length; index++)
              SizedBox(
                width: 143.5,
                child: _PhotoTile(
                  key: ValueKey('ragpicker-photo-$index'),
                  removeKey: ValueKey('ragpicker-photo-remove-$index'),
                  path: effectivePhotoSources[index],
                  onRemove: () => onRemove(index),
                ),
              ),
          ],
        ),
      ],
      const SizedBox(height: 8),
      Text(
        helperText,
        style: AppTextStyles.regularB8_12.copyWith(color: AppColors.neutral600),
      ),
    ],
  );
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    super.key,
    required this.path,
    required this.onRemove,
    this.removeKey,
  });

  final String path;
  final VoidCallback onRemove;
  final Key? removeKey;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 143.5 / 92,
    child: Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Material(
            color: AppColors.cool100,
            child: InkWell(
              key: const Key('preview-ragpicker-photo'),
              onTap: () => AppImagePreviewDialog.showSource(context, path),
              child: CachedAppImage(source: path, fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              key: removeKey,
              onTap: onRemove,
              borderRadius: BorderRadius.circular(4),
              child: const SizedBox(
                width: 24,
                height: 24,
                child: Icon(Icons.close, size: 20, color: AppColors.neutral950),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
