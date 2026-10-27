import 'package:eerl_app/features/collection/model/collection_entry_state.dart';
import 'package:eerl_app/features/dashboard/model/bottom_nav_item_model.dart';

/// Typed input for the dashboard route after a successful login.
class HomeRouteData {
  const HomeRouteData({
    required this.role,
    this.showInitialLoginLoader = false,
  });

  final DashboardUserRole role;
  final bool showInitialLoginLoader;
}

/// Typed input for the multi-step Add Collection route.
class AddCollectionRouteData {
  const AddCollectionRouteData({
    this.initialStep = CollectionEntryStep.items,
    this.initialType,
    this.initialSelectedItems = const <int>{},
    this.collectionId,
  });

  final CollectionEntryStep initialStep;
  final CollectionType? initialType;
  final Set<int> initialSelectedItems;
  final String? collectionId;
}
