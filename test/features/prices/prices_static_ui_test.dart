import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/prices/model/price_ui_models.dart';
import 'package:eerl_app/features/prices/view/ask_price_change_screen.dart';
import 'package:eerl_app/features/prices/view/price_request_detail_screen.dart';
import 'package:eerl_app/features/prices/view/price_requests_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.instance;
  late String databasePath;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(await getDatabasesPath(), 'prices_ui_test.db');
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    await database.clearDatabaseOnLogout();
    await _seedPrices(database);
    TestWidgetsFlutterBinding
            .instance
            .platformDispatcher
            .textScaleFactorTestValue =
        1;
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher
        .clearTextScaleFactorTestValue();
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  testWidgets('all price designs fit a phone in every locale', (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final screens = <Widget>[
      const PriceRequestDetailScreen(request: _pendingRequest),
      const PriceRequestDetailScreen(request: _rejectedRequest),
      const AskPriceChangeScreen(requestContext: _requestContext),
    ];

    for (final locale in const [Locale('en'), Locale('gu'), Locale('hi')]) {
      for (final screen in screens) {
        await tester.pumpWidget(
          _LocalizedPricesApp(locale: locale, home: screen),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    }
  });

  testWidgets('request tabs show live SQLite request rows', (tester) async {
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      const _LocalizedPricesApp(
        locale: Locale('en'),
        home: PriceRequestsScreen(centerId: 'center-1'),
      ),
    );
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();

    await tester.tap(find.text('Decided (2)'));
    await tester.pump();

    expect(find.textContaining('PP Hard Plastics'), findsOneWidget);
    expect(find.textContaining('HDPE Rigid'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _seedPrices(AppDatabase database) async {
  await database.insert(DatabaseTables.centers, {
    'id': 'center-1',
    'name': 'TS-3 Bhestan',
  });
  await database.insert(DatabaseTables.myCenters, {
    'center_id': 'center-1',
    'is_primary': 1,
    'slip_last_count': 0,
  });
  await database.setSyncMeta('active_center_id', 'center-1');
  for (final item in const [
    {'id': 'pet', 'name': 'PET Bottles'},
    {'id': 'pp', 'name': 'PP Hard Plastics'},
    {'id': 'hdpe', 'name': 'HDPE Rigid'},
  ]) {
    await database.insert(DatabaseTables.items, {
      ...item,
      'category_name': 'Plastic',
      'unit_code': 'KG',
      'unit_name': 'Kilogram',
      'material_type': 'PLASTIC',
      'is_active': 1,
    });
    await database.insert(DatabaseTables.centerPrices, {
      'center_id': 'center-1',
      'item_id': item['id'],
      'rate': 45,
      'from_name': 'SMC',
      'from_level': 'CHANNEL',
      'own': 0,
    });
  }
  await database.insert(DatabaseTables.priceRequests, _pendingRequestMap);
  await database.insert(DatabaseTables.priceRequests, {
    ..._pendingRequestMap,
    'id': 'request-approved',
    'item_id': 'pp',
    'status': 'APPROVED',
    'requested_rate': 52,
  });
  await database.insert(DatabaseTables.priceRequests, {
    ..._pendingRequestMap,
    'id': 'request-rejected',
    'item_id': 'hdpe',
    'status': 'REJECTED',
    'requested_rate': 50,
    'rejection_reason': 'Price evidence is insufficient.',
  });
}

const _pendingRequestMap = <String, Object?>{
  'id': 'request-pending',
  'center_id': 'center-1',
  'item_id': 'pet',
  'current_rate': 45,
  'current_from_name': 'SMC',
  'current_from_level': 'CHANNEL',
  'requested_rate': 48,
  'reason': 'Buyers near Surat pay more this month.',
  'status': 'PENDING',
  'raised_by_id': 'supervisor-1',
  'raised_by_name': 'Supervisor One',
  'raised_at': '2026-11-24T05:00:00.000Z',
  'updated_at': '2026-11-24T05:00:00.000Z',
  'sync_state': 'synced',
};

const _requestContext = PriceRequestContext(
  itemId: 'pet',
  itemName: 'PET Bottles',
  unitCode: 'KG',
  currentRate: 45,
  fromName: 'SMC',
  fromLevel: 'CHANNEL',
);

const _pendingRequest = PriceRequestModel(
  id: 'request-pending',
  centerId: 'center-1',
  centerName: 'TS-3 Bhestan',
  itemId: 'pet',
  itemName: 'PET Bottles',
  unitCode: 'KG',
  currentRate: 45,
  currentFromName: 'SMC',
  currentFromLevel: 'CHANNEL',
  requestedRate: 48,
  reason: 'Buyers near Surat pay more this month.',
  status: 'PENDING',
  raisedById: 'supervisor-1',
  raisedByName: 'Supervisor One',
  raisedAt: '2026-11-24T05:00:00.000Z',
  updatedAt: '2026-11-24T05:00:00.000Z',
  syncState: 'synced',
);

const _rejectedRequest = PriceRequestModel(
  id: 'request-rejected',
  centerId: 'center-1',
  centerName: 'TS-3 Bhestan',
  itemId: 'hdpe',
  itemName: 'HDPE Rigid',
  unitCode: 'KG',
  currentRate: 45,
  requestedRate: 50,
  reason: 'Market price increased.',
  status: 'REJECTED',
  raisedById: 'supervisor-1',
  raisedByName: 'Supervisor One',
  raisedAt: '2026-11-24T05:00:00.000Z',
  rejectionReason: 'Price evidence is insufficient.',
  updatedAt: '2026-11-24T05:00:00.000Z',
  syncState: 'synced',
);

class _LocalizedPricesApp extends StatelessWidget {
  const _LocalizedPricesApp({required this.locale, required this.home});

  final Locale locale;
  final Widget home;

  @override
  Widget build(BuildContext context) => MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: ThemeData(fontFamily: 'Manrope'),
    home: home,
  );
}
