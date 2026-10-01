import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eerl_app/features/agent_status/view/agent_status_screen.dart';
import 'package:eerl_app/features/auth/view/app_lock_screen.dart';
import 'package:eerl_app/features/auth/view/login_screen.dart';
import 'package:eerl_app/features/auth/view/otp_screen.dart';
import 'package:eerl_app/features/auth/view/splash_screen.dart';
import 'package:eerl_app/features/dashboard/view/main_dashboard_screen.dart';
import 'package:eerl_app/features/dashboard/model/bottom_nav_item_model.dart';
import 'package:eerl_app/features/d2d_vehicle_management/view/d2d_vehicle_management_screen.dart';
import 'package:eerl_app/features/details/view/details_screen.dart';
import 'package:eerl_app/features/settings/view/settings_screen.dart';
import 'package:eerl_app/features/collection/view/add_collection_screen.dart';
import 'package:eerl_app/features/collection/view/collection_image_preview_screen.dart';
import 'package:eerl_app/features/collection/view/collection_receipt_screen.dart';
import 'package:eerl_app/features/configure_material/view/configure_material_screen.dart';
import 'package:eerl_app/features/end_my_day/view/end_my_day_screen.dart';
import 'package:eerl_app/features/help_support/view/help_support_screen.dart';
import 'package:eerl_app/features/notifications/view/notifications_screen.dart';
import 'package:eerl_app/features/ragpicker_directory/view/ragpicker_directory_screen.dart';
import 'package:eerl_app/features/records/model/collection_detail_status.dart';
import 'package:eerl_app/features/records/view/collection_detail_screen.dart';
import 'package:eerl_app/features/requests/model/request_list_item.dart';
import 'package:eerl_app/features/requests/view/raise_request_screen.dart';
import 'package:eerl_app/features/requests/view/request_detail_screen.dart';
import 'package:eerl_app/features/requests/view/requests_screen.dart';
import 'package:eerl_app/features/role_switcher/view/role_switcher_screen.dart';
import 'package:eerl_app/features/stock/model/stock_item.dart';
import 'package:eerl_app/features/stock/view/stock_detail_screen.dart';
import 'package:eerl_app/features/supervisor_expense/view/supervisor_expense_module_screen.dart';
import 'package:eerl_app/features/supervisor_mrf_people/view/supervisor_mrf_people_screen.dart';
import 'package:eerl_app/features/supervisor_requests/view/supervisor_agent_requests_screen.dart';
import 'package:eerl_app/features/supervisor_requests/view/supervisor_completed_request_screen.dart';
import 'package:eerl_app/features/supervisor_requests/view/supervisor_resolve_request_screen.dart';
import 'package:eerl_app/features/supervisor_tasks/model/supervisor_task_detail_status.dart';
import 'package:eerl_app/features/supervisor_tasks/view/assign_supervisor_task_screen.dart';
import 'package:eerl_app/features/supervisor_tasks/view/supervisor_task_detail_screen.dart';
import 'package:eerl_app/features/supervisor_tasks/view/supervisor_tasks_screen.dart';
import 'package:eerl_app/features/tasks/model/task_list_item.dart';
import 'package:eerl_app/features/tasks/view/my_tasks_screen.dart';
import 'package:eerl_app/features/tasks/view/task_detail_screen.dart';
import 'package:eerl_app/features/transfer_requests/model/transfer_request_detail_state.dart';
import 'package:eerl_app/features/transfer_requests/view/create_transfer_request_screen.dart';
import 'package:eerl_app/features/transfer_requests/view/transfer_request_detail_screen.dart';
import 'package:eerl_app/features/transfer_requests/view/transfer_requests_screen.dart';
import 'package:eerl_app/features/verification/model/verification_entry.dart';
import 'package:eerl_app/features/verification/view/reject_collection_screen.dart';
import 'package:eerl_app/features/verification/view/verification_detail_screen.dart';
import 'package:eerl_app/features/wallet/model/cash_request_detail_status.dart';
import 'package:eerl_app/features/wallet/model/expense_claim_detail_status.dart';
import 'package:eerl_app/features/wallet/view/cash_request_detail_screen.dart';
import 'package:eerl_app/features/wallet/view/expense_claim_detail_screen.dart';
import 'package:eerl_app/features/wallet/view/expense_submitted_screen.dart';
import 'package:eerl_app/features/wallet/view/log_expense_screen.dart';
import 'package:eerl_app/features/wallet/view/request_cash_screen.dart';
import 'package:eerl_app/features/wallet/view/wallet_tab_screen.dart';
import 'app_route_data.dart';
import 'app_routes.dart';

