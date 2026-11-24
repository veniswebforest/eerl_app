import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/driver_labour/widgets/driver_labour_assets.dart';

const driverLabourCardShadow = BoxShadow(
  color: Color(0x1F000000),
  blurRadius: 4,
  offset: Offset(0, 2),
);

/// Text field decoration with every border removed. The surrounding container
/// draws the one Figma border; the app theme's input borders must not show a
/// second one (enabled/focused borders win over `border`, so clear them all).
InputDecoration driverLabourBareInputDecoration({
  required String hint,
  required Color hintColor,
}) {
  return InputDecoration(
    isCollapsed: true,
    isDense: true,
    filled: false,
    contentPadding: EdgeInsets.zero,
    hintText: hint,
    hintStyle: DriverTextStyles.regular14.copyWith(color: hintColor),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    focusedErrorBorder: InputBorder.none,
  );
}

/// Active / Inactive dropdown shown in the directory header.
class DriverLabourFilterDropdown extends StatelessWidget {
  const DriverLabourFilterDropdown({
    super.key,
    required this.activeLabel,
    required this.inactiveLabel,
    required this.showActive,
    required this.onChanged,
  });

  final String activeLabel;
  final String inactiveLabel;
  final bool showActive;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<bool>(
      key: const Key('driver-labour-filter'),
      onSelected: onChanged,
      color: DriverColors.neutral50,
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: true,
          child: Text(activeLabel, style: DriverTextStyles.semibold14),
        ),
        PopupMenuItem(
          value: false,
          child: Text(inactiveLabel, style: DriverTextStyles.semibold14),
        ),
      ],
      child: Container(
        constraints: const BoxConstraints(minWidth: 112),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: DriverColors.neutral50,
          border: Border.all(color: DriverColors.cool400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              showActive ? activeLabel : inactiveLabel,
              style: DriverTextStyles.semibold14.copyWith(
                color: DriverColors.primary800,
              ),
            ),
            const SizedBox(width: 16),
            RotatedBox(
              quarterTurns: 1,
              child: SvgPicture.asset(
                DriverLabourAssets.chevronRight,
                package: DriverLabourAssets.package,
                width: 18,
                height: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full width secondary (grey) button, e.g. Cancel.
class DriverLabourSecondaryButton extends StatelessWidget {
  const DriverLabourSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: DriverColors.cool200,
          foregroundColor: DriverColors.neutral950,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: DriverTextStyles.medium16,
        ),
        child: Text(label),
      ),
    );
  }
}

/// Outlined destructive button (Deactivate).
class DriverLabourDangerOutlineButton extends StatelessWidget {
  const DriverLabourDangerOutlineButton({
    super.key,
    required this.label,
    required this.iconAsset,
    required this.onPressed,
  });

  final String label;
  final String iconAsset;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: DriverColors.neutral50,
          foregroundColor: DriverColors.red600,
          side: const BorderSide(color: DriverColors.red600),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: DriverTextStyles.bold16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              iconAsset,
              package: DriverLabourAssets.package,
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

/// The profile photo with the exact Figma crop (zoomed 132% × 146%, shifted
/// left 16% / up 14%). The caller clips it to its rounded tile.
class DriverLabourProfilePhoto extends StatelessWidget {
  const DriverLabourProfilePhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return ClipRect(
          child: Stack(
            children: [
              Positioned(
                left: -0.1618 * w,
                top: -0.1432 * h,
                width: 1.3235 * w,
                height: 1.4571 * h,
                child: Image.asset(
                  DriverLabourAssets.profilePhoto,
                  package: DriverLabourAssets.package,
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
