import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/utils/module_date_format.dart';
import 'package:pickup_supervisor/core/widgets/module_button.dart';
import 'package:pickup_supervisor/core/widgets/module_modal.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _icons = 'assets/icons/report';
const _package = 'pickup_supervisor';

/// Opens the "Pick dates" bottom sheet and returns the applied range, or null
/// when it is dismissed. Days before [firstDate] or after [lastDate] are
/// greyed out and cannot be picked; [today] is drawn bold. Set
/// [weekdayInSummary] for "Mon 26 Oct – Sat 31 Oct" in the footer.
Future<DateTimeRange?> showModuleDateRangeSheet(
  BuildContext context, {
  DateTimeRange? initialRange,
  DateTime? firstDate,
  DateTime? lastDate,
  DateTime? today,
  DateTime? initialMonth,
  bool weekdayInSummary = false,
}) {
  return showModuleSheet<DateTimeRange>(
    context,
    builder: (_) => DriverLocalizationScope(
      child: ModuleDateRangePicker(
        initialRange: initialRange,
        firstDate: firstDate,
        lastDate: lastDate,
        today: today,
        initialMonth: initialMonth,
        weekdayInSummary: weekdayInSummary,
        onApply: (range) => Navigator.of(context).pop(range),
      ),
    ),
  );
}

/// Month calendar with range selection, a summary line, Clear and Apply.
///
/// Tap a day to start a range and a second day to end it; tapping before the
/// start begins a new range. A single day is a one-day range.
class ModuleDateRangePicker extends StatefulWidget {
  const ModuleDateRangePicker({
    super.key,
    required this.onApply,
    this.lastDate,
    this.firstDate,
    this.today,
    this.initialMonth,
    this.initialRange,
    this.weekdayInSummary = false,
  });

  final DateTime? lastDate;
  final DateTime? firstDate;
  final DateTime? today;
  final DateTime? initialMonth;
  final DateTimeRange? initialRange;
  final bool weekdayInSummary;
  final ValueChanged<DateTimeRange> onApply;

  @override
  State<ModuleDateRangePicker> createState() => _ModuleDateRangePickerState();
}

class _ModuleDateRangePickerState extends State<ModuleDateRangePicker> {
  late DateTime? _start = _day(widget.initialRange?.start);
  late DateTime? _end = _day(widget.initialRange?.end);
  late DateTime _month = () {
    final d =
        widget.initialMonth ??
        widget.initialRange?.end ??
        widget.lastDate ??
        widget.today ??
        DateTime.now();
    return DateTime(d.year, d.month);
  }();

  static DateTime? _day(DateTime? d) =>
      d == null ? null : DateUtils.dateOnly(d);

  DateTime? get _last =>
      widget.lastDate == null ? null : DateUtils.dateOnly(widget.lastDate!);

  DateTime? get _first =>
      widget.firstDate == null ? null : DateUtils.dateOnly(widget.firstDate!);

  DateTimeRange? get _range => _start == null
      ? null
      : DateTimeRange(start: _start!, end: _end ?? _start!);

  bool get _canGoNext =>
      _last == null ||
      DateTime(
        _month.year,
        _month.month + 1,
      ).isBefore(DateTime(_last!.year, _last!.month + 1));

  bool get _canGoPrev =>
      _first == null ||
      DateTime(
        _month.year,
        _month.month,
      ).isAfter(DateTime(_first!.year, _first!.month));

  String _summary(DriverLocalizations l10n, DateTimeRange r) {
    if (!widget.weekdayInSummary) return l10n.shortRange(r);
    String day(DateTime d) =>
        '${l10n.calWeekdayShort('${d.weekday}')} ${l10n.dayMonth(d)}';
    return DateUtils.isSameDay(r.start, r.end)
        ? day(r.start)
        : '${day(r.start)} – ${day(r.end)}';
  }

