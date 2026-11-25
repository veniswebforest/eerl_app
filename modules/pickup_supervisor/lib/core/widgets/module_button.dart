import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';

enum ModuleButtonVariant { primary, outline, danger, neutral }

/// Full-width action button used by cards, sheets and popups.
///
/// * primary – green filled, white bold text
/// * outline – white with a green border and green bold text
/// * danger – red filled, white bold text
/// * neutral – light grey filled, dark semibold text (Cancel / Back to home)
class ModuleButton extends StatelessWidget {
  const ModuleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ModuleButtonVariant.primary,
    this.height = 48,
    this.radius = 12,
    this.semibold = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final ModuleButtonVariant variant;
  final double height;
  final double radius;

  /// Use the semibold 16 style instead of bold 16.
  final bool semibold;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, border) = switch (variant) {
      ModuleButtonVariant.primary => (
        DriverColors.primary500,
        DriverColors.neutral50,
        null,
      ),
      ModuleButtonVariant.outline => (
        DriverColors.neutral50,
        DriverColors.primary500,
        DriverColors.primary500,
      ),
      ModuleButtonVariant.danger => (
        DriverColors.red600,
        DriverColors.neutral50,
        null,
      ),
      ModuleButtonVariant.neutral => (
        DriverColors.cool200,
        DriverColors.neutral950,
        null,
      ),
    };
    final weightSemibold = semibold || variant == ModuleButtonVariant.neutral;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: border == null ? BorderSide.none : BorderSide(color: border),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              (weightSemibold
                      ? DriverTextStyles.semibold16
                      : DriverTextStyles.bold16)
                  .copyWith(color: foreground, height: 20 / 16),
        ),
      ),
    );
  }
}
