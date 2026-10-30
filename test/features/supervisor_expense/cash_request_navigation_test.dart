import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/supervisor_expense/view/supervisor_expense_module_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.instance;
  late String databasePath;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(
      await getDatabasesPath(),
      'cash_request_navigation_test.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await database.setSyncMeta('active_center_id', 'center-1');
    await database.setSyncMeta('user_id', 'supervisor-1');
    await database.setSyncMeta('user_name', 'Supervisor One');
    await database.insert(DatabaseTables.cashRequests, {
      'id': 'cash-1',
      'number': 'CR-001',
      'center_id': 'center-1',
      'requested_by': 'agent-1',
      'requested_by_name': 'Agent One',
      'amount': 1200.0,
      'reason': 'Route advance',
      'status': 'PENDING',
      'created_at': '2026-10-30T05:00:00.000Z',
      'sync_state': 'synced',
    });
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  testWidgets('cash approval returns to cash tab with cash request toast', (
    tester,
  ) async {
    await _pumpModule(tester);
    await tester.tap(find.text('Cash Request'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('supervisor-cash-pending-0')));
    await tester.pumpAndSettle();
    final approve = tester
        .widget<ElevatedButton>(
          find.byKey(const Key('supervisor-cash-approve')),
        )
        .onPressed!;
    await _invokeAsync(tester, approve);

    expect(tester.takeException(), isNull);
    late List<Map<String, Object?>> rows;
    await tester.runAsync(() async {
      rows = await database.query(DatabaseTables.cashRequests);
    });
    expect(rows.single['status'], 'APPROVED');
    expect(
      find.byKey(const Key('supervisor-cash-request-tab-active')),
      findsOneWidget,
    );
    expect(find.text('Cash Request Approved!'), findsOneWidget);
    expect(find.text('Cash Request Approved Successfully'), findsOneWidget);
    expect(find.text('Expense Rejected!'), findsNothing);
  });

  testWidgets('cash rejection returns to cash tab with cash request toast', (
    tester,
  ) async {
    await _pumpModule(tester);
    await tester.tap(find.text('Cash Request'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('supervisor-cash-pending-0')));
    await tester.pumpAndSettle();
    tester
        .widget<OutlinedButton>(find.byKey(const Key('supervisor-cash-reject')))
        .onPressed!();
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('supervisor-cash-reject-reason-0')),
    );
    await tester.pump();
    final confirmRejection = tester
        .widget<ElevatedButton>(
          find.byKey(const Key('supervisor-cash-confirm-rejection')),
        )
        .onPressed!;
    await _invokeAsync(tester, confirmRejection);

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const Key('supervisor-cash-request-tab-active')),
      findsOneWidget,
    );
    expect(find.text('Cash Request Rejected!'), findsOneWidget);
    expect(find.text('Cash Request Rejected Successfully'), findsOneWidget);
    expect(find.text('Expense Rejected!'), findsNothing);
  });
}

Future<void> _pumpModule(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.runAsync(() async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SupervisorExpenseModuleScreen(syncAfterDecision: () async {}),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 500));
  });
  await tester.pump();
}

Future<void> _invokeAsync(WidgetTester tester, VoidCallback callback) async {
  await tester.runAsync(() async {
    callback();
    await Future<void>.delayed(const Duration(seconds: 1));
    await tester.pump();
    await Future<void>.delayed(const Duration(milliseconds: 500));
  });
  await tester.pump();
}
