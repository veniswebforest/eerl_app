import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';

const _package = 'pickup_supervisor';
const _radioOn = 'assets/icons/driver/location_flow/radio_selected.svg';
const _radioOff = 'assets/icons/driver/location_flow/radio.svg';
const _checkWhite = 'assets/icons/route_actions/check_white.svg';

/// Bordered option with a radio, a title, an optional subtitle and an
/// optional trailing tag. Selected options are tinted green; [dimmed] ones
/// (busy people) are greyed but still tappable.
class ModuleRadioCard extends StatelessWidget {
  const ModuleRadioCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.dimmed = false,
    this.large = false,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool selected;
  final bool dimmed;

  /// 16px title and 14px padding (sheets) instead of 14px / 12px (forms).
  final bool large;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titleColor = dimmed
        ? DriverColors.neutral400
        : DriverColors.neutral950;
    final subColor = dimmed ? DriverColors.neutral400 : DriverColors.neutral600;
    return Material(
      color: selected ? DriverColors.primary50 : DriverColors.neutral50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected
              ? DriverColors.primary500
              : DriverColors.stopInactiveBorder,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(large ? 14 : 12),
          child: Row(
            children: [
              Opacity(
                opacity: dimmed && !selected ? .6 : 1,
                child: SvgPicture.asset(
                  selected ? _radioOn : _radioOff,
                  package: _package,
                  width: 20,
                  height: 20,
                ),
              ),
              SizedBox(width: large ? 12 : 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          (large
                                  ? DriverTextStyles.semibold16
                                  : DriverTextStyles.semibold14)
                              .copyWith(color: titleColor),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: DriverTextStyles.medium12.copyWith(
                          color: subColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 10), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

/// 20px square checkbox: green with a white tick, or outlined.
class ModuleCheckBox extends StatelessWidget {
  const ModuleCheckBox({super.key, required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) => Container(
    width: 20,
    height: 20,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: checked ? DriverColors.primary500 : DriverColors.neutral50,
      borderRadius: BorderRadius.circular(4),
      border: checked ? null : Border.all(color: DriverColors.neutral400),
    ),
    child: checked
        ? SvgPicture.asset(
            _checkWhite,
            package: _package,
            width: 14,
            height: 14,
          )
        : null,
  );
}

/// Bordered row with a checkbox and a label (Stops to move).
class ModuleCheckRow extends StatelessWidget {
  const ModuleCheckRow({
    super.key,
    required this.label,
    required this.checked,
    required this.onTap,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: DriverColors.neutral50,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(color: DriverColors.stopInactiveBorder),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ModuleCheckBox(checked: checked),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: DriverTextStyles.medium14.copyWith(
                  color: DriverColors.neutral950,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
