import 'package:eerl_app/core/providers/locale_provider.dart';
import 'package:eerl_app/core/theme/app_theme.dart';
import 'package:eerl_app/features/dashboard/view/main_dashboard_screen.dart';
import 'package:eerl_app/features/tasks/view/my_tasks_screen.dart';
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

  testWidgets('Tasks opens from expanded dashboard drawer', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(app(const MainDashboardScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('home-menu-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drawer-tasks-requests')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drawer-tasks')));
    await tester.pumpAndSettle();

    expect(find.byType(MyTasksScreen), findsOneWidget);
    expect(find.text('My Tasks'), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-nav-home')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('My Tasks matches open and closed Figma states', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(app(MyTasksScreen(onBack: () {})));
    await tester.pumpAndSettle();

    expect(find.text('Due Today, 5:00 PM'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('my_tasks_open_preview.png'),
    );

    await tester.tap(find.text('Closed (3)'));
    await tester.pumpAndSettle();
    expect(find.text('Completed: Today, 11:30 AM'), findsNWidgets(3));
    expect(find.text('Due Today, 5:00 PM'), findsNothing);
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('my_tasks_closed_preview.png'),
    );

    await tester.enterText(
      find.byKey(const Key('task-search-field')),
      'not available',
    );
    await tester.pumpAndSettle();
    expect(find.text('No Tasks for now'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
