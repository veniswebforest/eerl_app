import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';

/// Amber note with an info icon ("Only this trip changes…").
class ModuleInfoNote extends StatelessWidget {
  const ModuleInfoNote({
    super.key,
    required this.message,
    this.title,
    this.icon = 'assets/icons/trips_plan/info.svg',
    this.blue = false,
  });

  /// Blue, borderless variant (Request cash, Pay a pickup point).
  const ModuleInfoNote.blue({super.key, required this.message})
    : title = null,
      icon = 'assets/icons/cash_payments/info_blue.svg',
      blue = true;

  final bool blue;

  final String message;

  /// Bold first line ("Changed for today").
  final String? title;
  final String icon;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: blue
        ? const EdgeInsets.all(8)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: blue ? DriverColors.secondary100 : DriverColors.infoBannerBg,
      borderRadius: BorderRadius.circular(blue ? 12 : 10),
      border: blue ? null : Border.all(color: DriverColors.infoBannerBorder),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          icon,
          package: 'pickup_supervisor',
          width: 20,
          height: 20,
        ),
        SizedBox(width: blue ? 6 : 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(
                  title!,
                  style: DriverTextStyles.semibold14.copyWith(
                    color: DriverColors.amber800,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                message,
                style: blue
                    ? DriverTextStyles.semibold12.copyWith(
                        color: DriverColors.secondary500,
                      )
                    : DriverTextStyles.medium12.copyWith(
                        color: DriverColors.infoBannerText,
                      ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
