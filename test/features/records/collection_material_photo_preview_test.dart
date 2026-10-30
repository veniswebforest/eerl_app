import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/records/widgets/collection_material_card.dart';
import 'package:eerl_app/shared/widgets/app_image_preview_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const photo = 'assets/images/collection_detail/figma/raw_01.png';
  const item = CollectionItemModel(
    id: 'line-1',
    collectionId: 'collection-1',
    itemId: 'item-1',
    qty: 10,
    photoUrls: [photo],
    sortOrder: 0,
    name: 'PET',
    unitCode: 'KG',
    itemImageUrl: photo,
  );

  testWidgets('thumbnail and proof photo both open the common full preview', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Builder(
              builder: (context) => CollectionMaterialCard(
                item: item,
                thumbnailPath: photo,
                collectionWeightLabel: 'Collected',
                verifiedWeightLabel: 'Verified',
                rateLabel: 'Rate',
                totalLabel: 'Total',
                onPhotoTap: (source) =>
                    AppImagePreviewDialog.showSource(context, source),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('collection-material-thumbnail-$photo')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('app-image-preview-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('app-image-preview-close')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('collection-material-photo-$photo')),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('app-image-preview-dialog')), findsOneWidget);
  });
}
