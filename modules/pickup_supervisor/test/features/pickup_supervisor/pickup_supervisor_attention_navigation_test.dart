import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_attention_screens.dart';
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

  testWidgets('see suggestions quick action opens suggestions design', (
    tester,
  ) async {
    await pumpHome(tester);

    final suggestionsButton = find.byKey(
      const Key('supervisor-quick-action-See suggestions'),
    );
    await tester.scrollUntilVisible(
      suggestionsButton,
      500,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('supervisor-home-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(suggestionsButton);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('supervisor-suggestions-screen')),
      findsOneWidget,
    );
    expect(find.text('Suggestions'), findsOneWidget);
    expect(find.text('All 3'), findsOneWidget);
  });

  testWidgets('attention screens can be constructed directly', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: PickupSupervisorIssueDetailScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Reason : No Vehicle Available'), findsOneWidget);
  });
}
