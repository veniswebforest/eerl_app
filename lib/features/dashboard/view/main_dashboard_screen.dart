import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/features/collection/view/collections_tab_screen.dart';
import 'package:eerl_app/features/home/view/home_screen.dart';
import 'package:eerl_app/features/profile/view/profile_screen.dart';
import 'package:eerl_app/features/records/model/collection_detail_status.dart';
import 'package:eerl_app/features/records/view/collection_detail_screen.dart';
import 'package:eerl_app/features/records/view/records_tab_screen.dart';
import 'package:eerl_app/features/wallet/model/expense_claim_detail_status.dart';
import 'package:eerl_app/features/wallet/view/expense_claim_detail_screen.dart';
import 'package:eerl_app/features/wallet/view/log_expense_screen.dart';
import 'package:eerl_app/features/wallet/view/wallet_tab_screen.dart';
import '../model/bottom_nav_item_model.dart';
import '../widgets/dynamic_bottom_nav_bar.dart';

const _navIconPath = 'assets/icons/home';

/// Role-aware dashboard shell that preserves each tab's widget state.
class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({
    super.key,
    this.userRole = DashboardUserRole.collectionAgent,
    this.permissions = const <String>{},
    this.initialPageKey = 'home',
    this.onTabChanged,
  });

  final DashboardUserRole userRole;
  final Set<String> permissions;
  final String initialPageKey;
  final ValueChanged<BottomNavItemModel>? onTabChanged;

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  late String _selectedPageKey = widget.initialPageKey == 'wallet'
      ? 'home'
      : widget.initialPageKey;
  late bool _isWalletOpen = widget.initialPageKey == 'wallet';
  bool _isLogExpenseOpen = false;
  ExpenseClaimDetailStatus? _claimDetailStatus;
  CollectionDetailStatus? _collectionDetailStatus;
  bool _isDrawerOpen = false;

  List<BottomNavItemModel> get _visibleItems => _createItems()
      .where((item) => item.isVisibleFor(widget.userRole, widget.permissions))
      .toList(growable: false);

  @override
  void didUpdateWidget(covariant MainDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final items = _visibleItems;
    if (items.isNotEmpty &&
        !items.any((item) => item.pageKey == _selectedPageKey)) {
      _selectedPageKey = items.first.pageKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleItems;
    if (items.isEmpty) {
      return Scaffold(
        body: Center(child: Text(context.l10n.dashboardEmptyMessage)),
      );
    }
    final selectedIndex = items.indexWhere(
      (item) => item.pageKey == _selectedPageKey,
    );
    final safeSelectedIndex = selectedIndex < 0 ? 0 : selectedIndex;

    return Scaffold(
      extendBody: true,
      body: _collectionDetailStatus != null
          ? CollectionDetailScreen(
              status: _collectionDetailStatus!,
              onBack: () => setState(() => _collectionDetailStatus = null),
            )
          : _claimDetailStatus != null
          ? ExpenseClaimDetailScreen(
              status: _claimDetailStatus!,
              onBack: () => setState(() => _claimDetailStatus = null),
            )
          : _isLogExpenseOpen
          ? LogExpenseScreen(
              onBack: () => setState(() => _isLogExpenseOpen = false),
            )
          : _isWalletOpen
          ? WalletTabScreen(
              onBack: () => setState(() => _isWalletOpen = false),
              onLogExpense: () => setState(() => _isLogExpenseOpen = true),
              onClaimTap: (status) {
                setState(() => _claimDetailStatus = status);
              },
            )
          : IndexedStack(
              index: safeSelectedIndex,
              children: items.map((item) => item.page).toList(growable: false),
            ),
      bottomNavigationBar:
          _isWalletOpen ||
              _isLogExpenseOpen ||
              _claimDetailStatus != null ||
              _collectionDetailStatus != null ||
              _isDrawerOpen
          ? null
          : DynamicBottomNavBar(
              items: items,
              selectedIndex: safeSelectedIndex,
              onItemSelected: (index) {
                final selectedItem = items[index];
                if (selectedItem.pageKey == _selectedPageKey) return;

                setState(() => _selectedPageKey = selectedItem.pageKey);
                widget.onTabChanged?.call(selectedItem);
              },
            ),
    );
  }

  List<BottomNavItemModel> _createItems() {
    const allRoles = <DashboardUserRole>{
      DashboardUserRole.collectionAgent,
      DashboardUserRole.supervisor,
      DashboardUserRole.admin,
    };

    final l10n = context.l10n;

    return [
      BottomNavItemModel(
        title: l10n.home,
        selectedIcon: '$_navIconPath/nav_home.svg',
        unselectedIcon: '$_navIconPath/nav_home.svg',
        page: HomeScreen(
          onWalletTap: () => setState(() => _isWalletOpen = true),
          onDrawerChanged: (isOpen) {
            if (_isDrawerOpen == isOpen) return;
            setState(() => _isDrawerOpen = isOpen);
          },
        ),
        pageKey: 'home',
        roles: allRoles,
        permission: 'dashboard.view',
      ),
      BottomNavItemModel(
        title: l10n.drawerCollection,
        selectedIcon: '$_navIconPath/nav_collections.svg',
        unselectedIcon: '$_navIconPath/nav_collections.svg',
        page: CollectionsTabScreen(),
        pageKey: 'collections',
        roles: allRoles,
        permission: 'collections.view',
      ),
      BottomNavItemModel(
        title: l10n.records,
        selectedIcon: '$_navIconPath/nav_wallet.svg',
        unselectedIcon: '$_navIconPath/nav_wallet.svg',
        page: RecordsTabScreen(
          onRecordTap: (status) =>
              setState(() => _collectionDetailStatus = status),
        ),
        pageKey: 'records',
        roles: allRoles,
        permission: 'records.view',
      ),
      BottomNavItemModel(
        title: l10n.profile,
        selectedIcon: '$_navIconPath/nav_profile.svg',
        unselectedIcon: '$_navIconPath/nav_profile.svg',
        page: ProfileScreen(),
        pageKey: 'profile',
        roles: allRoles,
        permission: 'profile.view',
      ),
    ];
  }
}
