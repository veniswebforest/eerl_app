import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/shared/widgets/app_mobile_number_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a fixed country code and accepts only 10 digits', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: AppMobileNumberField(
              controller: controller,
              hintText: 'Enter mobile number',
              countryCodeKey: const Key('country-code'),
              phoneFieldKey: const Key('phone-field'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('+91'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('country-code'))),
      const Size(72, 56),
    );

    await tester.enterText(
      find.byKey(const Key('phone-field')),
      '12ab345678901',
    );
    expect(controller.text, '1234567890');
  });

  testWidgets('uses the primary border for both boxes while focused', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: AppMobileNumberField(
              controller: controller,
              countryCodeKey: const Key('country-code'),
              phoneFieldKey: const Key('phone-field'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('phone-field')));
    await tester.pump(const Duration(milliseconds: 200));

    final countryCode = tester.widget<AnimatedContainer>(
      find.byKey(const Key('country-code')),
    );
    final decoration = countryCode.decoration! as BoxDecoration;
    expect(decoration.border!.top.color, AppColors.primary500);

    final phoneField = tester.widget<TextField>(
      find.byKey(const Key('phone-field')),
    );
    final focusedBorder =
        phoneField.decoration!.focusedBorder! as OutlineInputBorder;
    expect(focusedBorder.borderSide.color, AppColors.primary500);
  });
}
