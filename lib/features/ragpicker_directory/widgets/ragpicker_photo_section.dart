import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/cached_app_image.dart';
import 'package:eerl_app/shared/widgets/app_required_text.dart';

class RagpickerPhotoSection extends StatelessWidget {
  const RagpickerPhotoSection({
    super.key,
    required this.label,
    required this.captureLabel,
    required this.helperText,
    this.photoSource,
    required this.onCapture,
    required this.onRemove,
  });

  final String label;
  final String captureLabel;
  final String helperText;
  final String? photoSource;
  final VoidCallback onCapture;
  final ValueChanged<int> onRemove;

  bool get hasPhoto => photoSource?.trim().isNotEmpty == true;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppRequiredText(label, style: AppTextStyles.mediumSH8_14),
      const SizedBox(height: 8),
      GestureDetector(
        key: const Key('ragpicker-photo-capture'),
        onTap: onCapture,
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            radius: const Radius.circular(10),
            color: hasPhoto ? AppColors.cool400 : AppColors.primary500,
            dashPattern: const [4, 4],
          ),
          child: Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: hasPhoto ? AppColors.cool100 : AppColors.primary50,
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
                    hasPhoto ? AppColors.cool400 : AppColors.primary500,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  captureLabel,
                  style:
                      (hasPhoto
                              ? AppTextStyles.mediumSH8_14
                              : AppTextStyles.semiboldH9_14)
                          .copyWith(
                            color: hasPhoto
                                ? AppColors.neutral400
                                : AppColors.neutral900,
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
      if (hasPhoto) ...[
        const SizedBox(height: 8),
        SizedBox(
          width: 150,
          child: _PhotoTile(path: photoSource!, onRemove: () => onRemove(0)),
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
  const _PhotoTile({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 143.5 / 92,
    child: Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: CachedAppImage(source: path, fit: BoxFit.cover),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
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
