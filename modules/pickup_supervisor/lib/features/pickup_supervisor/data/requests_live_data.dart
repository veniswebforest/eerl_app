import 'package:intl/intl.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/features/driver/data/driver_live_data.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// A request kind in words.
String requestKindLabel(DriverLocalizations l10n, String? kind) =>
    switch (kind) {
      'VEHICLE' => l10n.liveKindVehicle,
      'LABOUR' => l10n.liveKindLabour,
      'PICKUP_POINT_CHANGE' => l10n.liveKindPointChange,
      'START_PICKUPS' => l10n.liveKindStart,
      'STOP_PICKUPS' => l10n.liveKindStop,
      'PAUSE_PICKUPS' => l10n.liveKindPause,
      'SCHEDULE_CHANGE' => l10n.liveKindSchedule,
      'ROUTE_OR_VEHICLE' => l10n.liveKindRoute,
      'ENTRY_CORRECTION' => l10n.liveKindCorrection,
      _ => l10n.liveKindOther,
    };

/// An ISO time or `YYYY-MM-DD` day as "27 Nov" (IST).
String requestDay(String? value) {
  final at = DateTime.tryParse(value ?? '');
  if (at == null) return '';
  final ist = value!.length > 10
      ? at.toUtc().add(const Duration(hours: 5, minutes: 30))
      : at;
  return DateFormat('d MMM').format(ist);
}

/// One card on Approval requests: a request sent to me, or an extra pickup
/// an IEC asked for (outbound doc, Pickup Supervisor screens · Approval
/// Requests).
class LiveApproval {
  const LiveApproval({
    required this.id,
    required this.isExtraPickup,
    required this.title,
    required this.source,
    required this.detail,
    required this.time,
    required this.status,
  });

  final String id;
  final bool isExtraPickup;
  final String title;
  final String source;
  final String detail;
  final String time;

  /// WAITING / REQUESTED, APPROVED / DUE…, DECLINED.
  final String status;

  bool get declined => status == 'DECLINED';

  static Future<List<LiveApproval>> load(
    OutboundLiveSession session,
    DriverLocalizations l10n, {
    required bool toApprove,
  }) async {
    final rows = await session.queries.approvalRequests(toApprove: toApprove);
    return [
      for (final row in rows)
        if (row['what'] == 'EXTRA_PICKUP')
          LiveApproval(
            id: row['id']! as String,
            isExtraPickup: true,
            title: l10n.attentionExtraPickup,
            source: row['source_name'] as String? ?? '',
            detail: [
              if ((row['details'] as String?)?.isNotEmpty ?? false)
                row['details']! as String,
              if (row['raised_by_name'] != null)
                row['raised_by_name']! as String,
            ].join(' · '),
            time: l10n.liveSentOn(requestDay(row['sent_at'] as String?)),
            status: row['status'] as String? ?? '',
          )
        else
          LiveApproval(
            id: row['id']! as String,
            isExtraPickup: false,
            title: l10n.liveKindFrom(
              requestKindLabel(l10n, row['kind'] as String?),
              row['raised_by_name'] as String? ?? '',
            ),
            source: [
              row['source_name'] as String? ?? '',
              if (row['trip_number'] != null) row['trip_number']! as String,
            ].where((s) => s.isNotEmpty).join(' · '),
            detail: row['details'] as String? ?? '',
            time: l10n.liveSentOn(requestDay(row['sent_at'] as String?)),
            status: row['status'] as String? ?? '',
          ),
    ];
  }
}

/// One of my requests to the Collection Head (outbound doc, My Requests).
class LiveMyRequest {
  const LiveMyRequest({
    required this.id,
    required this.title,
    required this.status,
    required this.description,
    required this.response,
    required this.sent,
    required this.canFollowUp,
  });

  final String id;
  final String title;

  /// WAITING | APPROVED | DECLINED.
  final String status;
  final String description;
  final String response;
  final String sent;
  final bool canFollowUp;

  static Future<List<LiveMyRequest>> load(
    OutboundLiveSession session,
    DriverLocalizations l10n,
  ) async {
    final rows = await session.queries.myRequests();
    return [
      for (final r in rows)
        LiveMyRequest(
          id: r['id']! as String,
          title: l10n.liveKindFor(
            requestKindLabel(l10n, r['kind'] as String?),
            (r['route_name'] ?? r['trip_number'] ?? r['source_name'] ?? '')
                as String,
          ),
          status: r['status'] as String? ?? 'WAITING',
          description: [
            r['details'] as String? ?? '',
            if (r['from_date'] != null)
              [
                requestDay(r['from_date'] as String?),
                if (r['to_date'] != null) requestDay(r['to_date'] as String?),
              ].join(' – '),
          ].where((s) => s.isNotEmpty).join(' · '),
          response: r['decided_by_name'] == null
              ? (r['assignee_name'] as String? ?? '')
              : [
                  l10n.liveAnsweredBy(
                    r['decided_by_name']! as String,
                    requestDay(r['decided_at'] as String?),
                  ),
                  if ((r['reply'] as String?)?.isNotEmpty ?? false)
                    r['reply']! as String,
                ].join(' · '),
          sent: l10n.liveSentOn(requestDay(r['raised_at'] as String?)),
          canFollowUp: r['can_follow_up'] == 1,
        ),
    ];
  }
}

/// A trip or route the "For" sheet of Ask the Collection Head offers.
String routeChoiceTime(Map<String, Object?> route) =>
    '${formatClock(route['start_time'] as String? ?? '')} – '
    '${formatClock(route['end_time'] as String? ?? '')}';
