import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/issues/model/issue_mock_data.dart';
import 'package:pickup_supervisor/features/issues/view/issue_detail_screen.dart';
import 'package:pickup_supervisor/features/issues/view/issues_screen.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_dashboard_shell.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('packages/pickup_supervisor/Manrope');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      loader.addFont(rootBundle.load('assets/font/Manrope-$weight.ttf'));
    }
    await loader.load();
  });

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    Locale? locale,
    Size size = const Size(375, 900),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('en'), Locale('gu'), Locale('hi')],
        home: home,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> closeToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  }

  testWidgets('list shows the three issues with their states', (tester) async {
    await pump(tester, const PickupSupervisorIssuesScreen());
    expect(find.text('Issues'), findsOneWidget);
    expect(find.text('Ramesh Ahir (Driver)'), findsOneWidget);
    expect(find.text('Problem at the source'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Escalated'), findsOneWidget);
    expect(find.text('Resolved'), findsOneWidget);
    expect(find.text('Raised 10:42 AM'), findsOneWidget);
  });

  testWidgets('open issue: resolve sheet, cancel, then resolve', (
    tester,
  ) async {
    await pump(tester, const PickupSupervisorIssuesScreen());
    await tester.tap(find.byKey(const Key('issue-card-issue-ramesh')));
    await tester.pumpAndSettle();
    expect(find.text('GJ-05-BX-1234'), findsOneWidget);
    expect(find.text('•  Ramesh Ahir'), findsOneWidget);
    expect(find.byKey(const Key('issue-escalate')), findsOneWidget);

    await tester.tap(find.byKey(const Key('issue-mark-resolved')));
    await tester.pumpAndSettle();
    expect(find.text('Mark as resolved'), findsOneWidget);
    await tester.tap(find.byKey(const Key('issue-resolve-cancel')));
    await tester.pumpAndSettle();
    expect(find.text('Mark as resolved'), findsNothing);

    await tester.tap(find.byKey(const Key('issue-mark-resolved')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('issue-resolve-text')),
      'Sent the spare van.',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('issue-resolve-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Issue Resolved!'), findsOneWidget);
    expect(find.text('Ramesh Ahir is told.'), findsOneWidget);
    expect(find.byKey(const Key('issue-resolved-card')), findsOneWidget);
    expect(find.byKey(const Key('issue-mark-resolved')), findsNothing);
    await closeToast(tester);

    // Back on the list the issue shows as resolved.
    await tester.tap(find.byKey(const Key('module-back-button')));
    await tester.pumpAndSettle();
    expect(find.text('Open'), findsNothing);
    expect(find.text('Resolved'), findsNWidgets(2));
  });

  testWidgets('escalate popup: cancel, then escalate', (tester) async {
    await pump(
      tester,
      PickupSupervisorIssueDetailScreen(issue: IssueMockData.issues.first),
    );
    await tester.tap(find.byKey(const Key('issue-escalate')));
    await tester.pumpAndSettle();
    expect(find.text('Escalate this issue?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('issue-escalate-cancel')));
    await tester.pumpAndSettle();
    expect(find.text('Escalate this issue?'), findsNothing);

    await tester.tap(find.byKey(const Key('issue-escalate')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('issue-escalate-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Issue Escalated!'), findsOneWidget);
    expect(find.byKey(const Key('issue-escalated-card')), findsOneWidget);
    expect(find.byKey(const Key('issue-escalate')), findsNothing);
    expect(find.byKey(const Key('issue-mark-resolved')), findsOneWidget);
    await closeToast(tester);
  });

  testWidgets('escalated and resolved issues show their cards', (tester) async {
    await pump(
      tester,
      PickupSupervisorIssueDetailScreen(issue: IssueMockData.issues[1]),
    );
    expect(find.byKey(const Key('issue-escalated-card')), findsOneWidget);
    await pump(
      tester,
      PickupSupervisorIssueDetailScreen(issue: IssueMockData.issues[2]),
    );
    expect(find.byKey(const Key('issue-resolved-card')), findsOneWidget);
    expect(find.byKey(const Key('issue-mark-resolved')), findsNothing);
  });

  testWidgets('drawer Issues opens the list', (tester) async {
    await pump(tester, const PickupSupervisorDashboardShell());
    await tester.tap(find.byKey(const Key('supervisor-menu-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('supervisor-drawer-issues')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('supervisor-issues-screen')), findsOneWidget);
  });

  for (final entry in {
    'gu': ['ખુલ્લું', 'સ્રોત પર સમસ્યા'],
    'hi': ['खुला', 'स्रोत पर समस्या'],
  }.entries) {
    testWidgets('issues use ${entry.key} localization', (tester) async {
      await pump(
        tester,
        const PickupSupervisorIssuesScreen(),
        locale: Locale(entry.key),
      );
      expect(find.text(entry.value.first), findsOneWidget);
      expect(find.text(entry.value.last), findsOneWidget);
    });
  }

  testWidgets('screens fit a small phone with large text', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);
    for (final screen in <Widget>[
      const PickupSupervisorIssuesScreen(),
      for (final issue in IssueMockData.issues)
        PickupSupervisorIssueDetailScreen(issue: issue),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: screen,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: PickupSupervisorIssueDetailScreen(
          issue: IssueMockData.issues.first,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('issue-mark-resolved')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
