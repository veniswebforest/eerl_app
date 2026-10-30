import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/wallet/view/log_expense_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('amount above wallet balance shows an error and blocks submit', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LogExpenseScreen(
          initialCategories: const [
            ExpenseCategoryModel(
              id: 'category-1',
              centerId: 'center-1',
              name: 'Fuel',
              isActive: true,
            ),
          ],
          walletBalanceLoader: () async => 100,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '150');
    await tester.pump();

    expect(
      find.text(
        'Amount cannot exceed the available wallet balance of ₹100.00.',
      ),
      findsOneWidget,
    );
    final submit = tester.widget<ElevatedButton>(
      find.byKey(const Key('submit-expense-button')),
    );
    expect(submit.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
