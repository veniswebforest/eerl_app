import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/transfer_requests/view/transfer_request_detail_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('supervisor dispatch detail matches the supervisor view', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const transfer = TransferModel(
      id: 'transfer-1',
      centerId: 'center-1',
      centerName: 'EERL - Sector 4',
      type: 'INTERNAL',
      status: 'DISPATCHED',
      number: 'ES4-TRF-261022-001',
      destinationId: 'destination-1',
      destinationName: 'Bhatar Recycling Plant',
      plannedVehicleNumber: 'GJ-05-AB-1234',
      fixedQty: 2168.4,
      truckExpectedAt: '2026-10-22T15:15:00.000Z',
      requestedBy: 'user-1',
      requestedByName: 'Rahul Patel',
      requestedAt: '2026-10-22T11:15:00.000Z',
      syncState: 'synced',
    );
    const items = [
      TransferItemModel(
        id: 'item-1',
        transferId: 'transfer-1',
        itemId: 'pet',
        name: 'PET Bottles',
        qty: 930.6,
        unitCode: 'KG',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TransferRequestDetailScreen(
          transferId: transfer.id,
          roleLoader: () async => 'SUPERVISOR',
          detailLoader: (_) async => (transfer: transfer, items: items),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2168.40 KG'), findsOneWidget);
    expect(find.text('930.60 KG'), findsOneWidget);
    expect(find.text('EERL - Sector 4'), findsOneWidget);
    expect(find.text('center-1'), findsNothing);
    expect(find.text('Dispatch'), findsOneWidget);
    expect(find.text('Vehicle Information'), findsOneWidget);
    expect(find.text('GJ-05-AB-1234'), findsOneWidget);
    expect(find.text('4 Hours'), findsOneWidget);
    expect(
      find.byKey(const Key('supervisor-transfer-vehicle-information')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('transfer-vehicle-arrived')), findsNothing);
    await tester.scrollUntilVisible(find.text('Items to Transfer'), 300);
    expect(find.text('PET Bottles'), findsOneWidget);
    expect(find.text('Status Timeline'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
