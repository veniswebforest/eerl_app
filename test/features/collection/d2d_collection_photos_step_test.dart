import 'package:eerl_app/core/providers/bluetooth_weight_provider.dart';
import 'package:eerl_app/features/collection/widgets/d2d_collection_photos_step.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('matches Figma Step 3 rate, conversion and payment details', (
    tester,
  ) async {
    const item = ItemModel(
      id: 'pet',
      name: 'PET Bottles',
      categoryName: 'Plastic',
      materialType: 'PLASTIC',
      unitCode: 'KG',
      unitName: 'Kilogram',
      centreUnitName: 'Bag',
      unitFactor: 25,
      rate: 45,
      ratePerCentreUnit: 1125,
      colour: '#39AE51',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: D2dCollectionPhotosStep(
              weightProvider: BluetoothWeightProvider.instance,
              selectedItems: const [0],
              items: const [item],
              photos: const {},
              collectionWeights: const {0: '11'},
              verifiedWeights: const {0: '11'},
              units: const {0: D2dMeasureUnit.kg},
              paymentMode: D2dPaymentMode.cash,
              onCollectionWeightChanged: (_, _) {},
              onVerifiedWeightChanged: (_, _) {},
              onCapture: (_) {},
              onRemove: (_, _) {},
              onPreview: (_) {},
              onPaymentModeChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Capture all collection photos for review'),
      findsOneWidget,
    );
    expect(find.text('Rate: ₹1,125.00/Bag'), findsOneWidget);
    expect(find.text('Total: ₹12,375.00'), findsOneWidget);
    expect(find.textContaining('PET Bottles  •  Bag (25 kg)'), findsOneWidget);
    expect(
      find.text('1 Bag = 25 KG · 11 Bags = 275.00 KG (₹45.00/KG)'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('d2d-payment-mode')), findsOneWidget);
    expect(find.byKey(const Key('payment-icon-Cash')), findsOneWidget);
    expect(find.byKey(const Key('payment-icon-UPI')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides rate and total when the item has no rate', (tester) async {
    const item = ItemModel(
      id: 'unpriced',
      name: 'Unpriced Item',
      categoryName: 'Plastic',
      materialType: 'PLASTIC',
      unitCode: 'KG',
      unitName: 'Kilogram',
      colour: '#39AE51',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: D2dCollectionPhotosStep(
              weightProvider: BluetoothWeightProvider.instance,
              selectedItems: const [0],
              items: const [item],
              photos: const {},
              collectionWeights: const {0: '10'},
              verifiedWeights: const {0: '10'},
              units: const {0: D2dMeasureUnit.kg},
              paymentMode: D2dPaymentMode.cash,
              onCollectionWeightChanged: (_, _) {},
              onVerifiedWeightChanged: (_, _) {},
              onCapture: (_) {},
              onRemove: (_, _) {},
              onPreview: (_) {},
              onPaymentModeChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Rate:'), findsNothing);
    expect(find.textContaining('Total:'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
