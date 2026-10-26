import 'dart:convert';
import 'dart:io';

import 'package:eerl_app/core/location/device_location_service.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/core/local_database/outbox_queue.dart';
import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:eerl_app/core/utils/uuid_generator.dart';
import 'package:eerl_app/core/utils/vehicle_registration_number.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class CollectionLocationUnavailableException implements Exception {
  const CollectionLocationUnavailableException();

  @override
  String toString() => 'A valid location is required to submit a collection.';
}

class TransferStockUnavailableException implements Exception {
  const TransferStockUnavailableException({
    required this.itemId,
    required this.requestedQuantity,
    required this.freeQuantity,
  });

  final String itemId;
  final double requestedQuantity;
  final double freeQuantity;

  @override
  String toString() =>
      'TransferStockUnavailableException(itemId: $itemId, '
      'requested: $requestedQuantity, free: $freeQuantity)';
}

class TransferDispatchValidationException implements Exception {
  const TransferDispatchValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}

class TransferDecisionValidationException implements Exception {
  const TransferDecisionValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ExpenseBalanceUnavailableException implements Exception {
  const ExpenseBalanceUnavailableException({
    required this.requestedAmount,
    required this.availableBalance,
  });

  final double requestedAmount;
  final double availableBalance;

  @override
  String toString() =>
      'Expense amount ₹${requestedAmount.toStringAsFixed(2)} exceeds the '
      'available balance ₹${availableBalance.toStringAsFixed(2)}.';
}

class ExpenseDecisionValidationException implements Exception {
  const ExpenseDecisionValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CashRequestBalanceUnavailableException implements Exception {
  const CashRequestBalanceUnavailableException({
    required this.requestedAmount,
    required this.availableBalance,
  });

  final double requestedAmount;
  final double availableBalance;

  @override
  String toString() =>
      'Cash request amount ₹${requestedAmount.toStringAsFixed(2)} exceeds '
      'the available cash balance ₹${availableBalance.toStringAsFixed(2)}. '
      'Enter an amount equal to or below the available balance.';
}

class EerlLocalDataSource {
  EerlLocalDataSource({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<String?> get currentUserId => _database.getSyncMeta('user_id');

  Future<String?> get activeRole => _database.getSyncMeta('active_role');

  Future<String?> get activeCenterId async {
    final saved = await _database.getSyncMeta('active_center_id');
    if (saved != null && saved.isNotEmpty) return saved;
    final rows = await _database.rawQuery('''
      SELECT center_id
      FROM ${DatabaseTables.myCenters}
      ORDER BY is_primary DESC, center_id
      LIMIT 1
    ''');
    if (rows.isEmpty) return null;
    final centerId = rows.first['center_id'] as String?;
    if (centerId != null) {
      await _database.setSyncMeta('active_center_id', centerId);
    }
    return centerId;
  }

  Future<void> selectCenter(String centerId) =>
      _database.setSyncMeta('active_center_id', centerId);

  Future<List<MyRoleModel>> getRoles() async => (await _database.query(
    DatabaseTables.myRoles,
    orderBy: 'role_name',
  )).map(MyRoleModel.fromMap).toList(growable: false);

  Future<List<CenterModel>> getCenters() => getMyCenters();

  Future<List<CenterModel>> getMyCenters() async {
    final rows = await _database.rawQuery('''
      SELECT c.*, mc.is_primary
      FROM ${DatabaseTables.myCenters} mc
      JOIN ${DatabaseTables.centers} c ON c.id = mc.center_id
      ORDER BY mc.is_primary DESC, c.name COLLATE NOCASE
    ''');
    return rows.map(CenterModel.fromMap).toList(growable: false);
  }

  Future<List<CenterModel>> getMrfCenters() async {
    final rows = await _database.rawQuery('''
      SELECT DISTINCT c.*
      FROM ${DatabaseTables.centers} c
      JOIN ${DatabaseTables.mrfPeople} p ON p.center_id = c.id
      ORDER BY c.name COLLATE NOCASE
    ''');
    return rows.map(CenterModel.fromMap).toList(growable: false);
  }

  Future<List<CenterModel>> getAllCenters() async => (await _database.query(
    DatabaseTables.centers,
    orderBy: 'name COLLATE NOCASE',
  )).map(CenterModel.fromMap).toList(growable: false);

  Future<CenterModel?> getCenter(String id) async {
    final rows = await _database.rawQuery(
      '''
      SELECT c.*, COALESCE(mc.is_primary, 0) AS is_primary
      FROM ${DatabaseTables.centers} c
      LEFT JOIN ${DatabaseTables.myCenters} mc ON mc.center_id = c.id
      WHERE c.id = ?
      LIMIT 1
      ''',
      [id],
    );
    return rows.isEmpty ? null : CenterModel.fromMap(rows.first);
  }

  Future<ProfileModel> getProfile() async {
    final rows = await _database.rawQuery('''
      SELECT
        MAX(CASE WHEN key = 'user_name' THEN value END) AS user_name,
        MAX(CASE WHEN key = 'user_phone' THEN value END) AS user_phone,
        MAX(CASE WHEN key = 'user_photo_url' THEN value END) AS user_photo_url,
        MAX(CASE WHEN key = 'supervisor_name' THEN value END) AS supervisor_name,
        MAX(CASE WHEN key = 'supervisor_phone' THEN value END) AS supervisor_phone,
        MAX(CASE WHEN key = 'session_expires_at' THEN value END) AS session_expires_at
      FROM ${DatabaseTables.syncMeta}
    ''');
    final row = rows.single;
    return ProfileModel(
      userName: row['user_name'] as String?,
      userPhone: row['user_phone'] as String?,
      userPhotoUrl: row['user_photo_url'] as String?,
      supervisorName: row['supervisor_name'] as String?,
      supervisorPhone: row['supervisor_phone'] as String?,
      sessionExpiresAt: row['session_expires_at'] as String?,
    );
  }

  Future<AgentHomeSummaryModel> getAgentHomeSummary() async {
    final userId = await currentUserId;
    final centerId = await activeCenterId;
    if (userId == null || centerId == null) {
      return const AgentHomeSummaryModel(
        verifiedEntries: 0,
        collectedKg: 0,
        transferRequests: 0,
        drafts: 0,
        toFix: 0,
      );
    }
    final todayStart = _startOfIstDayUtc();
    final rows = await _database.rawQuery(
      '''
      SELECT
        (SELECT COUNT(*) FROM ${DatabaseTables.collections}
          WHERE agent_id = ? AND center_id = ?
            AND UPPER(status) IN ('VERIFIED', 'APPROVED')
            AND collected_at >= ?) AS verified_entries,
        (SELECT COALESCE(SUM(CASE WHEN i.unit_code = 'KG'
          THEN COALESCE(ci.verified_qty, ci.qty) ELSE 0 END), 0)
          FROM ${DatabaseTables.collectionItems} ci
          JOIN ${DatabaseTables.collections} c ON c.id = ci.collection_id
          JOIN ${DatabaseTables.items} i ON i.id = ci.item_id
          WHERE c.agent_id = ? AND c.center_id = ? AND c.status != 'DRAFT'
            AND c.collected_at >= ?) AS collected_kg,
        (SELECT COUNT(*) FROM ${DatabaseTables.transfers}
          WHERE requested_by = ? AND center_id = ?
            AND requested_at >= ?) AS transfer_requests,
        (SELECT COUNT(*) FROM ${DatabaseTables.collections}
          WHERE agent_id = ? AND center_id = ? AND status = 'DRAFT') AS drafts,
        (SELECT COUNT(*) FROM ${DatabaseTables.collections}
          WHERE agent_id = ? AND center_id = ? AND status = 'REJECTED') AS to_fix
    ''',
      [
        userId,
        centerId,
        todayStart,
        userId,
        centerId,
        todayStart,
        userId,
        centerId,
        todayStart,
        userId,
        centerId,
        userId,
        centerId,
      ],
    );
    return AgentHomeSummaryModel.fromMap(rows.single);
  }

  Future<SupervisorHomeSummaryModel> getSupervisorHomeSummary() async {
    final centerId = await activeCenterId;
    if (centerId == null) {
      return const SupervisorHomeSummaryModel(
        activeAgents: 0,
        transfersDone: 0,
        totalTransfers: 0,
        stockKg: 0,
        pendingExpenses: 0,
      );
    }
    final todayStart = _startOfIstDayUtc();
    final rows = await _database.rawQuery(
      '''
      SELECT
        (SELECT COUNT(DISTINCT p.user_id)
          FROM ${DatabaseTables.centerPeople} p
          WHERE p.center_id = ? AND p.is_agent = 1) AS active_agents,
        (SELECT COUNT(*) FROM ${DatabaseTables.transfers} t
          WHERE t.center_id = ? AND t.requested_at >= ?
            AND UPPER(t.status) IN
              ('DISPATCHED', 'COMPLETED', 'CLOSED', 'HANDED_OVER'))
          AS transfers_done,
        (SELECT COUNT(*) FROM ${DatabaseTables.transfers} t
          WHERE t.center_id = ? AND t.requested_at >= ?
            AND UPPER(t.status) != 'CANCELLED') AS total_transfers,
        (SELECT COALESCE(SUM(CASE WHEN UPPER(i.unit_code) = 'KG'
          THEN s.qty ELSE 0 END), 0)
          FROM ${DatabaseTables.stock} s
          JOIN ${DatabaseTables.items} i ON i.id = s.item_id
          WHERE s.center_id = ?) AS stock_kg,
        (SELECT COUNT(*) FROM ${DatabaseTables.expenses} e
          WHERE e.center_id = ? AND UPPER(e.status) IN
            ('PENDING', 'WAITING_SUPERVISOR', 'PENDING_REVIEW'))
          AS pending_expenses
    ''',
      [
        centerId,
        centerId,
        todayStart,
        centerId,
        todayStart,
        centerId,
        centerId,
      ],
    );
    return SupervisorHomeSummaryModel.fromMap(rows.single);
  }

  Future<List<CenterChannelModel>> getChannels({String? centerId}) async {
    final resolvedCenter = centerId ?? await activeCenterId;
    if (resolvedCenter == null) return const [];
    final rows = await _database.query(
      DatabaseTables.centerChannels,
      where: 'center_id = ?',
      whereArgs: [resolvedCenter],
      orderBy: 'channel COLLATE NOCASE',
    );
    return rows.map(CenterChannelModel.fromMap).toList(growable: false);
  }

  Future<List<ItemModel>> getItems({
    String? centerId,
    required String channel,
    bool selectedOnly = false,
  }) async {
    final resolvedCenter = centerId ?? await activeCenterId;
    if (resolvedCenter == null) return const [];
    final rows = await _database.rawQuery(
      '''
      SELECT i.*,
        CASE WHEN COALESCE(ch.show_price, 0) = 1 THEN ci.rate END AS rate,
        COALESCE(ci.is_selected, 0) AS is_selected,
        ci.sort_order,
        ci.item_id AS configured_item_id
      FROM ${DatabaseTables.centerItems} ci
      JOIN ${DatabaseTables.items} i ON i.id = ci.item_id
      JOIN ${DatabaseTables.centerChannels} ch
        ON ch.center_id = ci.center_id AND ch.channel = ci.channel
      WHERE ci.center_id = ? AND ci.channel = ? AND i.is_active = 1
        ${selectedOnly ? 'AND COALESCE(ci.is_selected, 0) = 1' : ''}
      ORDER BY
        CASE WHEN ci.sort_order IS NULL THEN 1 ELSE 0 END,
        ci.sort_order,
        i.name COLLATE NOCASE
    ''',
      [resolvedCenter, channel],
    );
    if (kDebugMode) {
      final configured = rows
          .where((row) => row['configured_item_id'] != null)
          .length;
      final selected = rows
          .where((row) => (row['is_selected'] as num?)?.toInt() == 1)
          .length;
      AppLogger.sqlite(
        'LOAD_ITEMS',
        'center=$resolvedCenter channel=$channel total=${rows.length} '
            'configured=$configured selected=$selected',
      );
    }
    return rows.map(ItemModel.fromMap).toList(growable: false);
  }

  Future<List<ItemModel>> getCollectionMaterials({
    String? centerId,
    required String channel,
  }) async {
    final resolvedCenter = centerId ?? await activeCenterId;
    if (resolvedCenter == null) return const [];
    final rows = await _database.rawQuery(
      '''
      SELECT i.*,
        CASE WHEN ch.show_price = 1 THEN ci.rate END AS rate,
        ci.is_selected,
        ci.sort_order
      FROM ${DatabaseTables.centerItems} ci
      JOIN ${DatabaseTables.items} i ON i.id = ci.item_id
      JOIN ${DatabaseTables.centerChannels} ch
        ON ch.center_id = ci.center_id AND ch.channel = ci.channel
      WHERE ci.center_id = ?
        AND ci.channel = ?
        AND ci.is_selected = 1
        AND i.is_active = 1
      ORDER BY ci.sort_order, i.name COLLATE NOCASE
      ''',
      [resolvedCenter, channel],
    );
    if (kDebugMode) {
      AppLogger.sqlite(
        'LOAD_CENTER_ITEMS',
        'center=$resolvedCenter channel=$channel selected_items=${rows.length}',
      );
    }
    return rows.map(ItemModel.fromMap).toList(growable: false);
  }

  Future<void> saveItemConfiguration({
    String? centerId,
    required String channel,
    required String tab,
    required List<ItemModel> items,
  }) async {
    final resolvedCenter = centerId ?? await activeCenterId;
    if (resolvedCenter == null) {
      throw StateError('No active center is available.');
    }
    final itemIds = items.map((item) => item.id).toList(growable: false);
    if (itemIds.toSet().length != itemIds.length) {
      throw ArgumentError('Material configuration contains duplicate items.');
    }
    final now = DateTime.now().toUtc().toIso8601String();
    final entityId = '$resolvedCenter:$channel:$tab';
    final refs = <String>[resolvedCenter, ...itemIds];
    final body = <String, Object?>{
      'centerId': resolvedCenter,
      'collectionChannel': channel,
      'tab': tab,
      'items': [
        for (var index = 0; index < items.length; index++)
          {
            'itemId': items[index].id,
            'isSelected': items[index].isSelected == true,
            'sortOrder': index,
            'rate': items[index].rate,
          },
      ],
    };

    await _database.transaction((txn) async {
      if (itemIds.isNotEmpty) {
        final placeholders = List.filled(itemIds.length, '?').join(',');
        final sourceItemCount = Sqflite.firstIntValue(
          await txn.rawQuery(
            'SELECT COUNT(*) FROM ${DatabaseTables.items} '
            'WHERE id IN ($placeholders) AND is_active = 1',
            itemIds,
          ),
        );
        if (sourceItemCount != itemIds.length) {
          throw StateError(
            'Material configuration contains an item missing from the '
            '${DatabaseTables.items} table.',
          );
        }
      }

      for (var index = 0; index < items.length; index++) {
        final item = items[index];
        await txn.insert(DatabaseTables.centerItems, {
          'center_id': resolvedCenter,
          'channel': channel,
          'item_id': item.id,
          'is_selected': item.isSelected == true ? 1 : 0,
          'sort_order': index,
          'rate': item.rate,
          'sync_state': 'pending',
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
        final values = <String, Object?>{
          'is_selected': item.isSelected == true ? 1 : 0,
          'sort_order': index,
          'sync_state': 'pending',
        };
        if (item.rate != null) values['rate'] = item.rate;
        final changed = await txn.update(
          DatabaseTables.centerItems,
          values,
          where: 'center_id = ? AND channel = ? AND item_id = ?',
          whereArgs: [resolvedCenter, channel, item.id],
        );
        if (changed != 1) {
          throw StateError(
            'Material configuration could not be stored for '
            '$resolvedCenter/$channel/${item.id}.',
          );
        }
      }

      final updated = await OutboxQueue.updateQueued(
        txn,
        entity: DatabaseTables.centerItems,
        entityId: entityId,
        kind: 'item_config',
        body: body,
        refs: refs,
      );
      if (updated == 0) {
        await OutboxQueue.enqueue(
          txn,
          method: 'PUT',
          path: '/item-config',
          body: body,
          entity: DatabaseTables.centerItems,
          entityId: entityId,
          kind: 'item_config',
          refs: refs,
          createdAt: now,
        );
      }
    });
    if (kDebugMode) {
      await _debugLogMaterialConfigCommit(
        centerId: resolvedCenter,
        channel: channel,
        tab: tab,
        itemIds: itemIds,
      );
    }
  }

  Future<void> _debugLogMaterialConfigCommit({
    required String centerId,
    required String channel,
    required String tab,
    required List<String> itemIds,
  }) async {
    try {
      final entityId = '$centerId:$channel:$tab';
      final placeholders = List.filled(itemIds.length, '?').join(',');
      final counts = itemIds.isEmpty
          ? <String, Object?>{
              'stored_count': 0,
              'selected_count': 0,
              'pending_count': 0,
            }
          : (await _database.rawQuery(
              '''
              SELECT COUNT(*) AS stored_count,
                SUM(CASE WHEN is_selected = 1 THEN 1 ELSE 0 END)
                  AS selected_count,
                SUM(CASE WHEN sync_state = 'pending' THEN 1 ELSE 0 END)
                  AS pending_count
              FROM ${DatabaseTables.centerItems}
              WHERE center_id = ? AND channel = ?
                AND item_id IN ($placeholders)
              ''',
              [centerId, channel, ...itemIds],
            )).single;
      final outbox = await _database.query(
        DatabaseTables.outbox,
        columns: const ['seq', 'method', 'path', 'kind', 'status'],
        where: 'entity = ? AND entity_id = ? AND kind = ?',
        whereArgs: [DatabaseTables.centerItems, entityId, 'item_config'],
        orderBy: 'seq DESC',
        limit: 1,
      );
      final storedCount = (counts['stored_count'] as num?)?.toInt() ?? 0;
      if (storedCount != itemIds.length || outbox.isEmpty) {
        AppLogger.sqliteError(
          'VERIFY',
          'Material configuration commit failed | '
              'center=$centerId channel=$channel tab=$tab '
              'rows=$storedCount/${itemIds.length} '
              'outbox_stored=${outbox.isNotEmpty}',
        );
        return;
      }

      final queued = outbox.single;
      AppLogger.sqlite(
        'COMMIT',
        'Material configuration stored | '
            'center=$centerId channel=$channel tab=$tab '
            'rows=$storedCount selected=${counts['selected_count'] ?? 0} '
            'pending=${counts['pending_count'] ?? 0} '
            'outbox_seq=${queued['seq']} method=${queued['method']} '
            'kind=${queued['kind']} queue_status=${queued['status']} '
            'path=${queued['path']}',
      );
    } catch (error) {
      AppLogger.sqliteError(
        'VERIFY',
        'Material configuration verification log failed | '
            'center=$centerId channel=$channel tab=$tab error=$error',
      );
    }
  }

  Future<List<VehicleModel>> getVehicles({
    String? centerId,
    bool activeOnly = true,
  }) async {
    final resolvedCenter = centerId ?? await activeCenterId;
    if (resolvedCenter == null) return const [];
    final rows = await _database.query(
      DatabaseTables.vehicles,
      where:
          '(center_id = ? OR center_id IS NULL)'
          '${activeOnly ? ' AND is_active = 1' : ''}',
      whereArgs: [resolvedCenter],
      orderBy: 'center_id IS NULL, plate_number COLLATE NOCASE',
    );
    return rows.map(VehicleModel.fromMap).toList(growable: false);
  }

  Future<void> saveVehicle(VehicleModel vehicle, {required bool isNew}) async {
    final plateNumber = VehicleRegistrationNumber.normalize(
      vehicle.plateNumber,
    );
    if (plateNumber == null) {
      throw ArgumentError.value(
        vehicle.plateNumber,
        'plateNumber',
        'Enter the vehicle number in the format GJ-05-BX-1234.',
      );
    }
    if (isNew && vehicle.centerId?.trim().isNotEmpty != true) {
      throw ArgumentError.value(
        vehicle.centerId,
        'centerId',
        'Collection center is required.',
      );
    }
    final now = DateTime.now().toUtc().toIso8601String();
    final driverName = vehicle.driverName?.trim();
    final normalizedDriverName = driverName?.isEmpty == true
        ? null
        : driverName;
    final refs = <String>[if (vehicle.centerId != null) vehicle.centerId!];
    await _database.transaction((txn) async {
      final duplicateRows = await txn.rawQuery(
        '''
        SELECT id
        FROM ${DatabaseTables.vehicles}
        WHERE REPLACE(REPLACE(UPPER(plate_number), '-', ''), ' ', '') =
              REPLACE(REPLACE(UPPER(?), '-', ''), ' ', '')
          AND id <> ?
        LIMIT 1
        ''',
        [plateNumber, vehicle.id],
      );
      if (duplicateRows.isNotEmpty) {
        throw DuplicateVehicleRegistrationException(plateNumber);
      }
      final storedRows = await txn.query(
        DatabaseTables.vehicles,
        where: 'id = ?',
        whereArgs: [vehicle.id],
        limit: 1,
      );
      final stored = storedRows.isEmpty ? null : storedRows.single;
      final queuedUpserts = await txn.query(
        DatabaseTables.outbox,
        columns: const ['method', 'body'],
        where:
            "entity = ? AND entity_id = ? AND kind = 'upsert' "
            "AND status = 'queued'",
        whereArgs: [DatabaseTables.vehicles, vehicle.id],
        limit: 1,
      );
      final queuedPut =
          queuedUpserts.isNotEmpty && queuedUpserts.single['method'] == 'PUT';
      final storedDriver = stored?['driver_name']?.toString().trim();
      final normalizedStoredDriver = storedDriver?.isEmpty == true
          ? null
          : storedDriver;
      final keepsExistingDriver =
          !isNew && !queuedPut && normalizedDriverName == null;
      final effectiveDriverName = keepsExistingDriver
          ? normalizedStoredDriver
          : normalizedDriverName;
      var body = <String, Object?>{};
      if (isNew || queuedPut) {
        body.addAll({
          'centerId': vehicle.centerId,
          'plateNumber': plateNumber,
          'driverName': ?normalizedDriverName,
        });
      } else {
        if (stored == null || stored['plate_number'] != plateNumber) {
          body['plateNumber'] = plateNumber;
        }
        if (normalizedDriverName != null &&
            (stored == null ||
                normalizedStoredDriver != normalizedDriverName)) {
          body['driverName'] = normalizedDriverName;
        }
        if (queuedUpserts.isNotEmpty) {
          final rawQueuedBody = queuedUpserts.single['body'] as String?;
          final decodedQueuedBody = rawQueuedBody == null
              ? null
              : jsonDecode(rawQueuedBody);
          if (decodedQueuedBody is Map) {
            final cumulativeBody = Map<String, Object?>.from(decodedQueuedBody);
            if (cumulativeBody.containsKey('plateNumber')) {
              cumulativeBody['plateNumber'] = plateNumber;
            }
            if (normalizedDriverName != null &&
                cumulativeBody.containsKey('driverName')) {
              cumulativeBody['driverName'] = normalizedDriverName;
            }
            cumulativeBody.addAll(body);
            body = cumulativeBody;
          }
        }
      }

      if (body.isEmpty) return;
      await _upsertById(txn, DatabaseTables.vehicles, {
        ...vehicle.toMap(),
        'plate_number': plateNumber,
        'driver_name': effectiveDriverName,
        'sync_state': 'pending',
      });

      final updated = await OutboxQueue.updateQueued(
        txn,
        entity: DatabaseTables.vehicles,
        entityId: vehicle.id,
        kind: 'upsert',
        body: body,
        refs: refs,
      );
      if (updated == 0) {
        await OutboxQueue.enqueue(
          txn,
          method: isNew ? 'PUT' : 'PATCH',
          path: '/vehicles/${vehicle.id}',
          body: body,
          entity: DatabaseTables.vehicles,
          entityId: vehicle.id,
          kind: 'upsert',
          refs: refs,
          createdAt: now,
        );
      }
    });
    if (kDebugMode) await _debugLogVehicleCommit(vehicle.id);
  }

  Future<void> _debugLogVehicleCommit(String vehicleId) async {
    try {
      final vehicles = await _database.query(
        DatabaseTables.vehicles,
        columns: const [
          'id',
          'center_id',
          'plate_number',
          'is_active',
          'sync_state',
        ],
        where: 'id = ?',
        whereArgs: [vehicleId],
        limit: 1,
      );
      final outbox = await _database.query(
        DatabaseTables.outbox,
        columns: const ['seq', 'method', 'path', 'kind', 'status'],
        where: 'entity = ? AND entity_id = ? AND kind = ?',
        whereArgs: [DatabaseTables.vehicles, vehicleId, 'upsert'],
        orderBy: 'seq DESC',
        limit: 1,
      );
      if (vehicles.isEmpty || outbox.isEmpty) {
        AppLogger.sqliteError(
          'VERIFY',
          'Vehicle commit failed | '
              'vehicle_id=$vehicleId vehicle_stored=${vehicles.isNotEmpty} '
              'outbox_stored=${outbox.isNotEmpty}',
        );
        return;
      }

      final vehicle = vehicles.single;
      final queued = outbox.single;
      AppLogger.sqlite(
        'COMMIT',
        'Vehicle stored | '
            'vehicle_id=$vehicleId center=${vehicle['center_id']} '
            'plate=${vehicle['plate_number']} '
            'is_active=${vehicle['is_active']} '
            'sync_state=${vehicle['sync_state']} '
            'outbox_seq=${queued['seq']} method=${queued['method']} '
            'kind=${queued['kind']} queue_status=${queued['status']} '
            'path=${queued['path']}',
      );
    } catch (error) {
      AppLogger.sqliteError(
        'VERIFY',
        'Vehicle verification log failed | '
            'vehicle_id=$vehicleId error=$error',
      );
    }
  }

  Future<void> setVehicleActive(VehicleModel vehicle, bool active) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _database.transaction((txn) async {
      await txn.update(
        DatabaseTables.vehicles,
        {'is_active': active ? 1 : 0, 'sync_state': 'pending'},
        where: 'id = ?',
        whereArgs: [vehicle.id],
      );
      await OutboxQueue.enqueue(
        txn,
        method: 'POST',
        path: '/vehicles/${vehicle.id}/status',
        body: {'isActive': active},
        entity: DatabaseTables.vehicles,
        entityId: vehicle.id,
        kind: 'status',
        createdAt: now,
      );
    });
  }

  Future<List<MrfPersonModel>> getMrfPeople({
    String? centerId,
    String? role,
    bool activeOnly = true,
    bool? isActive,
    bool allCenters = false,
  }) async {
    final conditions = <String>[];
    final args = <Object?>[];
    if (!allCenters) {
      final resolvedCenter = centerId ?? await activeCenterId;
      if (resolvedCenter == null) return const [];
      conditions.add('center_id = ?');
      args.add(resolvedCenter);
    }
    if (isActive != null) {
      conditions.add('is_active = ?');
      args.add(isActive ? 1 : 0);
    } else if (activeOnly) {
      conditions.add('is_active = 1');
    }
    if (role != null && role.isNotEmpty) {
      conditions.add('role = ?');
      args.add(role);
    }
    final rows = await _database.query(
      DatabaseTables.mrfPeople,
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy:
          '${allCenters ? 'center_id, ' : ''}'
          "CASE UPPER(role) WHEN 'SUPERVISOR' THEN 0 ELSE 1 END, "
          'name COLLATE NOCASE',
    );
    return rows.map(MrfPersonModel.fromMap).toList(growable: false);
  }

  Future<MrfPersonModel?> getOtherActiveMrfSupervisor({
    required String centerId,
    required String personId,
  }) async {
    final rows = await _database.query(
      DatabaseTables.mrfPeople,
      columns: const [
        'id',
        'number',
        'center_id',
        'name',
        'phone',
        'id_number',
        'photo_url',
        'is_active',
        'role',
        'sync_state',
      ],
      where:
          "center_id = ? AND UPPER(role) = 'SUPERVISOR' "
          'AND is_active = 1 AND id <> ?',
      whereArgs: [centerId, personId],
      orderBy: 'name COLLATE NOCASE',
      limit: 1,
    );
    return rows.isEmpty ? null : MrfPersonModel.fromMap(rows.single);
  }

  Future<void> saveMrfPerson(
    MrfPersonModel person, {
    required bool isNew,
  }) async {
    final normalizedName = person.name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(person.name, 'name', 'Full name is required.');
    }
    final normalizedCenterId = person.centerId.trim();
    if (normalizedCenterId.isEmpty) {
      throw ArgumentError.value(
        person.centerId,
        'centerId',
        'Center is required.',
      );
    }
    final normalizedPhone = _normalizeIndianPhone(person.phone);
    final normalizedRole = person.role.trim().toUpperCase() == 'SUPERVISOR'
        ? 'SUPERVISOR'
        : 'LABOUR';
    final normalizedIdNumber = person.idNumber?.trim();
    final normalizedPhotoUrl = person.photoUrl?.trim();
    if (normalizedRole == 'SUPERVISOR' && person.isActive) {
      final conflict = await getOtherActiveMrfSupervisor(
        centerId: normalizedCenterId,
        personId: person.id,
      );
      if (conflict != null) {
        throw StateError(
          '${conflict.name} is already the active MRF supervisor for this center.',
        );
      }
    }

    final personBody = <String, Object?>{
      'name': normalizedName,
      'phone': normalizedPhone,
      if (normalizedIdNumber?.isNotEmpty == true)
        'idNumber': normalizedIdNumber,
      if (normalizedPhotoUrl?.isNotEmpty == true)
        'photoUrl': normalizedPhotoUrl,
      'role': normalizedRole,
    };
    final now = DateTime.now().toUtc().toIso8601String();
    await _database.transaction((txn) async {
      final center = await txn.query(
        DatabaseTables.centers,
        columns: const ['id'],
        where: 'id = ?',
        whereArgs: [normalizedCenterId],
        limit: 1,
      );
      if (center.isEmpty) {
        throw StateError('The selected center is not available locally.');
      }
      final queuedUpserts = await txn.query(
        DatabaseTables.outbox,
        columns: const ['method'],
        where:
            "entity = ? AND entity_id = ? AND kind = 'upsert' "
            "AND status = 'queued'",
        whereArgs: [DatabaseTables.mrfPeople, person.id],
        limit: 1,
      );
      final queuedPut =
          queuedUpserts.isNotEmpty && queuedUpserts.single['method'] == 'PUT';
      final body = <String, Object?>{
        if (isNew || queuedPut) 'centerId': normalizedCenterId,
        ...personBody,
      };
      await _upsertById(txn, DatabaseTables.mrfPeople, {
        ...person.toMap(),
        'center_id': normalizedCenterId,
        'name': normalizedName,
        'phone': normalizedPhone,
        'id_number': normalizedIdNumber?.isEmpty == true
            ? null
            : normalizedIdNumber,
        'photo_url': normalizedPhotoUrl?.isEmpty == true
            ? null
            : normalizedPhotoUrl,
        'role': normalizedRole,
        'sync_state': 'pending',
      });
      final updated = await OutboxQueue.updateQueued(
        txn,
        entity: DatabaseTables.mrfPeople,
        entityId: person.id,
        kind: 'upsert',
        body: body,
        refs: [normalizedCenterId],
      );
      if (updated == 0) {
        await OutboxQueue.enqueue(
          txn,
          method: isNew ? 'PUT' : 'PATCH',
          path: '/mrf-people/${person.id}',
          body: body,
          entity: DatabaseTables.mrfPeople,
          entityId: person.id,
          kind: 'upsert',
          refs: [normalizedCenterId],
          createdAt: now,
        );
      }
    });
  }

  Future<void> setMrfPersonActive(MrfPersonModel person, bool active) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _database.transaction((txn) async {
      final changed = await txn.update(
        DatabaseTables.mrfPeople,
        {'is_active': active ? 1 : 0, 'sync_state': 'pending'},
        where: 'id = ?',
        whereArgs: [person.id],
      );
      if (changed != 1) {
        throw StateError('MRF person is not available locally.');
      }
      await OutboxQueue.enqueue(
        txn,
        method: 'POST',
        path: '/mrf-people/${person.id}/status',
        body: {'isActive': active},
        entity: DatabaseTables.mrfPeople,
        entityId: person.id,
        kind: 'status',
        refs: [person.centerId],
        createdAt: now,
      );
    });
  }

  String _normalizeIndianPhone(String? phone) {
    final digits = (phone ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    final normalized = digits.length == 12 && digits.startsWith('91')
        ? digits.substring(2)
        : digits;
    if (RegExp(r'^[6-9][0-9]{9}$').hasMatch(normalized)) {
      return normalized;
    }
    throw ArgumentError.value(
      phone,
      'phone',
      'Enter a valid 10-digit Indian mobile number.',
    );
  }

  Future<List<RagpickerModel>> getRagpickers({
    String? centerId,
    String search = '',
    bool activeOnly = false,
  }) async {
    final resolvedCenter = centerId ?? await activeCenterId;
    if (resolvedCenter == null) return const [];
    final conditions = <String>['center_id = ?'];
    final args = <Object?>[resolvedCenter];
    if (activeOnly) conditions.add('is_active = 1');
    if (search.trim().isNotEmpty) {
      conditions.add('(name LIKE ? OR phone LIKE ?)');
      final like = '%${search.trim()}%';
      args.addAll([like, like]);
    }
    final rows = await _database.query(
      DatabaseTables.ragpickers,
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'is_active DESC, name COLLATE NOCASE',
    );
    return rows.map(RagpickerModel.fromMap).toList(growable: false);
  }

  Future<void> saveRagpicker(
    RagpickerModel ragpicker, {
    String? localPhotoPath,
  }) async {
    final normalizedName = ragpicker.name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(ragpicker.name, 'name', 'Name is required.');
    }
    final phoneDigits = (ragpicker.phone ?? '').replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final normalizedPhone = phoneDigits.isEmpty
        ? null
        : phoneDigits.length > 10
        ? phoneDigits.substring(phoneDigits.length - 10)
        : phoneDigits;
    if (normalizedPhone != null && normalizedPhone.length != 10) {
      throw ArgumentError.value(
        ragpicker.phone,
        'phone',
        'Enter a valid 10-digit mobile number.',
      );
    }
    final normalizedIdNumber = ragpicker.idNumber?.trim();
    final normalizedPhotoPath = localPhotoPath?.trim();
    final hasNewPhoto = normalizedPhotoPath?.isNotEmpty == true;
    final now = DateTime.now().toUtc().toIso8601String();
    final photoId = hasNewPhoto ? UuidGenerator.v4() : null;
    final blockingPhotoIds = photoId == null
        ? const <String>[]
        : <String>[photoId];
    final body = <String, Object?>{
      'centerId': ragpicker.centerId,
      'name': normalizedName,
      'phone': normalizedPhone,
      'idNumber': normalizedIdNumber?.isEmpty == true
          ? null
          : normalizedIdNumber,
      'photoUrl': photoId ?? ragpicker.photoUrl,
    };
    var outboxSeq = -1;
    await _database.transaction((txn) async {
      if (photoId != null) {
        await txn.insert(DatabaseTables.photos, {
          'id': photoId,
          'owner_table': DatabaseTables.ragpickers,
          'owner_id': ragpicker.id,
          'field': 'profile',
          // Exact enum documented by POST /mobile/uploads/batch.
          'purpose': 'RAGPICKER',
          'content_type': 'image/jpeg',
          'local_path': normalizedPhotoPath,
          'status': 'local',
          'size_bytes': await _localFileSize(normalizedPhotoPath!),
          'created_at': now,
        });
      }
      await _upsertById(txn, DatabaseTables.ragpickers, {
        ...ragpicker.toMap(),
        'name': normalizedName,
        'phone': normalizedPhone,
        'id_number': normalizedIdNumber?.isEmpty == true
            ? null
            : normalizedIdNumber,
        'photo_url': hasNewPhoto ? normalizedPhotoPath : ragpicker.photoUrl,
        'sync_state': 'pending',
      });
      final updated = await OutboxQueue.updateQueued(
        txn,
        entity: DatabaseTables.ragpickers,
        entityId: ragpicker.id,
        kind: 'upsert',
        body: body,
        refs: [ragpicker.centerId],
        blockingPhotoIds: blockingPhotoIds,
      );
      if (updated == 0) {
        outboxSeq = await OutboxQueue.enqueue(
          txn,
          method: 'PUT',
          path: '/ragpickers/${ragpicker.id}',
          body: body,
          entity: DatabaseTables.ragpickers,
          entityId: ragpicker.id,
          kind: 'upsert',
          refs: [ragpicker.centerId],
          blockingPhotoIds: blockingPhotoIds,
          createdAt: now,
        );
      } else {
        await txn.update(
          DatabaseTables.outbox,
          {'method': 'PUT', 'path': '/ragpickers/${ragpicker.id}'},
          where:
              "entity = ? AND entity_id = ? AND kind = 'upsert' "
              "AND status = 'queued'",
          whereArgs: [DatabaseTables.ragpickers, ragpicker.id],
        );
      }
      await txn.delete(
        DatabaseTables.photos,
        where:
            'owner_table = ? AND owner_id = ? '
            "AND status IN ('local', 'failed')"
            '${photoId == null ? '' : ' AND id <> ?'}',
        whereArgs: [DatabaseTables.ragpickers, ragpicker.id, ?photoId],
      );
    });
    if (kDebugMode) {
      AppLogger.sqlite(
        'COMMIT',
        'Ragpicker stored | '
            'ragpicker_id=${ragpicker.id} center=${ragpicker.centerId} '
            'photo=${photoId != null ? 'queued' : 'none'} '
            'sync_state=pending '
            '${outboxSeq < 0 ? 'outbox=updated' : 'outbox_seq=$outboxSeq'} '
            'method=PUT '
            'path=/ragpickers/${ragpicker.id}',
      );
    }
  }

  Future<void> setRagpickerActive(RagpickerModel ragpicker, bool active) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _database.transaction((txn) async {
      await txn.update(
        DatabaseTables.ragpickers,
        {'is_active': active ? 1 : 0, 'sync_state': 'pending'},
        where: 'id = ?',
        whereArgs: [ragpicker.id],
      );
      await OutboxQueue.enqueue(
        txn,
        method: 'POST',
        path: '/ragpickers/${ragpicker.id}/status',
        body: {'isActive': active},
        entity: DatabaseTables.ragpickers,
        entityId: ragpicker.id,
        kind: 'status',
        createdAt: now,
      );
    });
  }

