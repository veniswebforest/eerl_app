import 'dart:convert';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_data_source.dart';
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
    databasePath = p.join(await getDatabasesPath(), 'transfer_decision.db');
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.accessTokenKey: 'transfer-token',
    });
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await database.insert(DatabaseTables.destinations, {
      'id': 'destination-1',
      'name': 'Recycler One',
    });
    await database.insert(DatabaseTables.transferVehicles, {
      'id': 'truck-1',
      'number': 'GJ-05-EE-1001',
      'ownership': 'HIRED',
      'transporter_name': 'Shree Ram Transport',
    });
    await database.setSyncMeta('user_name', 'Supervisor One');
    await _insertTransfer(database, 'transfer-1');
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test(
    'approval stores arranged hired truck and queues API mutation',
    () async {
      await repository.approveTransfer(
        transferId: 'transfer-1',
        destinationId: 'destination-1',
        transferVehicleId: 'truck-1',
        transferFee: 1800,
        vehicleArrivalTime: DateTime.utc(2026, 10, 10, 4, 30),
        note: '  Load the dry bales first.  ',
      );

      final transfer = (await database.query(DatabaseTables.transfers)).single;
      expect(transfer['status'], 'APPROVED');
      expect(transfer['planned_vehicle_number'], 'GJ-05-EE-1001');
      expect(transfer['planned_vehicle_ownership'], 'HIRED');
      expect(transfer['transfer_fee'], 1800.0);
      expect(transfer['dispatch_note'], 'Load the dry bales first.');
      expect(transfer['note'], isNull);
      expect(transfer['decided_by_name'], 'Supervisor One');
      expect(transfer['sync_state'], 'pending');

      final outbox = (await database.query(DatabaseTables.outbox)).single;
      expect(outbox['method'], 'POST');
      expect(outbox['path'], '/transfers/transfer-1/approve');
      expect(outbox['kind'], 'approve');
      expect(jsonDecode(outbox['body']! as String), {
        'destinationFacilityId': 'destination-1',
        'vehicleArrivalTime': '2026-10-10T04:30:00.000Z',
        'vehicle': {'transferVehicleId': 'truck-1', 'transferFee': 1800.0},
        'note': 'Load the dry bales first.',
      });
    },
  );

  test('rejection updates locally and queues reason', () async {
    await repository.rejectTransfer(
      transferId: 'transfer-1',
      reason: 'No vehicle available.',
    );

    final transfer = (await database.query(DatabaseTables.transfers)).single;
    expect(transfer['status'], 'REJECTED');
    expect(transfer['rejection_reason'], 'No vehicle available.');
    expect(transfer['sync_state'], 'pending');
    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(outbox['path'], '/transfers/transfer-1/reject');
    expect(jsonDecode(outbox['body']! as String), {
      'reason': 'No vehicle available.',
    });
  });

  test('approval note is limited to 150 characters', () async {
    await expectLater(
      repository.approveTransfer(
        transferId: 'transfer-1',
        destinationId: 'destination-1',
        transferVehicleId: 'truck-1',
        transferFee: 1800,
        note: List.filled(151, 'x').join(),
      ),
      throwsA(
        isA<TransferDecisionValidationException>().having(
          (error) => error.message,
          'message',
          'Note must be 150 characters or fewer.',
        ),
      ),
    );

    final transfer = (await database.query(DatabaseTables.transfers)).single;
    expect(transfer['status'], 'REQUESTED');
    expect(transfer['dispatch_note'], isNull);
    expect(await database.query(DatabaseTables.outbox), isEmpty);
  });

  test('approval response applies nested dispatch note', () async {
    await repository.approveTransfer(
      transferId: 'transfer-1',
      destinationId: 'destination-1',
      transferVehicleId: 'truck-1',
      transferFee: 1800,
      note: 'Initial note',
    );
    final service = OutgoingSyncService(
      database: database,
      internetAccessChecker: () async => true,
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'data': {
              'status': 'APPROVED',
              'dispatch': {'note': 'Updated note from server'},
            },
          }),
          200,
        ),
      ),
    );

    await service.drain();

    final transfer = (await database.query(DatabaseTables.transfers)).single;
    expect(transfer['dispatch_note'], 'Updated note from server');
    expect(transfer['sync_state'], 'synced');
    expect(await database.query(DatabaseTables.outbox), isEmpty);
  });

  test(
    'refused approval is removed and transfer returns to requested',
    () async {
      await repository.approveTransfer(
        transferId: 'transfer-1',
        destinationId: 'destination-1',
        transferVehicleId: 'truck-1',
        transferFee: 1800,
      );
      final service = OutgoingSyncService(
        database: database,
        internetAccessChecker: () async => true,
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'error': {'code': 'VEHICLE_INACTIVE'},
            }),
            422,
          ),
        ),
      );

      await service.drain();

      expect(await database.query(DatabaseTables.outbox), isEmpty);
      final transfer = (await database.query(DatabaseTables.transfers)).single;
      expect(transfer['status'], 'REQUESTED');
      expect(transfer['destination_id'], isNull);
      expect(transfer['planned_vehicle_number'], isNull);
      expect(transfer['transfer_fee'], isNull);
      expect(transfer['sync_state'], 'synced');
    },
  );
}

Future<void> _insertTransfer(AppDatabase database, String id) =>
    database.insert(DatabaseTables.transfers, {
      'id': id,
      'center_id': 'center-1',
      'type': 'STOCK_TRANSFER',
      'status': 'REQUESTED',
      'requested_by': 'agent-1',
      'requested_by_name': 'Agent One',
      'requested_at': '2026-10-09T05:00:00.000Z',
      'sync_state': 'synced',
    });
