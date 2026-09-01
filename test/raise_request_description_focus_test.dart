import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/features/requests/view/raise_request_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('Description border changes on focus and unfocus', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RaiseRequestScreen(onBack: _noop),
      ),
    );
    await tester.pumpAndSettle();

    expect(_borderColor(tester), AppColors.cool400);

    await tester.tap(find.byKey(const Key('request-description-field')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(_borderColor(tester), AppColors.primary400);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 200));
    expect(_borderColor(tester), AppColors.cool400);
    expect(tester.takeException(), isNull);
  });
}

Color _borderColor(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(
    find.byKey(const Key('request-description-container')),
  );
  final decoration = container.decoration! as BoxDecoration;
  return decoration.border!.top.color;
}

void _noop() {}
