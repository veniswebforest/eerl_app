/// Table names of the outbound (Pickup Supervisor, Driver, IEC Executive,
/// Warehouse Incharge) SQLite schema.
///
/// Source: `docs/project-context/outbound-schema-and-queries.md`, "The schema".
/// Outbound shares `sync_meta`, `my_roles`, `outbox`, `outbox_photos`,
/// `photos`, `notifications` and `items` with the fixed-point schema and only
/// adds the tables below.
abstract final class OutboundTables {
  // Reference tables (sent whole as `replace`; no sync_state).
  static const myWarehouses = 'my_warehouses';
  static const warehouses = 'warehouses';
  static const warehouseShifts = 'warehouse_shifts';
  static const outboundVehicles = 'outbound_vehicles';
  static const warehouseDrivers = 'warehouse_drivers';
  static const warehouseLabour = 'warehouse_labour';
  static const cities = 'cities';
  static const areas = 'areas';
  static const sourceCategories = 'source_categories';

  // Pickup points and leads.
  static const outboundSources = 'outbound_sources';
  static const outboundSourceItems = 'outbound_source_items';
  static const pickupSchedules = 'pickup_schedules';
  static const sourcePaymentTerms = 'source_payment_terms';
  static const sourceItemRates = 'source_item_rates';
  static const sourcePauses = 'source_pauses';
  static const sourceLeads = 'source_leads';
  static const leadVisits = 'lead_visits';

  // Pickups.
  static const duePickups = 'due_pickups';

  // Routes and trips.
  static const pickupRoutes = 'pickup_routes';
  static const pickupRouteStops = 'pickup_route_stops';
  static const pickupTrips = 'pickup_trips';
  static const tripStops = 'trip_stops';
  static const supervisorFlags = 'supervisor_flags';

  // Issues and requests.
  static const tripIssues = 'trip_issues';
  static const outboundRequests = 'outbound_requests';

  // Cash.
  static const supervisorCashBook = 'supervisor_cash_book';
  static const supervisorCashRequests = 'supervisor_cash_requests';
  static const sourcePayments = 'source_payments';
  static const sourceDues = 'source_dues';

  /// Every outbound table, in creation order.
  static const values = <String>[
    myWarehouses,
    warehouses,
    warehouseShifts,
    outboundVehicles,
    warehouseDrivers,
    warehouseLabour,
    cities,
    areas,
    sourceCategories,
    outboundSources,
    outboundSourceItems,
    pickupSchedules,
    sourcePaymentTerms,
    sourceItemRates,
    sourcePauses,
    sourceLeads,
    leadVisits,
    duePickups,
    pickupRoutes,
    pickupRouteStops,
    pickupTrips,
    tripStops,
    supervisorFlags,
    tripIssues,
    outboundRequests,
    supervisorCashBook,
    supervisorCashRequests,
    sourcePayments,
    sourceDues,
  ];

  /// Reference tables sent whole as `replace` (Step reference tables).
  /// `my_warehouses` and `source_dues` are filled from `me`, not `tables`.
  static const referenceTables = <String>[
    warehouses,
    warehouseShifts,
    outboundVehicles,
    warehouseDrivers,
    warehouseLabour,
    cities,
    areas,
    sourceCategories,
  ];

  /// Tables the phone writes to; they carry a `sync_state` column.
  static const tablesWithSyncState = <String>{
    outboundSources,
    sourceLeads,
    duePickups,
    pickupRoutes,
    pickupTrips,
    supervisorFlags,
    tripIssues,
    outboundRequests,
    supervisorCashRequests,
    sourcePayments,
  };

  /// The order the scope reset empties them in (children before parents).
  static const scopeResetOrder = <String>[
    myWarehouses,
    warehouses,
    warehouseShifts,
    outboundVehicles,
    warehouseDrivers,
    warehouseLabour,
    cities,
    areas,
    sourceCategories,
    sourceItemRates,
    sourcePaymentTerms,
    pickupSchedules,
    outboundSourceItems,
    sourcePauses,
    outboundSources,
    leadVisits,
    sourceLeads,
    duePickups,
    pickupRouteStops,
    pickupRoutes,
    tripStops,
    pickupTrips,
    supervisorFlags,
    tripIssues,
    outboundRequests,
    supervisorCashBook,
    supervisorCashRequests,
    sourcePayments,
    sourceDues,
  ];

  /// `sync_meta` keys written from `me.outbound` (removed when it is null).
  static const outboundMetaKeys = <String>[
    'outbound_gps_radius_m',
    'outbound_tolerance_pct',
    'outbound_speed_kmh',
    'outbound_minutes_per_stop',
    'outbound_off_route_km',
    'outbound_support_phone',
    'outbound_support_whatsapp',
    'outbound_driver_code',
    'outbound_mixed_item_id',
    'outbound_collection_head_id',
    'outbound_collection_head_name',
    'outbound_collection_head_phone',
  ];

  static const cashBalanceMetaKey = 'outbound_cash_balance';
}
