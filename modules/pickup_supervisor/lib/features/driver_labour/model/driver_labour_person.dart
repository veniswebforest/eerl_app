enum DriverLabourKind { driver, labour }

/// Static person row used by the Driver & Labour directory screens.
class DriverLabourPerson {
  const DriverLabourPerson({
    required this.name,
    required this.code,
    required this.idNumber,
    required this.dateTime,
    required this.kind,
    this.phone,
    this.warehouse,
    this.active = true,
  });

  final String name;
  final String code;
  final String? phone;
  final String idNumber;
  final String dateTime;
  final String? warehouse;
  final DriverLabourKind kind;
  final bool active;
}
