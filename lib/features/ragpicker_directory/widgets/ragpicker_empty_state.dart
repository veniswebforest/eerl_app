import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class RagpickerEmptyState extends StatelessWidget {
  const RagpickerEmptyState({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: 0.3,
          child: SizedBox(
            key: const Key('ragpicker-empty-illustration'),
            width: 174,
            height: 170,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0.23,
                  top: 0,
                  width: 94.25,
                  height: 170,
                  child: SvgPicture.asset(
                    'assets/images/ragpicker_directory/empty_person.svg',
                  ),
                ),
                Positioned(
                  left: 101,
                  top: 59.5,
                  width: 73.21,
                  height: 110.5,
                  child: SvgPicture.asset(
                    'assets/images/ragpicker_directory/empty_bin.svg',
                  ),
                ),
                Positioned(
                  left: 72.8,
                  top: 142.8,
                  width: 57.61,
                  height: 27.2,
                  child: SvgPicture.asset(
                    'assets/images/ragpicker_directory/empty_ground.svg',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          message,
          key: const Key('ragpicker-empty-message'),
          textAlign: TextAlign.center,
          style: AppTextStyles.semiboldH8_16.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    ),
  );
}
