import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/home/widgets/collection_drafts.dart';
import 'package:eerl_app/features/records/model/records_view_flag.dart';
import 'package:eerl_app/features/records/widgets/collection_draft_card.dart';
import 'package:eerl_app/features/records/view/records_tab_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.instance;
  late String databasePath;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(await getDatabasesPath(), 'records_filter_test.db');
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.accessTokenKey: 'test-token',
    });
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await database.setSyncMeta('active_center_id', 'center-1');
    await database.setSyncMeta('user_id', 'agent-1');

    final nowUtc = DateTime.now().toUtc().toIso8601String();
    final yesterdayUtc = DateTime.now()
        .toUtc()
        .subtract(const Duration(days: 1))
        .toIso8601String();

    // Today's D2D draft
    await database.insert(DatabaseTables.collections, {
      'id': 'draft-d2d-today',
      'center_id': 'center-1',
      'agent_id': 'agent-1',
      'agent_name': 'Agent One',
      'channel': 'D2D',
      'status': 'DRAFT',
      'updated_at': nowUtc,
      'sync_state': 'pending',
    });

    // Yesterday's RAMP draft
    await database.insert(DatabaseTables.collections, {
      'id': 'draft-ramp-yesterday',
      'center_id': 'center-1',
      'agent_id': 'agent-1',
      'agent_name': 'Agent One',
      'channel': 'RAMP',
      'status': 'DRAFT',
      'updated_at': yesterdayUtc,
      'sync_state': 'pending',
    });
  });

  test('Unit test: getAgentCollections returns drafts', () async {
    final history = await EerlLocalRepository.instance.getAgentCollections();
    expect(history, isEmpty);
    final drafts = await EerlLocalRepository.instance.getAgentCollections(
      drafts: true,
    );
    expect(drafts, hasLength(2));
    expect(drafts.every((draft) => draft.centerName == 'Center One'), isTrue);
  });

  testWidgets('home draft card shows center name instead of center UUID', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: CollectionDrafts()),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    expect(find.text('Center One'), findsOneWidget);
    expect(find.text('center-1'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty history shows collection history message and icon', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.runAsync(() async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RecordsTabScreen(),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();

    expect(find.text('No Collection History for now'), findsOneWidget);
    expect(find.byKey(const Key('records-history-empty-icon')), findsOneWidget);
  });

  testWidgets('Records tab filters drafts by channel type and date properly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.runAsync(() async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RecordsTabScreen(initialView: RecordsViewFlag.drafts),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();

    // Verify Drafts segmented control is active and drafts are shown
    expect(find.text('Collection Drafts'), findsOneWidget);
    expect(find.text('D2D'), findsOneWidget);
    expect(find.text('RAMP'), findsOneWidget);

    // Type filters now live in the Figma filter bottom sheet and apply only
    // after the user confirms them.
    await tester.tap(find.byKey(const Key('records-date-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('records-type-d2d')));
    await tester.tap(find.byKey(const Key('records-apply-filter')));
    await tester.pumpAndSettle();
    expect(find.text('D2D'), findsOneWidget);
    expect(find.text('RAMP'), findsNothing);

    await tester.tap(find.byKey(const Key('records-date-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('records-type-ramp')));
    await tester.tap(find.byKey(const Key('records-apply-filter')));
    await tester.pumpAndSettle();
    expect(find.text('D2D'), findsNothing);
    expect(find.text('RAMP'), findsOneWidget);

    await tester.tap(find.byKey(const Key('records-date-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('records-type-all')));
    await tester.tap(find.byKey(const Key('records-apply-filter')));
    await tester.pumpAndSettle();
    expect(find.text('D2D'), findsOneWidget);
    expect(find.text('RAMP'), findsOneWidget);

    // Open Date filter sheet
    await tester.tap(find.byKey(const Key('records-date-filter')));
    await tester.pumpAndSettle();

    // Select Today and apply: only today's D2D draft should remain.
    await tester.tap(find.byKey(const Key('records-date-today')));
    await tester.tap(find.byKey(const Key('records-apply-filter')));
    await tester.pumpAndSettle();
    expect(find.text('D2D'), findsOneWidget);
    expect(find.text('RAMP'), findsNothing);

    // Open Date filter sheet again and select Yesterday
    await tester.tap(find.byKey(const Key('records-date-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('records-date-yesterday')));
    await tester.tap(find.byKey(const Key('records-apply-filter')));
    await tester.pumpAndSettle();
    expect(find.text('D2D'), findsNothing);
    expect(find.text('RAMP'), findsOneWidget);

    // Last 7 days restores both dates (the design no longer has date "All").
    await tester.tap(find.byKey(const Key('records-date-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('records-date-lastSevenDays')));
    await tester.tap(find.byKey(const Key('records-apply-filter')));
    await tester.pumpAndSettle();
    expect(find.text('D2D'), findsOneWidget);
    expect(find.text('RAMP'), findsOneWidget);

    // Search filter on drafts
    await tester.runAsync(() async {
      await tester.enterText(find.byType(TextField), 'RAMP');
      await Future<void>.delayed(const Duration(milliseconds: 400));
    });
    await tester.pump();
    expect(
      find.descendant(
        of: find.byType(CollectionDraftCard),
        matching: find.text('D2D'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(CollectionDraftCard),
        matching: find.text('RAMP'),
      ),
      findsOneWidget,
    );

    // Clear search filter
    await tester.runAsync(() async {
      await tester.enterText(find.byType(TextField), '');
      await Future<void>.delayed(const Duration(milliseconds: 400));
    });
    await tester.pump();
    expect(
      find.descendant(
        of: find.byType(CollectionDraftCard),
        matching: find.text('D2D'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(CollectionDraftCard),
        matching: find.text('RAMP'),
      ),
      findsOneWidget,
    );
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });
}
