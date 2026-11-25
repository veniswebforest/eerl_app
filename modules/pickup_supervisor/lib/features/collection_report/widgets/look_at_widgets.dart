import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_models.dart';
import 'package:pickup_supervisor/features/collection_report/widgets/collection_report_text.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _package = 'pickup_supervisor';
const _icons = 'assets/icons/look_at';

/// Card / tag colours and tag icon for each outcome.
({Color background, Color border, Color tagBg, Color tagFg, String icon})
lookAtStyle(LookAtOutcome o) => switch (o) {
  LookAtOutcome.missed => (
    background: DriverColors.missedCard,
    border: DriverColors.missedCardBorder,
    tagBg: DriverColors.red100,
    tagFg: DriverColors.red600,
    icon: '$_icons/missed.svg',
  ),
  LookAtOutcome.cancelledBySource => (
    background: DriverColors.cancelledCard,
    border: DriverColors.cancelledCardBorder,
    tagBg: DriverColors.purple50,
    tagFg: DriverColors.purple600,
    icon: '$_icons/cancelled.svg',
  ),
  LookAtOutcome.zeroKg => (
    background: DriverColors.neutral50,
    border: DriverColors.zeroKgCardBorder,
    tagBg: DriverColors.slate50,
    tagFg: DriverColors.slate600,
    icon: '$_icons/zero.svg',
  ),
};

/// A pickup point that was missed, cancelled by the source, or 0 kg.
class LookAtStopCard extends StatelessWidget {
  const LookAtStopCard({
    super.key,
    required this.stop,
    required this.outcome,
    this.onTap,
  });

  final LookAtStop stop;
  final LookAtOutcome outcome;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final style = lookAtStyle(outcome);
    return Container(
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.border),
        boxShadow: const [
          BoxShadow(
            color: DriverColors.shadow,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ?? () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stop.name,
                        style: DriverTextStyles.semibold16.copyWith(
                          fontSize: 15,
                          height: 1.37,
                          color: DriverColors.neutral950,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SvgPicture.asset(
                      '$_icons/chevron.svg',
                      package: _package,
                      width: 20,
                      height: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.lookAtFirstLine(stop),
                  style: DriverTextStyles.medium12.copyWith(
                    color: DriverColors.neutral900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.lookAtDetail(stop),
                  style: DriverTextStyles.medium12.copyWith(
                    color: DriverColors.mutedText,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: style.tagBg,
                        borderRadius: BorderRadius.circular(48),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            style.icon,
                            package: _package,
                            width: 14,
                            height: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.outcomeTabLabel(outcome),
                            style: DriverTextStyles.semibold12.copyWith(
                              color: style.tagFg,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l10n.lookAtReason(stop.reason),
                        style: DriverTextStyles.medium12.copyWith(
                          color: DriverColors.neutral700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
