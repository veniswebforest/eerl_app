import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:eerl_app/core/providers/locale_provider.dart';
import 'package:eerl_app/features/dashboard/view/main_dashboard_screen.dart';
import 'package:eerl_app/features/wallet/view/expense_submitted_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('Expense submitted screen matches review preview', (
    tester,
  ) async {
    final fontLoader = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/font/Manrope-Regular.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-Medium.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-Bold.ttf'));
    await fontLoader.load();
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainDashboardScreen(initialPageKey: 'wallet'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Log Expense'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('expense-category-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fuel / Diesel').last);
    await tester.enterText(find.byType(TextField).first, '1000');
    await tester.tap(find.byKey(const Key('capture-receipt-button')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('submit-expense-button')));
    await tester.pumpAndSettle();

    expect(find.byType(ExpenseSubmittedScreen), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('expense_submitted_preview.png'),
    );
  });
}
