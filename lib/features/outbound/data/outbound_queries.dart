import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:eerl_app/core/local_database/outbound/named_sql.dart';
import 'package:eerl_app/features/outbound/data/outbound_clock.dart';

typedef OutboundRow = Map<String, Object?>;

/// Every outbound screen query, read from SQLite only.
///
/// Source: `docs/project-context/outbound-schema-and-queries.md`,
/// "Pickup Supervisor screens", "Driver screens", "IEC Executive screens"
/// and "Warehouse Incharge screens". The SQL is the doc's, with its `:name`
/// parameters; `:me`, `:today`, `:tomorrow` and `:now_hhmm` come from
/// [actorId] and [clock].
class OutboundQueries {
  OutboundQueries({
    required this.actorId,
    AppDatabase? database,
    OutboundClock? clock,
  }) : _database = database ?? AppDatabase.instance,
       clock = clock ?? OutboundClock();

  final String actorId;
  final AppDatabase _database;
  final OutboundClock clock;

  Map<String, Object?> get _base => {
    'me': actorId,
    'today': clock.today,
    'tomorrow': clock.tomorrow,
  };

  Future<List<OutboundRow>> _all(
    String sql, [
    Map<String, Object?> params = const {},
  ]) {
    final bound = NamedSql(sql, {..._base, ...params});
    return _database.rawQuery(bound.sql, bound.arguments);
  }

  Future<OutboundRow?> _one(
    String sql, [
    Map<String, Object?> params = const {},
  ]) async {
    final rows = await _all(sql, params);
    return rows.isEmpty ? null : rows.first;
  }

  // ===================================================== Pickup Supervisor
  // ------------------------------------------------------------------ Home

  /// Needs your attention: Approvals and My requests.
  Future<OutboundRow?> supervisorAttention() => _one(
    '''
    SELECT
      (SELECT COUNT(*) FROM outbound_requests WHERE assignee_id = :me AND send_to = 'SUPERVISOR' AND status = 'WAITING')
      + (SELECT COUNT(*) FROM due_pickups WHERE pickup_supervisor_id = :me AND status = 'REQUESTED') AS approvals,
      (SELECT COUNT(*) FROM outbound_requests WHERE raised_by_id = :me AND status = 'WAITING') AS my_requests''',
  );

  /// The Home tiles.
  Future<OutboundRow?> supervisorHomeTiles() => _one(
    '''
    SELECT
      (SELECT COUNT(*) FROM pickup_trips
        WHERE supervisor_id = :me AND trip_date = :today AND status <> 'CANCELLED')                AS trips_today,
      (SELECT COUNT(*) FROM due_pickups
        WHERE pickup_supervisor_id = :me AND status IN ('DUE', 'PLANNED') AND due_date = :today)  AS due_today,
      (SELECT COUNT(*) FROM due_pickups
        WHERE pickup_supervisor_id = :me AND status = 'REQUESTED')                                  AS extra_requests,
      (SELECT COUNT(*) FROM due_pickups p LEFT JOIN pickup_trips t ON t.id = p.trip_id
        WHERE p.pickup_supervisor_id = :me AND p.status IN ('DUE', 'PLANNED')
          AND (p.due_date < :today OR t.status IN ('AT_WAREHOUSE', 'CHECKING', 'APPROVED')))       AS missed,
      (SELECT COUNT(*) FROM supervisor_flags WHERE done_at IS NULL)                                 AS open_flags,
      (SELECT COUNT(*) FROM trip_issues WHERE supervisor_id = :me AND status = 'OPEN')             AS open_issues''',
  );

  /// Collection summary for the chip's IST days, inclusive.
  Future<OutboundRow?> collectionSummary({
    required String from,
    required String to,
  }) => _one(
    '''
    SELECT
      COUNT(DISTINCT t.id)                                                        AS trips,
      COUNT(s.id)                                                                 AS stops,
      COALESCE(SUM(s.status = 'COLLECTED'), 0)                                    AS collected,
      COALESCE(SUM(s.status = 'NOT_COLLECTED'), 0)                                AS zero_kg,
      COALESCE(SUM(s.status = 'AT_GATE'), 0)                                      AS at_gate,
      COALESCE(SUM(s.status = 'SOURCE_CANCELLED'), 0)                             AS cancelled_at_stop,
      COALESCE(SUM(s.status = 'PLANNED' AND (s.due_date < :today
        OR t.status IN ('AT_WAREHOUSE', 'CHECKING', 'APPROVED'))), 0)             AS missed
    FROM pickup_trips t LEFT JOIN trip_stops s ON s.trip_id = t.id
    WHERE t.supervisor_id = :me AND t.trip_date BETWEEN :from AND :to AND t.status <> 'CANCELLED'
  ''',
    {'from': from, 'to': to},
  );

  /// Collected KG and pieces for the chip's IST days.
  Future<List<OutboundRow>> collectionSummaryByUnit({
    required String from,
    required String to,
  }) => _all(
    '''
    SELECT json_extract(l.value, '\$.unit') AS unit, ROUND(SUM(json_extract(l.value, '\$.quantity')), 2) AS total
    FROM pickup_trips t JOIN trip_stops s ON s.trip_id = t.id, json_each(s.entry_lines) l
    WHERE t.supervisor_id = :me AND t.trip_date BETWEEN :from AND :to AND s.status = 'COLLECTED'
    GROUP BY unit''',
    {'from': from, 'to': to},
  );

  /// Call the Collection Head (also the IEC's and the Driver's button).
  /// Both NULL: hide the button.
  Future<OutboundRow?> collectionHead() => _one(
    '''
    SELECT
      (SELECT value FROM sync_meta WHERE key = 'outbound_collection_head_name')  AS name,
      (SELECT value FROM sync_meta WHERE key = 'outbound_collection_head_phone') AS phone''',
  );

  /// Who requests to the Collection Head go to: `outbound_collection_head_id`.
  Future<String?> collectionHeadId() async =>
      (await _one(
            "SELECT value FROM sync_meta WHERE key = 'outbound_collection_head_id'",
          ))?['value']
          as String?;

  /// The supervisor's areas (Home, the side drawer).
  Future<List<OutboundRow>> supervisorAreas() => _all('''
    SELECT a.id, a.name, c.name AS city_name, a.pin_codes
    FROM areas a
    JOIN cities c ON c.id = a.city_id
    ORDER BY c.name, a.name''');

  // ------------------------------------------------------- Approval requests

