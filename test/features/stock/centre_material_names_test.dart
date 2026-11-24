import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/stock/widgets/stock_material_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  StockModel stock({String? localName}) => StockModel(
    id: 's1',
    centerId: 'c1',
    itemId: 'pet',
    stage: 'RM',
    qty: 980,
    name: 'PET Bottles',
    unitCode: 'KG',
    localName: localName,
  );

  testWidgets('stock card: centre name main, standard name under, KG kept', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StockMaterialCard(
            item: stock(localName: 'પીઈટી બોટલ'),
            fallbackImage: 'assets/images/collection_detail/pet_thumbnail.png',
          ),
        ),
      ),
    );
    expect(find.text('પીઈટી બોટલ'), findsOneWidget);
    expect(find.text('PET Bottles'), findsOneWidget);
    expect(find.textContaining("980.00"), findsOneWidget);
    expect(find.textContaining('KG'), findsOneWidget);
  });

  testWidgets('stock card: standard name alone without a centre name', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StockMaterialCard(
            item: stock(),
            fallbackImage: 'assets/images/collection_detail/pet_thumbnail.png',
          ),
        ),
      ),
    );
    expect(find.text('PET Bottles'), findsOneWidget);
  });

  test('transfer item names follow the same rule', () {
    const aliased = TransferItemModel(
      id: 't',
      transferId: 'x',
      itemId: 'pet',
      qty: 1,
      name: 'PET Bottles',
      localName: 'Bottle',
    );
    expect(aliased.displayName, 'Bottle');
    expect(aliased.standardNameBeneathAlias, 'PET Bottles');
  });

  test('document number card: number, "Given after sync", or hidden', () {
    CollectionModel collection({
      String? reference,
      String status = 'SUBMITTED',
      String syncState = 'synced',
    }) => CollectionModel(
      id: 'c',
      centerId: 'c1',
      agentId: 'a',
      agentName: 'A',
      channel: 'D2D',
      status: status,
      referenceNumber: reference,
      handoverPhotoUrls: const [],
      updatedAt: '2026-11-24T00:00:00.000Z',
      syncState: syncState,
    );
    const pending = 'Given after sync';
    expect(
      collection(reference: 'SUR-AAN-2627-COL-0042').documentNumber(pending),
      'SUR-AAN-2627-COL-0042',
    );
    expect(collection(syncState: 'pending').documentNumber(pending), pending);
    expect(collection().documentNumber(pending), isNull);
    expect(
      collection(status: 'DRAFT', syncState: 'pending').documentNumber(pending),
      isNull,
    );
  });
}
