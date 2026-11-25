import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';

/// Full-width red action button (52px, radius 12) pinned at the page bottom.
class ModuleDangerButton extends StatelessWidget {
  const ModuleDangerButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;

  /// A null callback renders the disabled state.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: DriverColors.red500,
          foregroundColor: DriverColors.neutral50,
          disabledBackgroundColor: DriverColors.red200,
          disabledForegroundColor: DriverColors.neutral50,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: DriverTextStyles.bold16,
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