  /// Corrections and IEC requests sent to you, with extra pickups waiting.
  /// [toApprove]: the To approve tab; false: Done.
  Future<List<OutboundRow>> approvalRequests({required bool toApprove}) => _all(
    '''
    SELECT 'REQUEST' AS what, r.id, r.kind, r.source_name, r.trip_number, r.details, r.proposed, r.raised_by_name,
      r.raised_as, r.raised_at AS sent_at, r.status
    FROM outbound_requests r
    WHERE r.assignee_id = :me AND r.send_to = 'SUPERVISOR' AND (:tab = 'TO_APPROVE') = (r.status = 'WAITING')
    UNION ALL
    SELECT 'EXTRA_PICKUP', p.id, 'EXTRA_PICKUP', p.source_name, NULL, p.note, NULL, p.requested_by_name, NULL,
      p.updated_at, p.status
    FROM due_pickups p
    WHERE p.pickup_supervisor_id = :me AND p.origin = 'EXTRA' AND (:tab = 'TO_APPROVE') = (p.status = 'REQUESTED')
    ORDER BY sent_at DESC''',
    {'tab': toApprove ? 'TO_APPROVE' : 'DONE'},
  );

  /// A correction's before and after, per item. A Mixed stop: compare
  /// `trip_stops.total_kg` with `proposed.totalKg` ([correctionMixed]).
  Future<List<OutboundRow>> correctionLines(String requestId) => _all(
    '''
    SELECT json_extract(l.value, '\$.item_name') AS item_name, json_extract(l.value, '\$.quantity') AS now_qty,
      (SELECT json_extract(p.value, '\$.quantity') FROM json_each(r.proposed, '\$.lines') p
       WHERE json_extract(p.value, '\$.itemId') = json_extract(l.value, '\$.item_id')) AS asked_qty
    FROM outbound_requests r
    JOIN trip_stops s ON s.id = r.due_pickup_id, json_each(s.entry_lines) l
    WHERE r.id = :id''',
    {'id': requestId},
  );

  Future<OutboundRow?> correctionMixed(String requestId) => _one(
    '''
    SELECT s.total_kg AS now_kg, json_extract(r.proposed, '\$.totalKg') AS asked_kg
    FROM outbound_requests r JOIN trip_stops s ON s.id = r.due_pickup_id
    WHERE r.id = :id''',
    {'id': requestId},
  );

  /// The extra pickups waiting for you (Extra pickup requests in the drawer).
  Future<List<OutboundRow>> extraPickupRequests() => _all('''
    SELECT p.id, p.source_id, p.source_name, p.due_date, p.window_start, p.window_end,
           p.expected_qty_kg, p.note, p.requested_by_name, p.sync_state
    FROM due_pickups p
    WHERE p.pickup_supervisor_id = :me AND p.status = 'REQUESTED'
    ORDER BY p.due_date, p.window_start''');

  // ------------------------------------------------------------ My requests

  /// My requests (also the IEC's). [tab]: ALL | WAITING | APPROVED | DECLINED.
  Future<List<OutboundRow>> myRequests({String tab = 'ALL'}) => _all(
    '''
    SELECT r.*, (r.status = 'WAITING' AND (r.last_follow_up_at IS NULL OR date(r.last_follow_up_at, '+5 hours',
        '+30 minutes') < date('now', '+5 hours', '+30 minutes'))) AS can_follow_up,
      (r.status = 'WAITING' AND r.raised_as = 'IEC' AND r.send_to = 'SUPERVISOR' AND r.follow_ups >= 3) AS can_escalate
    FROM outbound_requests r
    WHERE r.raised_by_id = :me AND (:tab = 'ALL' OR r.status = :tab)
    ORDER BY r.status = 'WAITING' DESC, r.raised_at DESC''',
    {'tab': tab},
  );

  Future<List<OutboundRow>> myRequestCounts() => _all(
    'SELECT status, COUNT(*) AS n FROM outbound_requests WHERE raised_by_id = :me GROUP BY status',
  );

  // ---------------------------------------------------------- Pickup points

  /// The supervisor's pickup points, by area.
  Future<List<OutboundRow>> supervisorPickupPoints() => _all('''
    SELECT s.id, s.number, s.name, s.status, s.area_name, s.material_mode, s.contact_phone,
           (SELECT summary FROM pickup_schedules p WHERE p.source_id = s.id AND p.effective_from <= :today
             ORDER BY p.effective_from DESC LIMIT 1) AS schedule_summary
    FROM outbound_sources s
    WHERE s.pickup_supervisor_id = :me AND s.status IN ('ACTIVE', 'PAUSED')
    ORDER BY s.area_name, s.name''');

  /// One pickup point with its route and Payment card (IEC: no dues or route).
  Future<OutboundRow?> pickupPointDetail(String sourceId) => _one(
    '''
    SELECT o.*,
      (SELECT r.name FROM pickup_route_stops rs JOIN pickup_routes r ON r.id = rs.route_id
        WHERE rs.source_id = o.id) AS route_name,
      d.earned, d.paid, d.balance AS owed, d.next_due_on, d.last_paid_on
    FROM outbound_sources o
    LEFT JOIN source_dues d ON d.source_id = o.id
    WHERE o.id = :source_id''',
    {'source_id': sourceId},
  );

  /// A Sorted pickup point's items, in form order (Pickup point detail).
  Future<List<OutboundRow>> sourceItems(String sourceId) => _all(
    '''
    SELECT i.id, i.name, i.unit_code
    FROM outbound_source_items si JOIN items i ON i.id = si.item_id
    WHERE si.source_id = :source_id
    ORDER BY si.sort_order''',
    {'source_id': sourceId},
  );

  /// The schedule in force today: the latest started, else the first one.
  Future<OutboundRow?> scheduleInForce(String sourceId) async =>
      await _one(
        '''
        SELECT * FROM pickup_schedules WHERE source_id = :id AND effective_from <= :today
        ORDER BY effective_from DESC LIMIT 1''',
        {'id': sourceId},
      ) ??
      await _one(
        'SELECT * FROM pickup_schedules WHERE source_id = :id ORDER BY effective_from ASC LIMIT 1',
        {'id': sourceId},
      );

  /// The payment terms in force today.
  Future<OutboundRow?> paymentTermsInForce(String sourceId) => _one(
    '''
    SELECT * FROM source_payment_terms WHERE source_id = :id AND effective_from <= :today
    ORDER BY effective_from DESC LIMIT 1''',
    {'id': sourceId},
  );

  /// Every payment terms version with its item rates.
  Future<List<OutboundRow>> paymentTermsVersions(String sourceId) => _all(
    '''
    SELECT t.*, (SELECT json_group_array(json_object('item_id', r.item_id, 'rate_per_kg', r.rate_per_kg))
                 FROM source_item_rates r WHERE r.terms_id = t.id) AS item_rates
    FROM source_payment_terms t WHERE t.source_id = :id ORDER BY t.effective_from''',
    {'id': sourceId},
  );

  /// Its next pickups (Upcoming pickups, a route's Next 7 days).
  Future<List<OutboundRow>> upcomingPickups(String sourceId) => _all(
    '''
    SELECT p.id, p.origin, p.status, p.due_date, p.window_start, p.window_end, p.moved_from,
           p.skip_reasons, p.skip_note, p.cancel_reason, p.requested_by_name, p.decline_reason, p.sync_state
    FROM due_pickups p
    WHERE p.source_id = :source_id AND p.due_date >= :today AND p.status <> 'CANCELLED'
    ORDER BY p.due_date, p.slot_index
    LIMIT 14''',
    {'source_id': sourceId},
  );

