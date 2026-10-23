import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/transfer_requests/view/supervisor_transfer_approval_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('selects a vehicle and opens the destination step', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const transfer = TransferModel(
      id: 'transfer-1',
      centerId: 'center-1',
      type: 'INTERNAL',
      status: 'PENDING',
      number: 'ES4-TRF-261022-001',
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
    const vehicles = [
      TransferVehicleModel(
        id: 'vehicle-1',
        number: 'GJ-05-EE-1001',
        ownership: 'COMPANY',
        capacityKg: 5000,
      ),
      TransferVehicleModel(
        id: 'vehicle-2',
        number: 'GJ-05-EE-1002',
        ownership: 'HIRED',
        transporterName: 'Shree Ram Transport',
        capacityKg: 5000,
      ),
      TransferVehicleModel(
        id: 'vehicle-3',
        number: 'GJ-05-EE-1003',
        ownership: 'HIRED',
        transporterName: 'Khodiyar Transport',
        capacityKg: 5000,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SupervisorTransferApprovalScreen(
          transfer: transfer,
          items: items,
          vehicles: vehicles,
          destinations: const [
            DestinationModel(id: 'center-1', name: 'Center One'),
            DestinationModel(
              id: 'destination-1',
              name: 'Bhatar Recycling Plant',
            ),
          ],
          onBack: () {},
          onApproved: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('supervisor-transfer-vehicle-dropdown')),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(
        find.byKey(const Key('supervisor-transfer-vehicle-sheet')),
      ),
      const Size(375, 346),
    );
    expect(
      find.byKey(const ValueKey('transfer-vehicle-vehicle-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('transfer-vehicle-vehicle-2')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('transfer-vehicle-vehicle-3')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('supervisor-transfer-other-hired')),
      findsOneWidget,
    );

    await tester.tap(find.text('GJ-05-EE-1001').last);
    await tester.pumpAndSettle();

    final continueButton = tester.widget<ElevatedButton>(
      find.byKey(const Key('supervisor-transfer-continue')),
    );
    expect(continueButton.onPressed, isNotNull);
    await tester.tap(find.byKey(const Key('supervisor-transfer-continue')));
    await tester.pumpAndSettle();

    expect(find.text('Select Destination'), findsOneWidget);
    expect(
      find.byKey(const Key('supervisor-transfer-destination-dropdown')),
      findsOneWidget,
    );

    final confirmBeforeSelection = tester.widget<ElevatedButton>(
      find.byKey(const Key('supervisor-transfer-confirm')),
    );
    expect(confirmBeforeSelection.onPressed, isNull);

    await tester.tap(
      find.byKey(const Key('supervisor-transfer-destination-dropdown')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bhatar Recycling Plant'), findsOneWidget);
    expect(find.text('Center One'), findsNothing);

    await tester.tap(
      find.byKey(
        const ValueKey('supervisor-transfer-destination-destination-1'),
      ),
    );
    await tester.pumpAndSettle();

    final confirmAfterSelection = tester.widget<ElevatedButton>(
      find.byKey(const Key('supervisor-transfer-confirm')),
    );
    expect(confirmAfterSelection.onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('supervisor-transfer-date-time')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('transfer-calendar-confirm')), findsOneWidget);
  });

  testWidgets('shows the complete Other Hired Truck section', (tester) async {
    tester.view.physicalSize = const Size(375, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SupervisorTransferApprovalScreen(
          transfer: const TransferModel(
            id: 'transfer-1',
            centerId: 'center-1',
            type: 'INTERNAL',
            status: 'PENDING',
            number: 'ES4-TRF-261022-001',
            requestedBy: 'user-1',
            requestedByName: 'Rahul Patel',
            requestedAt: '2026-10-22T11:15:00.000Z',
            syncState: 'synced',
          ),
          items: const [
            TransferItemModel(
              id: 'item-1',
              transferId: 'transfer-1',
              itemId: 'pet',
              name: 'PET Bottles',
              qty: 930.6,
              unitCode: 'KG',
            ),
          ],
          vehicles: const [],
          destinations: const [],
          onBack: () {},
          onApproved: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('supervisor-transfer-vehicle-dropdown')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('supervisor-transfer-other-hired')));
    await tester.pumpAndSettle();

    expect(find.text('Other Hired Truck'), findsOneWidget);
    expect(find.text('Capacity 5000 KG'), findsOneWidget);
    expect(
      find.byKey(const Key('supervisor-transfer-other-vehicle-number')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('supervisor-transfer-other-transporter')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('supervisor-transfer-other-fee')),
      findsOneWidget,
    );

    final continueButton = tester.widget<ElevatedButton>(
      find.byKey(const Key('supervisor-transfer-continue')),
    );
    expect(continueButton.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
