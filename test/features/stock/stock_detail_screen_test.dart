import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/stock/model/stock_item.dart';
import 'package:eerl_app/features/stock/view/stock_detail_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the supervisor RM detail design with stock data', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StockDetailScreen(
          stage: StockStage.rawMaterial,
          centerNameLoader: () async => 'EERL – Surat South',
          stockLoader: (_) async => const [
            StockModel(
              id: 'stock-1',
              centerId: 'center-1',
              centerName: 'EERL – Surat South',
              itemId: 'pet',
              name: 'PET Bottles',
              stage: 'RM',
              qty: 980,
              unitCode: 'KG',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('RM Detail'), findsOneWidget);
    expect(find.text('Stock Center : EERL – Surat South'), findsOneWidget);
    expect(find.text('PET Bottles'), findsOneWidget);
    expect(find.text('980.00 KG'), findsOneWidget);
    expect(find.text('Bin: RM-01'), findsNothing);
    expect(find.text('10m ago'), findsNothing);
    expect(find.byKey(const Key('stock-detail-back')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the task-style empty state when stock is unavailable', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: StockDetailScreen(
          stage: StockStage.rawMaterial,
          stockLoader: (_) async => const [],
          centerNameLoader: () async => 'EERL – Surat South',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('RM Detail'), findsOneWidget);
    expect(find.text('Stock Center : EERL – Surat South'), findsOneWidget);
    expect(find.text('No Stock for now'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
