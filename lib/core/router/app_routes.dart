/// Static route path constants for type-safe navigation.
class AppRoutes {
  AppRoutes._();

  // ── Auth routes ──────────────────────────────────────────────────
  static const String splash = '/splash';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String appLock = '/app-lock';

  // ── Shell (bottom navigation) ────────────────────────────────────
  /// Home tab — also the shell root for the bottom navigation.
  static const String home = '/';

  /// Settings — accessible from profile / drawer.
  static const String settings = '/settings';

  // ── Feature routes ───────────────────────────────────────────────
  static const String roleSwitcher = '/role-switcher';
  static const String wallet = '/wallet';
  static const String logExpense = '/wallet/log-expense';
  static const String requestCash = '/wallet/request-cash';
  static const String expenseSubmitted = '/wallet/expense-submitted';
  static const String expenseClaimDetail = '/wallet/expense-claim';
  static const String cashRequestDetail = '/wallet/cash-request';
  static const String addCollection = '/collections/add';
  static const String collectionDetail = '/collections/detail';
  static const String collectionReceipt = '/collections/receipt';
  static const String collectionImagePreview = '/collections/image-preview';
  static const String configureMaterials = '/configure-materials';
  static const String ragpickerDirectory = '/ragpicker-directory';
  static const String notifications = '/notifications';
  static const String endMyDay = '/end-my-day';
  static const String helpSupport = '/help-support';
  static const String tasks = '/tasks';
  static const String taskDetail = '/tasks/detail';
  static const String supervisorTasks = '/supervisor/tasks';
  static const String assignSupervisorTask = '/supervisor/tasks/assign';
  static const String supervisorTaskDetail = '/supervisor/tasks/detail';
  static const String requests = '/requests';
  static const String raiseRequest = '/requests/raise';
  static const String requestDetail = '/requests/detail';
  static const String supervisorRequests = '/supervisor/requests';
  static const String supervisorResolveRequest = '/supervisor/requests/resolve';
  static const String supervisorCompletedRequest =
      '/supervisor/requests/completed';
  static const String transferRequests = '/transfer-requests';
  static const String createTransferRequest = '/transfer-requests/create';
  static const String transferRequestDetail = '/transfer-requests/detail';
  static const String stockDetail = '/stock/detail';
  static const String verificationDetail = '/verification/detail';
  static const String rejectCollection = '/verification/reject';
  static const String supervisorExpense = '/supervisor/expense';
  static const String supervisorMrfPeople = '/supervisor/mrf-people';

  // ── Legacy standalone ────────────────────────────────────────────
  static const String details = '/details';
}
