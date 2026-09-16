import 'package:eerl_app/features/wallet/view/wallet_tab_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('wallet switches between expense and cash request designs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WalletTabScreen(),
      ),
    );

    expect(find.text('Fuel / Diesel'), findsOneWidget);
    expect(find.text('Emergency Fuel'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('expense-type-1')));
    await tester.pumpAndSettle();

    expect(find.text('Fuel / Diesel'), findsNothing);
    expect(find.text('Emergency Fuel'), findsOneWidget);
    expect(find.text('Credited to Wallet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