  Future<List<OutboundRow>> sourcePauses(String sourceId) => _all(
    '''
    SELECT id, from_date, to_date, reason, cancelled_at FROM source_pauses
    WHERE source_id = :source_id ORDER BY from_date DESC''',
    {'source_id': sourceId},
  );

  /// Whether a pause covers [day] ("Paused till …").
  Future<bool> isPausedOn(String sourceId, String day) async {
    final row = await _one(
      '''
      SELECT EXISTS (SELECT 1 FROM source_pauses
        WHERE source_id = :source_id AND cancelled_at IS NULL
          AND from_date <= :day AND (:day <= to_date OR to_date IS NULL)) AS paused''',
      {'source_id': sourceId, 'day': day},
    );
    return row?['paused'] == 1;
  }

  /// Home · Pickup points: the supervisor's Active and Paused pickup points
  /// by `pickup_category` (DAILY, WEEKLY, BI_WEEKLY, MONTHLY, ON_CALL,
  /// ONE_TIME; NULL: no schedule).
  Future<List<OutboundRow>> pickupCategoryCounts() => _all('''
    SELECT pickup_category, COUNT(*) AS n
    FROM outbound_sources
    WHERE pickup_supervisor_id = :me AND status IN ('ACTIVE', 'PAUSED')
    GROUP BY pickup_category''');

  // -------------------------------------------------------------- Unassigned

  /// Your Active and Paused pickup points on no active route.
  Future<List<OutboundRow>> unassignedSources() => _all('''
    SELECT s.id, s.name, s.number, s.area_id
    FROM outbound_sources s
    WHERE s.pickup_supervisor_id = :me AND s.status IN ('ACTIVE', 'PAUSED')
      AND NOT EXISTS (SELECT 1 FROM pickup_route_stops rs JOIN pickup_routes r ON r.id = rs.route_id
                      WHERE rs.source_id = s.id AND r.is_active = 1)
    ORDER BY s.name''');

  /// Today's and tomorrow's DUE pickups on no trip.
  Future<List<OutboundRow>> unassignedPickups() => _all(
    '''
    SELECT p.id, p.source_id, p.source_name, p.due_date, p.window_start, p.window_end, p.origin
    FROM due_pickups p
    WHERE p.pickup_supervisor_id = :me AND p.status = 'DUE' AND p.trip_id IS NULL
      AND p.due_date IN (:today, :tomorrow)
    ORDER BY p.due_date, p.window_start IS NULL, p.window_start, p.source_name''',
  );

  // ------------------------------------------------------------------ Routes

  /// The route cards.
  Future<List<OutboundRow>> routeCards() => _all('''
    SELECT r.id, r.name, r.is_active, r.sync_state,
           w.name AS warehouse_name, sh.name AS shift_name, sh.start_time, sh.end_time,
           COALESCE(v.plate_number, r.rented_vehicle_number) AS vehicle,
           r.rented_vehicle_number IS NOT NULL AS rented,
           COALESCE(d.name, r.rented_driver_name) AS driver_name, l.name AS labour_name,
           (SELECT COUNT(*) FROM pickup_route_stops rs WHERE rs.route_id = r.id) AS sources
    FROM pickup_routes r
    JOIN warehouses w ON w.id = r.warehouse_id
    JOIN warehouse_shifts sh ON sh.id = r.shift_id
    LEFT JOIN outbound_vehicles v ON v.id = r.vehicle_id
    LEFT JOIN warehouse_drivers d ON d.user_id = r.driver_id AND d.warehouse_id = r.warehouse_id
    LEFT JOIN warehouse_labour l ON l.id = r.labour_id
    WHERE r.supervisor_id = :me
    ORDER BY r.is_active DESC, sh.start_time, r.name''');

  /// One route as saved (Assign to a route re-saves the whole route).
  Future<OutboundRow?> route(String routeId) => _one(
    'SELECT * FROM pickup_routes WHERE id = :route_id',
    {'route_id': routeId},
  );

  /// One route's pickup points, in order.
  Future<List<OutboundRow>> routeSources(String routeId) => _all(
    '''
    SELECT rs.stop_order, s.id, s.name, s.number, s.status, s.address
    FROM pickup_route_stops rs JOIN outbound_sources s ON s.id = rs.source_id
    WHERE rs.route_id = :route_id
    ORDER BY rs.stop_order''',
    {'route_id': routeId},
  );

  /// Add a new route: shifts, with "ends next day".
  Future<List<OutboundRow>> warehouseShiftOptions(String warehouseId) => _all(
    '''
    SELECT id, name, start_time, end_time, (end_time < start_time) AS ends_next_day
    FROM warehouse_shifts
    WHERE warehouse_id = :warehouse_id AND is_active = 1
    ORDER BY sort_order, start_time''',
    {'warehouse_id': warehouseId},
  );

  Future<List<OutboundRow>> warehouseVanOptions(String warehouseId) => _all(
    '''
    SELECT id, plate_number, type_name, capacity_kg
    FROM outbound_vehicles
    WHERE warehouse_id = :warehouse_id AND is_active = 1
    ORDER BY plate_number''',
    {'warehouse_id': warehouseId},
  );

  Future<List<OutboundRow>> warehouseDriverOptions(String warehouseId) => _all(
    '''
    SELECT user_id, number, name, phone, id_number, photo_url, id_proof_url FROM warehouse_drivers
    WHERE warehouse_id = :warehouse_id AND is_active = 1
    ORDER BY name''',
    {'warehouse_id': warehouseId},
  );

  Future<List<OutboundRow>> warehouseLabourOptions(String warehouseId) => _all(
    '''
    SELECT id, number, name, phone, id_number, photo_url, id_proof_url FROM warehouse_labour
    WHERE warehouse_id = :warehouse_id AND is_active = 1
    ORDER BY name''',
    {'warehouse_id': warehouseId},
  );

  // --------------------------------------------------- Route estimate inputs

  /// Where the trip starts and when.
  Future<OutboundRow?> routeEstimateStart(String routeId) => _one(
    '''
    SELECT w.lat, w.lng, sh.start_time
    FROM pickup_routes r
    JOIN warehouses w ON w.id = r.warehouse_id
    JOIN warehouse_shifts sh ON sh.id = r.shift_id
    WHERE r.id = :route_id''',
    {'route_id': routeId},
  );

  /// The stops in order, with the pickup windows of the schedule in force.
  Future<List<OutboundRow>> routeEstimateStops(String routeId) => _all(
    '''
    SELECT o.id, o.name, o.lat, o.lng,
      COALESCE(
        (SELECT ps.slots FROM pickup_schedules ps
          WHERE ps.source_id = o.id AND ps.effective_from <= :today
          ORDER BY ps.effective_from DESC LIMIT 1),
        (SELECT ps.slots FROM pickup_schedules ps
          WHERE ps.source_id = o.id ORDER BY ps.effective_from LIMIT 1),
        '[]') AS slots
    FROM pickup_route_stops rs
    JOIN outbound_sources o ON o.id = rs.source_id
    WHERE rs.route_id = :route_id
    ORDER BY rs.stop_order''',
    {'route_id': routeId},
  );

