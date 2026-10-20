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
}
