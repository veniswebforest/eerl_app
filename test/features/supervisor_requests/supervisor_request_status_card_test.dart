import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/supervisor_requests/view/supervisor_completed_request_screen.dart';
import 'package:eerl_app/features/supervisor_requests/widgets/supervisor_request_detail_widgets.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget(Widget child) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );

  testWidgets(
    'SupervisorRequestStatusCard shows awaiting response when not completed',
    (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SupervisorRequestStatusCard(completed: false),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Awaiting Response'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('supervisor-request-awaiting-icon')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'SupervisorRequestStatusCard shows default completed label when time is null or empty',
    (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SupervisorRequestStatusCard(completed: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Completed'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('supervisor-request-completed-icon')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'SupervisorRequestStatusCard formats and displays past completion date time',
    (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          const SupervisorRequestStatusCard(
            completed: true,
            time: '2026-10-25T06:00:00.000Z',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Completed: 25 Oct 2026, 11:30 AM'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('supervisor-request-completed-icon')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'SupervisorCompletedRequestScreen passes answeredAt to status card',
    (tester) async {
      const request = RequestModel(
        id: 'req-1',
        createdBy: 'agent-1',
        createdByName: 'Kiran Rathod',
        body: 'Scale needs replacement.',
        priority: 'HIGH',
        status: 'CLOSED',
        answer: 'Replacement provided.',
        answeredAt: '2026-10-25T06:00:00.000Z',
        photoUrls: [],
        createdAt: '2026-10-24T05:00:00.000Z',
        syncState: 'synced',
      );

      await tester.pumpWidget(
        buildTestWidget(
          const SupervisorCompletedRequestScreen(request: request),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Completed: 25 Oct 2026, 11:30 AM'), findsOneWidget);
    },
  );
}
