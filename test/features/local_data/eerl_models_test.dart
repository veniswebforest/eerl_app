import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ItemModel maps exact SQLite snake_case keys', () {
    final item = ItemModel.fromMap(const {
      'id': 'item-1',
      'name': 'PET',
      'category_name': 'Plastic',
      'material_type': 'PLASTIC',
      'colour': 'Clear',
      'hsn_code': '3915',
      'unit_code': 'KG',
      'unit_name': 'Kilogram',
      'rate': 18.5,
      'is_selected': 1,
      'sort_order': 2,
    });

    expect(item.categoryName, 'Plastic');
    expect(item.isSelected, isTrue);
    expect(item.sortOrder, 2);
    expect(item.toMap()['unit_code'], 'KG');
  });

  test('CollectionModel decodes booleans and JSON photo arrays', () {
    final collection = CollectionModel.fromMap(const {
      'id': 'collection-1',
      'center_id': 'center-1',
      'agent_id': 'user-1',
      'agent_name': 'Agent',
      'channel': 'D2D',
      'status': 'APPROVED',
      'takes_payment': 1,
      'total_amount': 42.5,
      'handover_photo_urls': '["https://example.test/photo.jpg"]',
      'updated_at': '2026-10-02T00:00:00.000Z',
      'sync_state': 'synced',
      'total_qty': 12.5,
      'item_count': 2,
    });

    expect(collection.takesPayment, isTrue);
    expect(collection.handoverPhotoUrls, hasLength(1));
    expect(collection.totalQty, 12.5);
    expect(collection.toMap()['agent_name'], 'Agent');
  });

  test('RagpickerModel preserves nullable server fields', () {
    final ragpicker = RagpickerModel.fromMap(const {
      'id': 'ragpicker-1',
      'center_id': 'center-1',
      'name': 'Worker',
      'phone': null,
      'id_number': null,
      'photo_url': null,
      'is_active': 0,
      'sync_state': 'synced',
    });

    expect(ragpicker.phone, isNull);
    expect(ragpicker.isActive, isFalse);
    expect(ragpicker.toMap()['is_active'], 0);
  });
}