/// Application router configuration built with [GoRouter].
///
/// Uses a single [GoRoute] for the home shell which houses [MainDashboardScreen].
/// [MainDashboardScreen] preserves bottom-navigation tabs with [IndexedStack].
/// Feature pages are pushed onto the root navigator so toolbar and system back
/// actions share the same stack behavior.
class AppRouter {
  AppRouter._();

  static final GoRouter router = createRouter();

  /// Creates an isolated router. The optional home builder keeps widget tests
  /// on the same production route table while allowing a specific dashboard
  /// role or initial tab to be exercised.
  static GoRouter createRouter({
    String initialLocation = AppRoutes.splash,
    WidgetBuilder? homeBuilder,
  }) {
    final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initialLocation,
      routes: _routes(rootNavigatorKey, homeBuilder),
      errorBuilder: (context, state) => const _ErrorPage(),
    );
  }

  static List<RouteBase> _routes(
    GlobalKey<NavigatorState> rootNavigatorKey,
    WidgetBuilder? homeBuilder,
  ) => [
    // ── Main dashboard shell (owns bottom nav + overlays) ─────────
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) =>
          homeBuilder?.call(context) ?? const MainDashboardScreen(),
    ),

    // ── Feature routes ──────────────────────────────────────────
    GoRoute(
      path: AppRoutes.roleSwitcher,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => RoleSwitcherScreen(
        initialRole:
            state.extra as DashboardUserRole? ??
            DashboardUserRole.collectionAgent,
      ),
    ),
    GoRoute(
      path: AppRoutes.wallet,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const WalletTabScreen(),
    ),
    GoRoute(
      path: AppRoutes.logExpense,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const LogExpenseScreen(),
    ),
    GoRoute(
      path: AppRoutes.requestCash,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const RequestCashScreen(),
    ),
    GoRoute(
      path: AppRoutes.expenseSubmitted,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (_, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 180),
        reverseTransitionDuration: const Duration(milliseconds: 140),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
        child: const ExpenseSubmittedScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.expenseClaimDetail,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => ExpenseClaimDetailScreen(
        status:
            state.extra as ExpenseClaimDetailStatus? ??
            ExpenseClaimDetailStatus.pending,
      ),
    ),
    GoRoute(
      path: AppRoutes.cashRequestDetail,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => CashRequestDetailScreen(
        status:
            state.extra as CashRequestDetailStatus? ??
            CashRequestDetailStatus.pending,
      ),
    ),
    GoRoute(
      path: AppRoutes.addCollection,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) {
        final data =
            state.extra as AddCollectionRouteData? ??
            const AddCollectionRouteData();
        return AddCollectionScreen(
          initialStep: data.initialStep,
          initialType: data.initialType,
          initialSelectedItems: data.initialSelectedItems,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.collectionDetail,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => CollectionDetailScreen(
        status:
            state.extra as CollectionDetailStatus? ??
            CollectionDetailStatus.pending,
      ),
    ),
    GoRoute(
      path: AppRoutes.collectionReceipt,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const CollectionReceiptScreen(),
    ),
    GoRoute(
      path: AppRoutes.collectionImagePreview,
      parentNavigatorKey: rootNavigatorKey,
      pageBuilder: (_, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.9),
        transitionDuration: const Duration(milliseconds: 180),
        reverseTransitionDuration: const Duration(milliseconds: 140),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
        child: CollectionImagePreviewScreen(
          imageProvider: state.extra! as ImageProvider,
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.configureMaterials,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const ConfigureMaterialScreen(),
    ),
    GoRoute(
      path: AppRoutes.ragpickerDirectory,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) =>
          RagpickerDirectoryScreen(isSupervisor: state.extra == true),
    ),
    GoRoute(
      path: AppRoutes.d2dVehicleManagement,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const D2dVehicleManagementScreen(),
    ),
    GoRoute(
      path: AppRoutes.agentStatus,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const AgentStatusScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.endMyDay,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => EndMyDayScreen(isSupervisor: state.extra == true),
    ),
    GoRoute(
      path: AppRoutes.helpSupport,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const HelpSupportScreen(),
    ),
    GoRoute(
      path: AppRoutes.tasks,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const MyTasksScreen(),
    ),
    GoRoute(
      path: AppRoutes.taskDetail,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) =>
          TaskDetailScreen(task: state.extra! as TaskListItem),
    ),
    GoRoute(
      path: AppRoutes.supervisorTasks,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const SupervisorTasksScreen(),
    ),
    GoRoute(
      path: AppRoutes.assignSupervisorTask,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const AssignSupervisorTaskScreen(),
    ),
    GoRoute(
      path: AppRoutes.supervisorTaskDetail,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => SupervisorTaskDetailScreen(
        status:
            state.extra as SupervisorTaskDetailStatus? ??
            SupervisorTaskDetailStatus.inProgress,
      ),
    ),
    GoRoute(
      path: AppRoutes.requests,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const RequestsScreen(),
    ),
    GoRoute(
      path: AppRoutes.raiseRequest,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const RaiseRequestScreen(),
    ),
    GoRoute(
      path: AppRoutes.requestDetail,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => RequestDetailScreen(
        status: state.extra as RequestListStatus? ?? RequestListStatus.open,
      ),
    ),
    GoRoute(
      path: AppRoutes.supervisorRequests,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const SupervisorAgentRequestsScreen(),
    ),
    GoRoute(
      path: AppRoutes.supervisorResolveRequest,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const SupervisorResolveRequestScreen(),
    ),
    GoRoute(
      path: AppRoutes.supervisorCompletedRequest,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const SupervisorCompletedRequestScreen(),
    ),
    GoRoute(
      path: AppRoutes.transferRequests,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const TransferRequestsScreen(),
    ),
    GoRoute(
      path: AppRoutes.createTransferRequest,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const CreateTransferRequestScreen(),
    ),
    GoRoute(
      path: AppRoutes.transferRequestDetail,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => TransferRequestDetailScreen(
        state:
            state.extra as TransferRequestDetailState? ??
            TransferRequestDetailState.pendingVerification,
      ),
    ),
    GoRoute(
      path: AppRoutes.stockDetail,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => StockDetailScreen(
        stage: state.extra as StockStage? ?? StockStage.rawMaterial,
      ),
    ),
    GoRoute(
      path: AppRoutes.verificationDetail,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, state) => VerificationDetailScreen(
        status:
            state.extra as VerificationDetailStatus? ??
            VerificationDetailStatus.pending,
      ),
    ),
    GoRoute(
      path: AppRoutes.rejectCollection,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const RejectCollectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.supervisorExpense,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const SupervisorExpenseModuleScreen(),
    ),
    GoRoute(
      path: AppRoutes.supervisorMrfPeople,
      parentNavigatorKey: rootNavigatorKey,
      builder: (_, _) => const SupervisorMrfPeopleScreen(),
    ),

    // ── Auth routes ──────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      name: 'otp',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final phone = state.uri.queryParameters['phone'] ?? '';
        return OtpScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: AppRoutes.appLock,
      name: 'appLock',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const AppLockScreen(),
    ),

    // ── Miscellaneous standalone routes ──────────────────────────
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.details,
      name: 'details',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final featureName = state.uri.queryParameters['feature'] ?? '';
        return DetailsScreen(featureName: featureName);
      },
    ),
  ];
}

// ═══════════════════════════════════════════════════════════════════
//  ERROR / 404 PAGE
// ═══════════════════════════════════════════════════════════════════

class _ErrorPage extends StatelessWidget {
  const _ErrorPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                '404',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.pageNotFound, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                l10n.pageNotFoundMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.home),
                label: Text(l10n.returnHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
