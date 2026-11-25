import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';

/// Pill tag with an optional leading icon.
enum ModuleTagTone { blue, pink, yellow, red, green, grey }

class ModuleTag extends StatelessWidget {
  const ModuleTag({
    super.key,
    required this.label,
    required this.tone,
    this.iconAsset,
  });

  final String label;
  final ModuleTagTone tone;
  final String? iconAsset;

  (Color, Color) get _colors => switch (tone) {
    ModuleTagTone.blue => (DriverColors.secondary100, DriverColors.blue600),
    ModuleTagTone.pink => (DriverColors.pink100, DriverColors.pink600),
    ModuleTagTone.yellow => (DriverColors.yellow50, DriverColors.yellow700),
    ModuleTagTone.red => (DriverColors.red100, DriverColors.red600),
    ModuleTagTone.green => (DriverColors.primary50, DriverColors.primary500),
    ModuleTagTone.grey => (DriverColors.tagGrey, DriverColors.pdfMuted),
  };

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconAsset != null) ...[
            SvgPicture.asset(
              iconAsset!,
              package: 'pickup_supervisor',
              width: 14,
              height: 14,
            ),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: DriverTextStyles.semibold12.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
