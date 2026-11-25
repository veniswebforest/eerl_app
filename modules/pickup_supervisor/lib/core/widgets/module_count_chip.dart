import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';

/// Pill with a semibold label and a bold count ("To approve 2",
/// "Missed 4"). Selected: green with white text; otherwise white with a
/// grey border and a muted count.
class ModuleCountChip extends StatelessWidget {
  const ModuleCountChip({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.horizontalPadding = 12,
  });

  final String label;
  final String count;
  final bool selected;
  final VoidCallback onTap;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? DriverColors.primary500 : DriverColors.neutral50,
      shape: StadiumBorder(
        side: selected
            ? BorderSide.none
            : const BorderSide(color: DriverColors.border),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: DriverTextStyles.semibold12.copyWith(
                  color: selected
                      ? DriverColors.neutral50
                      : DriverColors.neutral900,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                count,
                style: DriverTextStyles.bold12.copyWith(
                  color: selected
                      ? DriverColors.neutral50
                      : DriverColors.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
