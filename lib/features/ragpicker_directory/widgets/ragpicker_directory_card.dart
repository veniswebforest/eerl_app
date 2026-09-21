import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/ragpicker_directory_item.dart';

class RagpickerDirectoryCard extends StatelessWidget {
  const RagpickerDirectoryCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final RagpickerDirectoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(16),
    elevation: 0,
    shadowColor: Colors.black.withValues(alpha: .12),
    child: InkWell(
      key: ValueKey('ragpicker-${item.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(minHeight: 98),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.semiboldH7_18.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: item.status == RagpickerStatus.active
                            ? AppColors.primary100
                            : AppColors.red50,
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        item.status == RagpickerStatus.active
                            ? 'assets/icons/help_support/call.svg'
                            : 'assets/icons/ragpicker_deactivated.svg',
                        colorFilter: ColorFilter.mode(
                          item.status == RagpickerStatus.active
                              ? AppColors.primary800
                              : AppColors.red500,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        item.phone,
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.neutral700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: SvgPicture.asset(
                'assets/icons/profile/arrow_right.svg',
                width: 14,
                height: 14,
                colorFilter: const ColorFilter.mode(
                  AppColors.cool400,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
