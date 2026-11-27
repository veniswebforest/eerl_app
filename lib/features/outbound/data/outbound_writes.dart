import 'dart:convert';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/database_tables.dart';
import 'package:eerl_app/core/local_database/mobile_write_validator.dart';
import 'package:eerl_app/core/local_database/outbound/named_sql.dart';
import 'package:eerl_app/core/local_database/outbox_queue.dart';
import 'package:eerl_app/features/outbound/data/outbound_clock.dart';
import 'package:sqflite/sqflite.dart';

/// Every queued outbound write: the row first, marked `pending`, then its
/// outbox item, in one transaction.
///
/// Source: `docs/project-context/outbound-schema-and-queries.md`,
/// "Outbox and uploads" (IEC Executive, Pickup Supervisor, Driver,
/// Warehouse Incharge writes and Requests). The SQL is the doc's, with its
/// `:name` parameters. Bodies are the API's camelCase JSON.
///
/// Photos and voice notes go through the fixed-point photo queue: pass the
/// local photo ids in the body where the URL goes and in `photoIds`; the
/// outbox item waits until they are uploaded and the ids are swapped for
/// their URLs just before sending.
class OutboundWrites {
  OutboundWrites({
    required this.actor,
    AppDatabase? database,
    OutboundClock? clock,
  }) : _database = database ?? AppDatabase.instance,
       clock = clock ?? OutboundClock();

  final OutboundActor actor;
  final AppDatabase _database;
  final OutboundClock clock;

  Map<String, Object?> get _who => {
    'me': actor.id,
    'my_name': actor.name,
    'my_phone': actor.phone,
    'now': clock.now,
    'today': clock.today,
    'yesterday': clock.yesterday,
  };

  // ===================================================== IEC Executive

  /// A lead (add or edit). Merge: an unsent `lead_save` is replaced.
  Future<void> saveLead({
    required String id,
    required String name,
    String? categoryId,
    String? contactName,
    String? contactPhone,
    double? lat,
    double? lng,
    String? address,
    String? areaId,
    String? notes,
    List<String> photoIds = const [],
    String status = 'NEW',
    String? nextFollowUpOn,
  }) => _tx((txn) async {
    final p = {
      ..._who,
      'id': id,
      'name': name,
      'category_id': categoryId,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'lat': lat,
      'lng': lng,
      'address': address,
      'area_id': areaId,
      'notes': notes,
      'photo_urls': jsonEncode(photoIds),
      'status': status,
      'next_follow_up_on': nextFollowUpOn,
    };
    await _run(
      txn,
      '''
      INSERT OR REPLACE INTO source_leads (id, name, category_id, contact_name, contact_phone, lat, lng,
        address, area_id, notes, photo_urls, status, next_follow_up_on, converted_source_id,
        created_at, updated_at, sync_state)
      VALUES (:id, :name, :category_id, :contact_name, :contact_phone, :lat, :lng,
        :address, :area_id, :notes, :photo_urls, :status, :next_follow_up_on, NULL,
        COALESCE((SELECT created_at FROM source_leads WHERE id = :id), :now), :now, 'pending')''',
      p,
    );
    await _queue(
      txn,
      method: 'PUT',
      path: '/source-leads/$id',
      entity: 'source_leads',
      entityId: id,
      kind: 'lead_save',
      merge: true,
      photoIds: photoIds,
      body: {
        'name': name,
        'categoryId': categoryId,
        'contactName': contactName,
        'contactPhone': contactPhone,
        'lat': lat,
        'lng': lng,
        'address': address,
        'areaId': areaId,
        'notes': notes,
        'photoUrls': photoIds,
        'nextFollowUpOn': nextFollowUpOn,
      },
    );
  });

  /// A visit. The latest visit sets the lead's status and next follow-up.
  Future<void> addVisit({
    required String visitId,
    required String leadId,
    required String visitedAt,
    required String outcome,
    String? note,
    String? nextFollowUpOn,
  }) => _tx((txn) async {
    final p = {
      ..._who,
      'visit_id': visitId,
      'lead_id': leadId,
      'visited_at': visitedAt,
      'outcome': outcome,
      'note': note,
      'next_follow_up_on': nextFollowUpOn,
    };
    await _run(
      txn,
      '''
      INSERT INTO lead_visits (id, lead_id, visited_at, outcome, note, next_follow_up_on)
      VALUES (:visit_id, :lead_id, :visited_at, :outcome, :note, :next_follow_up_on)''',
      p,
    );
    await _run(txn, '''
      UPDATE source_leads SET status = :outcome, next_follow_up_on = :next_follow_up_on, sync_state = 'pending'
       WHERE id = :lead_id AND status <> 'CONVERTED' ''', p);
    await _queue(
      txn,
      method: 'PUT',
      path: '/source-leads/$leadId/visits/$visitId',
      entity: 'source_leads',
      entityId: leadId,
      kind: 'visit',
      body: {
        'visitedAt': visitedAt,
        'outcome': outcome,
        'note': note,
        'nextFollowUpOn': nextFollowUpOn,
      },
    );
  });

  /// A source (register, edit while pending, resubmit after a rejection, or
  /// edit an approved one). [body] is the whole pickup point as the API takes
  /// it (`name`, `categoryId`, …, `schedule`, `paymentTerms`, `agreement`).
  /// [row] holds the snake_case columns the screen shows meanwhile.
  /// [scheduleRow] / [termsRow] (with [itemRates]) replace the one schedule and
  /// terms version while the source is not yet approved.
  Future<void> saveSource({
    required String id,
    required Map<String, Object?> row,
    required Map<String, Object?> body,
    List<String> itemIds = const [],
    Map<String, Object?>? scheduleRow,
    Map<String, Object?>? termsRow,
    List<Map<String, Object?>> itemRates = const [],
    List<String> photoIds = const [],
    String? agreementId,
    String? agreementEndsOn,
  }) => _tx((txn) async {
    String? col(String key) => row[key] as String?;
    final p = {
      ..._who,
      'id': id,
      'name': row['name'],
      'category_id': col('category_id'),
      'category_name': col('category_name'),
      'material_mode': col('material_mode'),
      'is_event': (row['is_event'] == true || row['is_event'] == 1) ? 1 : 0,
      'area_id': col('area_id'),
      'area_name': col('area_name'),
      'city_name': col('city_name'),
      'warehouse_id': col('warehouse_id'),
      'address': col('address'),
      'lat': row['lat'],
      'lng': row['lng'],
      'contact_name': col('contact_name'),
      'contact_phone': col('contact_phone'),
      'source_user_phone': col('source_user_phone'),
      'notes': col('notes'),
      'photo_urls': jsonEncode(photoIds),
      'lead_id': col('lead_id'),
      'contact_role': col('contact_role'),
      'contact_email': col('contact_email'),
      'agreement_id': agreementId,
      'agreement_ends_on': agreementEndsOn,
    };
    await _run(txn, '''
      INSERT INTO outbound_sources (id, number, status, name, category_id, category_name, material_mode,
        is_event, area_id, area_name, city_name, warehouse_id, address, lat, lng, contact_name, contact_phone,
        source_user_phone, notes, photo_urls, registered_by_id, registered_by_name, lead_id, revision,
        contact_role, contact_email, iec_owner_id, iec_owner_name, iec_owner_phone, agreement_status, agreement_ends_on,
        submitted_at, updated_at, sync_state)
      VALUES (:id, NULL, 'PENDING_APPROVAL', :name, :category_id, :category_name, :material_mode,
        :is_event, :area_id, :area_name, :city_name, :warehouse_id, :address, :lat, :lng, :contact_name, :contact_phone,
        :source_user_phone, :notes, :photo_urls, :me, :my_name, :lead_id, 1,
        :contact_role, :contact_email, :me, :my_name, :my_phone,
        CASE WHEN :agreement_id IS NULL THEN NULL ELSE 'DRAFT' END, :agreement_ends_on,
        :now, :now, 'pending')
      ON CONFLICT (id) DO UPDATE SET
        name = excluded.name, category_id = excluded.category_id, category_name = excluded.category_name,
        material_mode = excluded.material_mode, is_event = excluded.is_event, area_id = excluded.area_id,
        area_name = excluded.area_name, city_name = excluded.city_name, warehouse_id = excluded.warehouse_id,
        address = excluded.address, lat = excluded.lat, lng = excluded.lng, contact_name = excluded.contact_name,
        contact_phone = excluded.contact_phone, source_user_phone = excluded.source_user_phone,
        contact_role = excluded.contact_role, contact_email = excluded.contact_email,
        agreement_status = COALESCE(outbound_sources.agreement_status, excluded.agreement_status),
        agreement_ends_on = COALESCE(excluded.agreement_ends_on, outbound_sources.agreement_ends_on),
        notes = excluded.notes, photo_urls = excluded.photo_urls, updated_at = excluded.updated_at,
        status = CASE WHEN outbound_sources.status = 'REJECTED' THEN 'PENDING_APPROVAL' ELSE outbound_sources.status END,
        sync_state = 'pending' ''', p);
    // replace its items (and, while not yet approved, its one schedule and
    // one terms row) with what the IEC entered
    await txn.delete(
      'outbound_source_items',
      where: 'source_id = ?',
      whereArgs: [id],
    );
    for (var i = 0; i < itemIds.length; i++) {
      await txn.insert('outbound_source_items', {
        'id': '$id:${itemIds[i]}',
        'source_id': id,
        'item_id': itemIds[i],
        'sort_order': i + 1,
      });
    }
    final status = (await txn.query(
      'outbound_sources',
      columns: const ['status'],
      where: 'id = ?',
      whereArgs: [id],
    )).single['status'];
    final approved = status == 'ACTIVE' || status == 'PAUSED';
    if (!approved && scheduleRow != null) {
      await txn.delete(
        'pickup_schedules',
        where: 'source_id = ?',
        whereArgs: [id],
      );
      await txn.insert('pickup_schedules', {...scheduleRow, 'source_id': id});
    }
    if (!approved && termsRow != null) {
      await txn.rawDelete(
        'DELETE FROM source_item_rates WHERE terms_id IN '
        '(SELECT id FROM source_payment_terms WHERE source_id = ?)',
        [id],
      );
      await txn.delete(
        'source_payment_terms',
        where: 'source_id = ?',
        whereArgs: [id],
      );
      await txn.insert('source_payment_terms', {...termsRow, 'source_id': id});
      for (final rate in itemRates) {
        await txn.insert('source_item_rates', {
          ...rate,
          'terms_id': termsRow['id'],
        });
      }
    }
    await _queue(
      txn,
      method: 'PUT',
      path: '/outbound-sources/$id',
      entity: 'outbound_sources',
      entityId: id,
      kind: 'source_save',
      merge: true,
      photoIds: photoIds,
      body: body,
    );
    final leadId = col('lead_id');
    if (leadId != null) {
      await _run(
        txn,
        "UPDATE source_leads SET status = 'CONVERTED', converted_source_id = :id WHERE id = :lead_id",
        {'id': id, 'lead_id': leadId},
      );
    }
  });

