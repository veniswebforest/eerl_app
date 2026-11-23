import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eerl_app/features/prices/model/price_ui_models.dart';
import 'package:eerl_app/features/prices/view/ask_price_change_screen.dart';
import 'package:eerl_app/features/prices/view/price_request_detail_screen.dart';
import 'package:eerl_app/features/prices/view/price_requests_screen.dart';
import 'package:eerl_app/features/prices/view/supervisor_prices_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestWidgetsFlutterBinding
            .instance
            .platformDispatcher
            .textScaleFactorTestValue =
        1;
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearTextScaleFactorTestValue();
  });

  testWidgets('all static price designs fit a phone in every locale', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const screens = <Widget>[
      SupervisorPricesScreen(),
      PriceRequestsScreen(),
      PriceRequestDetailScreen(state: PriceRequestState.waiting),
      PriceRequestDetailScreen(state: PriceRequestState.rejected),
      AskPriceChangeScreen(),
    ];

    for (final locale in const [Locale('en'), Locale('gu'), Locale('hi')]) {
      for (final screen in screens) {
        await tester.pumpWidget(
          _LocalizedPricesApp(locale: locale, home: screen),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('request tabs switch while preserving the static flow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const _LocalizedPricesApp(
        locale: Locale('en'),
        home: PriceRequestsScreen(),
      ),
    );

    await tester.tap(find.text('Decided (2)'));
    await tester.pumpAndSettle();

    expect(find.textContaining('PP Hard Plastics'), findsOneWidget);
    expect(find.textContaining('HDPE Rigid'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _LocalizedPricesApp extends StatelessWidget {
  const _LocalizedPricesApp({required this.locale, required this.home});

  final Locale locale;
  final Widget home;

  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData(fontFamily: 'Manrope'),
    home: home,
  );
}
