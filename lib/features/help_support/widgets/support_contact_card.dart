import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class SupportContactCard extends StatelessWidget {
  const SupportContactCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.externalIcon,
    required this.accentColor,
    required this.iconBackgroundColor,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String icon;
  final String externalIcon;
  final Color accentColor;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.neutral50,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: accentColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(icon, width: 24, height: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.semiboldH8_16.copyWith(
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.semiboldH9_14.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              SvgPicture.asset(externalIcon, width: 12, height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
