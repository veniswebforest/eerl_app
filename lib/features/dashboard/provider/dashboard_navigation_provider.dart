import 'package:flutter/foundation.dart';

import 'package:eerl_app/features/dashboard/model/bottom_nav_item_model.dart';
import 'package:eerl_app/features/records/model/records_view_flag.dart';
import 'package:eerl_app/features/verification/model/verification_entry.dart';

/// Owns dashboard-shell state shared by the bottom navigation and its tabs.
class DashboardNavigationProvider extends ChangeNotifier {
  DashboardNavigationProvider({
    required DashboardUserRole initialRole,
    required String initialPageKey,
  }) : _activeRole = initialRole,
       _selectedPageKey = initialPageKey == 'wallet' ? 'home' : initialPageKey;

  DashboardUserRole _activeRole;
  String _selectedPageKey;
  VerificationListStatus _verificationStatus = VerificationListStatus.pending;
  RecordsViewFlag _recordsView = RecordsViewFlag.history;
  int _recordsPageVersion = 0;
  bool _isDrawerOpen = false;

  DashboardUserRole get activeRole => _activeRole;
  String get selectedPageKey => _selectedPageKey;
  VerificationListStatus get verificationStatus => _verificationStatus;
  RecordsViewFlag get recordsView => _recordsView;
  int get recordsPageVersion => _recordsPageVersion;
  bool get isDrawerOpen => _isDrawerOpen;

  void selectPage(String pageKey) {
    if (_selectedPageKey == pageKey) return;
    _selectedPageKey = pageKey;
    notifyListeners();
  }

  void changeRole(DashboardUserRole role) {
    if (_activeRole == role && _selectedPageKey == 'home') return;
    _activeRole = role;
    _selectedPageKey = 'home';
    notifyListeners();
  }

  void updateRoleFromParent(DashboardUserRole role) {
    if (_activeRole == role) return;
    changeRole(role);
  }

  void showSavedCollections() {
    _recordsView = RecordsViewFlag.drafts;
    _recordsPageVersion++;
    _selectedPageKey = 'records';
    notifyListeners();
  }

  void showVerification(VerificationListStatus status) {
    if (_verificationStatus == status &&
        _selectedPageKey == 'supervisor-verify') {
      return;
    }
    _verificationStatus = status;
    _selectedPageKey = 'supervisor-verify';
    notifyListeners();
  }

  void setDrawerOpen(bool isOpen) {
    if (_isDrawerOpen == isOpen) return;
    _isDrawerOpen = isOpen;
    notifyListeners();
  }
}
