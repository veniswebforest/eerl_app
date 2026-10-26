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
        vehicleArrivalTime: DateTime.utc(2099, 10, 10, 4, 30),
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
        'vehicleArrivalTime': '2099-10-10T04:30:00.000Z',
        'vehicle': {'transferVehicleId': 'truck-1', 'transferFee': 1800.0},
        'note': 'Load the dry bales first.',
      });
    },
  );

  test('vehicle dropdown only reads bootstrap transfer vehicles', () async {
    await database.insert(DatabaseTables.vehicles, {
      'id': 'configured-truck-1',
      'number': 'VH-001',
      'center_id': 'center-1',
      'plate_number': 'GJ-05-AB-4321',
      'driver_name': 'Ketan Patel',
      'is_active': 1,
      'sync_state': 'synced',
    });

    final vehicles = await repository.getTransferVehicles();

    expect(vehicles, hasLength(1));
    expect(vehicles.single.id, 'truck-1');
    expect(vehicles.single.number, 'GJ-05-EE-1001');
    expect(vehicles.single.transporterName, 'Shree Ram Transport');
    expect(vehicles.single.ownership, 'HIRED');
  });

  test('company truck queues the exact approve payload', () async {
    await database.insert(DatabaseTables.transferVehicles, {
      'id': 'company-truck-1',
      'number': 'GJ-05-AB-4321',
      'ownership': 'COMPANY',
      'vehicle_type': 'Pickup Truck',
      'capacity_kg': 3500,
    });

    await repository.approveTransfer(
      transferId: 'transfer-1',
      destinationId: 'destination-1',
      transferVehicleId: 'company-truck-1',
      vehicleArrivalTime: DateTime.utc(2099, 10, 24, 4),
    );

    final transfer = (await database.query(DatabaseTables.transfers)).single;
    expect(transfer['transfer_vehicle_id'], 'company-truck-1');
    expect(transfer['planned_vehicle_ownership'], 'COMPANY');
    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(jsonDecode(outbox['body']! as String), {
      'destinationFacilityId': 'destination-1',
      'vehicleArrivalTime': '2099-10-24T04:00:00.000Z',
      'vehicle': {'transferVehicleId': 'company-truck-1'},
    });
  });

  test('current active center is not available as a destination', () async {
    await database.insert(DatabaseTables.destinations, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await repository.selectCenter('center-1');

    final destinations = await repository.getDestinations();

    expect(destinations.map((destination) => destination.id), [
      'destination-1',
    ]);
    await expectLater(
      repository.approveTransfer(
        transferId: 'transfer-1',
        destinationId: 'center-1',
        transferVehicleId: 'truck-1',
        transferFee: 1800,
      ),
      throwsA(
        isA<TransferDecisionValidationException>().having(
          (error) => error.message,
          'message',
          'Choose a destination other than the current center.',
        ),
      ),
    );
    expect(await database.query(DatabaseTables.outbox), isEmpty);
  });

  test('other hired truck queues the exact approve payload', () async {
    await repository.approveTransfer(
      transferId: 'transfer-1',
      destinationId: 'destination-1',
      vehicleNumber: 'gj-05-xy-7788',
      transporterName: ' Shree Ram Transport ',
      transferFee: 1800,
      vehicleArrivalTime: DateTime.utc(2099, 10, 24, 4),
      note: ' Load before noon. ',
    );

    final transfer = (await database.query(DatabaseTables.transfers)).single;
    expect(transfer['planned_vehicle_number'], 'GJ-05-XY-7788');
    expect(transfer['planned_vehicle_ownership'], 'HIRED');
    expect(transfer['transporter_name'], 'Shree Ram Transport');
    expect(transfer['transfer_fee'], 1800.0);
    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(jsonDecode(outbox['body']! as String), {
      'destinationFacilityId': 'destination-1',
      'vehicleArrivalTime': '2099-10-24T04:00:00.000Z',
      'vehicle': {
        'vehicleNumber': 'GJ-05-XY-7788',
        'transporterName': 'Shree Ram Transport',
        'transferFee': 1800.0,
      },
      'note': 'Load before noon.',
    });
  });

  test('approval rejects a past arrival without changing local data', () async {
    await expectLater(
      repository.approveTransfer(
        transferId: 'transfer-1',
        destinationId: 'destination-1',
        transferVehicleId: 'truck-1',
        transferFee: 1800,
        vehicleArrivalTime: DateTime.utc(2000, 1, 1),
      ),
      throwsA(
        isA<TransferDecisionValidationException>().having(
          (error) => error.message,
          'message',
          'Vehicle arrival date and time cannot be in the past.',
        ),
      ),
    );

    final transfer = (await database.query(DatabaseTables.transfers)).single;
    expect(transfer['status'], 'REQUESTED');
    expect(transfer['truck_expected_at'], isNull);
    expect(await database.query(DatabaseTables.outbox), isEmpty);
  });

  test('transfer list only returns the selected home center', () async {
    await database.insert(DatabaseTables.centers, {
      'id': 'center-2',
      'name': 'Center Two',
    });
    await _insertTransfer(database, 'transfer-2', centerId: 'center-2');

    await repository.selectCenter('center-1');
    final centerOneTransfers = await repository.getTransfers();

    expect(centerOneTransfers.map((item) => item.id), ['transfer-1']);

    await repository.selectCenter('center-2');
    final centerTwoTransfers = await repository.getTransfers();

    expect(centerTwoTransfers.map((item) => item.id), ['transfer-2']);
  });

  test('rejection updates locally and queues reason', () async {
    await repository.rejectTransfer(
      transferId: 'transfer-1',
      reason: 'No vehicle available.',
      remarks: 'All yard trucks are out until 2 PM.',
    );

    final transfer = (await database.query(DatabaseTables.transfers)).single;
    expect(transfer['status'], 'REJECTED');
    expect(transfer['rejection_reason'], 'No vehicle available.');
    expect(
      transfer['rejection_remarks'],
      'All yard trucks are out until 2 PM.',
    );
    expect(transfer['sync_state'], 'pending');
    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(outbox['path'], '/transfers/transfer-1/reject');
    expect(jsonDecode(outbox['body']! as String), {
      'reason': 'No vehicle available.',
      'remarks': 'All yard trucks are out until 2 PM.',
    });
  });

  test(
    'rejection payload keeps the remarks key when remarks are empty',
    () async {
      await repository.rejectTransfer(
        transferId: 'transfer-1',
        reason: 'Plant is not taking PET this week.',
      );

      final outbox = (await database.query(DatabaseTables.outbox)).single;
      expect(jsonDecode(outbox['body']! as String), {
        'reason': 'Plant is not taking PET this week.',
        'remarks': null,
      });
    },
  );

  test('rejection outbox sync posts to the reject endpoint', () async {
    await repository.rejectTransfer(
      transferId: 'transfer-1',
      reason: 'Plant is not taking PET this week.',
      remarks: 'Try again next week.',
    );
    var requestSent = false;
    final service = OutgoingSyncService(
      database: database,
      internetAccessChecker: () async => true,
      client: MockClient((request) async {
        requestSent = true;
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/mobile/transfers/transfer-1/reject');
        expect(jsonDecode(request.body), {
          'reason': 'Plant is not taking PET this week.',
          'remarks': 'Try again next week.',
        });
        return http.Response(
          jsonEncode({
            'data': {
              'status': 'REJECTED',
              'rejection': {
                'reason': 'Plant is not taking PET this week.',
                'remarks': 'Try again next week.',
                'by': {'name': 'Supervisor One'},
                'at': '2026-10-23T07:00:00.000Z',
              },
            },
          }),
          200,
        );
      }),
    );

    await service.drain();

    expect(requestSent, isTrue);
    expect(await database.query(DatabaseTables.outbox), isEmpty);
    final transfer = (await database.query(DatabaseTables.transfers)).single;
    expect(transfer['status'], 'REJECTED');
    expect(transfer['rejection_reason'], 'Plant is not taking PET this week.');
    expect(transfer['rejection_remarks'], 'Try again next week.');
    expect(transfer['decided_by_name'], 'Supervisor One');
    expect(transfer['approved_at'], '2026-10-23T07:00:00.000Z');
    expect(transfer['sync_state'], 'synced');
  });

  test('rejection remarks allow 1000 characters but reject 1001', () async {
    final acceptedRemarks = List.filled(1000, 'x').join();
    await repository.rejectTransfer(
      transferId: 'transfer-1',
      reason: 'No Vehicle Available',
      remarks: acceptedRemarks,
    );
    final accepted = (await database.query(DatabaseTables.transfers)).single;
    expect(accepted['rejection_remarks'], acceptedRemarks);

    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
    await database.insert(DatabaseTables.destinations, {
      'id': 'destination-1',
      'name': 'Recycler One',
    });
    await database.setSyncMeta('user_name', 'Supervisor One');
    await _insertTransfer(database, 'transfer-1');

    await expectLater(
      repository.rejectTransfer(
        transferId: 'transfer-1',
        reason: 'No Vehicle Available',
        remarks: List.filled(1001, 'x').join(),
      ),
      throwsA(
        isA<TransferDecisionValidationException>().having(
          (error) => error.message,
          'message',
          'Rejection remarks must be 1000 characters or fewer.',
        ),
      ),
    );
    final rejected = (await database.query(DatabaseTables.transfers)).single;
    expect(rejected['status'], 'REQUESTED');
    expect(rejected['rejection_remarks'], isNull);
    expect(await database.query(DatabaseTables.outbox), isEmpty);
  });

  test('a failed unrecognized-remarks outbox retries unchanged', () async {
    await repository.rejectTransfer(
      transferId: 'transfer-1',
      reason: 'No Vehicle Available',
      remarks: 'The Bhatar truck is booked till Friday.',
    );
    final sentBodies = <String>[];
    var attempts = 0;
    final service = OutgoingSyncService(
      database: database,
      internetAccessChecker: () async => true,
      client: MockClient((request) async {
        attempts++;
        sentBodies.add(request.body);
        if (attempts == 1) {
          return http.Response(
            jsonEncode({
              'error': {'code': 'UNRECOGNIZED_KEYS'},
            }),
            400,
          );
        }
        return http.Response(
          jsonEncode({
            'data': {
              'status': 'REJECTED',
              'rejection': {
                'reason': 'No Vehicle Available',
                'remarks': 'The Bhatar truck is booked till Friday.',
              },
            },
          }),
          200,
        );
      }),
    );

    await service.drain();
    final failed = (await database.query(DatabaseTables.outbox)).single;
    expect(failed['status'], 'failed');
    expect(failed['last_error'], 'HTTP 400 UNRECOGNIZED_KEYS');

    await service.drain();

    expect(attempts, 2);
    expect(sentBodies[1], sentBodies[0]);
    expect(await database.query(DatabaseTables.outbox), isEmpty);
    final transfer = (await database.query(DatabaseTables.transfers)).single;
    expect(
      transfer['rejection_remarks'],
      'The Bhatar truck is booked till Friday.',
    );
    expect(transfer['sync_state'], 'synced');
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

  test('422 approval refusal stays failed for agent review', () async {
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

    final outbox = (await database.query(DatabaseTables.outbox)).single;
    expect(outbox['status'], 'failed');
    expect(outbox['last_error'], 'HTTP 422 VEHICLE_INACTIVE');
    final transfer = (await database.query(DatabaseTables.transfers)).single;
    expect(transfer['status'], 'APPROVED');
    expect(transfer['destination_id'], 'destination-1');
    expect(transfer['transfer_fee'], 1800.0);
    expect(transfer['sync_state'], 'failed');
  });
}

Future<void> _insertTransfer(
  AppDatabase database,
  String id, {
  String centerId = 'center-1',
}) => database.insert(DatabaseTables.transfers, {
  'id': id,
  'center_id': centerId,
  'type': 'STOCK_TRANSFER',
  'status': 'REQUESTED',
  'requested_by': 'agent-1',
  'requested_by_name': 'Agent One',
  'requested_at': '2026-10-09T05:00:00.000Z',
  'sync_state': 'synced',
});
