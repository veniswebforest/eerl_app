import 'package:eerl_app/core/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_dashboard_shell.dart';
import 'package:pickup_supervisor/features/profile/view/driver_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app as the EERL host builds it: its LocaleProvider above a
/// MaterialApp that follows the chosen locale.
Widget _host(LocaleProvider locale, Widget home) =>
    ChangeNotifierProvider.value(
      value: locale,
      child: Consumer<LocaleProvider>(
        builder: (context, provider, _) => MaterialApp(
          locale: provider.locale ?? const Locale('en'),
          supportedLocales: const [Locale('en'), Locale('gu'), Locale('hi')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: home,
        ),
      ),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  void size(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 1100);
    addTearDown(tester.view.reset);
  }

  testWidgets('Driver profile uses the app language selector', (tester) async {
    size(tester);
    final locale = LocaleProvider();
    await tester.pumpWidget(_host(locale, const DriverProfileScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile-language-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-language-gu')));
    await tester.pumpAndSettle();

    expect(locale.locale, const Locale('gu'));
    // The module's own texts follow: its language code now reads ગુ.
    expect(find.text('ગુ'), findsWidgets);
  });

  testWidgets('Pickup Supervisor profile uses the app language selector', (
    tester,
  ) async {
    size(tester);
    final locale = LocaleProvider();
    await tester.pumpWidget(
      _host(locale, const PickupSupervisorDashboardShell()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('supervisor-nav-profile')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('profile-language-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('profile-language-hi')));
    await tester.pumpAndSettle();

    expect(locale.locale, const Locale('hi'));
  });

  testWidgets('the language list opens right under its box', (tester) async {
    size(tester);
    await tester.pumpWidget(
      _host(LocaleProvider(), const DriverProfileScreen()),
    );
    await tester.pumpAndSettle();
    final box = tester.getRect(
      find.byKey(const Key('profile-language-selector')),
    );
    await tester.tap(find.byKey(const Key('profile-language-selector')));
    await tester.pumpAndSettle();
    final first = tester.getRect(find.byKey(const Key('profile-language-en')));
    final last = tester.getRect(find.byKey(const Key('profile-language-hi')));

    // Left and right edges line up with the box; the top sits 2px below it
    // (plus the list's 1px border).
    expect(first.left, closeTo(box.left + 1, 0.5));
    expect(first.right, closeTo(box.right - 1, 0.5));
    expect(first.top, closeTo(box.bottom + 2 + 1, 0.5));
    expect(last.top, greaterThan(first.bottom));

    // A tap outside closes it without changing the language.
    await tester.tapAt(const Offset(20, 900));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile-language-en')), findsNothing);
  });

  testWidgets('without the app the selector only shows the language', (
    tester,
  ) async {
    size(tester);
    await tester.pumpWidget(const MaterialApp(home: DriverProfileScreen()));
    await tester.pumpAndSettle();
    expect(find.text('En'), findsOneWidget);
    await tester.tap(find.byKey(const Key('profile-language-selector')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('profile-language-gu')), findsNothing);
  });
}
