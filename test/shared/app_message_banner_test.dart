import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/shared/widgets/app_message_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('expands past its design height when scaled text needs room', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: const Scaffold(
            body: Center(
              child: SizedBox(
                width: 350,
                child: AppMessageBanner(
                  title: 'Expense Request Rejected',
                  subtitle: 'Expense request rejected successfully',
                  color: AppColors.red500,
                  height: 78,
                  icon: Icon(Icons.block_rounded),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(AppMessageBanner)).height,
      greaterThanOrEqualTo(78),
    );
  });

  testWidgets(
    'AppMessageBanner automatically calls onClose and hides after 3 seconds',
    (tester) async {
      var closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppMessageBanner(
              title: 'Task Cancelled',
              subtitle: 'Task has been cancelled successfully',
              color: AppColors.red500,
              icon: const Icon(Icons.close),
              onClose: () => closed = true,
            ),
          ),
        ),
      );

      expect(find.text('Task Cancelled'), findsOneWidget);
      expect(closed, isFalse);

      // Fast forward 3 seconds
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
      expect(find.text('Task Cancelled'), findsNothing);
    },
  );

  testWidgets('AppMessageBanner with autoDismiss: false stays visible', (
    tester,
  ) async {
    var closed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppMessageBanner(
            title: 'Static Info',
            subtitle: 'This is a persistent banner',
            color: AppColors.primary500,
            icon: const Icon(Icons.info),
            autoDismiss: false,
            onClose: () => closed = true,
          ),
        ),
      ),
    );

    expect(find.text('Static Info'), findsOneWidget);

    // Fast forward 3 seconds
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(closed, isFalse);
    expect(find.text('Static Info'), findsOneWidget);
  });
}
