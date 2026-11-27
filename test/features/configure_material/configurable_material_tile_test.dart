import 'package:eerl_app/features/configure_material/widgets/configurable_material_tile.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpTile(WidgetTester tester, Widget tile) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReorderableListView(
            onReorderItem: (_, _) {},
            children: [KeyedSubtree(key: const ValueKey('t'), child: tile)],
          ),
        ),
      ),
    );
  }

  testWidgets('local name is the title, the item name the subtitle', (
    tester,
  ) async {
    await pumpTile(
      tester,
      ConfigurableMaterialTile(
        index: 0,
        label: 'Plastic Bottle (Local)',
        subtitle: 'PET Bottles',
        selected: true,
        onSelected: (_) {},
      ),
    );
    expect(
      tester
          .widget<Text>(find.byKey(const Key('configure-material-title-0')))
          .data,
      'Plastic Bottle (Local)',
    );
    expect(
      tester
          .widget<Text>(find.byKey(const Key('configure-material-subtitle-0')))
          .data,
      'PET Bottles',
    );
  });

  testWidgets('without a local name only the item name shows', (tester) async {
    await pumpTile(
      tester,
      ConfigurableMaterialTile(
        index: 0,
        label: 'PET Bottles',
        selected: false,
        onSelected: (_) {},
      ),
    );
    expect(find.text('PET Bottles'), findsOneWidget);
    expect(
      find.byKey(const Key('configure-material-subtitle-0')),
      findsNothing,
    );
  });

  test('displayName falls back to the items-table name', () {
    ItemModel item(String? local) => ItemModel.fromMap({
      'id': 'i1',
      'name': 'PET Bottles',
      'category_name': 'Plastic',
      'material_type': 'PLASTIC',
      'unit_code': 'KG',
      'unit_name': 'Kilogram',
      'is_active': 1,
      'local_name': local,
    });
    expect(item('Bottle').displayName, 'Bottle');
    expect(item(null).displayName, 'PET Bottles');
    expect(item('  ').displayName, 'PET Bottles');
  });
}
