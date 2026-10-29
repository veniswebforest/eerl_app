import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/supervisor_requests/widgets/supervisor_agent_request_card.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_card.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const task = TaskModel(
    id: 'task-1',
    assignedTo: 'agent-1',
    assignedToName: 'Kiran Rathod',
    assignedBy: 'supervisor-1',
    title: 'Check weighing scale',
    description: 'Verify the scale before collection.',
    priority: 'HIGH',
    status: 'COMPLETED',
    dueAt: '2026-10-20T03:30:00.000Z',
    completedAt: '2026-10-23T04:00:00.000Z',
    photoUrls: [],
    createdAt: '2026-10-18T03:30:00.000Z',
    syncState: 'synced',
  );
  const request = RequestModel(
    id: 'request-1',
    createdBy: 'agent-1',
    createdByName: 'Kiran Rathod',
    body: 'The scale needs calibration.',
    priority: 'HIGH',
    status: 'CLOSED',
    answer: 'Calibration completed.',
    answeredAt: '2026-10-23T04:00:00.000Z',
    photoUrls: [],
    createdAt: '2026-10-20T03:30:00.000Z',
    syncState: 'synced',
  );

  testWidgets('task card uses completed_at only for the closed tab', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      SupervisorTaskCard(item: task, showClosedTimestamp: true),
    );
    expect(find.text('23 Oct, 09:30 AM'), findsOneWidget);
    expect(find.text('20 Oct, 09:00 AM'), findsNothing);

    await _pumpCard(tester, const SupervisorTaskCard(item: task));
    expect(find.text('20 Oct, 09:00 AM'), findsOneWidget);
    expect(find.text('23 Oct, 09:30 AM'), findsNothing);
  });

  testWidgets('request card uses answered_at only for the closed tab', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      SupervisorAgentRequestCard(
        item: request,
        showClosedTimestamp: true,
        onTap: _noop,
      ),
    );
    expect(find.text('23 Oct 2026, 9:30 AM'), findsOneWidget);
    expect(find.text('20 Oct 2026, 9:00 AM'), findsNothing);

    await _pumpCard(
      tester,
      const SupervisorAgentRequestCard(item: request, onTap: _noop),
    );
    expect(find.text('20 Oct 2026, 9:00 AM'), findsOneWidget);
    expect(find.text('23 Oct 2026, 9:30 AM'), findsNothing);
  });
}

void _noop() {}

Future<void> _pumpCard(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
