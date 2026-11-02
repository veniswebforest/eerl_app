import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/supervisor_expense/view/supervisor_expense_module_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('new category request badge shows the pending SQLite count', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const requests = [
      CategoryRequestModel(
        id: 'category-1',
        centerId: 'center-1',
        requestedBy: 'agent-1',
        name: 'Vehicle repair',
        status: 'PENDING',
        createdAt: '2026-11-02T05:00:00.000Z',
        syncState: 'synced',
      ),
      CategoryRequestModel(
        id: 'category-2',
        centerId: 'center-1',
        requestedBy: 'agent-2',
        name: 'Protective equipment',
        status: 'PENDING',
        createdAt: '2026-11-02T06:00:00.000Z',
        syncState: 'synced',
      ),
      CategoryRequestModel(
        id: 'category-3',
        centerId: 'center-1',
        requestedBy: 'agent-3',
        name: 'Fuel',
        status: 'APPROVED',
        createdAt: '2026-11-01T05:00:00.000Z',
        syncState: 'synced',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SupervisorExpenseModuleScreen(
          loadExpenses: () async => const [],
          loadCashRequests: () async => const [],
          loadCategoryRequests: () async => requests,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final badge = find.byKey(const Key('category-request-pending-count'));
    expect(badge, findsOneWidget);
    expect(
      find.descendant(of: badge, matching: find.text('2')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: badge,
        matching: find.byIcon(Icons.chevron_right_rounded),
      ),
      findsNothing,
    );
  });
}
