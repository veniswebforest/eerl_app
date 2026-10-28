import 'package:eerl_app/features/verification/view/supervisor_verification_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('supervisor collection filter opens date options', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SupervisorVerificationScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('verification-date-filter')));
    await tester.pumpAndSettle();

    expect(find.text('Filter By Date'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.text('Last 7 days'), findsOneWidget);

    await tester.tap(find.byKey(const Key('verification-date-lastSevenDays')));
    await tester.pumpAndSettle();

    expect(find.text('Filter By Date'), findsNothing);
  });
}