  Future<List<ExpenseCategoryModel>> getExpenseCategories({
    String? centerId,
  }) async {
    final resolvedCenter = centerId ?? await activeCenterId;
    if (resolvedCenter == null) return const [];
    final rows = await _database.query(
      DatabaseTables.expenseCategories,
      where: 'center_id = ? AND is_active = 1',
      whereArgs: [resolvedCenter],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(ExpenseCategoryModel.fromMap).toList(growable: false);
  }

  Future<List<CenterPersonModel>> getCenterPeople({
    String? centerId,
    bool agentsOnly = false,
  }) async {
    final resolvedCenter = centerId ?? await activeCenterId;
    if (resolvedCenter == null) return const [];
    final rows = await _database.query(
      DatabaseTables.centerPeople,
      where: 'center_id = ?${agentsOnly ? ' AND is_agent = 1' : ''}',
      whereArgs: [resolvedCenter],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(CenterPersonModel.fromMap).toList(growable: false);
  }

  Future<List<DestinationModel>> getDestinations() async {
    final centerId = await activeCenterId;
    final rows = await _database.query(
      DatabaseTables.destinations,
      where: centerId == null ? null : 'id <> ?',
      whereArgs: centerId == null ? null : [centerId],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(DestinationModel.fromMap).toList(growable: false);
  }

  Future<List<CollectionModel>> getAgentCollections({
    String? centerId,
    bool drafts = false,
    String? channel,
    String search = '',
  }) async {
    final userId = await currentUserId;
    final resolvedCenter = centerId ?? await activeCenterId;
    if (userId == null || resolvedCenter == null) return const [];
    final conditions = <String>[
      'c.agent_id = ?',
      'c.center_id = ?',
      drafts ? "c.status = 'DRAFT'" : "c.status != 'DRAFT'",
    ];
    final args = <Object?>[userId, resolvedCenter];
    if (!drafts) {
      conditions.add('c.collected_at >= ?');
      args.add(_startOfIstDayUtc(daysAgo: 6));
    }
    if (channel != null && channel.isNotEmpty) {
      conditions.add('c.channel = ?');
      args.add(channel);
    }
    if (search.trim().isNotEmpty) {
      conditions.add('(c.slip_number LIKE ? OR c.agent_name LIKE ?)');
      final like = '%${search.trim()}%';
      args.addAll([like, like]);
    }
    final rows = await _database.rawQuery('''
      SELECT c.*,
        COALESCE(SUM(ci.qty), 0) AS total_qty,
        COUNT(ci.id) AS item_count
      FROM ${DatabaseTables.collections} c
      LEFT JOIN ${DatabaseTables.collectionItems} ci ON ci.collection_id = c.id
      WHERE ${conditions.join(' AND ')}
      GROUP BY c.id
      ORDER BY ${drafts ? 'c.updated_at' : 'c.collected_at'} DESC
    ''', args);
    if (kDebugMode) {
      AppLogger.sqlite(
        'LOAD_COLLECTIONS',
        'center=$resolvedCenter agent=$userId '
            'view=${drafts ? 'drafts' : 'history'} channel=${channel ?? 'ALL'} '
            'rows=${rows.length}',
      );
    }
    return rows.map(CollectionModel.fromMap).toList(growable: false);
  }

  Future<List<CollectionModel>> getVerificationCollections({
    required bool pending,
    String? channel,
    String search = '',
  }) async {
    final centerId = await activeCenterId;
    if (centerId == null) return const [];
    final conditions = <String>[
      'c.center_id = ?',
      pending
          ? "c.status = 'SUBMITTED'"
          : "c.status IN ('APPROVED', 'REJECTED')",
    ];
    final args = <Object?>[centerId];
    if (channel != null && channel.isNotEmpty) {
      conditions.add('c.channel = ?');
      args.add(channel);
    }
    if (search.trim().isNotEmpty) {
      conditions.add(
        '(c.slip_number LIKE ? OR c.agent_name LIKE ? OR ct.name LIKE ?)',
      );
      final like = '%${search.trim()}%';
      args.addAll([like, like, like]);
    }
    final rows = await _database.rawQuery('''
      SELECT c.*, ct.name AS center_name,
        COALESCE(SUM(ci.qty), 0) AS total_qty,
        COUNT(ci.id) AS item_count
      FROM ${DatabaseTables.collections} c
      JOIN ${DatabaseTables.centers} ct ON ct.id = c.center_id
      LEFT JOIN ${DatabaseTables.collectionItems} ci ON ci.collection_id = c.id
      WHERE ${conditions.join(' AND ')}
      GROUP BY c.id
      ORDER BY c.collected_at DESC
    ''', args);
    return rows.map(CollectionModel.fromMap).toList(growable: false);
  }

  Future<CollectionModel?> getCollection(String id) async {
    final centerId = await activeCenterId;
    if (centerId == null) return null;
    final rows = await _database.rawQuery(
      '''
      SELECT c.*, ct.name AS center_name,
        COALESCE(SUM(ci.qty), 0) AS total_qty,
        COUNT(ci.id) AS item_count
      FROM ${DatabaseTables.collections} c
      LEFT JOIN ${DatabaseTables.centers} ct ON ct.id = c.center_id
      LEFT JOIN ${DatabaseTables.collectionItems} ci ON ci.collection_id = c.id
      WHERE c.id = ? AND c.center_id = ?
      GROUP BY c.id
      LIMIT 1
    ''',
      [id, centerId],
    );
    if (rows.isEmpty) return null;
    final photoRows = await _database.query(
      DatabaseTables.photos,
      columns: const ['id', 'local_path', 'remote_url', 'created_at'],
      where: 'owner_table = ? AND owner_id = ? AND field = ?',
      whereArgs: [DatabaseTables.collections, id, 'handover'],
      orderBy: 'created_at ASC',
    );
    final sources = _photoSourcesForReferences(
      _decodeStringList(rows.first['handover_photo_urls']),
      photoRows,
    );
    return CollectionModel.fromMap({
      ...rows.first,
      'handover_photo_urls': jsonEncode(sources),
    });
  }

  Future<List<CollectionItemModel>> getCollectionItems(
    String collectionId,
  ) async {
    final centerId = await activeCenterId;
    if (centerId == null) return const [];
    final rows = await _database.rawQuery(
      '''
      SELECT ci.*, i.name, i.unit_code, i.unit_name,
        i.image_url AS item_image_url
      FROM ${DatabaseTables.collectionItems} ci
      JOIN ${DatabaseTables.items} i ON i.id = ci.item_id
      JOIN ${DatabaseTables.collections} c ON c.id = ci.collection_id
      WHERE ci.collection_id = ? AND c.center_id = ?
      ORDER BY ci.sort_order, i.name COLLATE NOCASE
    ''',
      [collectionId, centerId],
    );
    if (rows.isEmpty) return const [];
    final itemIds = rows.map((row) => row['id']).whereType<String>().toList();
    final marks = List.filled(itemIds.length, '?').join(',');
    final photoRows = await _database.rawQuery(
      '''
      SELECT id, owner_id, local_path, remote_url, created_at
      FROM ${DatabaseTables.photos}
      WHERE owner_table = ? AND owner_id IN ($marks) AND field = ?
      ORDER BY created_at ASC
      ''',
      [DatabaseTables.collectionItems, ...itemIds, 'item'],
    );
    final photosByItem = <String, List<Map<String, Object?>>>{};
    for (final photo in photoRows) {
      final ownerId = photo['owner_id'] as String?;
      if (ownerId != null) {
        photosByItem.putIfAbsent(ownerId, () => []).add(photo);
      }
    }
    return rows
        .map((row) {
          final itemId = row['id'] as String;
          final sources = _photoSourcesForReferences(
            _decodeStringList(row['photo_urls']),
            photosByItem[itemId] ?? const [],
          );
          return CollectionItemModel.fromMap({
            ...row,
            'photo_urls': jsonEncode(sources),
          });
        })
        .toList(growable: false);
  }

  List<String> _photoSourcesForReferences(
    List<String> references,
    List<Map<String, Object?>> photoRows,
  ) {
    final sourceById = <String, String>{};
    final orderedSources = <String>[];
    for (final row in photoRows) {
      final localPath = (row['local_path'] as String?)?.trim();
      final remoteUrl = (row['remote_url'] as String?)?.trim();
      final source = localPath?.isNotEmpty == true
          ? localPath!
          : remoteUrl?.isNotEmpty == true
          ? remoteUrl!
          : null;
      if (source == null) continue;
      final photoId = row['id'] as String?;
      if (photoId != null) sourceById[photoId] = source;
      if (localPath?.isNotEmpty == true) sourceById[localPath!] = source;
      if (remoteUrl?.isNotEmpty == true) sourceById[remoteUrl!] = source;
      orderedSources.add(source);
    }
    return <String>{
      for (final reference in references)
        if ((sourceById[reference] ?? reference).trim().isNotEmpty)
          sourceById[reference] ?? reference,
      ...orderedSources,
    }.toList(growable: false);
  }

  Future<void> approveCollection(String collectionId) =>
      _saveCollectionReview(collectionId: collectionId, approved: true);

  Future<void> rejectCollection(
    String collectionId,
    String reason, {
    String? remarks,
  }) {
    final normalizedReason = reason.trim();
    final normalizedRemarks = remarks?.trim();
    if (normalizedReason.isEmpty) {
      throw ArgumentError.value(reason, 'reason', 'Reject reason is required.');
    }
    if (normalizedReason.length > 1000 ||
        (normalizedRemarks?.length ?? 0) > 1000) {
      throw ArgumentError(
        'Reason and remarks must be 1000 characters or fewer.',
      );
    }
    return _saveCollectionReview(
      collectionId: collectionId,
      approved: false,
      reason: normalizedReason,
      remarks: normalizedRemarks,
    );
  }

  Future<void> _saveCollectionReview({
    required String collectionId,
    required bool approved,
    String? reason,
    String? remarks,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final kind = approved ? 'approve' : 'reject';
    final profile = await getProfile();
    await _database.runInTransaction((txn) async {
      final rows = await txn.query(
        DatabaseTables.collections,
        columns: const ['status'],
        where: 'id = ?',
        whereArgs: [collectionId],
        limit: 1,
      );
      if (rows.isEmpty) {
        throw StateError('Collection $collectionId was not found.');
      }
      if (rows.single['status'] != 'SUBMITTED') {
        throw StateError(
          'Only a submitted collection can be approved or rejected.',
        );
      }

      final updated = await txn.update(
        DatabaseTables.collections,
        {
          'status': approved ? 'APPROVED' : 'REJECTED',
          'rejection_reason': approved ? null : reason,
          'rejection_remarks': approved || remarks?.isEmpty == true
              ? null
              : remarks,
          'verified_by_name': profile.userName,
          'verified_at': now,
          'updated_at': now,
          'sync_state': 'pending',
        },
        where: "id = ? AND status = 'SUBMITTED'",
        whereArgs: [collectionId],
      );
      if (updated != 1) {
        throw StateError(
          'Collection review state changed before it was saved.',
        );
      }

      await OutboxQueue.enqueue(
        txn,
        method: 'POST',
        path: '/collections/$collectionId/$kind',
        entity: DatabaseTables.collections,
        entityId: collectionId,
        kind: kind,
        body: approved
            ? null
            : {
                'reason': reason,
                if (remarks?.isNotEmpty == true) 'remarks': remarks,
              },
        refs: [collectionId],
        createdAt: now,
      );
    });
    if (kDebugMode) {
      AppLogger.sqlite(
        'COMMIT',
        'Collection review ${kind.toUpperCase()} stored | '
            'collection_id=$collectionId status=${approved ? 'APPROVED' : 'REJECTED'} '
            'outbox_path=/collections/$collectionId/$kind',
      );
    }
  }

  Future<void> saveCollection({
    required CollectionModel collection,
    required List<CollectionItemModel> items,
    required bool submit,
  }) async {
    final channel = collection.channel.trim().toUpperCase();
    if (!const {'D2D', 'MRF', 'RAMP'}.contains(channel)) {
      throw ArgumentError.value(
        collection.channel,
        'collection.channel',
        'Collection type must be D2D, MRF, or RAMP.',
      );
    }
    if (items.isEmpty) {
      throw ArgumentError.value(
        items,
        'items',
        'At least one item is required.',
      );
    }
    for (final item in items) {
      if (item.collectionId != collection.id || item.qty <= 0) {
        throw ArgumentError('Collection item identity or quantity is invalid.');
      }
      if (submit && (item.verifiedQty == null || item.verifiedQty! <= 0)) {
        throw ArgumentError('Verified quantity is required before submission.');
      }
      if (submit && item.photoUrls.isEmpty) {
        throw ArgumentError('An item photo is required before submission.');
      }
    }
    final now = DateTime.now().toUtc().toIso8601String();
    final locationRows = submit
        ? await _database.query(
            DatabaseTables.collections,
            columns: const ['status', 'gps_lat', 'gps_lng'],
            where: 'id = ?',
            whereArgs: [collection.id],
            limit: 1,
          )
        : const <Map<String, Object?>>[];
    final resubmittingRejected =
        locationRows.isNotEmpty && locationRows.single['status'] == 'REJECTED';
    final existingLocation = locationRows.isEmpty ? null : locationRows.single;
    final hasStoredGps = _isValidGps(
      (existingLocation?['gps_lat'] as num?)?.toDouble(),
      (existingLocation?['gps_lng'] as num?)?.toDouble(),
    );
    final suppliedGps = _isValidGps(collection.gpsLat, collection.gpsLng)
        ? DeviceCoordinates(
            latitude: collection.gpsLat!,
            longitude: collection.gpsLng!,
            capturedAt: DateTime.now().toUtc(),
          )
        : null;
    final capturedGps = submit && (!resubmittingRejected || !hasStoredGps)
        ? suppliedGps ??
              await DeviceLocationService.instance.bestAvailableCoordinates(
                requestPermission: true,
              )
        : null;
    if (submit && !hasStoredGps && capturedGps == null) {
      throw const CollectionLocationUnavailableException();
    }
    final photoIds = <String>[];
    final savedItemIds = <String>[];
    final photoSizes = <String, int?>{};
    for (final path in <String>{
      ...collection.handoverPhotoUrls,
      for (final item in items) ...item.photoUrls,
    }) {
      photoSizes[path] = await _localFileSize(path);
    }
    await _database.transaction((txn) async {
      final channelRows = await txn.query(
        DatabaseTables.centerChannels,
        columns: const ['takes_payment'],
        where: 'center_id = ? AND channel = ?',
        whereArgs: [collection.centerId, channel],
        limit: 1,
      );
      final takesPayment = channelRows.isEmpty
          ? collection.takesPayment
          : channelRows.single['takes_payment'] == 1;
      if (submit && channel == 'D2D') {
        final vehicleId = collection.vehicleId?.trim();
        if (vehicleId == null || vehicleId.isEmpty) {
          throw StateError('A D2D vehicle is required.');
        }
        final vehicles = await txn.query(
          DatabaseTables.vehicles,
          columns: const ['id'],
          where:
              'id = ? AND is_active = 1 AND (center_id = ? OR center_id IS NULL)',
          whereArgs: [vehicleId, collection.centerId],
          limit: 1,
        );
        if (vehicles.isEmpty) {
          throw StateError('The selected D2D vehicle is unavailable.');
        }
        if (collection.givenByName?.trim().isEmpty != false) {
          throw StateError(
            'The person handing over the collection is required.',
          );
        }
      }
      if (submit && channel == 'MRF') {
        final supervisors = await txn.query(
          DatabaseTables.mrfPeople,
          columns: const ['id'],
          where:
              "center_id = ? AND UPPER(role) = 'SUPERVISOR' AND is_active = 1",
          whereArgs: [collection.centerId],
          limit: 1,
        );
        if (supervisors.isEmpty) {
          throw StateError('An active MRF supervisor is required.');
        }
        final labourId = collection.mrfPersonId?.trim();
        if (labourId == null || labourId.isEmpty) {
          throw StateError('An MRF labour person is required.');
        }
        final labours = await txn.query(
          DatabaseTables.mrfPeople,
          columns: const ['id'],
          where:
              "id = ? AND center_id = ? AND UPPER(role) = 'LABOUR' AND is_active = 1",
          whereArgs: [labourId, collection.centerId],
          limit: 1,
        );
        if (labours.isEmpty) {
          throw StateError('The selected MRF labour person is unavailable.');
        }
      }
      if (submit && channel == 'RAMP') {
        final ragpickerId = collection.ragpickerId?.trim();
        if (ragpickerId == null || ragpickerId.isEmpty) {
          throw StateError('A ragpicker is required.');
        }
        final ragpickers = await txn.query(
          DatabaseTables.ragpickers,
          columns: const ['id'],
          where: 'id = ? AND center_id = ? AND is_active = 1',
          whereArgs: [ragpickerId, collection.centerId],
          limit: 1,
        );
        if (ragpickers.isEmpty) {
          throw StateError('The selected ragpicker is unavailable.');
        }
      }
      if (submit && (channel == 'D2D' || channel == 'RAMP')) {
        if (collection.handoverPhotoUrls.isEmpty) {
          throw StateError('A handover photo is required.');
        }
        final paidBy = collection.paidBy?.trim().toUpperCase();
        if (paidBy != 'CASH' && paidBy != 'UPI') {
          throw StateError('Select a valid payment mode.');
        }
      }
      final existing = await txn.query(
        DatabaseTables.collections,
        columns: const [
          'status',
          'slip_number',
          'collected_at',
          'gps_lat',
          'gps_lng',
        ],
        where: 'id = ?',
        whereArgs: [collection.id],
        limit: 1,
      );
      final existingRow = existing.isEmpty ? null : existing.single;
      final isResubmission = existingRow?['status'] == 'REJECTED';
      var slipNumber =
          collection.slipNumber ?? existingRow?['slip_number'] as String?;
      var collectedAt =
          collection.collectedAt ?? existingRow?['collected_at'] as String?;
      final gpsLat = submit
          ? (isResubmission
                ? (existingRow?['gps_lat'] as num?)?.toDouble() ??
                      capturedGps?.latitude
                : capturedGps?.latitude)
          : (existingRow?['gps_lat'] as num?)?.toDouble();
      final gpsLng = submit
          ? (isResubmission
                ? (existingRow?['gps_lng'] as num?)?.toDouble() ??
                      capturedGps?.longitude
                : capturedGps?.longitude)
          : (existingRow?['gps_lng'] as num?)?.toDouble();

      if (submit && !isResubmission && slipNumber == null) {
        final centerRows = await txn.rawQuery(
          '''
          SELECT c.code, m.agent_number, m.slip_date, m.slip_last_count
          FROM ${DatabaseTables.myCenters} m
          JOIN ${DatabaseTables.centers} c ON c.id = m.center_id
          WHERE m.center_id = ?
          LIMIT 1
        ''',
          [collection.centerId],
        );
        if (centerRows.isEmpty) {
          throw StateError('Cannot create a slip for an unavailable center.');
        }
        final istNow = DateTime.now().toUtc().add(
          const Duration(hours: 5, minutes: 30),
        );
        final today = _dateKey(istNow);
        final center = centerRows.single;
        final lastCount = center['slip_date'] == today
            ? ((center['slip_last_count'] as num?)?.toInt() ?? 0)
            : 0;
        final nextCount = lastCount + 1;
        final code = (center['code'] as String?)?.trim();
        final agentNumber = (center['agent_number'] as num?)?.toInt();
        if (code == null || code.isEmpty || agentNumber == null) {
          throw StateError('Center code or agent number is missing.');
        }
        final compactDate =
            '${today.substring(2, 4)}${today.substring(5, 7)}${today.substring(8, 10)}';
        slipNumber =
            '$code-$compactDate-${agentNumber.toString().padLeft(2, '0')}-${nextCount.toString().padLeft(3, '0')}';
        await txn.update(
          DatabaseTables.myCenters,
          {'slip_date': today, 'slip_last_count': nextCount},
          where: 'center_id = ?',
          whereArgs: [collection.centerId],
        );
      }
      if (submit) collectedAt ??= now;

      final collectionRow = <String, Object?>{
        ...collection.toMap(),
        'channel': channel,
        'status': submit ? 'SUBMITTED' : 'DRAFT',
        'slip_number': slipNumber,
        'collected_at': collectedAt,
        'takes_payment': takesPayment == null ? null : (takesPayment ? 1 : 0),
        'rejection_reason': submit ? null : collection.rejectionReason,
        'rejection_remarks': submit ? null : collection.rejectionRemarks,
        'gps_lat': gpsLat,
        'gps_lng': gpsLng,
        'updated_at': now,
        'sync_state': 'pending',
      };
      await _upsertById(txn, DatabaseTables.collections, collectionRow);

      // Collection ids are generated on the phone. Read the saved parent row
      // back before writing its complete child set so every line is linked to
      // an id that is present in `collections` inside this transaction.
      final savedParents = await txn.query(
        DatabaseTables.collections,
        columns: const ['id'],
        where: 'id = ?',
        whereArgs: [collection.id],
        limit: 1,
      );
      if (savedParents.isEmpty) {
        throw StateError('Collection parent row was not saved.');
      }
      final savedCollectionId = savedParents.single['id']! as String;

      final previousPhotoRows = await txn.rawQuery(
        '''
        SELECT id
        FROM ${DatabaseTables.photos}
        WHERE (owner_table = ? AND owner_id = ?)
           OR (owner_table = ? AND owner_id IN (
             SELECT id
             FROM ${DatabaseTables.collectionItems}
             WHERE collection_id = ?
           ))
        ''',
        [
          DatabaseTables.collections,
          savedCollectionId,
          DatabaseTables.collectionItems,
          savedCollectionId,
        ],
      );
      final previousPhotoIds = previousPhotoRows
          .map((row) => row['id'])
          .whereType<String>()
          .toList(growable: false);

      await txn.delete(
        DatabaseTables.collectionItems,
        where: 'collection_id = ?',
        whereArgs: [savedCollectionId],
      );
      final handoverPhotoIds = <String>[];
      for (
        var index = 0;
        index < collection.handoverPhotoUrls.length;
        index++
      ) {
        final photoId = UuidGenerator.v4();
        handoverPhotoIds.add(photoId);
        photoIds.add(photoId);
        await _upsertById(txn, DatabaseTables.photos, {
          'id': photoId,
          'owner_table': DatabaseTables.collections,
          'owner_id': collection.id,
          'field': 'handover',
          'purpose': 'COLLECTION_HANDOVER',
          'content_type': 'image/jpeg',
          'local_path': collection.handoverPhotoUrls[index],
          'status': 'local',
          'size_bytes': photoSizes[collection.handoverPhotoUrls[index]],
          'created_at': now,
        });
      }
      final bodyItems = <Map<String, Object?>>[];
      for (final item in items) {
        final itemPhotoIds = <String>[];
        final normalizedItem = <String, Object?>{
          ...item.toMap(),
          // The data source owns the parent/child relationship. Never rely on
          // a caller-provided map value when persisting the child list.
          'collection_id': savedCollectionId,
          'amount': item.rate == null || item.verifiedQty == null
              ? null
              : double.parse(
                  (item.verifiedQty! * item.rate!).toStringAsFixed(2),
                ),
        };
        await txn.insert(DatabaseTables.collectionItems, normalizedItem);
        savedItemIds.add(item.id);
        for (var index = 0; index < item.photoUrls.length; index++) {
          final path = item.photoUrls[index];
          final photoId = UuidGenerator.v4();
          itemPhotoIds.add(photoId);
          photoIds.add(photoId);
          await _upsertById(txn, DatabaseTables.photos, {
            'id': photoId,
            'owner_table': DatabaseTables.collectionItems,
            'owner_id': item.id,
            'field': 'item',
            'purpose': 'COLLECTION_LINE',
            'content_type': 'image/jpeg',
            'local_path': path,
            'status': 'local',
            'size_bytes': photoSizes[path],
            'created_at': now,
          });
        }
        bodyItems.add({...normalizedItem, 'photo_urls': itemPhotoIds});
      }

      final savedItemCount = Sqflite.firstIntValue(
        await txn.rawQuery(
          'SELECT COUNT(*) FROM ${DatabaseTables.collectionItems} '
          'WHERE collection_id = ?',
          [savedCollectionId],
        ),
      );
      if (savedItemCount != items.length) {
        throw StateError(
          'Collection item set was not saved completely '
          '(${savedItemCount ?? 0}/${items.length}).',
        );
      }
      final body = submit
          ? _collectionSubmitBody(
              collectionRow: collectionRow,
              handoverPhotoIds: handoverPhotoIds,
              items: bodyItems,
            )
          : _collectionDraftBody(
              collectionRow: collectionRow,
              handoverPhotoIds: handoverPhotoIds,
              items: bodyItems,
            );

      final hasDraftOutbox = await OutboxQueue.hasQueued(
        txn,
        entity: DatabaseTables.collections,
        entityId: savedCollectionId,
        kind: 'draft_save',
      );
      if (!submit && hasDraftOutbox) {
        await OutboxQueue.updateQueued(
          txn,
          entity: DatabaseTables.collections,
          entityId: savedCollectionId,
          kind: 'draft_save',
          body: body,
          refs: photoIds,
        );
        await _deleteUnreferencedPhotoRows(txn, previousPhotoIds);
        return;
      }
      if (submit && hasDraftOutbox) {
        await OutboxQueue.removeQueued(
          txn,
          entity: DatabaseTables.collections,
          entityId: savedCollectionId,
          kind: 'draft_save',
        );
      }
      final hasSubmitOutbox =
          submit &&
          await OutboxQueue.hasQueued(
            txn,
            entity: DatabaseTables.collections,
            entityId: savedCollectionId,
            kind: 'submit',
          );
      if (hasSubmitOutbox) {
        await OutboxQueue.updateQueued(
          txn,
          entity: DatabaseTables.collections,
          entityId: savedCollectionId,
          kind: 'submit',
          body: body,
          refs: photoIds,
          blockingPhotoIds: photoIds,
        );
        await txn.update(
          DatabaseTables.outbox,
          {'method': 'POST', 'path': '/collections/$savedCollectionId/submit'},
          where:
              "entity = ? AND entity_id = ? AND kind = 'submit' "
              "AND status = 'queued'",
          whereArgs: [DatabaseTables.collections, savedCollectionId],
        );
        await _deleteUnreferencedPhotoRows(txn, previousPhotoIds);
        return;
      }

      await OutboxQueue.enqueue(
        txn,
        method: submit ? 'POST' : 'PUT',
        path: submit
            ? '/collections/$savedCollectionId/submit'
            : '/collections/$savedCollectionId',
        body: body,
        entity: DatabaseTables.collections,
        entityId: savedCollectionId,
        kind: submit ? 'submit' : 'draft_save',
        refs: photoIds,
        blockingPhotoIds: submit ? photoIds : const <String>[],
        createdAt: now,
      );
      await _deleteUnreferencedPhotoRows(txn, previousPhotoIds);
    });
    if (kDebugMode) {
      await _debugLogCollectionCommit(
        collectionId: collection.id,
        centerId: collection.centerId,
        channel: channel,
        expectedItemIds: savedItemIds,
      );
    }
  }

  Future<void> _debugLogCollectionCommit({
    required String collectionId,
    required String centerId,
    required String channel,
    required List<String> expectedItemIds,
  }) async {
    final graphRows = await _database.rawQuery(
      '''
      SELECT c.id, c.status, c.sync_state, c.gps_lat, c.gps_lng,
        (SELECT COUNT(*)
         FROM ${DatabaseTables.collectionItems} ci
         WHERE ci.collection_id = c.id) AS item_count,
        (SELECT COUNT(*)
         FROM ${DatabaseTables.photos} p
         WHERE (p.owner_table = ? AND p.owner_id = c.id)
            OR (p.owner_table = ? AND p.owner_id IN (
              SELECT ci.id
              FROM ${DatabaseTables.collectionItems} ci
              WHERE ci.collection_id = c.id
            ))) AS photo_count
      FROM ${DatabaseTables.collections} c
      WHERE c.id = ?
      LIMIT 1
    ''',
      [
        DatabaseTables.collections,
        DatabaseTables.collectionItems,
        collectionId,
      ],
    );
    final outboxRows = await _database.query(
      DatabaseTables.outbox,
      columns: const ['seq', 'method', 'path', 'kind', 'status'],
      where: 'entity = ? AND entity_id = ?',
      whereArgs: [DatabaseTables.collections, collectionId],
      orderBy: 'seq DESC',
      limit: 1,
    );
    if (graphRows.isEmpty || outboxRows.isEmpty) {
      AppLogger.sqliteError(
        'VERIFY',
        'Collection commit failed | '
            'collection_id=$collectionId collection_stored=${graphRows.isNotEmpty} '
            'outbox_stored=${outboxRows.isNotEmpty}',
      );
      return;
    }

    final graph = graphRows.single;
    final outbox = outboxRows.single;
    final outboxSeq = (outbox['seq'] as num).toInt();
    final blockedPhotos =
        Sqflite.firstIntValue(
          await _database.rawQuery(
            'SELECT COUNT(*) FROM ${DatabaseTables.outboxPhotos} '
            'WHERE outbox_seq = ?',
            [outboxSeq],
          ),
        ) ??
        0;
    AppLogger.sqlite(
      'COMMIT',
      'Collection stored | '
          'collection_id=$collectionId center=$centerId channel=$channel '
          'status=${graph['status']} sync_state=${graph['sync_state']} '
          'gps={lat:${graph['gps_lat']},lng:${graph['gps_lng']}} '
          'collection_items=${graph['item_count']} '
          'item_ids=${expectedItemIds.join(',')} photos=${graph['photo_count']} '
          'outbox_seq=$outboxSeq method=${outbox['method']} '
          'kind=${outbox['kind']} queue_status=${outbox['status']} '
          'outbox_photos=$blockedPhotos path=${outbox['path']}',
    );
  }

  Future<int?> _localFileSize(String path) async {
    if (path.trim().isEmpty) return null;
    try {
      final size = await File(path).length();
      return size > 0 ? size : null;
    } on FileSystemException {
      return null;
    }
  }

  Map<String, Object?> _collectionSubmitBody({
    required Map<String, Object?> collectionRow,
    required List<String> handoverPhotoIds,
    required List<Map<String, Object?>> items,
  }) {
    final vehicleId = collectionRow['vehicle_id'];
    final givenByName = collectionRow['given_by_name'];
    final mrfLabourId = collectionRow['mrf_person_id'];
    final ragpickerId = collectionRow['ragpicker_id'];
    final paidBy = collectionRow['paid_by'];
    final gpsLat = (collectionRow['gps_lat'] as num?)?.toDouble();
    final gpsLng = (collectionRow['gps_lng'] as num?)?.toDouble();
    if (!_isValidGps(gpsLat, gpsLng)) {
      throw const CollectionLocationUnavailableException();
    }
    return <String, Object?>{
      'centerId': collectionRow['center_id'],
      'type': collectionRow['channel'],
      'slipNumber': collectionRow['slip_number'],
      'collectedAt': collectionRow['collected_at'],
      if (collectionRow['channel'] == 'D2D') ...{
        'vehicleId': vehicleId,
        'givenByName': givenByName,
        'handoverPhotoUrls': handoverPhotoIds,
        'paidBy': paidBy,
      },
      if (collectionRow['channel'] == 'MRF') 'mrfLabourId': mrfLabourId,
      if (collectionRow['channel'] == 'RAMP') ...{
        'ragpickerId': ragpickerId,
        'handoverPhotoUrls': handoverPhotoIds,
        'paidBy': paidBy,
      },
      'lines': [
        for (final item in items)
          {
            'itemId': item['item_id'],
            'collectedQty': item['qty'],
            'verifiedQty': item['verified_qty'],
            'rate': item['rate'],
            'amount': item['amount'],
            'photoUrls': item['photo_urls'],
          },
      ],
      'gps': {'lat': gpsLat, 'lng': gpsLng},
    };
  }

  bool _isValidGps(double? latitude, double? longitude) =>
      latitude != null &&
      longitude != null &&
      latitude.isFinite &&
      longitude.isFinite &&
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  Map<String, Object?> _collectionDraftBody({
    required Map<String, Object?> collectionRow,
    required List<String> handoverPhotoIds,
    required List<Map<String, Object?>> items,
  }) {
    final body = <String, Object?>{
      ...collectionRow,
      'handover_photo_urls': handoverPhotoIds,
      'items': items,
    };
    body.remove('gps_lat');
    body.remove('gps_lng');
    return body;
  }

  Future<void> _deleteUnreferencedPhotoRows(
    Transaction txn,
    List<String> photoIds,
  ) async {
    if (photoIds.isEmpty) return;
    final marks = List.filled(photoIds.length, '?').join(',');
    await txn.rawDelete('''
      DELETE FROM ${DatabaseTables.photos}
      WHERE id IN ($marks)
        AND NOT EXISTS (
          SELECT 1
          FROM ${DatabaseTables.outboxPhotos} op
          WHERE op.photo_id = ${DatabaseTables.photos}.id
        )
      ''', photoIds);
  }

  Future<void> discardDraft(String collectionId) =>
      _database.runInTransaction((txn) async {
        await OutboxQueue.removeQueued(
          txn,
          entity: DatabaseTables.collections,
          entityId: collectionId,
          kind: 'draft_save',
        );
        await txn.delete(
          DatabaseTables.collectionItems,
          where: 'collection_id = ?',
          whereArgs: [collectionId],
        );
        await txn.delete(
          DatabaseTables.collections,
          where: "id = ? AND status = 'DRAFT'",
          whereArgs: [collectionId],
        );
        await OutboxQueue.enqueue(
          txn,
          method: 'DELETE',
          path: '/collections/$collectionId',
          entity: DatabaseTables.collections,
          entityId: collectionId,
          kind: 'discard',
        );
      });

  Future<List<ExpenseModel>> getExpenses({
    bool supervisor = false,
    String? status,
  }) async {
    final userId = await currentUserId;
    if (!supervisor && userId == null) return const [];
    final centerId = await activeCenterId;
    if (centerId == null) return const [];
    final conditions = <String>[
      supervisor ? 'e.center_id = ?' : 'e.user_id = ? AND e.center_id = ?',
    ];
    final args = <Object?>[
      if (supervisor) centerId else ...[userId, centerId],
    ];
    if (status != null && status.isNotEmpty) {
      conditions.add('e.status = ?');
      args.add(status);
    }
    final rows = await _database.rawQuery('''
      SELECT e.*, ec.name AS category_name
      FROM ${DatabaseTables.expenses} e
      LEFT JOIN ${DatabaseTables.expenseCategories} ec ON ec.id = e.category_id
      WHERE ${conditions.join(' AND ')}
      ORDER BY CASE
        WHEN UPPER(e.status) IN ('PENDING', 'WAITING_SUPERVISOR', 'PENDING_REVIEW')
          THEN 0
        ELSE 1
      END, e.created_at DESC
    ''', args);
    return rows.map(ExpenseModel.fromMap).toList(growable: false);
  }

  Future<ExpenseModel?> getExpense(String expenseId) async {
    final centerId = await activeCenterId;
    if (centerId == null) return null;
    final rows = await _database.rawQuery(
      '''
      SELECT e.*, ec.name AS category_name
      FROM ${DatabaseTables.expenses} e
      LEFT JOIN ${DatabaseTables.expenseCategories} ec ON ec.id = e.category_id
      WHERE e.id = ? AND e.center_id = ?
      LIMIT 1
    ''',
      [expenseId, centerId],
    );
    return rows.isEmpty ? null : ExpenseModel.fromMap(rows.first);
  }

  Future<void> decideExpense({
    required String expenseId,
    required String outcome,
    String? reason,
    String? remarks,
  }) async {
    final normalizedId = expenseId.trim();
    final normalizedOutcome = outcome.trim().toUpperCase();
    final normalizedReason = reason?.trim();
    final normalizedRemarks = remarks?.trim();
    if (normalizedId.isEmpty) {
      throw const ExpenseDecisionValidationException('Expense is required.');
    }
    if (normalizedOutcome != 'APPROVED' && normalizedOutcome != 'REJECTED') {
      throw const ExpenseDecisionValidationException(
        'Expense outcome must be APPROVED or REJECTED.',
      );
    }
    if (normalizedOutcome == 'REJECTED' &&
        (normalizedReason == null || normalizedReason.isEmpty)) {
      throw const ExpenseDecisionValidationException(
        'A rejection reason is required.',
      );
    }
    if ((normalizedReason?.length ?? 0) > 1000 ||
        (normalizedRemarks?.length ?? 0) > 1000) {
      throw const ExpenseDecisionValidationException(
        'Reason and remarks must be 1000 characters or fewer.',
      );
    }

    final centerId = await activeCenterId;
    if (centerId == null) {
      throw const ExpenseDecisionValidationException(
        'An active center is required.',
      );
    }
    final profile = await getProfile();
    final now = DateTime.now().toUtc().toIso8601String();

    await _database.runInTransaction((txn) async {
      final rows = await txn.query(
        DatabaseTables.expenses,
        columns: const ['id', 'status'],
        where: 'id = ? AND center_id = ?',
        whereArgs: [normalizedId, centerId],
        limit: 1,
      );
      if (rows.isEmpty) {
        throw const ExpenseDecisionValidationException(
          'Expense was not found for the active center.',
        );
      }
      final currentStatus = (rows.first['status'] as String).toUpperCase();
      const pendingStatuses = {
        'PENDING',
        'WAITING_SUPERVISOR',
        'PENDING_REVIEW',
      };
      if (!pendingStatuses.contains(currentStatus)) {
        throw const ExpenseDecisionValidationException(
          'Only an expense pending review can be decided.',
        );
      }

      await txn.update(
        DatabaseTables.expenses,
        {
          'status': normalizedOutcome,
          'decided_by_name': profile.userName,
          'decision_reason': normalizedOutcome == 'REJECTED'
              ? normalizedReason
              : null,
          'decision_remarks':
              normalizedOutcome == 'REJECTED' &&
                  normalizedRemarks?.isNotEmpty == true
              ? normalizedRemarks
              : null,
          'updated_at': now,
          'sync_state': 'pending',
        },
        where: 'id = ? AND center_id = ?',
        whereArgs: [normalizedId, centerId],
      );
      await OutboxQueue.enqueue(
        txn,
        method: 'POST',
        path: '/expenses/$normalizedId/decide',
        entity: DatabaseTables.expenses,
        entityId: normalizedId,
        kind: 'decide',
        body: <String, Object?>{
          'outcome': normalizedOutcome,
          if (normalizedOutcome == 'REJECTED') 'reason': normalizedReason,
          if (normalizedOutcome == 'REJECTED' &&
              normalizedRemarks?.isNotEmpty == true)
            'remarks': normalizedRemarks,
        },
        refs: [normalizedId, centerId],
        createdAt: now,
      );
    });

    if (kDebugMode) {
      AppLogger.sqlite(
        'COMMIT',
        'Expense decision stored | expense_id=$normalizedId '
            'center=$centerId outcome=$normalizedOutcome sync_state=pending '
            'method=POST path=/expenses/$normalizedId/decide',
      );
    }
  }

  Future<List<String>> getExpenseReceiptSources(String expenseId) async {
    final photoRows = await _database.query(
      DatabaseTables.photos,
      columns: const ['id', 'local_path', 'remote_url', 'created_at'],
      where: 'owner_table = ? AND owner_id = ? AND field = ?',
      whereArgs: [DatabaseTables.expenses, expenseId, 'receipt'],
      orderBy: 'created_at ASC',
    );
    final sourceById = <String, String>{};
    final orderedSources = <String>[];
    for (final row in photoRows) {
      final localPath = (row['local_path'] as String?)?.trim();
      final remoteUrl = (row['remote_url'] as String?)?.trim();
      final source = localPath?.isNotEmpty == true
          ? localPath!
          : remoteUrl?.isNotEmpty == true
          ? remoteUrl!
          : null;
      if (source == null) continue;
      sourceById[row['id']! as String] = source;
      if (localPath?.isNotEmpty == true) sourceById[localPath!] = source;
      if (remoteUrl?.isNotEmpty == true) sourceById[remoteUrl!] = source;
      orderedSources.add(source);
    }

    final expenseRows = await _database.query(
      DatabaseTables.expenses,
      columns: const ['receipt_photo_urls'],
      where: 'id = ?',
      whereArgs: [expenseId],
      limit: 1,
    );
    final storedReferences = expenseRows.isEmpty
        ? const <String>[]
        : _decodeStringList(expenseRows.first['receipt_photo_urls']);
    final resolved = <String>[
      for (final reference in storedReferences)
        sourceById[reference] ?? reference,
      ...orderedSources,
    ];
    return resolved
        .map((source) => source.trim())
        .where((source) => source.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  Future<String> saveExpense({
    required String categoryId,
    required double amount,
    required List<String> receiptPaths,
    String? note,
    String? collectionId,
  }) async {
    if (categoryId.trim().isEmpty) {
      throw ArgumentError.value(
        categoryId,
        'categoryId',
        'Category is required.',
      );
    }
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Amount must be greater than zero.',
      );
    }
    if (receiptPaths.isEmpty) {
      throw ArgumentError.value(
        receiptPaths,
        'receiptPaths',
        'A receipt is required.',
      );
    }

    final centerId = await activeCenterId;
    final userId = await currentUserId;
    if (centerId == null || userId == null) {
      throw StateError('Active center and signed-in user are required.');
    }
    final categoryRows = await _database.query(
      DatabaseTables.expenseCategories,
      columns: const ['id'],
      where: 'id = ? AND center_id = ? AND is_active = 1',
      whereArgs: [categoryId, centerId],
      limit: 1,
    );
    if (categoryRows.isEmpty) {
      throw StateError('The selected expense category is unavailable.');
    }
    final wallet = await getWalletSummary(centerId: centerId);
    if (amount > wallet.balanceNow) {
      throw ExpenseBalanceUnavailableException(
        requestedAmount: amount,
        availableBalance: wallet.balanceNow,
      );
    }

    final expenseId = UuidGenerator.v4();
    final now = DateTime.now().toUtc().toIso8601String();
    final profile = await getProfile();
    final normalizedNote = note?.trim();
    final normalizedCollectionId = collectionId?.trim();
    final uniqueReceiptPaths = receiptPaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (uniqueReceiptPaths.isEmpty) {
      throw ArgumentError.value(
        receiptPaths,
        'receiptPaths',
        'A receipt is required.',
      );
    }
    final photoSizes = <String, int?>{
      for (final path in uniqueReceiptPaths) path: await _localFileSize(path),
    };
    final photoIds = <String>[];
    late final int outboxSeq;

    await _database.runInTransaction((txn) async {
      for (final path in uniqueReceiptPaths) {
        final photoId = UuidGenerator.v4();
        photoIds.add(photoId);
        await txn.insert(DatabaseTables.photos, {
          'id': photoId,
          'owner_table': DatabaseTables.expenses,
          'owner_id': expenseId,
          'field': 'receipt',
          'purpose': 'EXPENSE_RECEIPT',
          'content_type': 'image/jpeg',
          'local_path': path,
          'status': 'local',
          'size_bytes': photoSizes[path],
          'created_at': now,
        });
      }

      await txn.insert(DatabaseTables.expenses, {
        'id': expenseId,
        'center_id': centerId,
        'user_id': userId,
        'user_name': profile.userName,
        'category_id': categoryId,
        'amount': amount,
        'note': normalizedNote?.isEmpty == true ? null : normalizedNote,
        'status': 'PENDING',
        'receipt_photo_urls': jsonEncode(photoIds),
        'created_at': now,
        'updated_at': now,
        'sync_state': 'pending',
      });

      outboxSeq = await OutboxQueue.enqueue(
        txn,
        method: 'PUT',
        path: '/expenses/$expenseId',
        entity: DatabaseTables.expenses,
        entityId: expenseId,
        kind: 'create',
        body: <String, Object?>{
          'centerId': centerId,
          'categoryId': categoryId,
          'amount': amount,
          'spentAt': now,
          if (normalizedNote?.isNotEmpty == true) 'note': normalizedNote,
          if (normalizedCollectionId?.isNotEmpty == true)
            'collectionId': normalizedCollectionId,
          'photoUrls': photoIds,
        },
        refs: [
          centerId,
          categoryId,
          if (normalizedCollectionId?.isNotEmpty == true)
            normalizedCollectionId,
        ],
        blockingPhotoIds: photoIds,
        createdAt: now,
      );
    });

    if (kDebugMode) {
      AppLogger.sqlite(
        'COMMIT',
        'Expense stored | '
            'expense_id=$expenseId center=$centerId category=$categoryId '
            'amount=$amount status=PENDING sync_state=pending '
            'photos=${photoIds.length} outbox_seq=$outboxSeq '
            'method=PUT path=/expenses/$expenseId',
      );
    }
    return expenseId;
  }

  Future<List<CashRequestModel>> getCashRequests({
    bool supervisor = false,
  }) async {
    final userId = await currentUserId;
    if (!supervisor && userId == null) return const [];
    final centerId = await activeCenterId;
    if (centerId == null) return const [];
    final rows = await _database.query(
      DatabaseTables.cashRequests,
      where: supervisor
          ? 'center_id = ?'
          : 'requested_by = ? AND center_id = ?',
      whereArgs: supervisor ? [centerId] : [userId, centerId],
      orderBy: 'created_at DESC',
    );
    return rows.map(CashRequestModel.fromMap).toList(growable: false);
  }

  Future<void> decideCashRequest({
    required String requestId,
    required String outcome,
    String? reason,
    String? remarks,
  }) async {
    final normalizedId = requestId.trim();
    final normalizedOutcome = outcome.trim().toUpperCase();
    final normalizedReason = reason?.trim();
    final normalizedRemarks = remarks?.trim();
    if (normalizedId.isEmpty ||
        !const {'APPROVED', 'REJECTED'}.contains(normalizedOutcome)) {
      throw ArgumentError('A cash request and valid outcome are required.');
    }
    if (normalizedOutcome == 'REJECTED' &&
        (normalizedReason == null || normalizedReason.isEmpty)) {
      throw ArgumentError.value(reason, 'reason', 'Reject reason is required.');
    }
    if ((normalizedReason?.length ?? 0) > 1000 ||
        (normalizedRemarks?.length ?? 0) > 1000) {
      throw ArgumentError(
        'Reason and remarks must be 1000 characters or fewer.',
      );
    }
    final centerId = await activeCenterId;
    if (centerId == null) throw StateError('An active center is required.');
    final profile = await getProfile();
    final now = DateTime.now().toUtc().toIso8601String();
    await _database.runInTransaction((txn) async {
      final updated = await txn.update(
        DatabaseTables.cashRequests,
        {
          'status': normalizedOutcome,
          'decided_by_name': profile.userName,
          'decision_note': normalizedOutcome == 'REJECTED'
              ? normalizedReason
              : null,
          'decision_remarks':
              normalizedOutcome == 'REJECTED' &&
                  normalizedRemarks?.isNotEmpty == true
              ? normalizedRemarks
              : null,
          'updated_at': now,
          'sync_state': 'pending',
        },
        where:
            "id = ? AND center_id = ? AND UPPER(status) IN ('PENDING', 'WAITING_SUPERVISOR', 'PENDING_REVIEW')",
        whereArgs: [normalizedId, centerId],
      );
      if (updated != 1) {
        throw StateError(
          'Only a pending cash request at the active center can be decided.',
        );
      }
      await OutboxQueue.enqueue(
        txn,
        method: 'POST',
        path: '/cash-requests/$normalizedId/decide',
        entity: DatabaseTables.cashRequests,
        entityId: normalizedId,
        kind: 'decide',
        body: {
          'outcome': normalizedOutcome,
          if (normalizedOutcome == 'REJECTED') 'reason': normalizedReason,
          if (normalizedOutcome == 'REJECTED' &&
              normalizedRemarks?.isNotEmpty == true)
            'remarks': normalizedRemarks,
        },
        refs: [normalizedId, centerId],
        createdAt: now,
      );
    });
  }

  Future<String> saveCashRequest({
    required double amount,
    required String reason,
  }) async {
    if (!amount.isFinite || amount <= 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Requested amount must be greater than zero.',
      );
    }
    final normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) {
      throw ArgumentError.value(reason, 'reason', 'Reason is required.');
    }

    final centerId = await activeCenterId;
    final userId = await currentUserId;
    if (centerId == null || userId == null) {
      throw StateError('Active center and signed-in user are required.');
    }
    final wallet = await getWalletSummary(centerId: centerId);
    if (amount > wallet.balanceNow) {
      if (kDebugMode) {
        AppLogger.diagnostic(
          'CASH_REQUEST_VALIDATION',
          'Blocked | '
              'center=$centerId amount=$amount available=${wallet.balanceNow} '
              'sqlite_write=false outbox_write=false',
        );
      }
      throw CashRequestBalanceUnavailableException(
        requestedAmount: amount,
        availableBalance: wallet.balanceNow,
      );
    }
    final profile = await getProfile();
    final requestId = UuidGenerator.v4();
    final now = DateTime.now().toUtc().toIso8601String();
    late final int outboxSeq;

    await _database.runInTransaction((txn) async {
      await txn.insert(DatabaseTables.cashRequests, {
        'id': requestId,
        'center_id': centerId,
        'requested_by': userId,
        'requested_by_name': profile.userName,
        'amount': amount,
        'reason': normalizedReason,
        'status': 'PENDING',
        'created_at': now,
        'updated_at': now,
        'sync_state': 'pending',
      });
      outboxSeq = await OutboxQueue.enqueue(
        txn,
        method: 'PUT',
        path: '/cash-requests/$requestId',
        entity: DatabaseTables.cashRequests,
        entityId: requestId,
        kind: 'create',
        body: {
          'centerId': centerId,
          'amount': amount,
          'reason': normalizedReason,
        },
        refs: [centerId],
        createdAt: now,
      );
    });

    if (kDebugMode) {
      AppLogger.sqlite(
        'COMMIT',
        'Cash request stored | '
            'request_id=$requestId center=$centerId amount=$amount '
            'status=PENDING sync_state=pending outbox_seq=$outboxSeq '
            'method=PUT path=/cash-requests/$requestId',
      );
    }
    return requestId;
  }

  Future<List<CategoryRequestModel>> getCategoryRequests({
    bool supervisor = false,
  }) async {
    final userId = await currentUserId;
    if (!supervisor && userId == null) return const [];
    final centerId = await activeCenterId;
    if (centerId == null) return const [];
    final rows = await _database.query(
      DatabaseTables.categoryRequests,
      where: supervisor
          ? 'center_id = ?'
          : 'requested_by = ? AND center_id = ?',
      whereArgs: supervisor ? [centerId] : [userId, centerId],
      orderBy: 'created_at DESC',
    );
    return rows.map(CategoryRequestModel.fromMap).toList(growable: false);
  }

  Future<void> decideCategoryRequest({
    required String requestId,
    required String outcome,
    String? reason,
  }) async {
    final normalizedId = requestId.trim();
    final normalizedOutcome = outcome.trim().toUpperCase();
    final normalizedReason = reason?.trim();
    if (normalizedId.isEmpty ||
        !const {'APPROVED', 'REJECTED'}.contains(normalizedOutcome)) {
      throw ArgumentError(
        'An expense category request and valid outcome are required.',
      );
    }
    if (normalizedOutcome == 'REJECTED' &&
        (normalizedReason == null || normalizedReason.isEmpty)) {
      throw ArgumentError.value(reason, 'reason', 'Reject reason is required.');
    }
    if ((normalizedReason?.length ?? 0) > 1000) {
      throw ArgumentError.value(
        reason,
        'reason',
        'Reject reason must be 1000 characters or fewer.',
      );
    }
    final centerId = await activeCenterId;
    if (centerId == null) throw StateError('An active center is required.');
    final profile = await getProfile();
    final now = DateTime.now().toUtc().toIso8601String();
    await _database.runInTransaction((txn) async {
      final updated = await txn.update(
        DatabaseTables.categoryRequests,
        {
          'status': normalizedOutcome,
          'decided_by_name': profile.userName,
          'decided_at': now,
          'decision_reason': normalizedOutcome == 'REJECTED'
              ? normalizedReason
              : null,
          'sync_state': 'pending',
        },
        where:
            "id = ? AND center_id = ? AND UPPER(status) IN ('PENDING', 'OPEN')",
        whereArgs: [normalizedId, centerId],
      );
      if (updated != 1) {
        throw StateError(
          'Only a pending category request at the active center can be decided.',
        );
      }
      await OutboxQueue.enqueue(
        txn,
        method: 'POST',
        path: '/expense-categories/requests/$normalizedId/decide',
        entity: DatabaseTables.categoryRequests,
        entityId: normalizedId,
        kind: 'decide',
        body: {
          'outcome': normalizedOutcome,
          if (normalizedOutcome == 'REJECTED') 'reason': normalizedReason,
        },
        refs: [normalizedId, centerId],
        createdAt: now,
      );
    });
  }

  Future<String> saveCategoryRequest({
    required String name,
    String? reason,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Category name is required.');
    }
    final centerId = await activeCenterId;
    final userId = await currentUserId;
    if (centerId == null || userId == null) {
      throw StateError('Active center and signed-in user are required.');
    }
    final profile = await getProfile();

    final requestId = UuidGenerator.v4();
    final now = DateTime.now().toUtc().toIso8601String();
    final normalizedReason = reason?.trim();
    final body = <String, Object?>{
      'centerId': centerId,
      'name': normalizedName,
      'reason': normalizedReason?.isEmpty == true ? null : normalizedReason,
    };

    await _database.runInTransaction((txn) async {
      await txn.insert(DatabaseTables.categoryRequests, {
        'id': requestId,
        'center_id': centerId,
        'requested_by': userId,
        'requested_by_name': profile.userName,
        'name': normalizedName,
        'reason': normalizedReason?.isEmpty == true ? null : normalizedReason,
        'status': 'PENDING',
        'created_at': now,
        'sync_state': 'pending',
      });
      await OutboxQueue.enqueue(
        txn,
        method: 'PUT',
        path: '/expense-categories/requests/$requestId',
        entity: DatabaseTables.categoryRequests,
        entityId: requestId,
        kind: 'create',
        body: body,
        refs: [centerId],
        createdAt: now,
      );
    });

    if (kDebugMode) {
      AppLogger.sqlite(
        'COMMIT',
        'Category request stored | '
            'request_id=$requestId center=$centerId '
            'status=PENDING sync_state=pending '
            'method=PUT path=/expense-categories/requests/$requestId',
      );
    }
    return requestId;
  }

  Future<List<TransferModel>> getTransfers({
    bool supervisor = false,
    String? status,
    bool allCenters = false,
  }) async {
    final conditions = <String>[];
    final args = <Object?>[];
    if (!allCenters) {
      final centerId = await activeCenterId;
      if (!supervisor && centerId == null) return const [];
      conditions.add(
        supervisor
            ? 't.center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})'
            : 't.center_id = ?',
      );
      if (!supervisor) args.add(centerId);
    }
    if (status != null && status.isNotEmpty) {
      conditions.add('t.status = ?');
      args.add(status);
    }
    final rows = await _database.rawQuery('''
      SELECT t.*, c.name AS center_name, COUNT(ti.id) AS lines,
             COALESCE(SUM(COALESCE(ti.dispatched_qty, ti.qty)), 0) AS total_qty
      FROM ${DatabaseTables.transfers} t
      LEFT JOIN ${DatabaseTables.centers} c ON c.id = t.center_id
      LEFT JOIN ${DatabaseTables.transferItems} ti ON ti.transfer_id = t.id
      ${conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}'}
      GROUP BY t.id
      ORDER BY t.requested_at DESC
    ''', args);
    return rows.map(TransferModel.fromMap).toList(growable: false);
  }

  Future<List<TransferVehicleModel>> getTransferVehicles() async {
    final rows = await _database.query(
      DatabaseTables.transferVehicles,
      orderBy: 'number COLLATE NOCASE',
    );
    return rows.map(TransferVehicleModel.fromMap).toList(growable: false);
  }

  Future<void> approveTransfer({
    required String transferId,
    required String destinationId,
    String? transferVehicleId,
    String? vehicleNumber,
    String? transporterName,
    double? transferFee,
    DateTime? vehicleArrivalTime,
    String? note,
  }) async {
    final normalizedDestinationId = destinationId.trim();
    if (normalizedDestinationId.isEmpty) {
      throw const TransferDecisionValidationException(
        'Choose where the material is going.',
      );
    }
    final centerId = await activeCenterId;
    if (centerId != null && normalizedDestinationId == centerId) {
      throw const TransferDecisionValidationException(
        'Choose a destination other than the current center.',
      );
    }

    final destinationRows = await _database.query(
      DatabaseTables.destinations,
      where: 'id = ?',
      whereArgs: [normalizedDestinationId],
      limit: 1,
    );
    if (destinationRows.isEmpty) {
      throw const TransferDecisionValidationException(
        'Choose where the material is going.',
      );
    }

    TransferVehicleModel? listedVehicle;
    final normalizedVehicleId = transferVehicleId?.trim();
    if (normalizedVehicleId != null && normalizedVehicleId.isNotEmpty) {
      final vehicleRows = await _database.query(
        DatabaseTables.transferVehicles,
        where: 'id = ?',
        whereArgs: [normalizedVehicleId],
        limit: 1,
      );
      if (vehicleRows.isNotEmpty) {
        listedVehicle = TransferVehicleModel.fromMap(vehicleRows.single);
      }
      if (listedVehicle == null) {
        throw const TransferDecisionValidationException(
          'Choose the truck that will take it.',
        );
      }
    }

    final normalizedNumber = (listedVehicle?.number ?? vehicleNumber ?? '')
        .trim()
        .toUpperCase();
    if (normalizedNumber.length < 4 || normalizedNumber.length > 20) {
      throw const TransferDecisionValidationException(
        'Enter the number as on the plate.',
      );
    }
    final ownership = listedVehicle?.ownership.toUpperCase() ?? 'HIRED';
    final normalizedTransporter =
        (listedVehicle?.transporterName ?? transporterName)?.trim();
    if ((normalizedTransporter?.length ?? 0) > 255) {
      throw const TransferDecisionValidationException(
        'Transporter name must be 255 characters or fewer.',
      );
    }
    final fee = ownership == 'COMPANY' ? 0.0 : transferFee;
    if (fee == null ||
        !fee.isFinite ||
        fee < 0 ||
        ((fee * 100).roundToDouble() - (fee * 100)).abs() > 0.000001) {
      throw const TransferDecisionValidationException(
        'Enter the fee in rupees for this hired truck.',
      );
    }
    final normalizedNote = note?.trim();
    if ((normalizedNote?.length ?? 0) > 150) {
      throw const TransferDecisionValidationException(
        'Note must be 150 characters or fewer.',
      );
    }
    if (vehicleArrivalTime != null &&
        vehicleArrivalTime.isBefore(DateTime.now())) {
      throw const TransferDecisionValidationException(
        'Vehicle arrival date and time cannot be in the past.',
      );
    }
    if (ownership != 'COMPANY' &&
        (normalizedTransporter == null || normalizedTransporter.isEmpty)) {
      throw const TransferDecisionValidationException(
        'Enter the transporter name for this hired truck.',
      );
    }

    final profile = await getProfile();
    final now = DateTime.now().toUtc().toIso8601String();
    final arrival = vehicleArrivalTime?.toUtc().toIso8601String();
    final vehicleBody = listedVehicle == null
        ? <String, Object?>{
            'vehicleNumber': normalizedNumber,
            'transporterName': normalizedTransporter?.isEmpty == true
                ? null
                : normalizedTransporter,
            'transferFee': fee,
          }
        : <String, Object?>{
            'transferVehicleId': listedVehicle.id,
            if (listedVehicle.isHired) 'transferFee': fee,
          };
    final body = <String, Object?>{
      'destinationFacilityId': normalizedDestinationId,
      'vehicleArrivalTime': ?arrival,
      'vehicle': vehicleBody,
      if (normalizedNote?.isNotEmpty == true) 'note': normalizedNote,
    };

    await _database.runInTransaction((txn) async {
      final updated = await txn.update(
        DatabaseTables.transfers,
        {
          'status': 'APPROVED',
          'destination_id': normalizedDestinationId,
          'destination_name': destinationRows.single['name'],
          'truck_expected_at': arrival,
          'transfer_vehicle_id': listedVehicle?.id,
          'planned_vehicle_number': normalizedNumber,
          'planned_vehicle_ownership': ownership,
          'transporter_name': ownership == 'COMPANY'
              ? null
              : normalizedTransporter,
          'transfer_fee': fee,
          'dispatch_note': normalizedNote?.isEmpty == true
              ? null
              : normalizedNote,
          'decided_by_name': profile.userName,
          'approved_at': now,
          'sync_state': 'pending',
        },
        where: "id = ? AND status IN ('REQUESTED', 'PENDING')",
        whereArgs: [transferId],
      );
      if (updated != 1) {
        throw StateError('This transfer is no longer waiting for approval.');
      }
      await OutboxQueue.enqueue(
        txn,
        method: 'POST',
        path: '/transfers/$transferId/approve',
        entity: DatabaseTables.transfers,
        entityId: transferId,
        kind: 'approve',
        body: body,
        refs: [
          normalizedDestinationId,
          if (listedVehicle != null) listedVehicle.id,
        ],
        createdAt: now,
      );
    });
  }

  Future<void> rejectTransfer({
    required String transferId,
    required String reason,
    String? remarks,
  }) async {
    final normalizedReason = reason.trim();
    final normalizedRemarks = remarks?.trim();
    if (normalizedReason.length < 3 || normalizedReason.length > 1000) {
      throw const TransferDecisionValidationException(
        'Rejection reason must be between 3 and 1000 characters.',
      );
    }
    if ((normalizedRemarks?.length ?? 0) > 1000) {
      throw const TransferDecisionValidationException(
        'Rejection remarks must be 1000 characters or fewer.',
      );
    }
    final profile = await getProfile();
    final now = DateTime.now().toUtc().toIso8601String();
    await _database.runInTransaction((txn) async {
      final updated = await txn.update(
        DatabaseTables.transfers,
        {
          'status': 'REJECTED',
          'rejection_reason': normalizedReason,
          'rejection_remarks': normalizedRemarks?.isEmpty == true
              ? null
              : normalizedRemarks,
          'decided_by_name': profile.userName,
          'approved_at': now,
          'sync_state': 'pending',
        },
        where: "id = ? AND status IN ('REQUESTED', 'PENDING')",
        whereArgs: [transferId],
      );
      if (updated != 1) {
        throw StateError('This transfer is no longer waiting for approval.');
      }
      await OutboxQueue.enqueue(
        txn,
        method: 'POST',
        path: '/transfers/$transferId/reject',
        entity: DatabaseTables.transfers,
        entityId: transferId,
        kind: 'reject',
        body: {
          'reason': normalizedReason,
          'remarks': normalizedRemarks?.isEmpty == true
              ? null
              : normalizedRemarks,
        },
        createdAt: now,
      );
    });
  }

  Future<String> saveTransferRequest({
    required Map<String, double> itemQuantities,
    required double estimatedExpense,
    String? note,
  }) async {
    // Also repair an already-open version-1 database (for example after a hot
    // reload) before writing fields recently added to the baseline schema.
    await _database.ensureCurrentSchema();

    final normalizedItems = Map<String, double>.fromEntries(
      itemQuantities.entries.where(
        (entry) => entry.key.trim().isNotEmpty && entry.value > 0,
      ),
    );
    if (normalizedItems.isEmpty) {
      throw ArgumentError('At least one transfer item is required.');
    }
    if (normalizedItems.length != 1) {
      throw ArgumentError('Exactly one transfer item is required.');
    }
    if (!estimatedExpense.isFinite || estimatedExpense < 0) {
      throw ArgumentError.value(
        estimatedExpense,
        'estimatedExpense',
        'Estimated expense must be zero or greater.',
      );
    }

    final centerId = await activeCenterId;
    final userId = await currentUserId;
    final profile = await getProfile();
    if (centerId == null || userId == null) {
      throw StateError('Active center and signed-in user are required.');
    }

    final transferId = UuidGenerator.v4();
    final now = DateTime.now().toUtc().toIso8601String();
    final normalizedNote = note?.trim();
    final totalQty = normalizedItems.values.fold<double>(0, (a, b) => a + b);
    final body = <String, Object?>{
      'centerId': centerId,
      'items': [
        for (final item in normalizedItems.entries)
          {'itemId': item.key, 'quantity': item.value},
      ],
      'estimatedExpense': estimatedExpense,
      'note': normalizedNote?.isEmpty == true ? null : normalizedNote,
    };

    await _database.runInTransaction((txn) async {
      for (final item in normalizedItems.entries) {
        final freeQuantity = await _transferFreeQuantity(
          txn,
          centerId: centerId,
          itemId: item.key,
        );
        if (item.value > freeQuantity) {
          throw TransferStockUnavailableException(
            itemId: item.key,
            requestedQuantity: item.value,
            freeQuantity: freeQuantity,
          );
        }
      }

      await txn.insert(DatabaseTables.transfers, {
        'id': transferId,
        'center_id': centerId,
        'type': 'STOCK_TRANSFER',
        'status': 'PENDING',
        'fixed_qty': totalQty,
        'estimated_expense': estimatedExpense,
        'note': normalizedNote?.isEmpty == true ? null : normalizedNote,
        'requested_by': userId,
        'requested_by_name': profile.userName ?? '',
        'requested_at': now,
        'updated_at': now,
        'sync_state': 'pending',
      });
      for (final item in normalizedItems.entries) {
        await txn.insert(DatabaseTables.transferItems, {
          'id': UuidGenerator.v4(),
          'transfer_id': transferId,
          'item_id': item.key,
          'qty': item.value,
          'dispatched_qty': null,
        });
      }
      await OutboxQueue.enqueue(
        txn,
        method: 'PUT',
        path: '/transfers/$transferId',
        entity: DatabaseTables.transfers,
        entityId: transferId,
        kind: 'create',
        body: body,
        refs: [centerId, ...normalizedItems.keys],
        createdAt: now,
      );
    });

    if (kDebugMode) {
      AppLogger.sqlite(
        'COMMIT',
        'Transfer stored | '
            'transfer_id=$transferId center=$centerId status=PENDING '
            'items=${normalizedItems.length} total_qty=$totalQty '
            'estimated_expense=$estimatedExpense outbox_path=/transfers/$transferId',
      );
    }
    return transferId;
  }

  Future<TransferModel?> getTransfer(String transferId) async {
    final centerId = await activeCenterId;
    if (centerId == null) return null;
    final rows = await _database.rawQuery(
      '''
      SELECT t.*, c.name AS center_name, COUNT(ti.id) AS lines,
             COALESCE(SUM(COALESCE(ti.dispatched_qty, ti.qty)), 0) AS total_qty
      FROM ${DatabaseTables.transfers} t
      LEFT JOIN ${DatabaseTables.centers} c ON c.id = t.center_id
      LEFT JOIN ${DatabaseTables.transferItems} ti ON ti.transfer_id = t.id
      WHERE t.id = ? AND t.center_id = ?
      GROUP BY t.id
      LIMIT 1
      ''',
      [transferId, centerId],
    );
    return rows.isEmpty ? null : TransferModel.fromMap(rows.single);
  }

  Future<List<TransferItemModel>> getTransferItems(String transferId) async {
    final centerId = await activeCenterId;
    if (centerId == null) return const [];
    final rows = await _database.rawQuery(
      '''
      SELECT ti.*, i.name, i.unit_code
      FROM ${DatabaseTables.transferItems} ti
      LEFT JOIN ${DatabaseTables.items} i ON i.id = ti.item_id
      JOIN ${DatabaseTables.transfers} t ON t.id = ti.transfer_id
      WHERE ti.transfer_id = ? AND t.center_id = ?
      ORDER BY i.name COLLATE NOCASE
    ''',
      [transferId, centerId],
    );
    return rows.map(TransferItemModel.fromMap).toList(growable: false);
  }

  Future<TransferDispatchDraftModel> getTransferDispatchDraft(
    String transferId,
  ) async {
    final centerId = await activeCenterId;
    String? vehicleNumber;
    String? driverName;
    final transferRows = await _database.query(
      DatabaseTables.transfers,
      columns: const ['vehicle_plate', 'planned_vehicle_number', 'driver_name'],
      where: 'id = ? AND center_id = ?',
      whereArgs: [transferId, centerId],
      limit: 1,
    );
    if (transferRows.isNotEmpty) {
      vehicleNumber =
          transferRows.single['vehicle_plate'] as String? ??
          transferRows.single['planned_vehicle_number'] as String?;
      driverName = transferRows.single['driver_name'] as String?;
    }
    final photoRows = await _database.query(
      DatabaseTables.photos,
      where: 'owner_table = ? AND owner_id = ? AND field IN (?, ?)',
      whereArgs: [
        DatabaseTables.transfers,
        transferId,
        'vehicle',
        'weighbridge',
      ],
      orderBy: 'created_at, id',
    );
    return TransferDispatchDraftModel(
      vehicleNumber: vehicleNumber,
      driverName: driverName,
      photos: photoRows
          .map(TransferDispatchPhotoModel.fromMap)
          .toList(growable: false),
    );
  }

  Future<void> saveTransferDispatchDraft({
    required String transferId,
    required String vehicleNumber,
    required String driverName,
  }) async {
    final plate = vehicleNumber.trim();
    final driver = driverName.trim();
    if (plate.length < 4 || plate.length > 20 || driver.isEmpty) {
      throw const TransferDispatchValidationException(
        'Enter a valid vehicle number and driver name.',
      );
    }
    final vehiclePhotos = await _database.query(
      DatabaseTables.photos,
      columns: const ['id'],
      where: 'owner_table = ? AND owner_id = ? AND field = ?',
      whereArgs: [DatabaseTables.transfers, transferId, 'vehicle'],
      orderBy: 'created_at, id',
    );
    if (vehiclePhotos.isEmpty || vehiclePhotos.length > 5) {
      throw const TransferDispatchValidationException(
        'Add between 1 and 5 vehicle photos.',
      );
    }
    final updated = await _database.update(
      DatabaseTables.transfers,
      {
        'vehicle_plate': plate,
        'driver_name': driver,
        'vehicle_photo_urls': jsonEncode(
          vehiclePhotos.map((row) => row['id']).toList(growable: false),
        ),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'sync_state': 'pending',
      },
      where: 'id = ? AND status = ?',
      whereArgs: [transferId, 'APPROVED'],
    );
    if (updated != 1) {
      throw const TransferDispatchValidationException(
        'Only an approved transfer can start loading.',
      );
    }
    if (kDebugMode) {
      AppLogger.sqlite(
        'UPDATE_TRANSFER',
        'Loading details stored | '
            'transfer_id=$transferId '
            'photos=${vehiclePhotos.length} table=transfers api_call=false',
      );
    }
  }

  Future<TransferDispatchPhotoModel> addTransferDispatchPhoto({
    required String transferId,
    required String field,
    required String localPath,
  }) async {
    if (field != 'vehicle' && field != 'weighbridge') {
      throw ArgumentError.value(
        field,
        'field',
        'Unsupported dispatch photo field',
      );
    }
    final existing = await _database.rawQuery(
      'SELECT COUNT(*) AS total FROM ${DatabaseTables.photos} '
      'WHERE owner_table = ? AND owner_id = ? AND field = ?',
      [DatabaseTables.transfers, transferId, field],
    );
    if (((existing.single['total'] as num?)?.toInt() ?? 0) >= 5) {
      throw const TransferDispatchValidationException(
        'A maximum of 5 photos is allowed.',
      );
    }
    final id = UuidGenerator.v4();
    await _database.insert(DatabaseTables.photos, {
      'id': id,
      'owner_table': DatabaseTables.transfers,
      'owner_id': transferId,
      'field': field,
      'purpose': 'TRANSFER_HANDOVER',
      'content_type': 'image/jpeg',
      'local_path': localPath,
      'status': 'local',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    if (kDebugMode) {
      AppLogger.sqlite(
        'INSERT_PHOTO',
        'transfer_id=$transferId '
            'photo_id=$id field=$field',
      );
    }
    return TransferDispatchPhotoModel(
      id: id,
      field: field,
      localPath: localPath,
      status: 'local',
    );
  }

  Future<void> removeTransferDispatchPhoto(String photoId) async {
    await _database.delete(
      DatabaseTables.photos,
      where: 'id = ?',
      whereArgs: [photoId],
    );
  }

  Future<void> submitTransferDispatch({
    required String transferId,
    required String vehicleNumber,
    required String driverName,
    required double dispatchedWeight,
    int? baleCount,
    double? piecesLoaded,
  }) async {
    final plate = vehicleNumber.trim();
    final driver = driverName.trim();
    if (plate.length < 4 || plate.length > 20) {
      throw const TransferDispatchValidationException(
        'Vehicle number must be 4 to 20 characters.',
      );
    }
    if (driver.isEmpty) {
      throw const TransferDispatchValidationException(
        'Driver name is required.',
      );
    }
    if (!dispatchedWeight.isFinite || dispatchedWeight <= 0) {
      throw const TransferDispatchValidationException(
        'Loaded weight must be more than zero.',
      );
    }
    if (baleCount != null && (baleCount < 1 || baleCount > 9999)) {
      throw const TransferDispatchValidationException(
        'Bales must be between 1 and 9999.',
      );
    }

    final transferRows = await _database.query(
      DatabaseTables.transfers,
      columns: const ['center_id', 'status', 'note'],
      where: 'id = ?',
      whereArgs: [transferId],
      limit: 1,
    );
    if (transferRows.isEmpty || transferRows.single['status'] != 'APPROVED') {
      throw const TransferDispatchValidationException(
        'Only an approved transfer can be dispatched.',
      );
    }
    final itemRows = await _database.rawQuery(
      '''
      SELECT ti.id, ti.item_id, ti.qty, ti.dispatched_qty, i.unit_code
      FROM ${DatabaseTables.transferItems} ti
      LEFT JOIN ${DatabaseTables.items} i ON i.id = ti.item_id
      WHERE ti.transfer_id = ?
      ORDER BY ti.id
      ''',
      [transferId],
    );
    if (itemRows.isEmpty) {
      throw const TransferDispatchValidationException(
        'A transfer dispatch must contain at least one item.',
      );
    }
    final singleItemIsPieces =
        itemRows.length == 1 &&
        itemRows.single['unit_code']?.toString().toUpperCase() == 'PCS';
    if (singleItemIsPieces &&
        (piecesLoaded == null ||
            !piecesLoaded.isFinite ||
            piecesLoaded <= 0 ||
            piecesLoaded != piecesLoaded.roundToDouble())) {
      throw const TransferDispatchValidationException(
        'Enter how many pieces went.',
      );
    }
    final dispatchItems = [
      for (final item in itemRows)
        {
          'itemId': item['item_id'],
          'quantity': itemRows.length == 1
              ? (singleItemIsPieces ? piecesLoaded : dispatchedWeight)
              : ((item['dispatched_qty'] ?? item['qty']) as num).toDouble(),
        },
    ];
    final photos = await _database.query(
      DatabaseTables.photos,
      columns: const ['id', 'field'],
      where: 'owner_table = ? AND owner_id = ? AND field IN (?, ?)',
      whereArgs: [
        DatabaseTables.transfers,
        transferId,
        'vehicle',
        'weighbridge',
      ],
      orderBy: 'created_at, id',
    );
    final vehiclePhotoIds = photos
        .where((row) => row['field'] == 'vehicle')
        .map((row) => row['id']! as String)
        .toList(growable: false);
    final weighbridgePhotoIds = photos
        .where((row) => row['field'] == 'weighbridge')
        .map((row) => row['id']! as String)
        .toList(growable: false);
    if (vehiclePhotoIds.isEmpty || vehiclePhotoIds.length > 5) {
      throw const TransferDispatchValidationException(
        'Add between 1 and 5 vehicle photos.',
      );
    }
    if (weighbridgePhotoIds.length > 5) {
      throw const TransferDispatchValidationException(
        'A maximum of 5 weighbridge photos is allowed.',
      );
    }

    final coordinates = await DeviceLocationService.instance
        .bestAvailableCoordinates(requestPermission: true);
    final now = DateTime.now().toUtc().toIso8601String();
    final body = <String, Object?>{
      'centerId': transferRows.single['center_id'],
      'handedOverAt': now,
      'vehicleNumber': plate,
      'driverName': driver,
      'vehiclePhotoUrls': vehiclePhotoIds,
      'dispatchedWeight': dispatchedWeight,
      ...(baleCount == null
          ? const <String, Object?>{}
          : <String, Object?>{'baleCount': baleCount}),
      'weighbridgePhotoUrls': weighbridgePhotoIds,
      'items': dispatchItems,
      'note': transferRows.single['note'],
      if (coordinates != null)
        'gps': {'lat': coordinates.latitude, 'lng': coordinates.longitude},
    };
    await _database.runInTransaction((txn) async {
      final updated = await txn.update(
        DatabaseTables.transfers,
        {
          'status': 'DISPATCHED',
          'handed_over_at': now,
          'vehicle_plate': plate,
          'driver_name': driver,
          'dispatched_weight': dispatchedWeight,
          'bale_count': baleCount,
          'gps_lat': coordinates?.latitude,
          'gps_lng': coordinates?.longitude,
          'vehicle_photo_urls': jsonEncode(vehiclePhotoIds),
          'weighbridge_photo_urls': jsonEncode(weighbridgePhotoIds),
          'updated_at': now,
          'sync_state': 'pending',
        },
        where: 'id = ? AND status = ?',
        whereArgs: [transferId, 'APPROVED'],
      );
      if (updated != 1) {
        throw const TransferDispatchValidationException(
          'Transfer is no longer approved.',
        );
      }
      for (var index = 0; index < itemRows.length; index++) {
        await txn.update(
          DatabaseTables.transferItems,
          {'dispatched_qty': dispatchItems[index]['quantity']},
          where: 'id = ?',
          whereArgs: [itemRows[index]['id']],
        );
      }
      await OutboxQueue.enqueue(
        txn,
        method: 'POST',
        path: '/transfers/$transferId/handover',
        entity: DatabaseTables.transfers,
        entityId: transferId,
        kind: 'handover',
        body: body,
        blockingPhotoIds: [...vehiclePhotoIds, ...weighbridgePhotoIds],
        createdAt: now,
      );
    });
    if (kDebugMode) {
      AppLogger.sqlite(
        'COMMIT',
        'Transfer dispatched | '
            'transfer_id=$transferId vehicle_photos=${vehiclePhotoIds.length} '
            'weighbridge_photos=${weighbridgePhotoIds.length} '
            'outbox_path=/transfers/$transferId/handover',
      );
    }
  }

  Future<List<TaskModel>> getTasks({
    bool supervisor = false,
    String search = '',
  }) async {
    final userId = await currentUserId;
    if (!supervisor && userId == null) return const [];
    final centerId = await activeCenterId;
    if (!supervisor && centerId == null) return const [];
    final conditions = <String>[
      supervisor
          ? 'center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})'
          : 'assigned_to = ? AND center_id = ?',
    ];
    final args = <Object?>[
      if (!supervisor) ...[userId, centerId],
    ];
    if (search.trim().isNotEmpty) {
      conditions.add('(title LIKE ? OR description LIKE ? OR note LIKE ?)');
      final like = '%${search.trim()}%';
      args.addAll([like, like, like]);
    }
    final rows = await _database.query(
      DatabaseTables.tasks,
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: supervisor
          ? "CASE status WHEN 'PENDING' THEN 0 ELSE 1 END, due_at"
          : "CASE status WHEN 'PENDING' THEN 0 ELSE 1 END, "
                "CASE priority WHEN 'HIGH' THEN 0 WHEN 'NORMAL' THEN 1 ELSE 2 END, created_at DESC",
    );
    return rows.map(TaskModel.fromMap).toList(growable: false);
  }

  Future<TaskModel?> getTask(String taskId) async {
    final normalizedTaskId = taskId.trim();
    if (normalizedTaskId.isEmpty) return null;
    final rows = await _database.rawQuery(
      '''
      SELECT t.*, c.name AS center_name
      FROM ${DatabaseTables.tasks} t
      LEFT JOIN ${DatabaseTables.centers} c ON c.id = t.center_id
      WHERE t.id = ?
      LIMIT 1
      ''',
      [normalizedTaskId],
    );
    return rows.isEmpty ? null : TaskModel.fromMap(rows.single);
  }

  Future<String> assignTask({
    required String centerId,
    required String assignedToId,
    required String title,
    required String description,
    required String priority,
    required DateTime dueDate,
    required List<String> photoPaths,
  }) async {
    final normalizedCenterId = centerId.trim();
    final normalizedAssignedToId = assignedToId.trim();
    final normalizedTitle = title.trim();
    final normalizedDescription = description.trim();
    final normalizedPriority = priority.trim().toUpperCase();
    final uniquePhotoPaths = photoPaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .toSet()
        .toList(growable: false);

    if (normalizedCenterId.isEmpty) {
      throw ArgumentError.value(centerId, 'centerId', 'Center is required.');
    }
    if (normalizedAssignedToId.isEmpty) {
      throw ArgumentError.value(
        assignedToId,
        'assignedToId',
        'Agent is required.',
      );
    }
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Title is required.');
    }
    if (normalizedDescription.isEmpty) {
      throw ArgumentError.value(
        description,
        'description',
        'Description is required.',
      );
    }
    if (!const {'LOW', 'NORMAL', 'HIGH'}.contains(normalizedPriority)) {
      throw ArgumentError.value(
        priority,
        'priority',
        'Priority must be LOW, NORMAL, or HIGH.',
      );
    }
    if (!dueDate.isAfter(DateTime.now())) {
      throw ArgumentError.value(
        dueDate,
        'dueDate',
        'Due date and time must be in the future.',
      );
    }
    if (uniquePhotoPaths.isEmpty) {
      throw ArgumentError.value(
        photoPaths,
        'photoPaths',
        'A reference photo is required.',
      );
    }

    final userId = await currentUserId;
    if (userId == null || userId.trim().isEmpty) {
      throw StateError('A signed-in supervisor is required.');
    }
    final profile = await getProfile();
    final centerRows = await _database.rawQuery(
      '''
      SELECT 1
      FROM ${DatabaseTables.myCenters}
      WHERE center_id = ?
      LIMIT 1
      ''',
      [normalizedCenterId],
    );
    if (centerRows.isEmpty) {
      throw StateError('The selected center is unavailable.');
    }
    final agentRows = await _database.query(
      DatabaseTables.centerPeople,
      columns: const ['name'],
      where: 'center_id = ? AND user_id = ? AND is_agent = 1',
      whereArgs: [normalizedCenterId, normalizedAssignedToId],
      limit: 1,
    );
    if (agentRows.isEmpty) {
      throw StateError('The selected agent is unavailable at this center.');
    }

    final taskId = UuidGenerator.v4();
    final now = DateTime.now().toUtc().toIso8601String();
    final dueDateUtc = dueDate.toUtc().toIso8601String();
    late final int outboxSeq;
    await _database.runInTransaction((txn) async {
      await txn.insert(DatabaseTables.tasks, {
        'id': taskId,
        'center_id': normalizedCenterId,
        'assigned_to': normalizedAssignedToId,
        'assigned_to_name': agentRows.single['name'],
        'assigned_by': userId,
        'assigned_by_name': profile.userName,
        'title': normalizedTitle,
        'description': normalizedDescription,
        'priority': normalizedPriority,
        'status': 'PENDING',
        'due_at': dueDateUtc,
        'photo_urls': jsonEncode(uniquePhotoPaths),
        'created_at': now,
        'sync_state': 'pending',
      });

      outboxSeq = await OutboxQueue.enqueue(
        txn,
        method: 'PUT',
        path: '/tasks/$taskId',
        entity: DatabaseTables.tasks,
        entityId: taskId,
        kind: 'assign',
        body: {
          'assignedToId': normalizedAssignedToId,
          'centerId': normalizedCenterId,
          'title': normalizedTitle,
          'description': normalizedDescription,
          'priority': normalizedPriority,
          'dueDate': dueDateUtc,
        },
        refs: [normalizedCenterId, normalizedAssignedToId],
        createdAt: now,
      );
    });

    if (kDebugMode) {
      AppLogger.sqlite(
        'COMMIT',
        'Task assigned | task_id=$taskId center=$normalizedCenterId '
            'agent=$normalizedAssignedToId due_at=$dueDateUtc '
            'outbox_seq=$outboxSeq method=PUT path=/tasks/$taskId',
      );
    }
    return taskId;
  }

  Future<void> completeTask({
    required String taskId,
    required String note,
    required List<String> photoPaths,
  }) async {
    final normalizedNote = note.trim();
    if (normalizedNote.isEmpty) {
      throw ArgumentError.value(note, 'note', 'Completion note is required.');
    }
    final uniquePhotoPaths = photoPaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (uniquePhotoPaths.isEmpty) {
      throw ArgumentError.value(
        photoPaths,
        'photoPaths',
        'Completion proof is required.',
      );
    }

    final now = DateTime.now().toUtc().toIso8601String();
    final photoSizes = <String, int?>{
      for (final path in uniquePhotoPaths) path: await _localFileSize(path),
    };
    final photoIds = <String>[];
    late final int outboxSeq;

    await _database.runInTransaction((txn) async {
      final rows = await txn.query(
        DatabaseTables.tasks,
        columns: const ['status'],
        where: 'id = ?',
        whereArgs: [taskId],
        limit: 1,
      );
      if (rows.isEmpty) throw StateError('Task $taskId was not found.');
      final status = rows.single['status']?.toString().toUpperCase();
      if (status == 'COMPLETED' || status == 'CLOSED') {
        throw StateError('Task $taskId is already completed.');
      }

      for (final path in uniquePhotoPaths) {
        final photoId = UuidGenerator.v4();
        photoIds.add(photoId);
        await txn.insert(DatabaseTables.photos, {
          'id': photoId,
          'owner_table': DatabaseTables.tasks,
          'owner_id': taskId,
          'field': 'completion',
          'purpose': 'TASK_COMPLETION',
          'content_type': 'image/jpeg',
          'local_path': path,
          'status': 'local',
          'size_bytes': photoSizes[path],
          'created_at': now,
        });
      }

      final updated = await txn.update(
        DatabaseTables.tasks,
        {
          'status': 'COMPLETED',
          'note': normalizedNote,
          'completed_at': now,
          'photo_urls': jsonEncode(uniquePhotoPaths),
          'sync_state': 'pending',
        },
        where: "id = ? AND UPPER(status) NOT IN ('COMPLETED', 'CLOSED')",
        whereArgs: [taskId],
      );
      if (updated != 1) {
        throw StateError('Task $taskId changed before completion was saved.');
      }

      outboxSeq = await OutboxQueue.enqueue(
        txn,
        method: 'POST',
        path: '/tasks/$taskId/complete',
        entity: DatabaseTables.tasks,
        entityId: taskId,
        kind: 'complete',
        body: {'note': normalizedNote, 'photoUrls': photoIds},
        refs: [taskId],
        blockingPhotoIds: photoIds,
        createdAt: now,
      );
    });

    if (kDebugMode) {
      AppLogger.sqlite(
        'COMMIT',
        'Task completion stored | task_id=$taskId status=COMPLETED '
            'photos=${photoIds.length} outbox_seq=$outboxSeq '
            'method=POST path=/tasks/$taskId/complete',
      );
    }
  }

  Future<void> cancelTask(String taskId) async {
    final normalizedTaskId = taskId.trim();
    if (normalizedTaskId.isEmpty) {
      throw ArgumentError.value(taskId, 'taskId', 'Task is required.');
    }
    final now = DateTime.now().toUtc().toIso8601String();
    late final int outboxSeq;
    await _database.runInTransaction((txn) async {
      final updated = await txn.rawUpdate(
        '''
        UPDATE ${DatabaseTables.tasks}
        SET status = 'CANCELLED', sync_state = 'pending'
        WHERE id = ?
          AND UPPER(status) = 'PENDING'
          AND center_id IN (
            SELECT center_id FROM ${DatabaseTables.myCenters}
          )
        ''',
        [normalizedTaskId],
      );
      if (updated != 1) {
        throw StateError(
          'Only a pending task at your centers can be cancelled.',
        );
      }
      outboxSeq = await OutboxQueue.enqueue(
        txn,
        method: 'POST',
        path: '/tasks/$normalizedTaskId/cancel',
        entity: DatabaseTables.tasks,
        entityId: normalizedTaskId,
        kind: 'cancel',
        refs: [normalizedTaskId],
        createdAt: now,
      );
    });
    if (kDebugMode) {
      AppLogger.sqlite(
        'COMMIT',
        'Task cancelled | task_id=$normalizedTaskId outbox_seq=$outboxSeq '
            'method=POST path=/tasks/$normalizedTaskId/cancel',
      );
    }
  }

  Future<List<RequestModel>> getRequests({
    bool supervisor = false,
    String search = '',
  }) async {
    final userId = await currentUserId;
    if (!supervisor && userId == null) return const [];
    final centerId = await activeCenterId;
    if (!supervisor && centerId == null) return const [];
    final conditions = <String>[
      supervisor
          ? 'center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})'
          : 'created_by = ? AND center_id = ?',
    ];
    final args = <Object?>[
      if (!supervisor) ...[userId, centerId],
    ];
    if (search.trim().isNotEmpty) {
      conditions.add('(body LIKE ? OR created_by_name LIKE ?)');
      final like = '%${search.trim()}%';
      args.addAll([like, like]);
    }
    final rows = supervisor
        ? await _database.rawQuery(
            '''
            SELECT r.*,
              (SELECT value FROM ${DatabaseTables.syncMeta}
                WHERE key = 'supervisor_name') AS supervisor_name,
              (r.follow_up_at IS NOT NULL
                AND r.follow_up_at < ?
                AND UPPER(r.status) IN ('OPEN', 'PENDING')) AS overdue
            FROM ${DatabaseTables.requests} r
            WHERE ${conditions.join(' AND ')}
            ORDER BY
              CASE UPPER(r.status) WHEN 'OPEN' THEN 0 WHEN 'PENDING' THEN 0 ELSE 1 END,
              CASE r.priority WHEN 'HIGH' THEN 0 WHEN 'NORMAL' THEN 1 ELSE 2 END,
              r.created_at DESC
            ''',
            [DateTime.now().toUtc().toIso8601String(), ...args],
          )
        : await _database.rawQuery('''
            SELECT r.*,
              (SELECT value FROM ${DatabaseTables.syncMeta}
                WHERE key = 'supervisor_name') AS supervisor_name
            FROM ${DatabaseTables.requests} r
            WHERE ${conditions.join(' AND ')}
            ORDER BY r.created_at DESC
            ''', args);
    return rows.map(RequestModel.fromMap).toList(growable: false);
  }

  Future<void> answerRequest({
    required String requestId,
    required String notes,
  }) async {
    final normalizedRequestId = requestId.trim();
    final normalizedNotes = notes.trim();
    if (normalizedRequestId.isEmpty) {
      throw ArgumentError.value(requestId, 'requestId', 'Request is required.');
    }
    if (normalizedNotes.length < 3) {
      throw ArgumentError.value(
        notes,
        'notes',
        'Answer notes must be at least 3 characters.',
      );
    }
    final now = DateTime.now().toUtc().toIso8601String();
    late final int outboxSeq;
    await _database.runInTransaction((txn) async {
      final proofRows = await txn.query(
        DatabaseTables.photos,
        columns: const ['id'],
        where: 'owner_table = ? AND owner_id = ? AND field = ?',
        whereArgs: [DatabaseTables.requests, normalizedRequestId, 'answer'],
        orderBy: 'created_at ASC',
      );
      final proofPhotoIds = proofRows
          .map((row) => row['id'])
          .whereType<String>()
          .toList(growable: false);
      final updated = await txn.rawUpdate(
        '''
        UPDATE ${DatabaseTables.requests}
        SET status = 'CLOSED', answer = ?, answered_at = ?, sync_state = 'pending'
        WHERE id = ?
          AND UPPER(status) = 'OPEN'
          AND center_id IN (
            SELECT center_id FROM ${DatabaseTables.myCenters}
          )
        ''',
        [normalizedNotes, now, normalizedRequestId],
      );
      if (updated != 1) {
        throw StateError(
          'Only an open request at your centers can be answered.',
        );
      }
      outboxSeq = await OutboxQueue.enqueue(
        txn,
        method: 'POST',
        path: '/requests/$normalizedRequestId/answer',
        entity: DatabaseTables.requests,
        entityId: normalizedRequestId,
        kind: 'answer',
        body: {'notes': normalizedNotes, 'photoUrls': proofPhotoIds},
        refs: [normalizedRequestId],
        blockingPhotoIds: proofPhotoIds,
        createdAt: now,
      );
    });
    if (kDebugMode) {
      AppLogger.sqlite(
        'COMMIT',
        'Request answered | request_id=$normalizedRequestId '
            'outbox_seq=$outboxSeq method=POST '
            'path=/requests/$normalizedRequestId/answer',
      );
    }
  }

  Future<String> stageRequestAnswerPhoto({
    required String requestId,
    required String path,
  }) async {
    final normalizedRequestId = requestId.trim();
    final normalizedPath = path.trim();
    if (normalizedRequestId.isEmpty || normalizedPath.isEmpty) {
      throw ArgumentError('Request and proof photo are required.');
    }
    final requestRows = await _database.rawQuery(
      '''
      SELECT 1
      FROM ${DatabaseTables.requests}
      WHERE id = ?
        AND UPPER(status) IN ('OPEN', 'PENDING')
        AND center_id IN (
          SELECT center_id FROM ${DatabaseTables.myCenters}
        )
      LIMIT 1
      ''',
      [normalizedRequestId],
    );
    if (requestRows.isEmpty) {
      throw StateError('Only an open request at your centers can be answered.');
    }
    final photoId = UuidGenerator.v4();
    final now = DateTime.now().toUtc().toIso8601String();
    await _database.insert(DatabaseTables.photos, {
      'id': photoId,
      'owner_table': DatabaseTables.requests,
      'owner_id': normalizedRequestId,
      'field': 'answer',
      'purpose': 'REQUEST',
      'content_type': 'image/jpeg',
      'local_path': normalizedPath,
      'status': 'local',
      'size_bytes': await _localFileSize(normalizedPath),
      'created_at': now,
    });
    return photoId;
  }

  Future<void> removeRequestAnswerPhoto({
    required String requestId,
    required String photoId,
  }) async {
    await _database.delete(
      DatabaseTables.photos,
      where:
          'id = ? AND owner_table = ? AND owner_id = ? '
          "AND field = 'answer' AND status = 'local'",
      whereArgs: [photoId, DatabaseTables.requests, requestId],
    );
  }

  Future<List<String>> getRequestAnswerPhotoSources(String requestId) async {
    final rows = await _database.query(
      DatabaseTables.requests,
      columns: const ['answer_photo_urls'],
      where: 'id = ?',
      whereArgs: [requestId],
      limit: 1,
    );
    final stored = rows.isEmpty
        ? const <String>[]
        : _decodeStringList(rows.single['answer_photo_urls']);
    final photoRows = await _database.query(
      DatabaseTables.photos,
      columns: const ['id', 'local_path', 'remote_url', 'created_at'],
      where: 'owner_table = ? AND owner_id = ? AND field = ?',
      whereArgs: [DatabaseTables.requests, requestId, 'answer'],
      orderBy: 'created_at ASC',
    );
    return _photoSourcesForReferences(stored, photoRows);
  }

  Future<List<String>> getRequestPhotoSources(String requestId) async {
    final rows = await _database.query(
      DatabaseTables.requests,
      columns: const ['photo_urls'],
      where: 'id = ?',
      whereArgs: [requestId],
      limit: 1,
    );
    final stored = rows.isEmpty
        ? const <String>[]
        : _decodeStringList(rows.single['photo_urls']);
    final photoRows = await _database.query(
      DatabaseTables.photos,
      columns: const ['id', 'local_path', 'remote_url', 'created_at'],
      where: 'owner_table = ? AND owner_id = ? AND field = ?',
      whereArgs: [DatabaseTables.requests, requestId, 'request'],
      orderBy: 'created_at ASC',
    );
    return _photoSourcesForReferences(stored, photoRows);
  }

  Future<String> raiseRequest({
    required String body,
    required String priority,
    required DateTime followUpAt,
    required List<String> photoPaths,
  }) async {
    final normalizedBody = body.trim();
    if (normalizedBody.isEmpty) {
      throw ArgumentError.value(
        body,
        'body',
        'Request description is required.',
      );
    }
    final normalizedPriority = priority.trim().toUpperCase();
    if (!const {'LOW', 'NORMAL', 'HIGH'}.contains(normalizedPriority)) {
      throw ArgumentError.value(
        priority,
        'priority',
        'Invalid request priority.',
      );
    }
    if (!followUpAt.isAfter(DateTime.now())) {
      throw ArgumentError.value(
        followUpAt,
        'followUpAt',
        'Follow-up date and time must be in the future.',
      );
    }
    final uniquePhotoPaths = photoPaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (uniquePhotoPaths.isEmpty) {
      throw ArgumentError.value(
        photoPaths,
        'photoPaths',
        'A photo is required.',
      );
    }

    final centerId = await activeCenterId;
    final userId = await currentUserId;
    if (centerId == null || userId == null) {
      throw StateError('Active center and signed-in user are required.');
    }
    final profile = await getProfile();
    final requestId = UuidGenerator.v4();
    final now = DateTime.now().toUtc().toIso8601String();
    final followUpAtUtc = followUpAt.toUtc().toIso8601String();
    final photoSizes = <String, int?>{
      for (final path in uniquePhotoPaths) path: await _localFileSize(path),
    };
    final photoIds = <String>[];
    late final int outboxSeq;

    await _database.runInTransaction((txn) async {
      for (final path in uniquePhotoPaths) {
        final photoId = UuidGenerator.v4();
        photoIds.add(photoId);
        await txn.insert(DatabaseTables.photos, {
          'id': photoId,
          'owner_table': DatabaseTables.requests,
          'owner_id': requestId,
          'field': 'request',
          'purpose': 'REQUEST',
          'content_type': 'image/jpeg',
          'local_path': path,
          'status': 'local',
          'size_bytes': photoSizes[path],
          'created_at': now,
        });
      }

      await txn.insert(DatabaseTables.requests, {
        'id': requestId,
        'center_id': centerId,
        'created_by': userId,
        'created_by_name': profile.userName,
        'body': normalizedBody,
        'priority': normalizedPriority,
        'status': 'OPEN',
        'follow_up_at': followUpAtUtc,
        // Keep the captured files visible while they are waiting to upload.
        // OutgoingSyncService replaces these paths with the uploaded URLs.
        'photo_urls': jsonEncode(uniquePhotoPaths),
        'created_at': now,
        'sync_state': 'pending',
      });

      outboxSeq = await OutboxQueue.enqueue(
        txn,
        method: 'PUT',
        path: '/requests/$requestId',
        entity: DatabaseTables.requests,
        entityId: requestId,
        kind: 'raise',
        body: {
          'centerId': centerId,
          'body': normalizedBody,
          'priority': normalizedPriority,
          'followUpAt': followUpAtUtc,
          'photoUrls': photoIds,
        },
        refs: [centerId],
        blockingPhotoIds: photoIds,
        createdAt: now,
      );
    });

    if (kDebugMode) {
      AppLogger.sqlite(
        'COMMIT',
        'Request stored | request_id=$requestId center=$centerId '
            'follow_up_at=$followUpAtUtc photos=${photoIds.length} '
            'outbox_seq=$outboxSeq method=PUT path=/requests/$requestId',
      );
    }
    return requestId;
  }

  Future<WalletSummaryModel> getWalletSummary({String? centerId}) async {
    final resolvedCenter = centerId ?? await activeCenterId;
    if (resolvedCenter == null) {
      return const WalletSummaryModel(
        balanceNow: 0,
        cashIn: 0,
        paidOut: 0,
        spent: 0,
      );
    }
    final rows = await _database.rawQuery(
      '''
      SELECT
        COALESCE((SELECT balance FROM ${DatabaseTables.centerBalances}
          WHERE center_id = ?), 0)
          - COALESCE((SELECT SUM(amount) FROM ${DatabaseTables.expenses}
              WHERE center_id = ? AND sync_state = 'pending'), 0)
          - COALESCE((SELECT SUM(total_amount) FROM ${DatabaseTables.collections}
              WHERE center_id = ? AND sync_state = 'pending'
                AND status = 'SUBMITTED' AND takes_payment = 1), 0) AS balance_now,
        COALESCE(SUM(CASE WHEN kind = 'TOP_UP' THEN amount ELSE 0 END), 0) AS cash_in,
        -COALESCE(SUM(CASE WHEN kind IN ('COLLECTION_PAYMENT', 'COLLECTION_REVERSAL')
          THEN amount ELSE 0 END), 0) AS paid_out,
        -COALESCE(SUM(CASE WHEN kind IN ('EXPENSE', 'EXPENSE_REVERSAL')
          THEN amount ELSE 0 END), 0) AS spent
      FROM ${DatabaseTables.walletEntries}
      WHERE center_id = ? AND created_at >= ?
    ''',
      [
        resolvedCenter,
        resolvedCenter,
        resolvedCenter,
        resolvedCenter,
        _startOfIstDayUtc(),
      ],
    );
    return WalletSummaryModel.fromMap(rows.single);
  }

  Future<List<WalletEntryModel>> getWalletEntries({String? centerId}) async {
    final resolvedCenter = centerId ?? await activeCenterId;
    if (resolvedCenter == null) return const [];
    final rows = await _database.rawQuery(
      '''
      SELECT w.*, c.slip_number, e.number AS expense_number
      FROM ${DatabaseTables.walletEntries} w
      LEFT JOIN ${DatabaseTables.collections} c ON c.id = w.collection_id
      LEFT JOIN ${DatabaseTables.expenses} e ON e.id = w.expense_id
      WHERE w.center_id = ?
      ORDER BY w.created_at DESC
    ''',
      [resolvedCenter],
    );
    return rows.map(WalletEntryModel.fromMap).toList(growable: false);
  }

  Future<List<DayCloseModel>> getDayCloses({String? centerId}) async {
    final resolvedCenter = centerId ?? await activeCenterId;
    if (resolvedCenter == null) return const [];
    final rows = await _database.query(
      DatabaseTables.dayCloses,
      where: 'center_id = ?',
      whereArgs: [resolvedCenter],
      orderBy: 'date DESC',
    );
    return rows.map(DayCloseModel.fromMap).toList(growable: false);
  }

  Future<List<NotificationModel>> getNotifications() async =>
      (await _database.query(
        DatabaseTables.notifications,
        orderBy: 'created_at DESC',
      )).map(NotificationModel.fromMap).toList(growable: false);

  Future<void> markNotificationRead(String id) =>
      _database.runInTransaction((txn) async {
        final now = DateTime.now().toUtc().toIso8601String();
        final changed = await txn.update(
          DatabaseTables.notifications,
          {'read_at': now, 'sync_state': 'pending'},
          where: 'id = ? AND read_at IS NULL',
          whereArgs: [id],
        );
        if (changed == 0) return;
        await OutboxQueue.enqueue(
          txn,
          method: 'POST',
          path: '/notifications/$id/read',
          entity: DatabaseTables.notifications,
          entityId: id,
          kind: 'read',
          createdAt: now,
        );
      });

  Future<List<StockModel>> getStock({String? centerId, String? stage}) async {
    final resolvedCenter = centerId ?? await activeCenterId;
    if (resolvedCenter == null) return const [];
    final conditions = <String>['s.center_id = ?'];
    final args = <Object?>[resolvedCenter];
    if (stage != null && stage.isNotEmpty) {
      conditions.add('s.stage = ?');
      args.add(stage);
    }
    final rows = await _database.rawQuery('''
      SELECT s.*, i.name, i.unit_code, i.image_url, c.name AS center_name
      FROM ${DatabaseTables.stock} s
      JOIN ${DatabaseTables.items} i ON i.id = s.item_id
      JOIN ${DatabaseTables.centers} c ON c.id = s.center_id
      WHERE ${conditions.join(' AND ')}
      ORDER BY s.stage, i.name COLLATE NOCASE
    ''', args);
    return rows.map(StockModel.fromMap).toList(growable: false);
  }

  /// RM stock currently free for a transfer. The server stock snapshot is
  /// combined with submitted collections that are still pending in outbox,
  /// then quantities promised to other open transfers are subtracted.
  Future<List<StockModel>> getTransferStockInHand({String? centerId}) async {
    final resolvedCenter = centerId ?? await activeCenterId;
    if (resolvedCenter == null) return const [];
    final rows = await _database.rawQuery(
      '''
      SELECT MIN(s.id) AS id, s.center_id, s.item_id, s.stage,
             i.name, i.unit_code,
             SUM(s.qty) + COALESCE((
               SELECT SUM(ci.verified_qty)
               FROM ${DatabaseTables.collectionItems} ci
               JOIN ${DatabaseTables.collections} col
                 ON col.id = ci.collection_id
               WHERE col.center_id = s.center_id
                 AND ci.item_id = s.item_id
                 AND col.sync_state = 'pending'
                 AND col.status = 'SUBMITTED'
             ), 0) - COALESCE((
               SELECT SUM(ti.qty)
               FROM ${DatabaseTables.transferItems} ti
               JOIN ${DatabaseTables.transfers} t ON t.id = ti.transfer_id
               WHERE t.center_id = s.center_id
                 AND ti.item_id = s.item_id
                 AND UPPER(t.status) IN ('PENDING', 'REQUESTED', 'APPROVED')
             ), 0) AS qty
      FROM ${DatabaseTables.stock} s
      JOIN ${DatabaseTables.items} i ON i.id = s.item_id
      WHERE s.center_id = ? AND s.stage = 'RM'
      GROUP BY s.center_id, s.item_id, s.stage, i.name, i.unit_code
      ORDER BY qty DESC
      ''',
      [resolvedCenter],
    );
    return rows
        .map((row) {
          final normalized = Map<String, Object?>.from(row);
          final quantity = (normalized['qty'] as num?)?.toDouble() ?? 0;
          normalized['qty'] = quantity < 0 ? 0.0 : quantity;
          return StockModel.fromMap(normalized);
        })
        .toList(growable: false);
  }

  Future<double> _transferFreeQuantity(
    DatabaseExecutor executor, {
    required String centerId,
    required String itemId,
  }) async {
    final rows = await executor.rawQuery(
      '''
      SELECT MAX(
        COALESCE((
          SELECT SUM(s.qty)
          FROM ${DatabaseTables.stock} s
          WHERE s.center_id = ? AND s.item_id = ? AND s.stage = 'RM'
        ), 0) + COALESCE((
          SELECT SUM(ci.verified_qty)
          FROM ${DatabaseTables.collectionItems} ci
          JOIN ${DatabaseTables.collections} col ON col.id = ci.collection_id
          WHERE col.center_id = ?
            AND ci.item_id = ?
            AND col.sync_state = 'pending'
            AND col.status = 'SUBMITTED'
        ), 0) - COALESCE((
          SELECT SUM(ti.qty)
          FROM ${DatabaseTables.transferItems} ti
          JOIN ${DatabaseTables.transfers} t ON t.id = ti.transfer_id
          WHERE t.center_id = ?
            AND ti.item_id = ?
            AND UPPER(t.status) IN ('PENDING', 'REQUESTED', 'APPROVED')
        ), 0),
        0
      ) AS qty_free
      ''',
      [centerId, itemId, centerId, itemId, centerId, itemId],
    );
    return (rows.single['qty_free'] as num?)?.toDouble() ?? 0;
  }

  Future<List<AgentStatusModel>> getAgentStatus({String? centerId}) async {
    final todayStart = _startOfIstDayUtc();
    final rows = await _database.rawQuery(
      '''
      SELECT cp.user_id, cp.name, cp.phone, c.name AS center_name,
        COUNT(col.id) AS collections_today,
        MAX(col.collected_at) AS last_collection_at,
        SUM(CASE WHEN col.status = 'SUBMITTED' THEN 1 ELSE 0 END) AS waiting_review
      FROM ${DatabaseTables.centerPeople} cp
      JOIN ${DatabaseTables.centers} c ON c.id = cp.center_id
      LEFT JOIN ${DatabaseTables.collections} col
        ON col.agent_id = cp.user_id AND col.center_id = cp.center_id
        AND col.status != 'DRAFT' AND col.collected_at >= ?
      WHERE cp.is_agent = 1
        AND (? IS NULL OR cp.center_id = ?)
      GROUP BY cp.user_id, cp.center_id
      ORDER BY c.name COLLATE NOCASE, cp.name COLLATE NOCASE
    ''',
      [todayStart, centerId, centerId],
    );
    return rows.map(AgentStatusModel.fromMap).toList(growable: false);
  }

  Future<SyncStatusModel> getSyncStatus() async {
    final rows = await _database.rawQuery('''
      SELECT
        (SELECT value FROM ${DatabaseTables.syncMeta}
          WHERE key = 'last_bootstrap_at') AS last_bootstrap_at,
        (SELECT COUNT(*) FROM ${DatabaseTables.outbox}
          WHERE status = 'queued') AS queued_count,
        (SELECT COUNT(*) FROM ${DatabaseTables.outbox}
          WHERE status = 'sending') AS sending_count,
        (SELECT COUNT(*) FROM ${DatabaseTables.outbox}
          WHERE status = 'failed') AS failed_count,
        (SELECT COUNT(*) FROM ${DatabaseTables.photos}
          WHERE status IN ('local', 'uploading', 'failed')) AS waiting_photo_count
    ''');
    return SyncStatusModel.fromMap(rows.single);
  }

  Future<List<FailedOutboxItemModel>> getFailedOutboxItems() async =>
      (await _database.query(
        DatabaseTables.outbox,
        columns: const [
          'seq',
          'method',
          'path',
          'entity',
          'entity_id',
          'attempts',
          'last_error',
        ],
        where: "status = 'failed'",
        orderBy: 'seq',
      )).map(FailedOutboxItemModel.fromMap).toList(growable: false);

  Future<void> retryFailedOutboxItem(int seq) => _database.update(
    DatabaseTables.outbox,
    {'status': 'queued', 'next_attempt_at': null},
    where: "seq = ? AND status = 'failed'",
    whereArgs: [seq],
  );

  static Future<void> _upsertById(
    Transaction txn,
    String table,
    Map<String, Object?> values,
  ) async {
    final id = values['id'];
    if (id == null) throw ArgumentError('$table upsert requires an id.');

    final updates = <String, Object?>{...values}..remove('id');
    final changed = await txn.update(
      table,
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (changed == 0) {
      await txn.insert(table, values);
    }
  }

  static List<String> _decodeStringList(Object? value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }
    if (value is! String || value.trim().isEmpty) return const [];
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List) return const [];
      return decoded.map((item) => item.toString()).toList(growable: false);
    } on FormatException {
      return const [];
    }
  }

  static String _startOfIstDayUtc({int daysAgo = 0}) {
    final istNow = DateTime.now().toUtc().add(
      const Duration(hours: 5, minutes: 30),
    );
    final istStart = DateTime.utc(
      istNow.year,
      istNow.month,
      istNow.day,
    ).subtract(Duration(days: daysAgo));
    return istStart
        .subtract(const Duration(hours: 5, minutes: 30))
        .toIso8601String();
  }

  static String _dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
