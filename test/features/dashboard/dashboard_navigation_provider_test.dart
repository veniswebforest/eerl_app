import 'package:eerl_app/features/dashboard/model/bottom_nav_item_model.dart';
import 'package:eerl_app/features/dashboard/provider/dashboard_navigation_provider.dart';
import 'package:eerl_app/features/records/model/records_view_flag.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('collection drafts View All opens Records on the Drafts tab', () {
    final navigation = DashboardNavigationProvider(
      initialRole: DashboardUserRole.collectionAgent,
      initialPageKey: 'home',
    );
    addTearDown(navigation.dispose);

    navigation.showSavedCollections();

    expect(navigation.selectedPageKey, 'records');
    expect(navigation.recordsView, RecordsViewFlag.drafts);
    expect(navigation.recordsPageVersion, 1);
  });
}
