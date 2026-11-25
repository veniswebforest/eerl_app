import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';
import 'package:pickup_supervisor/features/route_detail/widgets/route_detail_assets.dart';
import 'package:pickup_supervisor/features/route_detail/widgets/route_detail_header_widgets.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _cardShadow = BoxShadow(
  color: Color(0x1F000000),
  blurRadius: 5,
  offset: Offset(0, 2),
);

String routeStopTitle(DriverLocalizations l10n, RouteStop stop) =>
    l10n.rdStopTitle(
      stop.name,
      stop.type == StopType.sorted ? l10n.rdTypeSorted : l10n.rdTypeMixed,
    );

String _weekday(DriverLocalizations l10n, int day) => switch (day) {
  1 => l10n.rdWeekdayMon,
  4 => l10n.rdWeekdayThu,
  _ => const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day - 1],
};

String routeStopScheduleText(DriverLocalizations l10n, StopSchedule s) =>
    switch (s.kind) {
      StopScheduleKind.everyDay => l10n.rdSchedEveryDay(s.time),
      StopScheduleKind.days => l10n.rdSchedDays(
        s.days.map((d) => _weekday(l10n, d)).join(', '),
        s.time,
      ),
      StopScheduleKind.exceptSunday => l10n.rdSchedExceptSun(s.time),
      StopScheduleKind.secondWednesday => l10n.rdSchedSecondWed(s.time),
      StopScheduleKind.once => l10n.rdSchedOnce(s.date, s.time),
      StopScheduleKind.pausedTill => l10n.rdSchedPausedTill(s.date),
    };

/// Stop filter pills with counts (All, Collected, Pending, 0 kg, …).
class RouteDetailFilterChips extends StatelessWidget {
  const RouteDetailFilterChips({
    super.key,
    required this.selected,
    required this.counts,
    required this.onChanged,
  });

  final StopFilter selected;
  final Map<StopFilter, int> counts;
  final ValueChanged<StopFilter> onChanged;

