import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/tasks/view/task_detail_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('pending task renders the empty resolve design state', (
    tester,
  ) async {
    await _pumpTask(tester, _pendingTask());

    expect(find.text('Resolve Task'), findsOneWidget);
    expect(find.text('Verify Collection Details'), findsOneWidget);
    expect(find.text('Attachment from Supervisor'), findsOneWidget);
    expect(
      find.byKey(const Key('supervisor-task-attachments')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('preview-task-photo-0')), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -320));
    await tester.pump();
    expect(
      find.text('Task Completion Proof *', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Max 150 Characters'), findsOneWidget);

    final button = tester.widget<ElevatedButton>(
      find.byKey(const Key('mark-task-completed-button')),
    );
    expect(button.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('completed task renders the read-only detail design state', (
    tester,
  ) async {
    await _pumpTask(tester, _completedTask());

    expect(find.text('Task Details'), findsOneWidget);
    expect(find.textContaining('Completed:'), findsOneWidget);
    expect(find.text('Task Completion Proof'), findsOneWidget);
    expect(find.text('Capture Photo'), findsOneWidget);
    expect(find.text('Max 150 Characters'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Supervisor Details'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Supervisor Details'), findsOneWidget);
    expect(
      find.text('Review and verify the submitted collection.'),
      findsOneWidget,
    );
    expect(find.text('Bhavesh Shah'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loads supervisor attachments from the latest SQLite task row', (
    tester,
  ) async {
    final initial = _pendingTask(photoUrls: const []);
    final latest = _pendingTask();

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TaskDetailScreen(task: initial, taskLoader: (_) async => latest),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Attachment from Supervisor'), findsOneWidget);
    expect(
      find.byKey(const Key('supervisor-task-attachments')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('preview-task-photo-0')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpTask(WidgetTester tester, TaskModel task) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: TaskDetailScreen(task: task, taskLoader: (_) async => task),
    ),
  );
  await tester.pump();
}

TaskModel _pendingTask({
  List<String> photoUrls = const ['assets/images/profile_rahul_patel.png'],
}) {
  final due = DateTime.now().add(const Duration(hours: 2)).toUtc();
  return TaskModel(
    id: 'pending-task',
    assignedTo: 'agent-1',
    assignedBy: 'supervisor-1',
    assignedByName: 'Bhavesh Shah',
    title: 'Verify Collection Details',
    description: 'Review and verify the submitted collection.',
    priority: 'HIGH',
    status: 'PENDING',
    dueAt: due.toIso8601String(),
    photoUrls: photoUrls,
    createdAt: DateTime.now().toUtc().toIso8601String(),
    syncState: 'synced',
  );
}

TaskModel _completedTask() {
  final completed = DateTime.now()
      .subtract(const Duration(minutes: 30))
      .toUtc();
  return TaskModel(
    id: 'completed-task',
    assignedTo: 'agent-1',
    assignedBy: 'supervisor-1',
    assignedByName: 'Bhavesh Shah',
    title: 'Verify Collection Details',
    description: 'Review and verify the submitted collection.',
    note: 'Weight scale calibrated using 10kg standard test weight.',
    priority: 'HIGH',
    status: 'COMPLETED',
    completedAt: completed.toIso8601String(),
    photoUrls: const [
      'assets/images/profile_rahul_patel.png',
      'assets/images/profile_rahul_patel.png',
    ],
    createdAt: DateTime.now().toUtc().toIso8601String(),
    syncState: 'synced',
  );
}