  /// After the agreement file reached the server (online, not queued).
  Future<void> markAgreementUploaded(String sourceId) => _tx(
    (txn) => _run(
      txn,
      "UPDATE outbound_sources SET agreement_status = 'PENDING_APPROVAL' WHERE id = :source_id",
      {'source_id': sourceId},
    ),
  );

  /// New payment terms from a date (an approved source). [terms] holds the
  /// snake_case columns, with `id`, `effective_from` and the phone's
  /// `summary`; [body] is the API's terms object.
  Future<void> addPaymentTerms({
    required String sourceId,
    required Map<String, Object?> terms,
    required Map<String, Object?> body,
    List<Map<String, Object?>> itemRates = const [],
  }) => _tx((txn) async {
    final termsId = terms['id']! as String;
    await txn.insert('source_payment_terms', {...terms, 'source_id': sourceId});
    for (final rate in itemRates) {
      await txn.insert('source_item_rates', {...rate, 'terms_id': termsId});
    }
    await _run(
      txn,
      "UPDATE outbound_sources SET sync_state = 'pending' WHERE id = :id",
      {'id': sourceId},
    );
    await _queue(
      txn,
      method: 'PUT',
      path: '/outbound-sources/$sourceId/payment-terms/$termsId',
      entity: 'outbound_sources',
      entityId: sourceId,
      kind: 'terms',
      body: body,
    );
  });

  /// An extra pickup. IEC: [asSupervisor] false → `REQUESTED`; Pickup
  /// Supervisor: `DUE` at once. [date] is today to 60 days ahead.
  Future<void> addExtraPickup({
    required String id,
    required String sourceId,
    required String date,
    required bool asSupervisor,
    String? windowStart,
    String? windowEnd,
    double? expectedQtyKg,
    String? note,
  }) => _tx((txn) async {
    if ((windowStart == null) != (windowEnd == null)) {
      throw const LocalWriteValidationException(
        'Give both window times, or neither.',
        field: 'windowStart',
      );
    }
    final p = {
      ..._who,
      'id': id,
      'source_id': sourceId,
      'status': asSupervisor ? 'DUE' : 'REQUESTED',
      'date': date,
      'window_start': windowStart,
      'window_end': windowEnd,
      'expected_qty_kg': expectedQtyKg,
      'note': note,
    };
    await _run(txn, '''
      INSERT INTO due_pickups (id, source_id, origin, status, scheduled_for, slot_index, due_date,
        window_start, window_end, expected_qty_kg, note, warehouse_id, pickup_supervisor_id,
        requested_by_id, requested_by_name, source_name, source_address, lat, lng, contact_name,
        contact_phone, contact_role, material_mode, item_ids, updated_at, sync_state)
      SELECT :id, s.id, 'EXTRA', :status, :date, 0, :date,
        :window_start, :window_end, :expected_qty_kg, :note, s.warehouse_id, s.pickup_supervisor_id,
        :me, :my_name, s.name, s.address, s.lat, s.lng, s.contact_name,
        s.contact_phone, s.contact_role, s.material_mode,
        (SELECT json_group_array(item_id) FROM (SELECT item_id FROM outbound_source_items
           WHERE source_id = s.id ORDER BY sort_order)),
        :now, 'pending'
      FROM outbound_sources s WHERE s.id = :source_id''', p);
    await _queue(
      txn,
      method: 'PUT',
      path: '/due-pickups/$id',
      entity: 'due_pickups',
      entityId: id,
      kind: 'extra',
      body: {
        'sourceId': sourceId,
        'date': date,
        'windowStart': windowStart,
        'windowEnd': windowEnd,
        'expectedQtyKg': expectedQtyKg,
        'note': note,
      },
    );
  });

  /// A new schedule from a date (IEC, an Active or Paused pickup point).
  /// [schedule] holds the snake_case columns with `id`, `starts_on` and the
  /// phone's `summary`; [body] is the schedule fields without `id`.
  Future<void> saveSchedule({
    required String sourceId,
    required Map<String, Object?> schedule,
    required Map<String, Object?> body,
  }) => _tx((txn) async {
    final scheduleId = schedule['id']! as String;
    final startsOn = schedule['starts_on']! as String;
    await _run(
      txn,
      'DELETE FROM pickup_schedules WHERE source_id = :id AND effective_from >= :starts_on',
      {'id': sourceId, 'starts_on': startsOn},
    );
    await txn.insert('pickup_schedules', {
      ...schedule,
      'source_id': sourceId,
      'effective_from': startsOn,
    });
    await _run(
      txn,
      "UPDATE outbound_sources SET sync_state = 'pending' WHERE id = :id",
      {'id': sourceId},
    );
    await _queue(
      txn,
      method: 'PUT',
      path: '/outbound-sources/$sourceId/schedules/$scheduleId',
      entity: 'outbound_sources',
      entityId: sourceId,
      kind: 'schedule',
      body: body,
    );
  });

  /// A pause, or a change to one (IEC). Merge: an unsent `pause_save` for the
  /// same pause is replaced.
  Future<void> savePause({
    required String pauseId,
    required String sourceId,
    required String fromDate,
    String? toDate,
    required String reason,
  }) => _tx((txn) async {
    await _run(
      txn,
      '''
      INSERT OR REPLACE INTO source_pauses (id, source_id, from_date, to_date, reason, cancelled_at)
      VALUES (:pause_id, :source_id, :from_date, :to_date, :reason, NULL)''',
      {
        'pause_id': pauseId,
        'source_id': sourceId,
        'from_date': fromDate,
        'to_date': toDate,
        'reason': reason,
      },
    );
    await _run(
      txn,
      "UPDATE outbound_sources SET sync_state = 'pending' WHERE id = :source_id",
      {'source_id': sourceId},
    );
    await _queue(
      txn,
      method: 'PUT',
      path: '/source-pauses/$pauseId',
      entity: 'outbound_sources',
      entityId: sourceId,
      kind: 'pause_save',
      merge: true,
      mergeOnPath: true,
      body: {
        'sourceId': sourceId,
        'from': fromDate,
        'to': ?toDate,
        'reason': reason,
      },
    );
  });

  /// End a pause (IEC): not begun → it never applies; under way → it ends
  /// yesterday.
  Future<void> endPause({
    required String pauseId,
    required String sourceId,
  }) => _tx((txn) async {
    final p = {..._who, 'pause_id': pauseId, 'source_id': sourceId};
    await _run(
      txn,
      'UPDATE source_pauses SET cancelled_at = :now WHERE id = :pause_id AND from_date >= :today',
      p,
    );
    await _run(
      txn,
      'UPDATE source_pauses SET to_date = :yesterday WHERE id = :pause_id AND from_date < :today',
      p,
    );
    await _run(
      txn,
      "UPDATE outbound_sources SET sync_state = 'pending' WHERE id = :source_id",
      p,
    );
    await _queue(
      txn,
      method: 'POST',
      path: '/source-pauses/$pauseId/cancel',
      entity: 'outbound_sources',
      entityId: sourceId,
      kind: 'pause_cancel',
      body: const {},
    );
  });

  /// The pickup point called a pickup off (its IEC, or its Pickup
  /// Supervisor). It leaves its trip.
  Future<void> cancelBySource({
    required String duePickupId,
    required String reason,
    String? note,
  }) => _tx((txn) async {
    _requireNoteForOther(reason, note);
    final p = {..._who, 'id': duePickupId, 'reason': reason, 'note': note};
    await _run(txn, '''
      UPDATE due_pickups SET status = 'SOURCE_CANCELLED', source_cancel_reason = :reason,
        source_cancel_note = :note, source_cancelled_by_name = :my_name, source_cancelled_at = :now,
        trip_id = NULL, stop_order = NULL, sync_state = 'pending', updated_at = :now
      WHERE id = :id''', p);
    await _run(txn, 'DELETE FROM trip_stops WHERE id = :id', p);
    await _queue(
      txn,
      method: 'POST',
      path: '/due-pickups/$duePickupId/cancel-by-source',
      entity: 'due_pickups',
      entityId: duePickupId,
      kind: 'cancel_by_source',
      body: {'reason': reason, 'note': note},
    );
  });