  Future<List<OutboundRow>> routeEstimateSettings() => _all(
    '''
    SELECT key, value FROM sync_meta
    WHERE key IN ('outbound_speed_kmh', 'outbound_minutes_per_stop', 'outbound_off_route_km')''',
  );

  // -------------------------------------------------------------- Trips plan

  /// Trips plan, Today or Tomorrow ([day]).
  Future<List<OutboundRow>> tripsPlan(String day) => _all(
    '''
    SELECT t.id, t.route_name, t.shift_name, t.shift_start, t.shift_end, t.status, t.changed_for_today,
      t.vehicle_kind, COALESCE(t.vehicle_plate, t.rented_vehicle_number) AS vehicle, t.transporter_name,
      COALESCE(t.driver_name, t.rented_driver_name) AS driver_name, t.labour_name, t.started_at,
      (SELECT COUNT(*) FROM trip_stops s WHERE s.trip_id = t.id) AS stops,
      (SELECT COUNT(*) FROM trip_stops s WHERE s.trip_id = t.id AND s.status = 'COLLECTED') AS collected,
      (SELECT COALESCE(SUM(json_extract(l.value, '\$.quantity')), 0)
         FROM trip_stops s, json_each(s.entry_lines) l
        WHERE s.trip_id = t.id AND s.status = 'COLLECTED'
          AND json_extract(l.value, '\$.unit') = 'KG') AS kg
    FROM pickup_trips t
    WHERE t.trip_date = :day AND t.status <> 'CANCELLED'
    ORDER BY t.shift_start, t.route_name''',
    {'day': day},
  );

  /// "Daily 5 · Weekly 3" on each card.
  Future<List<OutboundRow>> tripCategoryCounts(String tripId) => _all(
    '''
    SELECT o.pickup_category, COUNT(*) AS stops
    FROM trip_stops s JOIN outbound_sources o ON o.id = s.source_id
    WHERE s.trip_id = :trip_id
    GROUP BY o.pickup_category''',
    {'trip_id': tripId},
  );

  // ------------------------------------------------------------ Trip details

  /// The trips of a day, cancelled ones last.
  Future<List<OutboundRow>> supervisorTripsOfDay(String day) => _all(
    '''
    SELECT t.id, t.number, t.route_name, t.shift_name, t.shift_start, t.shift_end, t.status,
           t.changed_for_today, t.cancel_reason, t.sync_state,
           COALESCE(t.vehicle_plate, t.rented_vehicle_number) AS vehicle,
           COALESCE(t.driver_name, t.rented_driver_name) AS driver_name, t.labour_name,
           t.vehicle_kind, COALESCE(t.driver_phone, t.rented_driver_phone) AS driver_phone,
           (SELECT COUNT(*) FROM trip_stops ts WHERE ts.trip_id = t.id) AS stops
    FROM pickup_trips t
    WHERE t.supervisor_id = :me AND t.trip_date = :day
    ORDER BY t.status = 'CANCELLED', t.shift_start, t.route_name''',
    {'day': day},
  );

  /// A trip's stops, each with its display state:
  /// PENDING | AT_GATE | COLLECTED | ZERO_KG | MISSED | SOURCE_CANCELLED.
  Future<List<OutboundRow>> tripStopsWithState(String tripId) => _all(
    '''
    SELECT s.*,
      CASE s.status
        WHEN 'AT_GATE'       THEN 'AT_GATE'
        WHEN 'COLLECTED'     THEN 'COLLECTED'
        WHEN 'NOT_COLLECTED' THEN 'ZERO_KG'
        WHEN 'SOURCE_CANCELLED' THEN 'SOURCE_CANCELLED'
        ELSE CASE WHEN s.due_date < :today OR t.status IN ('AT_WAREHOUSE', 'CHECKING', 'APPROVED')
                  THEN 'MISSED' ELSE 'PENDING' END
      END AS display_state
    FROM trip_stops s
    JOIN pickup_trips t ON t.id = s.trip_id
    WHERE s.trip_id = :trip_id
    ORDER BY s.stop_order''',
    {'trip_id': tripId},
  );

  /// Cancelled by source ahead of the day (these left the trip).
  Future<List<OutboundRow>> tripCancelledBySource(String tripId) => _all(
    '''
    SELECT p.id, p.source_id, p.source_name, p.source_cancel_reason, p.source_cancel_note,
      p.source_cancelled_by_name, p.source_cancelled_at
    FROM pickup_trips t
    JOIN pickup_route_stops rs ON rs.route_id = t.route_id
    JOIN due_pickups p ON p.source_id = rs.source_id AND p.due_date = t.trip_date
    WHERE t.id = :trip_id AND p.status = 'SOURCE_CANCELLED' AND (p.trip_id IS NULL OR p.trip_id <> t.id)
    ORDER BY p.source_cancelled_at''',
    {'trip_id': tripId},
  );

  /// Inactive: the route's sources paused ("Paused till …") or switched off.
  Future<List<OutboundRow>> tripInactiveSources(String tripId) => _all(
    '''
    SELECT o.id, o.name, o.number, o.status,
      (SELECT sp.to_date FROM source_pauses sp
        WHERE sp.source_id = o.id AND sp.cancelled_at IS NULL
          AND sp.from_date <= t.trip_date AND (sp.to_date IS NULL OR sp.to_date >= t.trip_date)
        ORDER BY sp.from_date DESC LIMIT 1) AS paused_until
    FROM pickup_trips t
    JOIN pickup_route_stops rs ON rs.route_id = t.route_id
    JOIN outbound_sources o ON o.id = rs.source_id
    WHERE t.id = :trip_id AND o.status IN ('PAUSED', 'ENDED')
    ORDER BY rs.stop_order''',
    {'trip_id': tripId},
  );

  /// A day's pickups, on a trip or not, with Missed worked out.
  Future<List<OutboundRow>> pickupsOfDay(String day) => _all(
    '''
    SELECT p.id, p.source_id, p.source_name, p.origin, p.status, p.due_date, p.window_start, p.window_end,
           p.moved_from, p.expected_qty_kg, p.skip_reasons, p.skip_note, p.cancel_reason, p.trip_id, p.sync_state,
           (p.status IN ('DUE', 'PLANNED')
            AND (p.due_date < :today OR t.status IN ('AT_WAREHOUSE', 'CHECKING', 'APPROVED'))) AS missed
    FROM due_pickups p
    LEFT JOIN pickup_trips t ON t.id = p.trip_id
    WHERE p.pickup_supervisor_id = :me AND p.due_date = :day
      AND p.status IN ('DUE', 'REQUESTED', 'SKIPPED', 'PLANNED')
    ORDER BY p.window_start IS NULL, p.window_start, p.source_name''',
    {'day': day},
  );

