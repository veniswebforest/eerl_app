import 'database_tables.dart';

abstract final class DatabaseSchema {
  static const createTableQueries = <String>[
    '''
      CREATE TABLE ${DatabaseTables.syncMeta} (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.myRoles} (
        role_key TEXT PRIMARY KEY,
        role_name TEXT NOT NULL,
        modules TEXT NOT NULL
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.myCenters} (
        center_id TEXT PRIMARY KEY,
        is_primary INTEGER NOT NULL,
        agent_number INTEGER,
        slip_date TEXT,
        slip_last_count INTEGER NOT NULL DEFAULT 0
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.centers} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT,
        address TEXT,
        eod_lock_time TEXT
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.items} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category_name TEXT NOT NULL,
        material_type TEXT NOT NULL,
        colour TEXT,
        hsn_code TEXT,
        unit_code TEXT NOT NULL,
        unit_name TEXT NOT NULL
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.centerChannels} (
        center_id TEXT NOT NULL,
        channel TEXT NOT NULL,
        show_price INTEGER NOT NULL,
        takes_payment INTEGER NOT NULL,
        PRIMARY KEY (center_id, channel)
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.centerItems} (
        center_id TEXT NOT NULL,
        channel TEXT NOT NULL,
        item_id TEXT NOT NULL,
        is_selected INTEGER NOT NULL,
        sort_order INTEGER NOT NULL,
        rate REAL,
        sync_state TEXT NOT NULL DEFAULT 'synced',
        PRIMARY KEY (center_id, channel, item_id)
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.vehicleTypes} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.vehicles} (
        id TEXT PRIMARY KEY,
        center_id TEXT,
        plate_number TEXT NOT NULL,
        type_id TEXT NOT NULL,
        type_name TEXT NOT NULL,
        capacity_kg REAL,
        driver_name TEXT,
        is_active INTEGER NOT NULL,
        sync_state TEXT NOT NULL DEFAULT 'synced'
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.mrfPeople} (
        id TEXT PRIMARY KEY,
        center_id TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        id_number TEXT,
        photo_url TEXT,
        is_active INTEGER NOT NULL,
        role TEXT NOT NULL,
        sync_state TEXT NOT NULL DEFAULT 'synced'
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.ragpickers} (
        id TEXT PRIMARY KEY,
        center_id TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        id_number TEXT,
        photo_url TEXT,
        is_active INTEGER NOT NULL,
        sync_state TEXT NOT NULL DEFAULT 'synced'
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.expenseCategories} (
        id TEXT PRIMARY KEY,
        center_id TEXT NOT NULL,
        name TEXT NOT NULL,
        is_active INTEGER NOT NULL
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.centerPeople} (
        user_id TEXT NOT NULL,
        center_id TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        is_agent INTEGER NOT NULL,
        PRIMARY KEY (user_id, center_id)
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.destinations} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.collections} (
        id TEXT PRIMARY KEY,
        center_id TEXT NOT NULL,
        agent_id TEXT NOT NULL,
        agent_name TEXT NOT NULL,
        channel TEXT NOT NULL,
        status TEXT NOT NULL,
        slip_number TEXT,
        collected_at TEXT,
        vehicle_id TEXT,
        mrf_person_id TEXT,
        ragpicker_id TEXT,
        given_by_name TEXT,
        handed_over_by TEXT,
        paid_by TEXT,
        takes_payment INTEGER,
        total_amount REAL,
        handover_photo_urls TEXT NOT NULL DEFAULT '[]',
        rejection_reason TEXT,
        verified_by_name TEXT,
        verified_at TEXT,
        updated_at TEXT NOT NULL,
        sync_state TEXT NOT NULL DEFAULT 'synced'
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.collectionItems} (
        id TEXT PRIMARY KEY,
        collection_id TEXT NOT NULL,
        item_id TEXT NOT NULL,
        qty REAL NOT NULL,
        verified_qty REAL,
        rate REAL,
        amount REAL,
        photo_urls TEXT NOT NULL DEFAULT '[]',
        sort_order INTEGER NOT NULL
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.expenses} (
        id TEXT PRIMARY KEY,
        center_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        user_name TEXT,
        category_id TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        status TEXT NOT NULL,
        number TEXT,
        receipt_photo_urls TEXT NOT NULL DEFAULT '[]',
        decided_by_name TEXT,
        decision_reason TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        sync_state TEXT NOT NULL DEFAULT 'synced'
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.cashRequests} (
        id TEXT PRIMARY KEY,
        center_id TEXT NOT NULL,
        requested_by TEXT NOT NULL,
        requested_by_name TEXT,
        amount REAL NOT NULL,
        reason TEXT,
        status TEXT NOT NULL,
        decided_by_name TEXT,
        decision_note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        sync_state TEXT NOT NULL DEFAULT 'synced'
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.categoryRequests} (
        id TEXT PRIMARY KEY,
        center_id TEXT NOT NULL,
        requested_by TEXT NOT NULL,
        name TEXT NOT NULL,
        reason TEXT,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        sync_state TEXT NOT NULL DEFAULT 'synced'
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.transfers} (
        id TEXT PRIMARY KEY,
        center_id TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        number TEXT,
        destination_id TEXT,
        destination_name TEXT,
        truck_expected_at TEXT,
        fixed_qty REAL,
        estimated_expense REAL,
        vehicle_plate TEXT,
        requested_by TEXT NOT NULL,
        requested_by_name TEXT NOT NULL,
        requested_at TEXT NOT NULL,
        decided_by_name TEXT,
        approved_at TEXT,
        rejection_reason TEXT,
        handed_over_at TEXT,
        photo_urls TEXT NOT NULL DEFAULT '[]',
        updated_at TEXT,
        sync_state TEXT NOT NULL DEFAULT 'synced'
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.transferItems} (
        id TEXT PRIMARY KEY,
        transfer_id TEXT NOT NULL,
        item_id TEXT NOT NULL,
        qty REAL NOT NULL,
        dispatched_qty REAL
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.tasks} (
        id TEXT PRIMARY KEY,
        center_id TEXT,
        assigned_to TEXT NOT NULL,
        assigned_to_name TEXT,
        assigned_by TEXT NOT NULL,
        assigned_by_name TEXT,
        title TEXT NOT NULL,
        description TEXT,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        due_at TEXT,
        completed_at TEXT,
        photo_urls TEXT NOT NULL DEFAULT '[]',
        created_at TEXT NOT NULL,
        sync_state TEXT NOT NULL DEFAULT 'synced'
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.requests} (
        id TEXT PRIMARY KEY,
        center_id TEXT,
        created_by TEXT NOT NULL,
        created_by_name TEXT,
        body TEXT NOT NULL,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        answer TEXT,
        answered_at TEXT,
        photo_urls TEXT NOT NULL DEFAULT '[]',
        created_at TEXT NOT NULL,
        sync_state TEXT NOT NULL DEFAULT 'synced'
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.walletEntries} (
        id TEXT PRIMARY KEY,
        center_id TEXT NOT NULL,
        kind TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        collection_id TEXT,
        expense_id TEXT,
        confirmed_at TEXT,
        created_at TEXT NOT NULL,
        sync_state TEXT NOT NULL DEFAULT 'synced'
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.dayCloses} (
        id TEXT PRIMARY KEY,
        center_id TEXT NOT NULL,
        date TEXT NOT NULL,
        closed_by_name TEXT,
        closed_at TEXT NOT NULL
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.notifications} (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        body TEXT,
        deep_link TEXT,
        created_at TEXT NOT NULL,
        read_at TEXT,
        sync_state TEXT NOT NULL DEFAULT 'synced'
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.centerBalances} (
        center_id TEXT PRIMARY KEY,
        balance REAL NOT NULL,
        updated_at TEXT
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.stock} (
        id TEXT PRIMARY KEY,
        center_id TEXT NOT NULL,
        item_id TEXT NOT NULL,
        stage TEXT NOT NULL,
        qty REAL NOT NULL
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.photos} (
        id TEXT PRIMARY KEY,
        owner_table TEXT NOT NULL,
        owner_id TEXT NOT NULL,
        field TEXT,
        purpose TEXT NOT NULL,
        content_type TEXT NOT NULL,
        local_path TEXT,
        remote_url TEXT UNIQUE,
        status TEXT NOT NULL,
        size_bytes INTEGER,
        created_at TEXT NOT NULL,
        uploaded_at TEXT
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.outbox} (
        seq INTEGER PRIMARY KEY AUTOINCREMENT,
        method TEXT NOT NULL,
        path TEXT NOT NULL,
        body TEXT,
        entity TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        kind TEXT,
        refs TEXT,
        status TEXT NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT,
        next_attempt_at TEXT,
        created_at TEXT NOT NULL
      )
    ''',
    '''
      CREATE TABLE ${DatabaseTables.outboxPhotos} (
        outbox_seq INTEGER NOT NULL,
        photo_id TEXT NOT NULL,
        PRIMARY KEY (outbox_seq, photo_id)
      )
    ''',
  ];

