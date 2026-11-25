import 'package:pickup_supervisor/features/issues/model/issue_models.dart';

/// Static issues (no backend yet).
abstract final class IssueMockData {
  /// The signed-in supervisor and the time actions are stamped with.
  static const supervisorName = 'Kiran Patel';
  static const actionTime = '23 Nov, 10:52 AM';

  static const issues = <SupervisorIssue>[
    SupervisorIssue(
      id: 'issue-ramesh',
      type: IssueType.vehicleBreakdown,
      driverName: 'Ramesh Ahir',
      phone: '9876543210',
      route: 'Adajan Morning',
      vehicle: 'GJ-05-BX-1234',
      raisedAt: '10:42 AM',
      driverNote:
          'Clutch plate gone near Adajan Patiya. The van can’t move. '
          '3 stops left.',
      status: IssueStatus.open,
      iecName: 'Neha Joshi',
    ),
    SupervisorIssue(
      id: 'issue-mohan',
      type: IssueType.sourceProblem,
      driverName: 'Mohan Lal',
      phone: '9898012345',
      route: 'Pal Gam Morning',
      vehicle: 'GJ-05-CD-4521',
      raisedAt: '9:15 AM',
      driverNote: 'Gate locked at Om Fabrics. Nobody answers the phone.',
      status: IssueStatus.escalated,
      actedBy: supervisorName,
      actedAt: '23 Nov, 9:40 AM',
      iecName: 'Neha Joshi',
    ),
    SupervisorIssue(
      id: 'issue-prakash',
      type: IssueType.vehicleBreakdown,
      driverName: 'Prakash Jadav',
      phone: '9825098250',
      route: 'Rander Evening',
      vehicle: 'GJ-05-EF-7788',
      raisedAt: '8:30 AM',
      driverNote: 'Flat tyre on the back left wheel.',
      status: IssueStatus.resolved,
      actedBy: supervisorName,
      actedAt: '23 Nov, 9:05 AM',
      resolution: 'Tyre changed at the stop. Trip continued.',
      iecName: 'Neha Joshi',
    ),
  ];
}
