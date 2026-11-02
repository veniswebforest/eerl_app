import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/home/widgets/quick_actions.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('pending task badge uses current agent task results', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
            padding: const EdgeInsets.all(20),
            child: QuickActions(
              taskLoader: () async => tasks,
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

    expect(find.byKey(const Key('home-start-collection-card')), findsNothing);
    expect(find.text('View Pending Tasks'), findsOneWidget);
    expect(find.text('Wallet & Log Expense'), findsOneWidget);

    final taskCard = find.byKey(const Key('home-pending-task-card'));
    final walletCard = find.byKey(const Key('home-wallet-expense-card'));
    expect(tester.getSize(taskCard), const Size(335, 166));
    expect(tester.getSize(walletCard), const Size(335, 166));
    expect(
      tester.getSize(find.byKey(const Key('agent-pending-task-count'))),
      const Size(28, 28),
    );
    expect(
      tester.widget<Text>(find.text('View Pending Tasks')).style,
      AppTextStyles.semiboldH7_18.copyWith(color: AppColors.neutral950),
    );

    expect(
      find.descendant(
        of: find.byKey(const Key('agent-pending-task-count')),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
    expect(find.text('3'), findsNothing);

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
