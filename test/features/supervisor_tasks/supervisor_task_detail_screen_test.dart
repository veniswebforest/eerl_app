import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/supervisor_tasks/view/supervisor_task_detail_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('matches the supervisor in-progress task detail state', (
    tester,
  ) async {
    final task = _task(status: 'PENDING');
    await _pumpScreen(tester, task);

    expect(find.text('Task in Progress'), findsOneWidget);
    expect(find.text('Assign To'), findsOneWidget);
    expect(find.text('Your sent task details'), findsNothing);
    expect(find.text('Task Title'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Attachment By you'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Attachment By you'), findsOneWidget);
    expect(find.text('Cancel Task'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('matches the supervisor cancelled task detail state', (
    tester,
  ) async {
    final task = _task(status: 'CANCELLED');
    await _pumpScreen(tester, task);

    expect(find.text('Task Cancelled'), findsOneWidget);
    expect(find.text('Your sent task details'), findsNothing);
    expect(find.text('Cancel Task'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Attachment By you'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Attachment By you'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('matches the supervisor completed task detail state', (
    tester,
  ) async {
    final task = _task(
      status: 'COMPLETED',
      note:
          'Weight scale calibrated using 10kg standard test weight. '
          'Zero-error verified.',
      completedAt: '2026-08-16T06:00:00.000Z',
    );
    await _pumpScreen(tester, task);

    expect(find.textContaining('Completed:'), findsOneWidget);
    expect(find.text('Task Completion Proof'), findsOneWidget);
    expect(find.text('Your sent task details'), findsOneWidget);
    expect(find.text('Task Title'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Attachment By you'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Attachment By you'), findsOneWidget);
    expect(find.text('Cancel Task'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpScreen(WidgetTester tester, TaskModel task) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SupervisorTaskDetailScreen(
        task: task,
        taskLoader: (_) async => task,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

TaskModel _task({
  required String status,
  String? note,
  String? completedAt,
}) => TaskModel(
  id: 'task-1',
  number: 'TSK-001',
  centerId: 'center-1',
  centerName: 'EERL South',
  assignedTo: 'agent-1',
  assignedToName: 'Rahul Patel',
  assignedBy: 'supervisor-1',
  assignedByName: 'Bhavesh Shah',
  title: 'Verify collection details',
  note: note,
  description:
      'Review and verify the latest collection entry submitted by the field '
      'agent. Cross-check the reported collection weight against the verified '
      'weight, inspect all uploaded item photos, and ensure customer details '
      'match the system records before final approval.',
  priority: 'LOW',
  status: status,
  dueAt: '2026-08-16T09:30:00.000Z',
  completedAt: completedAt,
  photoUrls: const [
    'assets/images/collection_detail/pet_collection.png',
    'assets/images/collection_detail/pet_collection.png',
  ],
  createdAt: '2026-08-15T06:00:00.000Z',
  syncState: 'synced',
);
