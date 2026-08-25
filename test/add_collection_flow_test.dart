import 'package:eerl_app/core/providers/locale_provider.dart';
import 'package:eerl_app/features/collection/view/add_collection_screen.dart';
import 'package:eerl_app/features/collection/view/collection_image_preview_screen.dart';
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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );

  testWidgets('collections opens add collection flow', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app(const MainDashboardScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bottom-nav-collections')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Collection'));
    await tester.pumpAndSettle();

    expect(find.byType(AddCollectionScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-nav-home')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('add collection initial state matches design', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app(AddCollectionScreen(onBack: () {})));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('add_collection_preview.png'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('conditional collection field selects a dropdown value', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app(AddCollectionScreen(onBack: () {})));
    await tester.tap(find.byKey(const Key('collection-type-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('D2D').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('collection-conditional-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('GJ-05-RT-9087'));
    await tester.pumpAndSettle();

    expect(find.text('GJ-05-RT-9087'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('collection photo step matches Figma layout', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(app(AddCollectionScreen(onBack: () {})));
    await tester.tap(find.byKey(const Key('collection-type-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ramp').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('collection-conditional-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ramesh Shah'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('collection-item-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PET Bottles'));
    await tester.tap(find.text('HDPE Rigid'));
    await tester.tap(find.text('PP Hard Plastics'));
    await tester.pumpAndSettle();
    final dropdownContinue = find.widgetWithText(OutlinedButton, 'Continue');
    await tester.ensureVisible(dropdownContinue);
    await tester.tap(dropdownContinue);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('collection-continue')));
    await tester.pumpAndSettle();

    expect(find.text('Upload Ramp Person Photo'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(6));
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('add_collection_step2_preview.png'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('collection image opens and closes full-screen preview', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const image = AssetImage(
      'assets/images/collection_detail/pet_collection.png',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(
                  context,
                ).push(CollectionImagePreviewScreen.route(image)),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('collection-image-preview-screen')),
      findsOneWidget,
    );
    await expectLater(
      find.byKey(const Key('collection-image-preview-screen')),
      matchesGoldenFile('collection_image_preview.png'),
    );

    await tester.tap(find.byKey(const Key('collection-image-preview-close')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('collection-image-preview-screen')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
