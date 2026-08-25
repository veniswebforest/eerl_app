import 'package:eerl_app/core/providers/locale_provider.dart';
import 'package:eerl_app/core/theme/app_theme.dart';
import 'package:eerl_app/features/configure_material/view/configure_material_screen.dart';
import 'package:eerl_app/features/dashboard/view/main_dashboard_screen.dart';
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

  testWidgets('drawer opens configure material screen', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(app(const MainDashboardScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('home-menu-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drawer-configure-material')));
    await tester.pumpAndSettle();

    expect(find.byType(ConfigureMaterialScreen), findsOneWidget);
    expect(find.text('Materials'), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-nav-home')), findsNothing);
  });

  testWidgets('material UI supports tabs, selection, reorder and save', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(app(ConfigureMaterialScreen(onBack: () {})));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('configure_material_preview.png'),
    );

    await tester.tap(find.text('Non-Plastic (10)'));
    await tester.pumpAndSettle();
    expect(find.text('Metals'), findsOneWidget);

    await tester.tap(find.text('Plastic (12)'));
    await tester.pumpAndSettle();
    final petBefore = tester.getTopLeft(find.text('PET Bottles')).dy;
    final hdpeBefore = tester.getTopLeft(find.text('HDPE Rigid')).dy;
    expect(petBefore, lessThan(hdpeBefore));

    await tester.drag(
      find.byType(ReorderableDragStartListener).first,
      const Offset(0, 160),
    );
    await tester.pumpAndSettle();
    final petAfter = tester.getTopLeft(find.text('PET Bottles')).dy;
    final hdpeAfter = tester.getTopLeft(find.text('HDPE Rigid')).dy;
    expect(hdpeAfter, lessThan(petAfter));

    await tester.tap(find.byKey(const Key('configure-material-save')));
    await tester.pumpAndSettle();
    expect(find.text('Sequence saved successfully'), findsOneWidget);
    expect(find.text('Plastic (25)'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.byKey(const Key('configure-material-save')),
          )
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });
}
