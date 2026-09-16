import 'package:eerl_app/features/wallet/model/cash_request_detail_status.dart';
import 'package:eerl_app/features/wallet/view/cash_request_detail_screen.dart';
import 'package:eerl_app/features/wallet/view/wallet_tab_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cash request cards open their matching detail states', (
    tester,
  ) async {
    CashRequestDetailStatus? selectedStatus;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WalletTabScreen(
          onCashRequestTap: (status) => selectedStatus = status,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('expense-type-1')));
    await tester.pumpAndSettle();

    final pendingCard = find.text('Emergency Fuel');
    tester
        .widget<InkWell>(
          find.ancestor(of: pendingCard, matching: find.byType(InkWell)),
        )
        .onTap!();
    expect(selectedStatus, CashRequestDetailStatus.pending);

    final approvedCard = find.text('Credited to Wallet');
    tester
        .widget<InkWell>(
          find.ancestor(of: approvedCard, matching: find.byType(InkWell)),
        )
        .onTap!();
    expect(selectedStatus, CashRequestDetailStatus.approved);

    final rejectedCard = find.text('Rejected by Supervisor');
    tester
        .widget<InkWell>(
          find.ancestor(of: rejectedCard, matching: find.byType(InkWell)),
        )
        .onTap!();
    expect(selectedStatus, CashRequestDetailStatus.rejected);
  });

  for (final testCase in <(CashRequestDetailStatus, String)>[
    (CashRequestDetailStatus.pending, 'Waiting for Supervisor Approval'),
    (CashRequestDetailStatus.approved, 'Approved by Supervisor'),
    (CashRequestDetailStatus.rejected, 'Invalid / Incomplete Request'),
  ]) {
    testWidgets('renders responsive ${testCase.$1.name} cash request detail', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CashRequestDetailScreen(status: testCase.$1, onBack: _noop),
        ),
      );

      final stateText = find.textContaining(testCase.$2);
      await tester.ensureVisible(stateText);
      expect(stateText, findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('cash request detail uses Gujarati localization', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('gu'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CashRequestDetailScreen(
          status: CashRequestDetailStatus.approved,
          onBack: _noop,
        ),
      ),
    );

    expect(find.text('સુપરવાઇઝર દ્વારા મંજૂર'), findsOneWidget);
    expect(find.text('વર્ણન'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
