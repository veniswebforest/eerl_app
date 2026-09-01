import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eerl_app/features/transfer_requests/view/create_transfer_request_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('Create transfer submits directly without destination step', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CreateTransferRequestScreen(onBack: _noop, onBackToList: _noop),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Submit Request'), findsOneWidget);
    expect(find.text('Select Destination'), findsNothing);

    await tester.tap(find.byKey(const Key('transfer-continue')));
    await tester.pumpAndSettle();

    expect(find.text('Your request submitted Successfully!'), findsOneWidget);
    expect(find.text('Select Destination'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
