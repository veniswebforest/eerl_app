import 'package:eerl_app/features/verification/view/supervisor_verification_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('collection history empty state matches the supervisor design', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SupervisorVerificationScreen(
            loadCollections: () async => const [],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Collection History'), findsOneWidget);
    expect(find.text('Weigh, verify & approve stock'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Verified / Processed'), findsOneWidget);
    expect(find.byKey(const Key('verification-empty-state')), findsOneWidget);
    expect(
      find.byKey(const Key('verification-empty-illustration')),
      findsOneWidget,
    );
    expect(find.text('No Collection History for now'), findsOneWidget);

    final illustration = tester.widget<SvgPicture>(
      find.byKey(const Key('verification-empty-illustration')),
    );
    expect(illustration.width, isNull);
    expect(illustration.height, isNull);

    final illustrationSize = tester.getSize(
      find.byKey(const Key('verification-empty-illustration')),
    );
    expect(illustrationSize.width, closeTo(213, 0.01));
    expect(illustrationSize.height, closeTo(236.348, 0.01));
  });
}
