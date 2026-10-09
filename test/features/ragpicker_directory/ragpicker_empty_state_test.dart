import 'package:eerl_app/features/ragpicker_directory/widgets/ragpicker_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('matches the ragpicker directory empty-state geometry', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RagpickerEmptyState(message: 'No Ragpicker Details Found'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('No Ragpicker Details Found'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('ragpicker-empty-illustration'))),
      const Size(174, 170),
    );
  });
}
