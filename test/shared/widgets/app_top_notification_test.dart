import 'package:eerl_app/shared/widgets/app_top_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'shows above the screen without layout shift and hides after two seconds',
    (tester) async {
      const markerKey = Key('screen-layout-marker');
      const notificationKey = Key('top-notification');

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  const SizedBox(key: markerKey, width: 100, height: 80),
                  ElevatedButton(
                    onPressed: () => AppTopNotification.show(
                      context,
                      key: notificationKey,
                      title: 'Vehicle Deactivated!',
                      subtitle: 'SMC vehicle removed from active list.',
                      tone: AppTopNotificationTone.error,
                    ),
                    child: const Text('Show'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final markerBefore = tester.getTopLeft(find.byKey(markerKey));
      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(notificationKey), findsOneWidget);
      expect(tester.getTopLeft(find.byKey(markerKey)), markerBefore);

      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byKey(notificationKey), findsNothing);
      expect(tester.getTopLeft(find.byKey(markerKey)), markerBefore);
    },
  );
}
