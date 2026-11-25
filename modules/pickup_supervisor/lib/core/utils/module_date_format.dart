import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// Localised date and number text built from the module's own strings, so it
/// works in English, Gujarati and Hindi without extra intl locale data.
extension ModuleDateFormat on DriverLocalizations {
  String monthShort(DateTime d) => calMonthShort('${d.month}');

  String monthLong(DateTime d) => calMonthLong('${d.month}');

  /// "October 2026"
  String monthYear(DateTime d) => '${monthLong(d)} ${d.year}';

  /// "16 Oct"
  String dayMonth(DateTime d) => '${d.day} ${monthShort(d)}';

  /// "22 Oct 2026"
  String dayMonthYear(DateTime d) => '${dayMonth(d)} ${d.year}';

  /// "16 – 22 Oct 2026", "28 Sep – 4 Oct 2026" or "22 Oct 2026".
  String rangeLabel(DateTimeRange r) {
    final s = r.start;
    final e = r.end;
    if (DateUtils.isSameDay(s, e)) return dayMonthYear(e);
    if (s.year == e.year && s.month == e.month) {
      return '${s.day} – ${dayMonthYear(e)}';
    }
    if (s.year == e.year) return '${dayMonth(s)} – ${dayMonthYear(e)}';
    return '${dayMonthYear(s)} – ${dayMonthYear(e)}';
  }

  /// "16 Oct – 22 Oct" (calendar footer).
  String shortRange(DateTimeRange r) => DateUtils.isSameDay(r.start, r.end)
      ? dayMonth(r.start)
      : '${dayMonth(r.start)} – ${dayMonth(r.end)}';

  /// "2,140" with the locale's grouping.
  String number(num value) =>
      NumberFormat.decimalPattern(localeName).format(value);
}

/// Whole days in [range], counting both ends.
int moduleRangeDays(DateTimeRange range) =>
    DateUtils.dateOnly(
      range.end,
    ).difference(DateUtils.dateOnly(range.start)).inDays +
    1;
