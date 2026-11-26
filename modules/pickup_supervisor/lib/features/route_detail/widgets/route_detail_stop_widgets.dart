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
      StopScheduleKind.firstOfMonth => l10n.rdSchedFirstOfMonth(s.time),
      StopScheduleKind.calledIn => l10n.rdSchedCalledIn(s.time),
      StopScheduleKind.everyDayExceptSun => l10n.rdSchedEveryDayExceptSun(
        s.time,
      ),
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
  StopStatus.missed => const _StatusStyle(
    RouteDetailAssets.chipMissed,
    DriverColors.red100,
    DriverColors.red600,
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
      StopStatus.missed => l10n.rdStatusMissed,
    };

/// "Daily" / "Weekly" / "Monthly".
String routeStopFrequencyLabel(DriverLocalizations l10n, StopFrequency f) =>
    switch (f) {
      StopFrequency.daily => l10n.rdFreqDaily,
      StopFrequency.weekly => l10n.rdFreqWeekly,
      StopFrequency.monthly => l10n.rdFreqMonthly,
      StopFrequency.onCall => l10n.rdFreqOnCall,
    };

/// A stop in today's list, styled by its status.
class RouteDetailStopCard extends StatelessWidget {
  const RouteDetailStopCard({
    super.key,
    required this.stop,
    this.onTap,
    this.upcoming = false,
  });

  final RouteStop stop;
  final VoidCallback? onTap;

  /// Next 7 Days: shows the coming visits instead of today's status (an
  /// inactive stop still shows its status).
  final bool upcoming;

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
      StopStatus.missed => (
        DriverColors.missedCard,
        DriverColors.missedCardBorder,
        1.0,
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
                            routeStopFrequencyLabel(l10n, frequency),
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
                  if (_showsVisits) ...[
                    const SizedBox(height: 10),
                    _RecordTag(
                      label: stop.nextVisits != null
                          ? l10n.rdNextVisits(stop.nextVisits!)
                          : l10n.rdEveryDayVisits('${stop.visitsThisWeek}'),
                      tone: _TagTone.grey,
                    ),
                  ] else ...[
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
                  ],
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
                            tone: _TagTone.blue,
                          ),
                        if (stop.voiceNote != null)
                          _RecordTag(
                            icon: RouteDetailAssets.tagVoice,
                            label: l10n.rdTagVoiceNote(stop.voiceNote!),
                            tone: _TagTone.blue,
                          ),
                        if (stop.gateEntryAt != null)
                          _RecordTag(
                            icon: RouteDetailAssets.tagGate,
                            label: l10n.rdTagGate(stop.gateEntryAt!),
                            tone: _TagTone.amber,
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

  bool get _showsVisits =>
      upcoming &&
      stop.status != StopStatus.inactive &&
      (stop.nextVisits != null || stop.visitsThisWeek != null);

  bool get _hasRecord =>
      !upcoming &&
      (stop.collectedAt != null ||
          stop.visitedAt != null ||
          stop.hasDriverNote ||
          stop.voiceNote != null ||
          stop.gateEntryAt != null);
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
      StopNote.notRecordedByDriver => l10n.rdNoteNotRecorded,
      StopNote.noMaterialPerDriver => l10n.rdNoteNoMaterialDriver,
      StopNote.askedToSkipToday => l10n.rdNoteAskedToSkip,
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
  const _DetailsBox({required this.rows, this.white = false});

  final List<(String, String)> rows;
  final bool white;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
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

enum _TagTone { plain, blue, amber, grey }

class _RecordTag extends StatelessWidget {
  const _RecordTag({
    required this.label,
    this.icon,
    this.tone = _TagTone.plain,
  });

  final String? icon;
  final String label;
  final _TagTone tone;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (tone) {
      _TagTone.plain => (DriverColors.neutral50, DriverColors.neutral700),
      _TagTone.blue => (DriverColors.secondary100, DriverColors.blue600),
      _TagTone.amber => (DriverColors.escalatedBg, DriverColors.amber800),
      _TagTone.grey => (DriverColors.cool100, DriverColors.neutral700),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: tone == _TagTone.plain
            ? Border.all(color: DriverColors.stopInactiveBorder)
            : null,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            routeDetailIcon(icon!, 14),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: DriverTextStyles.semibold12.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}
