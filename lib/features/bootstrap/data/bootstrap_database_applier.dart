import 'dart:convert';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/features/bootstrap/model/bootstrap_response.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_log.dart';
import 'package:eerl_app/features/dashboard/model/bottom_nav_item_model.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class BootstrapDatabaseApplier {
  BootstrapDatabaseApplier({AppDatabase? database})
    : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  static const _referenceWithoutSyncState = <String>{
    DatabaseTables.centers,
    DatabaseTables.items,
    DatabaseTables.centerChannels,
    DatabaseTables.expenseCategories,
    DatabaseTables.centerPeople,
    DatabaseTables.destinations,
    DatabaseTables.transferVehicles,
  };

  static const _referenceWithSyncState = <String>{
    DatabaseTables.centerItems,
    DatabaseTables.vehicles,
    DatabaseTables.mrfPeople,
    DatabaseTables.ragpickers,
  };

  static const _recordWithSyncState = <String>{
    DatabaseTables.collections,
    DatabaseTables.expenses,
    DatabaseTables.cashRequests,
    DatabaseTables.categoryRequests,
    DatabaseTables.transfers,
    DatabaseTables.tasks,
    DatabaseTables.requests,
    DatabaseTables.walletEntries,
    DatabaseTables.notifications,
  };

  static const _recordWithoutSyncState = <String, String>{
    DatabaseTables.dayCloses: 'id',
    DatabaseTables.centerBalances: 'center_id',
    DatabaseTables.stock: 'id',
  };

  /// Only these API table names are handled by this applier. Keeping this
  /// allow-list also makes the post-commit count query safe for table names.
  static const _bootstrapTableNames = <String>{
    ..._referenceWithoutSyncState,
    ..._referenceWithSyncState,
    ..._recordWithSyncState,
    DatabaseTables.dayCloses,
    DatabaseTables.centerBalances,
    DatabaseTables.stock,
    DatabaseTables.collectionItems,
    DatabaseTables.transferItems,
  };

  static const _recordColumns = <String, Set<String>>{
    DatabaseTables.collections: {
      'id',
      'center_id',
      'agent_id',
      'agent_name',
      'channel',
      'status',
      'slip_number',
      'collected_at',
      'vehicle_id',
      'mrf_person_id',
      'ragpicker_id',
      'given_by_name',
      'handed_over_by',
      'paid_by',
      'takes_payment',
      'total_amount',
      'handover_photo_urls',
      'rejection_reason',
      'rejection_remarks',
      'verified_by_name',
      'verified_at',
      'updated_at',
      'sync_state',
    },
    DatabaseTables.expenses: {
      'id',
      'center_id',
      'user_id',
      'user_name',
      'category_id',
      'amount',
      'note',
      'status',
      'number',
      'receipt_photo_urls',
      'decided_by_name',
      'decision_reason',
      'decision_remarks',
      'created_at',
      'updated_at',
      'sync_state',
    },
    DatabaseTables.cashRequests: {
      'id',
      'number',
      'center_id',
      'requested_by',
      'requested_by_name',
      'amount',
      'reason',
      'status',
      'decided_by_name',
      'decision_note',
      'decision_remarks',
      'created_at',
      'updated_at',
      'sync_state',
    },
    DatabaseTables.categoryRequests: {
      'id',
      'number',
      'center_id',
      'requested_by',
      'requested_by_name',
      'name',
      'reason',
      'status',
      'decided_by_name',
      'decided_at',
      'decision_reason',
      'created_at',
      'sync_state',
    },
    DatabaseTables.transfers: {
      'id',
      'center_id',
      'type',
      'status',
      'number',
      'destination_id',
      'destination_name',
      'truck_expected_at',
      'transfer_vehicle_id',
      'planned_vehicle_number',
      'planned_vehicle_ownership',
      'transporter_name',
      'transfer_fee',
      'fixed_qty',
      'estimated_expense',
      'note',
      'dispatch_note',
      'vehicle_plate',
      'driver_name',
      'dispatched_weight',
      'bale_count',
      'vehicle_photo_urls',
      'weighbridge_photo_urls',
      'vehicle_differs',
      'requested_by',
      'requested_by_name',
      'requested_at',
      'decided_by_name',
      'approved_at',
      'rejection_reason',
      'rejection_remarks',
      'handed_over_at',
      'updated_at',
      'sync_state',
    },
    DatabaseTables.tasks: {
      'id',
      'number',
      'center_id',
      'assigned_to',
      'assigned_to_name',
      'assigned_by',
      'assigned_by_name',
      'title',
      'note',
      'description',
      'priority',
      'status',
      'due_at',
      'completed_at',
      'photo_urls',
      'created_at',
      'sync_state',
    },
    DatabaseTables.requests: {
      'id',
      'number',
      'center_id',
      'created_by',
      'created_by_name',
      'body',
      'priority',
      'status',
      'follow_up_at',
      'answer',
      'answered_at',
      'photo_urls',
      'answer_photo_urls',
      'created_at',
      'sync_state',
    },
    DatabaseTables.walletEntries: {
      'id',
      'center_id',
      'kind',
      'amount',
      'note',
      'collection_id',
      'expense_id',
      'confirmed_at',
      'created_at',
      'sync_state',
    },
    DatabaseTables.notifications: {
      'id',
      'type',
      'title',
      'body',
      'deep_link',
      'role',
      'center_id',
      'created_at',
      'read_at',
      'sync_state',
    },
  };

  Future<void> apply(BootstrapData data) async {
    _log('BEGIN page transaction for cursor=${data.cursor}');
    try {
      await _database.runInTransaction((txn) async {
        // Bootstrap can replace reference parents before recreating them in
        // the same page. Defer validation until commit, when the complete
        // parent/child graph has been applied.
        await txn.execute('PRAGMA defer_foreign_keys = ON');
        await _applyMe(txn, data.me);
        await _applyReferenceTables(txn, data.tables);
        await _applyRecordUpserts(txn, data.tables);
        await _applyChildSets(txn, data.tables);
        await _applyNormalDeletes(txn, data.tables);
        await _applyParentDeletes(txn, data.tables);
        await _savePageMeta(txn, data);
      });
    } catch (error) {
      _log('Page transaction rolled back: $error');
      rethrow;
    }

    _log('Page transaction committed; cursor=${data.cursor}');
    if (kDebugMode) {
      await _logCommittedPage(data);
    }
  }

  /// Re-reads committed data from SQLite so this log confirms persisted data,
  /// rather than only reporting how many rows arrived in the API response.
  Future<void> _logCommittedPage(BootstrapData data) async {
    try {
      if (data.me != null) {
        final storedRoles = await _rowCount(DatabaseTables.myRoles);
        final storedCenters = await _rowCount(DatabaseTables.myCenters);
        BootstrapLog.databaseCommit(
          'STORED section=me '
          'api_roles=${data.me!.roles.length} sqlite_roles=$storedRoles '
          'api_centers=${data.me!.centers.length} '
          'sqlite_centers=$storedCenters',
        );
      }

      var verifiedTableCount = 0;
      for (final entry in data.tables.entries) {
        final table = entry.key;
        if (!_bootstrapTableNames.contains(table)) {
          BootstrapLog.warning(
            'SQLite commit verification skipped for unsupported API '
            'table=$table',
          );
          continue;
        }

        final change = entry.value;
        final storedRows = await _rowCount(table);
        BootstrapLog.databaseCommit(
          'STORED table=$table '
          'replace_received=${change.replace.length} '
          'upserts_received=${change.upserts.length} '
          'deletes_received=${change.deletes.length} '
          'sqlite_total=$storedRows',
        );
        verifiedTableCount++;
      }

      final storedCursor = await _database.getSyncMeta('cursor');
      if (storedCursor == data.cursor) {
        BootstrapLog.databaseCommit(
          'PAGE_STORED cursor=${data.cursor} cursor_verified=true '
          'tables_verified=$verifiedTableCount',
        );
      } else {
        BootstrapLog.error(
          'SQLITE COMMIT VERIFY_FAILED expected_cursor=${data.cursor} '
          'stored_cursor=${storedCursor ?? 'null'}',
        );
      }
    } catch (error) {
      // The page is already committed. A diagnostic query failure must not
      // make the successful sync retry or claim the transaction rolled back.
      BootstrapLog.error('SQLITE COMMIT LOG_FAILED error=$error');
    }
  }

  Future<int> _rowCount(String table) async {
    final rows = await _database.rawQuery('SELECT COUNT(*) FROM "$table"');
    return Sqflite.firstIntValue(rows) ?? 0;
  }

  Future<void> _applyMe(Transaction txn, BootstrapMe? me) async {
    if (me == null) {
      _log('ME skipped: section not present');
      return;
    }

    _log('ME apply: roles=${me.roles.length}, centers=${me.centers.length}');

    await txn.delete(DatabaseTables.myRoles);
    final roleKeys = <String>[];
    for (final role in me.roles) {
      final key = role.key;
      final name = role.name;
      if (key == null || key.isEmpty || name == null || name.isEmpty) continue;
      roleKeys.add(key);
      await txn.insert(DatabaseTables.myRoles, <String, Object?>{
        'role_key': key,
        'role_name': name,
        'modules': jsonEncode(role.modules ?? const <Object?>[]),
      });
    }

    final existingActiveRole = await _getMeta(txn, 'active_role');
    final availableRoles = roleKeys.map(DashboardUserRoleX.fromKey).toSet();
    if (roleKeys.length == 1) {
      await _setMeta(txn, 'active_role', roleKeys.single);
    } else if (existingActiveRole != null) {
      final existingRole = DashboardUserRoleX.fromKey(existingActiveRole);
      if (!availableRoles.contains(existingRole)) {
        await _setMeta(txn, 'active_role', null);
      }
    }

    final incomingCenterIds = <String>[];
    String? primaryCenterId;
    for (final center in me.centers) {
      final centerId = center.id;
      if (centerId == null || centerId.isEmpty) continue;
      incomingCenterIds.add(centerId);
      if (center.isPrimary) primaryCenterId = centerId;
      await txn.rawInsert(
        '''
        INSERT INTO ${DatabaseTables.myCenters} (
          center_id, is_primary, agent_number, slip_date, slip_last_count
        ) VALUES (?, ?, ?, ?, ?)
        ON CONFLICT (center_id) DO UPDATE SET
          is_primary = excluded.is_primary,
          agent_number = excluded.agent_number,
          slip_last_count = CASE
            WHEN excluded.slip_date IS NULL
              THEN ${DatabaseTables.myCenters}.slip_last_count
            WHEN ${DatabaseTables.myCenters}.slip_date IS NULL
              THEN excluded.slip_last_count
            WHEN ${DatabaseTables.myCenters}.slip_date = excluded.slip_date
              THEN MAX(
                ${DatabaseTables.myCenters}.slip_last_count,
                excluded.slip_last_count
              )
            WHEN ${DatabaseTables.myCenters}.slip_date > excluded.slip_date
              THEN ${DatabaseTables.myCenters}.slip_last_count
            ELSE excluded.slip_last_count
          END,
          slip_date = CASE
            WHEN excluded.slip_date IS NULL
              THEN ${DatabaseTables.myCenters}.slip_date
            WHEN ${DatabaseTables.myCenters}.slip_date IS NULL
              THEN excluded.slip_date
            ELSE MAX(
              ${DatabaseTables.myCenters}.slip_date,
              excluded.slip_date
            )
          END
        ''',
        <Object?>[
          centerId,
          center.isPrimary ? 1 : 0,
          center.agentNumber,
          center.slipCounter?.date,
          center.slipCounter?.lastCount ?? 0,
        ],
      );
    }
    await _deleteMissingCenters(txn, incomingCenterIds);

    final activeCenterId = await _getMeta(txn, 'active_center_id');
    if (activeCenterId == null || !incomingCenterIds.contains(activeCenterId)) {
      await _setMeta(
        txn,
        'active_center_id',
        primaryCenterId ??
            (incomingCenterIds.isEmpty ? null : incomingCenterIds.first),
      );
    }

    await _setMeta(txn, 'user_id', me.user?.id);
    await _setMeta(txn, 'user_name', me.user?.name);
    await _setMeta(txn, 'user_phone', me.user?.phone);
    await _setMeta(txn, 'user_photo_url', me.user?.photoUrl);
    await _setMeta(txn, 'supervisor_name', me.supervisor?.name);
    await _setMeta(txn, 'supervisor_phone', me.supervisor?.phone);
    await _setMeta(txn, 'session_expires_at', me.session?.expiresAt);
  }

  Future<void> _deleteMissingCenters(
    Transaction txn,
    List<String> incomingIds,
  ) async {
    if (incomingIds.isEmpty) {
      await txn.delete(DatabaseTables.myCenters);
      return;
    }
    final placeholders = List.filled(incomingIds.length, '?').join(', ');
    await txn.delete(
      DatabaseTables.myCenters,
      where: 'center_id NOT IN ($placeholders)',
      whereArgs: incomingIds,
    );
  }

  Future<void> _applyReferenceTables(
    Transaction txn,
    Map<String, BootstrapTableChange> tables,
  ) async {
    for (final table in _referenceWithoutSyncState) {
      final change = tables[table];
      if (change == null || !change.hasReplace) continue;
      if (table == DatabaseTables.transferVehicles) {
        await _detachRetiredTransferVehicles(txn, change.replace);
      }
      await txn.delete(table);
      final batch = txn.batch();
      for (final row in change.replace) {
        batch.insert(table, row);
      }
      await batch.commit(noResult: true);
      _log('$table reference replace committed: ${change.replace.length} rows');
    }

    for (final table in _referenceWithSyncState) {
      final change = tables[table];
      if (change == null || !change.hasReplace) continue;
      await txn.delete(
        table,
        where: 'sync_state = ?',
        whereArgs: const ['synced'],
      );
      final batch = txn.batch();
      for (final row in change.replace) {
        final values = <String, Object?>{...row, 'sync_state': 'synced'};
        if (table == DatabaseTables.vehicles) {
          values.remove('capacity_kg');
          values.remove('type_id');
          values.remove('type_name');
        }
        batch.insert(
          table,
          values,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      await batch.commit(noResult: true);
      _log(
        '$table protected reference replace: ${change.replace.length} '
        'server rows; pending/failed rows preserved',
      );
    }
  }

  /// A transfer keeps the selected vehicle's number, ownership and
  /// transporter as snapshot columns. The bootstrap vehicle list, however,
  /// only contains vehicles that are currently selectable. Clear the optional
  /// relation before replacing that list so a historical or locally failed
  /// transfer cannot make the page fail its deferred foreign-key check.
  Future<void> _detachRetiredTransferVehicles(
    Transaction txn,
    List<Map<String, Object?>> incomingVehicles,
  ) async {
    final incomingIds = incomingVehicles
        .map((row) => row['id'])
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toList(growable: false);
    final where = incomingIds.isEmpty
        ? 'transfer_vehicle_id IS NOT NULL'
        : 'transfer_vehicle_id IS NOT NULL AND transfer_vehicle_id NOT IN '
              '(${List.filled(incomingIds.length, '?').join(', ')})';
    final changed = await txn.update(
      DatabaseTables.transfers,
      const <String, Object?>{'transfer_vehicle_id': null},
      where: where,
      whereArgs: incomingIds,
    );
    if (changed > 0) {
      _log(
        'Detached $changed transfer(s) from retired transfer vehicles; '
        'planned vehicle snapshot preserved',
      );
    }
  }

  Future<void> _applyRecordUpserts(
    Transaction txn,
    Map<String, BootstrapTableChange> tables,
  ) async {
    const orderedSyncTables = <String>[
      DatabaseTables.collections,
      DatabaseTables.transfers,
      DatabaseTables.expenses,
      DatabaseTables.cashRequests,
      DatabaseTables.categoryRequests,
      DatabaseTables.tasks,
      DatabaseTables.requests,
      DatabaseTables.walletEntries,
      DatabaseTables.notifications,
    ];
    for (final table in orderedSyncTables) {
      final change = tables[table];
      if (change == null || !change.hasUpserts) continue;
      for (final row in change.upserts) {
        await _upsertSyncedRecord(txn, table, row);
      }
      _log('$table protected upserts applied: ${change.upserts.length} rows');
    }

    for (final entry in _recordWithoutSyncState.entries) {
      final change = tables[entry.key];
      if (change == null || !change.hasUpserts) continue;
      for (final row in change.upserts) {
        await txn.insert(
          entry.key,
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      _log(
        '${entry.key} server upserts applied: ${change.upserts.length} rows',
      );
    }
  }

  Future<void> _upsertSyncedRecord(
    Transaction txn,
    String table,
    Map<String, Object?> serverRow,
  ) async {
    final values = <String, Object?>{...serverRow, 'sync_state': 'synced'};
    // Old Bootstrap pages can still contain this legacy transfer field. It is
    // deliberately ignored: dispatch now has two field-specific photo lists.
    if (table == DatabaseTables.transfers) values.remove('photo_urls');
    if (table == DatabaseTables.transfers) {
      final transferVehicleId = values['transfer_vehicle_id'];
      if (transferVehicleId is String && transferVehicleId.isNotEmpty) {
        final vehicle = await txn.query(
          DatabaseTables.transferVehicles,
          columns: const ['id'],
          where: 'id = ?',
          whereArgs: [transferVehicleId],
          limit: 1,
        );
        if (vehicle.isEmpty) {
          values['transfer_vehicle_id'] = null;
          BootstrapLog.warning(
            'Transfer ${values['id']} references unavailable transfer vehicle '
            '$transferVehicleId; snapshot fields were kept',
          );
        }
      }
    }
    final allowedColumns = _recordColumns[table]!;
    final unknownColumns = values.keys
        .where((column) => !allowedColumns.contains(column))
        .toList(growable: false);
    if (unknownColumns.isNotEmpty) {
      throw FormatException(
        'Unsupported $table columns: ${unknownColumns.join(', ')}',
      );
    }
    if (!values.containsKey('id')) {
      throw FormatException('$table upsert is missing id');
    }

    final columns = values.keys.toList(growable: false);
    final quotedColumns = columns.map((column) => '"$column"').join(', ');
    final placeholders = List.filled(columns.length, '?').join(', ');
    final updates = columns
        .where((column) => column != 'id')
        .map((column) => '"$column" = excluded."$column"')
        .join(', ');
    await txn.rawInsert('''
      INSERT INTO "$table" ($quotedColumns)
      VALUES ($placeholders)
      ON CONFLICT (id) DO UPDATE SET $updates
      WHERE "$table".sync_state = 'synced'
      ''', columns.map((column) => values[column]).toList(growable: false));
  }

  Future<void> _applyChildSets(
    Transaction txn,
    Map<String, BootstrapTableChange> tables,
  ) async {
    await _replaceChildGroups(
      txn,
      change: tables[DatabaseTables.collectionItems],
      childTable: DatabaseTables.collectionItems,
      childParentColumn: 'collection_id',
      parentTable: DatabaseTables.collections,
    );
    await _replaceChildGroups(
      txn,
      change: tables[DatabaseTables.transferItems],
      childTable: DatabaseTables.transferItems,
      childParentColumn: 'transfer_id',
      parentTable: DatabaseTables.transfers,
    );
  }

  Future<void> _replaceChildGroups(
    Transaction txn, {
    required BootstrapTableChange? change,
    required String childTable,
    required String childParentColumn,
    required String parentTable,
  }) async {
    if (change == null || !change.hasUpserts) return;
    final groups = <String, List<Map<String, Object?>>>{};
    for (final row in change.upserts) {
      final parentId = row[childParentColumn];
      if (parentId is! String || parentId.isEmpty) continue;
      groups.putIfAbsent(parentId, () => []).add(row);
    }

    for (final entry in groups.entries) {
      if (!await _isSyncedParent(txn, parentTable, entry.key)) continue;
      await txn.delete(
        childTable,
        where: '$childParentColumn = ?',
        whereArgs: [entry.key],
      );
      final batch = txn.batch();
      for (final row in entry.value) {
        batch.insert(childTable, row);
      }
      await batch.commit(noResult: true);
      _log(
        '$childTable child set replaced for ${entry.key}: '
        '${entry.value.length} rows',
      );
    }
  }

  Future<void> _applyNormalDeletes(
    Transaction txn,
    Map<String, BootstrapTableChange> tables,
  ) async {
    for (final table in _recordWithSyncState) {
      if (table == DatabaseTables.collections ||
          table == DatabaseTables.transfers) {
        continue;
      }
      final deletes = tables[table]?.deletes ?? const <String>[];
      await _deleteSyncedIds(txn, table, 'id', deletes);
      if (deletes.isNotEmpty) {
        _log('$table protected deletes requested: ${deletes.length} ids');
      }
    }

    for (final entry in _recordWithoutSyncState.entries) {
      final deletes = tables[entry.key]?.deletes ?? const <String>[];
      await _deleteIds(txn, entry.key, entry.value, deletes);
      if (deletes.isNotEmpty) {
        _log('${entry.key} deletes applied: ${deletes.length} ids');
      }
    }

    await _deleteEligibleChildren(
      txn,
      change: tables[DatabaseTables.collectionItems],
      childTable: DatabaseTables.collectionItems,
      childParentColumn: 'collection_id',
      parentTable: DatabaseTables.collections,
    );
    await _deleteEligibleChildren(
      txn,
      change: tables[DatabaseTables.transferItems],
      childTable: DatabaseTables.transferItems,
      childParentColumn: 'transfer_id',
      parentTable: DatabaseTables.transfers,
    );
  }

  Future<void> _deleteEligibleChildren(
    Transaction txn, {
    required BootstrapTableChange? change,
    required String childTable,
    required String childParentColumn,
    required String parentTable,
  }) async {
    if (change == null || !change.hasDeletes) return;
    for (final id in change.deletes) {
      final rows = await txn.query(
        childTable,
        columns: ['id', childParentColumn],
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) continue;
      final parentId = rows.single[childParentColumn];
      if (parentId is String &&
          await _isSyncedParent(txn, parentTable, parentId)) {
        await txn.delete(childTable, where: 'id = ?', whereArgs: [id]);
      }
    }
  }

  Future<void> _applyParentDeletes(
    Transaction txn,
    Map<String, BootstrapTableChange> tables,
  ) async {
    for (final id
        in tables[DatabaseTables.collections]?.deletes ?? const <String>[]) {
      await _deleteParentGraph(
        txn,
        parentTable: DatabaseTables.collections,
        parentId: id,
        childTable: DatabaseTables.collectionItems,
        childParentColumn: 'collection_id',
      );
    }
    for (final id
        in tables[DatabaseTables.transfers]?.deletes ?? const <String>[]) {
      await _deleteParentGraph(
        txn,
        parentTable: DatabaseTables.transfers,
        parentId: id,
        childTable: DatabaseTables.transferItems,
        childParentColumn: 'transfer_id',
      );
    }
  }

  Future<void> _deleteParentGraph(
    Transaction txn, {
    required String parentTable,
    required String parentId,
    required String childTable,
    required String childParentColumn,
  }) async {
    if (!await _isSyncedParent(txn, parentTable, parentId)) return;
    final childRows = await txn.query(
      childTable,
      columns: const ['id'],
      where: '$childParentColumn = ?',
      whereArgs: [parentId],
    );
    for (final row in childRows) {
      await txn.delete(
        DatabaseTables.photos,
        where: 'owner_table = ? AND owner_id = ? AND status = ?',
        whereArgs: [childTable, row['id'], 'uploaded'],
      );
    }
    await txn.delete(
      childTable,
      where: '$childParentColumn = ?',
      whereArgs: [parentId],
    );
    await txn.delete(
      DatabaseTables.photos,
      where: 'owner_table = ? AND owner_id = ? AND status = ?',
      whereArgs: [parentTable, parentId, 'uploaded'],
    );
    await txn.delete(parentTable, where: 'id = ?', whereArgs: [parentId]);
    _log('$parentTable synced parent graph deleted: $parentId');
  }

  Future<bool> _isSyncedParent(Transaction txn, String table, String id) async {
    final rows = await txn.query(
      table,
      columns: const ['sync_state'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty && rows.single['sync_state'] == 'synced';
  }

  Future<void> _deleteSyncedIds(
    Transaction txn,
    String table,
    String primaryKey,
    List<String> ids,
  ) async {
    for (final chunk in _chunks(ids)) {
      final placeholders = List.filled(chunk.length, '?').join(', ');
      await txn.delete(
        table,
        where: '$primaryKey IN ($placeholders) AND sync_state = ?',
        whereArgs: <Object?>[...chunk, 'synced'],
      );
    }
  }

  Future<void> _deleteIds(
    Transaction txn,
    String table,
    String primaryKey,
    List<String> ids,
  ) async {
    for (final chunk in _chunks(ids)) {
      final placeholders = List.filled(chunk.length, '?').join(', ');
      await txn.delete(
        table,
        where: '$primaryKey IN ($placeholders)',
        whereArgs: chunk,
      );
    }
  }

  Iterable<List<String>> _chunks(List<String> values) sync* {
    const size = 400;
    for (var index = 0; index < values.length; index += size) {
      final end = (index + size).clamp(0, values.length);
      yield values.sublist(index, end);
    }
  }

  Future<void> _savePageMeta(Transaction txn, BootstrapData data) async {
    await _setMeta(txn, 'cursor', data.cursor);
    if (data.me != null) {
      await _setMeta(txn, 'scope_key', data.me!.scopeKey);
    }
    await _setMeta(txn, 'last_bootstrap_at', data.serverTime);
    _log('META saved: cursor, scope_key, last_bootstrap_at');
  }

  Future<String?> _getMeta(Transaction txn, String key) async {
    final rows = await txn.query(
      DatabaseTables.syncMeta,
      columns: const ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.single['value'] as String?;
  }

  Future<void> _setMeta(Transaction txn, String key, String? value) async {
    await txn.rawInsert(
      'INSERT OR REPLACE INTO ${DatabaseTables.syncMeta} (key, value) '
      'VALUES (?, ?)',
      [key, value],
    );
  }

  static void _log(String message) {
    BootstrapLog.database(message);
  }
}
