import 'dart:convert';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
      'cash_request_sync_test.db',
    );
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.accessTokenKey: 'cash-request-token',
    });
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await database.setSyncMeta('active_center_id', 'center-1');
    await database.setSyncMeta('user_id', 'user-1');
    await database.setSyncMeta('user_name', 'Agent One');
    await database.insert(DatabaseTables.centerBalances, {
      'center_id': 'center-1',
      'balance': 2000,
    });
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('sends queued cash request and applies server response', () async {
    final requestId = await repository.saveCashRequest(
      amount: 350,
      reason: 'Float for the weekend',
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
              'id': requestId,
              'number': 'CTR-CASH-001',
              'amount': 350,
              'reason': 'Float for the weekend',
              'status': 'PENDING',
              'createdAt': '2026-10-09T05:00:00.000Z',
              'updatedAt': '2026-10-09T05:00:01.000Z',
            },
          }),
          200,
        );
      }),
    );

    await service.drain();

    expect(sent.method, 'PUT');
    expect(sent.url.path, '/api/v1/mobile/cash-requests/$requestId');
    expect(sent.headers['authorization'], 'Bearer cash-request-token');
    expect(jsonDecode(sent.body), {
      'centerId': 'center-1',
      'amount': 350.0,
      'reason': 'Float for the weekend',
    });
    expect(await database.query(DatabaseTables.outbox), isEmpty);
    final stored = (await database.query(DatabaseTables.cashRequests)).single;
    expect(stored['number'], 'CTR-CASH-001');
    expect(stored['status'], 'PENDING');
    expect(stored['sync_state'], 'synced');
    expect(stored['updated_at'], '2026-10-09T05:00:01.000Z');
  });
}
