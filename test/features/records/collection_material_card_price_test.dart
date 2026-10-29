import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/records/widgets/collection_material_card.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows dashes when collection prices are hidden', (tester) async {
    const item = CollectionItemModel(
      id: 'line-1',
      collectionId: 'collection-1',
      itemId: 'item-1',
      qty: 10,
      verifiedQty: 9.5,
      photoUrls: [],
      sortOrder: 0,
      name: 'PET Bottles',
      unitCode: 'KG',
      unitName: 'Kilogram',
    );

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CollectionMaterialCard(
            item: item,
            collectionWeightLabel: 'Collected',
            verifiedWeightLabel: 'Verified',
            rateLabel: 'Rate:',
            totalLabel: 'Total:',
            matchSummaryDesign: true,
          ),
        ),
      ),
    );

    expect(find.text('Rate: -'), findsOneWidget);
    expect(find.text('Total: -'), findsOneWidget);
    expect(find.textContaining('₹-'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
