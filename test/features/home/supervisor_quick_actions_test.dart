import 'package:eerl_app/features/home/widgets/supervisor_quick_actions.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('assigned task summary uses task table results', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: SupervisorQuickActions(
              taskLoader: () async => [
                _task('pending-1', 'PENDING'),
                _task('pending-2', 'PENDING'),
                _task('completed-1', 'COMPLETED'),
                _task('closed-1', 'CLOSED'),
                _task('cancelled-1', 'CANCELLED'),
              ],
              expenseLoader: () async => [
                _expense('pending-1', 'PENDING'),
                _expense('pending-2', 'WAITING_SUPERVISOR'),
                _expense('pending-3', 'PENDING_REVIEW'),
                _expense('approved-1', 'APPROVED'),
                _expense('rejected-1', 'REJECTED'),
              ],
              onAssignTaskTap: () async {},
              onAgentsStatusTap: () {},
              onCheckStockTap: () {},
              onApprovalsTap: () async {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('supervisor-pending-task-count')),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('supervisor-completed-task-count')),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
    expect(find.text('03'), findsNothing);
    expect(find.text('05'), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('supervisor-approvals-card')),
        matching: find.text('3'),
      ),
      findsOneWidget,
    );
    expect(find.text('12'), findsNothing);
  });
}

TaskModel _task(String id, String status) => TaskModel(
  id: id,
  assignedTo: 'agent-id',
  assignedBy: 'supervisor-id',
  title: 'Task $id',
  priority: 'NORMAL',
  status: status,
  photoUrls: const [],
  createdAt: '2026-10-26T00:00:00.000Z',
  syncState: 'synced',
);

ExpenseModel _expense(String id, String status) => ExpenseModel(
  id: id,
  centerId: 'center-id',
  userId: 'agent-id',
  categoryId: 'category-id',
  amount: 100,
  status: status,
  receiptPhotoUrls: const [],
  createdAt: '2026-10-26T00:00:00.000Z',
  syncState: 'synced',
);