  void _tap(DateTime day) => setState(() {
    if (_start == null || _end != null || day.isBefore(_start!)) {
      _start = day;
      _end = null;
    } else {
      _end = day;
    }
  });

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final range = _range;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _ArrowButton(
              key: const Key('date-range-prev'),
              asset: '$_icons/prev.svg',
              tooltip: l10n.calPrevMonth,
              onTap: _canGoPrev
                  ? () => setState(
                      () => _month = DateTime(_month.year, _month.month - 1),
                    )
                  : null,
            ),
            Expanded(
              child: Text(
                l10n.monthYear(_month),
                textAlign: TextAlign.center,
                style: DriverTextStyles.semibold16.copyWith(
                  color: DriverColors.neutral950,
                ),
              ),
            ),
            _ArrowButton(
              key: const Key('date-range-next'),
              asset: '$_icons/next.svg',
              tooltip: l10n.calNextMonth,
              onTap: _canGoNext
                  ? () => setState(
                      () => _month = DateTime(_month.year, _month.month + 1),
                    )
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _MonthGrid(
          month: _month,
          first: _first,
          last: _last,
          today: widget.today,
          start: _start,
          end: _end,
          onTap: _tap,
          weekday: (i) => l10n.calWeekday('$i'),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                range == null
                    ? l10n.calPickDates
                    : l10n.calSelection(
                        _summary(l10n, range),
                        l10n.calDays(moduleRangeDays(range)),
                      ),
                style: DriverTextStyles.semibold14.copyWith(
                  color: DriverColors.neutral950,
                ),
              ),
            ),
            InkWell(
              key: const Key('date-range-clear'),
              onTap: () => setState(() => _start = _end = null),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  l10n.calClear,
                  style: DriverTextStyles.semibold14.copyWith(
                    color: DriverColors.red600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ModuleButton(
          key: const Key('date-range-apply'),
          label: l10n.calApply,
          height: 52,
          onPressed: range == null ? null : () => widget.onApply(range),
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    super.key,
    required this.asset,
    required this.tooltip,
    required this.onTap,
  });

  final String asset;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkResponse(
      onTap: onTap,
      radius: 18,
      child: Opacity(
        opacity: onTap == null ? .3 : 1,
        child: SvgPicture.asset(
          asset,
          package: _package,
          width: 20,
          height: 20,
        ),
      ),
    ),
  );
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.first,
    required this.last,
    required this.today,
    required this.start,
    required this.end,
    required this.onTap,
    required this.weekday,
  });

  final DateTime month;
  final DateTime? first;
  final DateTime? last;
  final DateTime? today;
  final DateTime? start;
  final DateTime? end;
  final ValueChanged<DateTime> onTap;
  final String Function(int day) weekday;

  @override
  Widget build(BuildContext context) {
    final leading = DateTime(month.year, month.month).weekday - 1; // Monday 0
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    final cells = <DateTime?>[
      for (var i = 0; i < leading; i++) null,
      for (var d = 1; d <= days; d++) DateTime(month.year, month.month, d),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return Column(
      children: [
        Row(
          children: [
            for (var i = 1; i <= 7; i++)
              Expanded(
                child: SizedBox(
                  height: 24,
                  child: Center(
                    child: Text(
                      weekday(i),
                      style: DriverTextStyles.semibold12.copyWith(
                        color: DriverColors.mutedText,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        for (var row = 0; row < cells.length ~/ 7; row++) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              for (final day in cells.sublist(row * 7, row * 7 + 7))
                Expanded(child: _dayCell(day)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _dayCell(DateTime? day) {
    if (day == null) return const SizedBox(height: 40);
    final disabled =
        (last != null && day.isAfter(last!)) ||
        (first != null && day.isBefore(first!));
    final isToday = today != null && DateUtils.isSameDay(day, today);
    final isStart = start != null && DateUtils.isSameDay(day, start);
    final isEnd = end != null && DateUtils.isSameDay(day, end);
    final inside =
        start != null &&
        end != null &&
        day.isAfter(start!) &&
        day.isBefore(end!);
    final edge = isStart || isEnd;
    return Semantics(
      button: !disabled,
      selected: edge || inside,
      child: GestureDetector(
        key: Key('date-range-day-${day.month}-${day.day}'),
        behavior: HitTestBehavior.opaque,
        onTap: disabled ? null : () => onTap(day),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: edge
                ? DriverColors.primary500
                : inside
                ? DriverColors.primary100
                : null,
            borderRadius: edge ? BorderRadius.circular(20) : null,
          ),
          child: Text(
            '${day.day}',
            style:
                (edge || isToday
                        ? DriverTextStyles.bold14
                        : DriverTextStyles.medium14)
                    .copyWith(
                      color: edge
                          ? DriverColors.neutral50
                          : disabled
                          ? DriverColors.cool400
                          : DriverColors.neutral950,
                    ),
          ),
        ),
      ),
    );
  }
}
