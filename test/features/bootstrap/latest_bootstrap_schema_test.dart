import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/bootstrap/data/bootstrap_database_applier.dart';
import 'package:eerl_app/features/bootstrap/model/bootstrap_response.dart';
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
    databasePath = p.join(await getDatabasesPath(), 'latest_bootstrap.db');
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test('stores category audit and planned transfer vehicle fields', () async {
    final data = BootstrapData.fromJson({
      'cursor': 'latest-1',
      'hasMore': false,
      'full': true,
      'tables': {
        'centers': {
          'replace': [
            {'id': 'center-1', 'name': 'Center One'},
          ],
        },
        'destinations': {
          'replace': [
            {'id': 'destination-1', 'name': 'Recycler One'},
          ],
        },
        'transfer_vehicles': {
          'replace': [
            {
              'id': 'truck-1',
              'number': 'GJ-05-EE-1001',
              'ownership': 'HIRED',
              'transporter_name': 'Shree Ram Transport',
              'vehicle_type': 'Truck',
              'capacity_kg': 1200,
            },
          ],
        },
        'category_requests': {
          'upserts': [
            {
              'id': 'category-request-1',
              'center_id': 'center-1',
              'requested_by': 'agent-1',
              'requested_by_name': 'Agent One',
              'name': 'Tyre repair',
              'reason': 'Punctures',
              'status': 'REJECTED',
              'decided_by_name': 'Supervisor One',
              'decided_at': '2026-10-08T10:00:00.000Z',
              'decision_reason': 'Already available',
              'created_at': '2026-10-08T09:00:00.000Z',
            },
          ],
        },
        'transfers': {
          'upserts': [
            {
              'id': 'transfer-1',
              'center_id': 'center-1',
              'type': 'STOCK_TRANSFER',
              'status': 'APPROVED',
              'destination_id': 'destination-1',
              'destination_name': 'Recycler One',
              'transfer_vehicle_id': 'truck-1',
              'planned_vehicle_number': 'GJ-05-EE-1001',
              'planned_vehicle_ownership': 'HIRED',
              'transporter_name': 'Shree Ram Transport',
              'transfer_fee': 1800,
              'vehicle_differs': 0,
              'requested_by': 'agent-1',
              'requested_by_name': 'Agent One',
              'requested_at': '2026-10-08T09:00:00.000Z',
            },
          ],
        },
      },
    });

    await BootstrapDatabaseApplier(database: database).apply(data);

    final vehicle = (await database.query(
      DatabaseTables.transferVehicles,
    )).single;
    expect(vehicle['number'], 'GJ-05-EE-1001');
    expect(vehicle['ownership'], 'HIRED');

    final category = (await database.query(
      DatabaseTables.categoryRequests,
    )).single;
    expect(category['requested_by_name'], 'Agent One');
    expect(category['decided_by_name'], 'Supervisor One');
    expect(category['decision_reason'], 'Already available');

    final transfer = (await database.query(DatabaseTables.transfers)).single;
    expect(transfer['transfer_vehicle_id'], 'truck-1');
    expect(transfer['planned_vehicle_number'], 'GJ-05-EE-1001');
    expect(transfer['transfer_fee'], 1800.0);
    expect(transfer['vehicle_differs'], 0);
    expect(await database.getSyncMeta('cursor'), 'latest-1');
  });
}
