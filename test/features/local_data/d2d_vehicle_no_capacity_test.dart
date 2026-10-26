import 'dart:convert';

import 'package:eerl_app/core/constants/app_constants.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/core/utils/vehicle_registration_number.dart';
import 'package:eerl_app/features/bootstrap/data/bootstrap_database_applier.dart';
import 'package:eerl_app/features/bootstrap/model/bootstrap_response.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:eerl_app/features/d2d_vehicle_management/widgets/d2d_vehicle_form.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_data_source.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase.instance;
  late String databasePath;
  late EerlLocalDataSource local;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    databasePath = p.join(await getDatabasesPath(), 'd2d_no_capacity.db');
    AppDatabase.setDatabasePathForTesting(databasePath);
    await deleteDatabase(databasePath);
    local = EerlLocalDataSource(database: database);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      AppConstants.accessTokenKey: 'vehicle-token',
    });
    await database.clearDatabaseOnLogout();
    await database.insert(DatabaseTables.centers, {
      'id': 'center-1',
      'name': 'Center One',
    });
  });

  tearDownAll(() async {
    await database.closeForTesting();
    AppDatabase.setDatabasePathForTesting(null);
    await deleteDatabase(databasePath);
  });

  test(
    'fresh D2D schema has no type or capacity but transfer vehicles keep it',
    () async {
      final vehicleColumns = await database.rawQuery(
        'PRAGMA table_info("${DatabaseTables.vehicles}")',
      );
      final transferVehicleColumns = await database.rawQuery(
        'PRAGMA table_info("${DatabaseTables.transferVehicles}")',
      );

      expect(
        vehicleColumns.map((row) => row['name']),
        isNot(contains('capacity_kg')),
      );
      expect(
        vehicleColumns.map((row) => row['name']),
        isNot(contains('type_id')),
      );
      expect(
        vehicleColumns.map((row) => row['name']),
        isNot(contains('type_name')),
      );
      expect(
        await database.getExistingTableNames(),
        isNot(contains('vehicle_types')),
      );
      expect(
        transferVehicleColumns.map((row) => row['name']),
        contains('capacity_kg'),
      );
    },
  );

  test('vehicle number normalization uses the required plate format', () {
    expect(VehicleRegistrationNumber.normalize('gj05bx1234'), 'GJ-05-BX-1234');
    expect(
      VehicleRegistrationNumber.normalize('GJ 05 BX 1234'),
      'GJ-05-BX-1234',
    );
    expect(VehicleRegistrationNumber.normalize('GK-4-SW1224'), isNull);
    expect(VehicleRegistrationNumber.normalize('GJ-05-1234'), isNull);
  });

  test('invalid vehicle number is rejected before SQLite and outbox', () async {
    const vehicle = VehicleModel(
      id: 'invalid-vehicle',
      centerId: 'center-1',
      plateNumber: 'GK-4-SW1224',
      isActive: true,
      syncState: 'pending',
    );

    await expectLater(
      local.saveVehicle(vehicle, isNew: true),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      await database.query(
        DatabaseTables.vehicles,
        where: 'id = ?',
        whereArgs: const ['invalid-vehicle'],
      ),
      isEmpty,
    );
    expect(
      await database.query(
        DatabaseTables.outbox,
        where: 'entity_id = ?',
        whereArgs: const ['invalid-vehicle'],
      ),
      isEmpty,
    );
  });

  test(
    'duplicate normalized plate is rejected before SQLite and outbox',
    () async {
      await database.insert(DatabaseTables.vehicles, {
        'id': 'existing-vehicle',
        'center_id': 'center-1',
        'plate_number': 'GJ-05-AB-1234',
        'driver_name': null,
        'is_active': 1,
        'sync_state': 'synced',
      });
      const duplicate = VehicleModel(
        id: 'duplicate-vehicle',
        centerId: 'center-1',
        plateNumber: 'gj 05 ab 1234',
        isActive: true,
        syncState: 'pending',
      );

      await expectLater(
        local.saveVehicle(duplicate, isNew: true),
        throwsA(isA<DuplicateVehicleRegistrationException>()),
      );
      expect(
        await database.query(
          DatabaseTables.vehicles,
          where: 'id = ?',
          whereArgs: const ['duplicate-vehicle'],
        ),
        isEmpty,
      );
      expect(await database.query(DatabaseTables.outbox), isEmpty);
    },
  );

  test('add stores no capacity and queues the exact PUT body', () async {
    const vehicle = VehicleModel(
      id: 'vehicle-add',
      centerId: 'center-1',
      plateNumber: 'GJ-05-AB-1234',
      driverName: 'Ketan Patel',
      isActive: true,
      syncState: 'pending',
    );

    await local.saveVehicle(vehicle, isNew: true);

    final stored = (await database.query(
      DatabaseTables.vehicles,
      where: 'id = ?',
      whereArgs: const ['vehicle-add'],
    )).single;
    final queued = (await database.query(
      DatabaseTables.outbox,
      where: 'entity_id = ?',
      whereArgs: const ['vehicle-add'],
    )).single;
    expect(stored.containsKey('capacity_kg'), isFalse);
    expect(queued['method'], 'PUT');
    expect(queued['path'], '/vehicles/vehicle-add');
    expect(jsonDecode(queued['body']! as String), {
      'centerId': 'center-1',
      'plateNumber': 'GJ-05-AB-1234',
      'driverName': 'Ketan Patel',
    });
  });

  test('edit queues PATCH with only changed fields', () async {
    await database.insert(DatabaseTables.vehicles, {
      'id': 'vehicle-edit',
      'number': 'SUR-VEH-0001',
      'center_id': 'center-1',
      'plate_number': 'GJ-05-AB-1234',
      'driver_name': 'Old Driver',
      'is_active': 1,
      'sync_state': 'synced',
    });

    await local.saveVehicle(
      const VehicleModel(
        id: 'vehicle-edit',
        number: 'SUR-VEH-0001',
        centerId: 'center-1',
        plateNumber: 'GJ-05-AB-1234',
        driverName: 'New Driver',
        isActive: true,
        syncState: 'pending',
      ),
      isNew: false,
    );

    final queued = (await database.query(DatabaseTables.outbox)).single;
    expect(queued['method'], 'PATCH');
    expect(jsonDecode(queued['body']! as String), {'driverName': 'New Driver'});
  });

  test('blank driver on edit keeps the current server-backed value', () async {
    await database.insert(DatabaseTables.vehicles, {
      'id': 'vehicle-keep-driver',
      'number': 'SUR-VEH-0010',
      'center_id': 'center-1',
      'plate_number': 'GJ-05-CD-1010',
      'driver_name': 'Existing Driver',
      'is_active': 1,
      'sync_state': 'synced',
    });

    await local.saveVehicle(
      const VehicleModel(
        id: 'vehicle-keep-driver',
        number: 'SUR-VEH-0010',
        centerId: 'center-1',
        plateNumber: 'GJ-05-CD-2020',
        driverName: null,
        isActive: true,
        syncState: 'pending',
      ),
      isNew: false,
    );

    final stored = (await database.query(
      DatabaseTables.vehicles,
      where: 'id = ?',
      whereArgs: const ['vehicle-keep-driver'],
    )).single;
    final queued = (await database.query(DatabaseTables.outbox)).single;
    expect(stored['driver_name'], 'Existing Driver');
    expect(jsonDecode(queued['body']! as String), {
      'plateNumber': 'GJ-05-CD-2020',
    });
  });

  test('edit sync sends PATCH to the vehicle endpoint', () async {
    await database.insert(DatabaseTables.vehicles, {
      'id': 'vehicle-patch',
      'number': 'SUR-VEH-0002',
      'center_id': 'center-1',
      'plate_number': 'GJ-05-BX-1234',
      'driver_name': 'Kiran Rathod',
      'is_active': 1,
      'sync_state': 'synced',
    });
    await local.saveVehicle(
      const VehicleModel(
        id: 'vehicle-patch',
        number: 'SUR-VEH-0002',
        centerId: 'center-1',
        plateNumber: 'GJ-05-BX-4321',
        driverName: 'Mahesh Solanki',
        isActive: true,
        syncState: 'pending',
      ),
      isNew: false,
    );
    late http.Request sent;
    final sync = OutgoingSyncService(
      database: database,
      internetAccessChecker: () async => true,
      client: MockClient((request) async {
        sent = request;
        return http.Response(
          jsonEncode({
            'data': {
              'vehicle': {
                'id': 'vehicle-patch',
                'number': 'SUR-VEH-0002',
                'centerId': 'center-1',
                'plateNumber': 'GJ-05-BX-4321',
                'driverName': 'Mahesh Solanki',
                'isActive': true,
              },
            },
          }),
          200,
        );
      }),
    );

    await sync.drain();

    expect(sent.method, 'PATCH');
    expect(sent.url.path, '/api/v1/mobile/vehicles/vehicle-patch');
    expect(jsonDecode(sent.body), {
      'plateNumber': 'GJ-05-BX-4321',
      'driverName': 'Mahesh Solanki',
    });
  });

  test('status change is local-first and syncs the exact API body', () async {
    const vehicle = VehicleModel(
      id: 'vehicle-status',
      number: 'SUR-VEH-0003',
      centerId: 'center-1',
      plateNumber: 'GJ-05-BX-9999',
      driverName: 'Kiran Rathod',
      isActive: true,
      syncState: 'synced',
    );
    await database.insert(DatabaseTables.vehicles, vehicle.toMap());

    await local.setVehicleActive(vehicle, false);

    final storedBeforeSync = (await database.query(
      DatabaseTables.vehicles,
      where: 'id = ?',
      whereArgs: const ['vehicle-status'],
    )).single;
    final queued = (await database.query(DatabaseTables.outbox)).single;
    expect(storedBeforeSync['is_active'], 0);
    expect(storedBeforeSync['sync_state'], 'pending');
    expect(queued['method'], 'POST');
    expect(queued['path'], '/vehicles/vehicle-status/status');
    expect(jsonDecode(queued['body']! as String), {'isActive': false});

    late http.Request sent;
    final sync = OutgoingSyncService(
      database: database,
      internetAccessChecker: () async => true,
      client: MockClient((request) async {
        sent = request;
        return http.Response(
          jsonEncode({
            'data': {
              'vehicle': {
                'id': 'vehicle-status',
                'number': 'SUR-VEH-0003',
                'centerId': 'center-1',
                'plateNumber': 'GJ-05-BX-9999',
                'driverName': 'Kiran Rathod',
                'isActive': false,
              },
            },
          }),
          200,
        );
      }),
    );

    await sync.drain();

    expect(sent.method, 'POST');
    expect(sent.url.path, '/api/v1/mobile/vehicles/vehicle-status/status');
    expect(jsonDecode(sent.body), {'isActive': false});
    expect(await database.query(DatabaseTables.outbox), isEmpty);
    final storedAfterSync = (await database.query(
      DatabaseTables.vehicles,
      where: 'id = ?',
      whereArgs: const ['vehicle-status'],
    )).single;
    expect(storedAfterSync['is_active'], 0);
    expect(storedAfterSync['sync_state'], 'synced');
  });

  test('successful vehicle response copies number without capacity', () async {
    const vehicle = VehicleModel(
      id: 'vehicle-sync',
      centerId: 'center-1',
      plateNumber: 'GJ-05-XY-7788',
      isActive: true,
      syncState: 'pending',
    );
    await local.saveVehicle(vehicle, isNew: true);
    late http.Request sent;
    final sync = OutgoingSyncService(
      database: database,
      internetAccessChecker: () async => true,
      client: MockClient((request) async {
        sent = request;
        return http.Response(
          jsonEncode({
            'data': {
              'vehicle': {
                'id': vehicle.id,
                'number': 'SUR-VEH-0009',
                'centerId': vehicle.centerId,
                'plateNumber': vehicle.plateNumber,
                'driverName': null,
                'isActive': true,
              },
            },
          }),
          200,
        );
      }),
    );

    await sync.drain();

    expect(sent.method, 'PUT');
    expect((jsonDecode(sent.body) as Map).containsKey('capacityKg'), isFalse);
    final stored = (await database.query(
      DatabaseTables.vehicles,
      where: 'id = ?',
      whereArgs: const ['vehicle-sync'],
    )).single;
    expect(stored['number'], 'SUR-VEH-0009');
    expect(stored['sync_state'], 'synced');
  });

  test(
    'bootstrap replaces synced vehicles and preserves pending rows',
    () async {
      await database.insert(DatabaseTables.vehicles, {
        'id': 'pending-vehicle',
        'center_id': 'center-1',
        'plate_number': 'GJ-05-AA-1000',
        'driver_name': null,
        'is_active': 1,
        'sync_state': 'pending',
      });
      await database.insert(DatabaseTables.vehicles, {
        'id': 'old-synced-vehicle',
        'center_id': 'center-1',
        'plate_number': 'GJ-05-AA-2000',
        'driver_name': null,
        'is_active': 1,
        'sync_state': 'synced',
      });

      await BootstrapDatabaseApplier(database: database).apply(
        BootstrapData.fromJson({
          'cursor': 'vehicle-page-1',
          'hasMore': false,
          'full': false,
          'tables': {
            'vehicles': {
              'replace': [
                {
                  'id': 'server-vehicle',
                  'number': 'SUR-VEH-0002',
                  'center_id': 'center-1',
                  'plate_number': 'GJ-05-AA-3000',
                  'driver_name': 'Server Driver',
                  'is_active': 1,
                },
              ],
            },
          },
        }),
      );

      final rows = await database.query(DatabaseTables.vehicles, orderBy: 'id');
      expect(rows.map((row) => row['id']), [
        'pending-vehicle',
        'server-vehicle',
      ]);
      expect(rows.every((row) => !row.containsKey('capacity_kg')), isTrue);
    },
  );

  testWidgets('vehicle form has driver but no type or capacity field', (
    tester,
  ) async {
    final number = TextEditingController();
    final driver = TextEditingController();
    addTearDown(number.dispose);
    addTearDown(driver.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: D2dVehicleForm(
          editing: false,
          numberController: number,
          centerOptions: const ['Center One'],
          selectedCenter: 0,
          centerExpanded: false,
          driverNameController: driver,
          onCenterToggle: () {},
          onCenterSelected: (_) {},
          onBack: () {},
          onCancel: () {},
          onSave: () {},
        ),
      ),
    );

    expect(find.byKey(const Key('d2d-form-type-selector')), findsNothing);
    expect(find.text('Vehicle Type'), findsNothing);
    expect(find.byKey(const Key('d2d-driver-name-field')), findsOneWidget);
    expect(find.textContaining('Capacity'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('d2d-vehicle-number-field')),
      'gj05bx1234',
    );
    expect(number.text, 'GJ-05-BX-1234');
  });
}
