/// Contact shown in the "Person at the pickup point" / "IEC Executive" rows.
class StopContact {
  const StopContact({required this.name, required this.phone, this.role});

  final String name;
  final String phone;

  /// Null for the IEC executive (no role in the design).
  final String? role;
}

/// Extra, static information the stop detail screen shows for a stop.
class StopDetailInfo {
  const StopDetailInfo({
    required this.person,
    required this.iecExecutive,
    required this.warehouse,
    required this.fullAddress,
  });

  final StopContact person;
  final StopContact iecExecutive;
  final String warehouse;
  final String fullAddress;
}

/// Reasons selectable on the Skip Source screen.
enum SkipReason { sourceClosed, holiday, vehicleUnavailable, other }
