import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/features/home/widgets/home_assets.dart';
import 'package:eerl_app/features/home/widgets/todays_summary.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AgentHomeSummaryModel Unit Tests', () {
    test('AgentHomeSummaryModel parses collected_kg and collected_pcs', () {
      final model = AgentHomeSummaryModel.fromMap({
        'verified_entries': 5,
        'collected_kg': 120.5,
        'collected_pcs': 25.0,
        'transfer_requests': 2,
        'drafts': 1,
        'to_fix': 0,
      });

      expect(model.verifiedEntries, 5);
      expect(model.collectedKg, 120.5);
      expect(model.collectedPcs, 25.0);
      expect(model.transferRequests, 2);
      expect(model.drafts, 1);
      expect(model.toFix, 0);
    });

    test('AgentHomeSummaryModel defaults collectedPcs to 0', () {
      const model = AgentHomeSummaryModel(
        verifiedEntries: 0,
        collectedKg: 10,
        transferRequests: 0,
        drafts: 0,
        toFix: 0,
      );

      expect(model.collectedPcs, 0);
    });
  });

  group('getAgentHomeSummary & SummaryCard Tests', () {
    final database = AppDatabase.instance;
    late String databasePath;

    setUpAll(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      databasePath = p.join(
        await getDatabasesPath(),
        'todays_summary_quantity_test.db',
      );
      AppDatabase.setDatabasePathForTesting(databasePath);
      await deleteDatabase(databasePath);
    });

    tearDownAll(() async {
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
        'code': 'AAN',
      });
      await database.setSyncMeta('active_center_id', 'center-1');
      await database.setSyncMeta('user_id', 'agent-1');

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
        'name': 'PET Bottles',
        'category_name': 'Plastic',
        'material_type': 'PLASTIC',
        'unit_code': 'PCS',
        'unit_name': 'Piece',
        'is_active': 1,
      });
    });

    test('getAgentHomeSummary aggregates both KG and PCS collections using verified_qty', () async {
      final nowIso = DateTime.now().toUtc().toIso8601String();

      // Collection 1: KG item (qty 50, verified 45)
      await database.insert(DatabaseTables.collections, {
        'id': 'col-1',
        'center_id': 'center-1',
        'agent_id': 'agent-1',
        'agent_name': 'Agent One',
        'channel': 'RAMP',
        'status': 'APPROVED',
        'collected_at': nowIso,
        'updated_at': nowIso,
        'sync_state': 'synced',
      });
      await database.insert(DatabaseTables.collectionItems, {
        'id': 'ci-1',
        'collection_id': 'col-1',
        'item_id': 'item-kg',
        'qty': 50.0,
        'verified_qty': 45.0,
        'sort_order': 0,
      });

      // Collection 2: PCS item (qty 20, verified 18)
      await database.insert(DatabaseTables.collections, {
        'id': 'col-2',
        'center_id': 'center-1',
        'agent_id': 'agent-1',
        'agent_name': 'Agent One',
        'channel': 'RAMP',
        'status': 'SUBMITTED',
        'collected_at': nowIso,
        'updated_at': nowIso,
        'sync_state': 'synced',
      });
      await database.insert(DatabaseTables.collectionItems, {
        'id': 'ci-2',
        'collection_id': 'col-2',
        'item_id': 'item-pcs',
        'qty': 20.0,
        'verified_qty': 18.0,
        'sort_order': 0,
      });

      // Collection 3: DRAFT collection (should be ignored for collected counts)
      await database.insert(DatabaseTables.collections, {
        'id': 'col-draft',
        'center_id': 'center-1',
        'agent_id': 'agent-1',
        'agent_name': 'Agent One',
        'channel': 'RAMP',
        'status': 'DRAFT',
        'collected_at': nowIso,
        'updated_at': nowIso,
        'sync_state': 'synced',
      });
      await database.insert(DatabaseTables.collectionItems, {
        'id': 'ci-draft',
        'collection_id': 'col-draft',
        'item_id': 'item-kg',
        'qty': 999.0,
        'sort_order': 0,
      });

      final summary = await EerlLocalRepository.instance.getAgentHomeSummary();
      expect(summary.collectedKg, 45.0);
      expect(summary.collectedPcs, 18.0);
    });

    testWidgets('SummaryCard renders "45 KG / 18 PCS" in collected today card (EN)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                const summary = AgentHomeSummaryModel(
                  verifiedEntries: 2,
                  collectedKg: 45,
                  collectedPcs: 18,
                  transferRequests: 0,
                  drafts: 0,
                  toFix: 0,
                );
                final kgCount = summary.collectedKg.round();
                final pcsVal = summary.collectedPcs;
                final pcsCount = pcsVal % 1 == 0
                    ? pcsVal.toInt().toString()
                    : pcsVal.toStringAsFixed(1);
                final collectedValue =
                    '${context.l10n.weightKg(kgCount)} / $pcsCount ${context.l10n.collectionUnitPcs}';

                return SummaryCard(
                  iconAsset: HomeAssets.collected,
                  iconColor: AppColors.orchid,
                  iconBg: AppColors.orchidLight,
                  label: context.l10n.collectedToday,
                  value: collectedValue,
                  valueColor: AppColors.orchid,
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('45 KG / 18 PCS'), findsOneWidget);
    });

    testWidgets('SummaryCard renders "45 કિગ્રા / 18 નંગ" in collected today card (GU)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('gu'),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                const summary = AgentHomeSummaryModel(
                  verifiedEntries: 2,
                  collectedKg: 45,
                  collectedPcs: 18,
                  transferRequests: 0,
                  drafts: 0,
                  toFix: 0,
                );
                final kgCount = summary.collectedKg.round();
                final pcsVal = summary.collectedPcs;
                final pcsCount = pcsVal % 1 == 0
                    ? pcsVal.toInt().toString()
                    : pcsVal.toStringAsFixed(1);
                final collectedValue =
                    '${context.l10n.weightKg(kgCount)} / $pcsCount ${context.l10n.collectionUnitPcs}';

                return SummaryCard(
                  iconAsset: HomeAssets.collected,
                  iconColor: AppColors.orchid,
                  iconBg: AppColors.orchidLight,
                  label: context.l10n.collectedToday,
                  value: collectedValue,
                  valueColor: AppColors.orchid,
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('45 કિગ્રા / 18 નંગ'), findsOneWidget);
    });
  });
}
