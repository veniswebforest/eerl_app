import 'package:eerl_app/core/providers/locale_provider.dart';
import 'package:eerl_app/features/dashboard/view/main_dashboard_screen.dart';
import 'package:eerl_app/features/wallet/view/request_cash_screen.dart';
import 'package:eerl_app/features/wallet/view/wallet_tab_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Request Cash manages empty, filled and success states', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainDashboardScreen(initialPageKey: 'wallet'),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('wallet-request-cash-button')));
    await tester.pumpAndSettle();
    expect(find.byType(RequestCashScreen), findsOneWidget);

    final submit = find.byKey(const Key('submit-cash-request'));
    expect(tester.widget<ElevatedButton>(submit).onPressed, isNull);

    await tester.enterText(find.byType(TextField).first, '1000');
    await tester.tap(find.byKey(const Key('cash-reason-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cash-reason-option-0')));
    await tester.pumpAndSettle();

    expect(tester.widget<ElevatedButton>(submit).onPressed, isNotNull);
    await tester.tap(submit);
    await tester.pumpAndSettle();
    expect(find.text('Request Submitted!'), findsOneWidget);
    expect(find.textContaining('₹ 1000'), findsOneWidget);

    await tester.tap(find.byKey(const Key('cash-request-back-to-wallet')));
    await tester.pumpAndSettle();
    expect(find.byType(WalletTabScreen), findsOneWidget);
    expect(find.byType(RequestCashScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Request Cash is responsive in Gujarati at 320px', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('gu'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RequestCashScreen(onBack: _noop, onBackToWallet: _noop),
      ),
    );

    await tester.tap(find.byKey(const Key('cash-reason-selector')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
