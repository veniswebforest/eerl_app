import 'package:eerl_app/features/verification/view/reject_collection_screen.dart';
import 'package:eerl_app/features/verification/view/verification_detail_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows collection number instead of internal collection id', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RejectCollectionScreen(collectionNumber: 'COL-2026-001'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('#COL-2026-001'), findsOneWidget);
  });

  testWidgets('rejected detail shows reason stored on collection', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: VerificationRejectReasonCard(reason: 'Weight mismatch'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('verification-rejection-reason-value')),
      findsOneWidget,
    );
    expect(find.text('Weight mismatch'), findsOneWidget);
    expect(find.text('No Vehicle Available'), findsNothing);
  });

  testWidgets('Other replaces its label and remarks stay separate', (
    tester,
  ) async {
    CollectionRejectionDecision? result;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await Navigator.of(context).push(
                MaterialPageRoute<CollectionRejectionDecision>(
                  builder: (_) =>
                      const RejectCollectionScreen(collectionNumber: 'COL-001'),
                ),
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('verification-reject-reason-0')),
    );
    await tester.tap(
      find.byKey(const ValueKey('verification-reject-reason-3')),
    );
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('verification-reject-other')),
      'Damaged material',
    );
    await tester.enterText(
      find.byKey(const Key('verification-reject-remarks')),
      'Please recollect tomorrow.',
    );
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('verification-confirm-rejection')));
    await tester.pumpAndSettle();

    expect(result?.reason, 'Weight Mismatch, Damaged material');
    expect(result?.remarks, 'Please recollect tomorrow.');
  });

  testWidgets('rejected detail shows non-empty remarks after the reason', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: VerificationRejectReasonCard(
            reason: 'Weight mismatch',
            remarks: 'Scale was not calibrated.',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Weight mismatch'), findsOneWidget);
    expect(find.text('Scale was not calibrated.'), findsOneWidget);
  });
}