  // =================================================== Pickup Supervisor

  /// Decisions on one pickup: accept, decline, skip, unskip, move.
  Future<void> decidePickup({
    required String duePickupId,
    required PickupDecision action,
    String? declineReason,
    List<String> skipReasons = const [],
    String? skipNote,
    String? moveDate,
    String? windowStart,
    String? windowEnd,
  }) => _tx((txn) async {
    final Map<String, Object?> body;
    final String newStatus;
    switch (action) {
      case PickupDecision.accept:
        newStatus = 'DUE';
        body = const {};
      case PickupDecision.decline:
        final reason = declineReason?.trim() ?? '';
        if (reason.length < 3 || reason.length > 500) {
          throw const LocalWriteValidationException(
            'Give a reason of 3 to 500 characters.',
            field: 'reason',
          );
        }
        newStatus = 'DECLINED';
        body = {'reason': reason};
      case PickupDecision.skip:
        final unique = skipReasons.toSet();
        if (unique.isEmpty ||
            unique.length != skipReasons.length ||
            !unique.every(skipReasonValues.contains)) {
          throw const LocalWriteValidationException(
            'Choose one or more skip reasons, each once.',
            field: 'reasons',
          );
        }
        if (unique.contains('OTHER') && (skipNote?.trim().isEmpty ?? true)) {
          throw const LocalWriteValidationException(
            'Add a note for Other.',
            field: 'note',
          );
        }
        newStatus = 'SKIPPED';
        body = {'reasons': skipReasons, 'note': skipNote};
      case PickupDecision.unskip:
        newStatus = 'DUE';
        body = const {};
      case PickupDecision.move:
        if (moveDate == null) {
          throw const LocalWriteValidationException(
            'Choose the day to move it to.',
            field: 'date',
          );
        }
        newStatus = 'DUE';
        body = {
          'date': moveDate,
          'windowStart': ?windowStart,
          'windowEnd': ?windowEnd,
        };
    }
    final p = {
      ..._who,
      'id': duePickupId,
      'action': action.path,
      'new_status': newStatus,
      'decline_reason': action == PickupDecision.decline
          ? body['reason']
          : null,
      'skip_reasons_json': jsonEncode(
        action == PickupDecision.skip ? skipReasons : const <String>[],
      ),
      'skip_note': action == PickupDecision.skip ? skipNote : null,
      'date': moveDate,
      'window_start': windowStart,
      'window_end': windowEnd,
    };
    if (action == PickupDecision.move) {
      await _run(txn, '''
        UPDATE due_pickups SET moved_from = COALESCE(moved_from, due_date), due_date = :date,
          window_start = COALESCE(:window_start, window_start), window_end = COALESCE(:window_end, window_end),
          status = 'DUE', trip_id = NULL, stop_order = NULL, sync_state = 'pending', updated_at = :now
        WHERE id = :id''', p);
    } else {
      await _run(txn, '''
        UPDATE due_pickups SET status = :new_status, decline_reason = :decline_reason,
          skip_reasons = :skip_reasons_json, skip_note = :skip_note,
          decided_at = CASE WHEN :action IN ('accept', 'decline') THEN :now ELSE decided_at END,
          trip_id = CASE WHEN :action = 'skip' THEN NULL ELSE trip_id END,
          stop_order = CASE WHEN :action = 'skip' THEN NULL ELSE stop_order END,
          sync_state = 'pending', updated_at = :now
        WHERE id = :id''', p);
    }
    await _run(
      txn,
      "DELETE FROM trip_stops WHERE id = :id AND :action IN ('skip', 'move')",
      p,
    );
    await _queue(
      txn,
      method: 'POST',
      path: '/due-pickups/$duePickupId/${action.path}',
      entity: 'due_pickups',
      entityId: duePickupId,
      kind: action.path,
      body: body,
    );
  });

  /// Save a route (add or change; the whole route each time). Merge: an
  /// unsent `route_save` is replaced. [sourceIds] are the pickup points in
  /// order; a pickup point leaves any other route it was on.
  Future<void> saveRoute({
    required String id,
    required String name,
    required String warehouseId,
    required String shiftId,
    required List<String> sourceIds,
    String? vehicleId,
    String? driverId,
    String? labourId,
    RentedVehicle? rented,
  }) => _tx((txn) async {
    if (rented == null && (vehicleId == null || driverId == null)) {
      throw const LocalWriteValidationException(
        'Choose a van and a driver, or type in a rented truck.',
        field: 'vehicleId',
      );
    }
    rented?.validate();
    final sourceIdsJson = jsonEncode(sourceIds);
    final p = {
      ..._who,
      'id': id,
      'name': name,
      'warehouse_id': warehouseId,
      'shift_id': shiftId,
      'vehicle_id': rented == null ? vehicleId : null,
      'rented_vehicle_number': rented?.vehicleNumber,
      'transporter_name': rented?.transporterName,
      'rented_driver_name': rented?.driverName,
      'rented_driver_phone': rented?.driverPhone,
      'rented_capacity_kg': rented?.capacityKg,
      'driver_id': rented == null ? driverId : null,
      'labour_id': labourId,
      'source_ids_json': sourceIdsJson,
    };
    await _run(
      txn,
      '''
      INSERT OR REPLACE INTO pickup_routes (id, name, supervisor_id, warehouse_id, shift_id, vehicle_kind, vehicle_id,
        rented_vehicle_number, transporter_name, rented_driver_name, rented_driver_phone, rented_capacity_kg,
        driver_id, labour_id, is_active, created_at, updated_at, sync_state)
      VALUES (:id, :name, :me, :warehouse_id, :shift_id,
        CASE WHEN :rented_vehicle_number IS NULL THEN 'OWN' ELSE 'CONTRACT' END, :vehicle_id,
        :rented_vehicle_number, :transporter_name, :rented_driver_name, :rented_driver_phone, :rented_capacity_kg,
        :driver_id, :labour_id, COALESCE((SELECT is_active FROM pickup_routes WHERE id = :id), 1),
        COALESCE((SELECT created_at FROM pickup_routes WHERE id = :id), :now), :now, 'pending')''',
      p,
    );
    await _run(
      txn,
      'DELETE FROM pickup_route_stops WHERE source_id IN (SELECT value FROM json_each(:source_ids_json))',
      p,
    );
    await _run(txn, 'DELETE FROM pickup_route_stops WHERE route_id = :id', p);
    await _run(
      txn,
      '''
      INSERT INTO pickup_route_stops (id, route_id, source_id, stop_order)
      SELECT lower(hex(randomblob(16))), :id, value, key + 1 FROM json_each(:source_ids_json)''',
      p,
    );
    await _queue(
      txn,
      method: 'PUT',
      path: '/pickup-routes/$id',
      entity: 'pickup_routes',
      entityId: id,
      kind: 'route_save',
      merge: true,
      body: {
        'name': name,
        'warehouseId': warehouseId,
        'shiftId': shiftId,
        if (rented == null) ...{'vehicleId': vehicleId, 'driverId': driverId},
        if (rented != null) 'rented': rented.toJson(),
        'labourId': labourId,
        'sourceIds': sourceIds,
      },
    );
  });

  /// Switch a route off or on.
  Future<void> setRouteActive({
    required String routeId,
    required bool active,
  }) => _tx((txn) async {
    final action = active ? 'activate' : 'deactivate';
    await _run(
      txn,
      "UPDATE pickup_routes SET is_active = :is_active, sync_state = 'pending', updated_at = :now WHERE id = :id",
      {..._who, 'id': routeId, 'is_active': active ? 1 : 0},
    );
    await _queue(
      txn,
      method: 'POST',
      path: '/pickup-routes/$routeId/$action',
      entity: 'pickup_routes',
      entityId: routeId,
      kind: action,
      body: const {},
    );
  });