  /// Stop details (also the driver's Stop detail; the pickup point columns
  /// are NULL on a driver's phone).
  Future<OutboundRow?> stopDetail(String stopId) => _one(
    '''
    SELECT s.*, t.number AS trip_number, t.route_name, t.status AS trip_status, t.driver_name,
      o.pickup_category, o.iec_owner_name, o.iec_owner_phone,
      (SELECT ps.summary FROM pickup_schedules ps
        WHERE ps.source_id = s.source_id AND ps.effective_from <= :today
        ORDER BY ps.effective_from DESC LIMIT 1) AS schedule_summary
    FROM trip_stops s
    JOIN pickup_trips t ON t.id = s.trip_id
    LEFT JOIN outbound_sources o ON o.id = s.source_id
    WHERE s.id = :stop_id''',
    {'stop_id': stopId},
  );

  // ------------------------------------------------- Change driver or labour

  /// Pickups that can be added to a trip (Change for today).
  Future<List<OutboundRow>> pickupsAddableToTrip({
    required String tripId,
    required String tripDate,
  }) => _all(
    '''
    SELECT p.id, p.source_id, p.source_name, p.window_start, p.window_end, p.trip_id,
           t.route_name AS on_trip
    FROM due_pickups p LEFT JOIN pickup_trips t ON t.id = p.trip_id
    WHERE p.pickup_supervisor_id = :me AND p.due_date = :trip_date
      AND (p.status = 'DUE' OR (p.status = 'PLANNED' AND t.status = 'PLANNED' AND p.trip_id <> :trip_id))
    ORDER BY p.trip_id IS NOT NULL, p.window_start IS NULL, p.window_start, p.source_name''',
    {'trip_id': tripId, 'trip_date': tripDate},
  );

  /// Vans of the trip's warehouse not on another trip that day and shift.
  /// Online, `GET /pickup-trips/{id}/free-staff` sees other supervisors' too.
  Future<List<OutboundRow>> freeVans(String tripId) => _all(
    '''
    SELECT v.id, v.plate_number, v.number
    FROM pickup_trips t
    JOIN outbound_vehicles v ON v.warehouse_id = t.warehouse_id AND v.is_active = 1
    WHERE t.id = :trip_id
      AND v.id NOT IN (SELECT o.vehicle_id FROM pickup_trips o
                       WHERE o.trip_date = t.trip_date AND o.shift_id = t.shift_id
                         AND o.status <> 'CANCELLED' AND o.id <> t.id AND o.vehicle_id IS NOT NULL)
    ORDER BY v.plate_number''',
    {'trip_id': tripId},
  );

  Future<List<OutboundRow>> freeDrivers(String tripId) => _all(
    '''
    SELECT d.user_id, d.name, d.phone
    FROM pickup_trips t
    JOIN warehouse_drivers d ON d.warehouse_id = t.warehouse_id AND d.is_active = 1
    WHERE t.id = :trip_id
      AND d.user_id NOT IN (SELECT o.driver_id FROM pickup_trips o
                            WHERE o.trip_date = t.trip_date AND o.shift_id = t.shift_id
                              AND o.status <> 'CANCELLED' AND o.id <> t.id AND o.driver_id IS NOT NULL)
    ORDER BY d.name''',
    {'trip_id': tripId},
  );

  Future<List<OutboundRow>> freeLabour(String tripId) => _all(
    '''
    SELECT l.id, l.name, l.phone
    FROM pickup_trips t
    JOIN warehouse_labour l ON l.warehouse_id = t.warehouse_id AND l.is_active = 1
    WHERE t.id = :trip_id
      AND l.id NOT IN (SELECT o.labour_id FROM pickup_trips o
                       WHERE o.trip_date = t.trip_date AND o.shift_id = t.shift_id
                         AND o.status <> 'CANCELLED' AND o.id <> t.id AND o.labour_id IS NOT NULL)
    ORDER BY l.name''',
    {'trip_id': tripId},
  );

  /// The trips stops can move to (another of my Planned trips, the same day
  /// and warehouse).
  Future<List<OutboundRow>> moveStopsTargets(String tripId) => _all(
    '''
    SELECT t.id, t.number, t.route_name, t.shift_name, t.shift_start,
      COALESCE(t.vehicle_plate, t.rented_vehicle_number) AS vehicle,
      COALESCE(t.driver_name, t.rented_driver_name) AS driver_name,
      (SELECT COUNT(*) FROM trip_stops s WHERE s.trip_id = t.id) AS stops
    FROM pickup_trips f
    JOIN pickup_trips t ON t.trip_date = f.trip_date AND t.warehouse_id = f.warehouse_id
    WHERE f.id = :trip_id AND t.id <> f.id AND t.status = 'PLANNED' AND t.supervisor_id = :me
    ORDER BY t.shift_start, t.route_name''',
    {'trip_id': tripId},
  );

  // ------------------------------------------------- Driver not using app

  /// Trips not started 30 minutes after their shift began.
  Future<List<OutboundRow>> driverNotUsingApp() => _all(
    '''
    SELECT t.id, t.number, t.route_name, t.shift_start, t.vehicle_kind,
      COALESCE(t.driver_name, t.rented_driver_name) AS driver_name,
      COALESCE(t.driver_phone, t.rented_driver_phone) AS driver_phone
    FROM pickup_trips t
    WHERE t.supervisor_id = :me AND t.trip_date = :today AND t.status = 'PLANNED' AND t.started_at IS NULL
      AND :now_hhmm >= strftime('%H:%M', t.shift_start, '+30 minutes')''',
    {'now_hhmm': clock.nowHhmm},
  );

  // ------------------------------------------------------------------ Missed

  /// Missed: the day is over, or the trip reached the warehouse unrecorded.
  Future<List<OutboundRow>> missedPickups() => _all('''
    SELECT p.id, p.source_id, p.source_name, p.due_date, p.window_start, p.window_end, p.trip_id
    FROM due_pickups p
    LEFT JOIN pickup_trips t ON t.id = p.trip_id
    WHERE p.pickup_supervisor_id = :me AND p.status IN ('DUE', 'PLANNED')
      AND (p.due_date < :today OR t.status IN ('AT_WAREHOUSE', 'CHECKING', 'APPROVED'))
    ORDER BY p.due_date DESC''');

  // ------------------------------------------------------------------ Issues

  /// Open first, then escalated, then resolved (also the driver's list).
  Future<List<OutboundRow>> issues() => _all(
    '''
    SELECT * FROM trip_issues
    WHERE (supervisor_id = :me OR raised_by_id = :me)
    ORDER BY CASE status WHEN 'OPEN' THEN 0 WHEN 'ESCALATED' THEN 1 ELSE 2 END, raised_at DESC''',
  );

  // ------------------------------------------------------------------- Flags

  Future<List<OutboundRow>> flags() => _all('''
    SELECT f.id, f.type, f.source_id, f.due_pickup_id, f.message, f.done_at, f.created_at, f.sync_state
    FROM supervisor_flags f
    ORDER BY f.done_at IS NOT NULL, f.updated_at DESC
    LIMIT 100''');

