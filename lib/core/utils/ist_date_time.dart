import 'package:intl/intl.dart';

abstract final class IstDateTime {
  static const offset = Duration(hours: 5, minutes: 30);

  /// Returns an unzoned wall-clock value whose fields represent current IST.
  static DateTime now() => fromUtc(DateTime.now().toUtc());

  /// Converts an instant to an unzoned wall-clock value for picker/display use.
  static DateTime fromUtc(DateTime value) {
    final shifted = value.toUtc().add(offset);
    return DateTime(
      shifted.year,
      shifted.month,
      shifted.day,
      shifted.hour,
      shifted.minute,
      shifted.second,
      shifted.millisecond,
      shifted.microsecond,
    );
  }

  /// Treats [value]'s fields as IST and converts that wall time to a UTC instant.
  static DateTime toUtc(DateTime value) => DateTime.utc(
    value.year,
    value.month,
    value.day,
    value.hour,
    value.minute,
    value.second,
    value.millisecond,
    value.microsecond,
  ).subtract(offset);

  static String formatUtc(String value, String pattern) {
    final parsed = DateTime.tryParse(value);
    return parsed == null ? value : DateFormat(pattern).format(fromUtc(parsed));
  }
}
