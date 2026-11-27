/// The time parameters of the outbound SQLite doc: `:now` is the current UTC
/// time (ISO-8601), `:today`, `:tomorrow`, `:yesterday` are IST days
/// (`YYYY-MM-DD`) and `:now_hhmm` is the IST clock time.
class OutboundClock {
  OutboundClock({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  static const _ist = Duration(hours: 5, minutes: 30);

  DateTime get utc => _now().toUtc();

  String get now => utc.toIso8601String();

  DateTime get _istNow => utc.add(_ist);

  String get today => day(0);

  String get tomorrow => day(1);

  String get yesterday => day(-1);

  /// The IST day [offset] days from today.
  String day(int offset) {
    final d = _istNow.add(Duration(days: offset));
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  /// The IST clock time, `HH:MM`.
  String get nowHhmm {
    final d = _istNow;
    return '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  /// Monday of the current IST week (the IEC's "this week").
  String get weekStart => day(-(_istNow.weekday - 1));
}

/// Who is acting: `:me`, `:my_name`, `:my_phone` (from `me.user`).
class OutboundActor {
  const OutboundActor({required this.id, required this.name, this.phone});

  final String id;
  final String name;
  final String? phone;
}