  Future<int> openFlagCount() async =>
      ((await _one(
            'SELECT COUNT(*) AS open_flags FROM supervisor_flags WHERE done_at IS NULL',
          ))?['open_flags']
          as int?) ??
      0;

  // --------------------------------------------------------- Drivers & Labour

  /// [filter]: ALL | ACTIVE | INACTIVE (the Deactivated Driver Directory).
  Future<List<OutboundRow>> driverDirectory({String filter = 'ALL'}) => _all(
    '''
    SELECT d.user_id, d.number, d.name, d.phone, d.is_active, d.id_number, d.photo_url, d.id_proof_url,
      w.id AS warehouse_id, w.name AS warehouse_name
    FROM warehouse_drivers d JOIN warehouses w ON w.id = d.warehouse_id
    WHERE (:filter = 'ALL' OR d.is_active = (:filter = 'ACTIVE'))
    ORDER BY d.is_active DESC, d.name, w.name''',
    {'filter': filter},
  );

  Future<List<OutboundRow>> labourDirectory({String filter = 'ALL'}) => _all(
    '''
    SELECT l.id, l.number, l.name, l.phone, l.is_active, l.id_number, l.photo_url, l.id_proof_url,
      w.name AS warehouse_name
    FROM warehouse_labour l JOIN warehouses w ON w.id = l.warehouse_id
    WHERE (:filter = 'ALL' OR l.is_active = (:filter = 'ACTIVE'))
    ORDER BY l.is_active DESC, l.name''',
    {'filter': filter},
  );

  // ----------------------------------------------------------- Cash & Payments

  Future<double> cashInHand() async =>
      ((await _one(
                "SELECT CAST(value AS REAL) AS balance FROM sync_meta WHERE key = 'outbound_cash_balance'",
              ))?['balance']
              as num?)
          ?.toDouble() ??
      0;

  Future<List<OutboundRow>> cashBook() =>
      _all('SELECT * FROM supervisor_cash_book ORDER BY created_at DESC');

  /// What each pickup point is owed (Pickup points to pay).
  Future<List<OutboundRow>> sourceDues() => _all('''
    SELECT o.id, o.name, o.number, d.earned, d.paid, d.balance, d.next_due_on, d.last_paid_on
    FROM source_dues d JOIN outbound_sources o ON o.id = d.source_id
    ORDER BY d.balance DESC, o.name''');

  Future<List<OutboundRow>> cashRequests() => _all('''
    SELECT id, amount, reason, status, approved_amount, rejection_reason, decided_by_name, decided_at,
      created_at, sync_state
    FROM supervisor_cash_requests
    ORDER BY status = 'PENDING' DESC, created_at DESC''');

  Future<List<OutboundRow>> sourcePayments() => _all('''
    SELECT p.id, p.amount, p.method, p.reference, p.photo_url, p.note, p.paid_on, p.sync_state,
      o.name AS source_name, o.number AS source_number
    FROM source_payments p LEFT JOIN outbound_sources o ON o.id = p.source_id
    ORDER BY p.paid_on DESC, p.created_at DESC''');

  // ================================================================= Driver

  /// Today's trips with their counts and what they collected.
  Future<List<OutboundRow>> driverHomeTrips() => _all('''
    SELECT t.*,
      (SELECT COUNT(*) FROM trip_stops s WHERE s.trip_id = t.id) AS stops,
      (SELECT COUNT(*) FROM trip_stops s WHERE s.trip_id = t.id AND s.status = 'COLLECTED')        AS collected,
      (SELECT COUNT(*) FROM trip_stops s WHERE s.trip_id = t.id AND s.status = 'PLANNED')          AS pending,
      (SELECT COUNT(*) FROM trip_stops s WHERE s.trip_id = t.id AND s.status = 'NOT_COLLECTED')    AS zero_kg,
      (SELECT COUNT(*) FROM trip_stops s WHERE s.trip_id = t.id AND s.status = 'SOURCE_CANCELLED') AS cancelled,
      (SELECT COUNT(*) FROM trip_stops s WHERE s.trip_id = t.id AND s.status = 'AT_GATE')          AS at_gate,
      (SELECT COALESCE(SUM(json_extract(j.value, '\$.quantity')), 0)
         FROM trip_stops s, json_each(s.entry_lines) j
        WHERE s.trip_id = t.id AND json_extract(j.value, '\$.unit') = 'KG')                            AS collected_kg
    FROM pickup_trips t
    WHERE t.driver_id = :me AND t.trip_date = :today AND t.status <> 'CANCELLED'
    ORDER BY t.shift_start''');

  /// One of the driver's trips with the Home counts (Trip stops header,
  /// Trip summary). Not limited to today.
  Future<OutboundRow?> driverTrip(String tripId) => _one(
    '''
    SELECT t.*,
      (SELECT COUNT(*) FROM trip_stops s WHERE s.trip_id = t.id) AS stops,
      (SELECT COUNT(*) FROM trip_stops s WHERE s.trip_id = t.id AND s.status = 'COLLECTED')        AS collected,
      (SELECT COUNT(*) FROM trip_stops s WHERE s.trip_id = t.id AND s.status = 'PLANNED')          AS pending,
      (SELECT COUNT(*) FROM trip_stops s WHERE s.trip_id = t.id AND s.status = 'NOT_COLLECTED')    AS zero_kg,
      (SELECT COUNT(*) FROM trip_stops s WHERE s.trip_id = t.id AND s.status = 'SOURCE_CANCELLED') AS cancelled,
      (SELECT COUNT(*) FROM trip_stops s WHERE s.trip_id = t.id AND s.status = 'AT_GATE')          AS at_gate,
      (SELECT COALESCE(SUM(json_extract(j.value, '\$.quantity')), 0)
         FROM trip_stops s, json_each(s.entry_lines) j
        WHERE s.trip_id = t.id AND json_extract(j.value, '\$.unit') = 'KG')                            AS collected_kg
    FROM pickup_trips t
    WHERE t.id = :trip_id''',
    {'trip_id': tripId},
  );

  /// A stop with everything recorded at it (Stop detail, Collection record).
  Future<OutboundRow?> driverStop(String stopId) =>
      _one('SELECT * FROM trip_stops WHERE id = :stop_id', {'stop_id': stopId});

  /// The next stop of a trip: the first still open.
  Future<OutboundRow?> nextStop(String tripId) => _one(
    "SELECT * FROM trip_stops WHERE trip_id = :trip_id AND status = 'PLANNED' ORDER BY stop_order LIMIT 1",
    {'trip_id': tripId},
  );

  /// Today's and tomorrow's trips (with the labourer to call).
  Future<List<OutboundRow>> driverUpcomingTrips() => _all('''
    SELECT t.id, t.number, t.trip_date, t.route_name, t.warehouse_name, t.shift_name, t.shift_start,
           t.shift_end, t.vehicle_plate, t.labour_name, t.labour_phone, t.status, t.cancel_reason,
           (SELECT COUNT(*) FROM trip_stops ts WHERE ts.trip_id = t.id) AS stops
    FROM pickup_trips t
    WHERE t.driver_id = :me AND t.trip_date IN (:today, :tomorrow)
    ORDER BY t.trip_date, t.shift_start''');

