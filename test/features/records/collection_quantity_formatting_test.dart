import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/records/widgets/collection_history_card.dart';
import 'package:eerl_app/features/records/widgets/collection_draft_card.dart';
import 'package:eerl_app/features/verification/widgets/verification_entry_card.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CollectionModel.formattedQuantity Unit Tests', () {
    test('formats mixed KG and PCS items as "320.20kg / 15pcs"', () {
      const model = CollectionModel(
        id: 'c1',
        centerId: 'center-1',
        agentId: 'agent-1',
        agentName: 'Agent One',
        channel: 'RAMP',
        status: 'APPROVED',
        handoverPhotoUrls: [],
        updatedAt: '2026-10-29T10:00:00Z',
        syncState: 'synced',
        totalKg: 320.2,
        totalPcs: 15,
        totalQty: 335.2,
      );

      expect(model.formattedQuantity, '320.20kg / 15pcs');
    });

    test('formats fractional PCS properly', () {
      const model = CollectionModel(
        id: 'c1',
        centerId: 'center-1',
        agentId: 'agent-1',
        agentName: 'Agent One',
        channel: 'RAMP',
        status: 'APPROVED',
        handoverPhotoUrls: [],
        updatedAt: '2026-10-29T10:00:00Z',
        syncState: 'synced',
        totalKg: 320.2,
        totalPcs: 15.5,
      );

      expect(model.formattedQuantity, '320.20kg / 15.50pcs');
    });

    test('formats KG-only collections as "320.20kg"', () {
      const model = CollectionModel(
        id: 'c2',
        centerId: 'center-1',
        agentId: 'agent-1',
        agentName: 'Agent One',
        channel: 'RAMP',
        status: 'APPROVED',
        handoverPhotoUrls: [],
        updatedAt: '2026-10-29T10:00:00Z',
        syncState: 'synced',
        totalKg: 320.2,
        totalPcs: 0,
      );

      expect(model.formattedQuantity, '320.20kg');
    });

    test('formats PCS-only collections as "15pcs"', () {
      const model = CollectionModel(
        id: 'c3',
        centerId: 'center-1',
        agentId: 'agent-1',
        agentName: 'Agent One',
        channel: 'RAMP',
        status: 'APPROVED',
        handoverPhotoUrls: [],
        updatedAt: '2026-10-29T10:00:00Z',
        syncState: 'synced',
        totalKg: 0,
        totalPcs: 15,
      );

      expect(model.formattedQuantity, '15pcs');
    });

    test('falls back to totalQty in KG when totalKg and totalPcs are 0', () {
      const model = CollectionModel(
        id: 'c4',
        centerId: 'center-1',
        agentId: 'agent-1',
        agentName: 'Agent One',
        channel: 'RAMP',
        status: 'APPROVED',
        handoverPhotoUrls: [],
        updatedAt: '2026-10-29T10:00:00Z',
        syncState: 'synced',
        totalQty: 42.5,
      );

      expect(model.formattedQuantity, '42.50kg');
    });

    test('returns "0.00kg" when all quantities are 0', () {
      const model = CollectionModel(
        id: 'c5',
        centerId: 'center-1',
        agentId: 'agent-1',
        agentName: 'Agent One',
        channel: 'RAMP',
        status: 'APPROVED',
        handoverPhotoUrls: [],
        updatedAt: '2026-10-29T10:00:00Z',
        syncState: 'synced',
      );

      expect(model.formattedQuantity, '0.00kg');
    });

    test('CollectionModel.fromMap parses total_kg and total_pcs', () {
      final model = CollectionModel.fromMap({
        'id': 'c1',
        'center_id': 'center-1',
        'agent_id': 'agent-1',
        'agent_name': 'Agent One',
        'channel': 'RAMP',
        'status': 'APPROVED',
        'handover_photo_urls': '[]',
        'updated_at': '2026-10-29T10:00:00Z',
        'sync_state': 'synced',
        'total_qty': 335.2,
        'total_kg': 320.2,
        'total_pcs': 15,
      });

      expect(model.totalKg, 320.2);
      expect(model.totalPcs, 15.0);
      expect(model.formattedQuantity, '320.20kg / 15pcs');
    });
  });

  group('SQLite query aggregation & Widget tests', () {
    final database = AppDatabase.instance;
    late String databasePath;

    setUpAll(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      databasePath = p.join(
        await getDatabasesPath(),
        'collection_quantity_formatting_test.db',
      );
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

      // Insert items (one KG item, one PCS item)
      await database.insert(DatabaseTables.items, {
        'id': 'item-kg',
        'name': 'Cardboard',
        'category_name': 'Paper',
        'material_type': 'NON_PLASTIC',
        'unit_code': 'KG',
        'unit_name': 'Kilogram',
        'is_active': 1,
      });
      await database.insert(DatabaseTables.items, {
        'id': 'item-pcs',
        'name': 'Plastic Drum',
        'category_name': 'Rigid',
        'material_type': 'PLASTIC',
        'unit_code': 'PCS',
        'unit_name': 'Pieces',
        'is_active': 1,
      });

      // Insert collection
      final nowUtc = DateTime.now().toUtc().toIso8601String();
      await database.insert(DatabaseTables.collections, {
        'id': 'col-1',
        'slip_number': 'RC-000246',
        'center_id': 'center-1',
        'agent_id': 'agent-1',
        'agent_name': 'Agent One',
        'channel': 'RAMP',
        'status': 'APPROVED',
        'collected_at': nowUtc,
        'updated_at': nowUtc,
        'sync_state': 'synced',
      });

      // Insert collection items: 320.20 KG and 15 PCS
      await database.insert(DatabaseTables.collectionItems, {
        'id': 'ci-1',
        'collection_id': 'col-1',
        'item_id': 'item-kg',
        'qty': 320.20,
        'sort_order': 0,
      });
      await database.insert(DatabaseTables.collectionItems, {
        'id': 'ci-2',
        'collection_id': 'col-1',
        'item_id': 'item-pcs',
        'qty': 15.0,
        'sort_order': 1,
      });
    });

    test('getAgentCollections aggregates both KG and PCS accurately', () async {
      final collections =
          await EerlLocalRepository.instance.getAgentCollections();
      expect(collections, hasLength(1));
      final col = collections.first;
      expect(col.slipNumber, 'RC-000246');
      expect(col.totalKg, 320.20);
      expect(col.totalPcs, 15.0);
      expect(col.formattedQuantity, '320.20kg / 15pcs');
    });

    test('getAgentCollections uses verified_qty when present', () async {
      // Update items with verified_qty: 310.00 KG and 12 PCS
      await database.update(
        DatabaseTables.collectionItems,
        {'verified_qty': 310.00},
        where: 'id = ?',
        whereArgs: ['ci-1'],
      );
      await database.update(
        DatabaseTables.collectionItems,
        {'verified_qty': 12.0},
        where: 'id = ?',
        whereArgs: ['ci-2'],
      );

      final collections =
          await EerlLocalRepository.instance.getAgentCollections();
      expect(collections, hasLength(1));
      final col = collections.first;
      expect(col.totalKg, 310.00);
      expect(col.totalPcs, 12.0);
      expect(col.formattedQuantity, '310.00kg / 12pcs');
    });

    testWidgets('CollectionHistoryCard renders "320.20kg / 15pcs"', (
      tester,
    ) async {
      const model = CollectionModel(
        id: 'col-1',
        slipNumber: 'RC-000246',
        centerId: 'center-1',
        agentId: 'agent-1',
        agentName: 'Agent One',
        channel: 'RAMP',
        status: 'APPROVED',
        handoverPhotoUrls: [],
        updatedAt: '2026-10-29T10:00:00Z',
        syncState: 'synced',
        totalKg: 320.20,
        totalPcs: 15.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CollectionHistoryCard(
              item: model,
              statusLabel: 'Approved',
            ),
          ),
        ),
      );

      expect(find.text('RC-000246'), findsOneWidget);
      expect(find.text('320.20kg / 15pcs'), findsOneWidget);
    });

    testWidgets('CollectionDraftCard renders "320.20kg / 15pcs"', (
      tester,
    ) async {
      const model = CollectionModel(
        id: 'col-draft',
        centerId: 'center-1',
        agentId: 'agent-1',
        agentName: 'Agent One',
        channel: 'RAMP',
        status: 'DRAFT',
        handoverPhotoUrls: [],
        updatedAt: '2026-10-29T10:00:00Z',
        syncState: 'pending',
        totalKg: 320.20,
        totalPcs: 15.0,
        itemCount: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CollectionDraftCard(
              item: model,
              pendingLabel: 'Pending Submission',
              discardLabel: 'Discard',
              continueLabel: 'Continue',
              onDiscard: () {},
              onContinue: () {},
            ),
          ),
        ),
      );

      expect(find.text('320.20kg / 15pcs'), findsOneWidget);
      expect(find.text('2 items'), findsOneWidget);
    });

    testWidgets('VerificationEntryCard renders "320.20kg / 15pcs • ₹35,550.00"', (
      tester,
    ) async {
      const model = CollectionModel(
        id: 'col-ver',
        slipNumber: 'RC-000246',
        centerId: 'center-1',
        centerName: 'Center One',
        agentId: 'agent-1',
        agentName: 'Agent One',
        channel: 'RAMP',
        status: 'SUBMITTED',
        handoverPhotoUrls: [],
        updatedAt: '2026-10-29T10:00:00Z',
        syncState: 'synced',
        totalKg: 320.20,
        totalPcs: 15.0,
        totalAmount: 35550.0,
        showPrice: true,
      );

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: VerificationEntryCard(entry: model),
          ),
        ),
      );

      expect(find.text('320.20kg / 15pcs • ₹35550.00'), findsOneWidget);
    });
  });
}
