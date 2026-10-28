import 'package:eerl_app/features/collection/widgets/collection_draft_saved_notification.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:eerl_app/shared/widgets/app_snackbar.dart';
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

  testWidgets('collection draft success uses the shared two-second overlay', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => showCollectionDraftSavedNotification(context),
              child: const Text('Save draft'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Save draft'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const Key('collection-draft-saved-notification')),
      findsOneWidget,
    );
    expect(find.text('Draft Saved!'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.byKey(const Key('collection-draft-saved-notification')),
      findsNothing,
    );
  });

  testWidgets('snackbar helper always displays title and subtitle', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => AppSnackbar.error(
                context,
                message: 'Unable to save the task.',
              ),
              child: const Text('Show error'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show error'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Error'), findsOneWidget);
    expect(find.text('Unable to save the task.'), findsOneWidget);
  });
}