  /// Change a trip for its day: the team, and the stops in order.
  /// [team] carries the van (or rented truck), driver and labourer with their
  /// names. A [reason] is required when the van, truck, driver or labourer
  /// differs from the trip's.
  Future<void> changeTripForToday({
    required String tripId,
    required TripTeam team,
    required List<String> stopIds,
    String? reason,
    String? note,
  }) => _tx((txn) async {
    if (stopIds.isEmpty) {
      throw const LocalWriteValidationException(
        'Keep at least one stop: to empty a trip, cancel it.',
        field: 'stopIds',
      );
    }
    team.rented?.validate();
    final current = (await txn.query(
      'pickup_trips',
      where: 'id = ?',
      whereArgs: [tripId],
    )).single;
    final teamChanged =
        current['vehicle_id'] != team.vehicleId ||
        current['rented_vehicle_number'] != team.rented?.vehicleNumber ||
        current['driver_id'] != team.driverId ||
        current['labour_id'] != team.labourId;
    if (teamChanged) {
      if (reason == null || !changeReasonValues.contains(reason)) {
        throw const LocalWriteValidationException(
          'Give the reason for the change.',
          field: 'reason',
        );
      }
      _requireNoteForOther(reason, note);
    }
    final rented = team.rented;
    final p = {
      ..._who,
      'id': tripId,
      'vehicle_kind': rented == null ? 'OWN' : 'CONTRACT',
      'vehicle_id': rented == null ? team.vehicleId : null,
      'vehicle_plate': rented == null ? team.vehiclePlate : null,
      'rented_vehicle_number': rented?.vehicleNumber,
      'transporter_name': rented?.transporterName,
      'rented_driver_name': rented?.driverName,
      'rented_driver_phone': rented?.driverPhone,
      'rented_capacity_kg': rented?.capacityKg,
      'driver_id': rented == null ? team.driverId : null,
      'driver_name': rented == null ? team.driverName : null,
      'driver_phone': rented == null ? team.driverPhone : null,
      'labour_id': team.labourId,
      'labour_name': team.labourName,
      'labour_phone': team.labourPhone,
      'reason': teamChanged ? reason : null,
      'note': teamChanged ? note : null,
      'stop_ids_json': jsonEncode(stopIds),
    };
    await _run(txn, '''
      UPDATE pickup_trips SET vehicle_kind = :vehicle_kind, vehicle_id = :vehicle_id, vehicle_plate = :vehicle_plate,
        rented_vehicle_number = :rented_vehicle_number, transporter_name = :transporter_name,
        rented_driver_name = :rented_driver_name, rented_driver_phone = :rented_driver_phone,
        rented_capacity_kg = :rented_capacity_kg,
        driver_id = :driver_id, driver_name = :driver_name, driver_phone = :driver_phone,
        labour_id = :labour_id, labour_name = :labour_name, labour_phone = :labour_phone,
        change_reason = COALESCE(:reason, change_reason), change_note = CASE WHEN :reason IS NULL THEN change_note ELSE :note END,
        changed_for_today = 1, sync_state = 'pending', updated_at = :now
      WHERE id = :id''', p);
    await _run(
      txn,
      '''
      UPDATE due_pickups SET status = 'DUE', trip_id = NULL, stop_order = NULL
      WHERE trip_id = :id AND id NOT IN (SELECT value FROM json_each(:stop_ids_json))''',
      p,
    );
    await _run(txn, '''
      UPDATE due_pickups SET status = 'PLANNED', trip_id = :id,
        stop_order = (SELECT key + 1 FROM json_each(:stop_ids_json) WHERE value = due_pickups.id)
      WHERE id IN (SELECT value FROM json_each(:stop_ids_json))''', p);
    await _run(
      txn,
      'DELETE FROM trip_stops WHERE trip_id = :id OR id IN (SELECT value FROM json_each(:stop_ids_json))',
      p,
    );
    await _run(txn, '''
      INSERT INTO trip_stops (id, trip_id, stop_order, source_id, status, due_date, window_start, window_end,
        expected_qty_kg, note, source_name, source_address, lat, lng, contact_name, contact_phone,
        contact_role, material_mode, item_ids)
      SELECT p.id, :id, p.stop_order, p.source_id, 'PLANNED', p.due_date, p.window_start, p.window_end,
        p.expected_qty_kg, p.note, p.source_name, p.source_address, p.lat, p.lng, p.contact_name,
        p.contact_phone, p.contact_role, p.material_mode, p.item_ids
      FROM due_pickups p WHERE p.trip_id = :id''', p);
    await _queue(
      txn,
      method: 'POST',
      path: '/pickup-trips/$tripId/change-for-today',
      entity: 'pickup_trips',
      entityId: tripId,
      kind: 'change_for_today',
      body: {
        if (rented == null) ...{
          'vehicleId': team.vehicleId,
          'driverId': team.driverId,
        },
        if (rented != null) 'rented': rented.toJson(),
        'labourId': team.labourId,
        'stopIds': stopIds,
        if (teamChanged) ...{'reason': reason, 'note': note},
      },
    );
  });

  /// Move stops to another Planned trip of mine, the same day and warehouse.
  Future<void> moveStops({
    required String tripId,
    required String toTripId,
    required List<String> duePickupIds,
    String? reason,
    String? note,
  }) => _tx((txn) async {
    if (tripId == toTripId) {
      throw const LocalWriteValidationException(
        'Choose another trip.',
        field: 'toTripId',
      );
    }
    final p = {
      ..._who,
      'id': tripId,
      'to_trip_id': toTripId,
      'stop_ids_json': jsonEncode(duePickupIds),
      'reason': reason,
      'note': note,
    };
    await _run(
      txn,
      '''
      UPDATE due_pickups SET trip_id = :to_trip_id,
        stop_order = (SELECT COALESCE(MAX(stop_order), 0) FROM due_pickups WHERE trip_id = :to_trip_id)
                   + (SELECT key + 1 FROM json_each(:stop_ids_json) WHERE value = due_pickups.id)
      WHERE id IN (SELECT value FROM json_each(:stop_ids_json)) AND trip_id = :id''',
      p,
    );
    await _run(txn, '''
      UPDATE trip_stops SET trip_id = :to_trip_id,
        stop_order = (SELECT stop_order FROM due_pickups WHERE due_pickups.id = trip_stops.id)
      WHERE id IN (SELECT value FROM json_each(:stop_ids_json))''', p);
    await _run(
      txn,
      '''
      UPDATE pickup_trips SET changed_for_today = 1, change_reason = :reason, change_note = :note,
        sync_state = 'pending', updated_at = :now WHERE id IN (:id, :to_trip_id)''',
      p,
    );
    await _run(
      txn,
      '''
      UPDATE pickup_trips SET status = 'CANCELLED', cancel_reason = 'Stops moved to ' || (SELECT route_name FROM pickup_trips WHERE id = :to_trip_id)
      WHERE id = :id AND NOT EXISTS (SELECT 1 FROM trip_stops WHERE trip_id = :id)''',
      p,
    );
    await _queue(
      txn,
      method: 'POST',
      path: '/pickup-trips/$tripId/move-stops',
      entity: 'pickup_trips',
      entityId: tripId,
      kind: 'move_stops',
      body: {
        'toTripId': toTripId,
        'duePickupIds': duePickupIds,
        'reason': reason,
        'note': note,
      },
    );
  });

  /// Cancel a trip for its day: its pickups go back to Unassigned.
  Future<void> cancelTrip({
    required String tripId,
    required String reason,
  }) => _tx((txn) async {
    if (reason.trim().isEmpty) {
      throw const LocalWriteValidationException(
        'Give a reason.',
        field: 'reason',
      );
    }
    final p = {..._who, 'id': tripId, 'reason': reason};
    await _run(txn, '''
          UPDATE pickup_trips SET status = 'CANCELLED', cancel_reason = :reason, changed_for_today = 1,
            sync_state = 'pending', updated_at = :now WHERE id = :id''', p);
    await _run(
      txn,
      "UPDATE due_pickups SET status = 'DUE', trip_id = NULL, stop_order = NULL WHERE trip_id = :id",
      p,
    );
    await _run(txn, 'DELETE FROM trip_stops WHERE trip_id = :id', p);
    await _queue(
      txn,
      method: 'POST',
      path: '/pickup-trips/$tripId/cancel',
      entity: 'pickup_trips',
      entityId: tripId,
      kind: 'cancel',
      body: {'reason': reason},
    );
  });

  /// Mark a flag done.
  Future<void> markFlagDone(String flagId) => _tx((txn) async {
    await _run(
      txn,
      "UPDATE supervisor_flags SET done_at = :now, sync_state = 'pending' WHERE id = :id",
      {..._who, 'id': flagId},
    );
    await _queue(
      txn,
      method: 'POST',
      path: '/supervisor-flags/$flagId/done',
      entity: 'supervisor_flags',
      entityId: flagId,
      kind: 'done',
      body: const {},
    );
  });

  /// Complete a trip for a driver not using the app (Planned or On route;
  /// today or earlier). [notVisited] go back to Unassigned.
  Future<void> completeTripForDriver({
    required String tripId,
    List<String> notVisited = const [],
    String? note,
  }) => _tx((txn) async {
    if (notVisited.length > 200) {
      throw const LocalWriteValidationException(
        'At most 200 stops can be marked not visited.',
        field: 'notVisited',
      );
    }
    if ((note?.length ?? 0) > 500) {
      throw const LocalWriteValidationException(
        'The note can be up to 500 characters.',
        field: 'note',
      );
    }
    final p = {
      ..._who,
      'id': tripId,
      'not_visited_json': jsonEncode(notVisited),
      'note': note,
    };
    await _run(
      txn,
      '''
      UPDATE trip_stops SET status = 'AT_GATE'
      WHERE trip_id = :id AND status = 'PLANNED' AND id NOT IN (SELECT value FROM json_each(:not_visited_json))''',
      p,
    );
    await _run(
      txn,
      'DELETE FROM trip_stops WHERE id IN (SELECT value FROM json_each(:not_visited_json))',
      p,
    );
    await _run(txn, '''
      UPDATE due_pickups SET status = 'DUE', trip_id = NULL, stop_order = NULL
      WHERE id IN (SELECT value FROM json_each(:not_visited_json))''', p);
    await _run(
      txn,
      "UPDATE due_pickups SET status = 'AT_GATE' WHERE trip_id = :id AND status = 'PLANNED'",
      p,
    );
    await _run(txn, '''
      UPDATE pickup_trips SET status = 'AT_WAREHOUSE', started_at = COALESCE(started_at, :now), completed_at = :now,
        completed_by_name = :my_name, complete_note = :note, sync_state = 'pending', updated_at = :now
      WHERE id = :id''', p);
    await _queue(
      txn,
      method: 'POST',
      path: '/pickup-trips/$tripId/complete-for-driver',
      entity: 'pickup_trips',
      entityId: tripId,
      kind: 'complete_for_driver',
      body: {'notVisited': notVisited, 'note': note},
    );
  });

