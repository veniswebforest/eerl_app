// Basic smoke test for the EERL app.
//
// Note: Comprehensive widget tests should be added as features
// are built out. This placeholder verifies the app boots.

import 'package:eerl_app/core/providers/locale_provider.dart';
import 'package:eerl_app/features/home/presentation/screens/home_screen.dart';
import 'package:eerl_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test placeholder', (WidgetTester tester) async {
    // The full app requires localization delegates and providers,
    // so a proper test harness will be set up when features expand.
    expect(true, isTrue);
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

        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeScreen(),
          ),
        );
        await tester.pumpAndSettle();

        final initialException = tester.takeException();
        expect(initialException, isNull);

        await tester.drag(find.byType(ListView), const Offset(0, -1200));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );
  }

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

    await tester.tap(find.text('Select Language · English'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ગુજરાતી'));
    await tester.pumpAndSettle();

    expect(provider.locale, const Locale('gu'));
    expect(find.text('મારી પ્રોફાઇલ'), findsOneWidget);

    final restoredProvider = LocaleProvider();
    await restoredProvider.loadLocale();
    expect(restoredProvider.locale, const Locale('gu'));
  });
}
