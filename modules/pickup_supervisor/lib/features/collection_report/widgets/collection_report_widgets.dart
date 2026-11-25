import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/utils/module_date_format.dart';
import 'package:pickup_supervisor/features/collection_report/model/collection_report_models.dart';
import 'package:pickup_supervisor/features/collection_report/widgets/collection_report_text.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _package = 'pickup_supervisor';
const reportIconRoot = 'assets/icons/report';
const _shadow = [
  BoxShadow(color: DriverColors.shadow, blurRadius: 5, offset: Offset(0, 2)),
];

/// Today / Yesterday / Week / Month pills plus the calendar pill. Used on the
/// home collection summary and on the collection report.
class ReportPeriodChips extends StatelessWidget {
  const ReportPeriodChips({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.onPickDates,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    this.calendarPadding = const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 7,
    ),
    this.keyPrefix = 'report-period',
    this.calendarAsset = '$reportIconRoot/calendar.svg',
  });

  final ReportPeriod selected;
  final ValueChanged<ReportPeriod> onSelected;
  final VoidCallback onPickDates;
  final EdgeInsets padding;
  final EdgeInsets calendarPadding;
  final String keyPrefix;
  final String calendarAsset;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final custom = selected == ReportPeriod.custom;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final p in ReportPeriod.values.take(4)) ...[
            _Pill(
              key: Key('$keyPrefix-${p.name}'),
              selected: p == selected,
              padding: padding,
              onTap: () => onSelected(p),
              child: Text(
                l10n.periodChip(p),
                style: DriverTextStyles.semibold12.copyWith(
                  color: p == selected
                      ? DriverColors.neutral50
                      : DriverColors.neutral900,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          _Pill(
            key: Key('$keyPrefix-dates'),
            selected: custom,
            padding: calendarPadding,
            onTap: onPickDates,
            child: Semantics(
              label: l10n.calPickDates,
              child: SvgPicture.asset(
                calendarAsset,
                package: _package,
                width: 14,
                height: 14,
                colorFilter: custom
                    ? const ColorFilter.mode(
                        DriverColors.neutral50,
                        BlendMode.srcIn,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    super.key,
    required this.selected,
    required this.padding,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final EdgeInsets padding;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? DriverColors.primary500 : DriverColors.neutral50,
    shape: StadiumBorder(
      side: selected
          ? BorderSide.none
          : const BorderSide(color: DriverColors.border),
    ),
    child: InkWell(
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: Padding(padding: padding, child: child),
    ),
  );
}

/// Small outlined "Share" action in the report header.
class ReportShareButton extends StatelessWidget {
  const ReportShareButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Material(
      color: DriverColors.neutral50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: DriverColors.primary500),
      ),
      child: InkWell(
        key: const Key('report-share'),
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                '$reportIconRoot/share.svg',
                package: _package,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.rpShare,
                style: DriverTextStyles.bold12.copyWith(
                  color: DriverColors.primary500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// White rounded card with the module's shadow.
class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.child, this.spacing = 0});

  final Widget child;
  final double spacing;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: DriverColors.neutral50,
      borderRadius: BorderRadius.circular(12),
      boxShadow: _shadow,
    ),
    child: child,
  );
}

/// "Collected this week" totals with the outcome bar and the four counts.
class ReportTotalsCard extends StatelessWidget {
  const ReportTotalsCard({super.key, required this.data, required this.period});

  final CollectionReportData data;
  final ReportPeriod period;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final outcomes = [
      (
        data.collected,
        l10n.supervisorCollected,
        DriverColors.primary500,
        DriverColors.primary50,
      ),
      (
        data.zeroKg,
        l10n.supervisorKg,
        DriverColors.slate600,
        DriverColors.slate50,
      ),
      (
        data.missed,
        l10n.supervisorMissed,
        DriverColors.red600,
        DriverColors.red100,
      ),
      (
        data.cancelled,
        l10n.supervisorCancelled,
        DriverColors.purple600,
        DriverColors.purple50,
      ),
    ];
    return ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.collectedPeriodLabel(period),
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.totalText(data),
            style: DriverTextStyles.bold24.copyWith(
              color: DriverColors.neutral950,
              height: 28 / 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.rpStopsDue(l10n.number(data.due)),
            style: DriverTextStyles.semibold14.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            key: const Key('report-outcome-bar'),
            children: [
              for (final (i, o) in outcomes.indexed)
                if (o.$1 > 0) ...[
                  if (i > 0) const SizedBox(width: 2),
                  Expanded(
                    flex: o.$1,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: o.$3,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final (i, o) in outcomes.indexed) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: o.$4,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.number(o.$1),
                          style: DriverTextStyles.bold16.copyWith(color: o.$3),
                        ),
                        Text(
                          o.$2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: DriverTextStyles.medium12.copyWith(
                            color: DriverColors.neutral700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Card with a title and divided rows (By route, By pickup category, …).
class ReportSectionCard extends StatelessWidget {
  const ReportSectionCard({super.key, required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) => ReportCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: DriverTextStyles.semibold16.copyWith(
            color: DriverColors.neutral950,
          ),
        ),
        const SizedBox(height: 6),
        ...rows,
      ],
    ),
  );
}

/// One divided row: title + grey subtitle, an optional tag and a bold value.
class ReportRow extends StatelessWidget {
  const ReportRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    this.tag,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String value;
  final Widget? tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: DriverColors.slate50)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DriverTextStyles.semibold14.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: DriverTextStyles.medium12.copyWith(
                    color: DriverColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          if (tag != null) ...[const SizedBox(width: 8), tag!],
          const SizedBox(width: 8),
          Text(
            value,
            style: DriverTextStyles.bold14.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
        ],
      ),
    ),
  );
}

/// "Own" (blue) or "Contract" (pink) vehicle tag.
class ReportVehicleTag extends StatelessWidget {
  const ReportVehicleTag({super.key, required this.vehicle});

  final RouteVehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final own = vehicle == RouteVehicle.own;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: own ? DriverColors.secondary100 : DriverColors.pink100,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Text(
        DriverLocalizations.of(context).vehicleLabel(vehicle),
        style: DriverTextStyles.semibold12.copyWith(
          color: own ? DriverColors.blue600 : DriverColors.pink600,
        ),
      ),
    );
  }
}
