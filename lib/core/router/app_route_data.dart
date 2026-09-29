import 'package:eerl_app/features/collection/model/collection_entry_state.dart';

/// Typed input for the multi-step Add Collection route.
class AddCollectionRouteData {
  const AddCollectionRouteData({
    this.initialStep = CollectionEntryStep.items,
    this.initialType,
    this.initialSelectedItems = const <int>{},
  });

  final CollectionEntryStep initialStep;
  final CollectionType? initialType;
  final Set<int> initialSelectedItems;
}