  /// Decide an issue: resolve (a note, 150 characters) or escalate.
  Future<void> decideIssue({
    required String issueId,
    required bool resolve,
    String? note,
  }) => _tx((txn) async {
    if (resolve) {
      final text = note?.trim() ?? '';
      if (text.isEmpty || text.length > 150) {
        throw const LocalWriteValidationException(
          'Say what was done, in up to 150 characters.',
          field: 'note',
        );
      }
    }
    final action = resolve ? 'resolve' : 'escalate';
    await _run(
      txn,
      '''
      UPDATE trip_issues SET status = :status, resolution_note = COALESCE(:note, resolution_note),
        escalated_at = CASE WHEN :status = 'ESCALATED' THEN :now ELSE escalated_at END,
        decided_by_name = :my_name, decided_at = :now, sync_state = 'pending', updated_at = :now
      WHERE id = :id''',
      {
        ..._who,
        'id': issueId,
        'status': resolve ? 'RESOLVED' : 'ESCALATED',
        'note': resolve ? note : null,
      },
    );
    await _queue(
      txn,
      method: 'POST',
      path: '/trip-issues/$issueId/$action',
      entity: 'trip_issues',
      entityId: issueId,
      kind: action,
      body: resolve ? {'note': note} : const {},
    );
  });

  /// Ask the office for cash.
  Future<void> requestCash({
    required String id,
    required double amount,
    required String reason,
  }) => _tx((txn) async {
    if (amount <= 0) {
      throw const LocalWriteValidationException(
        'Enter an amount above zero.',
        field: 'amount',
      );
    }
    await _run(
      txn,
      '''
      INSERT INTO supervisor_cash_requests (id, amount, reason, status, created_at, updated_at, sync_state)
      VALUES (:id, :amount, :reason, 'PENDING', :now, :now, 'pending')''',
      {..._who, 'id': id, 'amount': amount, 'reason': reason},
    );
    await _queue(
      txn,
      method: 'PUT',
      path: '/supervisor-cash-requests/$id',
      entity: 'supervisor_cash_requests',
      entityId: id,
      kind: 'cash_request',
      body: {'amount': amount, 'reason': reason},
    );
  });

  /// Pay a pickup point. The amount is capped at cash in hand and at what
  /// is owed, checked here first. [receiptPhotoId] is a local photo id
  /// (upload purpose `PAYMENT_RECEIPT`).
  Future<void> paySource({
    required String id,
    required String sourceId,
    required double amount,
    required String method,
    String? reference,
    String? receiptPhotoId,
    String? note,
    required String paidOn,
  }) => _tx((txn) async {
    if (amount <= 0) {
      throw const LocalWriteValidationException(
        'Enter an amount above zero.',
        field: 'amount',
      );
    }
    if (!const {'CASH', 'UPI', 'BANK'}.contains(method)) {
      throw const LocalWriteValidationException(
        'Choose cash, UPI or bank.',
        field: 'method',
      );
    }
    if (paidOn.compareTo(clock.today) > 0) {
      throw const LocalWriteValidationException(
        'The payment date is today or earlier.',
        field: 'paidOn',
      );
    }
    final balance = await txn.rawQuery(
      "SELECT CAST(value AS REAL) AS v FROM sync_meta WHERE key = 'outbound_cash_balance'",
    );
    final inHand = balance.isEmpty ? 0.0 : (balance.single['v'] as num? ?? 0);
    if (amount > inHand) {
      throw const LocalWriteValidationException(
        'More than the cash in hand.',
        field: 'amount',
      );
    }
    final dues = await txn.query(
      'source_dues',
      columns: const ['balance'],
      where: 'source_id = ?',
      whereArgs: [sourceId],
    );
    final owed = dues.isEmpty ? 0.0 : (dues.single['balance'] as num? ?? 0);
    if (amount > owed) {
      throw const LocalWriteValidationException(
        'More than what is owed.',
        field: 'amount',
      );
    }
    final p = {
      ..._who,
      'id': id,
      'source_id': sourceId,
      'amount': amount,
      'method': method,
      'reference': method == 'CASH' ? null : reference,
      'photo_url': receiptPhotoId,
      'note': note,
      'paid_on': paidOn,
    };
    await _run(
      txn,
      '''
      INSERT INTO source_payments (id, source_id, amount, method, reference, photo_url, note, paid_on, created_at, sync_state)
      VALUES (:id, :source_id, :amount, :method, :reference, :photo_url, :note, :paid_on, :now, 'pending')''',
      p,
    );
    await _run(
      txn,
      "UPDATE sync_meta SET value = value - :amount WHERE key = 'outbound_cash_balance'",
      p,
    );
    await _run(txn, '''
      UPDATE source_dues SET paid = paid + :amount, balance = balance - :amount, last_paid_on = :paid_on
      WHERE source_id = :source_id''', p);
    await _queue(
      txn,
      method: 'PUT',
      path: '/source-payments/$id',
      entity: 'source_payments',
      entityId: id,
      kind: 'source_payment',
      photoIds: [?receiptPhotoId],
      body: {
        'sourceId': sourceId,
        'amount': amount,
        'method': method,
        'reference': method == 'CASH' ? null : reference,
        'photoUrl': receiptPhotoId,
        'note': note,
        'paidOn': paidOn,
      },
    );
  });

  // ============================================================== Driver

  /// Start trip (today's Planned trip only).
  Future<void> startTrip({required String tripId, double? lat, double? lng}) =>
      _tx((txn) async {
        await _run(
          txn,
          '''
          UPDATE pickup_trips SET status = 'ON_ROUTE', started_at = COALESCE(started_at, :now),
            sync_state = 'pending', updated_at = :now
          WHERE id = :id AND status = 'PLANNED' ''',
          {..._who, 'id': tripId},
        );
        await _queue(
          txn,
          method: 'POST',
          path: '/pickup-trips/$tripId/start',
          entity: 'pickup_trips',
          entityId: tripId,
          kind: 'start',
          body: {'lat': ?lat, 'lng': ?lng},
        );
      });

  /// Record a stop (Sorted or Mixed form, Nothing collected, Gate team will
  /// enter, Cancelled by source). One entry per stop, never changed after.
  Future<void> recordStop(StopEntry entry) => _tx((txn) async {
    entry.validate();
    final p = {
      ..._who,
      'entry_id': entry.entryId,
      'outcome': entry.outcome.wire,
      'status': entry.outcome.stopStatus,
      'zero_kg_reason': entry.zeroKgReason,
      'source_cancel_reason': entry.sourceCancelReason,
      'total_kg': entry.totalKg,
      'entry_lines_json': jsonEncode([
        for (final line in entry.lines) line.toLocalJson(),
      ]),
      'photo_urls_json': jsonEncode(entry.photoIds),
      'note': entry.note,
      'voice_url': entry.voiceId,
      'lat': entry.lat,
      'lng': entry.lng,
      'picked_by_hand': entry.pickedByHand ? 1 : 0,
      'recorded_later': entry.recordedLater ? 1 : 0,
      'recorded_at': entry.recordedAt,
      'due_pickup_id': entry.duePickupId,
      'trip_id': entry.tripId,
    };
    await _run(txn, '''
      UPDATE trip_stops SET entry_id = :entry_id, outcome = :outcome, status = :status,
        zero_kg_reason = :zero_kg_reason, source_cancel_reason = :source_cancel_reason, total_kg = :total_kg,
        entry_lines = :entry_lines_json, photo_urls = :photo_urls_json, entry_note = :note, voice_url = :voice_url,
        entry_lat = :lat, entry_lng = :lng, picked_by_hand = :picked_by_hand, recorded_later = :recorded_later,
        recorded_at = :recorded_at, recorded_by_name = :my_name, entry_method = 'DRIVER'
      WHERE id = :due_pickup_id''', p);
    await _run(txn, '''
      UPDATE pickup_trips SET status = CASE WHEN status = 'PLANNED' THEN 'ON_ROUTE' ELSE status END,
        started_at = COALESCE(started_at, :now), sync_state = 'pending', updated_at = :now
      WHERE id = :trip_id''', p);
    await _queue(
      txn,
      method: 'PUT',
      path: '/pickup-entries/${entry.entryId}',
      entity: 'pickup_trips',
      entityId: entry.tripId,
      kind: 'entry',
      photoIds: [
        ...entry.photoIds,
        for (final line in entry.lines) ?line.photoId,
        ?entry.voiceId,
      ],
      body: entry.toBody(),
    );
  });

