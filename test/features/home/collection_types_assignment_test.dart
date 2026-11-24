import 'package:eerl_app/features/home/widgets/collection_types.dart';
import 'package:eerl_app/features/home/widgets/home_app_bar.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget localized(Widget child) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );

  testWidgets('home shows only collection types assigned at active centre', (
    tester,
  ) async {
    await tester.pumpWidget(
      localized(
        CollectionTypes(
          channelLoader: () async => const [
            CenterChannelModel(
              centerId: 'centre-1',
              channel: 'D2D',
              showPrice: true,
              takesPayment: true,
            ),
            CenterChannelModel(
              centerId: 'centre-1',
              channel: 'RAMP',
              showPrice: true,
              takesPayment: true,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Only the types you collect at this centre'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('home-collection-type-d2d')), findsOneWidget);
    expect(find.byKey(const Key('home-collection-type-ramp')), findsOneWidget);
    expect(find.byKey(const Key('home-collection-type-mrf')), findsNothing);
  });

  testWidgets('home header shows chosen centre code beside the date', (
    tester,
  ) async {
    await tester.pumpWidget(
      localized(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: HomeAppBar(centerCode: 'TS-1'),
        ),
      ),
    );

    expect(find.textContaining('· TS-1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