  static const createIndexQueries = <String>[
    'CREATE INDEX ix_collections_agent ON ${DatabaseTables.collections} (agent_id, status, collected_at)',
    'CREATE INDEX ix_collections_review ON ${DatabaseTables.collections} (center_id, status, collected_at)',
    'CREATE INDEX ix_collection_items ON ${DatabaseTables.collectionItems} (collection_id)',
    'CREATE INDEX ix_center_items ON ${DatabaseTables.centerItems} (center_id, channel, sort_order)',
    'CREATE INDEX ix_ragpickers_center ON ${DatabaseTables.ragpickers} (center_id, is_active, name)',
    'CREATE INDEX ix_mrf_people_center ON ${DatabaseTables.mrfPeople} (center_id, is_active, role)',
    'CREATE INDEX ix_vehicles_center ON ${DatabaseTables.vehicles} (center_id, is_active)',
    'CREATE INDEX ix_expenses_center ON ${DatabaseTables.expenses} (center_id, status, created_at)',
    'CREATE INDEX ix_cash_requests ON ${DatabaseTables.cashRequests} (center_id, status)',
    'CREATE INDEX ix_tasks_assignee ON ${DatabaseTables.tasks} (assigned_to, status)',
    'CREATE INDEX ix_tasks_center ON ${DatabaseTables.tasks} (center_id, status)',
    'CREATE INDEX ix_requests_center ON ${DatabaseTables.requests} (center_id, status)',
    'CREATE INDEX ix_transfers_center ON ${DatabaseTables.transfers} (center_id, status, requested_at)',
    'CREATE INDEX ix_transfer_items ON ${DatabaseTables.transferItems} (transfer_id)',
    'CREATE INDEX ix_wallet_center ON ${DatabaseTables.walletEntries} (center_id, created_at)',
    'CREATE INDEX ix_stock_center ON ${DatabaseTables.stock} (center_id, item_id)',
    'CREATE INDEX ix_notifications_time ON ${DatabaseTables.notifications} (created_at)',
    'CREATE INDEX ix_photos_owner ON ${DatabaseTables.photos} (owner_table, owner_id)',
    'CREATE INDEX ix_photos_status ON ${DatabaseTables.photos} (status)',
    'CREATE INDEX ix_outbox_status ON ${DatabaseTables.outbox} (status, seq)',
    'CREATE INDEX ix_outbox_entity ON ${DatabaseTables.outbox} (entity, entity_id, status)',
  ];

  static const indexNames = <String>[
    'ix_collections_agent',
    'ix_collections_review',
    'ix_collection_items',
    'ix_center_items',
    'ix_ragpickers_center',
    'ix_mrf_people_center',
    'ix_vehicles_center',
    'ix_expenses_center',
    'ix_cash_requests',
    'ix_tasks_assignee',
    'ix_tasks_center',
    'ix_requests_center',
    'ix_transfers_center',
    'ix_transfer_items',
    'ix_wallet_center',
    'ix_stock_center',
    'ix_notifications_time',
    'ix_photos_owner',
    'ix_photos_status',
    'ix_outbox_status',
    'ix_outbox_entity',
  ];
}