  /// Raise an issue. It goes to the trip's supervisor, else the driver's
  /// reporting manager.
  Future<void> raiseIssue({
    required String id,
    String? tripId,
    String? sourceId,
    String? sourceName,
    required List<String> types,
    String? note,
  }) => _tx((txn) async {
    if (types.isEmpty || !types.every(issueTypeValues.contains)) {
      throw const LocalWriteValidationException(
        'Choose what happened.',
        field: 'types',
      );
    }
    if (types.contains('OTHER') && (note?.trim().isEmpty ?? true)) {
      throw const LocalWriteValidationException(
        'Add a note for Other.',
        field: 'note',
      );
    }
    final p = {
      ..._who,
      'id': id,
      'trip_id': tripId,
      'source_id': sourceId,
      'source_name': sourceName,
      'types_json': jsonEncode(types),
      'note': note,
    };
    await _run(txn, '''
      INSERT INTO trip_issues (id, trip_id, trip_number, route_name, vehicle, source_id, source_name, raised_by_id,
        raised_by_name, raised_by_phone, supervisor_id, types, note, status, raised_at, updated_at, sync_state)
      SELECT :id, t.id, t.number, t.route_name, COALESCE(t.vehicle_plate, t.rented_vehicle_number), :source_id,
        :source_name, :me, :my_name, COALESCE(:my_phone, ''), t.supervisor_id, :types_json, :note, 'OPEN', :now, :now, 'pending'
      FROM (SELECT 1) LEFT JOIN pickup_trips t ON t.id = :trip_id''', p);
    await _queue(
      txn,
      method: 'PUT',
      path: '/trip-issues/$id',
      entity: 'trip_issues',
      entityId: id,
      kind: 'issue',
      body: {
        'tripId': ?tripId,
        'sourceId': ?sourceId,
        'types': types,
        'note': note,
        'raisedAt': clock.now,
      },
    );
  });

  /// Hand over at the warehouse. Stops not recorded go to the gate team.
  Future<void> handOver({required String tripId, required int bags}) => _tx((
    txn,
  ) async {
    if (bags < 0) {
      throw const LocalWriteValidationException(
        'Enter the number of bags.',
        field: 'bags',
      );
    }
    final p = {..._who, 'id': tripId, 'bags': bags};
    await _run(
      txn,
      "UPDATE trip_stops SET status = 'AT_GATE' WHERE trip_id = :id AND status = 'PLANNED'",
      p,
    );
    await _run(txn, '''
          UPDATE pickup_trips SET status = 'AT_WAREHOUSE', handed_over_at = :now, bag_count = :bags,
            sync_state = 'pending', updated_at = :now
          WHERE id = :id''', p);
    await _queue(
      txn,
      method: 'POST',
      path: '/pickup-trips/$tripId/hand-over',
      entity: 'pickup_trips',
      entityId: tripId,
      kind: 'hand_over',
      body: {'bags': bags},
    );
  });

  // ================================================== Warehouse Incharge

  /// The incharge records a stop at the gate: COLLECTED or ZERO_KG. Only a
  /// stop `AT_GATE`, or one the gate recorded before.
  Future<void> gateEntry({
    required String tripId,
    required String duePickupId,
    required bool collected,
    List<EntryLine> lines = const [],
    double? totalKg,
    List<String> photoIds = const [],
    String? zeroKgReason,
    String? note,
  }) => _tx((txn) async {
    if (!collected) {
      if (zeroKgReason == null) {
        throw const LocalWriteValidationException(
          'Choose why nothing was collected.',
          field: 'zeroKgReason',
        );
      }
      _requireNoteForOther(zeroKgReason, note);
    }
    final p = {
      ..._who,
      'trip_id': tripId,
      'due_pickup_id': duePickupId,
      'status': collected ? 'COLLECTED' : 'NOT_COLLECTED',
      'outcome': collected ? 'COLLECTED' : 'ZERO_KG',
      'zero_kg_reason': collected ? null : zeroKgReason,
      'total_kg': totalKg,
      'entry_lines_json': jsonEncode([for (final l in lines) l.toLocalJson()]),
      'photo_urls_json': jsonEncode(photoIds),
      'note': note,
    };
    await _run(txn, '''
      UPDATE trip_stops SET status = :status, outcome = :outcome,
        driver_estimate_kg = CASE WHEN entry_method = 'DRIVER' THEN total_kg ELSE driver_estimate_kg END,
        entry_method = 'GATE', zero_kg_reason = :zero_kg_reason, total_kg = :total_kg,
        entry_lines = :entry_lines_json, photo_urls = :photo_urls_json, entry_note = :note,
        recorded_at = :now, recorded_by_name = :my_name
      WHERE id = :due_pickup_id''', p);
    await _run(
      txn,
      "UPDATE pickup_trips SET status = 'AT_WAREHOUSE', sync_state = 'pending', updated_at = :now WHERE id = :trip_id",
      p,
    );
    await _queue(
      txn,
      method: 'PUT',
      path: '/pickup-trips/$tripId/gate-entries/$duePickupId',
      entity: 'pickup_trips',
      entityId: tripId,
      kind: 'gate_entry',
      photoIds: [...photoIds, for (final l in lines) ?l.photoId],
      body: {
        'outcome': collected ? 'COLLECTED' : 'ZERO_KG',
        if (lines.isNotEmpty) 'lines': [for (final l in lines) l.toBody()],
        'totalKg': ?totalKg,
        if (photoIds.isNotEmpty) 'photoUrls': photoIds,
        'zeroKgReason': ?(collected ? null : zeroKgReason),
        'note': note,
      },
    );
  });

  /// The incharge saves the weighbridge. Partial saves: null keeps a value;
  /// only what was entered is sent. Empty must be less than gross.
  Future<void> saveWeighbridge({
    required String tripId,
    double? grossKg,
    String? grossAt,
    double? emptyKg,
    String? emptyAt,
    int? bagsReceived,
    List<String>? slipPhotoIds,
    String? unloadingStartedAt,
    String? unloadingDoneAt,
  }) => _tx((txn) async {
    final trip = (await txn.query(
      'pickup_trips',
      columns: const ['gross_kg', 'empty_kg'],
      where: 'id = ?',
      whereArgs: [tripId],
    )).single;
    final gross = grossKg ?? (trip['gross_kg'] as num?)?.toDouble();
    final empty = emptyKg ?? (trip['empty_kg'] as num?)?.toDouble();
    if (gross != null && empty != null && empty >= gross) {
      throw const LocalWriteValidationException(
        'The empty weight must be less than the loaded weight.',
        field: 'emptyKg',
      );
    }
    final p = {
      ..._who,
      'id': tripId,
      'gross_kg': grossKg,
      'empty_kg': emptyKg,
      'bags_received': bagsReceived,
      'slip_photo_urls_json': slipPhotoIds == null
          ? null
          : jsonEncode(slipPhotoIds),
      'unloading_started_at': unloadingStartedAt,
      'unloading_done_at': unloadingDoneAt,
    };
    await _run(txn, '''
      UPDATE pickup_trips SET gross_kg = COALESCE(:gross_kg, gross_kg), empty_kg = COALESCE(:empty_kg, empty_kg),
        bags_received = COALESCE(:bags_received, bags_received),
        slip_photo_urls = COALESCE(:slip_photo_urls_json, slip_photo_urls),
        unloading_started_at = COALESCE(:unloading_started_at, unloading_started_at),
        unloading_done_at = COALESCE(:unloading_done_at, unloading_done_at),
        net_kg = CASE WHEN COALESCE(:gross_kg, gross_kg) IS NOT NULL AND COALESCE(:empty_kg, empty_kg) IS NOT NULL
          THEN ROUND(COALESCE(:gross_kg, gross_kg) - COALESCE(:empty_kg, empty_kg), 2) END,
        weighed_by_name = :my_name, sync_state = 'pending', updated_at = :now
      WHERE id = :id''', p);
    await _queue(
      txn,
      method: 'PUT',
      path: '/pickup-trips/$tripId/weighbridge',
      entity: 'pickup_trips',
      entityId: tripId,
      kind: 'weighbridge',
      photoIds: slipPhotoIds ?? const [],
      body: {
        'grossKg': ?grossKg,
        'grossAt': ?grossAt,
        'emptyKg': ?emptyKg,
        'emptyAt': ?emptyAt,
        'bagsReceived': ?bagsReceived,
        'slipPhotoUrls': ?slipPhotoIds,
        'unloadingStartedAt': ?unloadingStartedAt,
        'unloadingDoneAt': ?unloadingDoneAt,
      },
    );
  });

  /// The incharge approves (status CHECKING; a note when flagged) or sends
  /// back (a note).
  Future<void> decideTrip({
    required String tripId,
    required bool approve,
    String? note,
  }) => _tx((txn) async {
    final trip = (await txn.query(
      'pickup_trips',
      columns: const ['variance_flagged'],
      where: 'id = ?',
      whereArgs: [tripId],
    )).single;
    final needsNote = !approve || trip['variance_flagged'] == 1;
    if (needsNote && (note?.trim().isEmpty ?? true)) {
      throw const LocalWriteValidationException('Add a note.', field: 'note');
    }
    final action = approve ? 'approve' : 'send-back';
    await _run(
      txn,
      '''
      UPDATE pickup_trips SET status = CASE :action WHEN 'approve' THEN 'APPROVED' ELSE 'AT_WAREHOUSE' END,
        approved_at = CASE :action WHEN 'approve' THEN :now ELSE approved_at END,
        approved_by_name = CASE :action WHEN 'approve' THEN :my_name ELSE approved_by_name END,
        approval_note = CASE :action WHEN 'approve' THEN :note ELSE approval_note END,
        sent_back_at = CASE :action WHEN 'send-back' THEN :now ELSE sent_back_at END,
        sent_back_note = CASE :action WHEN 'send-back' THEN :note ELSE sent_back_note END,
        sync_state = 'pending', updated_at = :now
      WHERE id = :id''',
      {..._who, 'id': tripId, 'action': action, 'note': note},
    );
    await _queue(
      txn,
      method: 'POST',
      path: '/pickup-trips/$tripId/$action',
      entity: 'pickup_trips',
      entityId: tripId,
      kind: action,
      body: {'note': note},
    );
  });

