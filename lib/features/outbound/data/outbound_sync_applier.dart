import 'dart:convert';

import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/core/local_database/outbound/outbound_tables.dart';
import 'package:eerl_app/features/bootstrap/model/bootstrap_response.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_log.dart';
import 'package:sqflite/sqflite.dart';

/// Applies the outbound part of `/bootstrap` and of outbox answers.
///
/// Source: `docs/project-context/outbound-schema-and-queries.md`,
/// "Sync: applying /bootstrap" and "Outbox and uploads · Handle the answer".
///
/// Everything runs inside the caller's transaction: the fixed-point page
/// transaction for `/bootstrap`, or the outbox completion transaction.
///
/// Rules kept from the doc:
/// * Reference tables are emptied and refilled (`replace`).
/// * Records are upserted by primary key but never over a row that is
///   `pending` or `failed` here.
/// * A parent brings all its children: they are replaced, unless the parent
///   is not `synced` on this phone.
/// * Deletes never touch a row that is not `synced`.
abstract final class OutboundSyncApplier {
  // ------------------------------------------------------------------ me

  /// Step `me` (outbound lines). Runs in the same transaction as the
  /// fixed-point `my_roles` / `my_centers` step.
  static Future<void> applyMe(Transaction txn, BootstrapMe me) async {
    // my_warehouses: upsert every listed warehouse, then drop the rest.
    final listedIds = <String>[];
    for (final entry in me.warehouses) {
      final id = _string(entry['id'] ?? entry['warehouseId']);
      if (id == null) continue;
      listedIds.add(id);
      final isPrimary = _bool(entry['isPrimary'] ?? entry['is_primary']);
      await txn.rawInsert(
        'INSERT INTO my_warehouses (warehouse_id, is_primary) VALUES (?, ?) '
        'ON CONFLICT (warehouse_id) DO UPDATE SET '
        'is_primary = excluded.is_primary',
        [id, isPrimary ? 1 : 0],
      );
    }
    if (listedIds.isEmpty) {
      await txn.delete(OutboundTables.myWarehouses);
    } else {
      await txn.delete(
        OutboundTables.myWarehouses,
        where:
            'warehouse_id NOT IN (${List.filled(listedIds.length, '?').join(', ')})',
        whereArgs: listedIds,
      );
    }

    final outbound = me.outbound;
    if (outbound == null) {
      // No outbound role: remove every outbound setting, the cash and dues.
      await txn.delete(
        DatabaseTables.syncMeta,
        where:
            'key IN (${List.filled(OutboundTables.outboundMetaKeys.length, '?').join(', ')})',
        whereArgs: OutboundTables.outboundMetaKeys,
      );
      await txn.delete(
        DatabaseTables.syncMeta,
        where: 'key = ?',
        whereArgs: const [OutboundTables.cashBalanceMetaKey],
      );
      await txn.delete(OutboundTables.sourceDues);
      _log('ME outbound: null; outbound settings, cash and dues removed');
      return;
    }

    final head = outbound['collectionHead'] is Map
        ? Map<String, Object?>.from(outbound['collectionHead'] as Map)
        : const <String, Object?>{};
    final settings = <String, Object?>{
      'outbound_gps_radius_m': outbound['gpsRadiusM'],
      'outbound_tolerance_pct': outbound['tolerancePct'],
      'outbound_speed_kmh': outbound['speedKmh'],
      'outbound_minutes_per_stop': outbound['minutesPerStop'],
      'outbound_off_route_km': outbound['offRouteKm'],
      'outbound_support_phone': outbound['supportPhone'],
      'outbound_support_whatsapp': outbound['supportWhatsapp'],
      'outbound_driver_code': outbound['driverCode'],
      'outbound_mixed_item_id': outbound['mixedItemId'],
      'outbound_collection_head_id': head['userId'],
      'outbound_collection_head_name': head['name'],
      'outbound_collection_head_phone': head['phone'],
    };
    for (final entry in settings.entries) {
      await _setMeta(txn, entry.key, entry.value?.toString());
    }

    // The Pickup Supervisor's cash in hand and what each pickup point is owed.
    await txn.delete(OutboundTables.sourceDues);
    final cash = outbound['cash'];
    if (cash is Map) {
      await _setMeta(
        txn,
        OutboundTables.cashBalanceMetaKey,
        cash['balance']?.toString(),
      );
      final dues = cash['dues'];
      if (dues is List) {
        for (final due in dues.whereType<Map>()) {
          final sourceId = _string(due['sourceId'] ?? due['source_id']);
          if (sourceId == null) continue;
          await txn.insert(
            OutboundTables.sourceDues,
            {
              'source_id': sourceId,
              'earned': _num(due['earned']) ?? 0,
              'paid': _num(due['paid']) ?? 0,
              'balance': _num(due['balance']) ?? 0,
              'next_due_on': due['nextDueOn'] ?? due['next_due_on'],
              'last_paid_on': due['lastPaidOn'] ?? due['last_paid_on'],
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    } else {
      await txn.delete(
        DatabaseTables.syncMeta,
        where: 'key = ?',
        whereArgs: const [OutboundTables.cashBalanceMetaKey],
      );
    }
    _log(
      'ME outbound applied: warehouses=${listedIds.length}, '
      'cash=${cash is Map ? 'yes' : 'no'}',
    );
  }

  // -------------------------------------------------------------- tables

  /// Step reference tables (`replace`) and Step records (`upserts`, then
  /// `deletes`) for every outbound key present in `tables`.
  static Future<void> applyTables(
    Transaction txn,
    Map<String, BootstrapTableChange> tables,
  ) async {
    await _applyReferenceTables(txn, tables);
    await _applyRecordUpserts(txn, tables);
    await _applyRecordDeletes(txn, tables);
  }

  static Future<void> _applyReferenceTables(
    Transaction txn,
    Map<String, BootstrapTableChange> tables,
  ) async {
    for (final table in OutboundTables.referenceTables) {
      final change = tables[table];
      if (change == null || !change.hasReplace) continue;
      final columns = await _columns(txn, table);
      await txn.delete(table);
      for (final row in change.replace) {
        await txn.insert(
          table,
          _rowValues(row, columns),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      _log('$table reference replace: ${change.replace.length} rows');
    }
  }

  /// Parents in the order the doc applies them; children ride on them.
  static const _parents = <_ParentSpec>[
    _ParentSpec(OutboundTables.outboundSources, [
      _ChildSpec(OutboundTables.outboundSourceItems, 'source_id', [
        'outbound_source_items',
        'source_items',
        'sourceItems',
        'items',
      ]),
      _ChildSpec(OutboundTables.pickupSchedules, 'source_id', [
        'pickup_schedules',
        'schedules',
      ]),
      _ChildSpec(
        OutboundTables.sourcePaymentTerms,
        'source_id',
        ['source_payment_terms', 'payment_terms', 'paymentTerms'],
        grandchild: _ChildSpec(OutboundTables.sourceItemRates, 'terms_id', [
          'source_item_rates',
          'item_rates',
          'itemRates',
        ]),
      ),
      _ChildSpec(OutboundTables.sourcePauses, 'source_id', [
        'source_pauses',
        'pauses',
      ]),
    ]),
    _ParentSpec(OutboundTables.sourceLeads, [
      _ChildSpec(OutboundTables.leadVisits, 'lead_id', [
        'lead_visits',
        'visits',
      ]),
    ]),
    _ParentSpec(OutboundTables.pickupRoutes, [
      _ChildSpec(OutboundTables.pickupRouteStops, 'route_id', [
        'pickup_route_stops',
        'route_stops',
        'stops',
      ]),
    ]),
    _ParentSpec(OutboundTables.pickupTrips, [
      _ChildSpec(OutboundTables.tripStops, 'trip_id', ['trip_stops', 'stops']),
    ]),
    _ParentSpec(OutboundTables.duePickups, []),
    _ParentSpec(OutboundTables.supervisorFlags, []),
    _ParentSpec(OutboundTables.tripIssues, []),
    _ParentSpec(OutboundTables.outboundRequests, []),
    _ParentSpec(OutboundTables.supervisorCashRequests, []),
    _ParentSpec(OutboundTables.sourcePayments, []),
    // Lines never change: INSERT OR REPLACE, no sync_state.
    _ParentSpec(OutboundTables.supervisorCashBook, []),
  ];

  static Future<void> _applyRecordUpserts(
    Transaction txn,
    Map<String, BootstrapTableChange> tables,
  ) async {
    for (final parent in _parents) {
      final change = tables[parent.table];
      final rows = change?.hasUpserts == true
          ? change!.upserts
          : const <Map<String, Object?>>[];
      for (final row in rows) {
        await upsertRecord(txn, parent.table, row);
      }
      if (parent.children.isNotEmpty) {
        await _replaceChildren(txn, parent, rows, tables);
      }
      if (rows.isNotEmpty) {
        _log('${parent.table} protected upserts: ${rows.length} rows');
      }
    }
  }

  /// Upserts one record as the doc's Step records statement does: insert,
  /// or update every column sent, but only over a `synced` row unless
  /// [force] (an outbox answer for a record with nothing left to send).
  /// A partial row (an answer such as `{id, status, startedAt}`) only
  /// updates the columns it carries.
  static Future<void> upsertRecord(
    Transaction txn,
    String table,
    Map<String, Object?> serverRow, {
    bool force = false,
  }) async {
    final columns = await _columns(txn, table);
    final values = _rowValues(serverRow, columns);
    final id = values['id'];
    if (id is! String || id.isEmpty) {
      BootstrapLog.warning('$table row without id skipped');
      return;
    }
    final hasSyncState = columns.contains('sync_state');
    if (!hasSyncState) {
      await txn.insert(
        table,
        values,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return;
    }
    values['sync_state'] = 'synced';
    final existing = await txn.query(
      table,
      columns: const ['sync_state'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (existing.isEmpty) {
      await txn.insert(table, values);
      return;
    }
    if (!force && existing.single['sync_state'] != 'synced') return;
    final updates = Map<String, Object?>.from(values)..remove('id');
    await txn.update(table, updates, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> _replaceChildren(
    Transaction txn,
    _ParentSpec parent,
    List<Map<String, Object?>> parentRows,
    Map<String, BootstrapTableChange> tables,
  ) async {
    for (final child in parent.children) {
      final separate = tables[child.table];
      final groups = <String, List<Map<String, Object?>>>{};
      if (separate != null && separate.hasUpserts) {
        for (final row in separate.upserts) {
          final parentId = _string(row[child.parentColumn]);
          if (parentId == null) continue;
          groups.putIfAbsent(parentId, () => []).add(row);
        }
      }
      final handled = <String>{};
      for (final row in parentRows) {
        final parentId = _string(row['id']);
        if (parentId == null) continue;
        handled.add(parentId);
        var childRows = _nested(row, child);
        if (childRows == null && separate != null) {
          childRows = groups[parentId] ?? const [];
        }
        // "A cancelled trip comes with no stops."
        if (childRows == null &&
            parent.table == OutboundTables.pickupTrips &&
            row['status'] == 'CANCELLED') {
          childRows = const [];
        }
        if (childRows == null) continue;
        await _replaceChildSet(
          txn,
          parent.table,
          parentId,
          child,
          childRows,
          tables,
        );
      }
      // Children sent for a parent that did not ride in this page.
      for (final entry in groups.entries) {
        if (handled.contains(entry.key)) continue;
        await _replaceChildSet(
          txn,
          parent.table,
          entry.key,
          child,
          entry.value,
          tables,
        );
      }
    }
  }

  static Future<void> _replaceChildSet(
    Transaction txn,
    String parentTable,
    String parentId,
    _ChildSpec child,
    List<Map<String, Object?>> rows,
    Map<String, BootstrapTableChange> tables,
  ) async {
    if (!await _isSynced(txn, parentTable, parentId)) return;
    final grandchild = child.grandchild;
    if (grandchild != null) {
      await txn.rawDelete(
        'DELETE FROM ${grandchild.table} WHERE ${grandchild.parentColumn} IN '
        '(SELECT id FROM ${child.table} WHERE ${child.parentColumn} = ?)',
        [parentId],
      );
    }
    await txn.delete(
      child.table,
      where: '${child.parentColumn} = ?',
      whereArgs: [parentId],
    );
    final columns = await _columns(txn, child.table);
    final grandGroups = <String, List<Map<String, Object?>>>{};
    final separateGrand = grandchild == null ? null : tables[grandchild.table];
    if (grandchild != null && separateGrand != null) {
      for (final row in separateGrand.upserts) {
        final id = _string(row[grandchild.parentColumn]);
        if (id != null) grandGroups.putIfAbsent(id, () => []).add(row);
      }
    }
    for (final raw in rows) {
      final values = _rowValues(raw, columns);
      values.putIfAbsent(child.parentColumn, () => parentId);
      await txn.insert(
        child.table,
        values,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (grandchild == null) continue;
      final childId = _string(values['id']);
      if (childId == null) continue;
      final grandRows = _nested(raw, grandchild) ?? grandGroups[childId];
      if (grandRows == null) continue;
      final grandColumns = await _columns(txn, grandchild.table);
      for (final grandRaw in grandRows) {
        final grandValues = _rowValues(grandRaw, grandColumns);
        grandValues.putIfAbsent(grandchild.parentColumn, () => childId);
        await txn.insert(
          grandchild.table,
          grandValues,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  static Future<void> _applyRecordDeletes(
    Transaction txn,
    Map<String, BootstrapTableChange> tables,
  ) async {
    List<String> ids(String table) =>
        tables[table]?.deletes ?? const <String>[];

    for (final id in ids(OutboundTables.outboundSources)) {
      if (!await _isSynced(txn, OutboundTables.outboundSources, id)) continue;
      await txn.rawDelete(
        'DELETE FROM source_item_rates WHERE terms_id IN '
        '(SELECT id FROM source_payment_terms WHERE source_id = ?)',
        [id],
      );
      for (final child in const [
        OutboundTables.sourcePaymentTerms,
        OutboundTables.pickupSchedules,
        OutboundTables.outboundSourceItems,
        OutboundTables.sourcePauses,
      ]) {
        await txn.delete(child, where: 'source_id = ?', whereArgs: [id]);
      }
      await txn.delete(
        OutboundTables.outboundSources,
        where: "id = ? AND sync_state = 'synced'",
        whereArgs: [id],
      );
    }
    for (final id in ids(OutboundTables.sourceLeads)) {
      if (!await _isSynced(txn, OutboundTables.sourceLeads, id)) continue;
      await txn.delete(
        OutboundTables.leadVisits,
        where: 'lead_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        OutboundTables.sourceLeads,
        where: "id = ? AND sync_state = 'synced'",
        whereArgs: [id],
      );
    }
    for (final id in ids(OutboundTables.pickupTrips)) {
      if (!await _isSynced(txn, OutboundTables.pickupTrips, id)) continue;
      await txn.delete(
        OutboundTables.tripStops,
        where: 'trip_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        OutboundTables.pickupTrips,
        where: "id = ? AND sync_state = 'synced'",
        whereArgs: [id],
      );
    }
    for (final id in ids(OutboundTables.pickupRoutes)) {
      if (!await _isSynced(txn, OutboundTables.pickupRoutes, id)) continue;
      await txn.delete(
        OutboundTables.pickupRouteStops,
        where: 'route_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        OutboundTables.pickupRoutes,
        where: "id = ? AND sync_state = 'synced'",
        whereArgs: [id],
      );
    }
    for (final table in const [
      OutboundTables.duePickups,
      OutboundTables.supervisorFlags,
      OutboundTables.tripIssues,
      OutboundTables.outboundRequests,
      OutboundTables.supervisorCashRequests,
      OutboundTables.sourcePayments,
    ]) {
      for (final id in ids(table)) {
        await txn.delete(
          table,
          where: "id = ? AND sync_state = 'synced'",
          whereArgs: [id],
        );
      }
    }
    for (final id in ids(OutboundTables.supervisorCashBook)) {
      await txn.delete(
        OutboundTables.supervisorCashBook,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // ------------------------------------------------------------- answers

  /// Writes a 2xx outbox answer ("the whole record as the server now holds
  /// it") with the Step records upsert of its table. Called only when no
  /// other outbox item is left for the record, so the answer replaces the
  /// phone's pending copy and the row becomes `synced`.
  static Future<void> applyAnswer(
    Transaction txn, {
    required String entity,
    required String entityId,
    required Object? data,
  }) async {
    if (data is! Map) {
      await markSynced(txn, entity, entityId);
      return;
    }
    final record = Map<String, Object?>.from(data);

    // Move stops answers {from, to}: both trips, with their stops.
    if (entity == OutboundTables.pickupTrips &&
        record['from'] is Map &&
        record['to'] is Map) {
      for (final key in const ['from', 'to']) {
        await _applyParentAnswer(
          txn,
          OutboundTables.pickupTrips,
          Map<String, Object?>.from(record[key] as Map),
        );
      }
      await markSynced(txn, entity, entityId);
      return;
    }

    // A wrapped answer, e.g. {"pickup_trips": {...}}.
    final wrapped = record[entity];
    final row = wrapped is Map ? Map<String, Object?>.from(wrapped) : record;
    row.putIfAbsent('id', () => entityId);
    if (row['id'] == entityId) {
      await _applyParentAnswer(txn, entity, row);
    }
    await markSynced(txn, entity, entityId);
  }

  static Future<void> _applyParentAnswer(
    Transaction txn,
    String table,
    Map<String, Object?> row,
  ) async {
    await upsertRecord(txn, table, row, force: true);
    final spec = _parents.where((parent) => parent.table == table);
    if (spec.isEmpty || spec.first.children.isEmpty) return;
    final parentId = _string(row['id']);
    if (parentId == null) return;
    for (final child in spec.first.children) {
      final rows = _nested(row, child);
      if (rows == null) continue;
      await _replaceChildSet(txn, table, parentId, child, rows, const {});
    }
  }

  /// "Back to `synced` only when no other item for the same record is still
  /// queued."
  static Future<void> markSynced(
    Transaction txn,
    String entity,
    String entityId,
  ) async {
    if (!OutboundTables.tablesWithSyncState.contains(entity)) return;
    await txn.rawUpdate(
      "UPDATE $entity SET sync_state = 'synced' WHERE id = ? "
      'AND NOT EXISTS (SELECT 1 FROM ${DatabaseTables.outbox} '
      'WHERE entity = ? AND entity_id = ?)',
      [entityId, entity, entityId],
    );
  }

  // ------------------------------------------------------------- helpers

  static final Map<String, Set<String>> _columnCache = {};

  static Future<Set<String>> _columns(
    DatabaseExecutor txn,
    String table,
  ) async {
    final cached = _columnCache[table];
    if (cached != null) return cached;
    final info = await txn.rawQuery('PRAGMA table_info("$table")');
    final names = info.map((row) => row['name']).whereType<String>().toSet();
    if (names.isNotEmpty) _columnCache[table] = names;
    return names;
  }

  /// Keeps the columns the table has (accepting camelCase keys for its
  /// snake_case columns), turning booleans into 1/0 and lists and maps into
  /// JSON text, as the doc's conventions say.
  static Map<String, Object?> _rowValues(
    Map<String, Object?> row,
    Set<String> columns,
  ) {
    final values = <String, Object?>{};
    for (final entry in row.entries) {
      var key = entry.key;
      if (!columns.contains(key)) key = _snake(key);
      if (!columns.contains(key) || key == 'sync_state') continue;
      values[key] = _sqliteValue(entry.value);
    }
    return values;
  }

  static List<Map<String, Object?>>? _nested(
    Map<String, Object?> row,
    _ChildSpec child,
  ) {
    for (final key in child.nestedKeys) {
      final value = row[key];
      if (value is List) {
        return [
          for (final item in value)
            if (item is Map) Map<String, Object?>.from(item),
        ];
      }
    }
    return null;
  }

  static Object? _sqliteValue(Object? value) {
    if (value is bool) return value ? 1 : 0;
    if (value is List || value is Map) return jsonEncode(value);
    return value;
  }

  static String _snake(String key) => key.replaceAllMapped(
    RegExp('[A-Z]'),
    (match) => '_${match[0]!.toLowerCase()}',
  );

  static Future<bool> _isSynced(
    Transaction txn,
    String table,
    String id,
  ) async {
    final rows = await txn.query(
      table,
      columns: const ['sync_state'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty && rows.single['sync_state'] == 'synced';
  }

  static Future<void> _setMeta(Transaction txn, String key, String? value) =>
      txn.rawInsert(
        'INSERT OR REPLACE INTO ${DatabaseTables.syncMeta} (key, value) '
        'VALUES (?, ?)',
        [key, value],
      );

  static String? _string(Object? value) =>
      value is String && value.isNotEmpty ? value : null;

  static num? _num(Object? value) =>
      value is num ? value : num.tryParse(value?.toString() ?? '');

  static bool _bool(Object? value) => value == true || value == 1;

  static void _log(String message) =>
      BootstrapLog.database('[OUTBOUND] $message');
}

class _ParentSpec {
  const _ParentSpec(this.table, this.children);

  final String table;
  final List<_ChildSpec> children;
}

class _ChildSpec {
  const _ChildSpec(
    this.table,
    this.parentColumn,
    this.nestedKeys, {
    this.grandchild,
  });

  final String table;
  final String parentColumn;
  final List<String> nestedKeys;
  final _ChildSpec? grandchild;
}
