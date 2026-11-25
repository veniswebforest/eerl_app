import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/issues/model/issue_mock_data.dart';
import 'package:pickup_supervisor/features/issues/view/issue_detail_screen.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_home_screen.dart';

void main() {
  Future<void> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(home: PickupSupervisorHomeScreen()),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('approval tile opens requests and approve shows confirmation', (
    tester,
  ) async {
    await pumpHome(tester);

    await tester.tap(find.text('Approvals'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('supervisor-approval-requests-screen')),
      findsOneWidget,
    );

    await tester.tap(find.text('Approve').first);
    await tester.pumpAndSettle();
    expect(find.text('Correction approved'), findsOneWidget);
    expect(find.text('Back to approval requests'), findsOneWidget);
  });

  testWidgets('my requests tile opens localized filter screen', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('My requests'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('supervisor-my-requests-screen')),
      findsOneWidget,
    );
    expect(find.text('All 4'), findsOneWidget);
    expect(find.text('Vehicle · Adajan Morning'), findsOneWidget);
  });

  testWidgets('issues tile opens list and first issue opens detail', (
    tester,
  ) async {
    await pumpHome(tester);

    await tester.tap(find.text('Issues'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('supervisor-issues-screen')), findsOneWidget);

    await tester.tap(find.text('Vehicle breakdown').first);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('supervisor-issue-detail-screen')),
      findsOneWidget,
    );
    expect(find.text('GJ-05-BX-1234'), findsOneWidget);
  });

  testWidgets('view sources quick action opens the sources screen', (
    tester,
  ) async {
    await pumpHome(tester);

    final viewSources = find.byKey(
      const Key('supervisor-quick-action-View sources'),
    );
    await tester.scrollUntilVisible(
      viewSources,
      500,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('supervisor-home-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(viewSources);
    await tester.pumpAndSettle();
    expect(find.text('Unassigned sources'), findsWidgets);
    expect(find.byKey(const Key('supervisor-home-screen')), findsNothing);
  });

  testWidgets('attention screens can be constructed directly', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: PickupSupervisorIssueDetailScreen(
          issue: IssueMockData.issues.first,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Reason for Issue'), findsOneWidget);
  });
}
