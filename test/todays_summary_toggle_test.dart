import 'package:eerl_app/features/home/widgets/todays_summary.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Today summary eye toggles summary cards', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Padding(padding: EdgeInsets.all(20), child: TodaysSummary()),
        ),
      ),
    );

    const toggleKey = Key('home-toggle-todays-summary');
    const summaryCardKey = Key('home-wallet-summary-card');

    expect(find.byKey(summaryCardKey), findsOneWidget);

    await tester.tap(find.byKey(toggleKey));
    await tester.pumpAndSettle();
    expect(find.byKey(summaryCardKey), findsNothing);

    await tester.tap(find.byKey(toggleKey));
    await tester.pumpAndSettle();
    expect(find.byKey(summaryCardKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