  /// The warehouse to open on (also the Warehouse Incharge's Home).
  Future<OutboundRow?> homeWarehouse() => _one('''
    SELECT w.id, w.name, w.code, w.address
    FROM my_warehouses m
    JOIN warehouses w ON w.id = m.warehouse_id
    ORDER BY m.is_primary DESC, w.name
    LIMIT 1''');

  /// Contact Supervisor: the fixed-point `supervisor_name`, `supervisor_phone`.
  Future<OutboundRow?> contactSupervisor() => _one(
    '''
    SELECT
      (SELECT value FROM sync_meta WHERE key = 'supervisor_name')  AS name,
      (SELECT value FROM sync_meta WHERE key = 'supervisor_phone') AS phone,
      (SELECT value FROM sync_meta WHERE key = 'supervisor_photo_url') AS photo_url''',
  );

  /// One trip's stops, in order, with whether each is still waiting to send.
  Future<List<OutboundRow>> driverTripStops(String tripId) => _all(
    '''
    SELECT s.id, s.stop_order, s.source_name, s.source_address, s.lat, s.lng, s.window_start, s.window_end,
      s.contact_name, s.contact_phone, s.contact_role, s.expected_qty_kg, s.note, s.material_mode,
      s.status, s.outcome, s.total_kg, s.recorded_at,
      EXISTS (SELECT 1 FROM outbox o WHERE o.entity = 'pickup_trips' AND o.entity_id = s.trip_id
                AND o.kind = 'entry' AND json_extract(o.body, '\$.duePickupId') = s.id) AS waiting_to_send
    FROM trip_stops s
    WHERE s.trip_id = :trip_id
    ORDER BY s.stop_order''',
    {'trip_id': tripId},
  );

  /// The stops the phone's position is matched against.
  Future<List<OutboundRow>> stopsToMatch(String tripId) => _all(
    '''
    SELECT s.id, s.stop_order, s.source_name, s.lat, s.lng,
      (SELECT CAST(value AS REAL) FROM sync_meta WHERE key = 'outbound_gps_radius_m') AS radius_m
    FROM trip_stops s
    WHERE s.trip_id = :trip_id AND s.status = 'PLANNED' AND s.lat IS NOT NULL
    ORDER BY s.stop_order''',
    {'trip_id': tripId},
  );

  /// The items of a Sorted form, in form order.
  Future<List<OutboundRow>> sortedFormItems(String stopId) => _all(
    '''
    SELECT i.id, i.name, i.unit_code, i.unit_name, i.image_url, i.colour
    FROM trip_stops s, json_each(s.item_ids) j
    JOIN items i ON i.id = j.value
    WHERE s.id = :stop_id
    ORDER BY j.key''',
    {'stop_id': stopId},
  );

  /// The item a Mixed stop is weighed as; NULL: the server will refuse a
  /// Mixed entry (409 MIXED_ITEM_NOT_SET).
  Future<String?> mixedItemId() async =>
      (await _one(
            "SELECT value FROM sync_meta WHERE key = 'outbound_mixed_item_id'",
          ))?['value']
          as String?;

  /// "Correction requested" while one waits.
  Future<bool> correctionRequested(String stopId) async =>
      (await _one(
        "SELECT EXISTS (SELECT 1 FROM outbound_requests WHERE due_pickup_id = :stop_id AND status = 'WAITING') AS correction_requested",
        {'stop_id': stopId},
      ))?['correction_requested'] ==
      1;

  /// The trip's summary, collected per item.
  Future<List<OutboundRow>> tripSummary(String tripId) => _all(
    '''
    SELECT json_extract(j.value, '\$.item_id') AS item_id, json_extract(j.value, '\$.item_name') AS item_name,
      json_extract(j.value, '\$.unit') AS unit, SUM(json_extract(j.value, '\$.quantity')) AS quantity
    FROM trip_stops s, json_each(s.entry_lines) j
    WHERE s.trip_id = :trip_id
    GROUP BY 1, 2, 3
    ORDER BY 2''',
    {'trip_id': tripId},
  );

  /// Hand over: "Your count (from the stops)", KG items first, then pieces.
  Future<List<OutboundRow>> handOverCount(String tripId) => _all(
    '''
    SELECT json_extract(l.value, '\$.item_name') AS item_name, json_extract(l.value, '\$.unit') AS unit,
      ROUND(SUM(json_extract(l.value, '\$.quantity')), 2) AS quantity
    FROM trip_stops s, json_each(s.entry_lines) l
    WHERE s.trip_id = :id AND s.outcome = 'COLLECTED'
    GROUP BY item_name, unit
    ORDER BY unit, quantity DESC''',
    {'id': tripId},
  );

  /// Waiting for the warehouse, then Received.
  Future<OutboundRow?> handOverStatus(String tripId) => _one(
    '''
    SELECT status, handed_over_at, bag_count, warehouse_name, weighed_at, weighed_by_name,
      gross_kg, empty_kg, net_kg, bags_received, driver_kg, variance_kg, variance_pct,
      CASE WHEN weighed_at IS NULL THEN 'WAITING' ELSE 'RECEIVED' END AS screen
    FROM pickup_trips WHERE id = :id''',
    {'id': tripId},
  );

  /// Help & Support (every outbound role) and the driver's code.
  Future<OutboundRow?> helpAndSupport() => _one(
    '''
    SELECT
      (SELECT value FROM sync_meta WHERE key = 'outbound_support_phone')    AS support_phone,
      (SELECT value FROM sync_meta WHERE key = 'outbound_support_whatsapp') AS support_whatsapp,
      (SELECT value FROM sync_meta WHERE key = 'outbound_driver_code')      AS driver_code''',
  );

  /// Call warehouse: the trip's warehouse in-charge (NULL: hide the button).
  Future<OutboundRow?> callWarehouse(String tripId) => _one(
    '''
    SELECT w.in_charge_name, w.in_charge_phone
    FROM pickup_trips t JOIN warehouses w ON w.id = t.warehouse_id
    WHERE t.id = :trip_id''',
    {'trip_id': tripId},
  );

  /// The offline banner and the logout warning count the outbox.
  Future<int> unsentChanges() async =>
      ((await _one(
            "SELECT COUNT(*) AS n FROM outbox WHERE status IN ('queued', 'sending', 'failed')",
          ))?['n']
          as int?) ??
      0;

  // ========================================================== IEC Executive

  Future<OutboundRow?> iecHomeCounts() => _one(
    '''
    SELECT
      (SELECT COUNT(*) FROM source_leads WHERE created_at >= :week_start)                    AS new_leads_this_week,
      (SELECT COUNT(*) FROM outbound_sources WHERE registered_by_id = :me)                     AS sources_registered,
      (SELECT COUNT(*) FROM outbound_sources WHERE registered_by_id = :me AND status = 'PENDING_APPROVAL') AS waiting_for_approval,
      (SELECT COUNT(*) FROM outbound_sources WHERE registered_by_id = :me AND status = 'REJECTED')         AS rejected''',
    {'week_start': clock.weekStart},
  );