  // ============================================================ Requests

  /// Ask. Until the server's row arrives, [assigneeId] / [assigneeName] show
  /// who it is with (see the doc: Collection Head from sync_meta, the IEC's
  /// supervisor from the pickup point, a correction's trip supervisor).
  Future<void> askRequest(OutboundRequestDraft draft) => _tx((txn) async {
    draft.validate(clock.today);
    final p = {
      ..._who,
      'id': draft.id,
      'kind': draft.kind,
      'my_role': draft.raisedAs,
      'send_to': draft.sendTo,
      'assignee_id': draft.assigneeId,
      'assignee_name': draft.assigneeName,
      'source_id': draft.sourceId,
      'source_name': draft.sourceName,
      'route_id': draft.routeId,
      'route_name': draft.routeName,
      'trip_id': draft.tripId,
      'trip_number': draft.tripNumber,
      'entry_id': draft.entryId,
      'due_pickup_id': draft.duePickupId,
      'from_date': draft.fromDate,
      'to_date': draft.toDate,
      'details': draft.details,
      'proposed_json': draft.correction == null
          ? null
          : jsonEncode(draft.correction),
    };
    await _run(txn, '''
      INSERT INTO outbound_requests (id, kind, raised_by_id, raised_by_name, raised_by_phone, raised_as, send_to,
        assignee_id, assignee_name, source_id, source_name, route_id, route_name, trip_id, trip_number, entry_id,
        due_pickup_id, from_date, to_date, details, proposed, status, raised_at, updated_at, sync_state)
      VALUES (:id, :kind, :me, :my_name, :my_phone, :my_role, :send_to, :assignee_id, :assignee_name, :source_id,
        :source_name, :route_id, :route_name, :trip_id, :trip_number, :entry_id, :due_pickup_id, :from_date, :to_date,
        :details, :proposed_json, 'WAITING', :now, :now, 'pending')''', p);
    await _queue(
      txn,
      method: 'PUT',
      path: '/outbound-requests/${draft.id}',
      entity: 'outbound_requests',
      entityId: draft.id,
      kind: 'outbound_request',
      body: {
        'kind': draft.kind,
        if (draft.raisedAs == 'IEC') 'sendTo': draft.sendTo,
        'sourceId': ?draft.sourceId,
        if (draft.tripId != null)
          'tripId': draft.tripId
        else if (draft.routeId != null)
          'routeId': draft.routeId,
        'entryId': ?draft.entryId,
        'fromDate': ?draft.fromDate,
        'toDate': ?draft.toDate,
        'details': draft.details,
        'correction': ?draft.correction,
        'raisedAt': clock.now,
      },
    );
  });

  /// The supervisor answers one sent to them. A reply is required to decline.
  Future<void> answerRequest({
    required String requestId,
    required bool approve,
    String? reply,
  }) => _tx((txn) async {
    if (!approve && (reply?.trim().isEmpty ?? true)) {
      throw const LocalWriteValidationException(
        'Give a reply to decline.',
        field: 'reply',
      );
    }
    await _run(
      txn,
      '''
      UPDATE outbound_requests SET status = :status, reply = :reply, decided_by_name = :my_name, decided_at = :now,
        sync_state = 'pending', updated_at = :now
      WHERE id = :id''',
      {
        ..._who,
        'id': requestId,
        'status': approve ? 'APPROVED' : 'DECLINED',
        'reply': reply,
      },
    );
    await _queue(
      txn,
      method: 'POST',
      path: '/outbound-requests/$requestId/decide',
      entity: 'outbound_requests',
      entityId: requestId,
      kind: 'decide',
      body: {'decision': approve ? 'APPROVE' : 'DECLINE', 'reply': reply},
    );
  });

  /// Follow up a waiting request: once an IST day.
  Future<void> followUpRequest(String requestId) => _tx((txn) async {
    final rows = await txn.rawQuery(
      '''SELECT (status = 'WAITING' AND (last_follow_up_at IS NULL OR date(last_follow_up_at, '+5 hours',
          '+30 minutes') < date('now', '+5 hours', '+30 minutes'))) AS ok
         FROM outbound_requests WHERE id = ?''',
      [requestId],
    );
    if (rows.isEmpty || rows.single['ok'] != 1) {
      throw const LocalWriteValidationException(
        'You can follow up once a day on a waiting request.',
      );
    }
    await _run(
      txn,
      '''
      UPDATE outbound_requests SET follow_ups = follow_ups + 1, last_follow_up_at = :now, sync_state = 'pending',
        updated_at = :now
      WHERE id = :id AND status = 'WAITING' ''',
      {..._who, 'id': requestId},
    );
    await _queue(
      txn,
      method: 'POST',
      path: '/outbound-requests/$requestId/follow-up',
      entity: 'outbound_requests',
      entityId: requestId,
      kind: 'follow_up',
      body: const {},
    );
  });

  /// Escalate an IEC's request to a supervisor, after 3 follow-ups.
  Future<void> escalateRequest(String requestId, {String? details}) => _tx((
    txn,
  ) async {
    final rows = await txn.rawQuery(
      '''SELECT (status = 'WAITING' AND raised_as = 'IEC' AND send_to = 'SUPERVISOR'
               AND follow_ups >= 3) AS ok FROM outbound_requests WHERE id = ?''',
      [requestId],
    );
    if (rows.isEmpty || rows.single['ok'] != 1) {
      throw const LocalWriteValidationException(
        'Escalate after 3 follow-ups on a request to a supervisor.',
      );
    }
    await _run(
      txn,
      '''
          UPDATE outbound_requests SET send_to = 'COLLECTION_HEAD', assignee_id = NULL,
            assignee_name = (SELECT value FROM sync_meta WHERE key = 'supervisor_name'),
            escalated_at = :now, sync_state = 'pending', updated_at = :now
          WHERE id = :id''',
      {..._who, 'id': requestId},
    );
    await _queue(
      txn,
      method: 'POST',
      path: '/outbound-requests/$requestId/escalate',
      entity: 'outbound_requests',
      entityId: requestId,
      kind: 'escalate',
      body: {'details': ?details},
    );
  });

  // ============================================================= helpers

  Future<T> _tx<T>(Future<T> Function(Transaction txn) action) =>
      _database.runInTransaction(action);

  static Future<int> _run(
    Transaction txn,
    String sql,
    Map<String, Object?> params,
  ) {
    final bound = NamedSql(sql, params);
    return txn.rawUpdate(bound.sql, bound.arguments);
  }

  /// Queues the outbox item. With [merge], an unsent item of the same kind for
  /// the same record (and, with [mergeOnPath], the same path) gets the new
  /// body instead of a second item.
  static Future<void> _queue(
    Transaction txn, {
    required String method,
    required String path,
    required String entity,
    required String entityId,
    required String kind,
    required Map<String, Object?> body,
    List<String> photoIds = const [],
    bool merge = false,
    bool mergeOnPath = false,
  }) async {
    if (merge) {
      final updated = await txn.rawUpdate(
        'UPDATE ${DatabaseTables.outbox} SET body = ?, refs = ?, attempts = 0, '
        'last_error = NULL, next_attempt_at = NULL '
        "WHERE entity = ? AND entity_id = ? AND kind = ? AND status = 'queued'"
        '${mergeOnPath ? ' AND path = ?' : ''}',
        [
          jsonEncode(body),
          jsonEncode(photoIds),
          entity,
          entityId,
          kind,
          if (mergeOnPath) path,
        ],
      );
      if (updated > 0) {
        final seqs = await txn.rawQuery(
          'SELECT seq FROM ${DatabaseTables.outbox} '
          "WHERE entity = ? AND entity_id = ? AND kind = ? AND status = 'queued'"
          '${mergeOnPath ? ' AND path = ?' : ''}',
          [entity, entityId, kind, if (mergeOnPath) path],
        );
        for (final row in seqs) {
          await txn.delete(
            DatabaseTables.outboxPhotos,
            where: 'outbox_seq = ?',
            whereArgs: [row['seq']],
          );
          for (final photoId in photoIds.toSet()) {
            await txn.insert(DatabaseTables.outboxPhotos, {
              'outbox_seq': row['seq'],
              'photo_id': photoId,
            });
          }
        }
        return;
      }
    }
    await OutboxQueue.enqueue(
      txn,
      method: method,
      path: path,
      entity: entity,
      entityId: entityId,
      kind: kind,
      body: body,
      refs: photoIds,
      blockingPhotoIds: photoIds,
    );
  }

  static void _requireNoteForOther(String reason, String? note) {
    if (reason == 'OTHER' && (note?.trim().isEmpty ?? true)) {
      throw const LocalWriteValidationException(
        'Add a note for Other.',
        field: 'note',
      );
    }
  }

  static const skipReasonValues = <String>{
    'SOURCE_CLOSED',
    'HOLIDAY',
    'SOURCE_ASKED',
    'VEHICLE_UNAVAILABLE',
    'CAPACITY_FULL',
    'NOT_ENOUGH_TIME',
    'OTHER',
  };

  static const changeReasonValues = <String>{
    'ABSENT',
    'BREAKDOWN',
    'VEHICLE_UNAVAILABLE',
    'OTHER',
  };

  static const issueTypeValues = <String>{
    'VEHICLE_BREAKDOWN',
    'ACCIDENT',
    'SOURCE_PROBLEM',
    'OTHER',
  };
}

