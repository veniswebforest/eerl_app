import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/shared/widgets/app_required_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('colors only a trailing required asterisk red', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppRequiredText(
            'Mobile Number *',
            key: Key('required-label'),
            style: TextStyle(color: AppColors.neutral950),
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('required-label')),
        matching: find.byType(Text),
      ),
    );
    final root = text.textSpan! as TextSpan;
    final asterisk = root.children!.single as TextSpan;

    expect(root.text, 'Mobile Number');
    expect(asterisk.text, ' *');
    expect(asterisk.style?.color, AppColors.red600);
    expect(text.style?.color, AppColors.neutral950);
  });
}
