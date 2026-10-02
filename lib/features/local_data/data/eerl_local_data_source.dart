import 'dart:convert';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
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
    if (userId == null) {
      return const AgentHomeSummaryModel(
        collections: 0,
        kg: 0,
        tasks: 0,
        drafts: 0,
        toFix: 0,
      );
    }
    final rows = await _database.rawQuery(
      '''
      SELECT
        (SELECT COUNT(*) FROM ${DatabaseTables.collections}
          WHERE agent_id = ? AND status != 'DRAFT'
            AND date(collected_at, 'localtime') = date('now', 'localtime')) AS collections,
        (SELECT COALESCE(SUM(ci.qty), 0)
          FROM ${DatabaseTables.collectionItems} ci
          JOIN ${DatabaseTables.collections} c ON c.id = ci.collection_id
          WHERE c.agent_id = ? AND c.status != 'DRAFT'
            AND date(c.collected_at, 'localtime') = date('now', 'localtime')) AS kg,
        (SELECT COUNT(*) FROM ${DatabaseTables.tasks}
          WHERE assigned_to = ? AND status NOT IN ('COMPLETED', 'CLOSED')) AS tasks,
        (SELECT COUNT(*) FROM ${DatabaseTables.collections}
          WHERE agent_id = ? AND status = 'DRAFT') AS drafts,
        (SELECT COUNT(*) FROM ${DatabaseTables.collections}
          WHERE agent_id = ? AND status = 'REJECTED') AS to_fix
    ''',
      [userId, userId, userId, userId, userId],
    );
    return AgentHomeSummaryModel.fromMap(rows.single);
  }

  Future<SupervisorHomeSummaryModel> getSupervisorHomeSummary() async {
    final rows = await _database.rawQuery('''
      SELECT
        (SELECT COUNT(*) FROM ${DatabaseTables.collections} c
          WHERE c.center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})
            AND c.status != 'DRAFT'
            AND date(c.collected_at, 'localtime') = date('now', 'localtime')) AS collections,
        (SELECT COALESCE(SUM(ci.qty), 0)
          FROM ${DatabaseTables.collectionItems} ci
          JOIN ${DatabaseTables.collections} c ON c.id = ci.collection_id
          WHERE c.center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})
            AND c.status != 'DRAFT'
            AND date(c.collected_at, 'localtime') = date('now', 'localtime')) AS kg,
        (SELECT COUNT(*) FROM ${DatabaseTables.collections} c
          WHERE c.center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})
            AND c.status IN ('SUBMITTED', 'PENDING', 'PENDING_VERIFICATION')) AS pending_verification,
        (SELECT COUNT(*) FROM ${DatabaseTables.tasks} t
          WHERE t.center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})
            AND t.status NOT IN ('COMPLETED', 'CLOSED')) AS open_tasks
    ''');
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
      SELECT i.*, ci.rate, ci.is_selected, ci.sort_order
      FROM ${DatabaseTables.centerItems} ci
      JOIN ${DatabaseTables.items} i ON i.id = ci.item_id
      WHERE ci.center_id = ? AND ci.channel = ?
        ${selectedOnly ? 'AND ci.is_selected = 1' : ''}
      ORDER BY ci.sort_order, i.name COLLATE NOCASE
    ''',
      [resolvedCenter, channel],
    );
    return rows.map(ItemModel.fromMap).toList(growable: false);
  }

  Future<void> saveItemConfiguration({
    String? centerId,
    required String channel,
    required List<ItemModel> items,
  }) async {
    final resolvedCenter = centerId ?? await activeCenterId;
    if (resolvedCenter == null) {
      throw StateError('No active center is available.');
    }
    final now = DateTime.now().toUtc().toIso8601String();
    final body = <String, Object?>{
      'center_id': resolvedCenter,
      'channel': channel,
      'items': [
        for (var index = 0; index < items.length; index++)
          {
            'item_id': items[index].id,
            'is_selected': items[index].isSelected == true ? 1 : 0,
            'sort_order': index,
            'rate': items[index].rate,
          },
      ],
    };

    await _database.transaction((txn) async {
      for (var index = 0; index < items.length; index++) {
        final item = items[index];
        await txn.update(
          DatabaseTables.centerItems,
          {
            'is_selected': item.isSelected == true ? 1 : 0,
            'sort_order': index,
            'sync_state': 'pending',
          },
          where: 'center_id = ? AND channel = ? AND item_id = ?',
          whereArgs: [resolvedCenter, channel, item.id],
        );
      }
      await txn.insert(DatabaseTables.outbox, {
        'method': 'PUT',
        'path': '/api/v1/mobile/center-items',
        'body': jsonEncode(body),
        'entity': 'center_items',
        'entity_id': '$resolvedCenter:$channel',
        'kind': 'CONFIGURE',
        'refs': jsonEncode([for (final item in items) item.id]),
        'status': 'pending',
        'attempts': 0,
        'created_at': now,
      });
    });
  }

  Future<List<VehicleModel>> getVehicles({
    String? centerId,
    bool activeOnly = true,
  }) async {
    final resolvedCenter = centerId ?? await activeCenterId;
    if (resolvedCenter == null) return const [];
    final rows = await _database.query(
      DatabaseTables.vehicles,
      where: 'center_id = ?${activeOnly ? ' AND is_active = 1' : ''}',
      whereArgs: [resolvedCenter],
      orderBy: 'plate_number COLLATE NOCASE',
    );
    return rows.map(VehicleModel.fromMap).toList(growable: false);
  }

  Future<List<VehicleTypeModel>> getVehicleTypes() async =>
      (await _database.query(
        DatabaseTables.vehicleTypes,
        orderBy: 'name COLLATE NOCASE',
      )).map(VehicleTypeModel.fromMap).toList(growable: false);

  Future<void> saveVehicle(VehicleModel vehicle) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _database.transaction((txn) async {
      await txn.insert(DatabaseTables.vehicles, {
        ...vehicle.toMap(),
        'sync_state': 'pending',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.insert(DatabaseTables.outbox, {
        'method': 'PUT',
        'path': '/api/v1/mobile/vehicles/${vehicle.id}',
        'body': jsonEncode(vehicle.toMap()),
        'entity': 'vehicles',
        'entity_id': vehicle.id,
        'kind': 'UPSERT',
        'status': 'pending',
        'attempts': 0,
        'created_at': now,
      });
    });
  }

  Future<void> setVehicleActive(VehicleModel vehicle, bool active) =>
      saveVehicle(
        VehicleModel(
          id: vehicle.id,
          centerId: vehicle.centerId,
          plateNumber: vehicle.plateNumber,
          typeId: vehicle.typeId,
          typeName: vehicle.typeName,
          capacityKg: vehicle.capacityKg,
          driverName: vehicle.driverName,
          isActive: active,
          syncState: 'pending',
        ),
      );

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
      await txn.insert(DatabaseTables.ragpickers, {
        ...ragpicker.toMap(),
        'sync_state': 'pending',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.insert(DatabaseTables.outbox, {
        'method': 'PUT',
        'path': '/api/v1/mobile/ragpickers/${ragpicker.id}',
        'body': jsonEncode(ragpicker.toMap()),
        'entity': 'ragpickers',
        'entity_id': ragpicker.id,
        'kind': 'UPSERT',
        'status': 'pending',
        'attempts': 0,
        'created_at': now,
      });
    });
  }

  Future<void> setRagpickerActive(RagpickerModel ragpicker, bool active) =>
      saveRagpicker(
        RagpickerModel(
          id: ragpicker.id,
          centerId: ragpicker.centerId,
          name: ragpicker.name,
          phone: ragpicker.phone,
          idNumber: ragpicker.idNumber,
          photoUrl: ragpicker.photoUrl,
          isActive: active,
          syncState: 'pending',
        ),
      );

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
    bool drafts = false,
    String? channel,
    String search = '',
  }) async {
    final userId = await currentUserId;
    if (userId == null) return const [];
    final conditions = <String>[
      'c.agent_id = ?',
      drafts ? "c.status = 'DRAFT'" : "c.status != 'DRAFT'",
    ];
    final args = <Object?>[userId];
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
          ? "c.status IN ('SUBMITTED', 'PENDING', 'PENDING_VERIFICATION')"
          : "c.status IN ('VERIFIED', 'APPROVED', 'REJECTED')",
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
    final now = DateTime.now().toUtc().toIso8601String();
    final photoIds = <String>[];
    await _database.transaction((txn) async {
      await txn.insert(DatabaseTables.collections, {
        ...collection.toMap(),
        'status': submit ? 'PENDING' : 'DRAFT',
        'sync_state': 'pending',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.delete(
        DatabaseTables.collectionItems,
        where: 'collection_id = ?',
        whereArgs: [collection.id],
      );
      for (final item in items) {
        await txn.insert(DatabaseTables.collectionItems, item.toMap());
        for (var index = 0; index < item.photoUrls.length; index++) {
          final path = item.photoUrls[index];
          final photoId = '${item.id}_photo_$index';
          photoIds.add(photoId);
          await txn.insert(DatabaseTables.photos, {
            'id': photoId,
            'owner_table': DatabaseTables.collectionItems,
            'owner_id': item.id,
            'field': 'photo_urls',
            'purpose': 'collection_item',
            'content_type': 'image/jpeg',
            'local_path': path,
            'status': 'pending',
            'created_at': now,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
      final body = {
        ...collection.toMap(),
        'status': submit ? 'PENDING' : 'DRAFT',
        'items': items.map((item) => item.toMap()).toList(growable: false),
      };
      final seq = await txn.insert(DatabaseTables.outbox, {
        'method': 'PUT',
        'path': '/api/v1/mobile/collections/${collection.id}',
        'body': jsonEncode(body),
        'entity': 'collections',
        'entity_id': collection.id,
        'kind': submit ? 'SUBMIT' : 'DRAFT',
        'refs': jsonEncode(photoIds),
        'status': 'pending',
        'attempts': 0,
        'created_at': now,
      });
      for (final photoId in photoIds) {
        await txn.insert(DatabaseTables.outboxPhotos, {
          'outbox_seq': seq,
          'photo_id': photoId,
        });
      }
    });
  }

  Future<void> discardDraft(String collectionId) =>
      _database.runInTransaction((txn) async {
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
      });

  Future<List<ExpenseModel>> getExpenses({
    bool supervisor = false,
    String? status,
  }) async {
    final userId = await currentUserId;
    if (!supervisor && userId == null) return const [];
    final conditions = <String>[
      supervisor
          ? 'e.center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})'
          : 'e.user_id = ?',
    ];
    final args = <Object?>[if (!supervisor) userId];
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
    final rows = await _database.query(
      DatabaseTables.cashRequests,
      where: supervisor
          ? 'center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})'
          : 'requested_by = ?',
      whereArgs: supervisor ? null : [userId],
      orderBy: 'created_at DESC',
    );
    return rows.map(CashRequestModel.fromMap).toList(growable: false);
  }

  Future<List<CategoryRequestModel>> getCategoryRequests({
    bool supervisor = false,
  }) async {
    final userId = await currentUserId;
    if (!supervisor && userId == null) return const [];
    final rows = await _database.query(
      DatabaseTables.categoryRequests,
      where: supervisor
          ? 'center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})'
          : 'requested_by = ?',
      whereArgs: supervisor ? null : [userId],
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
      conditions.add('(title LIKE ? OR description LIKE ?)');
      final like = '%${search.trim()}%';
      args.addAll([like, like]);
    }
    final rows = await _database.query(
      DatabaseTables.tasks,
      where: conditions.join(' AND '),
      whereArgs: args,
      orderBy:
          "CASE priority WHEN 'HIGH' THEN 0 WHEN 'NORMAL' THEN 1 ELSE 2 END, due_at, created_at DESC",
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
          WHERE center_id = ?), 0) AS balance_now,
        COALESCE(SUM(CASE WHEN kind IN ('CASH_IN', 'CREDIT') THEN amount ELSE 0 END), 0) AS cash_in,
        COALESCE(SUM(CASE WHEN kind IN ('PAID_OUT', 'PAYMENT') THEN amount ELSE 0 END), 0) AS paid_out,
        COALESCE(SUM(CASE WHEN kind IN ('SPENT', 'EXPENSE') THEN amount ELSE 0 END), 0) AS spent
      FROM ${DatabaseTables.walletEntries}
      WHERE center_id = ?
    ''',
      [resolvedCenter, resolvedCenter],
    );
    return WalletSummaryModel.fromMap(rows.single);
  }

  Future<List<WalletEntryModel>> getWalletEntries({String? centerId}) async {
    final resolvedCenter = centerId ?? await activeCenterId;
    if (resolvedCenter == null) return const [];
    final rows = await _database.query(
      DatabaseTables.walletEntries,
      where: 'center_id = ?',
      whereArgs: [resolvedCenter],
      orderBy: 'created_at DESC',
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

  Future<void> markNotificationRead(String id) => _database.update(
    DatabaseTables.notifications,
    {
      'read_at': DateTime.now().toUtc().toIso8601String(),
      'sync_state': 'pending',
    },
    where: 'id = ?',
    whereArgs: [id],
  );

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
    final rows = await _database.rawQuery('''
      SELECT cp.user_id, cp.name, cp.phone, c.name AS center_name,
        COUNT(CASE WHEN date(col.collected_at, 'localtime') = date('now', 'localtime') THEN 1 END) AS collections_today,
        MAX(col.collected_at) AS last_collection_at,
        COUNT(CASE WHEN col.status IN ('SUBMITTED', 'PENDING', 'PENDING_VERIFICATION') THEN 1 END) AS waiting_review
      FROM ${DatabaseTables.centerPeople} cp
      JOIN ${DatabaseTables.centers} c ON c.id = cp.center_id
      LEFT JOIN ${DatabaseTables.collections} col
        ON col.agent_id = cp.user_id AND col.center_id = cp.center_id
      WHERE cp.is_agent = 1
        AND cp.center_id IN (SELECT center_id FROM ${DatabaseTables.myCenters})
      GROUP BY cp.user_id, cp.center_id
      ORDER BY cp.name COLLATE NOCASE
    ''');
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
          WHERE status IN ('local', 'queued', 'uploading')) AS waiting_photo_count
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
}
