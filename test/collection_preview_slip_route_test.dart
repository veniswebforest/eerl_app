import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eerl_app/features/collection/view/collection_receipt_screen.dart';
import 'package:eerl_app/features/records/model/collection_detail_status.dart';
import 'package:eerl_app/features/records/view/collection_detail_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('Collection detail Preview Slip opens receipt route', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CollectionDetailScreen(
          status: CollectionDetailStatus.approved,
          onBack: _noop,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -3000),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('collection-detail-preview-slip')));
    await tester.pumpAndSettle();

    expect(find.byType(CollectionReceiptScreen), findsOneWidget);
    expect(find.text('RCP-2026-000245'), findsOneWidget);

    await tester.tap(find.byKey(const Key('collection-receipt-back')));
    await tester.pumpAndSettle();
    expect(find.byType(CollectionDetailScreen), findsOneWidget);
    expect(find.byType(CollectionReceiptScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
