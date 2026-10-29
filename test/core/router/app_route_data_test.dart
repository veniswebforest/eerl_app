import 'package:eerl_app/core/router/app_route_data.dart';
import 'package:eerl_app/features/collection/model/collection_entry_state.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const codec = AppRouteExtraCodec();

  test('restores add collection route data after process death', () {
    const original = AddCollectionRouteData(
      initialStep: CollectionEntryStep.photos,
      initialType: CollectionType.ramp,
      initialSelectedItems: {1, 3},
      collectionId: 'collection-1',
    );

    final restored = codec.decode(codec.encode(original))!;

    expect(restored, isA<AddCollectionRouteData>());
    final data = restored as AddCollectionRouteData;
    expect(data.initialStep, CollectionEntryStep.photos);
    expect(data.initialType, CollectionType.ramp);
    expect(data.initialSelectedItems, {1, 3});
    expect(data.collectionId, 'collection-1');
  });

  test('restores task model used by camera proof screen', () {
    const original = TaskModel(
      id: 'task-1',
      assignedTo: 'agent-1',
      assignedBy: 'supervisor-1',
      title: 'Verify material',
      priority: 'HIGH',
      status: 'PENDING',
      photoUrls: ['https://example.test/photo.jpg'],
      createdAt: '2026-10-29T06:00:00.000Z',
      syncState: 'synced',
    );

    final restored = codec.decode(codec.encode(original))! as TaskModel;

    expect(restored.id, original.id);
    expect(restored.title, original.title);
    expect(restored.photoUrls, original.photoUrls);
    expect(restored.status, original.status);
  });

  test('restores request model used by answer photo screen', () {
    const original = RequestModel(
      id: 'request-1',
      createdBy: 'agent-1',
      body: 'Check scale',
      priority: 'NORMAL',
      status: 'OPEN',
      photoUrls: [],
      createdAt: '2026-10-29T06:00:00.000Z',
      syncState: 'synced',
    );

    final restored = codec.decode(codec.encode(original))! as RequestModel;

    expect(restored.id, original.id);
    expect(restored.body, original.body);
    expect(restored.status, original.status);
  });

  test('restores submitted expense values', () {
    const original = ExpenseSubmittedRouteData(
      amount: 1234.50,
      remainingBalance: 8765.25,
    );

    final restored =
        codec.decode(codec.encode(original))! as ExpenseSubmittedRouteData;

    expect(restored.amount, 1234.50);
    expect(restored.remainingBalance, 8765.25);
  });
}
