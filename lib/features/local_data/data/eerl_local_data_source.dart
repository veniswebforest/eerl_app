import 'dart:io';

import 'package:eerl_app/core/location/device_location_service.dart';
import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/core/local_database/outbox_queue.dart';
import 'package:eerl_app/core/utils/uuid_generator.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class EerlLocalDataSource {
  EerlLocalDataSource({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  Future<String?> get currentUserId => _database.getSyncMeta('user_id');

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

  Future<List<CenterModel>> getCenters() async {
    final rows = await _database.rawQuery('''
      SELECT c.*, mc.is_primary
      FROM ${DatabaseTables.myCenters} mc
      JOIN ${DatabaseTables.centers} c ON c.id = mc.center_id
      ORDER BY mc.is_primary DESC, c.name COLLATE NOCASE
    ''');
    return rows.map(CenterModel.fromMap).toList(growable: false);
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
        collections: 0,
        kg: 0,
        tasks: 0,
        drafts: 0,
        toFix: 0,
      );
    }
    final todayStart = _startOfIstDayUtc();
    final rows = await _database.rawQuery(
      '''
      SELECT
        (SELECT COUNT(*) FROM ${DatabaseTables.collections}
          WHERE agent_id = ? AND center_id = ? AND status != 'DRAFT'
            AND collected_at >= ?) AS collections,
        (SELECT COALESCE(SUM(CASE WHEN i.unit_code = 'KG'
          THEN COALESCE(ci.verified_qty, ci.qty) ELSE 0 END), 0)
          FROM ${DatabaseTables.collectionItems} ci
          JOIN ${DatabaseTables.collections} c ON c.id = ci.collection_id
          JOIN ${DatabaseTables.items} i ON i.id = ci.item_id
          WHERE c.agent_id = ? AND c.center_id = ? AND c.status != 'DRAFT'
            AND c.collected_at >= ?) AS kg,
        (SELECT COUNT(*) FROM ${DatabaseTables.tasks}
          WHERE assigned_to = ? AND status = 'PENDING') AS tasks,
        (SELECT COUNT(*) FROM ${DatabaseTables.collections}
          WHERE agent_id = ? AND status = 'DRAFT') AS drafts,
        (SELECT COUNT(*) FROM ${DatabaseTables.collections}
          WHERE agent_id = ? AND status = 'REJECTED') AS to_fix
    ''',
      [
        userId,
        centerId,
        todayStart,
        userId,
        centerId,
        todayStart,
        userId,
        userId,
        userId,
      ],
    );
    return AgentHomeSummaryModel.fromMap(rows.single);
  }

  Future<SupervisorHomeSummaryModel> getSupervisorHomeSummary() async {
    final todayStart = _startOfIstDayUtc();
    final rows = await _database.rawQuery(
      '''
      SELECT
        (SELECT COUNT(*) FROM ${DatabaseTables.collections} c
          WHERE c.center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})
            AND c.status != 'DRAFT'
            AND c.collected_at >= ?) AS collections,
        (SELECT COALESCE(SUM(CASE WHEN i.unit_code = 'KG'
          THEN COALESCE(ci.verified_qty, ci.qty) ELSE 0 END), 0)
          FROM ${DatabaseTables.collectionItems} ci
          JOIN ${DatabaseTables.collections} c ON c.id = ci.collection_id
          JOIN ${DatabaseTables.items} i ON i.id = ci.item_id
          WHERE c.center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})
            AND c.status != 'DRAFT'
            AND c.collected_at >= ?) AS kg,
        (SELECT COUNT(*) FROM ${DatabaseTables.collections} c
          WHERE c.center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})
            AND c.status = 'SUBMITTED') AS pending_verification,
        (SELECT COUNT(*) FROM ${DatabaseTables.tasks} t
          WHERE t.center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})
            AND t.status = 'PENDING') AS open_tasks
    ''',
      [todayStart, todayStart],
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
      FROM ${DatabaseTables.items} i
      LEFT JOIN ${DatabaseTables.centerItems} ci
        ON ci.item_id = i.id AND ci.center_id = ? AND ci.channel = ?
      LEFT JOIN ${DatabaseTables.centerChannels} ch
        ON ch.center_id = ? AND ch.channel = ?
      ${selectedOnly ? 'WHERE COALESCE(ci.is_selected, 0) = 1' : ''}
      ORDER BY
        CASE WHEN ci.sort_order IS NULL THEN 1 ELSE 0 END,
        ci.sort_order,
        i.name COLLATE NOCASE
    ''',
      [resolvedCenter, channel, resolvedCenter, channel],
    );
    if (kDebugMode) {
      final configured = rows
          .where((row) => row['configured_item_id'] != null)
          .length;
      final selected = rows
          .where((row) => (row['is_selected'] as num?)?.toInt() == 1)
          .length;
      debugPrint(
        '📚 [EERL_MATERIAL_CONFIG][SQLITE][LOAD] ITEMS '
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
      ORDER BY ci.sort_order, i.name COLLATE NOCASE
      ''',
      [resolvedCenter, channel],
    );
    if (kDebugMode) {
      debugPrint(
        '📦 [EERL_ADD_COLLECTION][SQLITE][LOAD] CENTER_ITEMS '
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
            'WHERE id IN ($placeholders)',
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
        debugPrint(
          '🛑 [EERL_MATERIAL_CONFIG][SQLITE][COMMIT] VERIFY_FAILED '
          'center=$centerId channel=$channel tab=$tab '
          'rows=$storedCount/${itemIds.length} '
          'outbox_stored=${outbox.isNotEmpty}',
        );
        return;
      }

      final queued = outbox.single;
      debugPrint(
        '✅ [EERL_MATERIAL_CONFIG][SQLITE][COMMIT] STORED '
        'center=$centerId channel=$channel tab=$tab '
        'rows=$storedCount selected=${counts['selected_count'] ?? 0} '
        'pending=${counts['pending_count'] ?? 0} '
        'outbox_seq=${queued['seq']} method=${queued['method']} '
        'kind=${queued['kind']} queue_status=${queued['status']} '
        'path=${queued['path']}',
      );
    } catch (error) {
      debugPrint(
        '🛑 [EERL_MATERIAL_CONFIG][SQLITE][COMMIT] LOG_FAILED '
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

  Future<List<VehicleTypeModel>> getVehicleTypes() async =>
      (await _database.query(
        DatabaseTables.vehicleTypes,
        orderBy: 'name COLLATE NOCASE',
      )).map(VehicleTypeModel.fromMap).toList(growable: false);

  Future<void> saveVehicle(VehicleModel vehicle, {required bool isNew}) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final body = <String, Object?>{...vehicle.toMap()}..remove('sync_state');
    final refs = <String>[
      if (vehicle.centerId != null) vehicle.centerId!,
      vehicle.typeId,
    ];
    await _database.transaction((txn) async {
      await _upsertById(txn, DatabaseTables.vehicles, {
        ...vehicle.toMap(),
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
          'type_id',
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
        debugPrint(
          '🛑 [EERL_VEHICLE][SQLITE][COMMIT] VERIFY_FAILED '
          'vehicle_id=$vehicleId vehicle_stored=${vehicles.isNotEmpty} '
          'outbox_stored=${outbox.isNotEmpty}',
        );
        return;
      }

      final vehicle = vehicles.single;
      final queued = outbox.single;
      debugPrint(
        '✅ [EERL_VEHICLE][SQLITE][COMMIT] STORED '
        'vehicle_id=$vehicleId center=${vehicle['center_id']} '
        'plate=${vehicle['plate_number']} type_id=${vehicle['type_id']} '
        'is_active=${vehicle['is_active']} '
        'sync_state=${vehicle['sync_state']} '
        'outbox_seq=${queued['seq']} method=${queued['method']} '
        'kind=${queued['kind']} queue_status=${queued['status']} '
        'path=${queued['path']}',
      );
    } catch (error) {
      debugPrint(
        '🛑 [EERL_VEHICLE][SQLITE][COMMIT] LOG_FAILED '
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
        body: {'is_active': active},
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
  }) async {
    final resolvedCenter = centerId ?? await activeCenterId;
    if (resolvedCenter == null) return const [];
    final conditions = <String>['center_id = ?'];
    final args = <Object?>[resolvedCenter];
    if (activeOnly) conditions.add('is_active = 1');
    if (role != null && role.isNotEmpty) {
      conditions.add('role = ?');
      args.add(role);
    }
    final rows = await _database.query(
      DatabaseTables.mrfPeople,
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(MrfPersonModel.fromMap).toList(growable: false);
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

  Future<void> saveRagpicker(RagpickerModel ragpicker) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _database.transaction((txn) async {
      await _upsertById(txn, DatabaseTables.ragpickers, {
        ...ragpicker.toMap(),
        'sync_state': 'pending',
      });
      await OutboxQueue.enqueue(
        txn,
        method: 'PUT',
        path: '/ragpickers/${ragpicker.id}',
        body: ragpicker.toMap(),
        entity: DatabaseTables.ragpickers,
        entityId: ragpicker.id,
        kind: 'upsert',
        createdAt: now,
      );
    });
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
        body: {'is_active': active},
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

  Future<List<DestinationModel>> getDestinations() async =>
      (await _database.query(
        DatabaseTables.destinations,
        orderBy: 'name',
      )).map(DestinationModel.fromMap).toList(growable: false);

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
      debugPrint(
        '📋 [EERL_COLLECTION_RECORDS][SQLITE][LOAD] COLLECTIONS '
        'center=$resolvedCenter agent=$userId '
        'view=${drafts ? 'drafts' : 'history'} channel=${channel ?? 'ALL'} '
        'search=${search.trim().isEmpty ? '[EMPTY]' : search.trim()} '
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
    final conditions = <String>[
      'c.center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})',
      pending
          ? "c.status = 'SUBMITTED'"
          : "c.status IN ('APPROVED', 'REJECTED')",
    ];
    final args = <Object?>[];
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
    final rows = await _database.rawQuery(
      '''
      SELECT c.*, ct.name AS center_name,
        COALESCE(SUM(ci.qty), 0) AS total_qty,
        COUNT(ci.id) AS item_count
      FROM ${DatabaseTables.collections} c
      LEFT JOIN ${DatabaseTables.centers} ct ON ct.id = c.center_id
      LEFT JOIN ${DatabaseTables.collectionItems} ci ON ci.collection_id = c.id
      WHERE c.id = ?
      GROUP BY c.id
      LIMIT 1
    ''',
      [id],
    );
    return rows.isEmpty ? null : CollectionModel.fromMap(rows.first);
  }

  Future<List<CollectionItemModel>> getCollectionItems(
    String collectionId,
  ) async {
    final rows = await _database.rawQuery(
      '''
      SELECT ci.*, i.name, i.unit_code, i.unit_name
      FROM ${DatabaseTables.collectionItems} ci
      JOIN ${DatabaseTables.items} i ON i.id = ci.item_id
      WHERE ci.collection_id = ?
      ORDER BY ci.sort_order, i.name COLLATE NOCASE
    ''',
      [collectionId],
    );
    return rows.map(CollectionItemModel.fromMap).toList(growable: false);
  }

  Future<void> saveCollection({
    required CollectionModel collection,
    required List<CollectionItemModel> items,
    required bool submit,
  }) async {
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
    }
    final now = DateTime.now().toUtc().toIso8601String();
    final locationRows = submit
        ? await _database.query(
            DatabaseTables.collections,
            columns: const ['status'],
            where: 'id = ?',
            whereArgs: [collection.id],
            limit: 1,
          )
        : const <Map<String, Object?>>[];
    final resubmittingRejected =
        locationRows.isNotEmpty && locationRows.single['status'] == 'REJECTED';
    final capturedGps = submit && !resubmittingRejected
        ? await DeviceLocationService.instance.bestAvailableCoordinates()
        : null;
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
        whereArgs: [collection.centerId, collection.channel],
        limit: 1,
      );
      final takesPayment = channelRows.isEmpty
          ? collection.takesPayment
          : channelRows.single['takes_payment'] == 1;
      if (submit && collection.channel.toUpperCase() == 'MRF') {
        final supervisors = await txn.query(
          DatabaseTables.mrfPeople,
          columns: const ['id'],
          where: "id = ? AND role = 'SUPERVISOR' AND is_active = 1",
          whereArgs: [collection.mrfPersonId],
          limit: 1,
        );
        if (supervisors.isEmpty) {
          throw StateError('An active MRF supervisor is required.');
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
                ? (existingRow?['gps_lat'] as num?)?.toDouble()
                : capturedGps?.latitude)
          : (existingRow?['gps_lat'] as num?)?.toDouble();
      final gpsLng = submit
          ? (isResubmission
                ? (existingRow?['gps_lng'] as num?)?.toDouble()
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
        'status': submit ? 'SUBMITTED' : 'DRAFT',
        'slip_number': slipNumber,
        'collected_at': collectedAt,
        'takes_payment': takesPayment == null ? null : (takesPayment ? 1 : 0),
        'rejection_reason': submit ? null : collection.rejectionReason,
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
        channel: collection.channel,
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
      SELECT c.id, c.status, c.sync_state,
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
      debugPrint(
        '🛑 [EERL_COLLECTION][SQLITE][COMMIT] VERIFY_FAILED '
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
    debugPrint(
      '✅ [EERL_COLLECTION][SQLITE][COMMIT] STORED '
      'collection_id=$collectionId center=$centerId channel=$channel '
      'status=${graph['status']} sync_state=${graph['sync_state']} '
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
    final slipNumber = collectionRow['slip_number'];
    final collectedAt = collectionRow['collected_at'];
    final vehicleId = collectionRow['vehicle_id'];
    final givenByName = collectionRow['given_by_name'];
    final mrfLabourId = collectionRow['mrf_person_id'];
    final ragpickerId = collectionRow['ragpicker_id'];
    final paidBy = collectionRow['paid_by'];
    final gpsLat = (collectionRow['gps_lat'] as num?)?.toDouble();
    final gpsLng = (collectionRow['gps_lng'] as num?)?.toDouble();
    return <String, Object?>{
      'centerId': collectionRow['center_id'],
      'type': collectionRow['channel'],
      'slipNumber': ?slipNumber,
      'collectedAt': ?collectedAt,
      'vehicleId': ?vehicleId,
      'givenByName': ?givenByName,
      'mrfLabourId': ?mrfLabourId,
      'ragpickerId': ?ragpickerId,
      'handoverPhotoUrls': handoverPhotoIds,
      'paidBy': ?paidBy,
      'lines': [
        for (final item in items)
          {
            'itemId': item['item_id'],
            'collectedQty': item['qty'],
            if (item['verified_qty'] != null)
              'verifiedQty': item['verified_qty'],
            if (item['rate'] != null) 'rate': item['rate'],
            if (item['amount'] != null) 'amount': item['amount'],
            'photoUrls': item['photo_urls'],
          },
      ],
      'gps': gpsLat == null || gpsLng == null
          ? null
          : {'lat': gpsLat, 'lng': gpsLng},
    };
  }

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
    if (!supervisor && centerId == null) return const [];
    final conditions = <String>[
      supervisor
          ? 'e.center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})'
          : 'e.user_id = ? AND e.center_id = ?',
    ];
    final args = <Object?>[
      if (!supervisor) ...[userId, centerId],
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
      ORDER BY e.created_at DESC
    ''', args);
    return rows.map(ExpenseModel.fromMap).toList(growable: false);
  }

  Future<List<CashRequestModel>> getCashRequests({
    bool supervisor = false,
  }) async {
    final userId = await currentUserId;
    if (!supervisor && userId == null) return const [];
    final centerId = await activeCenterId;
    if (!supervisor && centerId == null) return const [];
    final rows = await _database.query(
      DatabaseTables.cashRequests,
      where: supervisor
          ? 'center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})'
          : 'requested_by = ? AND center_id = ?',
      whereArgs: supervisor ? null : [userId, centerId],
      orderBy: 'created_at DESC',
    );
    return rows.map(CashRequestModel.fromMap).toList(growable: false);
  }

  Future<List<CategoryRequestModel>> getCategoryRequests({
    bool supervisor = false,
  }) async {
    final userId = await currentUserId;
    if (!supervisor && userId == null) return const [];
    final centerId = await activeCenterId;
    if (!supervisor && centerId == null) return const [];
    final rows = await _database.query(
      DatabaseTables.categoryRequests,
      where: supervisor
          ? 'center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})'
          : 'requested_by = ? AND center_id = ?',
      whereArgs: supervisor ? null : [userId, centerId],
      orderBy: 'created_at DESC',
    );
    return rows.map(CategoryRequestModel.fromMap).toList(growable: false);
  }

  Future<List<TransferModel>> getTransfers({
    bool supervisor = false,
    String? status,
  }) async {
    final centerId = await activeCenterId;
    if (!supervisor && centerId == null) return const [];
    final conditions = <String>[
      supervisor
          ? 't.center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})'
          : 't.center_id = ?',
    ];
    final args = <Object?>[if (!supervisor) centerId];
    if (status != null && status.isNotEmpty) {
      conditions.add('t.status = ?');
      args.add(status);
    }
    final rows = await _database.rawQuery('''
      SELECT t.*, COUNT(ti.id) AS lines
      FROM ${DatabaseTables.transfers} t
      LEFT JOIN ${DatabaseTables.transferItems} ti ON ti.transfer_id = t.id
      WHERE ${conditions.join(' AND ')}
      GROUP BY t.id
      ORDER BY t.requested_at DESC
    ''', args);
    return rows.map(TransferModel.fromMap).toList(growable: false);
  }

  Future<List<TransferItemModel>> getTransferItems(String transferId) async {
    final rows = await _database.rawQuery(
      '''
      SELECT ti.*, i.name, i.unit_code
      FROM ${DatabaseTables.transferItems} ti
      JOIN ${DatabaseTables.items} i ON i.id = ti.item_id
      WHERE ti.transfer_id = ?
      ORDER BY i.name COLLATE NOCASE
    ''',
      [transferId],
    );
    return rows.map(TransferItemModel.fromMap).toList(growable: false);
  }

  Future<List<TaskModel>> getTasks({
    bool supervisor = false,
    String search = '',
  }) async {
    final userId = await currentUserId;
    if (!supervisor && userId == null) return const [];
    final conditions = <String>[
      supervisor
          ? 'center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})'
          : 'assigned_to = ?',
    ];
    final args = <Object?>[if (!supervisor) userId];
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

  Future<List<RequestModel>> getRequests({
    bool supervisor = false,
    String search = '',
  }) async {
    final userId = await currentUserId;
    if (!supervisor && userId == null) return const [];
    final conditions = <String>[
      supervisor
          ? 'center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})'
          : 'created_by = ?',
    ];
    final args = <Object?>[if (!supervisor) userId];
    if (search.trim().isNotEmpty) {
      conditions.add('(body LIKE ? OR created_by_name LIKE ?)');
      final like = '%${search.trim()}%';
      args.addAll([like, like]);
    }
    final rows = await _database.query(
      DatabaseTables.requests,
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'created_at DESC',
    );
    return rows.map(RequestModel.fromMap).toList(growable: false);
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
      SELECT s.*, i.name, i.unit_code, c.name AS center_name
      FROM ${DatabaseTables.stock} s
      JOIN ${DatabaseTables.items} i ON i.id = s.item_id
      JOIN ${DatabaseTables.centers} c ON c.id = s.center_id
      WHERE ${conditions.join(' AND ')}
      ORDER BY s.stage, i.name COLLATE NOCASE
    ''', args);
    return rows.map(StockModel.fromMap).toList(growable: false);
  }

  Future<List<AgentStatusModel>> getAgentStatus() async {
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
        AND cp.center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})
      GROUP BY cp.user_id, cp.center_id
      ORDER BY cp.name COLLATE NOCASE
    ''',
      [todayStart],
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
