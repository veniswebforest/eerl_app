import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

abstract final class StopDetailAssets {
  static const package = 'pickup_supervisor';
  static const _i = 'assets/icons/stop_detail';

  static const maps = '$_i/maps.svg';
  static const call = '$_i/call.svg';
  static const pending = '$_i/status_pending.svg';
  static const next = '$_i/status_next.svg';
  static const collected = '$_i/status_collected.svg';
  static const skipSource = '$_i/skip_source.svg';
  static const check = '$_i/check.svg';
}

Widget stopDetailIcon(String asset, double size) => SvgPicture.asset(
  asset,
  package: StopDetailAssets.package,
  width: size,
  height: size,
);

/// Thin divider between sections of the stop detail card.
class StopDetailDivider extends StatelessWidget {
  const StopDetailDivider({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 12),
    child: Divider(height: 1, thickness: 1, color: DriverColors.cool400),
  );
}

/// A labelled section: semibold label with [child] content underneath.
class StopDetailSection extends StatelessWidget {
  const StopDetailSection({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DriverTextStyles.semibold14.copyWith(
            color: DriverColors.neutral900,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

/// Body text used for the values in the stop detail card.
class StopDetailValue extends StatelessWidget {
  const StopDetailValue(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: DriverTextStyles.regular14.copyWith(
      color: DriverColors.neutral700,
      height: 22 / 14,
    ),
  );
}

/// Value text on the left with the green "Call" button on the right.
class StopDetailContactRow extends StatelessWidget {
  const StopDetailContactRow({
    super.key,
    required this.text,
    required this.callKey,
  });

  final String text;
  final Key callKey;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: StopDetailValue(text)),
        const SizedBox(width: 12),
        Material(
          color: DriverColors.primary500,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            key: callKey,
            borderRadius: BorderRadius.circular(8),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  stopDetailIcon(StopDetailAssets.call, 14),
                  const SizedBox(width: 4),
                  Text(
                    l10n.sdCall,
                    style: DriverTextStyles.bold12.copyWith(
                      color: DriverColors.neutral50,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Rounded tinted chip (Sorted / Mixed).
class StopDetailTypeChip extends StatelessWidget {
  const StopDetailTypeChip({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: DriverTextStyles.semibold14.copyWith(color: foreground),
    ),
  );
}
