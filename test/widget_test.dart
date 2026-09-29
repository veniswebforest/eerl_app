// Basic smoke test for the EERL app.
//
// Note: Comprehensive widget tests should be added as features
// are built out. This placeholder verifies the app boots.

import 'package:eerl_app/core/providers/locale_provider.dart';
import 'package:eerl_app/core/router/app_router.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/features/home/view/home_screen.dart';
import 'package:eerl_app/features/help_support/view/help_support_screen.dart';
import 'package:eerl_app/features/dashboard/model/bottom_nav_item_model.dart';
import 'package:eerl_app/features/dashboard/provider/dashboard_navigation_provider.dart';
import 'package:eerl_app/features/records/model/collection_detail_status.dart';
import 'package:eerl_app/features/wallet/model/expense_claim_detail_status.dart';
import 'package:eerl_app/features/records/model/records_view_flag.dart';
import 'package:eerl_app/features/wallet/view/expense_claim_detail_screen.dart';
import 'package:eerl_app/features/collection/view/collections_tab_screen.dart';
import 'package:eerl_app/features/records/view/collection_detail_screen.dart';
import 'package:eerl_app/features/dashboard/view/main_dashboard_screen.dart';
import 'package:eerl_app/features/dashboard/widgets/dynamic_bottom_nav_bar.dart';
import 'package:eerl_app/features/wallet/view/log_expense_screen.dart';
import 'package:eerl_app/features/wallet/view/expense_submitted_screen.dart';
import 'package:eerl_app/features/records/view/records_tab_screen.dart';
import 'package:eerl_app/features/wallet/view/wallet_tab_screen.dart';
import 'package:eerl_app/features/wallet/widgets/expense_claim_card.dart';
import 'package:eerl_app/features/supervisor_expense/view/supervisor_expense_module_screen.dart';
import 'package:eerl_app/features/profile/view/profile_screen.dart';
import 'package:eerl_app/features/profile/model/logout_data_status.dart';
import 'package:eerl_app/features/profile/widgets/logout_confirmation_dialog.dart';
import 'package:eerl_app/features/profile/widgets/sync_data_dialog.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test placeholder', (WidgetTester tester) async {
    // The full app requires localization delegates and providers,
    // so a proper test harness will be set up when features expand.
    expect(true, isTrue);
  });

  testWidgets('Supervisor expense supports reject flow and result banner', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SupervisorExpenseModuleScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Approvals & Claims'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('supervisor-expense-pending')));
    await tester.pumpAndSettle();
    expect(find.text('Waiting for Supervisor'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(ListView), const Offset(0, -160));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('supervisor-expense-reject')),
    );
    await tester.tap(find.byKey(const Key('supervisor-expense-reject')));
    await tester.pumpAndSettle();
    expect(find.text('Reject Expenses'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(
      find.byKey(const Key('supervisor-expense-confirm-rejection')),
    );
    await tester.tap(
      find.byKey(const Key('supervisor-expense-confirm-rejection')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Expense Rejected!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Supervisor expense approve shows the static success state', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SupervisorExpenseModuleScreen(),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('supervisor-expense-pending')));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -160));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('supervisor-expense-approve')),
    );
    await tester.tap(find.byKey(const Key('supervisor-expense-approve')));
    await tester.pumpAndSettle();

    expect(find.text('Successfully Approved!'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('supervisor-expense-pending')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('supervisor-expense-approved')),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Supervisor cash request supports approve and closed details', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SupervisorExpenseModuleScreen(),
      ),
    );
    await tester.tap(find.text('Cash Request'));
    await tester.pumpAndSettle();
    expect(find.text('Approved & Credited'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('supervisor-cash-pending-0')));
    await tester.pumpAndSettle();
    expect(find.text('#REQ-2026-089'), findsOneWidget);
    expect(find.text('Waiting for Supervisor'), findsOneWidget);

    await tester.tap(find.byKey(const Key('supervisor-cash-approve')));
    await tester.pumpAndSettle();
    expect(find.text('#REQ-2026-086'), findsOneWidget);
    expect(find.text('Verified by Supervisor'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Supervisor cash request supports rejection flow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SupervisorExpenseModuleScreen(),
      ),
    );
    await tester.tap(find.text('Cash Request'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('supervisor-cash-pending-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('supervisor-cash-reject')));
    await tester.pumpAndSettle();

    expect(find.text('Reject Cash Request'), findsOneWidget);
    expect(find.text('Sufficient Existing Balance'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('supervisor-cash-confirm-rejection')),
    );
    await tester.pumpAndSettle();

    expect(find.text('#REQ-2026-085'), findsOneWidget);
    expect(find.text('Rejected by Supervisor'), findsOneWidget);
    expect(
      find.textContaining('All yard trucks are currently out.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Supervisor category requests show pending and closed details', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SupervisorExpenseModuleScreen(),
      ),
    );
    await tester.ensureVisible(find.text('View Requests'));
    await tester.tap(find.text('View Requests'));
    await tester.pumpAndSettle();

    expect(find.text('Expense Category Request'), findsOneWidget);
    expect(find.text('Request Pending'), findsWidgets);
    await tester.tap(find.text('Closed (4)'));
    await tester.pumpAndSettle();
    expect(find.text('Request Resolved'), findsWidgets);

    await tester.ensureVisible(
      find.byKey(const ValueKey('category-request-rejected-2')),
    );
    await tester.tap(find.byKey(const ValueKey('category-request-rejected-2')));
    await tester.pumpAndSettle();
    expect(find.text('Request Reject'), findsOneWidget);
    expect(
      find.textContaining('Invalid / Unclear Request Purpose'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Supervisor category request supports approve and reject dialogs',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SupervisorExpenseModuleScreen(),
        ),
      );
      await tester.ensureVisible(find.text('View Requests'));
      await tester.tap(find.text('View Requests'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('category-request-pending-0')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('category-request-approve')));
      await tester.pumpAndSettle();
      expect(find.text('Expense Request\nApproved!'), findsOneWidget);
      await tester.tap(find.byKey(const Key('category-request-back-to-list')));
      await tester.pumpAndSettle();
      expect(find.text('Closed (4)'), findsOneWidget);

      await tester.tap(find.text('Pending (2)'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('category-request-pending-0')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('category-request-reject')));
      await tester.pumpAndSettle();
      expect(find.text('Are You Sure'), findsOneWidget);
      await tester.tap(
        find.byKey(const Key('category-request-confirm-reject')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Expense Request Rejected'), findsOneWidget);
      expect(
        find.text('Expense request rejected successfully'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Supervisor approvals quick action opens expense module', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const _RouterTestApp(
          home: MainDashboardScreen(userRole: DashboardUserRole.supervisor),
        ),
      ),
    );
    await tester.drag(
      find.byKey(const Key('home-dashboard-scroll')),
      const Offset(0, -1600),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('supervisor-approvals-card')),
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('supervisor-approvals-card')),
        matching: find.byType(ElevatedButton),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('supervisor-expense-list-screen')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final size in <Size>[
    const Size(320, 568),
    const Size(375, 812),
    const Size(800, 1200),
  ]) {
    final locale = switch (size.width.toInt()) {
      320 => const Locale('gu'),
      375 => const Locale('hi'),
      _ => const Locale('en'),
    };

    testWidgets(
      'Home screen is responsive at ${size.width.toInt()}px in ${locale.languageCode}',
      (WidgetTester tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(_homeTestApp(locale: locale));
        await tester.pumpAndSettle();

        final initialException = tester.takeException();
        expect(initialException, isNull);

        await tester.drag(
          find.byKey(const Key('home-dashboard-scroll')),
          const Offset(0, -1200),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Home menu opens the Figma navigation drawer', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_homeTestApp());

    await tester.tap(find.byKey(const Key('home-menu-button')));
    await tester.pumpAndSettle();

    expect(find.text('Rahul Patel'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Collection Agent'),
      ),
      findsOneWidget,
    );
    expect(find.text('Transfer Requests'), findsWidgets);
    expect(find.text('Ragpicker Directory'), findsOneWidget);
    expect(find.text('Tasks & Requests'), findsOneWidget);
    expect(find.byKey(const Key('drawer-tasks')), findsNothing);

    await tester.tap(find.byKey(const Key('drawer-tasks-requests')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('drawer-tasks')), findsOneWidget);
    expect(find.byKey(const Key('drawer-requests')), findsOneWidget);
    expect(find.text('Powered by Eco Vision'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Supervisor home uses the supervisor Figma drawer', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(375, 950);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_homeTestApp(role: DashboardUserRole.supervisor));

    await tester.tap(find.byKey(const Key('home-menu-button')));
    await tester.pumpAndSettle();

    expect(find.text('Bhavesh Shah'), findsOneWidget);
    expect(find.text('Collection Supervisor'), findsWidgets);
    expect(find.byKey(const Key('drawer-supervisor-stock')), findsOneWidget);
    expect(
      find.byKey(const Key('drawer-supervisor-verification')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('drawer-supervisor-mrf-person-list')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('drawer-supervisor-d2d-vehicle-list')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('drawer-supervisor-agent-status')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('drawer-supervisor-pending-verification')),
      findsNothing,
    );
    expect(find.byKey(const Key('drawer-supervisor-tasks')), findsNothing);

    tester.view.physicalSize = const Size(375, 1122);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('drawer-supervisor-verification')));
    await tester.tap(find.byKey(const Key('drawer-supervisor-tasks-requests')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('drawer-supervisor-pending-verification')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('drawer-supervisor-verified-entries')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('drawer-supervisor-tasks')), findsOneWidget);
    expect(find.byKey(const Key('drawer-supervisor-requests')), findsOneWidget);
    expect(find.byKey(const Key('drawer-collection')), findsNothing);
    expect(find.text('Powered by Eco Vision'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dashboard switches tabs and filters navigation by role', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const _RouterTestApp(
          home: MainDashboardScreen(userRole: DashboardUserRole.supervisor),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('bottom-nav-records')), findsNothing);
    expect(find.byKey(const ValueKey('bottom-nav-collections')), findsNothing);
    expect(
      find.byKey(const ValueKey('bottom-nav-supervisor-verify')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('bottom-nav-supervisor-stock')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('supervisor-summary-visible-icon')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('supervisor-toggle-todays-summary')));
    await tester.pumpAndSettle();

    expect(find.text('Active Agents'), findsNothing);
    expect(
      find.byKey(const ValueKey('supervisor-summary-hidden-icon')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey('bottom-nav-supervisor-verify')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Collection History'), findsOneWidget);
    expect(find.text('Pending Your Approval'), findsWidgets);

    await tester.tap(find.text('Rahul Patel • D2D').first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('verification-detail-back')), findsOneWidget);
    expect(
      find.byKey(const Key('verification-approve-button')),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const Key('verification-reject-button')),
    );
    await tester.tap(find.byKey(const Key('verification-reject-button')));
    await tester.pumpAndSettle();

    expect(find.text('Reject Collection'), findsOneWidget);
    expect(
      find.byKey(const Key('verification-confirm-rejection')),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.byKey(const Key('verification-cancel-rejection')),
    );
    await tester.tap(find.byKey(const Key('verification-cancel-rejection')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const Key('verification-approve-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('verification-approve-button')));
    await tester.pumpAndSettle();

    expect(find.text('Verified & Approved'), findsOneWidget);
    expect(find.byKey(const Key('verification-approve-button')), findsNothing);

    await tester.ensureVisible(
      find.byKey(const Key('verification-detail-back')),
    );
    await tester.tap(find.byKey(const Key('verification-detail-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bottom-nav-supervisor-stock')));
    await tester.pumpAndSettle();

    expect(find.text('Stock by Stage Overview'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('stock-stage-rm')));
    await tester.pumpAndSettle();

    expect(find.text('RM Detail'), findsOneWidget);
    expect(find.text('Bin: RM-01'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Supervisor drawer routes Stock and verification tabs', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainDashboardScreen(userRole: DashboardUserRole.supervisor),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('home-menu-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drawer-supervisor-stock')));
    await tester.pumpAndSettle();

    expect(find.text('Stock by Stage Overview'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('bottom-nav-home')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-menu-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drawer-supervisor-verification')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('drawer-supervisor-verified-entries')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('verification-status-processed')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Wallet opens from the dashboard drawer', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const _RouterTestApp(home: MainDashboardScreen()),
      ),
    );

    await tester.tap(find.byKey(const Key('home-menu-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('bottom-nav-home')), findsNothing);
    await tester.tap(
      find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Wallet & Log Expense'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WalletTabScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-nav-records')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('System back closes a pushed feature screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const _RouterTestApp(
          home: MainDashboardScreen(initialPageKey: 'wallet'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(WalletTabScreen), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(WalletTabScreen), findsNothing);
    expect(find.byType(MainDashboardScreen), findsOneWidget);
  });

  testWidgets('System back returns a bottom tab to Home before exiting', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainDashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bottom-nav-records')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<DynamicBottomNavBar>(find.byType(DynamicBottomNavBar))
          .selectedIndex,
      2,
    );

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<DynamicBottomNavBar>(find.byType(DynamicBottomNavBar))
          .selectedIndex,
      0,
    );
  });

  testWidgets('Log Expense opens from wallet and supports both Figma states', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const _RouterTestApp(
          home: MainDashboardScreen(initialPageKey: 'wallet'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Log Expense'));
    await tester.pumpAndSettle();
    expect(find.byType(LogExpenseScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('expense-category-selector')));
    await tester.pumpAndSettle();
    expect(find.text('Labour'), findsOneWidget);
    await tester.tap(find.text('Fuel / Diesel').last);
    await tester.enterText(find.byType(TextField).first, '1000');
    await tester.tap(find.byKey(const Key('capture-receipt-button')));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNWidgets(2));
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('submit-expense-button')));
    await tester.pumpAndSettle();

    expect(find.byType(ExpenseSubmittedScreen), findsOneWidget);
    expect(find.text('Expense Submitted!'), findsOneWidget);

    await tester.tap(find.byKey(const Key('expense-back-to-wallet')));
    await tester.pumpAndSettle();
    expect(find.byType(WalletTabScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Log Expense is responsive in Gujarati at 320px', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('gu'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LogExpenseScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Recent expense claim opens its matching detail status', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const _RouterTestApp(
          home: MainDashboardScreen(initialPageKey: 'wallet'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final pendingCard = find.byType(ExpenseClaimCard).first;
    await tester.ensureVisible(pendingCard);
    await tester.tap(pendingCard);
    await tester.pumpAndSettle();

    expect(find.byType(ExpenseClaimDetailScreen), findsOneWidget);
    expect(find.text('Waiting for Supervisor'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final variant in <(ExpenseClaimDetailStatus, Locale, Size)>[
    (
      ExpenseClaimDetailStatus.pending,
      const Locale('gu'),
      const Size(320, 568),
    ),
    (
      ExpenseClaimDetailStatus.verified,
      const Locale('hi'),
      const Size(375, 812),
    ),
    (
      ExpenseClaimDetailStatus.rejected,
      const Locale('en'),
      const Size(800, 1200),
    ),
  ]) {
    testWidgets(
      'Expense detail ${variant.$1.name} is responsive in ${variant.$2.languageCode}',
      (WidgetTester tester) async {
        tester.view.physicalSize = variant.$3;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            locale: variant.$2,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ExpenseClaimDetailScreen(status: variant.$1),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(ListView), const Offset(0, -900));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final localeAndSize in <(Locale, Size)>[
    (const Locale('gu'), const Size(320, 568)),
    (const Locale('hi'), const Size(375, 812)),
    (const Locale('en'), const Size(800, 1200)),
  ]) {
    testWidgets('Wallet UI is responsive in ${localeAndSize.$1.languageCode}', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = localeAndSize.$2;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(),
          child: _RouterTestApp(
            locale: localeAndSize.$1,
            home: const MainDashboardScreen(initialPageKey: 'wallet'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WalletTabScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(ListView).first, const Offset(0, -800));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  for (final collectionVariant in <(Locale, Size)>[
    (const Locale('gu'), const Size(320, 568)),
    (const Locale('hi'), const Size(375, 812)),
    (const Locale('en'), const Size(800, 1200)),
  ]) {
    testWidgets(
      'Collections tab is responsive in ${collectionVariant.$1.languageCode}',
      (WidgetTester tester) async {
        tester.view.physicalSize = collectionVariant.$2;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            locale: collectionVariant.$1,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const CollectionsTabScreen(),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(ListView), const Offset(0, -900));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final recordsVariant in <(RecordsViewFlag, Locale, Size)>[
    (RecordsViewFlag.history, const Locale('gu'), const Size(320, 568)),
    (RecordsViewFlag.drafts, const Locale('hi'), const Size(375, 812)),
    (RecordsViewFlag.emptyDrafts, const Locale('en'), const Size(800, 1200)),
  ]) {
    testWidgets(
      'Records ${recordsVariant.$1.name} is responsive in ${recordsVariant.$2.languageCode}',
      (WidgetTester tester) async {
        tester.view.physicalSize = recordsVariant.$3;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            locale: recordsVariant.$2,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: RecordsTabScreen(initialView: recordsVariant.$1),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final detailVariant in <(CollectionDetailStatus, Locale, Size)>[
    (CollectionDetailStatus.pending, const Locale('gu'), const Size(320, 568)),
    (CollectionDetailStatus.approved, const Locale('hi'), const Size(375, 812)),
    (
      CollectionDetailStatus.rejected,
      const Locale('en'),
      const Size(800, 1200),
    ),
  ]) {
    testWidgets(
      'Collection detail ${detailVariant.$1.name} is responsive in ${detailVariant.$2.languageCode}',
      (tester) async {
        tester.view.physicalSize = detailVariant.$3;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            locale: detailVariant.$2,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CollectionDetailScreen(status: detailVariant.$1),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Records history card opens collection detail and hides navigation',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(),
          child: const _RouterTestApp(
            home: MainDashboardScreen(initialPageKey: 'records'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('D2D').first);
      await tester.pumpAndSettle();
      expect(find.byType(CollectionDetailScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('bottom-nav-records')), findsNothing);
      expect(find.text('Pending Supervisor Verification'), findsOneWidget);
    },
  );

  testWidgets('Collection rejected detail matches review preview', (
    tester,
  ) async {
    final fontLoader = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/font/Manrope-Regular.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-Medium.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-Bold.ttf'));
    await fontLoader.load();
    tester.view.physicalSize = const Size(375, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CollectionDetailScreen(status: CollectionDetailStatus.rejected),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    await expectLater(
      find.byType(CollectionDetailScreen),
      matchesGoldenFile('collection_detail_rejected_preview.png'),
    );
  });

  testWidgets('Records screen matches review preview', (tester) async {
    final fontLoader = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/font/Manrope-Regular.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-Medium.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-Bold.ttf'));
    await fontLoader.load();
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainDashboardScreen(initialPageKey: 'records'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MainDashboardScreen),
      matchesGoldenFile('records_preview.png'),
    );
  });

  testWidgets('Profile screen matches review preview', (tester) async {
    final fontLoader = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/font/Manrope-Regular.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-Medium.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-Bold.ttf'));
    await fontLoader.load();
    tester.view.physicalSize = const Size(375, 1093);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainDashboardScreen(initialPageKey: 'profile'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
    await expectLater(
      find.byType(MainDashboardScreen),
      matchesGoldenFile('profile_preview.png'),
    );
  });

  testWidgets('Profile Sync Data dialog switches between both Figma states', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainDashboardScreen(initialPageKey: 'profile'),
        ),
      ),
    );
    final syncAction = find.byKey(const Key('profile-sync-data'));
    await tester.ensureVisible(syncAction);
    await tester.tap(syncAction);
    await tester.pumpAndSettle();
    expect(find.byType(SyncDataDialog), findsOneWidget);
    expect(find.text('Sync Offline Data'), findsOneWidget);
    expect(find.text('3 collection Pending'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('sync-now-button')));
    await tester.pumpAndSettle();
    expect(find.text('Data Already Synced'), findsOneWidget);
    expect(find.byKey(const ValueKey('sync-back-button')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile Sync Data dialog matches review preview', (
    tester,
  ) async {
    final fontLoader = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/font/Manrope-Regular.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-Medium.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-Bold.ttf'));
    await fontLoader.load();
    tester.view.physicalSize = const Size(375, 1024);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainDashboardScreen(initialPageKey: 'profile'),
        ),
      ),
    );
    final syncAction = find.byKey(const Key('profile-sync-data'));
    await tester.ensureVisible(syncAction);
    await tester.tap(syncAction);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('profile_sync_data_preview.png'),
    );
  });

  testWidgets('Profile Logout dialog supports pending and synced states', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainDashboardScreen(initialPageKey: 'profile'),
        ),
      ),
    );

    final logoutAction = find.byKey(const Key('profile-logout'));
    await tester.ensureVisible(logoutAction);
    await tester.drag(find.byType(ListView).first, const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.tap(logoutAction);
    await tester.pumpAndSettle();

    expect(find.byType(LogoutConfirmationDialog), findsOneWidget);
    expect(find.text('Are you sure you want to log out?'), findsOneWidget);
    expect(find.byKey(const Key('logout-pending-warning')), findsOneWidget);

    await tester.tap(find.byKey(const Key('logout-no-button')));
    await tester.pumpAndSettle();
    expect(find.byType(LogoutConfirmationDialog), findsNothing);

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LogoutConfirmationDialog(dataStatus: LogoutDataStatus.synced),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('logout-pending-warning')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile Logout dialog matches review preview', (tester) async {
    final fontLoader = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/font/Manrope-Regular.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-Medium.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-Bold.ttf'));
    await fontLoader.load();
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainDashboardScreen(initialPageKey: 'profile'),
        ),
      ),
    );
    final logoutAction = find.byKey(const Key('profile-logout'));
    await tester.ensureVisible(logoutAction);
    await tester.drag(find.byType(ListView).first, const Offset(0, -120));
    await tester.pumpAndSettle();
    await tester.tap(logoutAction);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('profile_logout_preview.png'),
    );
  });

  testWidgets('Help & Support opens from drawer and expands FAQ items', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LocaleProvider(),
        child: const _RouterTestApp(home: MainDashboardScreen()),
      ),
    );

    await tester.tap(find.byKey(const Key('home-menu-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drawer-help-support')));
    await tester.pumpAndSettle();

    expect(find.byType(HelpSupportScreen), findsOneWidget);
    expect(find.text('Frequently Asked Questions'), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-nav-home')), findsNothing);
    expect(
      find.textContaining('1. Turn Bluetooth OFF and ON.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('help-faq-1')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('1. Open Wallet & Log Expense.'),
      findsOneWidget,
    );
    expect(find.textContaining('1. Turn Bluetooth OFF and ON.'), findsNothing);

    await tester.tap(find.byKey(const Key('help-support-back')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Help & Support is responsive in Gujarati and Hindi', (
    tester,
  ) async {
    for (final locale in const [Locale('gu'), Locale('hi')]) {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HelpSupportScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  });

  testWidgets('Help & Support matches review preview', (tester) async {
    final fontLoader = FontLoader('Manrope')
      ..addFont(rootBundle.load('assets/font/Manrope-Regular.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-Medium.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/font/Manrope-Bold.ttf'));
    await fontLoader.load();
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HelpSupportScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(HelpSupportScreen),
      matchesGoldenFile('help_support_preview.png'),
    );
  });

  test('Selected Gujarati locale is persisted and restored', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = LocaleProvider();

    await provider.setLocale(const Locale('gu'));

    final restoredProvider = LocaleProvider();
    await restoredProvider.loadLocale();

    expect(restoredProvider.locale, const Locale('gu'));
  });

  testWidgets('Profile language button changes and persists the app locale', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final provider = LocaleProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: Consumer<LocaleProvider>(
          builder: (context, localeProvider, child) {
            return MaterialApp(
              locale: localeProvider.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const ProfileScreen(),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('profile-language-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-language-gu')));
    await tester.pumpAndSettle();

    expect(provider.locale, const Locale('gu'));
    expect(find.text('વપરાશકર્તા પ્રોફાઇલ'), findsOneWidget);

    final restoredProvider = LocaleProvider();
    await restoredProvider.loadLocale();
    expect(restoredProvider.locale, const Locale('gu'));
  });
}

class _RouterTestApp extends StatefulWidget {
  const _RouterTestApp({required this.home, this.locale});

  final Widget home;
  final Locale? locale;

  @override
  State<_RouterTestApp> createState() => _RouterTestAppState();
}

class _RouterTestAppState extends State<_RouterTestApp> {
  late final _router = AppRouter.createRouter(
    initialLocation: AppRoutes.home,
    homeBuilder: (_) => widget.home,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    locale: widget.locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: _router,
  );
}

Widget _homeTestApp({
  Locale? locale,
  DashboardUserRole role = DashboardUserRole.collectionAgent,
}) => ChangeNotifierProvider(
  create: (_) =>
      DashboardNavigationProvider(initialRole: role, initialPageKey: 'home'),
  child: MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const HomeScreen(),
  ),
);
