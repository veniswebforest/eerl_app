import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/transfer_requests/view/transfer_requests_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildScreen(String role) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: TransferRequestsScreen(
      roleLoader: () async => role,
      transferLoader: () async => <TransferModel>[],
    ),
  );

  testWidgets('hides create button for supervisor role', (tester) async {
    await tester.pumpWidget(buildScreen('SUPERVISOR'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('transfer-request-add')), findsNothing);
  });

  testWidgets('shows create button for agent role', (tester) async {
    await tester.pumpWidget(buildScreen('AGENT'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('transfer-request-add')), findsOneWidget);
  });
}
