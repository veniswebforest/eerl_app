import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/supervisor/view/supervisor_flags_screens.dart';
import 'package:pickup_supervisor/supervisor/view/supervisor_home_screen.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pumpAndSettle();
  }

  testWidgets('Flags attention tile opens the populated Figma list', (
    tester,
  ) async {
    await pumpScreen(tester, const SupervisorHomeScreen());

    final scroll = find.byKey(const Key('supervisor-home-scroll'));
    await tester.drag(scroll, const Offset(0, -280));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('supervisor-attention-Flags')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('supervisor-flags-list')), findsOneWidget);
    expect(find.text('Time clash'), findsOneWidget);
    expect(find.text('Source moved to you'), findsOneWidget);
  });

  testWidgets('Flags empty state matches the selected empty frame', (
    tester,
  ) async {
    await pumpScreen(tester, const SupervisorFlagsScreen(showEmpty: true));

    expect(find.byKey(const Key('supervisor-flags-empty')), findsOneWidget);
    expect(find.text('Nothing to check!'), findsOneWidget);
    expect(
      find.text(
        'You don’t have any new notifications or pending action items right now.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Schedule changed flag opens its detail design', (tester) async {
    await pumpScreen(tester, const SupervisorFlagsScreen());

    await tester.tap(find.text('Schedule changed'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('supervisor-flag-detail-scheduleChanged')),
      findsOneWidget,
    );
    expect(find.text('Mon, Thu · 8–10 am'), findsOneWidget);
    expect(find.text('Check route'), findsOneWidget);
  });

  testWidgets('Source paused flag opens the single-action detail design', (
    tester,
  ) async {
    await pumpScreen(tester, const SupervisorFlagsScreen());

    await tester.tap(find.text('Source paused'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('supervisor-flag-detail-sourcePaused')),
      findsOneWidget,
    );
    expect(find.text('Paused 20–26 Oct'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('No-route and moved variants render all selected states', (
    tester,
  ) async {
    const states = <SupervisorFlagDetailType, String>{
      SupervisorFlagDetailType.newSource: 'New source, no route',
      SupervisorFlagDetailType.extraPickup: 'Extra pickup, no route',
      SupervisorFlagDetailType.sourceMoved: 'Moved from Vesu area',
    };

    for (final entry in states.entries) {
      await tester.pumpWidget(
        MaterialApp(home: SupervisorFlagDetailScreen(type: entry.key)),
      );
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      expect(find.text('Mark done'), findsOneWidget);
    }
  });
}
