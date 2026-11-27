import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/features/issues/model/issue_models.dart';

/// Issues from SQLite, open first, then escalated, then resolved (outbound
/// doc, Pickup Supervisor screens · Issues).
Future<List<SupervisorIssue>> loadLiveIssues(
  OutboundLiveSession session,
) async {
  final rows = await session.queries.issues();
  return [for (final row in rows) _issue(row, session)];
}

SupervisorIssue _issue(Map<String, Object?> row, OutboundLiveSession session) {
  final types = row['types'] is String
      ? (jsonDecode(row['types']! as String) as List).whereType<String>()
      : const <String>[];
  final status = switch (row['status']) {
    'ESCALATED' => IssueStatus.escalated,
    'RESOLVED' => IssueStatus.resolved,
    _ => IssueStatus.open,
  };
  return SupervisorIssue(
    id: row['id']! as String,
    type:
        types.contains('SOURCE_PROBLEM') && !types.contains('VEHICLE_BREAKDOWN')
        ? IssueType.sourceProblem
        : IssueType.vehicleBreakdown,
    driverName: row['raised_by_name'] as String? ?? '',
    phone: row['raised_by_phone'] as String? ?? '',
    route: row['route_name'] as String? ?? row['source_name'] as String? ?? '',
    vehicle: row['vehicle'] as String? ?? '',
    raisedAt: issueTime(row['raised_at'] as String?),
    driverNote: row['note'] as String? ?? '',
    status: status,
    actedBy: row['decided_by_name'] as String? ?? '',
    actedAt: issueTime(
      row['escalated_at'] as String? ?? row['decided_at'] as String?,
    ),
    resolution: row['resolution_note'] as String? ?? '',
  );
}

/// An ISO time as "23 Nov, 10:52 AM" (IST).
String issueTime(String? iso) {
  final at = DateTime.tryParse(iso ?? '');
  if (at == null) return '';
  final ist = at.toUtc().add(const Duration(hours: 5, minutes: 30));
  return DateFormat('d MMM, h:mm a').format(ist);
}
