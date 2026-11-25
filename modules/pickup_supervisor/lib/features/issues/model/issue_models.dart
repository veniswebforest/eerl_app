enum IssueStatus { open, escalated, resolved }

enum IssueType { vehicleBreakdown, sourceProblem }

/// A problem a driver raised during a trip.
class SupervisorIssue {
  const SupervisorIssue({
    required this.id,
    required this.type,
    required this.driverName,
    required this.phone,
    required this.route,
    required this.vehicle,
    required this.raisedAt,
    required this.driverNote,
    required this.status,
    this.actedBy = '',
    this.actedAt = '',
    this.resolution = '',
    this.iecName = '',
  });

  final String id;
  final IssueType type;
  final String driverName;
  final String phone;
  final String route;
  final String vehicle;
  final String raisedAt;

  /// The driver's own words (user content, shown as typed).
  final String driverNote;
  final IssueStatus status;

  /// Who escalated / resolved it, and when.
  final String actedBy;
  final String actedAt;

  /// "What was done" when resolved.
  final String resolution;

  /// The source's IEC told when escalated.
  final String iecName;

  SupervisorIssue copyWith({
    IssueStatus? status,
    String? actedBy,
    String? actedAt,
    String? resolution,
  }) => SupervisorIssue(
    id: id,
    type: type,
    driverName: driverName,
    phone: phone,
    route: route,
    vehicle: vehicle,
    raisedAt: raisedAt,
    driverNote: driverNote,
    status: status ?? this.status,
    actedBy: actedBy ?? this.actedBy,
    actedAt: actedAt ?? this.actedAt,
    resolution: resolution ?? this.resolution,
    iecName: iecName,
  );
}
