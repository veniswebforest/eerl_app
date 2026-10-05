import 'package:eerl_app/features/collection/widgets/d2d_waste_items_step.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('filters real materials by type and shows live tab counts', (
    tester,
  ) async {
    var showPlastic = true;
    final selected = <int>{};
    const items = [
      ItemModel(
        id: 'plastic-1',
        name: 'PET Bottle',
        categoryName: 'Plastic',
        materialType: 'PLASTIC',
        colour: '#AFB4F1',
        unitCode: 'KG',
        unitName: 'Kilogram',
      ),
      ItemModel(
        id: 'paper-1',
        name: 'Cardboard',
        categoryName: 'Other',
        materialType: 'NON_PLASTIC',
        colour: '#FFF8D2',
        unitCode: 'PCS',
        unitName: 'Pieces',
      ),
      ItemModel(
        id: 'plastic-2',
        name: 'HDPE',
        categoryName: 'Plastic',
        materialType: 'plastic',
        colour: '#96FFF4',
        unitCode: 'KG',
        unitName: 'Kilogram',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: D2dWasteItemsStep(
                items: items,
                selectedItems: selected,
                isOpen: true,
                showPlasticItems: showPlastic,
                onSelectorTap: () {},
                onCategoryChanged: (value) => setState(() {
                  showPlastic = value;
                }),
                onItemChanged: (index) => setState(() {
                  if (!selected.add(index)) selected.remove(index);
                }),
                onDone: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Plastic (2)'), findsOneWidget);
    expect(find.text('Non-Plastic (1)'), findsOneWidget);
    expect(find.text('PET Bottle'), findsOneWidget);
    expect(find.text('HDPE'), findsOneWidget);
    expect(find.text('Cardboard'), findsNothing);

    await tester.tap(find.text('Non-Plastic (1)'));
    await tester.pump();

    expect(find.text('PET Bottle'), findsNothing);
    expect(find.text('HDPE'), findsNothing);
    expect(find.text('Cardboard'), findsOneWidget);

    await tester.tap(find.byKey(const Key('d2d-waste-item-1')));
    await tester.pump();
    expect(find.text('1 Items Selected'), findsOneWidget);
  });
}
