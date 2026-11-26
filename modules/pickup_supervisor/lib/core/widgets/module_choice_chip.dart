import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';

const _check = 'assets/icons/route_actions/check_green.svg';

/// Rounded choice pill: green with a tick when selected, outlined otherwise
/// (Reason, Why?, What do you need?).
class ModuleChoiceChip extends StatelessWidget {
  const ModuleChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// 13px text and 12px side padding (Ask the Collection Head).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final base = selected
        ? DriverTextStyles.semibold14
        : DriverTextStyles.medium14;
    return Material(
      color: selected ? DriverColors.primary50 : DriverColors.neutral50,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? DriverColors.primary500 : DriverColors.cool400,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 14,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                SvgPicture.asset(
                  _check,
                  package: 'pickup_supervisor',
                  width: 14,
                  height: 14,
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  style: base.copyWith(
                    fontSize: compact ? 13 : 14,
                    color: selected
                        ? DriverColors.primary500
                        : DriverColors.neutral900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A wrap of [ModuleChoiceChip]s, 8px apart.
class ModuleChoiceWrap<T> extends StatelessWidget {
  const ModuleChoiceWrap({
    super.key,
    required this.values,
    required this.labelOf,
    required this.isSelected,
    required this.onTap,
    this.keyPrefix = 'choice',
    this.compact = false,
  });

  final List<T> values;
  final String Function(T) labelOf;
  final bool Function(T) isSelected;
  final ValueChanged<T> onTap;
  final String keyPrefix;
  final bool compact;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final v in values)
        ModuleChoiceChip(
          key: Key('$keyPrefix-${v is Enum ? v.name : v}'),
          label: labelOf(v),
          selected: isSelected(v),
          compact: compact,
          onTap: () => onTap(v),
        ),
    ],
  );
}
