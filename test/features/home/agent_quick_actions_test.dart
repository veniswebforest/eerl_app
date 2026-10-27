import 'package:eerl_app/features/home/widgets/quick_actions.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('pending task badge uses current agent task results', (
    tester,
  ) async {
    var tasks = <TaskModel>[
      _task('open-1', 'OPEN'),
      _task('pending-2', 'PENDING'),
      _task('completed-1', 'COMPLETED'),
      _task('cancelled-1', 'CANCELLED'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuickActions(
              taskLoader: () async => tasks,
              onAddCollectionTap: () {},
              onTasksTap: () async {
                tasks = [_task('open-1', 'COMPLETED')];
              },
              onLogExpenseTap: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('agent-pending-task-count')),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
    expect(find.text('3'), findsNothing);

    final taskCard = find.byKey(const Key('home-pending-task-card'));
    await tester.tap(
      find.descendant(of: taskCard, matching: find.byType(ElevatedButton)),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('agent-pending-task-count')),
        matching: find.text('0'),
      ),
      findsOneWidget,
    );
  });
}

TaskModel _task(String id, String status) => TaskModel(
  id: id,
  centerId: 'center-id',
  assignedTo: 'agent-id',
  assignedBy: 'supervisor-id',
  title: 'Task $id',
  priority: 'NORMAL',
  status: status,
  photoUrls: const [],
  createdAt: '2026-10-27T00:00:00.000Z',
  syncState: 'synced',
);
