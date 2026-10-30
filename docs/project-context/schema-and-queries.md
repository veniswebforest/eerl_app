# EERL Mobile — SQLite Schema & Queries

> Local context snapshot from [the schema and query artifact](https://claude.ai/artifact/WEnT56TBowJyGgxjNvD3kD#1323c428-fc8e), captured on 30 Oct 2026. Update only when the user explicitly requests it.

8 Oct 2026 · @Someone

Every table the app keeps and every query it runs, screen by screen. The Offline Data Guide explains why the app works this way; this doc is what to type. Column names match the`/bootstrap` row keys exactly, so a row is inserted as it arrives.

## Conventions

| Thing | Rule |
| --- | --- |
| Ids | `TEXT` uuids. The app makes the id for everything it creates (`uuid v4`) and sends it in the URL, so a retry never creates a second record. |
| Booleans | `INTEGER` 1 / 0, as`/bootstrap` sends them. |
| Money and quantities | `REAL` rupees and units (KG to 3 decimals). Round money to paise only when showing it. |
| Times | `TEXT` ISO-8601 UTC (`2026-10-01T11:56:24.492Z`). IST days are`TEXT``YYYY-MM-DD`. Convert to IST only on screen. |
| Photo lists | `TEXT` holding a JSON array of URLs, e.g.`["https://…/a.png"]`. Read with`json_each()`. |
| `sync_state` | `'synced'` = matches the server.`'pending'` = changed on the phone, waiting in the outbox. 'failed' = the server refused it; shown in Sync Status. Only on tables the phone writes to. |
| Parameters | `:me` =`me.user.id`.`:center` = the center chosen in the app.`:role` = the role on screen.`:today` = today's IST date.`:now` = current UTC time. |
| Transactions | Every write that touches two tables (a row plus its outbox item, a page of`/bootstrap`) runs in one SQLite transaction. |

Every link between tables is written into the schema as a`REFERENCES` clause, so the script below is the map of the data: Drift (or any ORM) can read the joins from it. Keep`PRAGMA foreign_keys = OFF;` (the SQLite default) all the same. The links are for reading, not for SQLite to enforce: a`/bootstrap` page can bring a row before the row it points at, a`replace` deletes and re-inserts a whole reference table, and some ids point at rows the phone may never hold (see*How the tables connect* below). The server guarantees the links; the phone never refuses a row because its parent is missing. In debug builds,`PRAGMA foreign_key_check;` after a full sync lists any row whose parent is absent, which is a quick way to spot a sync bug.

## The schema

Run this once on first launch. Four groups: bookkeeping and`me` (filled from every response), reference tables (arrive whole as`replace`), records (arrive as`upserts` +`deletes`), and phone-only tables the server never sees. Add a column only when`/bootstrap` adds a key.

```
-- Links are declared with REFERENCES and never enforced (foreign_keys stays OFF).
-- No ON DELETE CASCADE: with enforcement off it would not fire. The sync steps
-- below delete children themselves.
-- Columns marked "server user id" point at a person on the server. The phone has
-- no users table: the name travels beside the id (agent_name, user_name, …).
-- `number` columns hold the reference number the server gives (AAN-TSK-261005-001,
-- AAN-RPK-0001); null until the server has numbered the row, shown as "Not synced
-- yet". collections.slip_number is the one number the app makes itself.

-- ── Bookkeeping ──
CREATE TABLE sync_meta (
  key   TEXT PRIMARY KEY,
  value TEXT
);
-- keys: cursor, scope_key, user_id, active_role, last_bootstrap_at,
--       user_name, user_phone, user_photo_url,
--       supervisor_name, supervisor_phone, supervisor_photo_url (13 Oct 2026), session_expires_at

-- ── Who I am (replaced from `me` on every call) ──
CREATE TABLE my_roles (
  role_key  TEXT PRIMARY KEY,           -- AGENT | SUPERVISOR
  role_name TEXT NOT NULL,
  modules   TEXT NOT NULL               -- JSON array of module keys
);
CREATE TABLE my_centers (
  center_id       TEXT PRIMARY KEY REFERENCES centers (id),
  is_primary      INTEGER NOT NULL,
  agent_number    INTEGER,              -- my number at this center, for slip numbers
  slip_date       TEXT,                 -- YYYY-MM-DD, IST
  slip_last_count INTEGER NOT NULL DEFAULT 0
);

-- ── Reference (sent whole as `replace`) ──
CREATE TABLE centers (
  id TEXT PRIMARY KEY, name TEXT NOT NULL, code TEXT, address TEXT,
  eod_lock_time TEXT                    -- HH:MM:SS, IST; null = close any time
);
CREATE TABLE items (
  id TEXT PRIMARY KEY, name TEXT NOT NULL, category_name TEXT NOT NULL,
  material_type TEXT NOT NULL,          -- PLASTIC | NON_PLASTIC | MIXED (MIXED shows on the Non-Plastic tab)
  colour TEXT,
  image_url TEXT,                       -- the item's picture, set in admin; null: show the colour
  hsn_code TEXT,
  unit_code TEXT NOT NULL,              -- KG | PCS
  unit_name TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1  -- 0: switched off by the admin; name old records only (12 Oct 2026)
);
CREATE TABLE center_channels (
  center_id TEXT NOT NULL REFERENCES centers (id),
  channel TEXT NOT NULL,                -- D2D | MRF | RAMP
  show_price INTEGER NOT NULL,
  takes_payment INTEGER NOT NULL,
  PRIMARY KEY (center_id, channel)
);
CREATE TABLE center_items (
  center_id TEXT NOT NULL REFERENCES centers (id),
  channel TEXT NOT NULL,
  item_id TEXT NOT NULL REFERENCES items (id),
  is_selected INTEGER NOT NULL,
  sort_order INTEGER NOT NULL,
  rate REAL,                            -- null when prices are hidden or not set
  sync_state TEXT NOT NULL DEFAULT 'synced',
  PRIMARY KEY (center_id, channel, item_id),
  FOREIGN KEY (center_id, channel) REFERENCES center_channels (center_id, channel)
);
CREATE TABLE vehicles (
  id TEXT PRIMARY KEY,
  number TEXT,                          -- SUR-VEH-0001 (company code: vans move)
  center_id TEXT REFERENCES centers (id), -- the center this D2D vehicle unloads at; null only on old shared-fleet rows (shown at every center)
  plate_number TEXT NOT NULL,
  driver_name TEXT,                     -- no capacity_kg or type since 26 Oct 2026
  is_active INTEGER NOT NULL,
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
CREATE TABLE mrf_people (
  id TEXT PRIMARY KEY,
  number TEXT,                          -- AAN-MRF-0001
  center_id TEXT NOT NULL REFERENCES centers (id),
  name TEXT NOT NULL, phone TEXT, id_number TEXT, photo_url TEXT,
  is_active INTEGER NOT NULL,
  role TEXT NOT NULL,                   -- SUPERVISOR (one active per center) | LABOUR
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
CREATE TABLE ragpickers (
  id TEXT PRIMARY KEY,
  number TEXT,                          -- AAN-RPK-0001
  center_id TEXT NOT NULL REFERENCES centers (id),
  name TEXT NOT NULL, phone TEXT, id_number TEXT, photo_url TEXT,
  is_active INTEGER NOT NULL,
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
CREATE TABLE expense_categories (
  id TEXT PRIMARY KEY,
  center_id TEXT NOT NULL REFERENCES centers (id),
  name TEXT NOT NULL,
  is_active INTEGER NOT NULL
);
CREATE TABLE center_people (            -- sent only to someone who hands out tasks
  user_id TEXT NOT NULL,                -- server user id
  center_id TEXT NOT NULL REFERENCES centers (id),
  name TEXT NOT NULL, phone TEXT NOT NULL,
  is_agent INTEGER NOT NULL,
  PRIMARY KEY (user_id, center_id)
);
CREATE TABLE destinations (             -- sent to everyone who sees transfers; only places still open (28 Oct 2026)
  id TEXT PRIMARY KEY, name TEXT NOT NULL
);
CREATE TABLE transfer_vehicles (       -- sent to everyone who sees transfers; only trucks still in use (8 Oct 2026, part 4; corrected 28 Oct 2026)
  id TEXT PRIMARY KEY,
  number TEXT NOT NULL,                 -- as on the plate, capitals
  ownership TEXT NOT NULL,              -- COMPANY (no fee) | HIRED (a fee per trip)
  transporter_name TEXT,                -- HIRED only
  vehicle_type TEXT, capacity_kg REAL
);

-- ── Records (sent as `upserts` + `deletes`) ──
CREATE TABLE collections (
  id TEXT PRIMARY KEY,
  center_id TEXT NOT NULL REFERENCES centers (id),
  agent_id TEXT NOT NULL,               -- server user id
  agent_name TEXT NOT NULL,
  channel TEXT NOT NULL,                -- D2D | MRF | RAMP
  status TEXT NOT NULL,                 -- DRAFT | SUBMITTED | APPROVED | REJECTED
  slip_number TEXT,                     -- null while a draft
  collected_at TEXT,
  vehicle_id TEXT REFERENCES vehicles (id),          -- D2D
  mrf_person_id TEXT REFERENCES mrf_people (id),     -- MRF
  ragpicker_id TEXT REFERENCES ragpickers (id),      -- RAMP
  given_by_name TEXT, handed_over_by TEXT,
  paid_by TEXT,                         -- CASH | UPI
  takes_payment INTEGER,
  total_amount REAL,
  handover_photo_urls TEXT NOT NULL DEFAULT '[]',
  rejection_reason TEXT,
  rejection_remarks TEXT,               -- optional words beside the reason (21 Oct 2026)
  verified_by_name TEXT, verified_at TEXT,
  gps_lat REAL, gps_lng REAL,           -- where Submit was pressed; phone only, null: no fix (6 Oct 2026)
  updated_at TEXT NOT NULL,
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
CREATE TABLE collection_items (          -- replaced as a set with its collection
  id TEXT PRIMARY KEY,
  collection_id TEXT NOT NULL REFERENCES collections (id),
  item_id TEXT NOT NULL REFERENCES items (id),
  qty REAL NOT NULL, verified_qty REAL,
  rate REAL, amount REAL,
  photo_urls TEXT NOT NULL DEFAULT '[]',
  sort_order INTEGER NOT NULL
);
CREATE TABLE expenses (
  id TEXT PRIMARY KEY,
  center_id TEXT NOT NULL REFERENCES centers (id),
  user_id TEXT NOT NULL,                -- server user id: who spent it
  user_name TEXT,
  category_id TEXT NOT NULL REFERENCES expense_categories (id),
  amount REAL NOT NULL, note TEXT,
  status TEXT NOT NULL,                 -- PENDING | APPROVED | REJECTED
  number TEXT,                          -- given by the server; null until it lands
  receipt_photo_urls TEXT NOT NULL DEFAULT '[]',
  decided_by_name TEXT, decision_reason TEXT,
  decision_remarks TEXT,                -- optional words beside the reason (21 Oct 2026)
  created_at TEXT NOT NULL, updated_at TEXT,
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
CREATE TABLE cash_requests (
  id TEXT PRIMARY KEY,
  number TEXT,                          -- AAN-CSH-261005-001
  center_id TEXT NOT NULL REFERENCES centers (id),
  requested_by TEXT NOT NULL,           -- server user id
  requested_by_name TEXT,
  amount REAL NOT NULL, reason TEXT,
  status TEXT NOT NULL,                 -- PENDING | APPROVED | REJECTED
  decided_by_name TEXT, decision_note TEXT,
  decision_remarks TEXT,                -- optional words beside the reason (21 Oct 2026)
  created_at TEXT NOT NULL, updated_at TEXT,
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
CREATE TABLE category_requests (
  id TEXT PRIMARY KEY,
  number TEXT,                          -- AAN-CAT-261005-001
  center_id TEXT NOT NULL REFERENCES centers (id),
  requested_by TEXT NOT NULL,           -- server user id
  requested_by_name TEXT,               -- who asked (8 Oct 2026, part 3)
  name TEXT NOT NULL,
  reason TEXT,                          -- the "Reason/Description" box on Request New Category
  status TEXT NOT NULL,                 -- PENDING | APPROVED | REJECTED
  decided_by_name TEXT, decided_at TEXT, -- who decided, when (8 Oct 2026, part 3)
  decision_reason TEXT,                 -- why it was rejected; null when approved (8 Oct 2026, part 3)
  created_at TEXT NOT NULL,
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
CREATE TABLE transfers (
  id TEXT PRIMARY KEY,
  center_id TEXT NOT NULL REFERENCES centers (id),
  type TEXT NOT NULL,                   -- STOCK_TRANSFER | SELL_ITEM
  status TEXT NOT NULL,                 -- REQUESTED | APPROVED | DISPATCHED | RECEIVED | REJECTED
  number TEXT,
  destination_id TEXT REFERENCES destinations (id), -- set by the supervisor on approval; null for a sale
  destination_name TEXT,                -- show this: the destination may have closed since
  truck_expected_at TEXT,               -- the agent's dispatch instruction
  dispatch_note TEXT,                   -- the note for the agent: approval note or a sale's note; latest wins (12 Oct 2026)
  transfer_vehicle_id TEXT REFERENCES transfer_vehicles (id), -- the truck arranged; null for a hired truck typed in (part 4)
  planned_vehicle_number TEXT,          -- the truck arranged at approval; pre-fills Vehicle Details (part 4)
  planned_vehicle_ownership TEXT,       -- COMPANY | HIRED (part 4)
  transporter_name TEXT,                -- for a hired truck (part 4)
  transfer_fee REAL,                    -- rupees; approvers only, null on an agent's phone (part 4)
  fixed_qty REAL,                       -- a sale: what must be handed over
  estimated_expense REAL,
  vehicle_plate TEXT,                   -- the truck, typed at dispatch
  driver_name TEXT,                     -- typed at dispatch (8 Oct 2026)
  requested_by TEXT NOT NULL,           -- server user id
  requested_by_name TEXT NOT NULL,
  requested_at TEXT NOT NULL,
  decided_by_name TEXT,
  approved_at TEXT,                     -- when it was decided, approved or refused
  rejection_reason TEXT,
  rejection_remarks TEXT,               -- optional words beside the reason (23 Oct 2026)
  handed_over_at TEXT,
  gps_lat REAL, gps_lng REAL,           -- where the truck was loaded; phone only, null: no fix (6 Oct 2026)
  dispatched_weight REAL,               -- loaded weight in KG (8 Oct 2026)
  bale_count INTEGER,                   -- bales or boris; null when not given (8 Oct 2026)
  vehicle_photo_urls TEXT NOT NULL DEFAULT '[]',     -- JSON array: the truck before loading (8 Oct 2026)
  weighbridge_photo_urls TEXT NOT NULL DEFAULT '[]', -- JSON array: the weighbridge slip; may be [] (8 Oct 2026)
  vehicle_differs INTEGER NOT NULL DEFAULT 0,       -- 1: a different truck was loaded (8 Oct 2026, part 4)
  updated_at TEXT,
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
CREATE TABLE transfer_items (            -- replaced as a set with its transfer
  id TEXT PRIMARY KEY,
  transfer_id TEXT NOT NULL REFERENCES transfers (id),
  item_id TEXT NOT NULL REFERENCES items (id),
  qty REAL NOT NULL, dispatched_qty REAL
);
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  number TEXT,                          -- AAN-TSK-261005-001
  center_id TEXT REFERENCES centers (id),
  assigned_to TEXT NOT NULL,            -- server user id (center_people.user_id for a supervisor)
  assigned_to_name TEXT,
  assigned_by TEXT NOT NULL,            -- server user id
  assigned_by_name TEXT,
  title TEXT NOT NULL, description TEXT,
  priority TEXT NOT NULL,               -- LOW | NORMAL | HIGH
  status TEXT NOT NULL,                 -- PENDING | COMPLETED | CANCELLED
  due_at TEXT, completed_at TEXT,
  photo_urls TEXT NOT NULL DEFAULT '[]',
  created_at TEXT NOT NULL,
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
CREATE TABLE requests (
  id TEXT PRIMARY KEY,
  number TEXT,                          -- AAN-REQ-261005-001
  center_id TEXT REFERENCES centers (id),
  created_by TEXT NOT NULL,             -- server user id
  created_by_name TEXT,
  body TEXT NOT NULL,
  priority TEXT NOT NULL,               -- LOW | NORMAL | HIGH
  status TEXT NOT NULL,                 -- OPEN | CLOSED
  follow_up_at TEXT,                    -- when the agent wants it looked at again, UTC; null only before 12 Oct 2026
  answer TEXT, answered_at TEXT,
  photo_urls TEXT NOT NULL DEFAULT '[]',          -- the agent's photos
  answer_photo_urls TEXT NOT NULL DEFAULT '[]',   -- the supervisor's proof with the answer (21 Oct 2026)
  created_at TEXT NOT NULL,
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
CREATE TABLE wallet_entries (
  id TEXT PRIMARY KEY,
  center_id TEXT NOT NULL REFERENCES centers (id),
  kind TEXT NOT NULL,                   -- TOP_UP | COLLECTION_PAYMENT | COLLECTION_REVERSAL
                                        -- | EXPENSE | EXPENSE_REVERSAL | ADJUSTMENT
  amount REAL NOT NULL,                 -- signed: + in, - out
  note TEXT,
  collection_id TEXT REFERENCES collections (id), -- what it paid for, when a collection
  expense_id TEXT REFERENCES expenses (id),       -- what it paid for, when an expense
  confirmed_at TEXT,                    -- top-ups: when the agent confirmed receipt
  created_at TEXT NOT NULL,
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
CREATE TABLE day_closes (
  id TEXT PRIMARY KEY,
  center_id TEXT NOT NULL REFERENCES centers (id),
  date TEXT NOT NULL,                   -- YYYY-MM-DD, IST
  closed_by_name TEXT, closed_at TEXT NOT NULL
);
CREATE TABLE notifications (            -- mine only; deep_link says what it is about
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL, title TEXT NOT NULL, body TEXT,
  deep_link TEXT,
  role TEXT,                            -- AGENT | SUPERVISOR: the role it is for; null before 20 Oct 2026
  center_id TEXT REFERENCES centers (id), -- the centre it is about; null when none (20 Oct 2026)
  created_at TEXT NOT NULL, read_at TEXT,
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
CREATE TABLE center_balances (           -- one row per center
  center_id TEXT PRIMARY KEY REFERENCES centers (id),
  balance REAL NOT NULL, updated_at TEXT
);
CREATE TABLE stock (
  id TEXT PRIMARY KEY,
  center_id TEXT NOT NULL REFERENCES centers (id),
  item_id TEXT NOT NULL REFERENCES items (id),
  stage TEXT NOT NULL,                  -- RM at a collection center
  qty REAL NOT NULL
);

-- ── Phone only ──
CREATE TABLE photos (
  id TEXT PRIMARY KEY,                  -- uuid made on the phone
  -- owner_table + owner_id point at one row in one of several tables, so they
  -- cannot be a REFERENCES clause. Delete a row's photos when you delete the row.
  owner_table TEXT NOT NULL,            -- collections | collection_items | expenses | tasks | requests | transfers | ragpickers | mrf_people
  owner_id TEXT NOT NULL,
  field TEXT,                           -- which photo slot on the owner, e.g. handover; transfers: vehicle | weighbridge
  purpose TEXT NOT NULL,                -- the /uploads purpose: COLLECTION_LINE, COLLECTION_HANDOVER, …
  content_type TEXT NOT NULL,           -- image/jpeg | image/png
  local_path TEXT,
  remote_url TEXT UNIQUE,               -- the fileUrl, set once uploaded
  status TEXT NOT NULL,                 -- local | uploading | uploaded | failed
  size_bytes INTEGER,
  created_at TEXT NOT NULL,
  uploaded_at TEXT
);
CREATE TABLE outbox (
  seq INTEGER PRIMARY KEY AUTOINCREMENT, -- send order
  method TEXT NOT NULL,                 -- PUT | POST | PATCH | DELETE
  path TEXT NOT NULL,                   -- /collections/{id}/submit
  body TEXT,                            -- JSON, photos as local photo ids
  entity TEXT NOT NULL,                 -- table name: collections, expenses, …
  entity_id TEXT NOT NULL,              -- the row in that table (same pairing as photos.owner_*)
  kind TEXT,                            -- draft_save | submit | discard | … (for merging)
  refs TEXT,                            -- JSON array of ids this body refers to
  status TEXT NOT NULL,                 -- queued | sending | failed
  attempts INTEGER NOT NULL DEFAULT 0,
  last_error TEXT,
  next_attempt_at TEXT,
  created_at TEXT NOT NULL
);
CREATE TABLE outbox_photos (             -- which photos must upload before an outbox item sends
  outbox_seq INTEGER NOT NULL REFERENCES outbox (seq),
  photo_id TEXT NOT NULL REFERENCES photos (id),
  PRIMARY KEY (outbox_seq, photo_id)
);

-- ── Indexes the screens need ──
CREATE INDEX ix_collections_agent  ON collections (agent_id, status, collected_at);
CREATE INDEX ix_collections_review ON collections (center_id, status, collected_at);
CREATE INDEX ix_collection_items   ON collection_items (collection_id);
CREATE INDEX ix_center_items       ON center_items (center_id, channel, sort_order);
CREATE INDEX ix_ragpickers_center  ON ragpickers (center_id, is_active, name);
CREATE INDEX ix_mrf_people_center  ON mrf_people (center_id, is_active, role);
CREATE INDEX ix_vehicles_center    ON vehicles (center_id, is_active);
CREATE INDEX ix_expenses_center    ON expenses (center_id, status, created_at);
CREATE INDEX ix_cash_requests      ON cash_requests (center_id, status);
CREATE INDEX ix_tasks_assignee     ON tasks (assigned_to, status);
CREATE INDEX ix_tasks_center       ON tasks (center_id, status);
CREATE INDEX ix_requests_center    ON requests (center_id, status);
CREATE INDEX ix_transfers_center   ON transfers (center_id, status, requested_at);
CREATE INDEX ix_transfer_items     ON transfer_items (transfer_id);
CREATE INDEX ix_wallet_center      ON wallet_entries (center_id, created_at);
CREATE INDEX ix_stock_center       ON stock (center_id, item_id);
CREATE INDEX ix_notifications_time ON notifications (created_at);
CREATE INDEX ix_notifications_role ON notifications (role, created_at);   -- 20 Oct 2026
CREATE INDEX ix_photos_owner       ON photos (owner_table, owner_id);
CREATE INDEX ix_photos_status      ON photos (status);
CREATE INDEX ix_outbox_status      ON outbox (status, seq);
CREATE INDEX ix_outbox_entity      ON outbox (entity, entity_id, status);
CREATE INDEX ix_outbox_photos      ON outbox_photos (photo_id);
```

### How the tables connect

An arrow reads "one parent row has many child rows"; the label is the child's column.`centers` is the hub: almost every row belongs to one center.

**Center setup** (reference tables, replaced whole on every sync):

```
erDiagram
  centers ||--o{ my_centers : "center_id"
  centers ||--o{ center_channels : "center_id"
  center_channels ||--o{ center_items : "center_id + channel"
  items ||--o{ center_items : "item_id"
  centers |o--o{ vehicles : "center_id (null = shared)"
  centers ||--o{ mrf_people : "center_id"
  centers ||--o{ ragpickers : "center_id"
  centers ||--o{ expense_categories : "center_id"
  centers ||--o{ center_people : "center_id"
```

**Records** (upserted and deleted row by row):

```
erDiagram
  centers ||--o{ collections : "center_id"
  vehicles |o--o{ collections : "vehicle_id (D2D)"
  mrf_people |o--o{ collections : "mrf_person_id (MRF)"
  ragpickers |o--o{ collections : "ragpicker_id (RAMP)"
  collections ||--|{ collection_items : "collection_id"
  items ||--o{ collection_items : "item_id"
  expense_categories ||--o{ expenses : "category_id"
  centers ||--o{ expenses : "center_id"
  centers ||--o{ transfers : "center_id"
  destinations |o--o{ transfers : "destination_id"
  transfers ||--|{ transfer_items : "transfer_id"
  items ||--o{ transfer_items : "item_id"
  centers ||--o{ wallet_entries : "center_id"
  collections |o--o{ wallet_entries : "collection_id"
  expenses |o--o{ wallet_entries : "expense_id"
  centers ||--o| center_balances : "center_id"
  centers ||--o{ stock : "center_id"
  items ||--o{ stock : "item_id"
```

`cash_requests`,`category_requests`,`day_closes`,`tasks` and`requests` hang off`centers` by`center_id` and nothing else (`tasks` and`requests` may have no center).`notifications` stands alone.

**Phone only:**

```
erDiagram
  outbox ||--o{ outbox_photos : "outbox_seq"
  photos ||--o{ outbox_photos : "photo_id"
```

`photos.owner_table` +`owner_id` and`outbox.entity` +`entity_id` name a row in whichever table the first column says. They are a pair, not a foreign key.

#### Links the phone cannot always follow

Every one of these is normal, not a sync error. Show the copied name and move on.

| Column | Why the parent may be missing | What to show |
| --- | --- | --- |
| `agent_id`,`user_id`,`requested_by`,`assigned_to`,`assigned_by`,`created_by` | They are people on the server. The phone keeps only you (`sync_meta.user_id`) and, for a supervisor, the people at their centers (`center_people`). | The`*_name` column beside it. |
| `transfers.destination_id` | `destinations` holds only places still open; a transfer can name one that has closed since. | `destination_name`. |
| `transfers.transfer_vehicle_id` | `transfer_vehicles` holds only trucks still in use; a transfer can name one switched off since. | `planned_vehicle_number`,`planned_vehicle_ownership`,`transporter_name`. |
| `collection_items.item_id`,`transfer_items.item_id`,`stock.item_id` | A material taken off the list stays on old records. | A name the app cached earlier, else "Removed item". |
| `wallet_entries.collection_id`,`expense_id` | The wallet is the whole centre's, but an agent is sent only their own collections and expenses, so every payment for another agent's collection or expense points at a row the phone never holds. The collection or expense may also be older than what the phone holds. Normal on every agent's phone: show the entry anyway (LEFT JOIN). | The entry's`note` and`kind`. |
| any`center_id` | A task, request or notification can be about a center you no longer work at. After the account moves to another center, that center's reference rows go at once; a scope reset (below) clears its records. | Nothing: the row is about to go. |

**These are the only links that can be missing (corrected 28 Oct 2026).** A missing parent on one of these columns is normal: log it as information, not a warning, and never refuse the row. A missing parent on any other column is a sync bug: report it with the table, the row id and the missing id.

Where a child must go with its parent, the sync steps below delete it themselves:`collection_items` with their collection,`transfer_items` with their transfer, a row's`photos` with the row, and`outbox_photos` with their outbox item.

## Sync: applying /bootstrap

One`/bootstrap` page is applied in**one transaction**, in the order below, and the new cursor is saved inside it. If the app dies halfway, nothing changes and the same page is fetched again.

### Before the call

```
-- What to send as ?since= (no row = first download, send no since)
SELECT value FROM sync_meta WHERE key = 'cursor';

-- Send the outbox first (Outbox section), then call only when it is empty or blocked
SELECT COUNT(*) FROM outbox WHERE status IN ('queued', 'sending');
```

### Step 1 — the scope check (outside the transaction)

```
SELECT value FROM sync_meta WHERE key = 'scope_key';
```

If a stored value exists and differs from`me.scopeKey`, do not apply the page: run the**scope reset** below, then download again without`since`. Same for a`400 INVALID_CURSOR` answer.

### Step 2 —`me`

```
BEGIN;

DELETE FROM my_roles;
INSERT INTO my_roles (role_key, role_name, modules) VALUES (:key, :name, :modules_json);  -- per role

-- Centers: keep the higher slip count for the same day. A slip printed offline
-- today may not have reached the server yet.
INSERT INTO my_centers (center_id, is_primary, agent_number, slip_date, slip_last_count)
VALUES (:id, :is_primary, :agent_number, :slip_date, :last_count)
ON CONFLICT (center_id) DO UPDATE SET
  is_primary      = excluded.is_primary,
  agent_number    = excluded.agent_number,
  slip_last_count = CASE
    WHEN my_centers.slip_date = excluded.slip_date THEN MAX(my_centers.slip_last_count, excluded.slip_last_count)
    WHEN my_centers.slip_date > excluded.slip_date THEN my_centers.slip_last_count
    ELSE excluded.slip_last_count END,
  slip_date       = MAX(COALESCE(my_centers.slip_date, ''), excluded.slip_date);
DELETE FROM my_centers WHERE center_id NOT IN (:center_ids_from_me);

INSERT OR REPLACE INTO sync_meta (key, value) VALUES
  ('user_id', :user_id), ('user_name', :user_name), ('user_phone', :user_phone),
  ('user_photo_url', :user_photo_url),
  ('supervisor_name', :supervisor_name), ('supervisor_phone', :supervisor_phone),  -- null when no supervisor
  ('supervisor_photo_url', :supervisor_photo_url),  -- null when no supervisor or no photo (13 Oct 2026)
  ('session_expires_at', :expires_at);
```

### Step 3 — reference tables (`replace`)

Only for tables present in`tables`. Rows the phone changed and has not sent (`sync_state = 'pending'`) survive.

```
-- Tables with a sync_state column: center_items, vehicles, mrf_people, ragpickers
DELETE FROM ragpickers WHERE sync_state = 'synced';
INSERT OR IGNORE INTO ragpickers (id, center_id, name, phone, id_number, photo_url, is_active)
VALUES (:id, :center_id, :name, :phone, :id_number, :photo_url, :is_active);          -- per row

-- Tables without one: centers, items, center_channels,
-- expense_categories, center_people, destinations, transfer_vehicles
DELETE FROM items;
INSERT INTO items (id, name, category_name, material_type, colour, image_url, hsn_code, unit_code, unit_name, is_active)
VALUES (…);                                                                          -- per row
```

### Step 4 — records (`upserts`, then`deletes`)

Insert or update by primary key, but**never over a pending row**: the phone's version is on its way and the server's copy comes back after it lands.

```
INSERT INTO collections (id, center_id, agent_id, agent_name, channel, status, slip_number,
  collected_at, vehicle_id, mrf_person_id, ragpicker_id, given_by_name, handed_over_by, paid_by,
  takes_payment, total_amount, handover_photo_urls, rejection_reason, verified_by_name,
  verified_at, updated_at, sync_state)
VALUES (…, 'synced')
ON CONFLICT (id) DO UPDATE SET
  status = excluded.status, slip_number = excluded.slip_number, /* …every column… */
  updated_at = excluded.updated_at, sync_state = 'synced'
WHERE collections.sync_state = 'synced';

-- Children arrive as a complete set with their parent: replace them, unless the parent is pending
DELETE FROM collection_items
WHERE collection_id = :collection_id
  AND (SELECT sync_state FROM collections WHERE id = :collection_id) = 'synced';
INSERT OR REPLACE INTO collection_items (id, collection_id, item_id, qty, verified_qty, rate,
  amount, photo_urls, sort_order)
SELECT :id, :collection_id, :item_id, :qty, :verified_qty, :rate, :amount, :photo_urls, :sort_order
WHERE (SELECT sync_state FROM collections WHERE id = :collection_id) = 'synced';
-- transfer_items under transfers: the same two statements

-- deletes: one id list per table. Never delete a row you have not sent yet.
-- (They include rows that aged out of the window: same handling.)
DELETE FROM photos           WHERE owner_table = 'collection_items' AND status = 'uploaded'
                               AND owner_id IN (SELECT ci.id FROM collection_items ci
                                 JOIN collections c ON c.id = ci.collection_id
                                 WHERE c.id IN (:deleted_ids) AND c.sync_state = 'synced');
DELETE FROM collection_items WHERE collection_id IN
                               (SELECT id FROM collections WHERE id IN (:deleted_ids) AND sync_state = 'synced');
DELETE FROM photos           WHERE owner_table = 'collections' AND owner_id IN (:deleted_ids)
                               AND status = 'uploaded';
DELETE FROM collections      WHERE id IN (:deleted_ids) AND sync_state = 'synced';
-- transfers: the same, with transfer_items; other tables: one line each
DELETE FROM expenses         WHERE id IN (:deleted_ids) AND sync_state = 'synced';
DELETE FROM center_balances  WHERE center_id IN (:deleted_ids);   -- its key is center_id
```

The same`ON CONFLICT … WHERE sync_state = 'synced'` shape serves every record table with a`sync_state` column.`transfer_items`,`day_closes`,`center_balances` and`stock` have none: use plain`INSERT OR REPLACE`.

### Step 5 — the cursor, then commit

```
INSERT OR REPLACE INTO sync_meta (key, value) VALUES
  ('cursor', :cursor), ('scope_key', :scope_key), ('last_bootstrap_at', :server_time);
COMMIT;
```

Then call again with the new cursor while`hasMore` is`true`.

### Scope reset

The account gained or lost a center or role (`scopeKey` changed), or the cursor was refused. Send the outbox until it is empty first, so nothing the agent did is lost.

```
BEGIN;
DELETE FROM my_roles; DELETE FROM my_centers;
DELETE FROM centers; DELETE FROM items; DELETE FROM center_channels; DELETE FROM center_items;
DELETE FROM vehicles; DELETE FROM mrf_people; DELETE FROM ragpickers;
DELETE FROM expense_categories; DELETE FROM center_people; DELETE FROM destinations;
DELETE FROM transfer_vehicles;
DELETE FROM collections; DELETE FROM collection_items; DELETE FROM expenses;
DELETE FROM cash_requests; DELETE FROM category_requests; DELETE FROM transfers;
DELETE FROM transfer_items; DELETE FROM tasks; DELETE FROM requests; DELETE FROM wallet_entries;
DELETE FROM day_closes; DELETE FROM notifications; DELETE FROM center_balances; DELETE FROM stock;
DELETE FROM photos WHERE status = 'uploaded';
DELETE FROM sync_meta WHERE key IN ('cursor', 'scope_key');
COMMIT;
-- then GET /bootstrap with no since
```

### Sign-out, and a different person signing in

```
-- Before signing out: warn when anything is unsent
SELECT COUNT(*) FROM outbox;

-- On sign-in, compare with the stored user
SELECT value FROM sync_meta WHERE key = 'user_id';
```

A different`user_id` than stored, or a confirmed sign-out: run the scope reset, then also`DELETE FROM outbox; DELETE FROM outbox_photos; DELETE FROM photos; DELETE FROM sync_meta;` and delete the local photo files.

### Ageing out: nothing to run

The server keeps the phone inside its window: 7 days of records for an agent and 30 with a supervisor role, plus whatever is still open. Once a day it sends closed rows that aged out as ordinary`deletes`. A closed row older than the window that changes also comes as a delete. The app runs**no clean-up by date**. Step 4 above already does everything: deletes skip unsent rows, and deleting a collection or transfer takes its items and photos with it.

## Outbox and photos

Every write the user makes lands in SQLite first, marked`pending`, with an outbox item in the**same transaction**. A sender drains the outbox one item at a time, oldest first. Photos upload on their own track; an item that needs photos waits for them.

### Queue a write

```
BEGIN;
-- 1. the row itself (any table), marked pending
INSERT OR REPLACE INTO expenses (id, center_id, user_id, user_name, category_id, amount, note,
  status, number, receipt_photo_urls, created_at, updated_at, sync_state)
VALUES (:id, :center, :me, :my_name, :category_id, :amount, :note,
  'PENDING', NULL, '[]', :now, :now, 'pending');

-- 2. the outbox item; photos in the body are local photo ids
INSERT INTO outbox (method, path, body, entity, entity_id, kind, refs, status, created_at)
VALUES ('PUT', '/expenses/' || :id, :body_json, 'expenses', :id, 'create', :refs_json, 'queued', :now);

-- 3. the photos it must wait for (skip for a draft save)
INSERT INTO outbox_photos (outbox_seq, photo_id) VALUES (last_insert_rowid(), :photo_id);
COMMIT;
```

### Merge before queueing a collection write

```
-- A draft save while an unsent one exists: replace its body instead of adding a second item
UPDATE outbox SET body = :body_json, created_at = created_at
WHERE entity = 'collections' AND entity_id = :id AND kind = 'draft_save' AND status = 'queued';
-- (changes() = 0 → insert a new draft_save item)

-- A submit: drop the unsent draft saves, then queue the submit
DELETE FROM outbox
WHERE entity = 'collections' AND entity_id = :id AND kind = 'draft_save' AND status = 'queued';

-- A discard: drop the unsent saves and queue DELETE /collections/{id}.
-- If the draft never reached the server the answer is still 204, so always sending it is safe.
DELETE FROM outbox
WHERE entity = 'collections' AND entity_id = :id AND kind = 'draft_save' AND status = 'queued';
```

### Send the next item

```
-- The oldest item. If it still waits for photos, stop: order matters more than speed.
SELECT o.*,
       (SELECT COUNT(*) FROM outbox_photos op JOIN photos p ON p.id = op.photo_id
        WHERE op.outbox_seq = o.seq AND p.status <> 'uploaded') AS photos_waiting
FROM outbox o
WHERE o.status = 'queued' AND (o.next_attempt_at IS NULL OR o.next_attempt_at <= :now)
ORDER BY o.seq
LIMIT 1;

UPDATE outbox SET status = 'sending' WHERE seq = :seq;

-- Swap local photo ids in the body for their URLs just before sending
SELECT id, remote_url FROM photos WHERE id IN (:photo_ids_in_body);
```

### Handle the answer

```
-- 2xx, or 409 NOT_PENDING / ALREADY_CLOSED (someone already did it): done
BEGIN;
DELETE FROM outbox_photos WHERE outbox_seq = :seq;
DELETE FROM outbox WHERE seq = :seq;
-- write what the server answered, then mark synced once nothing else for this
-- record is waiting. The answer's `number` is the reference number the server just
-- gave: copy it for expenses, cash_requests, category_requests, transfers, tasks,
-- requests, ragpickers, mrf_people and vehicles (the same UPDATE, that table's name).
-- If the answer is lost, the next /bootstrap brings the row with its number anyway.
UPDATE expenses SET number = :number, sync_state = 'synced'
WHERE id = :id
  AND NOT EXISTS (SELECT 1 FROM outbox WHERE entity = 'expenses' AND entity_id = :id);
COMMIT;

-- No network, timeout or 5xx: try again later (30 s, 2 min, 10 min, then every 30 min)
UPDATE outbox SET status = 'queued', attempts = attempts + 1,
                  last_error = :error, next_attempt_at = :next_try
WHERE seq = :seq;

-- 409 CANCELLED (task complete), DRAFT_DISCARDED (draft save), ALREADY_SUBMITTED (draft save
-- or discard) or REJECTED (transfer handover): the record moved on while this waited.
-- Not failed: take the server's state and drop the write (16 Oct 2026 entry).

-- Any other 4xx: it will never succeed as it is. Park it for the user.
UPDATE outbox SET status = 'failed', last_error = :code_and_message WHERE seq = :seq;
UPDATE expenses SET sync_state = 'failed' WHERE id = :id;   -- the record it belongs to
```

A failed item blocks the items after it**for the same record** only; others carry on:

```
SELECT o.* FROM outbox o
WHERE o.status = 'queued'
  AND NOT EXISTS (SELECT 1 FROM outbox f
                  WHERE f.status = 'failed' AND f.entity = o.entity AND f.entity_id = o.entity_id)
ORDER BY o.seq LIMIT 1;
```

### Photos

```
-- Taken: keep the file, record it
INSERT INTO photos (id, owner_table, owner_id, field, purpose, content_type, local_path,
                    status, size_bytes, created_at)
VALUES (:photo_id, 'collection_items', :line_id, 'item', 'COLLECTION_LINE', 'image/jpeg',
        :path, 'local', :size, :now);

-- Uploader: up to 20 waiting photos for one POST /uploads/batch
SELECT id, purpose, content_type, size_bytes FROM photos
WHERE status IN ('local', 'failed') ORDER BY created_at LIMIT 20;
UPDATE photos SET status = 'uploading' WHERE id IN (:ids);

-- After each PUT of the bytes succeeds
UPDATE photos SET status = 'uploaded', remote_url = :file_url, uploaded_at = :now WHERE id = :id;
-- A PUT that failed, or an upload URL that expired: back in the queue
UPDATE photos SET status = 'failed' WHERE id = :id;

-- Show a photo: the local file while it exists, otherwise the URL
SELECT COALESCE(local_path, remote_url) FROM photos WHERE owner_table = :t AND owner_id = :id;

-- Clean-up: free the files of photos whose record is on the server
SELECT p.id, p.local_path FROM photos p
WHERE p.status = 'uploaded' AND p.local_path IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM outbox_photos op WHERE op.photo_id = p.id);
UPDATE photos SET local_path = NULL WHERE id IN (:ids);   -- after deleting the files
```

## Agent screens

Each screen reads SQLite only. Each action writes the row as`pending` and queues its outbox item (Outbox section), in one transaction.`:center` is the center picked in the app;`:week_start` is the start of the IST day 6 days ago, in UTC.

### Home

```
-- Today's collections and weight at this center (mine)
SELECT COUNT(DISTINCT c.id) AS collections,
       COALESCE(SUM(CASE WHEN i.unit_code = 'KG' THEN ci.verified_qty END), 0) AS kg
FROM collections c
LEFT JOIN collection_items ci ON ci.collection_id = c.id
LEFT JOIN items i ON i.id = ci.item_id
WHERE c.agent_id = :me AND c.center_id = :center
  AND c.status <> 'DRAFT' AND c.collected_at >= :today_start_utc;

-- Open tasks, drafts, rejected collections to fix
SELECT (SELECT COUNT(*) FROM tasks       WHERE assigned_to = :me AND status = 'PENDING') AS tasks,
       (SELECT COUNT(*) FROM collections WHERE agent_id = :me AND status = 'DRAFT')      AS drafts,
       (SELECT COUNT(*) FROM collections WHERE agent_id = :me AND status = 'REJECTED')   AS to_fix;
```

Wallet balance: see Wallet below.

### New collection — step 1 (who handed it over)

```
-- Which channels this center runs, and whether each shows prices and takes payment
SELECT channel, show_price, takes_payment FROM center_channels WHERE center_id = :center;

-- D2D: this center's vans plus the shared fleet
SELECT id, plate_number, type_name, driver_name FROM vehicles
WHERE is_active = 1 AND (center_id = :center OR center_id IS NULL)
ORDER BY plate_number;

-- MRF: the MRF supervisor printed on the slip, and the labourers for "Given by"
SELECT id, name, phone FROM mrf_people
WHERE center_id = :center AND is_active = 1 AND role = 'SUPERVISOR';
SELECT id, name, phone FROM mrf_people
WHERE center_id = :center AND is_active = 1 AND role = 'LABOUR' ORDER BY name;

-- Ramp: pick a ragpicker (search by name or phone)
SELECT id, name, phone, photo_url FROM ragpickers
WHERE center_id = :center AND is_active = 1
  AND (:q IS NULL OR name LIKE '%' || :q || '%' OR phone LIKE '%' || :q || '%')
ORDER BY name;
```

No MRF supervisor row → the MRF channel cannot be submitted (`409 NO_MRF_SUPERVISOR`); say so before the agent starts.

### New collection — step 3 (items)

```
-- The items this center offers on this channel, in the saved order, with today's rate
SELECT i.id, i.name, i.unit_code, i.unit_name, i.colour, i.image_url, i.material_type,
       CASE WHEN ch.show_price = 1 THEN ci.rate END AS rate
FROM center_items ci
JOIN items i            ON i.id = ci.item_id
JOIN center_channels ch ON ch.center_id = ci.center_id AND ch.channel = ci.channel
WHERE ci.center_id = :center AND ci.channel = :channel AND ci.is_selected = 1
  AND i.is_active = 1                   -- never offer a switched-off material (12 Oct 2026)
ORDER BY ci.sort_order;
```

Line amount =`ROUND(verified_qty × rate, 2)`;`rate` and`amount` stay null when prices are hidden.

**Item pictures.**`image_url` is the picture an admin set for the item: show it as the small thumbnail beside the item name on this step, and open it full size on tap. It is a public link, so download it after each`/bootstrap` (again only when the URL changes) and show the saved copy, so it works offline. When`image_url` is`null`, show the item's`colour` instead.

### Save a draft

```
BEGIN;
INSERT OR REPLACE INTO collections (id, center_id, agent_id, agent_name, channel, status,
  vehicle_id, mrf_person_id, ragpicker_id, given_by_name, paid_by, takes_payment,
  total_amount, handover_photo_urls, updated_at, sync_state)
VALUES (:id, :center, :me, :my_name, :channel, 'DRAFT', :vehicle_id, :mrf_person_id,
  :ragpicker_id, :given_by_name, :paid_by, :takes_payment, :total, :handover_urls, :now, 'pending');
DELETE FROM collection_items WHERE collection_id = :id;
INSERT INTO collection_items (id, collection_id, item_id, qty, verified_qty, rate, amount,
  photo_urls, sort_order) VALUES (…);                                -- per line
-- outbox: PUT /collections/{id}, kind 'draft_save' (merge rule applies)
COMMIT;
```

### Slip numbers

The slip number is the one reference number the phone makes itself. The slip is printed or shared with the giver the moment Submit is pressed, usually with no signal, so its number cannot wait for the server. Every other number (`AAN-EXP-…`,`AAN-TRF-…`) comes from the server and reads "Not synced yet" until it arrives.

`AAN-261008-07-012`, read left to right:

| Part | Example | Comes from | Rule |
| --- | --- | --- | --- |
| Centre code | `AAN` | `centers.code` | 2–6 capital letters or digits, set by the admin. Null: the centre cannot record yet. |
| Date | `261008` | `collected_at` as an**IST** calendar day,`YYMMDD` | IST whatever the phone's time zone: 23:59 IST is still today, 00:00 IST starts a new day. |
| Agent number | `07` | `my_centers.agent_number` | Given by the server when the user is placed at the centre: 01–99, never reused, different at each centre. |
| Count | `012` | `my_centers.slip_last_count + 1` | This agent's slips at this centre that IST day, from 001 to 999. |

It is unique without the network: two agents at one centre differ in agent number, one agent's count only goes up, and the date separates the days.

**When it is made, and why it never changes**

- Made once, at the**first Submit**. Save draft makes none (`slip_number` stays null), so a discarded draft uses no number.
- Fixed from then on. An outbox retry resends the same number; a rejected collection is resubmitted with the same number and the same`collected_at` (the server refuses another:`SLIP_NUMBER_CHANGED`); a reprint shows the same.
- The count never goes back. If a submit is refused (a 4xx parked in the outbox), its number stays used: fix the collection and send it again with that number.
- One counter per centre: an agent at two centres has two agent numbers and two counts.

**Keeping the count across reinstalls.**`me.centers[].slipCounter` in`/bootstrap` (`date`,`lastCount`) is the highest count the server holds for this agent at that centre today. Step 2 stores it in`slip_date` /`slip_last_count`, keeping the higher of the phone's figure and the server's for the same day, because a slip printed offline may not have reached the server yet. A new or reinstalled phone therefore carries on at 013, not 001.

**The one repeat.** The same agent on two phones, both offline, on the same day, can print one number twice. The server accepts both and flags the second (`duplicateSlipNumber`) for the admin to look at. Keep one phone per agent.

**Block Submit, and say why, when:**

- `centers.code` is null: "This centre has no code yet. Ask the admin."
- `my_centers.agent_number` is null: "You are not set up to record at this centre yet. Ask the admin."
- the next count would be 1000: "999 slips is the daily limit at this centre."

**What the server checks** on a first submit:`422`, field`slipNumber`. Each one is a bug in the app, not something the agent can fix, so park it.

| Code | Means |
| --- | --- |
| `INVALID_SLIP_NUMBER` | Not in the`CODE-YYMMDD-NN-NNN` shape, or an impossible date |
| `SLIP_CENTER_MISMATCH` | The code is not this centre's |
| `SLIP_AGENT_MISMATCH` | The agent number is not this user's at this centre |
| `SLIP_DATE_MISMATCH` | The date is not`collectedAt` 's IST day: build both from the same instant |

**Test cases.** The backend runs the same ones (`docs/contracts/slip-number-vectors.json`); run them in the app's tests too.

| Inputs | Slip number |
| --- | --- |
| PAL, 17 Sep 2026, agent 7, count 12 | `PAL-260917-07-012` |
| AAN, 5 Jan 2026, agent 1, count 1 | `AAN-260105-01-001` |
| SRT01, 31 Dec 2027, agent 99, count 999 | `SRT01-271231-99-999` |
| Submit at`2026-09-17T18:29:59.999Z` (23:59:59 IST) | date`260917` |
| Submit at`2026-09-17T18:30:00.000Z` (00:00 IST) | date`260918`, count back to 001 |

Not valid:`PAL-260917-7-012` (agent needs two digits),`pal-260917-07-012` (capitals only),`PAL-261340-07-012` (no such date),`PAL-260917-00-012` (agents start at 01),`PAL-260917-07-000` (counts start at 001),`P-260917-07-012` (code is 2–6 characters).

### Submit (prints the slip)

```
BEGIN;
-- 1. The next slip number (rules under Slip numbers above). :now_utc is the instant
--    Submit was pressed: the same value goes in collected_at and the body's collectedAt.
SELECT c.code, m.agent_number,
       strftime('%Y-%m-%d', :now_utc, '+5 hours', '+30 minutes') AS today_ist,
       strftime('%y%m%d',   :now_utc, '+5 hours', '+30 minutes') AS yymmdd,
       CASE WHEN m.slip_date = strftime('%Y-%m-%d', :now_utc, '+5 hours', '+30 minutes')
            THEN m.slip_last_count + 1 ELSE 1 END AS next_count
FROM my_centers m JOIN centers c ON c.id = m.center_id
WHERE m.center_id = :center;
-- code NULL, agent_number NULL or next_count > 999: ROLLBACK and say why (Slip numbers).
SELECT printf('%s-%s-%02d-%03d', :code, :yymmdd, :agent_number, :next_count) AS slip_number;

-- 2. Use the count up in the same transaction, so a crash can never hand it out twice
UPDATE my_centers SET slip_date = :today_ist, slip_last_count = :next_count
WHERE center_id = :center;

-- 3. The collection
UPDATE collections
SET status = 'SUBMITTED', slip_number = :slip_number, collected_at = :now_utc,
    total_amount = :total, rejection_reason = NULL, updated_at = :now_utc, sync_state = 'pending'
WHERE id = :id;
-- lines rewritten as in Save a draft
-- outbox: POST /collections/{id}/submit, kind 'submit', waiting on every photo
COMMIT;
-- Print or share the slip only after COMMIT.
```

A rejected collection is resubmitted the same way,**keeping its slip number and`collected_at`**: skip the slip query and the`my_centers` update.

### Records

```
-- History: last 7 days, newest first
SELECT c.*, (SELECT COUNT(*) FROM collection_items WHERE collection_id = c.id) AS lines
FROM collections c
WHERE c.agent_id = :me AND c.status <> 'DRAFT' AND c.collected_at >= :week_start
  AND (:channel IS NULL OR c.channel = :channel)
  AND (:q IS NULL OR c.slip_number LIKE '%' || :q || '%')
ORDER BY c.collected_at DESC;

-- Drafts
SELECT * FROM collections WHERE agent_id = :me AND status = 'DRAFT' ORDER BY updated_at DESC;

-- One collection, with its lines
SELECT * FROM collections WHERE id = :id;
SELECT ci.*, i.name, i.unit_code, i.unit_name
FROM collection_items ci JOIN items i ON i.id = ci.item_id
WHERE ci.collection_id = :id ORDER BY ci.sort_order;
```

Discard a draft:`DELETE` it and its lines locally, then queue`DELETE /collections/{id}`.

### Configure material list

```
-- One tab: PLASTIC, or NON_PLASTIC (which also holds MIXED)
SELECT i.id, i.name, i.colour, ci.is_selected, ci.sort_order
FROM center_items ci JOIN items i ON i.id = ci.item_id
WHERE ci.center_id = :center AND ci.channel = :channel
  AND i.is_active = 1                   -- 12 Oct 2026
  AND (CASE WHEN :tab = 'PLASTIC' THEN i.material_type = 'PLASTIC'
            ELSE i.material_type IN ('NON_PLASTIC', 'MIXED') END)
ORDER BY ci.is_selected DESC, ci.sort_order;

-- Save the tab: every row of it, in the order shown
UPDATE center_items SET is_selected = :sel, sort_order = :pos, sync_state = 'pending'
WHERE center_id = :center AND channel = :channel AND item_id = :item_id;   -- per item
-- outbox: PUT /item-config with centerId, collectionChannel, tab and items (the whole list)
```

### Ragpicker directory

```
SELECT * FROM ragpickers
WHERE center_id = :center AND is_active = :active_tab          -- 1 Active, 0 Deactivated
  AND (:q IS NULL OR name LIKE '%' || :q || '%' OR phone LIKE '%' || :q || '%')
ORDER BY name;

-- Name already used at this center? (the server refuses it with DUPLICATE_NAME)
SELECT 1 FROM ragpickers WHERE center_id = :center AND name = :name AND id <> :id;

-- Can it be deactivated? Not while a draft or rejected collection names them
SELECT 1 FROM collections WHERE ragpicker_id = :id AND status IN ('DRAFT', 'REJECTED');
```

Add or edit:`INSERT OR REPLACE` the row with`sync_state = 'pending'`, queue`PUT /ragpickers/{id}` (or`PATCH`). Deactivate:`UPDATE ragpickers SET is_active = 0, sync_state = 'pending'`, queue`POST /ragpickers/{id}/status`.

### Wallet

```
-- Balance now: the server's figure minus what the phone spent and has not sent yet
SELECT b.balance
- COALESCE((SELECT SUM(amount) FROM expenses
              WHERE center_id = b.center_id AND sync_state = 'pending'), 0)
- COALESCE((SELECT SUM(total_amount) FROM collections
              WHERE center_id = b.center_id AND sync_state = 'pending'
                AND status = 'SUBMITTED' AND takes_payment = 1), 0) AS balance_now
FROM center_balances b WHERE b.center_id = :center;

-- Today's movement, shown as money in and money out
SELECT SUM(CASE WHEN kind = 'TOP_UP' THEN amount ELSE 0 END)                                   AS cash_in,
       -SUM(CASE WHEN kind IN ('COLLECTION_PAYMENT','COLLECTION_REVERSAL') THEN amount ELSE 0 END) AS paid_out,
       -SUM(CASE WHEN kind IN ('EXPENSE','EXPENSE_REVERSAL') THEN amount ELSE 0 END)             AS spent
FROM wallet_entries WHERE center_id = :center AND created_at >= :today_start_utc;

-- History, with what each entry was for
SELECT w.*, c.slip_number, e.number AS expense_number
FROM wallet_entries w
LEFT JOIN collections c ON c.id = w.collection_id
LEFT JOIN expenses e    ON e.id = w.expense_id
WHERE w.center_id = :center ORDER BY w.created_at DESC;

-- Cash sent and not yet confirmed (show Confirm)
SELECT * FROM wallet_entries
WHERE center_id = :center AND kind = 'TOP_UP' AND confirmed_at IS NULL;
```

Confirm:`UPDATE wallet_entries SET confirmed_at = :now, sync_state = 'pending'`, queue`POST /wallet/entries/{id}/confirm`.

### Expenses, cash and categories

```
-- Categories to pick from (approved only)
SELECT id, name FROM expense_categories
WHERE center_id = :center AND is_active = 1 ORDER BY name;

-- Categories I asked for: waiting ones, and decided ones with who decided and why
SELECT name, reason, status, decided_by_name, decided_at, decision_reason, created_at
FROM category_requests WHERE center_id = :center AND requested_by = :me
ORDER BY created_at DESC;

-- My expenses
SELECT e.*, k.name AS category_name FROM expenses e
LEFT JOIN expense_categories k ON k.id = e.category_id
WHERE e.user_id = :me AND e.center_id = :center
  AND (:status IS NULL OR e.status = :status)
ORDER BY e.created_at DESC;

-- My cash requests
SELECT * FROM cash_requests WHERE requested_by = :me AND center_id = :center
ORDER BY created_at DESC;
```

Block an expense larger than`balance_now` before queueing it: the server refuses it (`OVER_BALANCE`). Log an expense →`PUT /expenses/{id}`; ask for cash →`PUT /cash-requests/{id}`; ask for a category →`PUT /expense-categories/requests/{id}`.

### Transfers

```
-- Stock in hand: server figure plus what the phone collected and has not sent
SELECT s.item_id, i.name, i.unit_code,
       SUM(s.qty) + COALESCE((SELECT SUM(ci.verified_qty)
                              FROM collection_items ci JOIN collections c ON c.id = ci.collection_id
                              WHERE c.center_id = s.center_id AND ci.item_id = s.item_id
                                AND c.sync_state = 'pending' AND c.status = 'SUBMITTED'), 0) AS qty_now
FROM stock s JOIN items i ON i.id = s.item_id
WHERE s.center_id = :center AND s.stage = 'RM'
GROUP BY s.item_id ORDER BY qty_now DESC;

-- Free to send (8 Oct 2026, part 2): in hand, less what this center's open transfers
-- (waiting or approved, not yet loaded) already ask for. The server refuses a request
-- above it with OVER_STOCK, so use qty_free as the most the agent can type.
WITH in_hand AS (
  SELECT s.item_id,
         SUM(s.qty) + COALESCE((SELECT SUM(ci.verified_qty)
                                FROM collection_items ci JOIN collections c ON c.id = ci.collection_id
                                WHERE c.center_id = s.center_id AND ci.item_id = s.item_id
                                  AND c.sync_state = 'pending' AND c.status = 'SUBMITTED'), 0) AS qty_now
  FROM stock s
  WHERE s.center_id = :center AND s.stage = 'RM'
  GROUP BY s.item_id
), promised AS (
  SELECT ti.item_id, SUM(ti.qty) AS qty
  FROM transfer_items ti JOIN transfers t ON t.id = ti.transfer_id
  WHERE t.center_id = :center AND t.status IN ('REQUESTED', 'APPROVED')
  GROUP BY ti.item_id
)
SELECT h.item_id, i.name, i.unit_code, h.qty_now,
       COALESCE(p.qty, 0) AS qty_promised,
       MAX(h.qty_now - COALESCE(p.qty, 0), 0) AS qty_free
FROM in_hand h JOIN items i ON i.id = h.item_id
LEFT JOIN promised p ON p.item_id = h.item_id
ORDER BY h.qty_now DESC;

-- Transfer list, by tab
SELECT t.*, (SELECT COUNT(*) FROM transfer_items WHERE transfer_id = t.id) AS lines
FROM transfers t
WHERE t.center_id = :center AND t.status IN (:statuses)   -- e.g. ('APPROVED') for "Ready to send"
ORDER BY t.requested_at DESC;

-- One transfer, with its lines
SELECT ti.*, i.name, i.unit_code FROM transfer_items ti JOIN items i ON i.id = ti.item_id
WHERE ti.transfer_id = :id;

-- A dispatched transfer: what the agent recorded (see 8 Oct 2026 below)
SELECT vehicle_plate, driver_name, handed_over_at, dispatched_weight, bale_count,
       vehicle_photo_urls, weighbridge_photo_urls
FROM transfers WHERE id = :id;
```

Raise →`PUT /transfers/{id}`: one item, a quantity no more than`qty_now`, and`estimatedExpense` once for the request. Dispatch, once`APPROVED` → the agent fills**Vehicle Details** then**Weighbridge**, and**Submit Transfer** queues one`POST /transfers/{id}/handover`; locally set`status = 'DISPATCHED'`,`handed_over_at`,`vehicle_plate`,`driver_name`,`dispatched_weight`,`bale_count` and each line's`dispatched_qty`. The full steps and queries are under*8 Oct 2026* below.

**Free stock and changes after approval** (*8 Oct 2026, part 2* below). A request may ask for no more than`qty_free`; above it the server answers`OVER_STOCK` with the figures in the message. An approved transfer can still be changed (destination, truck time) or cancelled from the web until the truck is loaded: a cancelled one arrives as`REJECTED` with`rejection_reason` starting "Cancelled after approval:".

**The arranged truck** (*8 Oct 2026, part 4*). An approved transfer carries the truck the supervisor arranged:`planned_vehicle_number`,`planned_vehicle_ownership`,`transporter_name` (the agent's`transfer_fee` is always null). Show it on the approved card ("Truck GJ-05-EE-1001 expected 10 Oct, 10:00"), and open Vehicle Details with the number already filled in. The agent changes it if a different truck came: that is accepted and flagged (`vehicle_differs`).

### Tasks and requests

```
SELECT * FROM tasks WHERE assigned_to = :me
ORDER BY CASE status WHEN 'PENDING' THEN 0 ELSE 1 END,
         CASE priority WHEN 'HIGH' THEN 0 WHEN 'NORMAL' THEN 1 ELSE 2 END, created_at DESC;

SELECT * FROM requests WHERE created_by = :me ORDER BY created_at DESC;
```

Complete a task →`UPDATE tasks SET status = 'COMPLETED', completed_at = :now, sync_state = 'pending'`, queue`POST /tasks/{id}/complete`. Raise a request (with its required follow-up time, 12 Oct 2026) → insert with`status = 'OPEN'`, queue`PUT /requests/{id}`.

### Close the day

```
-- Already closed today?
SELECT closed_by_name, closed_at FROM day_closes WHERE center_id = :center AND date = :today;

-- Lock time and my own open drafts (the server also counts other agents' drafts)
SELECT eod_lock_time FROM centers WHERE id = :center;
SELECT COUNT(*) FROM collections WHERE center_id = :center AND agent_id = :me AND status = 'DRAFT';
```

Closing is online only:`GET /centers/{id}/day-close` for the summary, then`POST` to close.

## Supervisor screens

A supervisor sees everyone's records at their centers (never anyone's drafts). Every query is bound to`my_centers`;`:center` narrows to one when the screen has a center picker.`:month_start` is the start of the IST day 29 days ago, in UTC.

### Home

```
-- Waiting for verification
SELECT COUNT(*) FROM collections
WHERE center_id IN (SELECT center_id FROM my_centers) AND status = 'SUBMITTED';

-- Approvals waiting: expenses, cash requests, category requests
SELECT (SELECT COUNT(*) FROM expenses          WHERE center_id IN (SELECT center_id FROM my_centers) AND status = 'PENDING')
     + (SELECT COUNT(*) FROM cash_requests     WHERE center_id IN (SELECT center_id FROM my_centers) AND status = 'PENDING')
     + (SELECT COUNT(*) FROM category_requests WHERE center_id IN (SELECT center_id FROM my_centers) AND status = 'PENDING');

-- Transfers waiting for a decision
SELECT COUNT(*) FROM transfers
WHERE center_id IN (SELECT center_id FROM my_centers) AND status = 'REQUESTED';

-- Transports today: received / raised
SELECT SUM(status = 'RECEIVED'), COUNT(*) FROM transfers
WHERE center_id IN (SELECT center_id FROM my_centers) AND requested_at >= :today_start_utc;

-- Open tasks and open requests
SELECT (SELECT COUNT(*) FROM tasks    WHERE center_id IN (SELECT center_id FROM my_centers) AND status = 'PENDING'),
       (SELECT COUNT(*) FROM requests WHERE center_id IN (SELECT center_id FROM my_centers) AND status = 'OPEN');
```

### Verification — pending and verified

```
-- Pending verification, oldest first
SELECT c.*, ce.name AS center_name FROM collections c JOIN centers ce ON ce.id = c.center_id
WHERE c.center_id IN (SELECT center_id FROM my_centers) AND c.status = 'SUBMITTED'
  AND (:center IS NULL OR c.center_id = :center) AND (:channel IS NULL OR c.channel = :channel)
ORDER BY c.collected_at;

-- Verified entries: approved and rejected, last 30 days
SELECT * FROM collections
WHERE center_id IN (SELECT center_id FROM my_centers) AND status IN ('APPROVED','REJECTED')
  AND collected_at >= :month_start
ORDER BY verified_at DESC;

-- One collection: as for the agent, plus who handed it over
SELECT c.*, v.plate_number, m.name AS mrf_person_name, r.name AS ragpicker_name, r.photo_url
FROM collections c
LEFT JOIN vehicles v   ON v.id = c.vehicle_id
LEFT JOIN mrf_people m ON m.id = c.mrf_person_id
LEFT JOIN ragpickers r ON r.id = c.ragpicker_id
WHERE c.id = :id;
```

```
-- Approve
UPDATE collections SET status = 'APPROVED', verified_by_name = :my_name, verified_at = :now,
                       sync_state = 'pending'
WHERE id = :id;                                    -- outbox: POST /collections/{id}/approve

-- Reject (reason of at least 3 characters; the agent sees it as written)
UPDATE collections SET status = 'REJECTED', rejection_reason = :reason, rejection_remarks = :remarks,
                       verified_by_name = :my_name, verified_at = :now, sync_state = 'pending'
WHERE id = :id;                                    -- outbox: POST /collections/{id}/reject
```

A rejection gives the stock and the payment back on the server; the next`/bootstrap` brings the new balance and stock.

### Approvals and claims (expenses, cash, categories)

```
-- Expenses waiting
SELECT e.*, k.name AS category_name, ce.name AS center_name
FROM expenses e
LEFT JOIN expense_categories k ON k.id = e.category_id
JOIN centers ce ON ce.id = e.center_id
WHERE e.center_id IN (SELECT center_id FROM my_centers) AND e.status = 'PENDING'
ORDER BY e.created_at;

-- Cash requests waiting, with the center's balance beside each
SELECT r.*, b.balance FROM cash_requests r
LEFT JOIN center_balances b ON b.center_id = r.center_id
WHERE r.center_id IN (SELECT center_id FROM my_centers) AND r.status = 'PENDING'
ORDER BY r.created_at;

-- Category requests waiting
SELECT * FROM category_requests
WHERE center_id IN (SELECT center_id FROM my_centers) AND status = 'PENDING';
```

| Action | Local write | Outbox |
| --- | --- | --- |
| Approve / reject an expense | `UPDATE expenses SET status = :outcome, decided_by_name = :my_name, decision_reason = :reason, decision_remarks = :remarks, sync_state = 'pending'` | `POST /expenses/{id}/decide` (reason required when rejecting) |
| Approve / refuse cash | `UPDATE cash_requests SET status = :outcome, decided_by_name = :my_name, decision_note = :reason, decision_remarks = :remarks, sync_state = 'pending'` | `POST /cash-requests/{id}/decide` (optional`amount` sent) |
| Approve / refuse a category | `UPDATE category_requests SET status = :outcome, sync_state = 'pending'` | `POST /expense-categories/requests/{id}/decide` |

### Transfers

```
-- Transfer Requests list: one row per transfer with its item (one item per transfer).
-- :statuses by tab: Pending ('REQUESTED') · Approved ('APPROVED') · Dispatched ('DISPATCHED')
--                   · Closed ('RECEIVED','REJECTED') · All (every status)
SELECT t.id, t.number, t.type, t.status, t.center_id, ce.name AS center_name,
       t.destination_name, t.truck_expected_at, t.requested_by_name, t.requested_at,
       t.planned_vehicle_number, t.vehicle_differs, t.rejection_reason,
       ti.item_id, i.name AS item_name, i.unit_code, i.colour, ti.qty, ti.dispatched_qty
FROM transfers t
JOIN centers ce ON ce.id = t.center_id
LEFT JOIN transfer_items ti ON ti.transfer_id = t.id
LEFT JOIN items i ON i.id = ti.item_id
WHERE t.center_id IN (SELECT center_id FROM my_centers)
  AND t.status IN (:statuses)
  AND (:q IS NULL OR t.number LIKE '%' || :q || '%' OR t.requested_by_name LIKE '%' || :q || '%')
ORDER BY t.requested_at DESC;

-- Tab counts
SELECT status, COUNT(*) AS n FROM transfers
WHERE center_id IN (SELECT center_id FROM my_centers) GROUP BY status;

-- Detail: the transfer and its line
SELECT t.*, ce.name AS center_name FROM transfers t JOIN centers ce ON ce.id = t.center_id
WHERE t.id = :id;
SELECT ti.*, i.name, i.unit_code, i.colour FROM transfer_items ti JOIN items i ON i.id = ti.item_id
WHERE ti.transfer_id = :id;

-- Detail: free stock for that item at that centre, leaving this transfer out of "promised".
-- :qty_now = the Stock in hand query (Agent screens -> Transfers) for :center = t.center_id.
WITH promised AS (
  SELECT COALESCE(SUM(ti.qty), 0) AS qty
  FROM transfer_items ti JOIN transfers t ON t.id = ti.transfer_id
  WHERE t.center_id = :center AND ti.item_id = :item
    AND t.status IN ('REQUESTED', 'APPROVED') AND t.id <> :id
)
SELECT MAX(:qty_now - promised.qty, 0) AS qty_free FROM promised;

-- Approve form: where it can go (never the centre it leaves from) ...
SELECT id, name FROM destinations WHERE id <> :transfer_center_id ORDER BY name;
-- ... and the trucks to pick from, company trucks first (8 Oct 2026, part 4)
SELECT id, number, ownership, transporter_name, vehicle_type, capacity_kg
FROM transfer_vehicles ORDER BY ownership, number;
```

Approve and reject: the exact steps, SQL, bodies and answers are under*8 Oct 2026 (part 4)* below. Approving needs a destination**and a truck**; it can answer`422 OVER_STOCK` when other open transfers already claim the stock, or`422 VEHICLE_REQUIRED` /`FEE_REQUIRED` /`VEHICLE_INACTIVE` for the truck. The screens to build are described screen by screen in the Offline Data Guide,*Supervisor transfer screens*.

### Stock

```
SELECT ce.name AS center_name, i.name, i.unit_code, SUM(s.qty) AS qty
FROM stock s JOIN items i ON i.id = s.item_id JOIN centers ce ON ce.id = s.center_id
WHERE s.center_id IN (SELECT center_id FROM my_centers) AND s.stage = 'RM'
  AND (:center IS NULL OR s.center_id = :center)
GROUP BY s.center_id, s.item_id
ORDER BY ce.name, qty DESC;
```

### Tasks and requests

```
-- Everyone's tasks at my centers
SELECT * FROM tasks WHERE center_id IN (SELECT center_id FROM my_centers)
ORDER BY CASE status WHEN 'PENDING' THEN 0 ELSE 1 END, due_at;

-- Who a task can go to: agents at that center
SELECT user_id, name, phone FROM center_people
WHERE center_id = :center AND is_agent = 1 ORDER BY name;

-- Requests to answer
SELECT * FROM requests WHERE center_id IN (SELECT center_id FROM my_centers) AND status = 'OPEN'
ORDER BY CASE priority WHEN 'HIGH' THEN 0 WHEN 'NORMAL' THEN 1 ELSE 2 END, created_at;
```

Assign → insert into`tasks` with`status = 'PENDING'`,`assigned_by = :me`, queue`PUT /tasks/{id}`. Cancel a pending task →`status = 'CANCELLED'`, queue`POST /tasks/{id}/cancel`. Answer →`UPDATE requests SET status = 'CLOSED', answer = :notes, answered_at = :now`, queue`POST /requests/{id}/answer`.

### MRF person list

```
SELECT * FROM mrf_people
WHERE center_id = :center AND is_active = :active_tab
ORDER BY CASE role WHEN 'SUPERVISOR' THEN 0 ELSE 1 END, name;

-- Only one active MRF supervisor per center: check before making someone SUPERVISOR
SELECT id, name FROM mrf_people
WHERE center_id = :center AND role = 'SUPERVISOR' AND is_active = 1 AND id <> :id;
```

Writes:`PUT` /`PATCH /mrf-people/{id}`,`POST /mrf-people/{id}/status`, each with the row set`pending`.

### D2D vehicle list

```
-- This center's vans and the shared fleet (center_id null, managed on the web)
SELECT * FROM vehicles
WHERE (center_id = :center OR center_id IS NULL) AND is_active = :active_tab
ORDER BY center_id IS NULL, plate_number;

-- Plate already used? The server ignores spaces and hyphens
SELECT id FROM vehicles
WHERE REPLACE(REPLACE(UPPER(plate_number), '-', ''), ' ', '')
    = REPLACE(REPLACE(UPPER(:plate), '-', ''), ' ', '') AND id <> :id;
```

Writes:`PUT` /`PATCH /vehicles/{id}`,`POST /vehicles/{id}/status`.

### Agent status

```
SELECT p.user_id, p.name, p.phone, ce.name AS center_name,
       COUNT(c.id)                         AS collections_today,
       MAX(c.collected_at)                 AS last_collection_at,
       SUM(c.status = 'SUBMITTED')         AS waiting_review
FROM center_people p
JOIN centers ce ON ce.id = p.center_id
LEFT JOIN collections c ON c.agent_id = p.user_id AND c.center_id = p.center_id
                        AND c.status <> 'DRAFT' AND c.collected_at >= :today_start_utc
WHERE p.is_agent = 1 AND (:center IS NULL OR p.center_id = :center)
GROUP BY p.user_id, p.center_id
ORDER BY ce.name, p.name;
```

## Common screens

The same for both roles.

### Menu and role switch

```
-- Roles to switch between, and the menu of the one on screen
SELECT role_key, role_name, modules FROM my_roles ORDER BY role_key;
SELECT value FROM sync_meta WHERE key = 'active_role';
-- Show a menu entry only when its key is in that role's modules
SELECT 1 FROM my_roles, json_each(my_roles.modules)
WHERE role_key = :role AND json_each.value = :module_key;

-- Switching role: no call, just remember it
INSERT OR REPLACE INTO sync_meta (key, value) VALUES ('active_role', :role);
```

### Center picker

```
SELECT c.id, c.name, c.code, m.is_primary
FROM my_centers m JOIN centers c ON c.id = m.center_id
ORDER BY m.is_primary DESC, c.name;
```

### Notifications

```
-- The active role's first (20 Oct 2026); for_role_name labels the others
SELECT n.*, r.role_name AS for_role_name,
  CASE WHEN n.role IS NULL OR n.role = :active_role THEN 0 ELSE 1 END AS other_role
FROM notifications n
LEFT JOIN my_roles r ON r.role_key = n.role
ORDER BY other_role, n.created_at DESC;
SELECT COUNT(*) FROM notifications
WHERE read_at IS NULL AND (role IS NULL OR role = :active_role);   -- the bell's badge
SELECT role, COUNT(*) AS unread FROM notifications
WHERE read_at IS NULL AND role IS NOT NULL AND role <> :active_role
GROUP BY role;                                                     -- per other role, on the role switcher

-- Read one / read all
UPDATE notifications SET read_at = :now, sync_state = 'pending' WHERE id = :id AND read_at IS NULL;
UPDATE notifications SET read_at = :now, sync_state = 'pending' WHERE read_at IS NULL;
```

Outbox:`POST /notifications/{id}/read`, or one`POST /notifications/read-all`. Open`deep_link` (`eerl://collections/<id>` and the like) on tap.

### Profile

```
SELECT key, value FROM sync_meta
WHERE key IN ('user_name', 'user_phone', 'user_photo_url',
              'supervisor_name', 'supervisor_phone', 'supervisor_photo_url', 'session_expires_at');
```

### Sync status

```
-- Last successful sync
SELECT value FROM sync_meta WHERE key = 'last_bootstrap_at';

-- Waiting to send, and what failed (show the error, offer retry or discard)
SELECT status, COUNT(*) FROM outbox GROUP BY status;
SELECT seq, method, path, entity, entity_id, attempts, last_error FROM outbox
WHERE status = 'failed' ORDER BY seq;

-- Photos still to upload
SELECT COUNT(*) FROM photos WHERE status IN ('local', 'uploading', 'failed');

-- Retry a failed item
UPDATE outbox SET status = 'queued', next_attempt_at = NULL WHERE seq = :seq;
```

### Sign-out

Queue nothing: call`DELETE /devices/{token}` and`POST /auth/logout` if online, then wipe as in Sync → Sign-out.

## 6 Oct 2026 — Location on submit and handover, and item pictures

**What changes.** The phone now records where the agent is at two moments, and sends it with the request:

- when they press**Submit** on a collection;
- when they record a**truck handover** on a transfer.

Only latitude and longitude. GPS works with no signal, so the location is taken offline like everything else, kept in SQLite, and goes out with the outbox item.**Having no location never blocks anything**: GPS switched off, permission refused, or no fix in time all just send`null`, and the server accepts it.

| Step | How often |
| --- | --- |
| 1. Add two columns to`collections` and`transfers` | **Once**, when the app updates |
| 2. Take a fix and store it at Submit | **Every** collection submit |
| 3. Take a fix and store it at handover | **Every** handover |
| 4. Leave the columns alone during sync | **Every**`/bootstrap` (nothing to do, just don't overwrite) |

### 1. Once: add the columns

Bump the app's database version and run this once in its upgrade step. A fresh install gets the columns from the`CREATE TABLE` script above, which now includes them.

```
ALTER TABLE collections ADD COLUMN gps_lat REAL;
ALTER TABLE collections ADD COLUMN gps_lng REAL;
ALTER TABLE transfers   ADD COLUMN gps_lat REAL;
ALTER TABLE transfers   ADD COLUMN gps_lng REAL;
```

Rows already on the phone keep`NULL`: there is nothing to backfill. These columns are the phone's own;`/bootstrap` never sends them.

### 2. Every collection submit

When Submit is pressed, ask for one location fix. Wait a few seconds at most; if no fresh fix comes, use the last known one; if there is none, use`NULL`. Then store it in the same transaction as the rest of the submit (see**Submit** under Agent screens):

```
-- inside the submit transaction, beside the status / slip_number update
UPDATE collections
SET gps_lat = :lat, gps_lng = :lng            -- both NULL when there is no fix
WHERE id = :id;
```

Build the request body from the row, so a retry sends exactly what was stored:

```
SELECT gps_lat, gps_lng FROM collections WHERE id = :id;
```

```
"gps": { "lat": 21.1702, "lng": 72.8311 }
```

or`"gps": null` when both are`NULL`. It goes in the body of`POST /collections/{id}/submit`, beside`lines`.

- **Resubmitting a rejected collection:** send the stored`gps_lat` /`gps_lng` again. Don't take a new fix: like`collected_at`, the location says where the collection happened, not where it was corrected.
- **Drafts:** no location. A draft save sends no`gps`.

### 3. Every transfer handover

The same at handover: one fix (or`NULL`), stored with the rest of the handover, then sent.

```
-- the handover transaction: what the doc already sets, plus the location
UPDATE transfers
SET status = 'DISPATCHED', handed_over_at = :at, vehicle_plate = :plate,
    gps_lat = :lat, gps_lng = :lng,           -- both NULL when there is no fix
    sync_state = 'pending'
WHERE id = :id;

-- building the request body
SELECT gps_lat, gps_lng FROM transfers WHERE id = :id;
```

The body of`POST /transfers/{id}/handover` gains`"gps": { "lat": …, "lng": … }` or`"gps": null`.

>

**Timing:** the server accepts`gps` on handover only after the backend update that adds it is deployed. Until then that endpoint refuses fields it doesn't know (400), so leave`gps` out of the handover body until you are told it is live. Collection submit accepts`gps` already.

### 4. Every sync: leave the columns alone

`/bootstrap` does not send`gps_lat` /`gps_lng`. In Step 4, the`ON CONFLICT … DO UPDATE SET` for`collections` and`transfers` lists only the columns the server sends, so these two are never in it and a sync never wipes them. A record that arrives new from the server (made in the admin panel, or before the reinstall) simply has`NULL` there.

### What the server does with it

It stores the location on the collection and on the transfer's handover, and shows it to reviewers in the admin panel. Nothing is refused for a missing or odd location. The planned check that a collection is submitted*at* its centre (geofencing) will use these same fields; it is not built yet, and when it is, it will be announced here with what the app should show.

### Item pictures (`image_url`)

**What changes.** An admin can now give each material a picture in the admin panel. Every row of`items` from`/bootstrap` carries it as**`image_url`**: a public link to a small JPEG (at most 1024 px on its longer side), or`null` when no picture is set. The phone only shows it; it never changes it.

| Step | How often |
| --- | --- |
| 1. Add the column, then do one full download | **Once**, when the app updates |
| 2. Store`image_url` with each item | **Every**`/bootstrap` that sends`items` (already in Step 3) |
| 3. Download new or changed pictures, delete unused ones | **After every**`/bootstrap` that sends`items` |
| 4. Show the picture, or the colour | **Every** time items are listed on the collection screen |

#### 1. Once: add the column and refetch the items

```
ALTER TABLE items ADD COLUMN image_url TEXT;
```

Then, once after the upgrade, do a**Scope reset** (under*Sync*) so the next`/bootstrap` is a full download and`items` arrive again, this time with their pictures. As that section says, send the outbox until it is empty**first**: the reset deletes the synced data, so it must wait until nothing unsent is left (if the phone is offline at upgrade time, do it at the first moment it is online with an empty outbox). Without the reset, items already on the phone keep`image_url = NULL` until an admin next changes the item list, because`items` is only resent when it changes. (Clearing just the cursor is not enough: a full download sends no deletions, so rows removed on the server meanwhile would stay.)

**Order with the server update:** after the backend update is deployed,`/bootstrap` sends the new`image_url` key. If the app writes every key it receives straight into SQLite, add the column**before** that deploy, or the insert fails on an unknown column. If it maps columns one by one, either order is fine.

#### 2. Every`/bootstrap`: store it

Nothing new to write: Step 3's`INSERT INTO items` above already includes`image_url`.

#### 3. After every`/bootstrap` that sends`items`: keep the pictures on the phone

The picture has to show offline, so download it while there is signal and show the saved file. Key the saved file by its URL: a changed picture gets a new URL, so a URL already on disk never needs downloading again.

```
-- The pictures the phone should have
SELECT id, image_url FROM items WHERE image_url IS NOT NULL;
```

- For each URL with no saved file yet: download it and save it under a name made from the URL (for example its hash). A failed download is simply tried again after the next`/bootstrap`.
- Delete saved files whose URL is no longer in that list: the picture was replaced or removed.

#### 4. Showing it

- **New collection, step 3 (items):** the small thumbnail beside each item's name is the picture (`i.image_url` is already in that step's query). A tap opens it full size (Figma “Item Image”).
- **`image_url`is`NULL`, or its file isn't downloaded yet:** show the item's`colour` swatch in the same place.
- **Configure material list:** no picture there; it keeps the colour, as in Figma.

## 8 Oct 2026 — Transfer dispatch: vehicle and weighbridge photos, loaded weight

**What changes.** Dispatching a transfer is still**one call**,`POST /transfers/{id}/handover`, sent on**Submit Transfer**. Before it, the agent fills two screens:**Vehicle Details** (vehicle number, driver, vehicle photos;*Start Loading* only moves to the next screen) and**Weighbridge** (loaded weight, bales, weighbridge photos). The request body changes, and`transfers` gains five columns and stops using`photo_urls`. Ship the app update together with this server release: the old body is refused from it.

| Screen field | Request key | SQLite column | Rule |
| --- | --- | --- | --- |
| Vehicle number | `vehicleNumber` | `transfers.vehicle_plate` | Required, 4–20 characters, typed |
| Driver | `driverName` | `transfers.driver_name` (new) | Required, typed, not picked from a list |
| Vehicle photos | `vehiclePhotoUrls` | `transfers.vehicle_photo_urls` (new) | 1–10 photos |
| Loaded weight (KG) | `dispatchedWeight` | `transfers.dispatched_weight` (new) | Required, KG, more than 0 |
| Bales / boris | `baleCount` | `transfers.bale_count` (new) | Optional, 1–9999 |
| Weighbridge photos | `weighbridgePhotoUrls` | `transfers.weighbridge_photo_urls` (new) | Optional, 0–10 photos |
| Pieces loaded (a PCS item only) | `items[0].quantity` | `transfer_items.dispatched_qty` | Required when the item is counted in pieces |

Removed from the request, and from`handover` in every answer:`photoUrls`,`weighbridgeUsed`,`driverPhone`,`vehicleId`. Sending any of them now answers`400 VALIDATION_ERROR`. For a one-item transfer in KG leave`items` out: the loaded weight is the quantity taken off stock.

### 1. Once: add the columns, then a Scope reset

Bump the app's database version and run these in the upgrade step. Fresh installs get them from the`CREATE TABLE` script above.

```
ALTER TABLE transfers ADD COLUMN driver_name TEXT;
ALTER TABLE transfers ADD COLUMN dispatched_weight REAL;
ALTER TABLE transfers ADD COLUMN bale_count INTEGER;
ALTER TABLE transfers ADD COLUMN vehicle_photo_urls TEXT NOT NULL DEFAULT '[]';
ALTER TABLE transfers ADD COLUMN weighbridge_photo_urls TEXT NOT NULL DEFAULT '[]';
-- photo_urls is no longer sent. Leave the column on upgraded phones and stop
-- reading or writing it: DROP COLUMN needs SQLite 3.35, which older Android lacks.
```

Then do one**Scope reset** (under*Sync*), after the server release is live, so the next`/bootstrap` is a full one and transfers already on the phone come back with the new columns filled. Without it, old dispatched transfers keep empty photo lists and no weight until they change on the server.

### 2. Vehicle Details → Start Loading: keep the values, no call

Nothing is sent yet and the transfer stays`APPROVED`. Keep the typed values in`sync_meta` and the photos in`photos`, so the agent can close the app mid-loading and carry on. Do not write them on the`transfers` row yet: a`/bootstrap` in between would overwrite a`synced` row.

```
BEGIN;
INSERT OR REPLACE INTO sync_meta (key, value)
VALUES ('dispatch_draft:' || :id, json_object('vehicleNumber', :plate, 'driverName', :driver));

-- one row per vehicle photo, as it is taken
INSERT INTO photos (id, owner_table, owner_id, field, purpose, content_type, local_path, status, created_at)
VALUES (:photo_id, 'transfers', :id, 'vehicle', 'TRANSFER_HANDOVER', 'image/jpeg', :path, 'local', :now);
COMMIT;

-- reopening the screens
SELECT json_extract(value, '$.vehicleNumber') AS plate, json_extract(value, '$.driverName') AS driver
FROM sync_meta WHERE key = 'dispatch_draft:' || :id;
SELECT id, local_path FROM photos
WHERE owner_table = 'transfers' AND owner_id = :id AND field = 'vehicle' ORDER BY created_at;
```

Photos may start uploading straight away (purpose`TRANSFER_HANDOVER`), as under*Outbox → Photos*. A removed photo:`DELETE FROM photos WHERE id = :photo_id`.

### 3. Submit Transfer: one transaction, one outbox item

Weighbridge photos go into`photos` with`field = 'weighbridge'` as they are taken, like the vehicle photos. On Submit:

```
BEGIN;
UPDATE transfers
SET status = 'DISPATCHED', handed_over_at = :now_utc,
    vehicle_plate = :plate, driver_name = :driver,
    dispatched_weight = :weight_kg,
    bale_count = :bales,                  -- NULL when left empty
    gps_lat = :lat, gps_lng = :lng,       -- 6 Oct 2026; both NULL with no fix
    sync_state = 'pending'
WHERE id = :id AND status = 'APPROVED';

-- What left. A one-item transfer in KG: the loaded weight. A PCS item: the pieces typed.
UPDATE transfer_items SET dispatched_qty = :weight_kg_or_pieces WHERE transfer_id = :id;

INSERT INTO outbox (method, path, body, entity, entity_id, kind, refs, status, created_at)
VALUES ('POST', '/transfers/' || :id || '/handover', :body_json, 'transfers', :id, 'handover', '[]', 'queued', :now);
-- :seq = last_insert_rowid(), read once here

-- every photo of both screens must upload before it sends
INSERT INTO outbox_photos (outbox_seq, photo_id)
SELECT :seq, id FROM photos
WHERE owner_table = 'transfers' AND owner_id = :id AND field IN ('vehicle', 'weighbridge');

DELETE FROM sync_meta WHERE key = 'dispatch_draft:' || :id;
COMMIT;
```

The body, as queued (photos as local photo ids; the sender swaps in each`remote_url`):

```
{
  "centerId": "9f1c…",
  "handedOverAt": "2026-10-08T06:30:00.000Z",
  "vehicleNumber": "GJ-05-AB-1234",
  "driverName": "Pankaj Tripathi",
  "vehiclePhotoUrls": ["<photo id>", "<photo id>"],
  "dispatchedWeight": 900,
  "baleCount": 12,
  "weighbridgePhotoUrls": ["<photo id>"],
  "gps": { "lat": 21.1702, "lng": 72.8311 }
}
```

- A PCS item adds`"items": [{ "itemId": "…", "quantity": 40 }]` (pieces). A KG item leaves`items` out.
- No bales typed: leave`baleCount` out. No weighbridge photos: send`[]` or leave the key out. Since part 2, null works for every optional key too.
- Building the two lists when sending:

```
SELECT field, remote_url FROM photos
WHERE owner_table = 'transfers' AND owner_id = :id AND field IN ('vehicle', 'weighbridge')
ORDER BY created_at;
```

### 4. Every`/bootstrap`: store the new columns

`transfers` rows now carry`driver_name`,`dispatched_weight`,`bale_count`,`vehicle_photo_urls` and`weighbridge_photo_urls`, and no`photo_urls`. Step 4's upsert for`transfers` becomes:

```
INSERT INTO transfers (id, center_id, type, status, number, destination_id, destination_name,
  truck_expected_at, fixed_qty, estimated_expense, vehicle_plate, driver_name, requested_by,
  requested_by_name, requested_at, decided_by_name, approved_at, rejection_reason, handed_over_at,
  dispatched_weight, bale_count, vehicle_photo_urls, weighbridge_photo_urls, updated_at, sync_state)
VALUES (…, 'synced')
ON CONFLICT (id) DO UPDATE SET
  status = excluded.status, number = excluded.number, /* …every column it sends… */
  vehicle_plate = excluded.vehicle_plate, driver_name = excluded.driver_name,
  dispatched_weight = excluded.dispatched_weight, bale_count = excluded.bale_count,
  vehicle_photo_urls = excluded.vehicle_photo_urls,
  weighbridge_photo_urls = excluded.weighbridge_photo_urls,
  updated_at = excluded.updated_at, sync_state = 'synced'
WHERE transfers.sync_state = 'synced';
```

`gps_lat` /`gps_lng` stay out of it, as on 6 Oct. Once the handover is answered, the photos of both screens are uploaded rows: the usual clean-up applies.

### 5. Showing a dispatched transfer, and the errors

```
SELECT number, destination_name, vehicle_plate, driver_name, handed_over_at,
       dispatched_weight, bale_count
FROM transfers WHERE id = :id;

SELECT value AS url FROM json_each((SELECT vehicle_photo_urls     FROM transfers WHERE id = :id));
SELECT value AS url FROM json_each((SELECT weighbridge_photo_urls FROM transfers WHERE id = :id));

-- before the server has answered: the copies on the phone
SELECT field, local_path FROM photos
WHERE owner_table = 'transfers' AND owner_id = :id AND field IN ('vehicle', 'weighbridge');
```

- The vehicle and driver belong under the agent's dispatch, not under "From Collection Manager": the manager gives only`truck_expected_at`.
- After Submit, show**Dispatched**.`RECEIVED` comes later, when the receiving site confirms on the web.

| Answer | When | What to show |
| --- | --- | --- |
| `422 INVALID_TRANSFER`,`items` /`REQUIRED` | A PCS item with no pieces, or more than one item | "Enter how many pieces went" |
| `422`,`dispatchedWeight` or`items.0.quantity` /`OVER_STOCK` | More than the center holds | The message, which gives the stock |
| `422`,`vehiclePhotoUrls.N` or`weighbridgePhotoUrls.N` /`PHOTO_NOT_UPLOADED` | A photo did not reach storage | Re-upload, then resend |
| `409 ALREADY_DISPATCHED` | Sent before with other details | Keep the server's version |
| `409 NOT_APPROVED` /`REJECTED` | Not ready, refused, or cancelled after approval (part 2) | As before |
| `400 VALIDATION_ERROR` | An old key sent (`photoUrls`,`weighbridgeUsed`,`driverPhone`,`vehicleId`) | A bug: fix the body |

### Design notes: where the Figma and the build differ

No API change for these; build them as written here, not as drawn.

**Dispatch (Vehicle Details and Weighbridge)**

- "Weighbridge Slip" becomes**Weighbridge photos**: several allowed, optional.
- Drop the KG/PCS toggle. Label the box**Loaxded weight (KG)**; for an item counted in pieces, add**Pieces loaded**.
- No "weighbridge used?" question: the weight is always asked, the slip photos when there are any.
- "Driver Detail — Select Driver Name" is a typed name. There is no driver phone.
- "Transfer Completed!" after Submit becomes**Dispatched**.

**Raising a request**

- One item per request (the radio buttons). Send`items: [{ "itemId", "quantity" }]` with one entry.
- Add a**quantity** box on the selected item, no more than`qty_now` (*Agent screens → Transfers*). The design has no box, but the API needs the quantity.
- **Estimated expense** once per request (`estimatedExpense`), not inside the item card. Required in the app.
- Label stock**Stock in hand** everywhere: no "Capacity", no "Total KG" bar.
- No destination step: the request has no destination field, and the supervisor or admin picks it on approval.
- After approval, show "Truck arrives …" from`truck_expected_at`, not "Estimate Time to Reach".

**D2D vehicles (since 6 Oct, no app change)**

- `vehicles` in`/bootstrap` are the municipal D2D vehicles of each center; new ones always have a`center_id`. A row with`center_id` null is an old shared one, shown at every center until an admin assigns it.
- Transfer trucks are never picked from`vehicles`: they are typed at dispatch.

## 8 Oct 2026 (part 2) — Free stock, transfers changed or cancelled after approval, null for empty fields

**What changes.** No table, column or migration changes: the current app keeps working against the new server. Four behaviours change; steps 2 and 4 below are what the app should add so the agent never meets a confusing error. Everything here is live once the server is deployed.

| Change | What the phone sees | App change |
| --- | --- | --- |
| Empty optional fields | `null` is accepted wherever a key is optional (list in step 1). Before,`null` got`400 VALIDATION_ERROR` (e.g.`note` /`INVALID_TYPE` on the dispatch). | None. Send`null` or leave the key out. |
| Free stock | Raising a transfer is refused with`OVER_STOCK` when other open transfers already claim the stock, even if stock in hand looks enough. A supervisor's approve can answer`422 OVER_STOCK` for the same reason. | Recommended: cap the quantity at`qty_free` (step 2). |
| Changed after approval | The admin can move the destination or the truck time until the truck is loaded.`destination_id`,`destination_name` and`truck_expected_at` change on the next sync, with a`TRANSFER_APPROVED` notification titled "Transfer changed". | None: Step 4's upsert already writes them. |
| Cancelled after approval | The admin can call off an approved transfer before loading. It arrives as`status = 'REJECTED'`,`rejection_reason` = "Cancelled after approval: <reason>", with a`TRANSFER_REJECTED` notification titled "Transfer cancelled". No new status. A dispatch queued for it gets`409 REJECTED`. | Recommended: clear its dispatch draft and drop the queued dispatch (step 4). |

### 1. Empty optional fields: null or left out

Both now mean "nothing typed". The keys:

- `POST /transfers/{id}/handover`:`baleCount`,`weighbridgePhotoUrls`,`items`,`note`,`gps`.
- `PUT /transfers/{id}`:`estimatedExpense`,`note`.
- `POST /transfers/{id}/approve` (supervisor):`note`.
- `PUT /expenses/{id}`:`note`.
- `POST /tasks/{id}/complete`:`note`.

Required keys are unchanged:`null` there is still`400`.

### 2. Free stock when raising a transfer (recommended)

The server checks each item against what is**free**: stock in hand, less what the center's other open transfers (`REQUESTED` or`APPROVED`, not yet loaded) already ask for. The agent's own earlier requests count too. Use the*Free to send* query under*Agent screens → Transfers*: show`qty_free`, and do not let the agent type more.

```
-- The most one line may ask for. :item is the item being typed.
WITH promised AS (
  SELECT COALESCE(SUM(ti.qty), 0) AS qty
  FROM transfer_items ti JOIN transfers t ON t.id = ti.transfer_id
  WHERE t.center_id = :center AND ti.item_id = :item
    AND t.status IN ('REQUESTED', 'APPROVED')
)
SELECT MAX(:qty_now - promised.qty, 0) AS qty_free FROM promised;   -- :qty_now from the stock query
```

If the server still refuses (another agent raised one first), the outbox answer is`422 INVALID_TRANSFER` with`items.N.quantity` /`OVER_STOCK` in`details`. Park it as failed as today and show that detail's message, which gives the figures: "This center holds 100 of that item and 70 is already on other open transfers, so 30 can still go."

### 3. A transfer changed after approval

Nothing to add. The row comes again in`/bootstrap` and Step 4 overwrites`destination_id`,`destination_name` and`truck_expected_at` (it is`synced`). A dispatch draft in`sync_meta` stays valid: it is keyed by the transfer id. The server refuses a change once the truck is loaded, so a row with a queued dispatch never changes under it.

### 4. A transfer cancelled after approval

**a. After every`/bootstrap`**, in the same transaction after Step 4: drop dispatch drafts for transfers that are now rejected. Delete the photo files on disk for the rows removed here.

```
DELETE FROM sync_meta
WHERE key IN (SELECT 'dispatch_draft:' || id FROM transfers WHERE status = 'REJECTED');

DELETE FROM photos
WHERE owner_table = 'transfers' AND field IN ('vehicle', 'weighbridge')
  AND owner_id IN (SELECT id FROM transfers WHERE status = 'REJECTED')
  AND id NOT IN (SELECT photo_id FROM outbox_photos);
```

If Vehicle Details or Weighbridge is open for that transfer, close it and say "This transfer was cancelled" with the reason.

**b. When the dispatch answers`409 REJECTED`.** The agent pressed Submit Transfer offline and the admin cancelled it before it reached the server. Do not park it as failed: drop it.

```
BEGIN;
DELETE FROM outbox_photos WHERE outbox_seq = :seq;
DELETE FROM outbox WHERE seq = :seq;
DELETE FROM photos
WHERE owner_table = 'transfers' AND owner_id = :id AND field IN ('vehicle', 'weighbridge');
UPDATE transfer_items SET dispatched_qty = NULL WHERE transfer_id = :id;
UPDATE transfers
SET status = 'REJECTED', handed_over_at = NULL, vehicle_plate = NULL, driver_name = NULL,
    dispatched_weight = NULL, bale_count = NULL, gps_lat = NULL, gps_lng = NULL,
    sync_state = 'synced'
WHERE id = :id;
COMMIT;
```

Then call`GET /transfers/{id}` and write the reason. This call is needed: a`/bootstrap` that brought the rejection while the dispatch was still queued skipped the row (Step 4 overwrites only`synced` rows), and that change will not be sent again.

```
UPDATE transfers
SET rejection_reason = :reason,          -- data.rejection.reason
    decided_by_name  = :decided_by_name, -- data.rejection.by.name
    approved_at      = :decided_at       -- data.rejection.at
WHERE id = :id;
```

**c. Showing it.** A cancelled transfer is an ordinary rejected card. To label it "Cancelled" instead of "Rejected":

```
SELECT t.*, (t.rejection_reason LIKE 'Cancelled after approval:%') AS cancelled
FROM transfers t WHERE t.id = :id;
```

### 5. Errors

| Answer | When | What to show |
| --- | --- | --- |
| `422 INVALID_TRANSFER`,`items.N.quantity` /`OVER_STOCK` | Raising more than is free | The detail's message, which gives the figures |
| `422 OVER_STOCK`,`items.N.quantity` | A supervisor approving a request whose stock other open transfers already claim | The message; the row stays`REQUESTED` |
| `409 REJECTED` | Dispatching a transfer that was refused or cancelled after approval | Step 4b |
| `400 VALIDATION_ERROR` on a`null` optional key | No longer sent from this release | — |

No notification types are new: "Transfer changed" is`TRANSFER_APPROVED` and "Transfer cancelled" is`TRANSFER_REJECTED`, both deep-linking to`eerl://transfers/{id}`.

## 8 Oct 2026 (part 3) — Category requests: who asked and the decision; slip numbers explained

**What changes.** A category request now says who asked, who decided, when, and why it was rejected. Until now the agent saw a rejected request with no reason, and the supervisor's list could not name who asked. The "Reason/Description" box on Request New Category is unchanged: it is`reason`, as before. Slip numbers do not change: the new*Slip numbers* section under*Agent screens* explains the rule the app already follows.

| Column on`category_requests` | From`/bootstrap` | Shown where |
| --- | --- | --- |
| `requested_by_name` | `requested_by_name` | Supervisor's Category Request list |
| `decided_by_name` | `decided_by_name` (null while pending) | Agent's request card, once decided |
| `decided_at` | `decided_at` (null while pending) | Agent's request card |
| `decision_reason` | `decision_reason` (why it was rejected; null when approved) | Agent's rejected card |

### 1. Once: add the columns

```
ALTER TABLE category_requests ADD COLUMN requested_by_name TEXT;
ALTER TABLE category_requests ADD COLUMN decided_by_name TEXT;
ALTER TABLE category_requests ADD COLUMN decided_at TEXT;
ALTER TABLE category_requests ADD COLUMN decision_reason TEXT;
```

Then one**Scope reset** (under*Sync*), after the server release, so rows already on the phone come again with the new columns. Before that release the columns simply stay null.

### 2. Every`/bootstrap`: store them

```
INSERT INTO category_requests (id, number, center_id, requested_by, requested_by_name, name, reason,
  status, decided_by_name, decided_at, decision_reason, created_at, sync_state)
VALUES (:id, :number, :center_id, :requested_by, :requested_by_name, :name, :reason,
  :status, :decided_by_name, :decided_at, :decision_reason, :created_at, 'synced')
ON CONFLICT (id) DO UPDATE SET
  number = excluded.number, requested_by_name = excluded.requested_by_name,
  name = excluded.name, reason = excluded.reason, status = excluded.status,
  decided_by_name = excluded.decided_by_name, decided_at = excluded.decided_at,
  decision_reason = excluded.decision_reason, created_at = excluded.created_at,
  sync_state = 'synced'
WHERE category_requests.sync_state = 'synced';
```

### 3. Asking for a category

The body is unchanged;`reason` is the Reason/Description box and may be`null` or left out:

```
{ "centerId": "15c937a9…", "name": "Tyre repair", "reason": "Punctures on the D2D round" }
```

The answer now also carries`requestedBy` (`id`,`name`) and`decision` (`null` while pending, else`by`,`at`,`reason`). On a 2xx:

```
UPDATE category_requests
SET number = :number, requested_by_name = :requested_by_name, sync_state = 'synced'
WHERE id = :id
  AND NOT EXISTS (SELECT 1 FROM outbox WHERE entity = 'category_requests' AND entity_id = :id);
```

### 4. Supervisor: deciding one offline

Write the decision locally the same way the server will, so the card is right before the sync:

```
UPDATE category_requests
SET status = :outcome,                 -- APPROVED | REJECTED
    decided_by_name = :my_name, decided_at = :now_utc,
    decision_reason = :reason,         -- NULL when approving
    sync_state = 'pending'
WHERE id = :id;
```

### 5. Showing it

- **Agent:** the*Categories I asked for* query under*Agent screens → Expenses* lists waiting and decided requests. A rejected card shows`decision_reason`, and`decided_by_name` with`decided_at`.
- **Supervisor:** the*Category requests waiting* query already selects every column; show`requested_by_name` and`reason` on each card.

## 8 Oct 2026 (part 4) — Supervisor transfer screens; the truck is arranged at approval

**What changes.** The supervisor approves and rejects transfers in the app (the manager's CM-M03 screens, moved to the supervisor; what to change on each screen is in the Offline Data Guide,*Supervisor transfer screens*). Approving a stock transfer now**requires the truck**: one from the company's**Transfer Vehicles** list, or a hired truck typed in with its fee. The agent sees the arranged truck on the approved card and in Vehicle Details, pre-filled; a different truck at dispatch is accepted and flagged. The fee is the approvers' business: an agent's phone always has`transfer_fee` null.`TRANSFERS` is now in the supervisor's`roles[].modules`.

| What | Where | Who sees it |
| --- | --- | --- |
| `transfer_vehicles` (new table) | `/bootstrap` reference data,`replace` | Approvers only (the supervisor). An agent never gets it. |
| `transfers.transfer_vehicle_id`,`planned_vehicle_number`,`planned_vehicle_ownership`,`transporter_name` | `/bootstrap` transfer rows | Everyone at the centre |
| `transfers.transfer_fee` | `/bootstrap` transfer rows | Approvers; null for an agent |
| `transfers.vehicle_differs` | `/bootstrap` transfer rows | Everyone at the centre |
| `vehicle` in`POST /transfers/{id}/approve` | Outbox body | Required for`STOCK_TRANSFER` |

### 1. Once: the table and the columns

```
CREATE TABLE transfer_vehicles (
  id TEXT PRIMARY KEY,
  number TEXT NOT NULL,
  ownership TEXT NOT NULL,              -- COMPANY | HIRED
  transporter_name TEXT,
  vehicle_type TEXT, capacity_kg REAL
);
ALTER TABLE transfers ADD COLUMN transfer_vehicle_id TEXT;
ALTER TABLE transfers ADD COLUMN planned_vehicle_number TEXT;
ALTER TABLE transfers ADD COLUMN planned_vehicle_ownership TEXT;
ALTER TABLE transfers ADD COLUMN transporter_name TEXT;
ALTER TABLE transfers ADD COLUMN transfer_fee REAL;
ALTER TABLE transfers ADD COLUMN vehicle_differs INTEGER NOT NULL DEFAULT 0;
```

Then one**Scope reset** (under*Sync*) after the server release, so the supervisor's first download brings`transfer_vehicles` and existing transfer rows come back with the new columns. Add`DELETE FROM transfer_vehicles;` to the Scope reset (done above).

### 2. Every`/bootstrap`

`transfer_vehicles` arrives whole as`replace`, like`destinations`:

```
DELETE FROM transfer_vehicles;
INSERT INTO transfer_vehicles (id, number, ownership, transporter_name, vehicle_type, capacity_kg)
VALUES (:id, :number, :ownership, :transporter_name, :vehicle_type, :capacity_kg);   -- per row
```

The Step 4 upsert for`transfers` becomes (it replaces the one under*8 Oct 2026*, step 4):

```
INSERT INTO transfers (id, center_id, type, status, number, destination_id, destination_name,
  truck_expected_at, dispatch_note, transfer_vehicle_id, planned_vehicle_number, planned_vehicle_ownership,
  transporter_name, transfer_fee, fixed_qty, estimated_expense, vehicle_plate, driver_name,
  requested_by, requested_by_name, requested_at, decided_by_name, approved_at, rejection_reason,
  rejection_remarks, handed_over_at, dispatched_weight, bale_count, vehicle_photo_urls,
  weighbridge_photo_urls, vehicle_differs, updated_at, sync_state)
VALUES (…, 'synced')
ON CONFLICT (id) DO UPDATE SET
  status = excluded.status, number = excluded.number,
  destination_id = excluded.destination_id, destination_name = excluded.destination_name,
  truck_expected_at = excluded.truck_expected_at,
  dispatch_note = excluded.dispatch_note,           -- 12 Oct 2026
  transfer_vehicle_id = excluded.transfer_vehicle_id,
  planned_vehicle_number = excluded.planned_vehicle_number,
  planned_vehicle_ownership = excluded.planned_vehicle_ownership,
  transporter_name = excluded.transporter_name, transfer_fee = excluded.transfer_fee,
  fixed_qty = excluded.fixed_qty, estimated_expense = excluded.estimated_expense,
  vehicle_plate = excluded.vehicle_plate, driver_name = excluded.driver_name,
  decided_by_name = excluded.decided_by_name, approved_at = excluded.approved_at,
  rejection_reason = excluded.rejection_reason,
  rejection_remarks = excluded.rejection_remarks,   -- 23 Oct 2026
  handed_over_at = excluded.handed_over_at,
  dispatched_weight = excluded.dispatched_weight, bale_count = excluded.bale_count,
  vehicle_photo_urls = excluded.vehicle_photo_urls,
  weighbridge_photo_urls = excluded.weighbridge_photo_urls,
  vehicle_differs = excluded.vehicle_differs, updated_at = excluded.updated_at,
  sync_state = 'synced'
WHERE transfers.sync_state = 'synced';
```

### 3. Supervisor: approve (queued offline)

Check before queuing, with these messages:

| Field | Rule | Message |
| --- | --- | --- |
| Send it to | Required | "Choose where the material is going." |
| Truck | Required | "Choose the truck that will take it." |
| Truck fee | Required when the truck is`HIRED` (listed or typed); 0 or more, 2 decimals at most | "Enter the fee in rupees for this hired truck." |
| Vehicle number (typed hired truck) | 4–20 characters, saved in capitals | "Enter the number as on the plate." |
| Transporter (typed hired truck) | Optional, up to 255 | — |
| Truck expected | Optional, IST date and time, sent as UTC | — |
| Note | Optional, up to 255 | — |

```
BEGIN;
UPDATE transfers
SET status = 'APPROVED',
    destination_id = :destination_id, destination_name = :destination_name,
    truck_expected_at = :truck_utc,                     -- NULL when left empty
    transfer_vehicle_id = :transfer_vehicle_id,         -- NULL for a hired truck typed in
    planned_vehicle_number = :number, planned_vehicle_ownership = :ownership,
    transporter_name = :transporter_name,               -- NULL for a company truck
    transfer_fee = :fee,                                -- 0 for a company truck
    dispatch_note = :note,                              -- NULL when left empty (12 Oct 2026)
    decided_by_name = :my_name, approved_at = :now_utc,
    sync_state = 'pending'
WHERE id = :id AND status = 'REQUESTED';

INSERT INTO outbox (method, path, body, entity, entity_id, kind, refs, status, created_at)
VALUES ('POST', '/transfers/' || :id || '/approve', :body_json, 'transfers', :id, 'approve', '[]', 'queued', :now_utc);
COMMIT;
```

The body, one of three:

```
{ "destinationFacilityId": "ed6cf8f9…", "vehicleArrivalTime": "2026-10-10T04:30:00.000Z",
  "vehicle": { "transferVehicleId": "<company truck id>" }, "note": null }

{ "destinationFacilityId": "ed6cf8f9…", "vehicleArrivalTime": null,
  "vehicle": { "transferVehicleId": "<hired truck id>", "transferFee": 1800 } }

{ "destinationFacilityId": "ed6cf8f9…", "vehicleArrivalTime": "2026-10-10T04:30:00.000Z",
  "vehicle": { "vehicleNumber": "MH-04-AB-777", "transporterName": "One-off Movers", "transferFee": 2200 } }
```

### 4. Supervisor: reject (queued offline)

The reason is the ticked boxes joined with ", ", e.g.`"No vehicle available, Incorrect material / weight details"` (3–1000 characters). The Remarks box goes apart in`remarks`, e.g.`"All yard trucks are out, try after 2 PM."`, or`NULL` when empty (23 Oct 2026; before that the server refused`remarks` and they were joined into the reason).

```
BEGIN;
UPDATE transfers
SET status = 'REJECTED', rejection_reason = :reason, rejection_remarks = :remarks,
    decided_by_name = :my_name, approved_at = :now_utc, sync_state = 'pending'
WHERE id = :id AND status = 'REQUESTED';
INSERT INTO outbox (method, path, body, entity, entity_id, kind, refs, status, created_at)
VALUES ('POST', '/transfers/' || :id || '/reject', json_object('reason', :reason, 'remarks', :remarks),
        'transfers', :id, 'reject', '[]', 'queued', :now_utc);
COMMIT;
```

### 5. The answers

| Answer | What to do |
| --- | --- |
| `200` | Done: as*Outbox → Handle the answer* (mark`synced` once nothing else is waiting). |
| `409 NOT_PENDING` | Someone decided it first. Drop the outbox item, then`GET /transfers/{id}` and write its status and decision into the row,`sync_state = 'synced'`. |
| `422 OVER_STOCK` | Other open transfers already claim the stock. Undo the local approval (below) and show the message. The supervisor rejects one of the competing requests. |
| `422 VEHICLE_REQUIRED`,`FEE_REQUIRED`,`VEHICLE_INACTIVE`,`VEHICLE_NOT_FOUND` | The truck was missing, had no fee, or was switched off since the last sync. Undo the local approval and show the message; the supervisor picks again after a sync. |
| `404` | Not at your centre any more. Drop it. |

```
-- Undo a refused approval: back to waiting, nothing queued
BEGIN;
DELETE FROM outbox WHERE seq = :seq;
UPDATE transfers
SET status = 'REQUESTED', destination_id = NULL, destination_name = NULL,
    truck_expected_at = NULL, transfer_vehicle_id = NULL, planned_vehicle_number = NULL,
    planned_vehicle_ownership = NULL, transporter_name = NULL, transfer_fee = NULL,
    decided_by_name = NULL, approved_at = NULL, sync_state = 'synced'
WHERE id = :id;
COMMIT;
```

### 6. Agent: the arranged truck

```
-- Approved card: where, when, which truck, and the note for the agent (12 Oct 2026)
SELECT number, destination_name, truck_expected_at, planned_vehicle_number, dispatch_note
FROM transfers WHERE id = :id;

-- Vehicle Details opens with the number already typed: the agent's draft if any, else the arranged truck
SELECT COALESCE(json_extract(m.value, '$.vehicleNumber'), t.planned_vehicle_number) AS plate
FROM transfers t
LEFT JOIN sync_meta m ON m.key = 'dispatch_draft:' || t.id
WHERE t.id = :id;
```

The agent may change the number if a different truck came. Nothing else changes in the dispatch: the server compares the numbers (letters and digits only) and sets`vehicle_differs`.

### 7. Showing it

- **Supervisor, approved transfer:** "Truck*GJ-05-EE-1001* · Company truck" or "· Hired from*Shree Ram Transport* ", and "Truck fee ₹*1,800* " ("No fee" for a company truck).
- **Supervisor, dispatched transfer:** when`vehicle_differs = 1`, a**"Different truck"** badge beside the truck the agent loaded (`vehicle_plate`).
- **Agent:** the truck number on the approved card; never the fee (it is null on the agent's phone).

## 12 Oct 2026 — Materials get`is_active`

**What changes.** Every`items` row in`/bootstrap` now carries`is_active`. A material the admin switches off keeps arriving, with`0`, instead of vanishing, so old collections, transfers and stock still show its name. It has no`center_items` rows, so neither picker offers it. Switching it back on brings back its rows with the place and tick it had. No endpoint changes.

### 1. Once: the column

```
ALTER TABLE items ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1;
```

No scope reset: the default fills the rows already on the phone, and`items` arrives whole (`replace`) whenever any material changes.

### 2. Every`/bootstrap`

Step 3's insert into`items` takes the new column:

```
DELETE FROM items;
INSERT INTO items (id, name, category_name, material_type, colour, image_url,
                   hsn_code, unit_code, unit_name, is_active)
VALUES (…);                                                -- per row
```

### 3. Collection form: offer only active materials

The whole query, with the one new line:

```
-- The items this center offers on this channel, in the saved order, with today's rate
SELECT i.id, i.name, i.unit_code, i.unit_name, i.colour, i.image_url, i.material_type,
       CASE WHEN ch.show_price = 1 THEN ci.rate END AS rate
FROM center_items ci
JOIN items i            ON i.id = ci.item_id
JOIN center_channels ch ON ch.center_id = ci.center_id AND ch.channel = ci.channel
WHERE ci.center_id = :center AND ci.channel = :channel AND ci.is_selected = 1
  AND i.is_active = 1                   -- new: never offer a switched-off material
ORDER BY ci.sort_order;
```

### 4. Configure Material List: list and save only active materials

The whole tab query and the save, with the one new line. A switched-off material is not shown, so it is not in the saved list either:

```
-- One tab: PLASTIC, or NON_PLASTIC (which also holds MIXED)
SELECT i.id, i.name, i.colour, ci.is_selected, ci.sort_order
FROM center_items ci JOIN items i ON i.id = ci.item_id
WHERE ci.center_id = :center AND ci.channel = :channel
  AND i.is_active = 1                   -- new
  AND (CASE WHEN :tab = 'PLASTIC' THEN i.material_type = 'PLASTIC'
            ELSE i.material_type IN ('NON_PLASTIC', 'MIXED') END)
ORDER BY ci.is_selected DESC, ci.sort_order;

-- Save the tab: every row shown above, in the order shown (unchanged)
UPDATE center_items SET is_selected = :sel, sort_order = :pos, sync_state = 'pending'
WHERE center_id = :center AND channel = :channel AND item_id = :item_id;   -- per item
-- outbox: PUT /item-config with centerId, collectionChannel, tab and items (the rows shown)
```

### 5. Naming a material on old records: no change

Collection history and detail, transfers and stock look a material up by`item_id` to show its name, unit, colour and picture. Those queries stay as they are and must**not** filter on`is_active`, so a switched-off material keeps its name on old records.

### 6. Stock of a switched-off material

Stock in hand and Free to send join`stock` to`items`. Until now a switched-off material had no`items` row, so its stock silently dropped out of both lists. It now shows, and can still be sent on a transfer: that is intended, since material on hand still has to leave. No query change.

### 7. Order of work

Add the column (step 1) before, or in the same release as, anything else: if the app inserts`items` rows with every key it receives, the insert fails until the column exists. Steps 2 to 4 can follow. Until they ship, the collection form and Configure Material List still cannot show a switched-off material, because it has no`center_items` rows.

## 12 Oct 2026 — Ragpicker phones are the 10 digits, without +91

**What changes.** A ragpicker's phone is stored and returned as the 10 digits the person gave, e.g.`9700000009`, never`+919700000009`. MRF people's and users' phones keep`+91`. No table, column or query changes.

**Sending.**`PUT /ragpickers/{id}` and`PATCH /ragpickers/{id}` still accept`9700000009` or`+919700000009`; the server drops the +91 and answers with the 10 digits. Keep the row the answer returns.

**Numbers already on the phone.** Older ragpicker numbers on the server are cleaned once, after the release. That change arrives with the next`/bootstrap` as a new`ragpickers``replace`, and the usual Step 3 refreshes them:

```
DELETE FROM ragpickers WHERE sync_state = 'synced';
INSERT OR IGNORE INTO ragpickers (id, center_id, name, phone, id_number, photo_url, is_active)
VALUES (:id, :center_id, :name, :phone, :id_number, :photo_url, :is_active);          -- per row
```

**Showing it.** Show the number as stored. If a screen adds a prefix for display, add it only when the stored number has none.

## 12 Oct 2026 — Requests carry a required follow-up date and time

**What changes.** Raise Request (AG-M08) has a required**Next Follow-up Date & Time**.`PUT /requests/{id}` now requires`followUpAt` (UTC); a body without it is refused with`400 VALIDATION_ERROR`,`details[0].field = "followUpAt"`. Every request comes back with`followUpAt`, and every`requests` row in`/bootstrap` with`follow_up_at`. Requests raised before 12 Oct 2026 have it null. The supervisor's "New request" notification ends with "Follow up by 16 Aug, 3:00 pm" (IST).

### 1. Once: the column

```
ALTER TABLE requests ADD COLUMN follow_up_at TEXT;   -- UTC, e.g. 2026-08-16T09:30:00.000Z
```

No Scope reset: older requests have no follow-up time on the server either.

### 2. Every`/bootstrap`: store it

The whole`requests` upsert, with the new column:

```
INSERT INTO requests (id, number, center_id, created_by, created_by_name, body, priority, status,
  follow_up_at, answer, answered_at, photo_urls, created_at, sync_state)
VALUES (:id, :number, :center_id, :created_by, :created_by_name, :body, :priority, :status,
  :follow_up_at, :answer, :answered_at, :photo_urls, :created_at, 'synced')
ON CONFLICT (id) DO UPDATE SET
  number = excluded.number, center_id = excluded.center_id,
  created_by_name = excluded.created_by_name, body = excluded.body,
  priority = excluded.priority, status = excluded.status,
  follow_up_at = excluded.follow_up_at,          -- new
  answer = excluded.answer, answered_at = excluded.answered_at,
  photo_urls = excluded.photo_urls, created_at = excluded.created_at,
  sync_state = 'synced'
WHERE requests.sync_state = 'synced';
```

### 3. Raise Request: the form and the write

- **The field:** "Next Follow-up Date & Time *", a date and time picker shown in IST, e.g. "16 Aug 2026, 03:00 PM".**Submit Request** stays disabled until it is filled.
- **Not in the past:** the picker cannot choose a time before now. The server does not check this, because a request queued offline may arrive after its follow-up time.
- **Stored and sent as UTC:** 16 Aug 2026, 03:00 PM IST is`2026-08-16T09:30:00.000Z`.

```
BEGIN;
INSERT INTO requests (id, center_id, created_by, created_by_name, body, priority, status,
  follow_up_at, photo_urls, created_at, sync_state)
VALUES (:id, :center_id, :me, :my_name, :body, :priority, 'OPEN',
  :follow_up_at_utc,                              -- new, required
  '[]', :now_utc, 'pending');
INSERT INTO outbox (method, path, body, entity, entity_id, kind, status, created_at)
VALUES ('PUT', '/requests/' || :id, :body_json, 'requests', :id, 'raise', 'queued', :now_utc);
-- plus one outbox_photos row per photo, as for any write with photos
COMMIT;
```

The body (`:body_json`), photos as local photo ids until they upload:

```
{
  "centerId": "15c937a9…",
  "body": "Weight scale calibrated using 10kg standard test weight. Zero-error verified.",
  "priority": "LOW",
  "followUpAt": "2026-08-16T09:30:00.000Z",
  "photoUrls": ["https://…/requests/….jpg"]
}
```

A request queued by an older build without`followUpAt` is refused with`400` and parks as`failed`; open it in the form so the agent can add the time, then queue it again.

### 4. Showing it

Agent, the requests list (unchanged query; show`follow_up_at` on each card):

```
SELECT * FROM requests WHERE created_by = :me ORDER BY created_at DESC;
```

Supervisor, requests to answer, with an overdue flag for a request still open past its follow-up time (`:now_utc` in the same`YYYY-MM-DDTHH:MM:SS.sssZ` form, so the strings compare in time order):

```
SELECT r.*,
       (r.follow_up_at IS NOT NULL AND r.follow_up_at < :now_utc) AS overdue   -- new
FROM requests r
WHERE r.center_id IN (SELECT center_id FROM my_centers) AND r.status = 'OPEN'
ORDER BY CASE r.priority WHEN 'HIGH' THEN 0 WHEN 'NORMAL' THEN 1 ELSE 2 END, r.created_at;
```

Show "Follow up by 16 Aug, 3:00 PM" on the card and on Resolve Request, and an "Overdue" chip when`overdue = 1`. A null`follow_up_at` (older requests) shows nothing. Answering is unchanged.

## 12 Oct 2026 — Transfers carry the note for the agent (`dispatch_note`)

**What changes.** The note the supervisor types when approving ("Note" on Select Destination) now reaches the agent. Before, the server kept it only in its audit log. A sale's note from the sales team now arrives the same way.

| Where | Change |
| --- | --- |
| `POST /transfers/{id}/approve` (supervisor) | Body unchanged:`note`, up to 255 characters, null or left out for none. It is now saved on the transfer. |
| `GET /transfers`,`GET /transfers/{id}` | New`dispatch.note`: string, or null when there is none. |
| `GET /bootstrap`,`transfers` rows | New`dispatch_note`: string or null. On transfers and sales alike. |
| The agent's "Transfer approved" notification | Ends with "Note: …" when there is a note. |
| Admin changes an approved transfer on the web | A new note replaces the old one, and the agent gets a "Transfer changed" notification ending "note: …". The new note arrives in the next`/bootstrap`; nothing for the app to do. |
| A sale | The sales team's note is the transfer's`dispatch_note`; a change to the sale replaces it. |

Transfers approved before 12 Oct 2026 get their note back from the server's log, so they arrive with it too.

### 1. Once: the column

```
ALTER TABLE transfers ADD COLUMN dispatch_note TEXT;
```

No Scope reset needed for new data. To get the notes of transfers already on the phone, run a**Scope reset** once after the upgrade (under*Sync*), after the outbox has emptied: a transfer is only sent again when it changes.

### 2. Every`/bootstrap`: store it

The whole`transfers` upsert, with the new column:

```
INSERT INTO transfers (id, center_id, type, status, number, destination_id, destination_name,
  truck_expected_at, dispatch_note, transfer_vehicle_id, planned_vehicle_number, planned_vehicle_ownership,
  transporter_name, transfer_fee, fixed_qty, estimated_expense, vehicle_plate, driver_name,
  requested_by, requested_by_name, requested_at, decided_by_name, approved_at, rejection_reason,
  handed_over_at, dispatched_weight, bale_count, vehicle_photo_urls, weighbridge_photo_urls,
  vehicle_differs, updated_at, sync_state)
VALUES (…, 'synced')
ON CONFLICT (id) DO UPDATE SET
  status = excluded.status, number = excluded.number,
  destination_id = excluded.destination_id, destination_name = excluded.destination_name,
  truck_expected_at = excluded.truck_expected_at,
  dispatch_note = excluded.dispatch_note,           -- new
  transfer_vehicle_id = excluded.transfer_vehicle_id,
  planned_vehicle_number = excluded.planned_vehicle_number,
  planned_vehicle_ownership = excluded.planned_vehicle_ownership,
  transporter_name = excluded.transporter_name, transfer_fee = excluded.transfer_fee,
  fixed_qty = excluded.fixed_qty, estimated_expense = excluded.estimated_expense,
  vehicle_plate = excluded.vehicle_plate, driver_name = excluded.driver_name,
  decided_by_name = excluded.decided_by_name, approved_at = excluded.approved_at,
  rejection_reason = excluded.rejection_reason, handed_over_at = excluded.handed_over_at,
  dispatched_weight = excluded.dispatched_weight, bale_count = excluded.bale_count,
  vehicle_photo_urls = excluded.vehicle_photo_urls,
  weighbridge_photo_urls = excluded.weighbridge_photo_urls,
  vehicle_differs = excluded.vehicle_differs, updated_at = excluded.updated_at,
  sync_state = 'synced'
WHERE transfers.sync_state = 'synced';
```

### 3. Supervisor approves: save the note locally too

The whole approve transaction, with the one new line.`:note` is the "Note" box on Select Destination, trimmed; NULL when empty. The design caps it at 150 characters; the server takes up to 255.

```
BEGIN;
UPDATE transfers
SET status = 'APPROVED',
    destination_id = :destination_id, destination_name = :destination_name,
    truck_expected_at = :truck_utc,                     -- NULL when left empty
    transfer_vehicle_id = :transfer_vehicle_id,         -- NULL for a hired truck typed in
    planned_vehicle_number = :number, planned_vehicle_ownership = :ownership,
    transporter_name = :transporter_name,               -- NULL for a company truck
    transfer_fee = :fee,                                -- 0 for a company truck
    dispatch_note = :note,                              -- new; NULL when left empty
    decided_by_name = :my_name, approved_at = :now_utc,
    sync_state = 'pending'
WHERE id = :id AND status = 'REQUESTED';

INSERT INTO outbox (method, path, body, entity, entity_id, kind, refs, status, created_at)
VALUES ('POST', '/transfers/' || :id || '/approve', :body_json, 'transfers', :id, 'approve', '[]', 'queued', :now_utc);
COMMIT;
```

The body (`:body_json`), unchanged except that`note` now matters:

```
{
  "destinationFacilityId": "ed6cf8f9…",
  "vehicleArrivalTime": "2026-10-23T04:30:00.000Z",
  "vehicle": { "transferVehicleId": "<company truck id>" },
  "note": "Load the dry bales first."
}
```

### 4. Showing it

Agent, approved transfer (AG-M06 "Scheduled"), the whole query with the new column:

```
SELECT number, destination_name, truck_expected_at, planned_vehicle_number,
       dispatch_note                                    -- new
FROM transfers WHERE id = :id;
```

Supervisor, approved and dispatched detail (SUP-M11):

```
SELECT t.*, ce.name AS center_name FROM transfers t JOIN centers ce ON ce.id = t.center_id
WHERE t.id = :id;   -- unchanged: t.* now includes dispatch_note
```

- **Agent:** under the truck and time, "Note from supervisor: …" (for a sale, "Note: …"). Hidden when`dispatch_note` is NULL.
- **Supervisor:** "Note for the agent: …" under "Approved by". Hidden when NULL.
- **Never on a pending or rejected transfer:** it is set only by approving or by a sale.

## 13 Oct 2026 — The supervisor's photo (`me.supervisor.photoUrl`)

**What changes.** The supervisor block now carries their photo, for the "TO :" card on Raise Request (AG-M08) and for Contact Supervisor. It is the photo the supervisor set on their own profile. Additive: nothing that reads the old shape breaks.

| Where | Change |
| --- | --- |
| `GET /bootstrap`,`me.supervisor` | New`photoUrl`: a URL, or null when they have no photo.`name` and`phone` unchanged. |
| `GET /auth/me`,`supervisor` | The same new`photoUrl`. |
| `supervisor` itself | Still null when no reporting manager is set. It is the reporting manager whatever roles the user holds, so an agent who is also a supervisor sees their own manager. |

`me` is sent whole on every`/bootstrap`, so a new photo, or a new reporting manager, arrives on the next sync. No table changes and no Scope reset: it is one more`sync_meta` key.

### 1. Every`/bootstrap`: store it

The whole`sync_meta` write in Step 2, with the one new key:

```
INSERT OR REPLACE INTO sync_meta (key, value) VALUES
  ('user_id', :user_id), ('user_name', :user_name), ('user_phone', :user_phone),
  ('user_photo_url', :user_photo_url),
  ('supervisor_name', :supervisor_name), ('supervisor_phone', :supervisor_phone),  -- null when no supervisor
  ('supervisor_photo_url', :supervisor_photo_url),  -- new: null when no supervisor or no photo
  ('session_expires_at', :expires_at);
```

### 2. Reading it

The whole query, with the new key:

```
SELECT key, value FROM sync_meta
WHERE key IN ('user_name', 'user_phone', 'user_photo_url',
              'supervisor_name', 'supervisor_phone', 'supervisor_photo_url', 'session_expires_at');
```

### 3. Showing it

- **Raise Request (AG-M08), the "TO :" card:** the photo, then "TO : {supervisor_name}". Use the name as it comes; do not add "(Supervisor)" from the role, since for someone who is also a supervisor it is their manager.
- **Contact Supervisor:** the same photo beside the name and phone.
- **No photo, or offline before it was ever loaded:** a circle with their initials. Cache the image like other photos so it shows offline after the first load.
- **`supervisor_name`is null** (no reporting manager): "No supervisor set: ask your admin to set one." A request raised then still saves, but goes to nobody until an admin answers it from the panel.

## 16 Oct 2026 — When the record moved on while your write was waiting

No API change and no table change; this is how to handle four answers the app can already get.

A row with a queued write is`pending`, and Step 4 never writes over a pending row. So if someone else closes the record meanwhile (the supervisor cancels the task, the office discards the draft, the admin cancels the transfer), the`/bootstrap` that brings that change skips the row, and the change is not sent again. The queued write then comes back`409`. Parking it as failed would leave the row wrong for good: take the server's state and drop the write instead, and tell the agent why.

| Answer | To | What the app does |
| --- | --- | --- |
| `409 CANCELLED` | `POST /tasks/{id}/complete` | Drop the item and its photos; the task becomes Cancelled. Tell the agent the supervisor called it off |
| `409 DRAFT_DISCARDED` | `PUT /collections/{id}` (draft save) | Drop the queued draft saves. A queued submit for it still goes through (it undoes the discard): keep it and the draft. Otherwise delete the draft, its lines and photos |
| `409 ALREADY_SUBMITTED` | `PUT /collections/{id}` (draft save),`DELETE /collections/{id}` (discard) | Drop that item;`GET /collections/{id}` and write it as synced |
| `409 REJECTED` | `POST /transfers/{id}/handover` | Drop the dispatch and its photos; back to Rejected with the handover fields cleared;`GET /transfers/{id}` for the reason |

`409 NOT_PENDING` and`409 ALREADY_CLOSED` still mean done. Still real refusals, kept as failed:`ALREADY_SUBMITTED` on a submit,`ALREADY_LOGGED`,`ALREADY_DISPATCHED`,`ALREADY_RAISED`,`DUPLICATE_REQUEST`, and every`422`.

```
-- 409 CANCELLED on POST /tasks/{id}/complete
BEGIN;
DELETE FROM outbox_photos WHERE outbox_seq = :seq;
DELETE FROM outbox WHERE seq = :seq;
DELETE FROM photos WHERE owner_table = 'tasks' AND owner_id = :id;   -- and their local files
UPDATE tasks SET status = 'CANCELLED', completed_at = NULL, photo_urls = '[]', sync_state = 'synced'
WHERE id = :id;
COMMIT;
```

```
-- 409 DRAFT_DISCARDED on PUT /collections/{id}
BEGIN;
DELETE FROM outbox_photos
WHERE outbox_seq IN (SELECT seq FROM outbox
                     WHERE entity = 'collections' AND entity_id = :id AND kind = 'draft_save');
DELETE FROM outbox WHERE entity = 'collections' AND entity_id = :id AND kind = 'draft_save';
-- A queued submit still goes through and undoes the discard: keep the draft for it.
-- With nothing else queued for it, the draft leaves the phone.
DELETE FROM photos
WHERE ((owner_table = 'collections' AND owner_id = :id)
    OR (owner_table = 'collection_items'
        AND owner_id IN (SELECT id FROM collection_items WHERE collection_id = :id)))
  AND NOT EXISTS (SELECT 1 FROM outbox WHERE entity = 'collections' AND entity_id = :id);
DELETE FROM collection_items
WHERE collection_id = :id
  AND NOT EXISTS (SELECT 1 FROM outbox WHERE entity = 'collections' AND entity_id = :id);
DELETE FROM collections
WHERE id = :id
  AND NOT EXISTS (SELECT 1 FROM outbox WHERE entity = 'collections' AND entity_id = :id);
COMMIT;
```

```
-- 409 ALREADY_SUBMITTED on PUT /collections/{id} or DELETE /collections/{id}
BEGIN;
DELETE FROM outbox_photos WHERE outbox_seq = :seq;
DELETE FROM outbox WHERE seq = :seq;
COMMIT;
-- Then GET /collections/{id}. If nothing else is queued for it
-- (SELECT 1 FROM outbox WHERE entity = 'collections' AND entity_id = :id returns no row),
-- write the answer onto the collections row and replace its collection_items, exactly as
-- for a submit's answer, with sync_state = 'synced'.
```

```
-- 409 REJECTED on POST /transfers/{id}/handover
BEGIN;
DELETE FROM outbox_photos WHERE outbox_seq = :seq;
DELETE FROM outbox WHERE seq = :seq;
DELETE FROM photos
WHERE owner_table = 'transfers' AND owner_id = :id AND field IN ('vehicle', 'weighbridge');
UPDATE transfer_items SET dispatched_qty = NULL WHERE transfer_id = :id;
UPDATE transfers
SET status = 'REJECTED', handed_over_at = NULL, vehicle_plate = NULL, driver_name = NULL,
    dispatched_weight = NULL, bale_count = NULL, gps_lat = NULL, gps_lng = NULL,
    sync_state = 'synced'
WHERE id = :id;
COMMIT;
-- Then GET /transfers/{id} and write the reason:
UPDATE transfers
SET rejection_reason = :reason,          -- data.rejection.reason
    decided_by_name  = :decided_by_name, -- data.rejection.by.name
    approved_at      = :decided_at       -- data.rejection.at
WHERE id = :id;
```

**Items already parked as failed** with one of these answers: apply the same handling once when the app updates.

```
SELECT seq, entity, entity_id, kind, last_error
FROM outbox
WHERE status = 'failed'
  AND (last_error LIKE '409 CANCELLED%'
    OR last_error LIKE '409 DRAFT_DISCARDED%'
    OR (last_error LIKE '409 ALREADY_SUBMITTED%' AND kind IN ('draft_save', 'discard'))
    OR (last_error LIKE '409 REJECTED%' AND kind = 'handover'));
```

## 20 Oct 2026 — Push notifications: role and centre on notifications

Notifications can now also arrive as a push, the moment they are made. The`notifications` table from`/bootstrap` stays the record: a push only says "sync now". Every notification now carries the**role** it is for and the**centre** it is about, so someone with two roles sees the active role's first. Two new columns, no Scope reset: rows from before 20 Oct stay null and show under every role. The Firebase side (permission, token, channels, taps) is in the Offline Data Guide entry of the same date.

**1. Once: the columns.**

```
ALTER TABLE notifications ADD COLUMN role TEXT;                          -- AGENT | SUPERVISOR; null on rows before 20 Oct 2026
ALTER TABLE notifications ADD COLUMN center_id TEXT REFERENCES centers (id); -- the centre it is about; null when none
CREATE INDEX ix_notifications_role ON notifications (role, created_at);
```

The table is now:

```
CREATE TABLE notifications (            -- mine only; deep_link says what it is about
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL, title TEXT NOT NULL, body TEXT,
  deep_link TEXT,
  role TEXT,                            -- AGENT | SUPERVISOR: the role it is for; null before 20 Oct 2026
  center_id TEXT REFERENCES centers (id), -- the centre it is about; null when none
  created_at TEXT NOT NULL, read_at TEXT,
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
```

**2. Every`/bootstrap`: store it.** The whole`notifications` upsert, with the two new columns:

```
INSERT INTO notifications (id, type, title, body, deep_link, role, center_id, created_at, read_at, sync_state)
VALUES (:id, :type, :title, :body, :deep_link, :role, :center_id, :created_at, :read_at, 'synced')
ON CONFLICT (id) DO UPDATE SET
  type = excluded.type, title = excluded.title, body = excluded.body,
  deep_link = excluded.deep_link,
  role = excluded.role, center_id = excluded.center_id,     -- new
  created_at = excluded.created_at, read_at = excluded.read_at,
  sync_state = 'synced'
WHERE notifications.sync_state = 'synced';
```

**3. The list: the active role's first.**`:active_role` is`sync_meta.active_role`.`for_role_name` is the name to show on the others ("For your Supervisor role").

```
SELECT n.*, r.role_name AS for_role_name,
  CASE WHEN n.role IS NULL OR n.role = :active_role THEN 0 ELSE 1 END AS other_role
FROM notifications n
LEFT JOIN my_roles r ON r.role_key = n.role
ORDER BY other_role, n.created_at DESC;
```

Tapping an`other_role = 1` row offers to switch to that role first, then opens`deep_link` (its screen belongs to that role).

**4. Unread counts.** The bell counts the active role's (and the unlabelled older ones); the role switcher shows a count beside each other role.

```
-- The bell
SELECT COUNT(*) FROM notifications
WHERE read_at IS NULL AND (role IS NULL OR role = :active_role);

-- The role switcher: unread per other role
SELECT role, COUNT(*) AS unread FROM notifications
WHERE read_at IS NULL AND role IS NOT NULL AND role <> :active_role
GROUP BY role;
```

**5. A push was tapped.** The push's`data.notificationId` is`notifications.id`. Sync first, then mark it read the same way as a tap in the list, and queue`POST /notifications/{id}/read` as today:

```
UPDATE notifications SET read_at = :now, sync_state = 'pending'
WHERE id = :notification_id AND read_at IS NULL;
```

No row changed (the sync has not landed yet): open`data.deepLink` anyway and mark it read after the next sync. A push with`data.type = 'TEST_PUSH'` has an empty`notificationId` and no row: show it, store nothing.

**6. Never insert a row from a push.** The list reads only this table, so a notification never shows twice: the push is the alert, the`/bootstrap` row is the entry.

## 20 Oct 2026 — Supervisor Stock screen (SUP-M03): build it like this

No API change, no new table. Build the Stock screen from this entry, not from the Figma frames.

**What changes from the Figma frames:**

- **Only one stage: RM.** A collection centre only receives material and sends it on. SRM, WIP and FG do not exist. Drop the "Stock by Stage" screen and the four stage cards.
- **No bins, no machines.** Drop "Bin: RM-01", "Machine 01" and similar. Stock is one number per item per centre.
- **No time per item.** Drop "10m ago" on each row. Show one "Last updated" line at the top: the time of the last sync.
- **Totals by unit.** Some items are counted in pieces. Never add KG and PCS together: show "3,450.00 KG · 25 PCS".
- **The centre is the active centre** picked on Home. If the supervisor has several centres, the dropdown just changes the active centre.

**The screen (one screen, no detail page needed):**

```
Stock                                         [bell]
[MRF Station Aanjana  v]          active centre
● Last updated: Today, 11:20 AM

Total: 3,450.00 KG · 25 PCS

[ Plastic ] [ Non-plastic ]

[img] PET Bottles                 980.00 KG
      Free to send 730.00 KG
[img] HDPE Rigid                  980.00 KG
[img] E-Waste                         25 PCS
```

- One row per item: picture (`image_url`, else a dot in`colour`), name, quantity with its unit. KG with 2 decimals, PCS as a whole number.
- "Free to send" only when part of the stock is already on an open transfer (`qty_promised > 0`).
- Two tabs, as in the collection pickers: Plastic, and Non-plastic (which also holds Mixed).
- Items at zero are hidden. Empty tab: "No stock here".
- Read only. Stock changes through collections, transfers and admin corrections.
- Pull to refresh runs a`/bootstrap`.

**The SQL.**`:center` is the active centre;`:tab` is`PLASTIC` or`NON_PLASTIC`.

Header:

```
SELECT name FROM centers WHERE id = :center;
SELECT value AS last_updated FROM sync_meta WHERE key = 'last_bootstrap_at';
```

The rows of one tab. Stock in hand is the server figure plus what was submitted on this phone and not sent yet; free to send leaves out what open transfers already ask for:

```
WITH in_hand AS (
  SELECT s.item_id,
         SUM(s.qty) + COALESCE((SELECT SUM(ci.verified_qty)
                                FROM collection_items ci JOIN collections c ON c.id = ci.collection_id
                                WHERE c.center_id = s.center_id AND ci.item_id = s.item_id
                                  AND c.sync_state = 'pending' AND c.status = 'SUBMITTED'), 0) AS qty_now
  FROM stock s
  WHERE s.center_id = :center AND s.stage = 'RM'
  GROUP BY s.item_id
), promised AS (
  SELECT ti.item_id, SUM(ti.qty) AS qty
  FROM transfer_items ti JOIN transfers t ON t.id = ti.transfer_id
  WHERE t.center_id = :center AND t.status IN ('REQUESTED', 'APPROVED')
  GROUP BY ti.item_id
)
SELECT i.id, i.name, i.image_url, i.colour, i.unit_code,
       h.qty_now,
       COALESCE(p.qty, 0) AS qty_promised,
       MAX(h.qty_now - COALESCE(p.qty, 0), 0) AS qty_free
FROM in_hand h
JOIN items i ON i.id = h.item_id
LEFT JOIN promised p ON p.item_id = h.item_id
WHERE h.qty_now > 0
  AND (CASE WHEN :tab = 'PLASTIC' THEN i.material_type = 'PLASTIC'
            ELSE i.material_type IN ('NON_PLASTIC', 'MIXED') END)
ORDER BY h.qty_now DESC;
```

The total line, one figure per unit (both tabs together):

```
WITH in_hand AS (
  SELECT s.item_id,
         SUM(s.qty) + COALESCE((SELECT SUM(ci.verified_qty)
                                FROM collection_items ci JOIN collections c ON c.id = ci.collection_id
                                WHERE c.center_id = s.center_id AND ci.item_id = s.item_id
                                  AND c.sync_state = 'pending' AND c.status = 'SUBMITTED'), 0) AS qty_now
  FROM stock s
  WHERE s.center_id = :center AND s.stage = 'RM'
  GROUP BY s.item_id
)
SELECT i.unit_code, SUM(h.qty_now) AS total
FROM in_hand h JOIN items i ON i.id = h.item_id
WHERE h.qty_now > 0
GROUP BY i.unit_code
ORDER BY i.unit_code;     -- KG first, then PCS
```

## 21 Oct 2026 — Requests: proof photos when the supervisor answers (Resolve Request Proof)

**What changes.** On Resolve Request (SUP-M06) the supervisor can add photos under "Resolve Request Proof" before tapping Resolved Request.`POST /requests/{id}/answer` now takes them:`{ "notes": "…", "photoUrls": [ … ] }`.`photoUrls` is optional and has**no limit** on the number of photos. Every request now comes back with`answer.photoUrls`, and every`requests` row in`/bootstrap` with a new column`answer_photo_urls`. The agent's own photos stay in`photo_urls` ("Attachment from Collection Agent"); the two lists never mix. Requests answered before 21 Oct 2026 have`'[]'`.

### 1. Once: the column

```
ALTER TABLE requests ADD COLUMN answer_photo_urls TEXT NOT NULL DEFAULT '[]';  -- JSON array of URLs: the supervisor's proof
```

No Scope reset: older answers have no proof photos on the server either.

### 2. Every`/bootstrap`: store it

The whole`requests` upsert, with the new column:

```
INSERT INTO requests (id, number, center_id, created_by, created_by_name, body, priority, status,
  follow_up_at, answer, answered_at, photo_urls, answer_photo_urls, created_at, sync_state)
VALUES (:id, :number, :center_id, :created_by, :created_by_name, :body, :priority, :status,
  :follow_up_at, :answer, :answered_at, :photo_urls, :answer_photo_urls, :created_at, 'synced')
ON CONFLICT (id) DO UPDATE SET
  number = excluded.number, center_id = excluded.center_id,
  created_by_name = excluded.created_by_name, body = excluded.body,
  priority = excluded.priority, status = excluded.status,
  follow_up_at = excluded.follow_up_at,
  answer = excluded.answer, answered_at = excluded.answered_at,
  photo_urls = excluded.photo_urls,
  answer_photo_urls = excluded.answer_photo_urls,   -- new
  created_at = excluded.created_at,
  sync_state = 'synced'
WHERE requests.sync_state = 'synced';
```

### 3. Supervisor, Resolve Request: the photos and the write

Each proof photo is an ordinary photo of the request, uploaded with purpose`REQUEST` (the same purpose the agent's request photos use). Keep it with`field = 'answer'` so it is never shown as the agent's.

```
-- Taken or picked on "Resolve Request Proof": keep the file, record it
INSERT INTO photos (id, owner_table, owner_id, field, purpose, content_type, local_path,
                    status, size_bytes, created_at)
VALUES (:photo_id, 'requests', :request_id, 'answer', 'REQUEST', 'image/jpeg',
        :path, 'local', :size, :now);

-- Removed with the X before sending
DELETE FROM photos WHERE id = :photo_id AND status = 'local';
```

Resolved Request (Description required, 3 characters or more):

```
BEGIN;
UPDATE requests
   SET status = 'CLOSED', answer = :notes, answered_at = :now_utc,
       sync_state = 'pending'
 WHERE id = :request_id;
INSERT INTO outbox (method, path, body, entity, entity_id, kind, status, created_at)
VALUES ('POST', '/requests/' || :request_id || '/answer', :body_json, 'requests', :request_id,
        'answer', 'queued', :now_utc);
-- one row per proof photo, so the answer waits until every photo has uploaded
INSERT INTO outbox_photos (outbox_seq, photo_id)
SELECT last_insert_rowid(), id FROM photos
 WHERE owner_table = 'requests' AND owner_id = :request_id AND field = 'answer';
COMMIT;
```

The body (`:body_json`), photos as local photo ids until they upload, as for any write with photos; with no photos, send`"photoUrls": []` or leave it out:

```
{
  "notes": "Weight scale calibrated using 10kg standard test weight. Zero-error verified.",
  "photoUrls": ["https://…/requests/….jpg", "https://…/requests/….jpg"]
}
```

The answer is the whole request, with`answer.photoUrls` holding the uploaded URLs. Write it like the next`/bootstrap` would, then clear the pending flag:

```
BEGIN;
DELETE FROM outbox WHERE seq = :seq;
UPDATE requests
   SET status = 'CLOSED', answer = :answer_notes, answered_at = :answer_at,
       answer_photo_urls = :answer_photo_urls_json,   -- JSON of answer.photoUrls
       sync_state = 'synced'
 WHERE id = :request_id
   AND NOT EXISTS (SELECT 1 FROM outbox WHERE entity = 'requests' AND entity_id = :request_id);
COMMIT;
```

When it is refused:

- `409 ALREADY_CLOSED`: someone (often the admin, from the panel) answered first. Drop the write and keep the server's answer from the next`/bootstrap`.
- `422 INVALID_REQUEST`,`details[0].field = "photoUrls.N"`: that photo was not uploaded by this account, or never reached storage. Upload it again (status back to`'failed'`) and resend.

### 4. Showing it

Resolve Request (open): the agent's photos on top, the proof being added below:

```
SELECT id, number, body, priority, status, follow_up_at, created_by_name, photo_urls
FROM requests WHERE id = :request_id;

SELECT id, COALESCE(local_path, remote_url) AS src FROM photos
WHERE owner_table = 'requests' AND owner_id = :request_id AND field = 'answer'
ORDER BY created_at;
```

An answered request, for the supervisor and for the agent ("Proof" under the answer; hide the block when the list is empty):

```
SELECT answer, answered_at, photo_urls, answer_photo_urls FROM requests WHERE id = :request_id;
```

While the answer is still pending on this phone, show the local proof photos from the`photos` query above; once synced,`answer_photo_urls` has them.

Unchanged: raising a request, its photos (`photo_urls`) and every other table.

## 21 Oct 2026 — Rejecting with reasons and optional remarks (collections, expenses, cash requests)

**What changes.** The reject screens (Reject Collection, SUP-M02; Reject Cash Request and the expense reject, SUP-M04) have the reasons ticked and a separate, optional Remarks box. The three reject calls now take both:

- `reason` (required, as before): the ticked reasons, joined with ", " (for example`"Sufficient Existing Balance, Exceeds Advance Limit"`). With Other ticked, put the words typed for Other in its place.
- `remarks` (new, optional): the Remarks box, as typed. Leave it out (or`null`) when empty.

The calls:`POST /collections/{id}/reject``{ "reason", "remarks" }`;`POST /expenses/{id}/decide` and`POST /cash-requests/{id}/decide``{ "outcome": "REJECTED", "reason", "remarks" }`. The answers carry it as`review.remarks` (collection) and`decision.remarks` (expense, cash request), and`/bootstrap` as a new column on each row. The agent's notification ends with "Remarks: …" when there are any. Older builds keep working:`remarks` is optional.

### 1. Once: the columns

```
ALTER TABLE collections   ADD COLUMN rejection_remarks TEXT;  -- optional words beside rejection_reason
ALTER TABLE expenses      ADD COLUMN decision_remarks TEXT;   -- optional words beside decision_reason
ALTER TABLE cash_requests ADD COLUMN decision_remarks TEXT;   -- optional words beside decision_note
```

No Scope reset: nothing rejected before today has remarks.

### 2. Every`/bootstrap`: store them

The three upserts in full, with the new column (`gps_lat` and`gps_lng` on`collections` stay phone-only and are never written from the server):

```
INSERT INTO collections (id, center_id, agent_id, agent_name, channel, status, slip_number,
  collected_at, vehicle_id, mrf_person_id, ragpicker_id, given_by_name, handed_over_by, paid_by,
  takes_payment, total_amount, handover_photo_urls, rejection_reason, rejection_remarks,
  verified_by_name, verified_at, updated_at, sync_state)
VALUES (:id, :center_id, :agent_id, :agent_name, :channel, :status, :slip_number,
  :collected_at, :vehicle_id, :mrf_person_id, :ragpicker_id, :given_by_name, :handed_over_by, :paid_by,
  :takes_payment, :total_amount, :handover_photo_urls, :rejection_reason, :rejection_remarks,
  :verified_by_name, :verified_at, :updated_at, 'synced')
ON CONFLICT (id) DO UPDATE SET
  center_id = excluded.center_id, agent_id = excluded.agent_id, agent_name = excluded.agent_name,
  channel = excluded.channel, status = excluded.status, slip_number = excluded.slip_number,
  collected_at = excluded.collected_at, vehicle_id = excluded.vehicle_id,
  mrf_person_id = excluded.mrf_person_id, ragpicker_id = excluded.ragpicker_id,
  given_by_name = excluded.given_by_name, handed_over_by = excluded.handed_over_by,
  paid_by = excluded.paid_by, takes_payment = excluded.takes_payment,
  total_amount = excluded.total_amount, handover_photo_urls = excluded.handover_photo_urls,
  rejection_reason = excluded.rejection_reason,
  rejection_remarks = excluded.rejection_remarks,     -- new
  verified_by_name = excluded.verified_by_name, verified_at = excluded.verified_at,
  updated_at = excluded.updated_at, sync_state = 'synced'
WHERE collections.sync_state = 'synced';

INSERT INTO expenses (id, center_id, user_id, user_name, category_id, amount, note, status, number,
  receipt_photo_urls, decided_by_name, decision_reason, decision_remarks, created_at, updated_at,
  sync_state)
VALUES (:id, :center_id, :user_id, :user_name, :category_id, :amount, :note, :status, :number,
  :receipt_photo_urls, :decided_by_name, :decision_reason, :decision_remarks, :created_at, :updated_at,
  'synced')
ON CONFLICT (id) DO UPDATE SET
  center_id = excluded.center_id, user_id = excluded.user_id, user_name = excluded.user_name,
  category_id = excluded.category_id, amount = excluded.amount, note = excluded.note,
  status = excluded.status, number = excluded.number,
  receipt_photo_urls = excluded.receipt_photo_urls, decided_by_name = excluded.decided_by_name,
  decision_reason = excluded.decision_reason,
  decision_remarks = excluded.decision_remarks,       -- new
  created_at = excluded.created_at, updated_at = excluded.updated_at, sync_state = 'synced'
WHERE expenses.sync_state = 'synced';

INSERT INTO cash_requests (id, number, center_id, requested_by, requested_by_name, amount, reason,
  status, decided_by_name, decision_note, decision_remarks, created_at, updated_at, sync_state)
VALUES (:id, :number, :center_id, :requested_by, :requested_by_name, :amount, :reason,
  :status, :decided_by_name, :decision_note, :decision_remarks, :created_at, :updated_at, 'synced')
ON CONFLICT (id) DO UPDATE SET
  number = excluded.number, center_id = excluded.center_id, requested_by = excluded.requested_by,
  requested_by_name = excluded.requested_by_name, amount = excluded.amount, reason = excluded.reason,
  status = excluded.status, decided_by_name = excluded.decided_by_name,
  decision_note = excluded.decision_note,
  decision_remarks = excluded.decision_remarks,       -- new
  created_at = excluded.created_at, updated_at = excluded.updated_at, sync_state = 'synced'
WHERE cash_requests.sync_state = 'synced';
```

### 3. Supervisor: the reject writes

`:reason` is the ticked reasons joined with ", " (at least one must be ticked; with Other, its words).`:remarks` is the Remarks box trimmed, or`NULL` when empty.

```
-- Reject Collection (SUP-M02)
BEGIN;
UPDATE collections
   SET status = 'REJECTED', rejection_reason = :reason, rejection_remarks = :remarks,
       verified_by_name = :my_name, verified_at = :now, sync_state = 'pending'
 WHERE id = :id;
INSERT INTO outbox (method, path, body, entity, entity_id, kind, status, created_at)
VALUES ('POST', '/collections/' || :id || '/reject', :body_json, 'collections', :id, 'reject',
        'queued', :now);
COMMIT;
-- body: {"reason": "Weight Mismatch, Incorrect Material Category",
--        "remarks": "Scale shows 200 kg but 410 kg was entered."}

-- Reject an expense (SUP-M04)
BEGIN;
UPDATE expenses
   SET status = 'REJECTED', decided_by_name = :my_name, decision_reason = :reason,
       decision_remarks = :remarks, sync_state = 'pending'
 WHERE id = :id;
INSERT INTO outbox (method, path, body, entity, entity_id, kind, status, created_at)
VALUES ('POST', '/expenses/' || :id || '/decide', :body_json, 'expenses', :id, 'decide',
        'queued', :now);
COMMIT;
-- body: {"outcome": "REJECTED", "reason": "No receipt attached", "remarks": "The bill is from last month."}

-- Reject Cash Request (SUP-M04)
BEGIN;
UPDATE cash_requests
   SET status = 'REJECTED', decided_by_name = :my_name, decision_note = :reason,
       decision_remarks = :remarks, sync_state = 'pending'
 WHERE id = :id;
INSERT INTO outbox (method, path, body, entity, entity_id, kind, status, created_at)
VALUES ('POST', '/cash-requests/' || :id || '/decide', :body_json, 'cash_requests', :id, 'decide',
        'queued', :now);
COMMIT;
-- body: {"outcome": "REJECTED", "reason": "Sufficient Existing Balance, Exceeds Advance Limit",
--        "remarks": "Already holds ₹12,000 for this week."}
```

Approving is unchanged and sends no remarks. The server takes up to 1000 characters for each of`reason` and`remarks`; the screens may cap the Remarks box at 150 as designed.

### 4. Showing it

On a rejected record, for the agent and the supervisor: the reasons, then the remarks on their own line when there are any.

```
SELECT rejection_reason, rejection_remarks, verified_by_name, verified_at
FROM collections WHERE id = :id;

SELECT decision_reason, decision_remarks, decided_by_name FROM expenses WHERE id = :id;

SELECT decision_note, decision_remarks, decided_by_name FROM cash_requests WHERE id = :id;
```

Unchanged: approving, raising and logging, and every other table.

## 23 Oct 2026 — Rejecting a transfer with optional remarks (SUP-M11)

**What changes.** Reject Transfer (SUP-M11) has the reasons ticked and a separate, optional Remarks box.`POST /transfers/{id}/reject` now takes both:

- `reason` (as before, 3–1000 characters): the ticked reasons joined with ", ".
- `remarks` (new, optional, up to 1000 characters): the Remarks box, as typed. Leave it out (or`null`) when empty.

Until today the server refused`remarks` with`400 UNRECOGNIZED_KEYS`. From the server release that carries this change it is accepted, and an outbox item that already failed that way can be sent again unchanged. The answer carries the remarks as`rejection.remarks`, and`/bootstrap` as a new column`rejection_remarks` on the`transfers` row. The agent's "Transfer refused" notification ends with "Remarks: …" when there are any. Older builds keep working:`remarks` is optional.

```
ALTER TABLE transfers ADD COLUMN rejection_remarks TEXT;  -- optional words beside rejection_reason
```

No Scope reset: nothing rejected before today has remarks. A transfer the admin cancelled after approval still shows "Cancelled after approval: …" in`rejection_reason`, with no remarks.

Storing the row from`/bootstrap`, with the new column:

```
INSERT INTO transfers (id, center_id, type, status, number, destination_id, destination_name,
  truck_expected_at, dispatch_note, transfer_vehicle_id, planned_vehicle_number, planned_vehicle_ownership,
  transporter_name, transfer_fee, fixed_qty, estimated_expense, vehicle_plate, driver_name,
  requested_by, requested_by_name, requested_at, decided_by_name, approved_at, rejection_reason,
  rejection_remarks, handed_over_at, dispatched_weight, bale_count, vehicle_photo_urls,
  weighbridge_photo_urls, vehicle_differs, updated_at, sync_state)
VALUES (:id, :center_id, :type, :status, :number, :destination_id, :destination_name,
  :truck_expected_at, :dispatch_note, :transfer_vehicle_id, :planned_vehicle_number, :planned_vehicle_ownership,
  :transporter_name, :transfer_fee, :fixed_qty, :estimated_expense, :vehicle_plate, :driver_name,
  :requested_by, :requested_by_name, :requested_at, :decided_by_name, :approved_at, :rejection_reason,
  :rejection_remarks, :handed_over_at, :dispatched_weight, :bale_count, :vehicle_photo_urls,
  :weighbridge_photo_urls, :vehicle_differs, :updated_at, 'synced')
ON CONFLICT (id) DO UPDATE SET
  status = excluded.status, number = excluded.number,
  destination_id = excluded.destination_id, destination_name = excluded.destination_name,
  truck_expected_at = excluded.truck_expected_at, dispatch_note = excluded.dispatch_note,
  transfer_vehicle_id = excluded.transfer_vehicle_id,
  planned_vehicle_number = excluded.planned_vehicle_number,
  planned_vehicle_ownership = excluded.planned_vehicle_ownership,
  transporter_name = excluded.transporter_name, transfer_fee = excluded.transfer_fee,
  fixed_qty = excluded.fixed_qty, estimated_expense = excluded.estimated_expense,
  vehicle_plate = excluded.vehicle_plate, driver_name = excluded.driver_name,
  decided_by_name = excluded.decided_by_name, approved_at = excluded.approved_at,
  rejection_reason = excluded.rejection_reason,
  rejection_remarks = excluded.rejection_remarks,   -- new
  handed_over_at = excluded.handed_over_at,
  dispatched_weight = excluded.dispatched_weight, bale_count = excluded.bale_count,
  vehicle_photo_urls = excluded.vehicle_photo_urls,
  weighbridge_photo_urls = excluded.weighbridge_photo_urls,
  vehicle_differs = excluded.vehicle_differs, updated_at = excluded.updated_at,
  sync_state = 'synced'
WHERE transfers.sync_state = 'synced';
```

Rejecting on the phone.`:reason` is the ticked reasons joined with ", ";`:remarks` is the Remarks box trimmed, or`NULL` when empty (`json_object` then sends`"remarks": null`, which the server reads as not sent).

```
-- Reject Transfer (SUP-M11)
BEGIN;
UPDATE transfers
   SET status = 'REJECTED', rejection_reason = :reason, rejection_remarks = :remarks,
       decided_by_name = :my_name, approved_at = :now_utc, sync_state = 'pending'
 WHERE id = :id AND status = 'REQUESTED';
INSERT INTO outbox (method, path, body, entity, entity_id, kind, refs, status, created_at)
VALUES ('POST', '/transfers/' || :id || '/reject', json_object('reason', :reason, 'remarks', :remarks),
        'transfers', :id, 'reject', '[]', 'queued', :now_utc);
COMMIT;
-- body: {"reason": "No Vehicle Available", "remarks": "The Bhatar truck is booked till Friday."}
```

On a rejected transfer, for the agent and the supervisor: the reason, then the remarks on their own line when there are any.

```
SELECT rejection_reason, rejection_remarks, decided_by_name, approved_at
FROM transfers WHERE id = :id;
```

## 26 Oct 2026 — D2D vehicles: no capacity (SUP-M10)

*Later the same day the vehicle type was removed as well; the entry "D2D vehicles: no vehicle type" gives the final`vehicles`table.*

**What changes.** D2D vehicles belong to the municipality (SMC). Nothing in the app or on the server uses their capacity, so it is gone everywhere on the phone side:

- **Add / Edit Vehicle form (SUP-M10):** remove the Capacity field. The form keeps plate number, vehicle type and driver name.
- **`PUT /vehicles/{id}`and`PATCH /vehicles/{id}`:** do not send`capacityKg`. The server now refuses it with`400 VALIDATION_ERROR` (`UNRECOGNIZED_KEYS`, field`capacityKg`).
- **Responses** of`GET /vehicles`,`GET /vehicles/{id}`,`PUT`,`PATCH` and the status call no longer carry`capacityKg`.
- **`/bootstrap`:** rows of the`vehicles` table no longer carry`capacity_kg`. The phone table loses the column.

Not affected:`transfer_vehicles` keeps`capacity_kg` (the trucks a transfer is arranged with), and nothing else in the app reads a D2D vehicle's capacity.

**The table.** A fresh install creates it like this (the schema above already shows it):

```
CREATE TABLE vehicles (
  id TEXT PRIMARY KEY,
  number TEXT,                          -- SUR-VEH-0001 (company code: vans move)
  center_id TEXT REFERENCES centers (id), -- the center this D2D vehicle unloads at; null only on old shared-fleet rows (shown at every center)
  plate_number TEXT NOT NULL,
  type_id TEXT NOT NULL REFERENCES vehicle_types (id),
  type_name TEXT NOT NULL,              -- copied, so a retired type still has a name
  driver_name TEXT,
  is_active INTEGER NOT NULL,
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
CREATE INDEX ix_vehicles_center ON vehicles (center_id, is_active);
```

**An install that already has the old table** (a database version bump). SQLite before 3.35 cannot drop a column, so rebuild the table, keeping every row (including ones not sent yet):

```
BEGIN;
CREATE TABLE vehicles_new (
  id TEXT PRIMARY KEY,
  number TEXT,
  center_id TEXT REFERENCES centers (id),
  plate_number TEXT NOT NULL,
  type_id TEXT NOT NULL REFERENCES vehicle_types (id),
  type_name TEXT NOT NULL,
  driver_name TEXT,
  is_active INTEGER NOT NULL,
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
INSERT INTO vehicles_new (id, number, center_id, plate_number, type_id, type_name, driver_name, is_active, sync_state)
SELECT id, number, center_id, plate_number, type_id, type_name, driver_name, is_active, sync_state FROM vehicles;
DROP TABLE vehicles;
ALTER TABLE vehicles_new RENAME TO vehicles;
CREATE INDEX ix_vehicles_center ON vehicles (center_id, is_active);
COMMIT;
```

No Scope reset is needed: no other row changes.

**Storing the`/bootstrap`rows** (Step 3,`vehicles` is sent whole as`replace` and has a`sync_state` column):

```
DELETE FROM vehicles WHERE sync_state = 'synced';
INSERT OR IGNORE INTO vehicles (id, number, center_id, plate_number, type_id, type_name, driver_name, is_active)
VALUES (:id, :number, :center_id, :plate_number, :type_id, :type_name, :driver_name, :is_active);   -- per row
```

**Add a vehicle** (SUP-M10, Save on the Add form):

```
BEGIN;
INSERT INTO vehicles (id, number, center_id, plate_number, type_id, type_name, driver_name, is_active, sync_state)
VALUES (:id, NULL, :center, :plate_number, :type_id, :type_name, :driver_name, 1, 'pending');
-- then queue PUT /vehicles/{id} in the outbox (Outbox and photos → Queue a write) with this body:
--   {"centerId": :center, "plateNumber": :plate_number, "typeId": :type_id, "driverName": :driver_name}
--   (leave driverName out, or send null, when it is empty)
COMMIT;
```

**Edit a vehicle** (SUP-M10, Save on the Edit form):

```
BEGIN;
UPDATE vehicles
SET plate_number = :plate_number, type_id = :type_id, type_name = :type_name,
    driver_name = :driver_name, sync_state = 'pending'
WHERE id = :id;
-- then queue PATCH /vehicles/{id} with only what changed, e.g.
--   {"plateNumber": :plate_number, "typeId": :type_id, "driverName": :driver_name}
COMMIT;
```

The server's answer has no`capacityKg`; copy`number` from it as before (Outbox and photos → Handle the answer).

## 26 Oct 2026 — D2D vehicles: no vehicle type (SUP-M10)

**What changes.** The approved SUP-M10 form is**Collection centre, Vehicle number and Driver name**. D2D vehicles belong to the municipality (SMC) and nothing uses their type, so it is gone everywhere on the phone side:

- **Add / Edit Vehicle form (SUP-M10):** remove the Vehicle type picker. The form is centre, vehicle number and driver name (optional).
- **`PUT /vehicles/{id}`** (add):`{ "centerId", "plateNumber", "driverName"? }`. Sending`typeId` (or`capacityKg`) is refused:`400 VALIDATION_ERROR` with`UNRECOGNIZED_KEYS`.
- **`PATCH /vehicles/{id}`** (edit):`plateNumber` and`driverName` only. Left out or`null` keeps the value.
- **Responses** of`GET /vehicles`,`GET /vehicles/{id}`,`PUT`,`PATCH` and the status call no longer carry`type`. A vehicle is`{ id, number, centerId, plateNumber, driverName, isActive }`.
- **`GET /vehicle-types`is removed** (it answers`404`): the Add form was its only use.
- **`/bootstrap`** sends no`vehicle_types` table, and`vehicles` rows no longer carry`type_id` or`type_name`.

Not affected:`transfer_vehicles.vehicle_type` (a transfer truck's type, as text) stays.

**The table on a fresh install** (the schema above already shows it):

```
CREATE TABLE vehicles (
  id TEXT PRIMARY KEY,
  number TEXT,                          -- SUR-VEH-0001 (company code: vans move)
  center_id TEXT REFERENCES centers (id), -- the center this D2D vehicle unloads at; null only on old shared-fleet rows (shown at every center)
  plate_number TEXT NOT NULL,
  driver_name TEXT,
  is_active INTEGER NOT NULL,
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
CREATE INDEX ix_vehicles_center ON vehicles (center_id, is_active);
-- no vehicle_types table
```

**An install that already has the old tables** (a database version bump). Rebuild`vehicles` keeping every row (including ones not sent yet), and drop`vehicle_types`. This works whether or not the table still has`capacity_kg`:

```
BEGIN;
CREATE TABLE vehicles_new (
  id TEXT PRIMARY KEY,
  number TEXT,
  center_id TEXT REFERENCES centers (id),
  plate_number TEXT NOT NULL,
  driver_name TEXT,
  is_active INTEGER NOT NULL,
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
INSERT INTO vehicles_new (id, number, center_id, plate_number, driver_name, is_active, sync_state)
SELECT id, number, center_id, plate_number, driver_name, is_active, sync_state FROM vehicles;
DROP TABLE vehicles;
ALTER TABLE vehicles_new RENAME TO vehicles;
CREATE INDEX ix_vehicles_center ON vehicles (center_id, is_active);
DROP TABLE IF EXISTS vehicle_types;
COMMIT;
```

No Scope reset is needed: no other row changes.

**Storing the`/bootstrap`rows** (Step 3,`vehicles` is sent whole as`replace` and has a`sync_state` column):

```
DELETE FROM vehicles WHERE sync_state = 'synced';
INSERT OR IGNORE INTO vehicles (id, number, center_id, plate_number, driver_name, is_active)
VALUES (:id, :number, :center_id, :plate_number, :driver_name, :is_active);   -- per row
```

**Scope reset**, without`vehicle_types`:

```
BEGIN;
DELETE FROM my_roles; DELETE FROM my_centers;
DELETE FROM centers; DELETE FROM items; DELETE FROM center_channels; DELETE FROM center_items;
DELETE FROM vehicles; DELETE FROM mrf_people; DELETE FROM ragpickers;
DELETE FROM expense_categories; DELETE FROM center_people; DELETE FROM destinations;
DELETE FROM transfer_vehicles;
DELETE FROM collections; DELETE FROM collection_items; DELETE FROM expenses;
DELETE FROM cash_requests; DELETE FROM category_requests; DELETE FROM transfers;
DELETE FROM transfer_items; DELETE FROM tasks; DELETE FROM requests; DELETE FROM wallet_entries;
DELETE FROM day_closes; DELETE FROM notifications; DELETE FROM center_balances; DELETE FROM stock;
DELETE FROM photos WHERE status = 'uploaded';
DELETE FROM sync_meta WHERE key IN ('cursor', 'scope_key');
COMMIT;
-- then GET /bootstrap with no since
```

**The list** (SUP-M10, Active and Deactivated tabs):

```
-- This center's vans and the shared fleet (center_id null, managed on the web)
SELECT id, number, center_id, plate_number, driver_name, is_active, sync_state
FROM vehicles
WHERE (center_id = :center OR center_id IS NULL) AND is_active = :active_tab
ORDER BY center_id IS NULL, plate_number;

-- Plate already used? The server ignores spaces and hyphens
SELECT id FROM vehicles
WHERE REPLACE(REPLACE(UPPER(plate_number), '-', ''), ' ', '')
    = REPLACE(REPLACE(UPPER(:plate), '-', ''), ' ', '') AND id <> :id;
```

**Add a vehicle** (Save on the Add form):

```
BEGIN;
INSERT INTO vehicles (id, number, center_id, plate_number, driver_name, is_active, sync_state)
VALUES (:id, NULL, :center, :plate_number, :driver_name, 1, 'pending');
-- then queue PUT /vehicles/{id} in the outbox (Outbox and photos → Queue a write) with this body:
--   {"centerId": :center, "plateNumber": :plate_number, "driverName": :driver_name}
--   (leave driverName out, or send null, when it is empty)
COMMIT;
```

**Edit a vehicle** (Save on the Edit form):

```
BEGIN;
UPDATE vehicles
SET plate_number = :plate_number, driver_name = :driver_name, sync_state = 'pending'
WHERE id = :id;
-- then queue PATCH /vehicles/{id} with only what changed, e.g.
--   {"plateNumber": :plate_number, "driverName": :driver_name}
COMMIT;
```

The server's answer has no`type`; copy`number` from it as before (Outbox and photos → Handle the answer).

## 28 Oct 2026 — No API change: foreign keys stay OFF, and the links that can be missing

No server change, no table change, no new SQL. Two corrections to this doc after an agent-only phone failed`/bootstrap` with`FOREIGN KEY constraint failed` on COMMIT.

**1. Keep`PRAGMA foreign_keys = OFF;`** (the SQLite default, as the top of this doc says). With it ON, a page fails whenever a row points at a parent the phone does not hold, and a page can also bring a child before its parent. With it OFF, nothing that SQLite used to enforce is done for you: there is no`ON DELETE CASCADE`, so delete a row's children (items, photos, outbox rows) in code, as the sync steps already do.

**2. The links that can be missing, in full** (the table "Why the parent may be missing" in*How the tables connect* is corrected in place):

| Column | Why the parent may be missing | What to show |
| --- | --- | --- |
| `wallet_entries.collection_id`,`wallet_entries.expense_id` | The wallet is the whole centre's, but an agent is sent only their own collections and expenses. Every payment for another agent's collection or expense points at a row the phone never holds. Normal on every agent's phone. | The entry's`note`,`kind` and`amount`. Join with`LEFT JOIN`, never`INNER JOIN`, so the list still adds up to the balance. |
| `transfers.transfer_vehicle_id` | `transfer_vehicles` holds only trucks still in use; a transfer can name one switched off since. | `planned_vehicle_number`,`planned_vehicle_ownership`,`transporter_name`. |
| `transfers.destination_id` | `destinations` holds only places still open; a transfer can name one that has closed since. | `destination_name`. |
| `collection_items.item_id`,`transfer_items.item_id`,`stock.item_id` | A material taken off the list stays on old records. | A name cached earlier, else "Removed item". |
| `tasks.center_id`,`requests.center_id`,`notifications.center_id` (any`center_id`) | A task, request or notification about a centre you no longer work at. | Nothing: a scope reset clears it. |

A missing parent on one of these columns is normal: log it as information, not a warning, and never refuse the row. A missing parent on any other column is a sync bug: report it with the table, the row id and the missing id. In debug builds,`PRAGMA foreign_key_check;` after a full sync lists every row whose parent is absent.

Also corrected:`destinations` and`transfer_vehicles` are sent to**everyone who sees transfers**, agents included (the schema comments said "only to someone who approves transfers"). The`vehicles.type_id` row of that table is gone: D2D vehicles have no type since 26 Oct 2026.

## 29 Oct 2026 — No API change: check the loaded quantity against the stock before Submit Transfer

No server change, no table change. **Submit Transfer must not queue a dispatch that takes more than the centre holds.** The server already refuses it, but the agent is usually offline at the truck, so the refusal arrives later as a failed outbox item, after the truck has gone.

What the server checks on `POST /transfers/{id}/handover`: what goes on the truck against the stock in hand at the centre. For a one-item KG transfer sent without `items`, that is `dispatchedWeight`; otherwise each `items[].quantity`. Above it the answer is `422 INVALID_TRANSFER` with `dispatchedWeight` or `items.N.quantity` / `OVER_STOCK` in `details`, and the message "This center holds 25 of that item." It does **not** subtract what other open transfers ask for: that limit (`qty_free`) applies only when raising a request.

If you send `items` for a KG item, its `quantity` must be the loaded weight. The server takes `items[].quantity` off the stock and checks that figure, not `dispatchedWeight`. Leaving `items` out for a one-item KG transfer is still the simplest.

### 1. The most that can go on the truck, per item of this transfer

An item with no `stock` row gives `qty_can_go = 0`: nothing of it can go.

```sql
WITH line AS (
  SELECT item_id FROM transfer_items WHERE transfer_id = :id
), in_hand AS (
  -- Server stock plus submitted collections not yet sent.
  SELECT s.item_id,
         SUM(s.qty) + COALESCE((
           SELECT SUM(ci.verified_qty)
           FROM collection_items ci
           JOIN collections c ON c.id = ci.collection_id
           WHERE c.center_id = s.center_id
             AND ci.item_id = s.item_id
             AND c.sync_state = 'pending'
             AND c.status = 'SUBMITTED'
         ), 0) AS qty_now
  FROM stock s
  WHERE s.center_id = :center
    AND s.stage = 'RM'
    AND s.item_id IN (SELECT item_id FROM line)
  GROUP BY s.item_id
), loading_elsewhere AS (
  -- Other dispatches from this centre saved on the phone and not sent yet:
  -- the server takes them first.
  SELECT ti.item_id, SUM(ti.dispatched_qty) AS qty
  FROM transfer_items ti
  JOIN transfers t ON t.id = ti.transfer_id
  WHERE t.center_id = :center
    AND t.id <> :id
    AND t.status = 'DISPATCHED'
    AND t.sync_state = 'pending'
  GROUP BY ti.item_id
)
SELECT l.item_id, i.name, i.unit_code,
       MAX(COALESCE(h.qty_now, 0) - COALESCE(e.qty, 0), 0) AS qty_can_go
FROM line l
JOIN items i ON i.id = l.item_id
LEFT JOIN in_hand h ON h.item_id = l.item_id
LEFT JOIN loading_elsewhere e ON e.item_id = l.item_id;
```

### 2. On Submit Transfer: block when it is more

Run the query when the agent taps **Submit Transfer**, before anything is written. For each item, the quantity going is the **loaded weight** (an item in KG) or the **pieces loaded** (an item in PCS).

- When `ROUND(quantity going, 3) > ROUND(qty_can_go, 3)`: queue nothing, keep both screens filled in, and show under the Loaded weight (or Pieces loaded) box: "This center holds 25 kg of Plastic." (`qty_can_go`, the unit, `name`).
- Otherwise run Submit Transfer as today: nothing in that transaction changes.

### 3. When the server still refuses

The stock can change between the last sync and the send: another phone's dispatch, or an admin's stock correction. The answer is the same `422` with `OVER_STOCK`. Today the item parks as failed and the transfer keeps showing Dispatched, which is wrong: nothing left the centre's stock.

Show the message on the transfer and offer **Fix the dispatch**. It puts the transfer back to Approved, keeps the vehicle number, driver and photos, and drops the refused send. The agent re-types the loaded weight and submits again.

Use the same steps for a handover that already failed this way before this entry: an outbox item with `kind = 'handover'`, `status = 'failed'` and a `422` with `OVER_STOCK`.

```sql
-- The refused send.
SELECT seq FROM outbox
WHERE entity = 'transfers' AND entity_id = :id
  AND kind = 'handover' AND status = 'failed';

BEGIN;
-- Keep the vehicle and driver, so Vehicle Details opens filled in.
INSERT OR REPLACE INTO sync_meta (key, value)
SELECT 'dispatch_draft:' || id,
       json_object('vehicleNumber', vehicle_plate, 'driverName', driver_name)
FROM transfers WHERE id = :id;

UPDATE transfers
SET status = 'APPROVED', handed_over_at = NULL, vehicle_plate = NULL,
    driver_name = NULL, dispatched_weight = NULL, bale_count = NULL,
    gps_lat = NULL, gps_lng = NULL, sync_state = 'synced'
WHERE id = :id AND status = 'DISPATCHED';

UPDATE transfer_items SET dispatched_qty = NULL WHERE transfer_id = :id;

-- The photos stay in photos (already uploaded) and are linked again on the next Submit.
DELETE FROM outbox_photos WHERE outbox_seq = :seq;
DELETE FROM outbox WHERE seq = :seq;
COMMIT;
```

## 29 Oct 2026 — Supervisor Home (SUP-M01): every tile, and it reads the chosen centre

No server change, no table change. **This entry replaces the `### Home` block under Supervisor screens.** That block gave six numbers across every centre; the screen shows nine, for one.

**Home reads the active centre.** The centre picker sits on Home—it is the same one the Stock screen reads (20 Oct 2026), and the picture under it belongs to that centre. A supervisor holding two centres cannot act on "12 approvals waiting" without knowing whose they are. So every query below is `center_id = :center`, not `IN (SELECT center_id FROM my_centers)`. `:center` is always one of `my_centers`: the picker offers nothing else.

`:today_start_utc` and `:tomorrow_start_utc` bracket the IST day.

**Do not build Home from `GET /mobile/supervisor/summary`.** That endpoint takes no centre and measures across every centre in scope, so the moment a supervisor holds two it disagrees with the tiles. Home reads SQLite, like every other screen.

### The tiles

| Tile | Reads |
| --- | --- |
| Active Agents | the agent roster at this centre |
| Transports Done | transfers raised today, and how many came back received |
| Total Stocks | raw material in hand, one figure per unit |
| Pending Expenses | expenses waiting for a decision |
| Assigned Tasks | open tasks, and tasks completed today |
| Transfer Requests (badge) | transfers waiting for a decision |
| Approvals & Claims (badge) | expenses + cash requests + category requests waiting |
| Verification (badge) | collections waiting to be verified |
| Tasks and Requests (badge) | open requests |

`Total Stocks` is the total line already written for the Stock screen (20 Oct 2026)—the `in_hand` query grouped by `unit_code`. Run that one, so the tile and the Stock screen can never disagree, and show it the same way: `2,840.00 KG · 25 PCS`. **Never add KG and PCS into one number.** Stock of an item taken off the list is left out of both, as it is of the Stock screen.

```sql
-- Active Agents. The roster: everyone placed at this centre who holds the agent
-- role. NOT who has recorded something today (settled with the client, 24 Sep).
SELECT COUNT(*) FROM center_people
WHERE center_id = :center AND is_agent = 1;

-- Transports Done: received / raised. Both figures are about transfers raised
-- today, because the tile sits under Today's Summary—one raised yesterday and
-- received today is not counted.
SELECT SUM(status = 'RECEIVED'), COUNT(*) FROM transfers
WHERE center_id = :center
  AND requested_at >= :today_start_utc
  AND requested_at < :tomorrow_start_utc;

-- Pending Expenses.
SELECT COUNT(*) FROM expenses
WHERE center_id = :center AND status = 'PENDING';

-- Approvals & Claims: the badge, and its three parts.
SELECT (SELECT COUNT(*) FROM expenses
        WHERE center_id = :center AND status = 'PENDING') AS expenses,
       (SELECT COUNT(*) FROM cash_requests
        WHERE center_id = :center AND status = 'PENDING') AS cash_requests,
       (SELECT COUNT(*) FROM category_requests
        WHERE center_id = :center AND status = 'PENDING') AS category_requests;

-- Transfer Requests: waiting for a decision.
SELECT COUNT(*) FROM transfers
WHERE center_id = :center AND status = 'REQUESTED';

-- Verification: waiting to be verified.
SELECT COUNT(*) FROM collections
WHERE center_id = :center AND status = 'SUBMITTED';

-- Assigned Tasks: pending is every open task, of any age; completed is today's
-- only. Two different windows on one card—do not give them the same one.
SELECT (SELECT COUNT(*) FROM tasks
        WHERE center_id = :center AND status = 'PENDING') AS pending,
       (SELECT COUNT(*) FROM tasks
        WHERE center_id = :center AND status = 'COMPLETED'
          AND completed_at >= :today_start_utc
          AND completed_at < :tomorrow_start_utc) AS completed;

-- Open requests, for the Tasks and Requests screen's badge.
SELECT COUNT(*) FROM requests
WHERE center_id = :center AND status = 'OPEN';
```

### Notes on Active Agents

- The label says **Active** and means the roster. Nothing on the phone records whether an agent has started work: `center_people` carries `user_id`, `center_id`, `name`, `phone`, `is_agent` and nothing else—no last-seen, no activity. The "8/10" fraction in the old PRD journey cannot be built from this data and is not what the screen shows.
- Deactivated and deleted people are already gone. `/bootstrap` sends `center_people` filtered to active, undeleted users, and sets `is_agent = 1` only for someone holding the agent role in this company. So `is_agent = 1` is the whole filter: no extra condition, and the supervisor does not count themselves.
- `center_people` reaches only someone who hands out work, so this tile exists on the supervisor's Home and nowhere else.
- `COUNT(*)` is right because the table's key is `(user_id, center_id)`—one row per person per centre. Should this tile ever be shown across several centres, it becomes `COUNT(DISTINCT user_id)`: an agent placed at two of them is one agent, which is how the server counts.

Agent status (the **View Status** card) already takes `:center`. Pass the active centre, so the list under the tile is the same people the tile counted.
