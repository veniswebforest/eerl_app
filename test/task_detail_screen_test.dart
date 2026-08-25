import 'package:eerl_app/core/providers/locale_provider.dart';
import 'package:eerl_app/core/theme/app_theme.dart';
import 'package:eerl_app/features/dashboard/view/main_dashboard_screen.dart';
import 'package:eerl_app/features/tasks/model/task_list_item.dart';
import 'package:eerl_app/features/tasks/view/task_detail_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('Manrope');
    for (final asset in <String>[
      'assets/font/Manrope-Regular.ttf',
      'assets/font/Manrope-Medium.ttf',
      'assets/font/Manrope-SemiBold.ttf',
      'assets/font/Manrope-Bold.ttf',
    ]) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  });

  Widget app(Widget home) => ChangeNotifierProvider(
    create: (_) => LocaleProvider(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );

  void usePhoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  const task = TaskListItem(
    id: 'task-detail',
    status: TaskListStatus.open,
    priority: TaskPriority.high,
    scheduleKey: 'today',
  );

  testWidgets('task list item opens the Resolve Task screen', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(app(const MainDashboardScreen()));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.byKey(const Key('home-menu-button')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const Key('drawer-tasks-requests')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drawer-tasks')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('task-1')));
    await tester.pumpAndSettle();

    expect(find.byType(TaskDetailScreen), findsOneWidget);
    expect(find.text('Resolve Task'), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-nav-home')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('task detail switches from empty to filled proof state', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(app(TaskDetailScreen(task: task, onBack: () {})));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 200));

    final initialButton = tester.widget<ElevatedButton>(
      find.byKey(const Key('mark-task-completed-button')),
    );
    expect(initialButton.onPressed, isNull);
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('task_detail_empty_preview.png'),
    );

    await tester.tap(find.byKey(const Key('capture-task-proof')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('remove-task-proof-0')), findsOneWidget);
    final filledButton = tester.widget<ElevatedButton>(
      find.byKey(const Key('mark-task-completed-button')),
    );
    expect(filledButton.onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filled Figma state renders on a compact phone', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      app(TaskDetailScreen(task: task, onBack: () {}, initiallyFilled: true)),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 200));

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('task_detail_filled_preview.png'),
    );
    expect(tester.takeException(), isNull);
  });
}