// ================================================================ models

enum PickupDecision {
  accept('accept'),
  decline('decline'),
  skip('skip'),
  unskip('unskip'),
  move('move');

  const PickupDecision(this.path);

  final String path;
}

/// A rented truck typed in on a route or a trip (no driver app).
class RentedVehicle {
  const RentedVehicle({
    required this.vehicleNumber,
    this.transporterName,
    this.driverName,
    this.driverPhone,
    this.capacityKg,
  });

  final String vehicleNumber;
  final String? transporterName;
  final String? driverName;
  final String? driverPhone;
  final double? capacityKg;

  void validate() {
    if (vehicleNumber.trim().isEmpty) {
      throw const LocalWriteValidationException(
        "Enter the truck's number.",
        field: 'rented.vehicleNumber',
      );
    }
    final capacity = capacityKg;
    if (capacity != null &&
        (capacity <= 0 ||
            capacity > 100000 ||
            (capacity * 100).roundToDouble() != capacity * 100)) {
      throw const LocalWriteValidationException(
        'Capacity is above 0, at most 100000 KG, with up to 2 decimals.',
        field: 'rented.capacityKg',
      );
    }
  }

  Map<String, Object?> toJson() => {
    'vehicleNumber': vehicleNumber,
    'transporterName': transporterName,
    'driverName': driverName,
    'driverPhone': driverPhone,
    'capacityKg': ?capacityKg,
  };
}

/// The team for Change for today, with the names the trip row copies.
class TripTeam {
  const TripTeam({
    this.vehicleId,
    this.vehiclePlate,
    this.rented,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.labourId,
    this.labourName,
    this.labourPhone,
  });

  final String? vehicleId;
  final String? vehiclePlate;
  final RentedVehicle? rented;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? labourId;
  final String? labourName;
  final String? labourPhone;
}

enum StopOutcome {
  collected('COLLECTED', 'COLLECTED'),
  zeroKg('ZERO_KG', 'NOT_COLLECTED'),
  gate('GATE', 'AT_GATE'),
  sourceCancelled('SOURCE_CANCELLED', 'SOURCE_CANCELLED');

  const StopOutcome(this.wire, this.stopStatus);

  /// The API's `outcome` value.
  final String wire;

  /// The stop's status for this outcome.
  final String stopStatus;
}

/// One item line of a Sorted stop (or a gate entry).
class EntryLine {
  const EntryLine({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    this.photoId,
  });

  final String itemId;
  final String itemName;
  final double quantity;

  /// `KG` or `PCS`.
  final String unit;

  /// A local photo id (upload purpose `PICKUP_PHOTO`).
  final String? photoId;

  Map<String, Object?> toLocalJson() => {
    'item_id': itemId,
    'item_name': itemName,
    'quantity': quantity,
    'unit': unit,
    'photo_url': photoId,
  };

  Map<String, Object?> toBody() => {
    'itemId': itemId,
    'quantity': quantity,
    'photoUrl': ?photoId,
  };
}

/// What the driver records at a stop.
class StopEntry {
  const StopEntry({
    required this.entryId,
    required this.tripId,
    required this.duePickupId,
    required this.outcome,
    required this.recordedAt,
    this.lines = const [],
    this.totalKg,
    this.photoIds = const [],
    this.zeroKgReason,
    this.sourceCancelReason,
    this.note,
    this.voiceId,
    this.lat,
    this.lng,
    this.pickedByHand = false,
    this.recordedLater = false,
  });

  final String entryId;
  final String tripId;
  final String duePickupId;
  final StopOutcome outcome;
  final String recordedAt;
  final List<EntryLine> lines;
  final double? totalKg;
  final List<String> photoIds;
  final String? zeroKgReason;
  final String? sourceCancelReason;
  final String? note;
  final String? voiceId;
  final double? lat;
  final double? lng;
  final bool pickedByHand;
  final bool recordedLater;

  void validate() {
    if (outcome == StopOutcome.collected && photoIds.isEmpty) {
      throw const LocalWriteValidationException(
        'Add a photo of the material and the scale.',
        field: 'photoUrls',
      );
    }
    if (outcome == StopOutcome.zeroKg && zeroKgReason == null) {
      throw const LocalWriteValidationException(
        'Choose why nothing was collected.',
        field: 'zeroKgReason',
      );
    }
    if (outcome == StopOutcome.sourceCancelled && sourceCancelReason == null) {
      throw const LocalWriteValidationException(
        'Choose why the pickup point cancelled.',
        field: 'sourceCancelReason',
      );
    }
    final reason = zeroKgReason ?? sourceCancelReason;
    if (reason == 'OTHER' && (note?.trim().isEmpty ?? true)) {
      throw const LocalWriteValidationException(
        'Add a note for Other.',
        field: 'note',
      );
    }
    if ((note?.length ?? 0) > 150) {
      throw const LocalWriteValidationException(
        'The note can be up to 150 characters.',
        field: 'note',
      );
    }
    final itemIds = lines.map((line) => line.itemId).toList();
    if (itemIds.toSet().length != itemIds.length) {
      throw const LocalWriteValidationException(
        'Each item can be entered once.',
        field: 'lines',
      );
    }
  }

  Map<String, Object?> toBody() => {
    'duePickupId': duePickupId,
    'outcome': outcome.wire,
    if (lines.isNotEmpty) 'lines': [for (final line in lines) line.toBody()],
    'totalKg': ?totalKg,
    'photoUrls': photoIds,
    'zeroKgReason': ?zeroKgReason,
    'sourceCancelReason': ?sourceCancelReason,
    'note': ?note,
    'voiceUrl': ?voiceId,
    'lat': ?lat,
    'lng': ?lng,
    'pickedByHand': pickedByHand,
    'recordedLater': recordedLater,
    'recordedAt': recordedAt,
  };
}

/// A request to queue (Requests, Ask).
class OutboundRequestDraft {
  const OutboundRequestDraft({
    required this.id,
    required this.kind,
    required this.raisedAs,
    required this.sendTo,
    required this.details,
    this.assigneeId,
    this.assigneeName,
    this.sourceId,
    this.sourceName,
    this.routeId,
    this.routeName,
    this.tripId,
    this.tripNumber,
    this.entryId,
    this.duePickupId,
    this.fromDate,
    this.toDate,
    this.correction,
  });

  final String id;

  /// VEHICLE | LABOUR | PICKUP_POINT_CHANGE | START_PICKUPS | STOP_PICKUPS |
  /// PAUSE_PICKUPS | SCHEDULE_CHANGE | ROUTE_OR_VEHICLE | OTHER |
  /// ENTRY_CORRECTION.
  final String kind;

  /// PICKUP_SUPERVISOR | IEC | DRIVER.
  final String raisedAs;

  /// SUPERVISOR | COLLECTION_HEAD.
  final String sendTo;
  final String details;
  final String? assigneeId;
  final String? assigneeName;
  final String? sourceId;
  final String? sourceName;
  final String? routeId;
  final String? routeName;
  final String? tripId;
  final String? tripNumber;
  final String? entryId;
  final String? duePickupId;
  final String? fromDate;
  final String? toDate;

  /// A correction: `{"lines": [{"itemId", "quantity"}]}` or `{"totalKg"}`.
  final Map<String, Object?>? correction;

  static const _byRole = <String, Set<String>>{
    'PICKUP_SUPERVISOR': {
      'VEHICLE',
      'LABOUR',
      'PICKUP_POINT_CHANGE',
      'START_PICKUPS',
      'STOP_PICKUPS',
      'PAUSE_PICKUPS',
    },
    'IEC': {
      'START_PICKUPS',
      'SCHEDULE_CHANGE',
      'PAUSE_PICKUPS',
      'ROUTE_OR_VEHICLE',
      'OTHER',
    },
    'DRIVER': {'ENTRY_CORRECTION'},
  };

  void validate(String today) {
    if (!(_byRole[raisedAs]?.contains(kind) ?? false)) {
      throw LocalWriteValidationException(
        '$raisedAs cannot ask for $kind.',
        field: 'kind',
      );
    }
    if (details.trim().isEmpty) {
      throw const LocalWriteValidationException(
        'Add the details.',
        field: 'details',
      );
    }
    if (kind == 'VEHICLE' || kind == 'LABOUR') {
      if (routeId == null && tripId == null) {
        throw const LocalWriteValidationException(
          'Choose a route or a trip.',
          field: 'routeId',
        );
      }
    }
    if (kind == 'ENTRY_CORRECTION') {
      if (entryId == null || correction == null) {
        throw const LocalWriteValidationException(
          'Choose the stop and enter the correction.',
          field: 'correction',
        );
      }
    } else if (kind != 'VEHICLE' && kind != 'LABOUR' && sourceId == null) {
      throw const LocalWriteValidationException(
        'Choose the pickup point.',
        field: 'sourceId',
      );
    }
    final needsDate =
        kind != 'PICKUP_POINT_CHANGE' && kind != 'ENTRY_CORRECTION';
    if (needsDate && fromDate == null) {
      throw const LocalWriteValidationException(
        'Choose the date.',
        field: 'fromDate',
      );
    }
    if (kind == 'PAUSE_PICKUPS' &&
        fromDate != null &&
        fromDate!.compareTo(today) < 0) {
      throw const LocalWriteValidationException(
        'A pause starts today or later.',
        field: 'fromDate',
      );
    }
  }
}
