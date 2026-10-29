import 'package:eerl_app/features/wallet/view/expense_submitted_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the submitted amount and updated wallet balance', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ExpenseSubmittedScreen(
          amount: 1234.50,
          remainingBalance: 8765.25,
        ),
      ),
    );

    expect(
      find.text('₹1,234.50 deducted from your wallet balance.'),
      findsOneWidget,
    );
    expect(find.text('Remaining Balance: ₹8,765.25'), findsOneWidget);
    expect(find.textContaining('₹350'), findsNothing);
    expect(find.textContaining('₹4,850'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not crash for a stale dialog restored without amount', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ExpenseSubmittedScreen(amount: null),
      ),
    );

    expect(find.text('Expense Submitted!'), findsOneWidget);
    expect(find.textContaining('deducted from your wallet'), findsNothing);
    expect(find.byKey(const Key('expense-back-to-wallet')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