  Future<List<OutboundRow>> followUpsDue() => _all('''
    SELECT id, name, contact_phone, status, next_follow_up_on
    FROM source_leads
    WHERE status IN ('NEW', 'FOLLOW_UP', 'INTERESTED')
      AND next_follow_up_on IS NOT NULL AND next_follow_up_on <= :today
    ORDER BY next_follow_up_on, name''');

  /// The leads, by status ([status] null = All).
  Future<List<OutboundRow>> leads({String? status}) => _all(
    '''
    SELECT l.id, l.name, l.status, l.contact_name, l.contact_phone, l.next_follow_up_on, l.converted_source_id,
      l.sync_state, c.name AS category_name, a.name AS area_name
    FROM source_leads l
    LEFT JOIN source_categories c ON c.id = l.category_id
    LEFT JOIN areas a ON a.id = l.area_id
    WHERE (:status IS NULL OR l.status = :status)
    ORDER BY l.updated_at DESC''',
    {'status': status},
  );

  Future<List<OutboundRow>> leadVisits(String leadId) => _all(
    '''
    SELECT id, visited_at, outcome, note, next_follow_up_on
    FROM lead_visits WHERE lead_id = :lead_id
    ORDER BY visited_at DESC''',
    {'lead_id': leadId},
  );

  /// The area from the pin's PIN code: exactly one row fills it in.
  Future<List<OutboundRow>> areasForPinCode(String pinCode) => _all(
    '''
    SELECT a.id, a.name, c.name AS city_name, a.pickup_supervisor_name
    FROM areas a
    JOIN cities c ON c.id = a.city_id
    WHERE EXISTS (SELECT 1 FROM json_each(a.pin_codes) WHERE json_each.value = :pin_code)
    ORDER BY c.name, a.name''',
    {'pin_code': pinCode},
  );

  Future<List<OutboundRow>> areaPicker() => _all('''
    SELECT a.id, a.name, c.name AS city_name, a.pin_codes, a.pickup_supervisor_name
    FROM areas a
    JOIN cities c ON c.id = a.city_id
    ORDER BY c.name, a.name''');

  Future<List<OutboundRow>> sourceCategoryPicker() =>
      _all('SELECT id, name FROM source_categories ORDER BY name');

  Future<List<OutboundRow>> warehousePicker() =>
      _all('SELECT id, name, code, address FROM warehouses ORDER BY name');

  /// A Sorted pickup point's items (KG only).
  Future<List<OutboundRow>> sortedItemPicker() => _all('''
    SELECT id, name, category_name, unit_name, image_url
    FROM items WHERE is_active = 1 AND unit_code = 'KG'
    ORDER BY category_name, name''');

  /// The pickup points I look after.
  Future<List<OutboundRow>> iecPickupPoints() => _all('''
    SELECT o.id, o.name, o.number, o.status, o.pickup_category, o.area_name,
      o.pickup_supervisor_name, o.pickup_supervisor_phone, o.agreement_status, o.agreement_ends_on,
      (SELECT MAX(p.due_date) FROM due_pickups p
        WHERE p.source_id = o.id AND p.status IN ('COLLECTED', 'NOT_COLLECTED')) AS last_pickup_on,
      (SELECT COUNT(*) FROM due_pickups p
        WHERE p.source_id = o.id AND p.status IN ('DUE', 'PLANNED') AND p.due_date < :today) AS missed
    FROM outbound_sources o
    WHERE o.iec_owner_id = :me
      AND o.status IN ('ACTIVE', 'PAUSED')
    ORDER BY o.name''');

  /// The pickup points I registered, by status ([status] null = All).
  Future<List<OutboundRow>> iecRegisteredSources({String? status}) => _all(
    '''
    SELECT s.id, s.number, s.name, s.status, s.category_name, s.area_name, s.pickup_supervisor_name,
           s.rejection_reason, s.sync_state,
           (SELECT summary FROM pickup_schedules p WHERE p.source_id = s.id
             ORDER BY (p.effective_from <= :today) DESC,
                      CASE WHEN p.effective_from <= :today THEN p.effective_from END DESC,
                      p.effective_from ASC LIMIT 1) AS schedule_summary
    FROM outbound_sources s
    WHERE s.registered_by_id = :me AND (:status IS NULL OR s.status = :status)
    ORDER BY s.updated_at DESC''',
    {'status': status},
  );

  /// The extra pickups I asked for, with their answers.
  Future<List<OutboundRow>> iecExtraPickups() => _all('''
    SELECT p.id, p.source_name, p.due_date, p.window_start, p.window_end, p.status,
           p.decline_reason, p.decided_at, p.sync_state
    FROM due_pickups p
    WHERE p.origin = 'EXTRA' AND p.requested_by_id = :me
    ORDER BY p.due_date DESC''');

  // ===================================================== Warehouse Incharge

  /// [tab]: ARRIVING | AT_WAREHOUSE | APPROVED.
  Future<List<OutboundRow>> warehouseTrips(String tab) => _all(
    '''
    SELECT t.id, t.number, t.route_name, t.trip_date, t.status, t.shift_name,
      COALESCE(t.vehicle_plate, t.rented_vehicle_number) AS vehicle, t.driver_name, t.driver_phone,
      t.started_at, t.handed_over_at, t.bag_count, t.net_kg, t.driver_kg, t.variance_kg, t.variance_pct,
      t.variance_flagged, t.sent_back_note,
      (SELECT COUNT(*) FROM trip_stops s WHERE s.trip_id = t.id AND s.status = 'AT_GATE') AS at_gate
    FROM pickup_trips t
    WHERE (:tab = 'ARRIVING' AND t.status IN ('PLANNED', 'ON_ROUTE') AND t.trip_date = :today)
       OR (:tab = 'AT_WAREHOUSE' AND t.status IN ('AT_WAREHOUSE', 'CHECKING'))
       OR (:tab = 'APPROVED' AND t.status = 'APPROVED')
    ORDER BY t.status = 'CHECKING' DESC, t.handed_over_at, t.shift_start''',
    {'tab': tab},
  );

  /// A trip at the warehouse: its stops, the gate's work first.
  Future<List<OutboundRow>> gateStops(String tripId) => _all(
    '''
    SELECT s.id, s.stop_order, s.source_name, s.status, s.material_mode, s.item_ids, s.outcome, s.entry_method,
      s.total_kg, s.driver_estimate_kg, s.entry_lines, s.photo_urls, s.entry_note, s.recorded_by_name,
      s.status = 'AT_GATE' OR s.entry_method = 'GATE' AS gate_can_edit
    FROM trip_stops s
    WHERE s.trip_id = :id
    ORDER BY s.status = 'AT_GATE' DESC, s.stop_order''',
    {'id': tripId},
  );
}