  String _label(DriverLocalizations l10n, StopFilter filter) =>
      switch (filter) {
        StopFilter.all => l10n.rdFilterAll,
        StopFilter.collected => l10n.rdFilterCollected,
        StopFilter.pending => l10n.rdFilterPending,
        StopFilter.zeroKg => l10n.rdFilterZeroKg,
        StopFilter.missed => l10n.rdFilterMissed,
        StopFilter.cancelled => l10n.rdFilterCancelled,
        StopFilter.inactive => l10n.rdFilterInactive,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final filter in StopFilter.values)
          _FilterChip(
            key: Key('route-detail-filter-${filter.name}'),
            label: _label(l10n, filter),
            count: counts[filter] ?? 0,
            selected: filter == selected,
            onTap: () => onChanged(filter),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

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
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                '$count',
                style: DriverTextStyles.bold12.copyWith(
                  color: selected
                      ? DriverColors.neutral50
                      : DriverColors.neutral400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusStyle {
  const _StatusStyle(this.icon, this.background, this.foreground);

  final String icon;
  final Color background;
  final Color foreground;
}

_StatusStyle _statusStyle(StopStatus status) => switch (status) {
  StopStatus.collected => const _StatusStyle(
    RouteDetailAssets.chipCollected,
    DriverColors.primary100,
    DriverColors.primary500,
  ),
  StopStatus.zeroKg => const _StatusStyle(
    RouteDetailAssets.chipZero,
    DriverColors.cool200,
    DriverColors.slate600,
  ),
  StopStatus.cancelledBySource => const _StatusStyle(
    RouteDetailAssets.chipCancelled,
    DriverColors.purple50,
    DriverColors.purple600,
  ),
  StopStatus.nextStop => const _StatusStyle(
    RouteDetailAssets.chipNext,
    DriverColors.secondary100,
    DriverColors.blue600,
  ),
  StopStatus.pending => const _StatusStyle(
    RouteDetailAssets.chipPending,
    DriverColors.yellow50,
    DriverColors.yellow700,
  ),
  StopStatus.inactive => const _StatusStyle(
    RouteDetailAssets.chipInactive,
    DriverColors.cool200,
    DriverColors.neutral400,
  ),
};

String routeStopStatusLabel(DriverLocalizations l10n, StopStatus status) =>
    switch (status) {
      StopStatus.collected => l10n.rdStatusCollected,
      StopStatus.zeroKg => l10n.rdStatusZeroKg,
      StopStatus.cancelledBySource => l10n.rdStatusCancelledBySource,
      StopStatus.nextStop => l10n.rdStatusNextStop,
      StopStatus.pending => l10n.rdStatusPending,
      StopStatus.inactive => l10n.rdStatusInactive,
    };

/// A stop in today's list, styled by its status.
class RouteDetailStopCard extends StatelessWidget {
  const RouteDetailStopCard({super.key, required this.stop, this.onTap});

  final RouteStop stop;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final status = stop.status;
    final special =
        status == StopStatus.zeroKg ||
        status == StopStatus.cancelledBySource ||
        status == StopStatus.inactive;
    final (
      Color background,
      Color? border,
      double borderWidth,
    ) = switch (status) {
      StopStatus.zeroKg => (
        DriverColors.stopZeroBackground,
        DriverColors.stopZeroBorder,
        1.0,
      ),
      StopStatus.cancelledBySource => (
        DriverColors.stopCancelledBackground,
        DriverColors.stopCancelledBorder,
        1.0,
      ),
      StopStatus.inactive => (
        DriverColors.stopInactiveBackground,
        DriverColors.stopInactiveBorder,
        1.0,
      ),
      StopStatus.nextStop => (
        DriverColors.neutral50,
        DriverColors.primary500,
        2.0,
      ),
      _ => (DriverColors.neutral50, null, 0.0),
    };
    final style = _statusStyle(status);
    final frequency = stop.frequency;

    return Opacity(
      opacity: status == StopStatus.inactive ? .75 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
          border: border == null
              ? null
              : Border.all(color: border, width: borderWidth),
          boxShadow: const [_cardShadow],
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          routeStopTitle(l10n, stop),
                          style: DriverTextStyles.semibold16.copyWith(
                            color: DriverColors.neutral900,
                          ),
                        ),
                      ),
                      if (frequency != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: DriverColors.slate50,
                            borderRadius: BorderRadius.circular(48),
                          ),
                          child: Text(
                            frequency == StopFrequency.daily
                                ? l10n.rdFreqDaily
                                : l10n.rdFreqWeekly,
                            style: DriverTextStyles.semibold12.copyWith(
                              color: DriverColors.neutral700,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      routeDetailIcon(RouteDetailAssets.cardArrow, 20),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _DetailsBox(
                    white: special && status != StopStatus.nextStop,
                    rows: [
                      (RouteDetailAssets.pin, stop.address),
                      (
                        RouteDetailAssets.schedule,
                        routeStopScheduleText(l10n, stop.schedule),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RouteStatusChip(
                        icon: style.icon,
                        label: routeStopStatusLabel(l10n, status),
                        background: style.background,
                        foreground: style.foreground,
                      ),
                      const SizedBox(width: 8),
                      Flexible(child: _Trailing(stop: stop)),
                    ],
                  ),
                  if (_hasRecord) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (stop.collectedAt != null)
                          _RecordTag(
                            icon: RouteDetailAssets.tagClock,
                            label: l10n.rdTagCollectedAt(stop.collectedAt!),
                          ),
                        if (stop.visitedAt != null)
                          _RecordTag(
                            icon: RouteDetailAssets.tagClock,
                            label: l10n.rdTagVisitedAt(stop.visitedAt!),
                          ),
                        if (stop.hasDriverNote)
                          _RecordTag(
                            icon: RouteDetailAssets.tagNote,
                            label: l10n.rdTagNoteFromDriver,
                            blue: true,
                          ),
                        if (stop.voiceNote != null)
                          _RecordTag(
                            icon: RouteDetailAssets.tagVoice,
                            label: l10n.rdTagVoiceNote(stop.voiceNote!),
                            blue: true,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasRecord =>
      stop.collectedAt != null ||
      stop.visitedAt != null ||
      stop.hasDriverNote ||
      stop.voiceNote != null;
}

class _Trailing extends StatelessWidget {
  const _Trailing({required this.stop});

  final RouteStop stop;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    if (stop.amountKg != null) {
      final text = stop.amountPcs != null
          ? l10n.rdAmountKgPcs(stop.amountKg!, stop.amountPcs!)
          : l10n.tpWeightKg(stop.amountKg!);
      return Text(
        text,
        textAlign: TextAlign.end,
        style: DriverTextStyles.bold16.copyWith(color: DriverColors.neutral950),
      );
    }
    final note = switch (stop.note) {
      StopNote.noMaterial => l10n.rdNoteNoMaterial,
      StopNote.closedForStocktaking => l10n.rdNoteClosedStocktaking,
      StopNote.pausedForRenovation => l10n.rdNotePausedRenovation,
      null => null,
    };
    if (note == null) return const SizedBox.shrink();
    return Text(
      note,
      textAlign: TextAlign.end,
      style: DriverTextStyles.medium12.copyWith(color: DriverColors.neutral700),
    );
  }
}

class _DetailsBox extends StatelessWidget {
  const _DetailsBox({
    required this.rows,
    this.white = false,
    this.padding = 10,
  });

  final List<(String, String)> rows;
  final bool white;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: white ? DriverColors.neutral50 : DriverColors.cool100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: DriverColors.neutral50,
                    shape: BoxShape.circle,
                  ),
                  child: routeDetailIcon(rows[i].$1, 14),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    rows[i].$2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: DriverTextStyles.medium14.copyWith(
                      color: DriverColors.neutral700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Status pill. The [large] variant (32px, 20px icon) is used on the stop
/// detail and "Next 7 Days" cards; the default is the compact list chip.
class RouteStatusChip extends StatelessWidget {
  const RouteStatusChip({
    super.key,
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    this.large = false,
    this.radius = 12,
  });

  final String icon;
  final String label;
  final Color background;
  final Color foreground;
  final bool large;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: large ? 32 : null,
      padding: large
          ? const EdgeInsets.all(8)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          routeDetailIcon(icon, large ? 20 : 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: DriverTextStyles.semibold12.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

class _RecordTag extends StatelessWidget {
  const _RecordTag({
    required this.icon,
    required this.label,
    this.blue = false,
  });

  final String icon;
  final String label;
  final bool blue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: blue ? DriverColors.secondary100 : DriverColors.neutral50,
        border: blue
            ? null
            : Border.all(color: DriverColors.stopInactiveBorder),
        borderRadius: BorderRadius.circular(48),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          routeDetailIcon(icon, 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: DriverTextStyles.semibold12.copyWith(
              color: blue ? DriverColors.blue600 : DriverColors.neutral700,
            ),
          ),
        ],
      ),
    );
  }
}

/// A stop in the "Next 7 Days" list.
class RouteDetailUpcomingCard extends StatelessWidget {
  const RouteDetailUpcomingCard({
    super.key,
    required this.stop,
    this.highlighted = false,
    this.once = false,
    this.onTap,
  });

  final RouteStop stop;
  final bool highlighted;
  final bool once;
  final VoidCallback? onTap;

  Widget _upcomingChip(DriverLocalizations l10n) => switch (stop.status) {
    StopStatus.collected => RouteStatusChip(
      large: true,
      radius: 8,
      icon: RouteDetailAssets.upcomingCollected,
      label: l10n.rdStatusCollected,
      background: DriverColors.primary100,
      foreground: DriverColors.primary500,
    ),
    StopStatus.nextStop => RouteStatusChip(
      large: true,
      icon: RouteDetailAssets.upcomingNext,
      label: l10n.sdStatusNextStop,
      background: DriverColors.secondary100,
      foreground: DriverColors.secondary500,
    ),
    _ => RouteStatusChip(
      large: true,
      icon: once
          ? RouteDetailAssets.sevenPendingAlt
          : RouteDetailAssets.sevenPending,
      label: l10n.rdStatusPending,
      background: DriverColors.yellow50,
      foreground: DriverColors.yellow600,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: DriverColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: highlighted ? Border.all(color: DriverColors.primary500) : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        routeStopTitle(l10n, stop),
                        style: DriverTextStyles.semibold18.copyWith(
                          color: DriverColors.neutral900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _DetailsBox(
                      padding: 12,
                      rows: [
                        (RouteDetailAssets.sevenPin, stop.address),
                        (
                          RouteDetailAssets.clock,
                          routeStopScheduleText(l10n, stop.schedule),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _upcomingChip(l10n),
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: DriverColors.cool200,
                            borderRadius: BorderRadius.circular(5.12),
                          ),
                          child: routeDetailIcon(
                            RouteDetailAssets.sevenSwap,
                            24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: routeDetailIcon(
                    highlighted
                        ? RouteDetailAssets.sevenArrowGreen
                        : RouteDetailAssets.sevenArrowMuted,
                    10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
