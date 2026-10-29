import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/transfer_requests/view/transfer_request_detail_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'agent transfer request detail displays estimated expense as designed',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const transfer = TransferModel(
        id: 'transfer-agent-1',
        centerId: 'center-1',
        centerName: 'EERL - Sector 4',
        type: 'INTERNAL',
        status: 'DISPATCHED',
        number: 'ES4-TRF-261022-001',
        destinationId: 'destination-1',
        destinationName: 'Bhatar Recycling Plant',
        fixedQty: 2168.4,
        estimatedExpense: 900,
        plannedVehicleNumber: 'GJ-05-AB-1234',
        requestedBy: 'user-1',
        requestedByName: 'Rahul Patel',
        requestedAt: '2026-10-22T11:15:00.000Z',
        syncState: 'synced',
      );
      const items = [
        TransferItemModel(
          id: 'item-1',
          transferId: 'transfer-agent-1',
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
            roleLoader: () async => 'AGENT',
            detailLoader: (_) async => (transfer: transfer, items: items),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Screen title and number
      expect(find.text('Transfer Request Details'), findsOneWidget);
      expect(find.text('ES4-TRF-261022-001'), findsOneWidget);

      // Request Information card rows
      expect(find.text('From Location'), findsOneWidget);
      expect(find.text('EERL - Sector 4'), findsOneWidget);
      expect(find.text('To Location'), findsOneWidget);
      expect(find.text('Bhatar Recycling Plant'), findsOneWidget);
      expect(find.text('Available Stock'), findsOneWidget);
      expect(find.text('2168.40 KG'), findsOneWidget);
      expect(find.text('Request Date & Time'), findsOneWidget);
      expect(find.textContaining('22 Oct'), findsOneWidget);
      expect(find.text('Requested By'), findsOneWidget);
      expect(find.text('Rahul Patel'), findsOneWidget);

      // Estimated Expense row must be displayed as requested
      expect(find.text('Estimated Expense'), findsOneWidget);
      expect(find.text('₹ 900'), findsOneWidget);

      // Free to send should not be shown on agent screen
      expect(find.text('Free to Send'), findsNothing);

      // Status section
      expect(find.text('Request Status'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'agent transfer request detail displays estimated expense in Gujarati',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const transfer = TransferModel(
        id: 'transfer-agent-2',
        centerId: 'center-1',
        centerName: 'EERL - Sector 4',
        type: 'INTERNAL',
        status: 'PENDING',
        number: 'ES4-TRF-261022-001',
        destinationName: 'Bhatar Recycling Plant',
        fixedQty: 2168.4,
        estimatedExpense: 900,
        requestedBy: 'user-1',
        requestedByName: 'Rahul Patel',
        requestedAt: '2026-10-22T11:15:00.000Z',
        syncState: 'synced',
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('gu'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TransferRequestDetailScreen(
            transferId: transfer.id,
            roleLoader: () async => 'AGENT',
            detailLoader: (_) async =>
                (transfer: transfer, items: const <TransferItemModel>[]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('અંદાજિત ખર્ચ'), findsOneWidget);
      expect(find.text('₹ 900'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
