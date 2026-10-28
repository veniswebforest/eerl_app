import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/tasks/model/task_list_item.dart';
import 'package:eerl_app/features/tasks/widgets/task_list_card.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('closed task status includes completed, closed and cancelled', () {
    expect(isClosedTaskStatus('COMPLETED'), isTrue);
    expect(isClosedTaskStatus('CLOSED'), isTrue);
    expect(isClosedTaskStatus('CANCELLED'), isTrue);
    expect(isClosedTaskStatus('PENDING'), isFalse);
  });

  testWidgets('cancelled agent task card displays cancelled state', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: TaskListCard(item: _cancelledTask)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Task Cancelled'), findsOneWidget);
    expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

const _cancelledTask = TaskModel(
  id: 'task-cancelled',
  assignedTo: 'agent-1',
  assignedBy: 'supervisor-1',
  assignedByName: 'Supervisor One',
  title: 'Check vehicle documents',
  priority: 'NORMAL',
  status: 'CANCELLED',
  dueAt: '2026-10-28T10:00:00.000Z',
  photoUrls: [],
  createdAt: '2026-10-28T09:00:00.000Z',
  syncState: 'synced',
);
