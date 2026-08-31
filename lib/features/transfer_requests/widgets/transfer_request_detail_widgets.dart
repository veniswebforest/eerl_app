import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';

class TransferDetailCard extends StatelessWidget {
  const TransferDetailCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding ?? const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 7,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}

class TransferDetailRow extends StatelessWidget {
  const TransferDetailRow({
    super.key,
    required this.label,
    required this.values,
    this.valueColor,
    this.showDivider = true,
  });

  final String label;
  final List<String> values;
  final Color? valueColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyles.semiboldH9_14.copyWith(
          color: AppColors.neutral950,
        ),
      ),
      const SizedBox(height: 7),
      ...values.map(
        (value) => Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•', style: AppTextStyles.regularB8_12),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.regularB7_14.copyWith(
                    color: valueColor ?? AppColors.neutral950,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      if (showDivider) ...[
        const SizedBox(height: 6),
        const Divider(height: 1, color: AppColors.cool400),
        const SizedBox(height: 12),
      ],
    ],
  );
}

class TransferStatusChip extends StatelessWidget {
  const TransferStatusChip({
    super.key,
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
  });

  final String label;
  final Color color;
  final Color background;
  final String icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          icon,
          width: 16,
          height: 16,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.mediumSH9_12.copyWith(color: color),
          ),
        ),
      ],
    ),
  );
}

class TransferTimelineStep extends StatelessWidget {
  const TransferTimelineStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconAsset,
    this.showLine = true,
  });

  final String title;
  final String subtitle;
  final Color color;
  final String iconAsset;
  final bool showLine;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SvgPicture.asset(
                    iconAsset,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  ),
                ),
              ),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 1.5,
                    height: 30,
                    color: color,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.semiboldH9_14.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTextStyles.regularB8_12.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
