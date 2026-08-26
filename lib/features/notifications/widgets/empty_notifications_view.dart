import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class EmptyNotificationsView extends StatelessWidget {
  const EmptyNotificationsView({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 150,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 8,
                  child: Container(
                    width: 92,
                    height: 136,
                    decoration: BoxDecoration(
                      color: AppColors.cool100,
                      border: Border.all(color: AppColors.cool300, width: 5),
                    ),
                  ),
                ),
                Positioned(
                  top: 26,
                  child: Container(
                    width: 66,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.primary300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Positioned(
                  top: 52,
                  child: Container(
                    width: 74,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.primary500,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Color(0x24000000), blurRadius: 8),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      'assets/icons/home/notification.svg',
                      width: 58,
                      height: 58,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.boldH6_20.copyWith(
              color: AppColors.neutral950,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.regularB7_14.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    ),
  );
}
