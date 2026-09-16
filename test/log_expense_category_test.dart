import 'package:eerl_app/features/wallet/view/log_expense_screen.dart';
import 'package:eerl_app/features/wallet/widgets/request_new_expense_category_dialog.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Log Expense opens the Figma category panel and request dialog', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const Locale('en')));

    expect(find.text('Expense Reason'), findsOneWidget);
    await tester.tap(find.byKey(const Key('expense-category-selector')));
    await tester.pumpAndSettle();

    expect(find.text('Request New Category'), findsOneWidget);
    expect(find.byKey(const ValueKey('expense-category-0')), findsOneWidget);

    await tester.tap(find.byKey(const Key('request-new-expense-category')));
    await tester.pumpAndSettle();

    expect(find.byType(RequestNewExpenseCategoryDialog), findsOneWidget);
    expect(find.text('Category Name'), findsOneWidget);
    expect(find.text('Reason/Description'), findsOneWidget);
    expect(find.text('Max 150 Characters'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(RequestNewExpenseCategoryDialog), findsNothing);
  });

  testWidgets(
    'category request dialog is responsive and localized in Gujarati',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_app(const Locale('gu')));
      await tester.tap(find.byKey(const Key('expense-category-selector')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('request-new-expense-category')));
      await tester.pumpAndSettle();

      expect(find.text('નવી શ્રેણીની વિનંતી કરો'), findsOneWidget);
      expect(find.text('શ્રેણીનું નામ'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _app(Locale locale) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: LogExpenseScreen(onBack: _noop),
);

void _noop() {}
