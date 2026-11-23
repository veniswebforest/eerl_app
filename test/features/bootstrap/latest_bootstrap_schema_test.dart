import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/bootstrap/data/bootstrap_database_applier.dart';
import 'package:eerl_app/features/bootstrap/model/bootstrap_response.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_data_source.dart';
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
              'dispatch_note': 'Load the dry bales first.',
              'rejection_reason': 'No Vehicle Available',
              'rejection_remarks': 'The truck is booked till Friday.',
              'vehicle_differs': 0,
              'requested_by': 'agent-1',
              'requested_by_name': 'Agent One',
              'requested_at': '2026-10-08T09:00:00.000Z',
            },
          ],
        },
        'notifications': {
          'upserts': [
            {
              'id': 'notification-1',
              'type': 'TASK_ASSIGNED',
              'title': 'New task',
              'body': 'Check the material bay.',
              'deep_link': '/tasks',
              'role': 'AGENT',
              'center_id': 'center-1',
              'created_at': '2026-10-20T09:30:00.000Z',
              'read_at': null,
            },
          ],
        },
        'tasks': {
          'upserts': [
            {
              'id': 'task-1',
              'center_id': 'center-1',
              'assigned_to': 'agent-1',
              'assigned_to_name': 'Agent One',
              'assigned_by': 'supervisor-1',
              'assigned_by_name': 'Supervisor One',
              'title': 'Verify the scale',
              'description': 'Use the reference photos.',
              'priority': 'NORMAL',
              'status': 'PENDING',
              'due_at': '2026-10-31T04:00:00.000Z',
              'photo_urls': '["https://example.test/task-reference.jpg"]',
              'reference_photo_urls': '[]',
              'created_at': '2026-10-30T09:00:00.000Z',
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
    expect(transfer['dispatch_note'], 'Load the dry bales first.');
    expect(transfer['rejection_reason'], 'No Vehicle Available');
    expect(transfer['rejection_remarks'], 'The truck is booked till Friday.');
    expect(transfer['vehicle_differs'], 0);
    final notification = (await database.query(
      DatabaseTables.notifications,
    )).single;
    expect(notification['role'], 'AGENT');
    expect(notification['center_id'], 'center-1');
    final task = (await database.query(DatabaseTables.tasks)).single;
    expect(task['photo_urls'], '["https://example.test/task-reference.jpg"]');
    expect(task['reference_photo_urls'], '[]');
    expect(await database.getSyncMeta('cursor'), 'latest-1');

    await database.update(
      DatabaseTables.transfers,
      const {'sync_state': 'failed'},
      where: 'id = ?',
      whereArgs: const ['transfer-1'],
    );

    await BootstrapDatabaseApplier(database: database).apply(
      BootstrapData.fromJson({
        'cursor': 'latest-2',
        'hasMore': false,
        'full': false,
        'tables': {
          'transfer_vehicles': {
            'replace': [
              {
                'id': 'truck-2',
                'number': 'GJ-05-EE-2002',
                'ownership': 'COMPANY',
              },
            ],
          },
          'transfers': {
            'upserts': [
              {
                'id': 'transfer-2',
                'center_id': 'center-1',
                'type': 'STOCK_TRANSFER',
                'status': 'APPROVED',
                'destination_id': 'destination-1',
                'destination_name': 'Recycler One',
                'transfer_vehicle_id': 'truck-retired-on-server',
                'planned_vehicle_number': 'GJ-05-EE-3003',
                'planned_vehicle_ownership': 'HIRED',
                'requested_by': 'agent-1',
                'requested_by_name': 'Agent One',
                'requested_at': '2026-10-08T09:00:00.000Z',
              },
            ],
          },
        },
      }),
    );

    final refreshedVehicles = await database.query(
      DatabaseTables.transferVehicles,
    );
    expect(refreshedVehicles.map((row) => row['id']), ['truck-2']);
    final refreshedTransfer = (await database.query(
      DatabaseTables.transfers,
      where: 'id = ?',
      whereArgs: const ['transfer-1'],
    )).single;
    expect(refreshedTransfer['transfer_vehicle_id'], isNull);
    expect(refreshedTransfer['planned_vehicle_number'], 'GJ-05-EE-1001');
    expect(refreshedTransfer['planned_vehicle_ownership'], 'HIRED');
    expect(refreshedTransfer['sync_state'], 'failed');
    final serverTransfer = (await database.query(
      DatabaseTables.transfers,
      where: 'id = ?',
      whereArgs: const ['transfer-2'],
    )).single;
    expect(serverTransfer['transfer_vehicle_id'], isNull);
    expect(serverTransfer['planned_vehicle_number'], 'GJ-05-EE-3003');
    expect(serverTransfer['sync_state'], 'synced');
    expect(await database.getSyncMeta('cursor'), 'latest-2');
  });

  test(
    'applies me.supervisor.photoUrl to sync_meta supervisor_photo_url',
    () async {
      final applier = BootstrapDatabaseApplier(database: database);
      final dataWithSupervisor = BootstrapData.fromJson({
        'cursor': 'sup-1',
        'hasMore': false,
        'full': false,
        'me': {
          'user': {
            'id': 'agent-1',
            'name': 'Agent One',
            'phone': '9876543210',
            'photoUrl': 'https://example.com/user.jpg',
          },
          'supervisor': {
            'name': 'Supervisor One',
            'phone': '9876543211',
            'photoUrl': 'https://example.com/supervisor.jpg',
          },
        },
        'tables': {},
      });

      await applier.apply(dataWithSupervisor);

      expect(await database.getSyncMeta('user_id'), 'agent-1');
      expect(await database.getSyncMeta('user_name'), 'Agent One');
      expect(await database.getSyncMeta('user_phone'), '9876543210');
      expect(
        await database.getSyncMeta('user_photo_url'),
        'https://example.com/user.jpg',
      );
      expect(await database.getSyncMeta('supervisor_name'), 'Supervisor One');
      expect(await database.getSyncMeta('supervisor_phone'), '9876543211');
      expect(
        await database.getSyncMeta('supervisor_photo_url'),
        'https://example.com/supervisor.jpg',
      );

      // When supervisor is null
      final dataWithoutSupervisor = BootstrapData.fromJson({
        'cursor': 'sup-2',
        'hasMore': false,
        'full': false,
        'me': {
          'user': {'id': 'agent-1', 'name': 'Agent One', 'phone': '9876543210'},
          'supervisor': null,
        },
        'tables': {},
      });

      await applier.apply(dataWithoutSupervisor);

      expect(await database.getSyncMeta('supervisor_name'), isNull);
      expect(await database.getSyncMeta('supervisor_phone'), isNull);
      expect(await database.getSyncMeta('supervisor_photo_url'), isNull);
    },
  );

  test(
    'stores fixed-point assignments, zones, prices, and document fields',
    () async {
      final applier = BootstrapDatabaseApplier(database: database);
      await applier.apply(
        BootstrapData.fromJson({
          'cursor': 'fixed-point-1',
          'hasMore': false,
          'full': false,
          'me': {
            'centers': [
              {
                'id': 'center-1',
                'isPrimary': true,
                'assignment': [
                  {
                    'type': 'D2D',
                    'zoneIds': ['zone-1'],
                  },
                  {
                    'type': 'RAMP',
                    'zoneIds': ['zone-1'],
                  },
                ],
              },
            ],
          },
          'tables': {
            'zones': {
              'replace': [
                {
                  'id': 'zone-1',
                  'code': 'Z1',
                  'name': 'Zone One',
                  'is_active': 1,
                },
              ],
            },
            'items': {
              'replace': [
                {
                  'id': 'item-fixed',
                  'name': 'PET Bottles',
                  'category_name': 'Plastic',
                  'unit_code': 'KG',
                  'unit_name': 'Kilogram',
                  'material_type': 'PLASTIC',
                  'colour': '#00A86B',
                  'is_active': 1,
                },
              ],
            },
            'center_prices': {
              'replace': [
                {
                  'center_id': 'center-1',
                  'item_id': 'item-fixed',
                  'rate': 21.5,
                  'from_name': 'Center One',
                  'from_level': 'CENTER',
                  'own': 1,
                },
              ],
            },
            'center_channels': {
              'replace': [
                {
                  'center_id': 'center-1',
                  'channel': 'D2D',
                  'show_price': 1,
                  'takes_payment': 1,
                },
                {
                  'center_id': 'center-1',
                  'channel': 'MRF',
                  'show_price': 0,
                  'takes_payment': 0,
                },
                {
                  'center_id': 'center-1',
                  'channel': 'RAMP',
                  'show_price': 1,
                  'takes_payment': 1,
                },
              ],
            },
            'destinations': {
              'replace': [
                {
                  'id': 'other-llp',
                  'name': 'Other Facility',
                  'company_code': 'LLP2',
                },
              ],
            },
          },
        }),
      );

      final assignments = await database.query(
        DatabaseTables.myAssignments,
        orderBy: 'channel',
      );
      expect(assignments.map((row) => row['channel']), ['D2D', 'RAMP']);
      expect(assignments.first['zone_ids'], '["zone-1"]');
      expect(
        (await database.query(DatabaseTables.zones)).single['name'],
        'Zone One',
      );
      expect(
        (await database.query(DatabaseTables.centerPrices)).single['rate'],
        21.5,
      );
      expect(
        (await database.query(
          DatabaseTables.destinations,
        )).single['company_code'],
        'LLP2',
      );

      final local = EerlLocalDataSource(database: database);
      expect(
        (await local.getChannels(
          centerId: 'center-1',
        )).map((channel) => channel.channel),
        ['D2D', 'RAMP'],
      );
      expect(
        await local.getAssignedZoneNames(centerId: 'center-1', channel: 'D2D'),
        ['Zone One'],
      );

      for (final vehicle in <Map<String, Object?>>[
        {
          'id': 'vehicle-assigned',
          'center_id': 'center-1',
          'plate_number': 'GJ-05-AA-1001',
          'zone_id': 'zone-1',
          'is_active': 1,
          'sync_state': 'synced',
        },
        {
          'id': 'vehicle-no-zone',
          'center_id': 'center-1',
          'plate_number': 'GJ-05-AA-1002',
          'zone_id': null,
          'is_active': 1,
          'sync_state': 'synced',
        },
        {
          'id': 'vehicle-other-zone',
          'center_id': 'center-1',
          'plate_number': 'GJ-05-AA-1003',
          'zone_id': 'zone-2',
          'is_active': 1,
          'sync_state': 'synced',
        },
        {
          'id': 'vehicle-other-center',
          'center_id': 'center-2',
          'plate_number': 'GJ-05-AA-1004',
          'zone_id': 'zone-1',
          'is_active': 1,
          'sync_state': 'synced',
        },
      ]) {
        await database.insert(DatabaseTables.vehicles, vehicle);
      }
      for (final ragpicker in <Map<String, Object?>>[
        {
          'id': 'ragpicker-assigned',
          'center_id': 'center-1',
          'name': 'Assigned Ragpicker',
          'zone_id': 'zone-1',
          'is_active': 1,
          'sync_state': 'synced',
        },
        {
          'id': 'ragpicker-no-zone',
          'center_id': 'center-1',
          'name': 'No Zone Ragpicker',
          'zone_id': null,
          'is_active': 1,
          'sync_state': 'synced',
        },
        {
          'id': 'ragpicker-other-zone',
          'center_id': 'center-1',
          'name': 'Other Zone Ragpicker',
          'zone_id': 'zone-2',
          'is_active': 1,
          'sync_state': 'synced',
        },
        {
          'id': 'ragpicker-other-center',
          'center_id': 'center-2',
          'name': 'Other Center Ragpicker',
          'zone_id': 'zone-1',
          'is_active': 1,
          'sync_state': 'synced',
        },
      ]) {
        await database.insert(DatabaseTables.ragpickers, ragpicker);
      }
      for (final labour in <Map<String, Object?>>[
        {
          'id': 'labour-assigned',
          'center_id': 'center-1',
          'name': 'Assigned Labour',
          'role': 'LABOUR',
          'zone_id': 'zone-1',
          'is_active': 1,
          'sync_state': 'synced',
        },
        {
          'id': 'labour-no-zone',
          'center_id': 'center-1',
          'name': 'No Zone Labour',
          'role': 'LABOUR',
          'zone_id': null,
          'is_active': 1,
          'sync_state': 'synced',
        },
        {
          'id': 'labour-other-zone',
          'center_id': 'center-1',
          'name': 'Other Zone Labour',
          'role': 'LABOUR',
          'zone_id': 'zone-2',
          'is_active': 1,
          'sync_state': 'synced',
        },
        {
          'id': 'labour-other-center',
          'center_id': 'center-2',
          'name': 'Other Center Labour',
          'role': 'LABOUR',
          'zone_id': 'zone-1',
          'is_active': 1,
          'sync_state': 'synced',
        },
      ]) {
        await database.insert(DatabaseTables.mrfPeople, labour);
      }

      expect(
        (await local.getVehicles(centerId: 'center-1')).map((row) => row.id),
        ['vehicle-assigned', 'vehicle-no-zone'],
      );
      expect(
        (await local.getRagpickers(
          centerId: 'center-1',
          activeOnly: true,
        )).map((row) => row.id),
        ['ragpicker-assigned', 'ragpicker-no-zone'],
      );
      expect(
        (await local.getMrfPeople(
          centerId: 'center-1',
          role: 'LABOUR',
        )).map((row) => row.id),
        ['labour-assigned', 'labour-no-zone', 'labour-other-zone'],
      );
      await database.insert(DatabaseTables.myAssignments, {
        'center_id': 'center-1',
        'channel': 'MRF',
        'zone_ids': '["zone-1"]',
      });
      expect(
        (await local.getMrfPeople(
          centerId: 'center-1',
          role: 'LABOUR',
        )).map((row) => row.id),
        ['labour-assigned', 'labour-no-zone'],
      );

      await database.delete(DatabaseTables.myAssignments);
      expect(
        (await local.getChannels(
          centerId: 'center-1',
        )).map((channel) => channel.channel),
        ['D2D', 'MRF', 'RAMP'],
      );
    },
  );
}
