import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/core/local_database/mobile_write_validator.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.instance;
  final repository = EerlLocalRepository.instance;
  late String databasePath;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(
      await getDatabasesPath(),
      'price_request_save_test.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.accessTokenKey: 'price-token',
    });
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'TS-3 Bhestan',
    });
    await database.insert(DatabaseTables.items, {
      'id': 'item-1',
      'name': 'PET Bottles',
      'category_name': 'Plastic',
      'unit_code': 'KG',
      'unit_name': 'Kilogram',
      'material_type': 'PLASTIC',
      'is_active': 1,
    });
    await database.insert(DatabaseTables.centerPrices, {
      'center_id': 'center-1',
      'item_id': 'item-1',
      'rate': 45,
      'from_name': 'SMC',
      'from_level': 'CHANNEL',
      'own': 0,
    });
    await database.setSyncMeta('active_center_id', 'center-1');
    await database.setSyncMeta('user_id', 'supervisor-1');
    await database.setSyncMeta('user_name', 'Supervisor One');
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('commits request and exact PUT outbox body atomically', () async {
    final id = await repository.savePriceRequest(
      itemId: 'item-1',
      requestedRate: 48,
      reason: 'Buyers near Surat pay more this month.',
    );

    final stored = (await database.query(DatabaseTables.priceRequests)).single;
    expect(stored['id'], id);
    expect(stored['center_id'], 'center-1');
    expect(stored['item_id'], 'item-1');
    expect(stored['current_rate'], 45.0);
    expect(stored['current_from_name'], 'SMC');
    expect(stored['current_from_level'], 'CHANNEL');
    expect(stored['requested_rate'], 48.0);
    expect(stored['status'], 'PENDING');
    expect(stored['raised_by_id'], 'supervisor-1');
    expect(stored['raised_by_name'], 'Supervisor One');
    expect(stored['sync_state'], 'pending');

    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(outbox['method'], 'PUT');
    expect(outbox['path'], '/price-requests/$id');
    expect(outbox['entity'], DatabaseTables.priceRequests);
    expect(outbox['entity_id'], id);
    expect(outbox['kind'], 'create');
    expect(jsonDecode(outbox['body']! as String), {
      'centerId': 'center-1',
      'materialItemId': 'item-1',
      'requestedRate': 48.0,
      'reason': 'Buyers near Surat pay more this month.',
    });
  });

  test('does not create a second pending request for the material', () async {
    await repository.savePriceRequest(
      itemId: 'item-1',
      requestedRate: 48,
      reason: 'First price request.',
    );

    await expectLater(
      repository.savePriceRequest(
        itemId: 'item-1',
        requestedRate: 49,
        reason: 'Second price request.',
      ),
      throwsA(
        isA<LocalWriteValidationException>().having(
          (error) => error.field,
          'field',
          'materialItemId',
        ),
      ),
    );
    expect(await database.query(DatabaseTables.priceRequests), hasLength(1));
    expect(await database.query(DatabaseTables.outbox), hasLength(1));
  });

  test('syncs exact payload and applies the server request response', () async {
    final id = await repository.savePriceRequest(
      itemId: 'item-1',
      requestedRate: 48,
      reason: 'Buyers near Surat pay more this month.',
    );
    late http.Request sent;
    final service = OutgoingSyncService(
      database: database,
      internetAccessChecker: () async => true,
      client: MockClient((request) async {
        sent = request;
        return http.Response(
          jsonEncode({
            'data': {
              'id': id,
              'centerId': 'center-1',
              'materialItemId': 'item-1',
              'currentRate': 45,
              'currentFrom': {'name': 'SMC', 'level': 'CHANNEL'},
              'requestedRate': 48,
              'reason': 'Buyers near Surat pay more this month.',
              'status': 'PENDING',
              'raisedBy': {'id': 'supervisor-1', 'name': 'Supervisor One'},
              'raisedAt': '2026-11-24T05:00:00.000Z',
              'decidedBy': null,
              'decidedAt': null,
              'rejectionReason': null,
              'updatedAt': '2026-11-24T05:00:01.000Z',
            },
          }),
          200,
        );
      }),
    );

    await service.drain();

    expect(sent.method, 'PUT');
    expect(sent.url.path, '/api/v1/mobile/price-requests/$id');
    expect(sent.headers['authorization'], 'Bearer price-token');
    expect(jsonDecode(sent.body), {
      'centerId': 'center-1',
      'materialItemId': 'item-1',
      'requestedRate': 48.0,
      'reason': 'Buyers near Surat pay more this month.',
    });
    expect(await database.query(DatabaseTables.outbox), isEmpty);
    final stored = (await database.query(DatabaseTables.priceRequests)).single;
    expect(stored['status'], 'PENDING');
    expect(stored['updated_at'], '2026-11-24T05:00:01.000Z');
    expect(stored['sync_state'], 'synced');
  });

  test('409 ALREADY_REQUESTED drops the duplicate local request', () async {
    await repository.savePriceRequest(
      itemId: 'item-1',
      requestedRate: 48,
      reason: 'Duplicate server request.',
    );
    final service = OutgoingSyncService(
      database: database,
      internetAccessChecker: () async => true,
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'error': {
              'code': 'ALREADY_REQUESTED',
              'message': 'A price request is already waiting.',
            },
          }),
          409,
        ),
      ),
    );

    await service.drain();

    expect(await database.query(DatabaseTables.outbox), isEmpty);
    expect(await database.query(DatabaseTables.priceRequests), isEmpty);
  });
}
