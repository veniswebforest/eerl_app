import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/transfer_requests/view/transfer_request_detail_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('supervisor completes the designed transfer rejection flow', (
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
      status: 'PENDING',
      number: 'ES4-TRF-261022-001',
      fixedQty: 2168.4,
      estimatedExpense: 900,
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
    String? submittedReason;
    String? submittedRemarks;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TransferRequestDetailScreen(
          transferId: transfer.id,
          roleLoader: () async => 'SUPERVISOR',
          detailLoader: (_) async => (transfer: transfer, items: items),
          rejectHandler: (id, reason, remarks) async {
            submittedReason = reason;
            submittedRemarks = remarks;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('supervisor-transfer-reject')));
    await tester.pumpAndSettle();
    expect(find.text('Reject transfer'), findsOneWidget);
    expect(find.text('No Vehicle Available'), findsOneWidget);
    expect(find.text('Insufficient Yard Capacity'), findsOneWidget);
    expect(find.text('Incorrect Material'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
    final remarksField = tester.widget<TextField>(
      find.byKey(const Key('supervisor-transfer-reject-remarks')),
    );
    expect(remarksField.maxLength, 1000);

    await tester.tap(
      find.byKey(const ValueKey('supervisor-transfer-reject-reason-0')),
    );
    await tester.tap(
      find.byKey(const ValueKey('supervisor-transfer-reject-reason-2')),
    );
    await tester.enterText(
      find.byKey(const Key('supervisor-transfer-reject-remarks')),
      'All yard trucks are currently out. Try after 2 PM.',
    );
    await tester.tap(
      find.byKey(const Key('supervisor-transfer-confirm-rejection')),
    );
    await tester.pumpAndSettle();

    expect(submittedReason, 'No Vehicle Available, Incorrect Material');
    expect(
      submittedRemarks,
      'All yard trucks are currently out. Try after 2 PM.',
    );
    expect(
      find.byKey(const Key('supervisor-transfer-rejected-banner')),
      findsOneWidget,
    );
    expect(find.text('Request Rejected!'), findsOneWidget);
    expect(find.text('Rejected'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Reason for Reject'), 300);
    expect(
      find.textContaining('No Vehicle Available, Incorrect Material'),
      findsOneWidget,
    );
    expect(
      find.textContaining('All yard trucks are currently out'),
      findsOneWidget,
    );
    expect(find.text('Status Timeline'), findsNothing);

    await tester.tap(
      find.byKey(const Key('supervisor-transfer-rejected-banner-close')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('supervisor-transfer-rejected-banner')),
      findsNothing,
    );
    expect(find.text('Reason for Reject'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('supervisor pending detail shows actions and pending status', (
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
      status: 'PENDING',
      number: 'ES4-TRF-261022-001',
      destinationId: 'destination-1',
      destinationName: 'Bhatar Recycling Plant',
      fixedQty: 2168.4,
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

    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Waiting for Collection Manager'), findsNothing);
    expect(find.text('Vehicle Information'), findsNothing);
    expect(find.byKey(const Key('supervisor-transfer-reject')), findsOneWidget);
    expect(
      find.byKey(const Key('supervisor-transfer-approve')),
      findsOneWidget,
    );
    expect(find.text('Status Timeline'), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('transfer-request-route-icon'))),
      const Size.square(24),
    );
    expect(
      tester.getSize(
        find.byKey(const ValueKey('assets/icons/records/status_pending.svg')),
      ),
      const Size.square(20),
    );
    expect(tester.takeException(), isNull);
  });

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
      tester.getSize(
        find.byKey(
          const ValueKey('assets/icons/transfer_requests/status_dispatch.svg'),
        ),
      ),
      const Size.square(20),
    );
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

  testWidgets('supervisor completed detail shows dispatch evidence', (
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
      status: 'COMPLETED',
      number: 'ES4-TRF-261022-001',
      destinationName: 'Bhatar Recycling Plant',
      plannedVehicleNumber: 'GJ-05-AB-1234',
      vehiclePlate: 'GJ-05-BX-1234',
      driverName: 'Chandresh Prajapati',
      dispatchedWeight: 240.51,
      baleCount: 12,
      fixedQty: 1200.6,
      estimatedExpense: 900,
      truckExpectedAt: '2026-10-22T15:15:00.000Z',
      handedOverAt: '2026-08-16T09:32:00.000Z',
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
        qty: 270,
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

    expect(find.text('Transfer Completed'), findsOneWidget);
    expect(find.text('Estimated trip cost'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('supervisor-transfer-dispatch-evidence')),
      400,
    );
    expect(find.text('Stock in hand at the centre'), findsOneWidget);
    expect(find.text('GJ-05-BX-1234'), findsOneWidget);
    expect(find.text('Chandresh Prajapati'), findsOneWidget);
    expect(find.text('KG   240.51'), findsOneWidget);
    expect(find.text('Bales / boris'), findsOneWidget);
    expect(find.text('Free to Send'), findsNothing);
    expect(find.text('Status Timeline'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
