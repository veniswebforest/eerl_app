import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/wallet/model/cash_request_detail_status.dart';
import 'package:eerl_app/features/wallet/view/cash_request_detail_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CashRequestModel request({
    required String status,
    String? decisionNote,
    String? decisionRemarks,
  }) => CashRequestModel(
    id: 'cash-request-id',
    number: 'AAN-CSH-261029-004',
    centerId: 'center-id',
    requestedBy: 'agent-id',
    requestedByName: 'Kiran Rathod',
    amount: 2750.50,
    reason: 'Vehicle fuel advance',
    status: status,
    decidedByName: 'Supervisor Name',
    decisionNote: decisionNote,
    decisionRemarks: decisionRemarks,
    createdAt: '2026-10-29T04:45:00.000Z',
    updatedAt: '2026-10-29T05:00:00.000Z',
    syncState: 'synced',
  );

  Future<void> pumpScreen(
    WidgetTester tester, {
    required CashRequestModel model,
    required CashRequestDetailStatus status,
  }) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CashRequestDetailScreen(cashRequest: model, status: status),
      ),
    );
  }

  testWidgets('shows cash request values from the local row', (tester) async {
    await pumpScreen(
      tester,
      model: request(status: 'PENDING'),
      status: CashRequestDetailStatus.pending,
    );

    expect(find.text('AAN-CSH-261029-004'), findsOneWidget);
    expect(find.text('₹2,750.50'), findsOneWidget);
    expect(find.text('Kiran Rathod'), findsOneWidget);
    expect(find.text('Vehicle fuel advance'), findsNWidgets(2));
    expect(find.textContaining('#REQ-2026-088'), findsNothing);
    expect(find.text('₹1000'), findsNothing);
    expect(find.textContaining('08:15 AM'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('approved note uses the request amount', (tester) async {
    await pumpScreen(
      tester,
      model: request(status: 'APPROVED'),
      status: CashRequestDetailStatus.approved,
    );

    expect(
      find.text('Note: ₹2,750.50 credited to your active cash wallet balance.'),
      findsOneWidget,
    );
    expect(find.textContaining('₹1,000'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rejection uses stored reason and remarks', (tester) async {
    await pumpScreen(
      tester,
      model: request(
        status: 'REJECTED',
        decisionNote: 'Exceeds advance limit',
        decisionRemarks: 'Existing balance is sufficient.',
      ),
      status: CashRequestDetailStatus.rejected,
    );

    expect(find.textContaining('Exceeds advance limit'), findsOneWidget);
    expect(
      find.textContaining('Existing balance is sufficient.'),
      findsOneWidget,
    );
    expect(find.textContaining('Invalid / Incomplete Request'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
