import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_attention_screens.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('packages/pickup_supervisor/Manrope');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      loader.addFont(rootBundle.load('assets/font/Manrope-$weight.ttf'));
    }
    await loader.load();
  });

  Future<void> pump(
    WidgetTester tester, {
    bool done = false,
    Locale? locale,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('en'), Locale('gu'), Locale('hi')],
        home: PickupSupervisorApprovalRequestsScreen(initialShowDone: done),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('to approve lists two requests with actions', (tester) async {
    await pump(tester);
    expect(find.text('From your drivers and IEC Executives'), findsOneWidget);
    expect(find.text('To approve'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Correction · from driver'), findsOneWidget);
    expect(find.text('Extra pickup'), findsOneWidget);
    expect(find.byKey(const Key('approval-approve')), findsNWidgets(2));
    expect(find.byKey(const Key('approval-decline')), findsNWidgets(2));
  });

  testWidgets('done tab shows approved and declined requests', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('approval-tab-done')));
    await tester.pumpAndSettle();
    expect(find.text('Approved'), findsNWidgets(2));
    expect(find.text('Declined'), findsOneWidget);
    expect(find.text('Start pickups · from IEC'), findsOneWidget);
    expect(find.text('Declined by you 20 Oct'), findsOneWidget);
    expect(find.byKey(const Key('approval-approve')), findsNothing);
  });

  testWidgets('decline opens the reply sheet and cancel closes it', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('approval-decline')).first);
    await tester.pumpAndSettle();
    expect(find.text('Decline the correction'), findsOneWidget);
    expect(
      find.text(
        'The scale photo shows 50 kg. If it was more, ask the gate team to '
        'weigh it again.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('approval-decline-cancel')));
    await tester.pumpAndSettle();
    expect(find.text('Decline the correction'), findsNothing);

    await tester.tap(find.byKey(const Key('approval-decline')).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('approval-decline-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Decline the correction'), findsNothing);
  });

  testWidgets('approve shows the popup and returns to the list', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('approval-approve')).first);
    await tester.pumpAndSettle();
    expect(find.text('Correction approved'), findsOneWidget);
    expect(
      find.text(
        'Hotel Rajdhani’s record now shows PET Bottles 60 kg. '
        'Vikram Singh is told.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('approval-success-back')));
    await tester.pumpAndSettle();
    expect(find.text('Correction approved'), findsNothing);
    expect(
      find.byKey(const Key('supervisor-approval-requests-screen')),
      findsOneWidget,
    );
  });

  for (final entry in {
    'gu': ['મંજૂર કરવાના', 'પૂર્ણ'],
    'hi': ['मंज़ूरी बाकी', 'पूरे'],
  }.entries) {
    testWidgets('approvals use ${entry.key} localization', (tester) async {
      await pump(tester, locale: Locale(entry.key));
      for (final text in entry.value) {
        expect(find.text(text), findsOneWidget);
      }
    });
  }

  testWidgets('every state fits a small phone with large text', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);
    for (final done in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: PickupSupervisorApprovalRequestsScreen(initialShowDone: done),
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
        home: const PickupSupervisorApprovalRequestsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('approval-decline')).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    Navigator.of(tester.element(find.text('Cancel'))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('approval-approve')).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
