import 'package:eerl_app/features/home/widgets/home_app_bar.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('gu');
  });

  testWidgets('Gujarati date does not overflow the home app bar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('gu'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          drawer: Drawer(),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: HomeAppBar(),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('home-today-date')), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(HomeAppBar)).height,
      greaterThanOrEqualTo(45),
    );
  });

  testWidgets('home app bar remains overflow-free with larger Gujarati text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('gu'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          drawer: Drawer(),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: HomeAppBar(),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
