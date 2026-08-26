/// Static route path constants for type-safe navigation.
class AppRoutes {
  AppRoutes._();

  // ── Auth routes ──────────────────────────────────────────────────
  static const String splash = '/splash';
  static const String login = '/login';
  static const String otp = '/otp';

  // ── Shell (bottom navigation) ────────────────────────────────────
  /// Home tab — also the shell root for the bottom navigation.
  static const String home = '/';

  /// Collections tab inside the bottom nav shell.
  static const String collections = '/collections';

  /// Records tab inside the bottom nav shell.
  static const String records = '/records';

  /// Profile tab inside the bottom nav shell.
  static const String profile = '/profile';

  /// Settings — accessible from profile / drawer.
  static const String settings = '/settings';

  // ── Feature sub-routes (pushed over the shell) ───────────────────
  static const String endMyDay = '/end-my-day';
  static const String wallet = '/wallet';
  static const String logExpense = '/log-expense';
  static const String notifications = '/notifications';
  static const String helpSupport = '/help-support';
  static const String configureMaterials = '/configure-materials';
  static const String tasks = '/tasks';
  static const String taskDetail = '/task-detail';
  static const String addCollection = '/add-collection';
  static const String collectionDetail = '/collection-detail';
  static const String expenseClaimDetail = '/expense-claim-detail';

  // ── Legacy standalone ────────────────────────────────────────────
  static const String details = '/details';
}
