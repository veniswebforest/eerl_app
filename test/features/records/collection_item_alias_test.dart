import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/records/widgets/collection_material_card.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CollectionItemModel item({String? localName}) => CollectionItemModel(
    id: 'i1',
    collectionId: 'c1',
    itemId: 'pp',
    qty: 270,
    photoUrls: const [],
    sortOrder: 0,
    name: 'PP Hard Plastics',
    localName: localName,
  );

  test('alias becomes the main name, standard name goes beneath', () {
    final aliased = item(localName: 'Hard plastic (PP)');
    expect(aliased.displayName, 'Hard plastic (PP)');
    expect(aliased.standardNameBeneathAlias, 'PP Hard Plastics');
    final plain = item();
    expect(plain.displayName, 'PP Hard Plastics');
    expect(plain.standardNameBeneathAlias, isNull);
  });

  testWidgets('material card shows both names when an alias exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CollectionMaterialCard(
            item: item(localName: 'Hard plastic (PP)'),
            collectionWeightLabel: 'Collected',
            verifiedWeightLabel: 'Verified',
            rateLabel: 'Rate',
            totalLabel: 'Total',
          ),
        ),
      ),
    );
    expect(find.text('Hard plastic (PP)'), findsOneWidget);
    expect(find.text('PP Hard Plastics'), findsOneWidget);
  });
}
