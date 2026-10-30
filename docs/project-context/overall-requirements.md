# EERL Mobile — Offline Data Guide

> Local context snapshot from [the overall reference artifact](https://claude.ai/artifact/PyiXRt2UzSPbCu2ejoCjEu#2c3cabed-28bc.mqr00mm7t5y.3325~the-response), captured on 30 Oct 2026. Update only when the user explicitly requests it.

8 Oct 2026 · @Someone

## How it fits together

The app reads only from its own SQLite database. The network has two jobs, and they have fixed names:

- **Bootstrap** — server → phone.`GET /bootstrap` brings the server's data down into SQLite.
- **Sync** — phone → server. The outbox sends the user's writes up. The Sync Status screen means this direction.

The active role never changes what is stored. It only decides which screens exist and how they query SQLite.

A live-update socket comes later. Until then, Bootstrap runs on open, on reconnect, after Sync and on pull-to-refresh.

**In Swagger** (`/docs/mobile`) every call the app makes sits in a named group, in the order the app meets them: Auth, Bootstrap, then the outbox writes by area. The reads that`/bootstrap` replaced are kept together in the last group,**Not used by the app**: don't build against them. Every response has named examples, one per shape it can answer, taken from real responses and checked against the schema, so the keys shown are exactly the keys sent.

## Login and the first download

The first download fills SQLite once. After it, the app works fully with no signal.

1. `POST /auth/send-otp` with the phone number.
2. `POST /auth/verify-otp` → store`accessToken` and the session expiry.
3. `GET /bootstrap` with**no**`since`. Apply the response (see the contract below) and save its`cursor`.
4. While`hasMore` is`true`, call`GET /bootstrap?since=<cursor>` and apply each page. Show a progress bar: a supervisor's first download can take several pages.
5. Save`me.roles` into`my_roles`,`me.centers` into`my_centers`, and`me.scopeKey` into`sync_meta`.
6. More than one role in`me.roles` → show the role picker. One role → go straight in. Save the choice as`active_role` in`sync_meta`.

The first download contains:

- Every reference table in full: items, rates, item order, vehicles, MRF people, ragpickers, expense categories.
- Records from the last**7 days**, or**30 days** if the user also holds the supervisor role.
- Anything still open however old: submitted collections, pending expenses and cash requests, open tasks and requests, transfers not yet received.
- The user's own drafts.

A user holding both roles gets the supervisor's wider set once. Agent mode then narrows it with a query; nothing is downloaded again.

## Every app open

On every open the app makes one call,`GET /bootstrap?since=<cursor>`. There is no separate "has anything changed?" check: this call is the check. When nothing changed, the answer is a few hundred bytes.

1. Show the screen from SQLite straight away. Never wait for the network to show data.
2. In the background, send the outbox first (see Sync). Your own writes should be on the server before you ask what changed.
3. Call`GET /bootstrap?since=<cursor>`, apply it, and repeat while`hasMore` is`true`.
4. If`me.scopeKey` differs from the one you stored, do a reset (see Edge cases).

Run the same steps on each of these:

| Trigger | Why |
| --- | --- |
| App opened, or brought back from the background | The user may have been away for hours |
| Network comes back | Changes piled up while offline |
| The outbox finishes sending | Picks up the server's version of what you just sent |
| Pull-to-refresh | The user asked |
| Socket nudge (coming later) | Something changed while the app is open |

Never run two at once. If one is already running when a trigger fires, set a flag and run once more when it finishes.

## The /bootstrap contract

One endpoint, two behaviours: no`since` returns everything,`since` returns only what changed after it.

```
GET /api/v1/mobile/bootstrap?since=48213
Authorization: Bearer <accessToken>
```

No role header. Dart's HTTP client asks for gzip and unpacks it on its own, so nothing is needed for compression.

### The cursor

A change number, sent as a string. Every row the app cares about gets the next number from one counter each time it is created, changed or deleted. The cursor is simply the highest number you have seen.

| Situation | Request | Response`cursor` |
| --- | --- | --- |
| First open ever | `GET /bootstrap` | `"48213.f20260926"` |
| Nothing of yours changed | `GET /bootstrap?since=48213.f20260926` | `"48213.f20260926"` or a little higher,`tables` empty |
| A rate changed, two slips approved | `GET /bootstrap?since=48213.f20260926` | `"48216.f20260926"`, the reference set + 2 collections |
| Middle of a big first download | `GET /bootstrap?since=48213.f20260926.p3.9f1b…` | `"48213.f20260926.p5.2c4a…"`,`hasMore: true` |
| A cursor this server did not issue | `GET /bootstrap?since=nonsense` | `400 INVALID_CURSOR`: drop it, download again |

The`.f20260926` part is the first day of the phone's history window (IST) when it was last brought up to date. On the first sync after midnight the server sends`deletes` for closed records that aged out since, and moves the day on:`48216.f20260926` comes back as`48217.f20260927`. A phone away for weeks gets those deletes over a few pages with`hasMore: true`. The app does nothing special: it stores the cursor and applies the deletes.

Store it as it comes and send it back as it comes. Never parse it or do maths on it.

### The response

Below is one page carrying**every table and every key** the app can receive: a sync where reference data changed (so the`replace` tables arrive whole) along with record changes and one delete. It was checked key for key against the server's schema. A real response carries only the tables with something to report, and`center_people` and`destinations` only reach someone who holds a supervisor role. Ids and photo URLs are shortened here.

```
{
  "data": {
    "cursor": "48216",
    "hasMore": false,
    "full": false,
    "serverTime": "2026-10-01T12:00:00.000Z",
    "me": {
      "scopeKey": "ac53f9332a9694f4",
      "user": {"id": "06562e20…", "name": "Mitesh Dave", "phone": "+919812345678", "photoUrl": null},
      "roles": [
        {"key": "AGENT", "name": "Collection Point Agent",
         "modules": ["HOME", "COLLECTION", "RECORDS", "PROFILE", "TRANSFERS", "WALLET", "MATERIAL_CONFIG", "RAGPICKERS", "TASKS_REQUESTS", "TASKS", "REQUESTS", "SYNC_STATUS", "NOTIFICATIONS", "HELP"]},
        {"key": "SUPERVISOR", "name": "Collection Supervisor",
         "modules": ["HOME", "VERIFICATION", "PENDING_VERIFICATION", "VERIFIED_ENTRIES", "STOCK", "TRANSFERS", "PROFILE", "TASKS_REQUESTS", "TASKS", "REQUESTS", "EXPENSE_APPROVALS", "MRF_PEOPLE", "D2D_VEHICLES", "RAGPICKERS", "AGENT_STATUS", "SYNC_STATUS", "NOTIFICATIONS", "HELP"]}
      ],
      "centers": [
        {"id": "15c937a9…", "isPrimary": true, "agentNumber": 1, "slipCounter": {"date": "2026-10-01", "lastCount": 12}}
      ],
      "supervisor": {"name": "Mahesh Chaudhary", "phone": "+919876500002", "photoUrl": "https://…/profile/….jpg"},
      "session": {"expiresAt": "2026-10-08T12:00:00.000Z"}
    },
    "tables": {
      "centers": {"replace": [
        {"id": "15c937a9…", "name": "MRF Station Aanjana", "code": "AAN", "address": "Udhna, Sardar Market, Surat", "eod_lock_time": "18:30:00"}
      ]},
      "items": {"replace": [
        {"id": "23b26006…", "name": "Cardboard", "category_name": "CAT-4 Other", "material_type": "NON_PLASTIC", "colour": "#7A5BA6", "image_url": "https://…/EERL/items/….jpg", "hsn_code": null, "unit_code": "KG", "unit_name": "Kilogram", "is_active": 1}
      ]},
      "center_channels": {"replace": [
        {"center_id": "15c937a9…", "channel": "D2D", "show_price": 1, "takes_payment": 1}
      ]},
      "center_items": {"replace": [
        {"center_id": "15c937a9…", "channel": "D2D", "item_id": "23b26006…", "is_selected": 1, "sort_order": 0, "rate": 18.5}
      ]},
      "vehicles": {"replace": [
        {"id": "09133617…", "number": "SUR-VEH-0001", "center_id": "15c937a9…", "plate_number": "GJ-05-BX-1234", "driver_name": "Kiran Rathod", "is_active": 1}
      ]},
      "mrf_people": {"replace": [
        {"id": "84802d0d…", "number": "AAN-MRF-0001", "center_id": "15c937a9…", "name": "Hardik Pandya", "phone": "+919700000002", "id_number": null, "photo_url": null, "is_active": 1, "role": "LABOUR"}
      ]},
      "ragpickers": {"replace": [
        {"id": "f58554b7…", "number": "AAN-RPK-0002", "center_id": "15c937a9…", "name": "Ramesh Kumar", "phone": "9700000009", "id_number": "XXXX-XXXX-9012", "photo_url": null, "is_active": 1}
      ]},
      "expense_categories": {"replace": [
        {"id": "bc86f715…", "center_id": "15c937a9…", "name": "Food / Refreshment", "is_active": 1}
      ]},
      "center_people": {"replace": [
        {"user_id": "e876c78e…", "center_id": "15c937a9…", "name": "Amit Sharma", "phone": "+919876543210", "is_agent": 1}
      ]},
      "destinations": {"replace": [
        {"id": "ed6cf8f9…", "name": "Bhatar Recycling Plant"}
      ]},
      "transfer_vehicles": {"replace": [
        {"id": "acacacac…", "number": "GJ-05-EE-1001", "ownership": "COMPANY", "transporter_name": null, "vehicle_type": "Tata 407", "capacity_kg": 3000}
      ]},
      "collections": {
        "upserts": [
          {"id": "a95407d7…", "center_id": "15c937a9…", "agent_id": "e876c78e…", "agent_name": "Amit Sharma", "channel": "RAMP", "status": "APPROVED", "slip_number": "AAN-260925-01-001", "collected_at": "2026-09-25T04:10:00.000Z", "vehicle_id": null, "mrf_person_id": null, "ragpicker_id": "f58554b7…", "given_by_name": null, "handed_over_by": "Suresh Bhai", "paid_by": "CASH", "takes_payment": 1, "total_amount": 1145.7, "handover_photo_urls": "[\"https://…/collections/handover/….png\"]", "rejection_reason": null, "verified_by_name": "Mitesh Dave", "verified_at": "2026-09-30T10:34:16.702Z", "updated_at": "2026-09-30T10:34:16.703Z"}
        ],
        "deletes": ["aa5eaa56…"]
      },
      "collection_items": {
        "upserts": [
          {"id": "a1c31955…", "collection_id": "a95407d7…", "item_id": "23b26006…", "qty": 42.5, "verified_qty": 41, "rate": 18.5, "amount": 758.5, "photo_urls": "[\"https://…/collections/items/….png\"]", "sort_order": 0}
        ],
        "deletes": []
      },
      "expenses": {
        "upserts": [
          {"id": "f6705961…", "center_id": "15c937a9…", "user_id": "e876c78e…", "user_name": "Amit Sharma", "category_id": "bc86f715…", "amount": 600, "note": "Two loaders for the Tuesday truck", "status": "REJECTED", "number": "AAN-EXP-260927-001", "receipt_photo_urls": "[\"https://…/expenses/….png\"]", "decided_by_name": "Priya Admin", "decision_reason": "Loaders are paid by the contractor, not from the float.", "created_at": "2026-09-30T10:34:20.168Z", "updated_at": "2026-09-30T10:34:20.193Z"}
        ],
        "deletes": []
      },
      "cash_requests": {
        "upserts": [
          {"id": "0eece32c…", "number": "AAN-CSH-260930-001", "center_id": "15c937a9…", "requested_by": "e876c78e…", "requested_by_name": "Amit Sharma", "amount": 20000, "reason": "Opening float for the week", "status": "APPROVED", "decided_by_name": "Priya Admin", "decision_note": null, "created_at": "2026-09-30T10:34:15.868Z", "updated_at": "2026-09-30T10:34:15.888Z"}
        ],
        "deletes": []
      },
      "category_requests": {
        "upserts": [
          {"id": "d9a98075…", "number": "AAN-CAT-260930-001", "center_id": "15c937a9…", "requested_by": "e876c78e…", "requested_by_name": "Amit Sharma", "name": "Tyre puncture", "reason": "Happens every week on the D2D round", "status": "PENDING", "decided_by_name": null, "decided_at": null, "decision_reason": null, "created_at": "2026-09-30T10:34:20.687Z"}
        ],
        "deletes": []
      },
      "transfers": {
        "upserts": [
          {"id": "4a0c550b…", "center_id": "15c937a9…", "type": "STOCK_TRANSFER", "status": "RECEIVED", "number": "AAN-TRF-260930-001", "destination_id": "ed6cf8f9…", "destination_name": "Bhatar Recycling Plant", "truck_expected_at": "2026-09-30T05:30:00.000Z", "dispatch_note": "Load the dry bales first.", "transfer_vehicle_id": null, "planned_vehicle_number": "GJ-05-AV-2290", "planned_vehicle_ownership": "HIRED", "transporter_name": "Shree Ram Transport", "transfer_fee": 1800, "fixed_qty": null, "estimated_expense": 1500, "vehicle_plate": "GJ-05-AV-2290", "driver_name": "Salim Shaikh", "requested_by": "e876c78e…", "requested_by_name": "Amit Sharma", "requested_at": "2026-09-30T10:34:19.245Z", "decided_by_name": "Mitesh Dave", "approved_at": "2026-09-30T10:34:19.269Z", "rejection_reason": null, "handed_over_at": "2026-09-30T10:34:19.297Z", "dispatched_weight": 100, "bale_count": 12, "vehicle_photo_urls": "[\"https://…/transfers/….png\"]", "weighbridge_photo_urls": "[\"https://…/transfers/….png\"]", "vehicle_differs": 0, "updated_at": "2026-09-30T10:34:19.560Z"}
        ],
        "deletes": []
      },
      "transfer_items": {
        "upserts": [
          {"id": "1153182a…", "transfer_id": "4a0c550b…", "item_id": "23b26006…", "qty": 100, "dispatched_qty": 100}
        ],
        "deletes": []
      },
      "tasks": {
        "upserts": [
          {"id": "b8066bc4…", "number": "AAN-TSK-261001-002", "center_id": "15c937a9…", "assigned_to": "e876c78e…", "assigned_to_name": "Amit Sharma", "assigned_by": "06562e20…", "assigned_by_name": "Mitesh Dave", "title": "Clear the ramp before the Tuesday truck", "description": "Tell me if anything looks wrong.", "priority": "NORMAL", "status": "COMPLETED", "due_at": "2026-10-02T11:30:00.000Z", "completed_at": "2026-10-01T11:56:26.428Z", "photo_urls": "[\"https://…/tasks/….png\"]", "created_at": "2026-10-01T11:56:24.492Z"}
        ],
        "deletes": []
      },
      "requests": {
        "upserts": [
          {"id": "f6cbe81f…", "number": "AAN-REQ-261001-001", "center_id": "15c937a9…", "created_by": "e876c78e…", "created_by_name": "Amit Sharma", "body": "The weighing scale at Ramp B is broken and needs replacing.", "priority": "HIGH", "status": "CLOSED", "follow_up_at": "2026-10-02T09:30:00.000Z", "answer": "New scale ordered, arrives Thursday.", "answered_at": "2026-10-01T11:56:26.835Z", "photo_urls": "[\"https://…/requests/….png\"]", "created_at": "2026-10-01T11:56:26.810Z"}
        ],
        "deletes": []
      },
      "wallet_entries": {
        "upserts": [
          {"id": "ff3ea2ba…", "center_id": "15c937a9…", "kind": "COLLECTION_PAYMENT", "amount": -1145.7, "note": null, "collection_id": "a95407d7…", "expense_id": null, "confirmed_at": "2026-09-30T10:34:16.672Z", "created_at": "2026-09-30T10:34:16.672Z"}
        ],
        "deletes": []
      },
      "day_closes": {
        "upserts": [
          {"id": "7d2e4c10…", "center_id": "15c937a9…", "date": "2026-09-29", "closed_by_name": "Amit Sharma", "closed_at": "2026-09-29T13:05:44.000Z"}
        ],
        "deletes": []
      },
      "notifications": {
        "upserts": [
          {"id": "43768da3…", "type": "COLLECTION_VERIFIED", "title": "Collection approved", "body": "AAN-260925-01-001 was approved by Mitesh Dave.", "deep_link": "eerl://collections/a95407d7…", "created_at": "2026-09-30T10:34:16.710Z", "read_at": null}
        ],
        "deletes": []
      },
      "center_balances": {
        "upserts": [
          {"center_id": "15c937a9…", "balance": 14564, "updated_at": "2026-09-30T10:34:20.661Z"}
        ],
        "deletes": []
      },
      "stock": {
        "upserts": [
          {"id": "469d6235…", "center_id": "15c937a9…", "item_id": "23b26006…", "stage": "RM", "qty": 12}
        ],
        "deletes": []
      }
    }
  }
}
```

### Applying it

- **`me`** arrives on every call, whole. Replace`my_roles` and`my_centers` with it.
- **`tables`** lists only tables with something to report. A table that is missing has no changes.
- **Row keys are exactly the SQLite column names** in the SQLite Schema & Queries doc, so a row can be inserted as it arrives.
- **Reference tables arrive as`replace`.** They are small, so when anything in them changes the whole set is sent. Delete that table's rows where`sync_state = 'synced'`, then`INSERT OR IGNORE` the new rows. Your own unsent rows survive. A table without a sync_state column is simply emptied first.
- **Record tables arrive as`upserts`and`deletes`.**`INSERT OR REPLACE` each upsert by primary key, and delete each id in`deletes`. Skip an upsert whose local row has`sync_state = 'pending'`, and skip a delete for such a row too: your version is on its way, and the server's copy comes back after it lands. Deleting a collection or transfer deletes its items and photos with it. Some deletes are records that simply aged out of the 7- or 30-day window; they are handled the same way.
- **Child rows come as a complete set.** When a`collections` row arrives, its`collection_items` in the same response are all of them: delete that collection's existing items, then insert. Same for`transfer_items`.
- **One page = one SQLite transaction**, and save the new`cursor` inside it. A crash halfway leaves the old data and the old cursor, and the next call repeats the page safely.
- **`full: true`** means this page is part of a download from scratch.

### Errors

| Answer | Meaning | Do |
| --- | --- | --- |
| `401` | Session expired | Go to login. Keep SQLite and the outbox; resume after login |
| `403 ACCOUNT_SUSPENDED` | Account switched off | Show the message; block the app |
| `409 NO_CENTER_ASSIGNED` | Account not set up | Show the message; nothing to do until an admin fixes it |
| `400 INVALID_CURSOR` | Cursor not recognised | Drop the cursor and do a reset |
| `5xx`, timeout | Temporary | Keep the old data; try again on the next trigger |

## Roles and switching

The active role changes two things only: which screens exist, and the`WHERE` clause each screen uses. It never changes what is in SQLite, and switching needs no network.

- **The server does not know or care which role is active.** There is no role header. A write is allowed if any role the user holds allows it.
- **So the app must hide actions that don't belong to the active role.** No Approve button in agent mode, even though the server would accept it.
- **Switching** = update`active_role` in`sync_meta`, rebuild the bottom nav and drawer, re-run the screen queries. Instant, offline.
- **Menus are drawn by the app.** Show an entry only if its module key is in the active role's`modules` in`my_roles`.

| Role | Module keys |
| --- | --- |
| Agent | `HOME`,`COLLECTION`,`RECORDS`,`WALLET`,`TRANSFERS`,`MATERIAL_CONFIG`,`RAGPICKERS`,`TASKS_REQUESTS`,`TASKS`,`REQUESTS`,`PROFILE`,`SYNC_STATUS`,`NOTIFICATIONS`,`HELP` |
| Supervisor | `HOME`,`VERIFICATION`,`PENDING_VERIFICATION`,`VERIFIED_ENTRIES`,`STOCK`,`EXPENSE_APPROVALS`,`MRF_PEOPLE`,`D2D_VEHICLES`,`AGENT_STATUS`,`RAGPICKERS`,`TASKS_REQUESTS`,`TASKS`,`REQUESTS`,`PROFILE`,`SYNC_STATUS`,`NOTIFICATIONS`,`HELP` |

The same table, two queries:

The query behind each of these lists is in EERL Mobile — SQLite Schema & Queries: Agent screens → Records and Tasks, Supervisor screens → Verification and Tasks.

The 7 and 30 days are measured on IST calendar days, the same as today's API. The server keeps the phone inside them: older records arrive as deletes once they are closed, so the database never grows past the window. Someone with both roles keeps 30 days; agent screens still show 7.

## Sync — sending your changes

Every write goes to SQLite first, then into the outbox, and the outbox is sent in order whenever the phone is online.

1. Write the row with`sync_state = 'pending'`. The screen updates at once.
2. Add an outbox row: method, path, body, the entity and its id, the ids it refers to, and the photos it waits for.
3. In the body, refer to photos by their**local photo id**, not a URL. The URL doesn't exist yet.
4. The sender runs when a write is queued, when the network returns and when the app opens.**One item at a time, oldest first.**
5. Just before sending, swap each photo id in the body for that photo's uploaded URL.
6. Handle the answer as below.

| Answer | Meaning | Do |
| --- | --- | --- |
| `2xx` | It landed | Write the response over the row, set`synced`, delete the outbox item |
| `409` with`NOT_PENDING` or`ALREADY_CLOSED` | It already landed on an earlier try, or someone else decided it first | Same as`2xx`. The next`/bootstrap` shows the final state |
| 409 CANCELLED (task complete), DRAFT_DISCARDED (draft save), ALREADY_SUBMITTED (draft save or discard), REJECTED (transfer handover) | Someone closed the record while this waited; /bootstrap skipped that change because the row was pending, and will not send it again | Not failed: drop the write, take the server's state, tell the agent why (16 Oct 2026 entry) |
| Any other`4xx`, including`409 DUPLICATE_REQUEST` and`409 ALREADY_RAISED` | The server refused it; retrying won't help | Mark the item and the row`failed`, show the message in Sync Status, carry on with the rest |
| `401` | Session expired | Stop. Resume after login |
| `5xx`, timeout, no network | Temporary | Stop. Retry after 5 s, 30 s, 2 min, then every 10 min |

### Rules that keep the order safe

- **An item waits while anything it refers to has failed.** A collection naming a ragpicker created offline refers to that ragpicker's id; if the ragpicker failed, the collection waits instead of failing too. Store these ids in`outbox.refs` when queueing.
- **An item waits for its photos.** It is not sent until every photo in`outbox_photos` is uploaded.
- **Sync Status shows every failed item** with the server's message, and two buttons: retry, or discard my change.
- **Discarding a failed change** marks the row so the next`/bootstrap` puts the server's version back. Simplest: delete the local row if it was never on the server; otherwise set`sync_state = 'synced'` and let the next page overwrite it.

### Merging queued writes

- A**draft save** for an id that already has an unsent draft save: replace the queued body instead of adding a second item.
- A**submit** is queued: drop any unsent draft saves for that id.
- A**discard** is queued and the draft was never sent: drop both. Nothing reaches the server.

### Ids and reference numbers

Every record has two identities, and the app treats them differently.

- **`id`** is a uuid v4**the app makes** the moment it creates anything, online or not, and sends in the URL (`PUT /…/{id}`). Use it for every link between rows, photos and outbox items straight away. Never wait for the server to give an id: a record made offline (say a new ragpicker) has to be usable at once (picked in a collection made offline), and a retried`PUT` with the same id lands on the same record instead of making a second one.
- **`number`** is what people read out, write down and search by. Only the collection slip number is built on the phone, because the slip prints with no signal. Every other number comes from the server.

| Record | Number | Made by |
| --- | --- | --- |
| Collection | `AAN-261005-07-012`: centre, IST day, your agent number at the centre, your count that day | **The app**, at submit (`slip_number`) |
| Expense | `AAN-EXP-261005-001` | Server |
| Transfer, sale | `AAN-TRF-261005-001`,`AAN-SEL-261005-001` | Server |
| Cash request | `AAN-CSH-261005-001` | Server |
| Category request | `AAN-CAT-261005-001` | Server |
| Task | `AAN-TSK-261005-001` | Server |
| Agent request | `AAN-REQ-261005-001` | Server |
| Ragpicker | `AAN-RPK-0001` | Server |
| MRF person | `AAN-MRF-0001` | Server |
| Vehicle | `SUR-VEH-0001` (the company's code: a van can move between centres) | Server |

A server number arrives in the write's response, and in the`number` column of that row on the next`/bootstrap`. Until then the column is`null`: show**Not synced yet** where the number goes, and never make up a placeholder number on the phone. Numbers are unique within the company and never reused, so it is safe to search and link by them.

### Slip numbers

The collection slip number is the only reference number the app makes, because the slip is printed or shared with the giver the moment Submit is pressed, usually with no signal. The server checks it when the collection arrives.

| Part of`AAN-261008-07-012` | Means | The app takes it from |
| --- | --- | --- |
| `AAN` | The centre's code | `centers.code` (set by the admin) |
| `261008` | The IST day Submit was pressed,`YYMMDD` | The same instant as`collectedAt`, in IST whatever the phone's time zone |
| `07` | This agent's number at this centre, 01–99 | `me.centers[].agentNumber`, given by the server when the user is placed there |
| `012` | This agent's count at this centre that IST day, 001–999 | `me.centers[].slipCounter.lastCount` + this phone's own slips today |

- **Unique offline.** Two agents differ in agent number, one agent's count only goes up, and the date separates days. The count starts again at 001 at midnight IST.
- **Made once, at the first Submit.** A draft has none, so a discarded draft uses none. Retries, reprints and the resubmit of a rejected collection keep the same number and`collectedAt` (`SLIP_NUMBER_CHANGED` otherwise). A refused submit keeps its number too: the count never goes back.
- **Reinstalls and new phones.**`slipCounter` is the highest count the server holds for this agent today. The app keeps the higher of that and its own, so a reinstalled phone carries on from 013, never back to 001.
- **The one repeat.** The same agent offline on two phones the same day can print one number twice. The server accepts both and flags the second for the admin; keep one phone per agent.
- **Block Submit and say why** when the centre has no code, the agent has no number at the centre, or the day's count would pass 999.
- **Server checks** (`422`, field`slipNumber`, each an app bug):`INVALID_SLIP_NUMBER`,`SLIP_CENTER_MISMATCH`,`SLIP_AGENT_MISMATCH`,`SLIP_DATE_MISMATCH`.

The SQL that builds it inside the Submit transaction, and the test cases the backend also runs, are under*Agent screens → Slip numbers* in EERL Mobile — SQLite Schema & Queries.

### The writes

The app makes every id with`uuid v4` (see*Ids and reference numbers* above), so sending the same request twice never creates two records.

| Action | Call | Role |
| --- | --- | --- |
| Save a draft collection | `PUT /collections/{id}` | Agent |
| Submit or resubmit a collection | `POST /collections/{id}/submit` | Agent |
| Discard a draft | `DELETE /collections/{id}` | Agent |
| Approve / reject a collection | `POST /collections/{id}/approve`,`/reject` | Supervisor |
| Log an expense | `PUT /expenses/{id}` | Agent |
| Decide an expense | `POST /expenses/{id}/decide` | Supervisor |
| Ask for cash | `PUT /cash-requests/{id}` | Agent |
| Decide a cash request | `POST /cash-requests/{id}/decide` | Supervisor |
| Ask for a new expense category | `PUT /expense-categories/requests/{id}` | Agent |
| Decide a category request | `POST /expense-categories/requests/{id}/decide` | Supervisor |
| Confirm cash received | `POST /wallet/entries/{id}/confirm` | Agent |
| Raise a transfer | `PUT /transfers/{id}` | Agent |
| Dispatch a transfer (Submit Transfer, both screens in one call) | `POST /transfers/{id}/handover` | Agent |
| Approve / refuse a transfer | `POST /transfers/{id}/approve`,`/reject` | Supervisor |
| Assign a task | `PUT /tasks/{id}` | Supervisor |
| Complete a task | `POST /tasks/{id}/complete` | Agent |
| Cancel a task | `POST /tasks/{id}/cancel` | Supervisor |
| Raise a request | `PUT /requests/{id}` | Agent |
| Answer a request | `POST /requests/{id}/answer` | Supervisor |
| Add / edit / switch off a ragpicker | `PUT`,`PATCH /ragpickers/{id}`,`POST …/status` | Both |
| Add / edit / switch off an MRF person | `PUT`,`PATCH /mrf-people/{id}`,`POST …/status` | Supervisor |
| Add / edit / switch off a vehicle | `PUT`,`PATCH /vehicles/{id}`,`POST …/status` | Supervisor |
| Save item order for a centre | `PUT /item-config` | Agent |
| Mark a notification read | `POST /notifications/{id}/read` | Both |
| Mark every notification read | `POST /notifications/read-all` | Both |
| Register the handset for push, or refresh its token | `POST /devices` | Both |
| Stop push to this handset (on sign-out) | `DELETE /devices/{token}` | Both |
| Sign out (online; the app forgets its token either way) | `POST /auth/logout` | Both |

**Approving a transfer:** pick the destination from the`destinations` table, leaving out the transfer's own`center_id`, and send`destinationFacilityId` plus an optional`vehicleArrivalTime`. Until the answer lands, show the transfer as approved locally. Refusing takes a`reason` of at least 3 characters, which the agent sees as written.

**Close the day is the one exception:**`POST /centers/{id}/day-close` is online-only, and only when the outbox is empty. Show`GET /centers/{id}/day-close` first: it says whether the day can close, and why not (`BEFORE_LOCK_TIME`,`OPEN_DRAFTS`,`ALREADY_CLOSED`). It checks today's collections, so it must see all of them.

## Photos

A photo is saved on the phone the moment it is taken, uploaded separately, and the record that uses it waits in the outbox until it is up.

### Taking a photo

1. **Compress at capture.** Longest side 1600 px, JPEG quality 70. A 3–4 MB camera photo becomes roughly 200–400 KB, which is what makes uploads on field networks bearable.
2. **Save it to the app's documents folder** (`getApplicationDocumentsDirectory`), never the temp or cache folder: the OS may empty those without asking.
3. **Add a`photos`row**: a new`uuid`, the file path,`status = 'local'`, and what it belongs to (`owner_table`,`owner_id`,`field`).
4. The record points at the photo by that local id until it is uploaded.

### Uploading

The uploader runs before the outbox sender, every time the sender runs.

1. Take up to 20 photos with`status``local` or`failed`.
2. `POST /uploads/batch` once for all of them → an`uploadUrl` and a`fileUrl` for each, in the order sent.
3. `PUT` each file's bytes to its`uploadUrl`.
4. Mark each photo`uploaded` and store its`fileUrl` in`remote_url`.

**Ask for upload URLs just before uploading, never at capture.** They expire after 15 minutes.

Send the`purpose` that matches where the photo is used:`COLLECTION_LINE`,`COLLECTION_HANDOVER`,`RAGPICKER`,`MRF_PERSON`,`EXPENSE_RECEIPT`,`TASK_COMPLETION`,`REQUEST` or`TRANSFER_HANDOVER`. It decides the folder the photo is stored in.

### Showing a photo

Records from`/bootstrap` carry their photos as lists of URLs. For each URL:

- A`photos` row with that`remote_url` and a file still on disk → show the local file.
- Otherwise → load the URL through a disk image cache such as`cached_network_image`.

**Supervisors:** after each`/bootstrap`, pre-load the photos of collections waiting for verification at their centres. Those are the ones they must look at, possibly offline. Everything else loads when opened.

**Item pictures:** every row of`items` carries`image_url`, the picture an admin set for that material (or`null`). The collection screen shows it beside the item, and a tap opens it full size. Download each one after`/bootstrap` (again only when its URL changes) and show the saved file, so it works offline. With no picture, show the item's`colour`.

### Clean-up

Delete a local photo file 7 days after it was uploaded; the URL still works.**Never delete a photo that isn't uploaded yet.**

## Drafts

A draft is saved to SQLite on every change and backed up to the server in the background, so it survives a reinstall and comes back through`/bootstrap`.

- **Locally** a draft is a`collections` row with`status = 'DRAFT'`, plus its`collection_items`.
- **Backup** is an outbox item,`PUT /collections/{id}` with the draft so far. Queue one when the agent moves between steps and when the app goes to the background, not on every keystroke. Queued saves merge (see Sync), so there is never more than one waiting per draft.
- **Photos in a draft:** a draft save sends only photos already uploaded. It does not wait for the rest. The next save includes more as the uploader catches up. A photo that was never uploaded is lost if the app is removed first; nothing can prevent that.
- **Submit** is`POST /collections/{id}/submit` with the whole collection. It replaces any queued saves, and it does wait for every photo.
- **Discard** is`DELETE /collections/{id}`. If the draft never reached the server, just delete it locally and drop its queued saves.
- **After a reinstall** the first download returns the user's own drafts, photos as URLs. Nobody else ever sees a draft, supervisors included.
- **Slip numbers** are still built on the phone at submit, from`my_centers.agent_number` and`slip_last_count`, exactly as today.
- **A rejected collection** is edited and submitted again with the same id and slip number.

## Totals and counts

Counts are plain queries on SQLite. Money and stock start from a server figure and are adjusted for your own unsent writes, so they stay right offline.

### Counts — the home tiles

The count queries are in EERL Mobile — SQLite Schema & Queries: Agent screens → Home and Supervisor screens → Home.

### Wallet balance

The server sends each center's balance in`center_balances`. An expense and a paid collection both take money out the moment they are submitted, so subtract the ones still in your outbox:

The`balance_now` query is in EERL Mobile — SQLite Schema & Queries: Agent screens → Wallet.

### Stock in hand

Same idea: the server's figure in`stock`, plus what your unsent collections brought in. A handover takes stock out the same way once it is recorded. A new transfer may ask only for what is free: that figure, less what the center's open transfers (waiting or approved) already ask for (Changelog, 8 Oct 2026 part 2).

The`qty_now` query is in EERL Mobile — SQLite Schema & Queries: Agent screens → Transfers.

When anything is still pending, show a small "includes changes not yet synced" note under the figure. The server's exact number arrives with the next`/bootstrap` after the outbox empties.

## The SQLite schema

One set of tables serves every role. There is**no role column on any record**: the role lives only in the queries.

| Group | Tables | How`/bootstrap` sends them |
| --- | --- | --- |
| Who I am | `my_roles`,`my_centers` | Whole, from`me`, every call |
| Reference | `centers`,`items`,`center_channels`,`center_items`,`vehicles`,`mrf_people`,`ragpickers`,`expense_categories`,`center_people`,`destinations` | `replace` — the whole set when anything in it changed |
| Records | `collections`,`collection_items`,`expenses`,`cash_requests`,`category_requests`,`transfers`,`transfer_items`,`tasks`,`requests`,`wallet_entries`,`day_closes`,`notifications`,`center_balances`,`stock` | `upserts` +`deletes` |
| Phone only | `sync_meta`,`photos`,`outbox`,`outbox_photos` | Never |

`center_people` comes only to someone who hands out tasks. Switched-off vehicles, people and categories are sent too, with`is_active = 0`: pickers show only active rows, the rosters' Deactivated tabs show the rest, and an old expense still names its category.

**The full schema now lives inEERL Mobile — SQLite Schema & Queries**: every`CREATE TABLE` and index, the queries that apply a`/bootstrap` page, the outbox and photo queries, and the query behind every agent, supervisor and common screen. Keep this guide for the why; use that doc for what to type.

These columns are exactly what`/bootstrap` sends: each table has a schema in Swagger under`GET /bootstrap`, and the server's tests check every row of a real response against it. A task has no completion-note column because the server does not store one yet (see the last section).

## Edge cases

| Case | What happens | App does |
| --- | --- | --- |
| A supervisor rejects a slip while the agent is offline | The next`/bootstrap` brings`REJECTED` and the reason | Nothing special. The server always wins on status |
| A supervisor approves something another supervisor already decided | `409 NOT_PENDING` | Treat as done; the next`/bootstrap` shows who decided |
| Two people edit the same ragpicker offline | The last one to reach the server wins | Nothing special. Rare for directory data |
| **Admin adds or removes a centre, or a role** | `me.scopeKey` changes | **Reset**: send the outbox, then empty every server table except rows that are`pending` or`failed`, delete the cursor, and do a first download |
| Session expires while offline | Nothing, until the phone is online | Keep working and queueing. On the next`401`, go to login; the outbox sends after login |
| The same user logs in again | — | Keep everything |
| **A different user logs in on this phone** | — | **Wipe everything**: all tables, the outbox, the photo files |
| Logout | — | Warn if the outbox isn't empty ("3 changes not yet synced will be lost"). Then wipe |
| App killed while sending | The request may or may not have landed | Resend on restart. Every write is safe to send twice |
| Upload URL expired | `PUT` to S3 fails with`403` | Set the photo back to`local`; the next run asks for a fresh URL |
| Disk filling up | — | Nothing to trim by date: the server sends closed records that aged out of the window as`deletes` (see The cursor). Only free photo files: an uploaded photo's local file can go once nothing in the outbox needs it. |
| Close the day with items still in the outbox | The server can't see them yet | Disable the button until the outbox is empty, and say why |

## What works today and what is coming

The outbox, photos and schema can be built now against endpoints that already exist. Only the new`/bootstrap` needs a stand-in until it ships.

| Piece | State | Until it ships |
| --- | --- | --- |
| Login:`send-otp`,`verify-otp` | Built | — |
| **`GET /bootstrap`**: change-number cursor,`me` block, the tables above | **Built** | — |
| Every write in the Sync table, each with an id the app makes | Built | — |
| `POST /uploads/batch` and the upload purposes | Built | — |
| No role header; each role with its own`modules` | Built | — |
| gzip on every response | Built | Nothing to do: Dart handles it |
| `/sync/changes` and the old nested`/bootstrap` | Removed | — |
| A task's completion note, stored on the task | Not yet: today it only reaches the supervisor's notification | Show the note from the notification |
| Supervisor transfer approve / reject on mobile | Built | — |
| Socket nudge while the app is open | Later | Refresh on open, reconnect and pull-to-refresh |

Suggested order on the app side: schema and the apply logic first (against the fixture), then the outbox, then photos, then roles and switching.

## APIs by role

Every call the app makes falls in one of three groups. Swagger shows the same label in each operation's title,`[Agent API]`,`[Supervisor API]` or`[Common API]`, and in an`x-api-audience` field. Calls marked**Not used by the app** are left out here.

### Agent APIs

| Call | What it does |
| --- | --- |
| `PUT /item-config` | Save which items show on a channel, and their order |
| `PUT /collections/{id}` | Back up a draft collection |
| `POST /collections/{id}/submit` | Submit a collection, or resubmit a rejected one |
| `DELETE /collections/{id}` | Discard a draft |
| `POST /wallet/entries/{id}/confirm` | Confirm cash sent to the center arrived |
| `PUT /expenses/{id}` | Log an expense |
| `PUT /cash-requests/{id}` | Ask for cash |
| `PUT /expense-categories/requests/{id}` | Ask for a new expense category |
| `GET /centers/{centerId}/day-close` | Can today be closed, and the day's summary (online) |
| `POST /centers/{centerId}/day-close` | Close the day (online) |
| `PUT /transfers/{id}` | Raise a stock transfer, up to the free stock (OVER_STOCK above it) |
| `POST /transfers/{id}/handover` | Dispatch a transfer: vehicle number, driver, loaded weight, bales, vehicle and weighbridge photos, in one call |
| `POST /tasks/{id}/complete` | Mark a task done |
| `PUT /requests/{id}` | Ask the supervisor for something |

### Supervisor APIs

| Call | What it does |
| --- | --- |
| `POST /collections/{id}/approve` | Approve a collection |
| `POST /collections/{id}/reject` | Reject a collection, with a reason |
| `POST /expenses/{id}/decide` | Approve or reject an expense |
| `POST /cash-requests/{id}/decide` | Send or refuse cash |
| `POST /expense-categories/requests/{id}/decide` | Approve or refuse a new category |
| `POST /transfers/{id}/approve` | Approve a transfer: destination and truck time. Can answer OVER_STOCK when other open transfers already claim the stock |
| `POST /transfers/{id}/reject` | Refuse a transfer |
| `PUT /tasks/{id}` | Assign a task |
| `POST /tasks/{id}/cancel` | Call a task off |
| `POST /requests/{id}/answer` | Answer an agent's request |
| `PUT` /`PATCH /mrf-people/{id}` | Add or edit an MRF person |
| `POST /mrf-people/{id}/status` | Deactivate or reactivate an MRF person |
| `PUT` /`PATCH /vehicles/{id}` | Add or edit a D2D vehicle |
| `POST /vehicles/{id}/status` | Deactivate or reactivate a vehicle |

### Common APIs (both roles)

| Call | What it does |
| --- | --- |
| `POST /auth/send-otp` | Ask for a login code |
| `POST /auth/verify-otp` | Sign in with the code |
| `POST /auth/logout` | Sign out |
| `GET /bootstrap` | Download everything, then the changes |
| `POST /uploads/batch` | Upload URLs for waiting photos |
| `PUT` /`PATCH /ragpickers/{id}` | Add or edit a ragpicker |
| `POST /ragpickers/{id}/status` | Deactivate or reactivate a ragpicker |
| `POST /notifications/{id}/read` | Mark one notification read |
| `POST /notifications/read-all` | Mark all notifications read |
| `POST /devices` | Register the handset for push |
| `DELETE /devices/{token}` | Stop push to this handset |

A person who holds both roles may call all three groups. The server judges each call on every role the account holds, so the label says which screens call it, not who is allowed.

## Supervisor transfer screens (copy the manager's CM-M03)

The supervisor approves and rejects transfers and arranges the truck. Copy the manager's**CM-M03 Transfer Requests** module into the supervisor app and make exactly the changes below; everything not mentioned stays as designed. Words in quotes are the exact text to show. Every list and form has its SQL in the SQLite doc (*Supervisor screens → Transfers*), and every write its transaction, body and answers under*8 Oct 2026 (part 4)* there. All of it is live in the API.

**Show it only when allowed.** The drawer entry and the home tile appear only when the active SUPERVISOR role's`roles[].modules` contains`TRANSFERS`.

### Screen 1 — Transfer Requests (from "CM-M03 Transfer Requests" and "… Empty")

- **Title:** "Transfer Requests" (keep).
- **Search** (placeholder "Search by number or name"): matches`transfers.number` or`requested_by_name`.
- **Chips, in this order:** "All" · "Pending" · "Approved" · "Dispatched" · "Closed". Open on**Pending**. Each chip shows its count. Pending =`REQUESTED`; Approved =`APPROVED`; Dispatched =`DISPATCHED`; Closed =`RECEIVED` and`REJECTED`; All = every status.
- **Card, top to bottom:**
1. The number (`number`, e.g. "AAN-TRF-261008-001"), replacing "#TRF-2026-089". For a sale (`type = 'SELL_ITEM'`) add a grey "Sale" label beside it.
2. "From :*centre name* " (keep).
3. **Replace "Total : 1200.60 KG"** with the item and quantity: "*PET Bottles* ·*270 KG* ", the item name in its colour (`items.colour`).
4. **"To :*destination_name*" only when the status is Approved, Dispatched or Received.** Never on Pending or Rejected cards.
5. Date and time raised (`requested_at`, IST, e.g. "22 Oct • 11:15 AM") (keep).
6. **Status chip:** Pending (amber) · Approved (green) · Dispatched (blue) · Received (green) · Rejected (red). When`rejection_reason` starts with "Cancelled after approval:", show "Cancelled" (red) instead of Rejected.
7. When`vehicle_differs = 1`: a small amber "Different truck" label under the status.
- **Tap a card:** Pending → Screen 2. Approved → Screen 7. Dispatched or Received → Screen 8. Rejected or Cancelled → Screen 9. A sale opens Screen 7 or 8 with no buttons.
- **Empty:** "No Transfer Request Found" (keep).

### Screen 2 — Transfer Request Details, pending (from "CM-M03 Transfer Requests Pending")

- **Request Information, in this order:**
- "From Location": the centre name.
- **"Available Stock" → "Stock in hand"**:`qty_now` with the unit.
- **Add "Free to send"**:`qty_free` with the unit.
- "Request Date & Time":`requested_at`.
- "Requested By":`requested_by_name`.
- **Add "Estimated trip cost"**:`estimated_expense` as "₹ 1,200". Leave the row out when it is null.
- **"Request Status": "Waiting for your approval"** (amber), replacing "Waiting for Collection Manager".
- **Items to Transfer:** keep (item in its colour, quantity with unit). When the quantity is more than Free to send, show under it in red: "Other open transfers already claim this stock. Approving will be refused; reject one of them first."
- **Buttons: "Reject"** (keep)**and "Dispatch" → "Approve"**. Approve opens Screen 3; Reject opens Screen 6.

### Screen 3 — Select Destination, step 1 of approving (from "CM-M03 Transfer Requests Choose Destination")

- **Top card:** the centre's name and "Current Location", replacing "EERL - Surat East Zone".
- **"Where should this stock be transferred?"**: one card per row of`destinations`, leaving out the centre the stock leaves from. Each card shows**the name only: remove "12 KM away", "2 hours to reach" and their icons.**
- **Add under the list:**
- "Truck expected": date and time picker, optional, IST. Helper: "Leave it empty if the trip is not booked yet."
- "Note": optional, up to 255 characters.
- **Footer:** "*540.00 KG* " | "*₹1,960* " (keep): the quantity asked and the estimated trip cost (leave the amount out when null).
- **Buttons:** keep**"Arrange Vehicle"** as the only button, full width;**remove "Submit"**. It goes to Screen 4. With no destination picked: "Choose where the material is going."

### Screen 4 — Arrange Vehicle (from "CM-M03 Arrange Vehicle & Approve")

- **"Select Vehicle For Transfer *"**: a dropdown of the`transfer_vehicles` rows, company trucks first. Each option reads "*GJ-05-EE-1001* · Company truck" or "*GJ-05-HR-2002* · Hired from*Shree Ram Transport* " ("· Hired" when there is no transporter). The last option is always**"Other hired truck"**. When the list is empty, only "Other hired truck" is offered.
- **Under the dropdown, by choice:**
- **Company truck:** the line "Company truck: no fee." and "Capacity*3,000* KG" when known. No fee field.
- **Hired truck from the list:** "Truck fee (₹) *" (number, 0 or more, 2 decimals at most) and the capacity when known.
- **Other hired truck:** "Vehicle number *" (saved in capitals), "Transporter" (optional) and "Truck fee (₹) *".
- **"Items to Transfer":** keep.
- **"Approve & Confirm":** checks, then queues the approval (SQLite doc, part 4 §3) and opens Screen 5. Messages: no truck → "Choose the truck that will take it."; no fee → "Enter the fee in rupees for this hired truck."; bad number → "Enter the number as on the plate."

### Screen 5 — Approved popup (from "CM-M03 Approved Success")

- **Title:** "#TRF-2026-089 Request Dispatched!" → "*AAN-TRF-261008-001* approved".
- **Text:** "Vehicle GJ-05-BX-1234 is in transit. Awaiting Response by Warehouse Supervisor." → "*Amit Sharma* will send it to*Bhatar Recycling Plant*. Truck*GJ-05-EE-1001*, expected*10 Oct, 10:00 AM*." With no truck time: "… Truck*GJ-05-EE-1001*; time to be told."
- **Offline** (the approval is still in the outbox): add the line "It will send when you're back online."
- **"Back to Requests":** keep.

### Screen 6 — Request Reject (from "CM-M03Transfer Request Reject Reason" and "… Fill Details")

- **Title:** "Request Reject" → "Reject transfer".
- **"Reason for Reject *"** with the four boxes (keep): "No Vehicle Available", "Insufficient Yard Capacity", "Incorrect Material / Weight Details", "Other". Use the label "Reason for Reject *" on both screens.
- **"Remarks"** (keep, max 150).**Replace the sample text** in the design: it talks about an expense.
- **Rule:** at least one box ticked; "Other" needs Remarks. Message: "Choose a reason, or write one under Remarks."
- **What is sent (23 Oct 2026):**`reason` = the ticked labels joined with ", ", e.g. "No Vehicle Available, Incorrect Material / Weight Details";`remarks` = the Remarks box, apart, e.g. "All yard trucks are out, try after 2 PM.", or`null` when empty. Before 23 Oct the server refused`remarks` and they were joined into the reason.
- **"Confirm Rejection":** keep; queues the rejection (part 4 §4) and returns to Screen 1.
- **Toast:** "Collection Rejected! Collection #TRF-2026-089 rejected." → "Transfer rejected" / "*AAN-TRF-261008-001* rejected."

### Screen 7 — Transfer Request Details, approved (from "CM-M03 Transfer Requests Pending-1")

- **Request Information, in this order:**
- **"Vehicle" → "Truck"**:`planned_vehicle_number`; second line "Company truck" or "Hired from*transporter_name* "; third line "Capacity*3,000* KG" when the truck is in`transfer_vehicles` and has a capacity. Replaces "Truck (Capacity 3000 KG)".
- **Add "Truck fee"**: "₹*1,800* " (`transfer_fee`), or "No fee (company truck)".
- **"From Location": the centre name**, replacing "National Highway 8, 24 KM away".
- "To Location":`destination_name`.
- **Add "Truck expected"**:`truck_expected_at`, or "Not booked yet".
- **Remove "Available Stock"** on this screen.
- "Request Date & Time", "Requested By": keep.
- **Add "Approved by"**: "*decided_by_name* •*approved_at* ".
- **"Request Status": "Vehicle Dispatched by Collection Manager" → "Approved: waiting for the truck"** (green).
- **No buttons.** Changes after approval (destination, time, truck, cancel) are made by the admin on the web.

### Screen 8 — Transfer Request Details, dispatched or received (from "CM-M03 Transfer Requests Approved By Warehouse Supervisor")

- **"Request Status": "Transfer Completed" → "Dispatched"** (blue) when`DISPATCHED`,**"Received"** (green) when`RECEIVED`.
- **Request Information:** as Screen 7 (Truck arranged, Truck fee, From, To, Truck expected, Requested, Approved by).
- **Items to Transfer:** add a right-hand column**"Loaded"**:`transfer_items.dispatched_qty`.
- **The cards under it:**
- **"Vehicle number" → "Truck loaded"**:`vehicle_plate`, with an amber**"Different truck"** label when`vehicle_differs = 1`.
- **"Driver Detail" → "Driver"**:`driver_name`.
- **Add "Loaded weight"**:`dispatched_weight` KG.**Add "Bales / boris"**:`bale_count`, or "—".**Add "Loaded at"**:`handed_over_at`.
- **"Vehicle Photo" → "Vehicle photos"**: every URL in`vehicle_photo_urls`.
- **Add "Weighbridge photos"**: every URL in`weighbridge_photo_urls`; leave the card out when the list is empty.

### Screen 9 — Rejected summary (from "CM-M03 Transfer Requests Rejected Summary" and "… Rejected Summary In Closed")

- **"Request Status": "Rejected By Collection Manager" → "Rejected by*decided_by_name*"** (red). When`rejection_reason` starts with "Cancelled after approval:", show "Cancelled by*decided_by_name* " instead.
- **"Reason for Reject" card:** "Reason :*rejection_reason* ", then "Remarks :*rejection_remarks* " on its own line when there are any (23 Oct 2026). Hide the Remarks line when it is empty.
- **On the list ("… In Closed"):** rejected cards show no "To" line (Screen 1, rule 4).

### Screen 10 — Home and drawer

- **Drawer:** add "Transfer Requests" directly under "Facility Stock".
- **Home:** add the tile "Pending Transfers*5* ": the count of`REQUESTED` transfers at the supervisor's centres (*Supervisor screens → Home* in the SQLite doc). Tapping it opens Screen 1 on Pending.
- **Do not copy** the manager's OTP approval, Sales or zone selector: they are not the supervisor's.

### On the agent's side (AG-M06)

- **Approved card and detail:** add "Truck*GJ-05-EE-1001* " (`planned_vehicle_number`) beside the truck time. Never show a fee: it is null on the agent's phone.
- **Vehicle Details:** the vehicle number opens already filled with the arranged truck (query in part 4 §6). The agent changes it only if a different truck came; that is accepted and flagged for the supervisor.
- **Status text:** "Waiting for Collection Manager" → "Waiting for supervisor"; "Rejected By Collection Manager" / "Approved By Warehouse Supervisor" → "Rejected by*name* " / "Approved by*name* " (`decided_by_name`).

## Validation rules (28 Oct 2026)

Check a form before it saves, and before anything goes into the outbox, so the agent sees a problem at once instead of a refusal later. These tables are generated from the server's own request schemas (`npm run validation:mobile` in the backend), so they are the rules the server applies. They cover every fixed-point write.

Each API has up to three parts:

- **The table: field rules.** Required, type, length, range, decimal places, allowed values. Use them as form validators. Lengths count after spaces are trimmed from both ends. An optional field may be left out or sent as`null`;`null` never clears a value. "Required: Yes (choice 2)" means required when that shape is sent.
- **Check before saving: rules across fields.** Rules that depend on another field or on what is in SQLite: the collection type, prices and payment at the centre, the wallet balance, free stock. Check them before Save or Submit.
- **The server may still refuse it with:** refusals only the server can judge, such as a name someone else took or a record that moved on. Show`error.details[].message` against`details[].field` (`lines.2.amount` is the third line's amount); without`details`, show`error.message`.

Every API can also answer`400 VALIDATION_ERROR` (one`details` entry per field),`401` (sign in again),`403 ACCOUNT_SUSPENDED`,`409 NO_CENTER_ASSIGNED` and`500` (safe to retry); see**Errors** under*The /bootstrap contract*.

### Auth

#### `POST /auth/send-otp`

[Common API] Request a login OTP

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `phone` | Yes | Text | 10 digits starting 6–9, with or without`+91`; spaces are ignored. Stored and returned as`+919876543210`. |

**The server may still refuse it with:**

- **409**`NO_OTP_RECIPIENT` — No supervisor is set for this account, so no code can be sent.
- **429**`RATE_LIMIT_EXCEEDED` — Too many requests from this device. Wait and retry.

#### `POST /auth/verify-otp`

[Common API] Verify the OTP and start a session

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `phone` | Yes | Text | 10 digits starting 6–9, with or without`+91`; spaces are ignored. Stored and returned as`+919876543210`. |
| `otp` | Yes | Text; exactly 6 characters; must match`^\d{6}$` |  |

**The server may still refuse it with:**

- **401**`INVALID_OTP` — Wrong, expired or destroyed code. The same response for all three.
- **429**`RATE_LIMIT_EXCEEDED` — Too many sign-in attempts from this network (30 in 15 minutes). Wait and retry.

#### `POST /auth/logout`

[Common API] Log out

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `global` | No | `true` or`false`; left out:`false` |  |

### Bootstrap & Reference Data

#### `PUT /item-config`

[Agent API] Save which items show, and their order, for one collection type at one center

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `centerId` | Yes | UUID | The center selected in the app. One of the agent’s centers, else`403`. |
| `collectionChannel` | Yes | One of`MRF`,`D2D`,`RAMP` | Inbound channel handled by the collection point agent |
| `tab` | No | One of`PLASTIC`,`NON_PLASTIC` |  |
| `items` | Yes | List of entries; at least 1 |  |
| `items[].itemId` | Yes | UUID |  |
| `items[].isSelected` | Yes | `true` or`false` |  |
| `items[].sortOrder` | Yes | Whole number; at least 0 | 0-based position |

**Check before saving:**

- Send the whole tab: every item on it, each once, with`sortOrder` unique within the save.
- Every item must be on the`tab` being saved (Plastic or Non-Plastic, from`items.material_type`).

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **422**`DUPLICATE_SORT_ORDER` — Two items have the same`sortOrder`.`details[0].field` is`sortOrder`.
- **422**`INVALID_ITEMS` — None of the item ids exist for this company.
- **422**`WRONG_TAB` — An item sent is not on the`tab` being saved.`details[0].field` names it.

### Ragpicker Directory

#### `PUT /ragpickers/{id}`

[Common API] Add a ragpicker

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `centerId` | Yes | UUID | The center selected in the app. One of the agent’s centers, else`403`. |
| `name` | Yes | Text; 2–255 characters | Required, 2–255 characters. Unique per center: a duplicate is`409 DUPLICATE_NAME` with`details[0].field = "name"`. |
| `phone` | Yes | Text | 10 digits starting 6–9; a leading`+91` is dropped and spaces are ignored. Stored and returned as`9876543210`. |
| `idNumber` | No | Text; up to 100 characters |  |
| `photoUrl` | No | URL |  |

**Check before saving:**

- The name must not already be listed at this centre (any`ragpickers` row with the same`center_id`, ignoring case).
- `photoUrl`: a`fileUrl` from`POST /uploads/batch`, uploaded by this user.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **409**`DUPLICATE_NAME` — Someone with this name is already listed at this center.`details[0].field` is`name`.

#### `PATCH /ragpickers/{id}`

[Common API] Edit a ragpicker

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `name` | No | Text; 2–255 characters |  |
| `phone` | No | Text |  |
| `idNumber` | No | Text; up to 100 characters |  |
| `photoUrl` | No | URL |  |

**Check before saving:**

- The name must not already be listed at this centre for someone else.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — No ragpicker with that id at any of the agent’s centers.
- **409**`DUPLICATE_NAME` — Someone with this name is already listed at this center.`details[0].field` is`name`.

#### `POST /ragpickers/{id}/status`

[Common API] Activate or deactivate a ragpicker

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `isActive` | Yes | `true` or`false` | false: deactivate. true: reactivate. |

**Check before saving:**

- Switching someone off is refused while they have a collection still open (draft or waiting for review).

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — No ragpicker with that id at any of the agent’s centers.
- **422**`UNPROCESSABLE` — The person has an open collection; the message names the document.

### MRF People

#### `PUT /mrf-people/{id}`

[Supervisor API] Add an MRF person, or replace one (SUP-M08)

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `centerId` | Yes | UUID | The center selected in the app. One of the agent’s centers, else`403`. |
| `name` | Yes | Text; 2–255 characters | Required, 2–255 characters. Unique per center: a duplicate is`409 DUPLICATE_NAME` with`details[0].field = "name"`. |
| `phone` | Yes | Text | 10 digits starting 6–9, with or without`+91`; spaces are ignored. Stored and returned as`+919876543210`. |
| `idNumber` | No | Text; up to 100 characters |  |
| `photoUrl` | No | URL |  |
| `role` | No | One of`SUPERVISOR`,`LABOUR`; left out:`"LABOUR"` | Omit for a labourer. Making somebody the SUPERVISOR while the center already has an active one is`409 SUPERVISOR_EXISTS` — deactivate the current one first. |

**Check before saving:**

- One active MRF supervisor per centre: adding a`SUPERVISOR` is refused while`mrf_people` has an active one at that centre.
- The name must not already be listed at this centre.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **409**`DUPLICATE_NAME` — Someone with this name is already listed at this center.`details[0].field` is`name`.
- **409**`SUPERVISOR_EXISTS` — That center already has an active MRF supervisor. Deactivate them, or make this person a labourer.

#### `PATCH /mrf-people/{id}`

[Supervisor API] Edit an MRF person (SUP-M08)

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `name` | No | Text; 2–255 characters |  |
| `phone` | No | Text |  |
| `idNumber` | No | Text; up to 100 characters |  |
| `photoUrl` | No | URL |  |
| `role` | No | One of`SUPERVISOR`,`LABOUR` | `SUPERVISOR` is the center’s MRF supervisor — the "MRF Details" person on MRF step 1, and the name printed on the slip.`LABOUR` people work under them and are the ones an agent picks as "Given By".**A center has at most one active SUPERVISOR.** |

**Check before saving:**

- Making someone`SUPERVISOR` is refused while the centre has another active one.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — No MRF person with that id at any of your centers.
- **409**`DUPLICATE_NAME` — Someone with this name is already listed at this center.`details[0].field` is`name`.
- **409**`SUPERVISOR_EXISTS` — That center already has an active MRF supervisor. Deactivate them, or make this person a labourer.

#### `POST /mrf-people/{id}/status`

[Supervisor API] Activate or deactivate an MRF person (SUP-M08)

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `isActive` | Yes | `true` or`false` | false: deactivate. true: reactivate. |

**Check before saving:**

- Switching a supervisor back on is refused while the centre has another active one.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — No MRF person with that id at any of your centers.
- **409**`SUPERVISOR_EXISTS` — That center already has an active MRF supervisor. Deactivate them, or make this person a labourer.

### Collections

#### `POST /uploads/batch`

[Common API] Get upload URLs for several photos in one call

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `photos` | Yes | List of entries; 1–20 of them | One entry per photo, up to 20. Answered in the same order. |
| `photos[].purpose` | Yes | One of`COLLECTION_LINE`,`COLLECTION_HANDOVER`,`RAGPICKER`,`MRF_PERSON`,`EXPENSE_RECEIPT`,`TASK_COMPLETION`,`REQUEST`,`TRANSFER_HANDOVER`,`LEAD_PHOTO`,`SOURCE_PHOTO` | Where the photo will be used, which decides the folder it is stored in.`COLLECTION_LINE`: an item photo on step 3.`COLLECTION_HANDOVER`: the vehicle or person photo on step 1.`RAGPICKER` /`MRF_PERSON`: a directory photo.`EXPENSE_RECEIPT`: a receipt for an expense.`TASK_COMPLETION`: a photo sent when completing a task.`REQUEST`: a photo on a request.`TRANSFER_HANDOVER`: a weighbridge slip or load photo at the handover.`LEAD_PHOTO` /`SOURCE_PHOTO`: an IEC lead or outbound source. |
| `photos[].contentType` | Yes | One of`image/jpeg`,`image/png` |  |
| `photos[].sizeBytes` | Yes | Whole number; more than 0 | Size of the file about to be uploaded. At most 5 MB. |

**Check before saving:**

- Each photo at most 5 MB (`sizeBytes`), JPEG or PNG; up to 20 in one call.
- Ask right before uploading: each`uploadUrl` expires 15 minutes after it is issued.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **422**`FILE_TOO_LARGE` — A photo is larger than 5 MB.`details[0].field` names it, e.g.`photos.3.sizeBytes`.

#### `PUT /collections/{id}`

[Agent API] Save a draft (create or replace)

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `centerId` | Yes | UUID | One of the agent’s centers, else`403`. |
| `type` | Yes | One of`MRF`,`D2D`,`RAMP` | Inbound channel handled by the collection point agent |
| `vehicleId` | No | UUID |  |
| `givenByName` | No | Text; up to 255 characters |  |
| `mrfLabourId` | No | UUID |  |
| `ragpickerId` | No | UUID |  |
| `handoverPhotoUrls` | No | List of URLs; up to 10 | Uploaded so far. |
| `paidBy` | No | One of`CASH`,`UPI` |  |
| `lines` | No | List of entries; up to 100 |  |
| `lines[].itemId` | Yes | UUID |  |
| `lines[].collectedQty` | No | Number; 0 to 999,999.999; at most 3 decimal places | As typed so far. |
| `lines[].verifiedQty` | No | Number; 0 to 999,999.999; at most 3 decimal places | As typed so far. |
| `lines[].rate` | No | Number; 0 to 99,999,999.99; at most 2 decimal places | Accepted but not kept: a draft always shows the center’s current rate. May be omitted. |
| `lines[].amount` | No | Number; 0 to 99,999,999.99; at most 2 decimal places | Accepted but not kept: worked out from the current rate. May be omitted. |
| `lines[].photoUrls` | No | List of URLs; up to 10 | Uploaded so far. |
| `gps` | No | Object (fields below) |  |
| `gps.lat` | Yes | Number; -90 to 90 |  |
| `gps.lng` | Yes | Number; -180 to 180 |  |

**Check before saving:**

- Only`centerId` and`type` are required. Nothing else is checked until Submit, so a draft can be saved at any step.
- Refused once the id is submitted (`ALREADY_SUBMITTED`) or discarded (`DRAFT_DISCARDED`).

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — No such collection for this agent (or it was discarded).
- **409**`ALREADY_SUBMITTED` — This id is already submitted, approved or rejected. A rejected collection is corrected through submit.
- **409**`DRAFT_DISCARDED` — This draft was discarded.

#### `DELETE /collections/{id}`

[Agent API] Discard a draft

No body.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — No such collection for this agent (or it was discarded).
- **409**`ALREADY_SUBMITTED` — A submitted collection cannot be discarded.

#### `POST /collections/{id}/submit`

[Agent API] Submit a whole collection, or resubmit a rejected one

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `centerId` | Yes | UUID | The center selected in the app. One of the agent’s centers, else`403`. |
| `type` | Yes | One of`MRF`,`D2D`,`RAMP` | Inbound channel handled by the collection point agent |
| `slipNumber` | Yes | Text; must match`^([A-Z0-9]{2,6})-(\d{6})-(\d{2})-(\d{3})$` | The number printed on the slip, built by the shared rule. A resubmit sends the same number. |
| `collectedAt` | Yes | Date-time, UTC (ISO 8601) | UTC, when the agent pressed Submit on the phone. Its IST date must match the slip number. |
| `vehicleId` | No | UUID |  |
| `givenByName` | No | Text; 1–255 characters |  |
| `mrfLabourId` | No | UUID |  |
| `ragpickerId` | No | UUID |  |
| `handoverPhotoUrls` | No | List of URLs; up to 10 | Step 1 photo. Ramp: at least one (person). D2D: optional (vehicle). MRF: none. |
| `paidBy` | No | One of`CASH`,`UPI` | Required exactly when the type takes payment at this center; otherwise omit or send null. |
| `lines` | Yes | List of entries; 1–100 of them | In the order shown on step 3. Each item at most once. |
| `lines[].itemId` | Yes | UUID |  |
| `lines[].collectedQty` | Yes | Number; 0 to 999,999.999; at most 3 decimal places | Collection weight (or count), in the item’s unit. Greater than 0. |
| `lines[].verifiedQty` | Yes | Number; 0 to 999,999.999; at most 3 decimal places | Verified weight (or count) after weighing, in the item’s unit. 0 or more. |
| `lines[].rate` | Yes | Number; 0 to 99,999,999.99; at most 2 decimal places; may be`null` | The rate shown on step 3, per unit.`null` when prices are hidden or the item has no rate. |
| `lines[].amount` | Yes | Number; 0 to 99,999,999.99; at most 2 decimal places; may be`null` | `verifiedQty × rate`, rounded to paise.`null` when`rate` is null. |
| `lines[].photoUrls` | Yes | List of URLs; up to 10 | At least one, each a`fileUrl` from`POST /uploads`. |
| `gps` | No | Object (fields below) |  |
| `gps.lat` | Yes | Number; -90 to 90 |  |
| `gps.lng` | Yes | Number; -180 to 180 |  |

**Check before saving:**

- By type:**D2D** needs`vehicleId` and`givenByName`;**MRF** needs`mrfLabourId` and takes no handover photo;**RAMP** needs`ragpickerId` and at least one`handoverPhotoUrls`. A key of another type is refused (`NOT_FOR_THIS_TYPE`).
- The vehicle, labourer or ragpicker must belong to this centre (`center_id`), or be a shared vehicle (`center_id` null). Switched-off ones are still accepted.
- MRF: the centre must have an active MRF supervisor (`mrf_people` with`role = SUPERVISOR`,`is_active = 1`), else`NO_MRF_SUPERVISOR`.
- `lines`: 1–100, each item at most once, each with at least one photo.`collectedQty` greater than 0;`verifiedQty` 0 or more.
- Prices: where`center_channels.show_price = 1` for this centre and type, send each line's`rate` and`amount = round(verifiedQty × rate, 2)` (within ₹0.01). Where it is 0, send both as null (`PRICE_HIDDEN`).
- `paidBy` exactly when`center_channels.takes_payment = 1`; otherwise leave it out or send null.
- `slipNumber` =`{centre code}-{YYMMDD}-{agent number, 2 digits}-{count, 3 digits}`: the centre code and agent number from`my_centers`, the IST date of`collectedAt`, the count after`slip_last_count`. A resubmit sends the same slip number and centre.
- Every photo URL must be a`fileUrl` issued to this user and actually uploaded (`PHOTO_NOT_ISSUED`,`PHOTO_NOT_UPLOADED`).
- Never refused, only flagged for the admin: a slip number already used, a phone clock more than 10 minutes ahead, a submit after the day closed.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — No such collection for this agent (or it was discarded).
- **409**`ALREADY_SUBMITTED` — The collection was already submitted (with different content, for a submit). Only a rejected one can change.
- **409**`CENTER_NOT_SET_UP` — The center has no code yet.
- **409**`NO_MRF_SUPERVISOR` — MRF collection at a center with no MRF supervisor.
- **422**`INVALID_COLLECTION` — One or more fields are wrong;`details` lists each.

#### `POST /collections/{id}/approve`

[Supervisor API] Approve a collection (SUP-M02)

No body.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — No such collection for this agent (or it was discarded).
- **409**`NOT_PENDING` — Not waiting for a decision: a draft, or already approved or rejected.

#### `POST /collections/{id}/reject`

[Supervisor API] Reject a collection, with a reason (SUP-M02)

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `reason` | Yes | Text; 3–1000 characters | The reasons ticked on Reject Collection. Shown to the agent on the collection. |
| `remarks` | No | Text; up to 1000 characters |  |

**Check before saving:**

- `reason` is required (the reasons ticked);`remarks` is optional, shown beside it.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — No such collection for this agent (or it was discarded).
- **409**`NOT_PENDING` — Not waiting for a decision: a draft, or already approved or rejected.

### Wallet

#### `POST /wallet/entries/{id}/confirm`

[Agent API] Confirm the cash arrived

No body.

**Check before saving:**

- Only a top-up (`kind = TOP_UP`) is confirmed.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — Not found
- **409**`NOT_A_TOP_UP` — Only cash sent to the center is confirmed.

#### `PUT /cash-requests/{id}`

[Agent API] Ask for cash for the center

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `centerId` | Yes | UUID |  |
| `amount` | Yes | Number; more than 0, at most 9,999,999; at most 2 decimal places | Rupees the agent is asking for. |
| `reason` | No | Text; up to 255 characters |  |

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — Not found
- **409**`ALREADY_RAISED` — This id was raised for a different amount.

### Expenses

#### `PUT /expenses/{id}`

[Agent API] Log an expense

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `centerId` | Yes | UUID | One of the agent’s centers, else`403`. |
| `categoryId` | Yes | UUID | From`bootstrap.centers[].expenseCategories`. A pending category cannot be used. |
| `amount` | Yes | Number; more than 0, at most 9,999,999; at most 2 decimal places | Rupees spent. More than the wallet holds is refused. |
| `spentAt` | Yes | Date-time, UTC (ISO 8601) | UTC, when the agent logged it on the phone. Works offline. |
| `note` | No | Text; up to 255 characters |  |
| `collectionId` | No | UUID | When the cost belongs to one collection, e.g. its vehicle hire. Null or left out: none. |
| `photoUrls` | No | List of URLs; up to 5 |  |

**Check before saving:**

- `amount` greater than 0, at most the centre's wallet balance (`center_balances.balance`), else`OVER_BALANCE`.
- `categoryId` must be one of this centre's categories (`expense_categories.center_id`); show only active ones in the picker.
- `collectionId`, when sent, must be a collection at this centre.
- Up to 5 receipt photos, each a`fileUrl` this user uploaded.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — Not found
- **409**`ALREADY_LOGGED` — This id was logged with different details.
- **422**`INVALID_EXPENSE` — Every problem at once in`details`:`amount` /`OVER_BALANCE`,`categoryId` /`CATEGORY_NOT_AT_CENTER`,`collectionId` /`COLLECTION_NOT_AT_CENTER`,`photoUrls.N` /`PHOTO_NOT_UPLOADED`.

#### `PUT /expense-categories/requests/{id}`

[Agent API] Ask for a new expense category

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `centerId` | Yes | UUID |  |
| `name` | Yes | Text; 2–100 characters |  |
| `reason` | No | Text; up to 255 characters |  |

**Check before saving:**

- The name must not match a category this centre already has, active or not, ignoring case (`CATEGORY_EXISTS`), nor an open request with the same name (`DUPLICATE_REQUEST`).

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — That id is a request somebody else raised.
- **409**`CATEGORY_EXISTS` — The center already has that category.
- **409**`DUPLICATE_REQUEST` — Someone at this center has already asked for this name.

#### `POST /expenses/{id}/decide`

[Supervisor API] Approve or reject an expense (SUP-M04)

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `outcome` | Yes | One of`APPROVED`,`REJECTED` |  |
| `reason` | No | Text; 3–1000 characters |  |
| `remarks` | No | Text; up to 1000 characters |  |

**Check before saving:**

- `reason` is required when`outcome` is`REJECTED`.`remarks` is kept only on a rejection.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — Not found
- **409**`NOT_PENDING` — Not waiting for a decision: already approved, rejected or withdrawn.
- **422**`REASON_REQUIRED` — A reason is required for anything but an approval. The agent is shown it as written.

#### `POST /cash-requests/{id}/decide`

[Supervisor API] Answer a request for cash (SUP-M04)

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `outcome` | Yes | One of`APPROVED`,`REJECTED` |  |
| `amount` | No | Number; more than 0, at most 9,999,999 |  |
| `reason` | No | Text; 3–1000 characters |  |
| `remarks` | No | Text; up to 1000 characters |  |

**Check before saving:**

- Approving:`amount` may be left out (the amount asked); if sent, at most the amount asked (`cash_requests.amount`), else`MORE_THAN_ASKED`.
- `reason` is required when`outcome` is`REJECTED`.`remarks` is kept only on a rejection.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — Not found
- **409**`NOT_PENDING` — Not waiting for a decision: already approved, rejected or withdrawn.
- **422**`REASON_REQUIRED` — A reason is required for anything but an approval. The agent is shown it as written.
- **422**`MORE_THAN_ASKED` —`amount` /`MORE_THAN_ASKED`: an approval cannot send more than was asked for (`cash_requests.amount`).

#### `POST /expense-categories/requests/{id}/decide`

[Supervisor API] Decide a new expense category an agent asked for (SUP-M04)

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `outcome` | Yes | One of`APPROVED`,`REJECTED` |  |
| `reason` | No | Text; 3–1000 characters |  |

**Check before saving:**

- `reason` is required when`outcome` is`REJECTED`.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — Not found
- **409**`NOT_PENDING` — Not waiting for a decision: already approved, rejected or withdrawn.
- **422**`REASON_REQUIRED` — A reason is required for anything but an approval. The agent is shown it as written.

### Day close

#### `POST /centers/{centerId}/day-close`

[Agent API] Close the day

No body.

**Check before saving:**

- Online only, and only when the outbox is empty. Call`GET /centers/{centerId}/day-close` first:`canClose` and`blockedReason` say whether it can close.
- Refused before the centre's lock time (`centers.eod_lock_time`) and while any draft at the centre is open.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — Not found
- **409**`ALREADY_CLOSED` — Someone already closed this center today.
- **409**`BEFORE_LOCK_TIME` — The center’s lock time has not arrived.
- **409**`OPEN_DRAFTS` — Drafts are still waiting to be submitted or discarded.

### Transfers

#### `PUT /transfers/{id}`

[Agent API] Raise a stock transfer

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `centerId` | Yes | UUID | One of the agent’s centers, else`403`. |
| `items` | Yes | List of entries; 1–50 of them | Each item at most once. |
| `items[].itemId` | Yes | UUID |  |
| `items[].quantity` | Yes | Number; more than 0, at most 999,999.999; at most 3 decimal places | How much to send, in the item’s unit. Not more than the center holds. |
| `estimatedExpense` | No | Number; 0 to 9,999,999 | What the agent expects the trip to cost. |
| `note` | No | Text; up to 255 characters |  |

**Check before saving:**

- `items`: 1–50, each item at most once,`quantity` greater than 0.
- Each quantity at most the free stock:`stock.qty` for that item minus what other transfers not yet dispatched (`REQUESTED`,`APPROVED`) already ask for. The server has the last word (`OVER_STOCK`).

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — Not found
- **409**`ALREADY_RAISED` — This id was already decided; raise a new one.
- **422**`INVALID_TRANSFER` — Every problem at once in`details`:`items.N.quantity` /`OVER_STOCK`,`items.N.itemId` /`DUPLICATE_ITEM`.

#### `POST /transfers/{id}/handover`

[Agent API] Dispatch: truck, driver, loaded weight and photos, in one call

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `centerId` | Yes | UUID |  |
| `handedOverAt` | Yes | Date-time, UTC (ISO 8601) | UTC, when the agent pressed Submit Transfer. Works offline. Dates the stock movement. |
| `vehicleNumber` | Yes | Text; 4–20 characters | The truck, typed by the agent. |
| `driverName` | Yes | Text; 1–255 characters | Typed by the agent. |
| `vehiclePhotoUrls` | Yes | List of URLs; 1–10 of them | Vehicle Details screen: photos of the truck before loading. 1–10, each a`fileUrl` from`POST /uploads` (purpose`TRANSFER_HANDOVER`). |
| `dispatchedWeight` | Yes | Number; more than 0, at most 999,999.999; at most 3 decimal places | Weighbridge screen: the loaded weight, in KG. Always required. |
| `baleCount` | No | Whole number; more than 0, at most 9,999 | Number of bales or boris. Optional: null or left out. |
| `weighbridgePhotoUrls` | No | List of URLs; 0–10 of them | Weighbridge screen: photos of the weighbridge slip. 0–10, optional. Same upload purpose. |
| `items` | No | List of entries; 1–50 of them | Null or leave out for a one-item transfer in KG: the loaded weight is the quantity. Required when the item is counted in pieces (how many pieces went), or when the transfer has more than one item. |
| `items[].itemId` | Yes | UUID |  |
| `items[].quantity` | Yes | Number; more than 0, at most 999,999.999; at most 3 decimal places | How much went on the truck, in the item’s own unit. |
| `note` | No | Text; up to 255 characters |  |
| `gps` | No | Object (fields below) | Where the truck was loaded, taken on the phone (works offline). Null or left out when there was no fix: never refused for that. |
| `gps.lat` | Yes | Number; -90 to 90 |  |
| `gps.lng` | Yes | Number; -180 to 180 |  |

**Check before saving:**

- Only an`APPROVED` transfer.
- `vehiclePhotoUrls` 1–10,`weighbridgePhotoUrls` 0–10,`dispatchedWeight` (KG) always.
- `items` may be left out only for a one-line transfer of a KG item (the weight becomes its quantity). Otherwise one entry per item on the transfer, each at most the stock in hand.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — Not found
- **409**`NOT_APPROVED` — It is still waiting for a supervisor.
- **409**`REJECTED` — It was refused, so nothing can be handed over.
- **409**`ALREADY_DISPATCHED` — It already left with different details.
- **422**`INVALID_TRANSFER` — Every problem at once in`details`:`items` /`REQUIRED` (pieces, or more than one item),`dispatchedWeight` /`OVER_STOCK` (one KG item, no`items`),`items.N.quantity` /`OVER_STOCK`,`items.N.itemId` /`NOT_IN_REQUEST`,`vehiclePhotoUrls.N` or`weighbridgePhotoUrls.N` /`PHOTO_NOT_ISSUED` or`PHOTO_NOT_UPLOADED`.

#### `POST /transfers/{id}/approve`

[Supervisor API] Approve a stock transfer: where it goes and when the truck comes

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `destinationFacilityId` | No | UUID |  |
| `vehicleArrivalTime` | No | Date-time, UTC (ISO 8601) | UTC, when the truck is expected. The agent sees it as the dispatch instruction. |
| `vehicle` | No | Object, one of the choices below | Either`transferVehicleId` (from the list), or`vehicleNumber` +`transferFee` for a hired truck not in the list ("Other hired truck"). |
| `vehicle.transferVehicleId` | Yes (choice 1) | UUID | A truck from the Transfer Vehicles list. |
| `vehicle.transferFee` | No (choice 1) | Number; 0 to 9,999,999; at most 2 decimal places | Required for a hired truck from the list; ignored (0) for a company truck. |
| `vehicle.vehicleNumber` | Yes (choice 2) | Text; 4–20 characters | As on the plate. Stored in capitals. |
| `vehicle.transporterName` | No (choice 2) | Text; up to 255 characters |  |
| `vehicle.transferFee` | Yes (choice 2) | Number; 0 to 9,999,999; at most 2 decimal places | Required: a typed truck is always hired. |
| `note` | No | Text; up to 255 characters | For the agent who loads it ("Note" on Select Destination). Saved on the transfer and shown to the agent; null or left out for none. |

**Check before saving:**

- A stock transfer needs`destinationFacilityId` (not this centre) and`vehicle`. A sale takes neither.
- `vehicle` is either`{ transferVehicleId }` (a truck from`transfer_vehicles`; a hired one also needs`transferFee`) or`{ vehicleNumber, transporterName, transferFee }` for a hired truck typed in.
- Each item still has to fit the free stock (`OVER_STOCK`).

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — Not found
- **409**`NOT_PENDING` — Already decided, by you or someone else. From the outbox, treat it as done.
- **422**`DESTINATION_REQUIRED` —`destinationFacilityId` /`REQUIRED`: say where it is going.
- **422**`SAME_CENTER` —`destinationFacilityId` /`SAME_CENTER`: that is the center it leaves from.
- **422**`VEHICLE_REQUIRED` —`vehicle` /`REQUIRED`: arrange the truck that will take it.
- **422**`FEE_REQUIRED` —`vehicle.transferFee` /`FEE_REQUIRED`: a hired truck from the list needs its fee.
- **422**`VEHICLE_INACTIVE` —`vehicle.transferVehicleId`: that truck is switched off (or`VEHICLE_NOT_FOUND`). Refresh the list.
- **422**`OVER_STOCK` —`items.N.quantity` /`OVER_STOCK`: other open transfers already claim that stock. Show the message.

#### `POST /transfers/{id}/reject`

[Supervisor API] Refuse a stock transfer, with a reason

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `reason` | Yes | Text; 3–1000 characters | Shown to the agent as it is. |
| `remarks` | No | Text; up to 1000 characters |  |

**Check before saving:**

- `reason` is required;`remarks` is optional.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — Not found
- **409**`NOT_PENDING` — Already decided, by you or someone else. From the outbox, treat it as done.

### Notifications

#### `POST /notifications/{id}/read`

[Common API] Mark one as read

No body.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — Not found

#### `POST /notifications/read-all`

[Common API] Mark everything as read

No body.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.

#### `POST /devices`

[Common API] Register this handset for push

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `token` | Yes | Text; 10–255 characters | The Firebase token for this handset. Send it again whenever it changes. |
| `deviceId` | No | Text; up to 255 characters |  |
| `platform` | Yes | One of`ANDROID`,`IOS` |  |
| `deviceModel` | No | Text; up to 120 characters |  |
| `deviceBrand` | No | Text; up to 80 characters |  |
| `osVersion` | No | Text; up to 60 characters |  |

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.

#### `POST /devices/test-push`

[Common API] Send a test notification to your own phones

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `token` | No | Text; 10–255 characters |  |

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` —`token` is not a phone registered to you.

#### `DELETE /devices/{token}`

[Common API] Stop pushing to this handset

No body.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.

### Tasks

#### `PUT /tasks/{id}`

[Supervisor API] Give an agent something to do (SUP-M05)

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `assignedToId` | Yes | UUID | The agent. Must work at the center given. |
| `centerId` | Yes | UUID |  |
| `title` | Yes | Text; 3–255 characters |  |
| `description` | No | Text; up to 2000 characters |  |
| `priority` | No | One of`HIGH`,`NORMAL`,`LOW`; left out:`"NORMAL"` |  |
| `dueDate` | No | Date-time, UTC (ISO 8601) |  |

**Check before saving:**

- The assignee must work at that centre (`center_people` for the same`center_id`), else`NOT_AT_CENTER`.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **403**`FORBIDDEN` — That center is not one you hold.
- **404**`NOT_FOUND` — That id is a task somebody else assigned.
- **422**`NOT_AT_CENTER` — That person does not work at this center.

#### `POST /tasks/{id}/complete`

[Agent API] Mark a task done

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `note` | No | Text; up to 255 characters |  |
| `photoUrls` | No | List of URLs; up to 5 |  |

**Check before saving:**

- Up to 5 photos. A task the supervisor cancelled is refused (`CANCELLED`): drop the write and show the cancellation.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — Not found
- **409**`CANCELLED` — The supervisor called this task off.
- **422**`INVALID_TASK` —`photoUrls.N` /`PHOTO_NOT_UPLOADED` — a photo never finished uploading.

#### `POST /tasks/{id}/cancel`

[Supervisor API] Call a task off (SUP-M05)

No body.

**Check before saving:**

- Only a`PENDING` task.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — Not found
- **409**`NOT_PENDING` — Already completed or already called off.

### Requests

#### `PUT /requests/{id}`

[Agent API] Ask the supervisor for something

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `centerId` | Yes | UUID |  |
| `body` | Yes | Text; 3–2000 characters |  |
| `priority` | No | One of`HIGH`,`NORMAL`,`LOW`; left out:`"NORMAL"` |  |
| `followUpAt` | Yes | Date-time, UTC (ISO 8601) | Required: "Next Follow-up Date & Time" on Raise Request, as UTC (shown in IST). The app stops a time already past; the server does not, since a request queued offline may arrive after it. |
| `photoUrls` | No | List of URLs; up to 5 |  |

**Check before saving:**

- `followUpAt` is required. Up to 5 photos.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — Not found
- **422**`INVALID_REQUEST` —`photoUrls.N` /`PHOTO_NOT_UPLOADED` — a photo never finished uploading.

#### `POST /requests/{id}/answer`

[Supervisor API] Answer what an agent asked for (SUP-M06)

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `notes` | Yes | Text; 3–2000 characters | Shown to the agent as it is. Closing needs an answer. |
| `photoUrls` | No | List of URLs |  |

**Check before saving:**

- Only an open request. Proof photos must be uploaded by the person answering.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **404**`NOT_FOUND` — Not found
- **409**`ALREADY_CLOSED` — This request is already closed.
- **422**`INVALID_REQUEST` — A proof photo was not uploaded by you (`photoUrls.N`).

### D2D Vehicles

#### `PUT /vehicles/{id}`

[Supervisor API] Add a vehicle, or replace one (SUP-M10)

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `centerId` | Yes | UUID | One of your centers, else`403`. |
| `plateNumber` | Yes | Text; must match`^[A-Z]{2}[-\s]?[0-9]{1,2}[-\s]?[A-Z]{1,2}[-\s]?[0-9]{4}$` | Stored uppercased, as typed. Punctuation is ignored when checking for a duplicate, so`gj05bx1234` and`GJ-05-BX-1234` cannot both exist. |
| `driverName` | No | Text; up to 100 characters |  |

**Check before saving:**

- The plate must not be on another vehicle in the company, however it is punctuated (`GJ-05-BX-1234` =`gj05bx1234`).

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **403**`SHARED_VEHICLE` — A shared-fleet vehicle (`centerId: null`). Only the admin panel changes it.
- **409**`DUPLICATE_PLATE` — Another vehicle already carries this number, however it is punctuated.`details[0].field = "plateNumber"`.

#### `PATCH /vehicles/{id}`

[Supervisor API] Edit a vehicle (SUP-M10)

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `plateNumber` | No | Text; must match`^[A-Z]{2}[-\s]?[0-9]{1,2}[-\s]?[A-Z]{1,2}[-\s]?[0-9]{4}$` | Stored uppercased, as typed. Punctuation is ignored when checking for a duplicate, so`gj05bx1234` and`GJ-05-BX-1234` cannot both exist. |
| `driverName` | No | Text; up to 100 characters |  |

**Check before saving:**

- Same plate rule as adding. A shared vehicle (`center_id` null) cannot be changed from the phone.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **403**`SHARED_VEHICLE` — A shared-fleet vehicle (`centerId: null`). Only the admin panel changes it.
- **404**`NOT_FOUND` — No vehicle with that id at any of your centers.
- **409**`DUPLICATE_PLATE` — Another vehicle already carries this number, however it is punctuated.`details[0].field = "plateNumber"`.

#### `POST /vehicles/{id}/status`

[Supervisor API] Activate or deactivate a vehicle (SUP-M10)

| Field | Required | Rule | Notes |
| --- | --- | --- | --- |
| `isActive` | Yes | `true` or`false` | false: deactivate. true: reactivate. |

**Check before saving:**

- Switching off is refused while the vehicle is out on a transfer. A shared vehicle cannot be changed from the phone.

**The server may still refuse it with:**

- **403**`FORBIDDEN` — Not permitted: a center the agent is not assigned to, or an action the role lacks.
- **403**`SHARED_VEHICLE` — A shared-fleet vehicle (`centerId: null`). Only the admin panel changes it.
- **404**`NOT_FOUND` — No vehicle with that id at any of your centers.
- **422**`UNPROCESSABLE` — The vehicle is out on a transfer.

## Changelog

Every server change that touches the app, newest first. Each dated section in EERL Mobile — SQLite Schema & Queries has the full SQL for it.

| Date | Change | What the app does |
| --- | --- | --- |
| 20 Oct 2026 | Supervisor Stock screen (SUP-M03): the Figma frames show stages, bins and machines that do not exist. No API change | One screen: RM items of the active centre, totals per unit, Plastic and Non-plastic tabs, free to send. Layout and SQL in the SQLite Schema & Queries doc, entry of the same date |
| 20 Oct 2026 | Push notifications through Firebase: a push the moment a notification is made; role and center_id on every notification; POST /devices/test-push. The notifications table stays the record | Add Firebase; ask permission after login; create three Android channels; send the token on every launch and on refresh, delete it at sign-out; banner when open, open the deep link on tap; two columns on notifications, list by active role. Details below |
| 16 Oct 2026 | No API change. What to do when a queued write is refused because the record moved on while it waited: a task cancelled by the supervisor (409 CANCELLED), a draft discarded at the office (409 DRAFT_DISCARDED), a collection no longer a draft (409 ALREADY_SUBMITTED), a transfer cancelled (409 REJECTED) | Take the server's state and drop the write instead of parking it as failed; tell the agent why. SQL for each case. Details below |
| 13 Oct 2026 | The supervisor's photo: me.supervisor.photoUrl on /bootstrap and /auth/me, for the Raise Request card and Contact Supervisor | One more sync_meta key (supervisor_photo_url), no table change; show the photo, else initials. Details below |
| 12 Oct 2026 | The approval note reaches the agent: dispatch.note on transfers, dispatch_note on transfers rows, "Note: …" in the notification; a sale's note arrives the same way; an admin's change replaces it | One column on transfers (and a Scope reset for notes already given); save the note when approving; show it to the agent and on the supervisor's detail. Details below |
| 12 Oct 2026 | Requests carry a required follow-up date and time (AG-M08 "Next Follow-up Date & Time"): followUpAt on PUT /requests/{id}, follow_up_at on requests rows | One column on requests, no Scope reset; the form field and followUpAt in the body; show it to the agent and supervisor, Overdue when open past it. Details below |
| 12 Oct 2026 | Materials carry is_active: a material the admin switches off keeps arriving with 0 (and no center_items rows) instead of vanishing | One column on items, no Scope reset; offer only is_active = 1 where a material is picked, name any by id. Details below |
| 12 Oct 2026 | Ragpicker phones are stored and returned as the 10 digits, without +91 (MRF people and logins keep +91) | Nothing to build: the app may still send +91, and shows the number as it comes. Details below |
| 8 Oct 2026 (part 4) | Supervisor transfer screens (the manager's CM-M03, changed screen by screen); the truck is arranged at approval from the Transfer Vehicles list or typed in with its fee; TRANSFERS added to the supervisor's modules | New table transfer_vehicles, six transfers columns, a Scope reset; approve sends vehicle; the agent's Vehicle Details is pre-filled with the arranged truck. Details below |
| 8 Oct 2026 (part 3) | Category requests carry who asked and the decision (who, when, why rejected); slip numbers explained in full (no rule change) | Four columns on category_requests and a Scope reset; show the rejection reason to the agent and who asked to the supervisor. Details below |
| 8 Oct 2026 (part 2) | Free stock on raise and approve; approved transfers changed or cancelled from the web (cancelled = REJECTED with "Cancelled after approval:"); null accepted for every empty optional field | No migration. Cap the quantity at free stock; clear dispatch drafts of rejected transfers; on a dispatch answered 409 REJECTED, drop it and fetch the transfer. Details below |
| 8 Oct 2026 | Transfer dispatch: two screens, one call. The handover body takes`vehiclePhotoUrls`,`weighbridgePhotoUrls` and an always-required`dispatchedWeight`;`photoUrls`,`weighbridgeUsed`,`driverPhone` and`vehicleId` are gone | Five new`transfers` columns, a Scope reset, the new body. Details below |
| 8 Oct 2026 | Transfer request: design notes, no API change | One item, a quantity box,`estimatedExpense` once, "Stock in hand", no destination step |
| 6 Oct 2026 | Item pictures:`items.image_url` | One column, a Scope reset, show the picture else the colour |
| 6 Oct 2026 | Location on collection submit and transfer handover (`gps`) | Two columns on`collections` and`transfers`, send`gps` or`null` |
| 5 Oct 2026 | Reference numbers from the server (`number` columns) | Store`number`; show "Not synced yet" while null |

### 20 Oct 2026 — Push notifications (Firebase)

A notification can now reach the phone as a push the moment it is made, not only at the next sync. Nothing else about notifications changes: they still arrive in`/bootstrap` as the`notifications` table, which stays the record. A push only says "something new, sync now", so a lost push loses nothing. Every notification also carries the**role** it is for and the**centre** it is about. Until the server switches push on,`POST /devices` answers`pushWorking: false` and no push comes: build and ship this anyway, it starts working without another app release.

**1. Firebase in the app.**

- Packages:`firebase_core`,`firebase_messaging`,`flutter_local_notifications`.
- `google-services.json`: send us the Android package name (`applicationId`) and we send the file back. It is our development Firebase project for now. Before go-live the client's own project replaces it: the app is rebuilt with their file, nothing else in the code changes, and each phone registers its new token at its next launch.
- iOS: later (needs an Apple developer account and an APNs key). Nothing to do now.

**2. Permission.** Ask once, after the first successful login, not on the login screen:`FirebaseMessaging.instance.requestPermission()` (Android 13+ needs it at runtime). Refused: everything still works through sync; show "Notifications are off" on the notification screen with a button to the phone's settings. Do not ask again.

**3. Android channels, created at start-up.** Every push names one of these three. The user can mute each one on its own in the phone's settings.

| Channel id | Name to show | Importance | Used for |
| --- | --- | --- | --- |
| `login_codes` | Login codes | High | A login code someone asked for (supervisor) |
| `tasks_requests` | Tasks and requests | High | Task assigned, called off or done; request raised or answered; the test push |
| `approvals_money` | Approvals and money | Default | Collections, expenses, cash requests, transfers decided |

**4. The token.**

- **After login and on every app launch while signed in**:`getToken()`, then`POST /devices` with it, the same call and body as today (`token`,`platform`,`deviceId`,`deviceModel`,`deviceBrand`,`osVersion`). Sending the same token again is how the server knows the phone is still in use: a phone not registered for 60 days stops getting pushes.
- `onTokenRefresh`:`POST /devices` with the new token.
- No network: try again at the next launch. It is not a record, so no outbox item.
- **Sign-out**, while still signed in:`DELETE /devices/{token}`, then`FirebaseMessaging.instance.deleteToken()`, then clear the session. No network at sign-out: keep the token in shared preferences (signing out clears the tables) and call`deleteToken()` at the next launch that has a network. Firebase then refuses that token and the server forgets it at its next push.
- One phone, two people: the token belongs to whoever registered it last, so always register right after login.

**5. What a push carries.** All`data` values are strings; an empty string means none.

| Part | Content |
| --- | --- |
| `notification.title`,`notification.body` | What the phone shows. A login code reads "Login code requested" / "For Amit Sharma. Open the app to see the code.": the code itself is only in the list, inside the signed-in app |
| `data.notificationId` | `notifications.id`; empty for a test push |
| `data.type` | As`notifications.type`, or`TEST_PUSH` |
| `data.deepLink` | As`deep_link`; empty when there is nothing to open |
| `data.role` | `AGENT`,`SUPERVISOR`; empty when none |
| `data.centerId` | The centre it is about; empty when none |

Firebase keeps a push for a phone that is offline for 5 minutes (login codes: the code's own life), 1 day (tasks and requests) or 3 days (the rest). After that only the sync brings it.

**6. When it arrives.**

| The app is | The phone | The app does |
| --- | --- | --- |
| Open | Shows nothing by itself | `onMessage`: show an in-app banner with the title and body, and start a`/bootstrap` (at most one every 10 seconds). A tap on the banner counts as a tap on the notification |
| In the background or closed | Shows it on its channel | Nothing on arrival. Never show it again from the background handler (it would appear twice), and do not sync from there |
| Tapped | Opens the app | `onMessageOpenedApp` (was in the background) or`getInitialMessage()` (was closed): sync, mark it read, open`data.deepLink` (empty: the notification list). When`data.role` is not the active role, offer to switch first |

**7. Never twice.** The list is drawn only from the`notifications` table; a push is never inserted as a row. The push is the alert, the`/bootstrap` row is the entry, with the same id. A notification that came only by sync (push lost, phone off too long) simply appears in the list. A`TEST_PUSH` has no row: show it, store nothing.

**8. Several roles, one list.** Every notification of every role a person holds comes to each of their phones; the server keeps no active role. Show the active role's first, the others below marked "For your Supervisor role" (the role's name), and an unread count beside each other role on the role switcher. Nobody gets a notification about their own action.

**9. The SQL.** Once, the two columns (no Scope reset; older rows stay null and show under every role):

```
ALTER TABLE notifications ADD COLUMN role TEXT;                          -- AGENT | SUPERVISOR; null on rows before 20 Oct 2026
ALTER TABLE notifications ADD COLUMN center_id TEXT REFERENCES centers (id); -- the centre it is about; null when none
CREATE INDEX ix_notifications_role ON notifications (role, created_at);
```

Every`/bootstrap`, the whole`notifications` upsert:

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

The list, the active role's first (`:active_role` is`sync_meta.active_role`;`for_role_name` labels the others):

```
SELECT n.*, r.role_name AS for_role_name,
  CASE WHEN n.role IS NULL OR n.role = :active_role THEN 0 ELSE 1 END AS other_role
FROM notifications n
LEFT JOIN my_roles r ON r.role_key = n.role
ORDER BY other_role, n.created_at DESC;
```

The bell, and the count per other role on the role switcher:

```
SELECT COUNT(*) FROM notifications
WHERE read_at IS NULL AND (role IS NULL OR role = :active_role);

SELECT role, COUNT(*) AS unread FROM notifications
WHERE read_at IS NULL AND role IS NOT NULL AND role <> :active_role
GROUP BY role;
```

A tapped push, after the sync (`:notification_id` is`data.notificationId`), plus`POST /notifications/{id}/read` in the outbox as today. No row changed means the sync has not landed yet: open`data.deepLink` anyway and mark it read after the next sync.

```
UPDATE notifications SET read_at = :now, sync_state = 'pending'
WHERE id = :notification_id AND read_at IS NULL;
```

**10. Checking it works.**`POST /devices/test-push` with`{}` sends "Test notification" to every phone the person is signed in on, and answers per phone:`platform`,`deviceModel`,`tokenEnd` (last six characters),`sent`,`error`. Send`{"token": "…"}` for one phone. Worth a "Send a test notification" button in Settings or a debug menu.`error: messaging/registration-token-not-registered` means Firebase no longer knows that token: the server has removed it, and the next launch registers a fresh one.

### 16 Oct 2026 — When the record moved on while your write was waiting

No API change; this is how the app should read four answers it can already get.

**Why it happens.** The agent acts offline (completes a task, saves a draft, dispatches a transfer), so the row is`pending` and its write waits in the outbox. Meanwhile someone else closes that record: the supervisor cancels the task, the office discards the draft, the admin cancels the transfer. The next`/bootstrap` brings that change, but**Step 4 never writes over a pending row**, so the phone skips it, and the cursor moves on:**that change will not be sent again**. When the queued write then reaches the server, it is refused with a`409` that says what happened.

The general rule ("any other 4xx: park it as failed") is wrong for these four: the write can never succeed, and the row would stay wrong for good. Instead,**take the server's state, drop the write, and tell the agent**.

| Answer | To | What happened | What the app does |
| --- | --- | --- | --- |
| `409 CANCELLED` | `POST /tasks/{id}/complete` | The supervisor called the task off first | Drop the item and its photos; the task becomes**Cancelled** (synced). Tell the agent: "This task was called off by*assigned_by_name*. Your update wasn't needed." |
| `409 DRAFT_DISCARDED` | `PUT /collections/{id}` (draft save) | The office discarded the draft in the panel | Drop the queued draft saves. If a**submit** for it is still queued, keep it and the draft: the submit goes through (it undoes the discard). Otherwise delete the draft, its lines and photos. Tell the agent: "This draft was discarded at the office." |
| `409 ALREADY_SUBMITTED` | `PUT /collections/{id}` (draft save) or`DELETE /collections/{id}` (discard) | The collection is no longer a draft: it was submitted (and may since be approved or rejected) | Drop that item, then`GET /collections/{id}` and write the answer onto the row as synced, as you write a submit's answer. A rejected one can then be corrected and resubmitted as usual |
| `409 REJECTED` | `POST /transfers/{id}/handover` | The transfer was refused, or cancelled after approval, before the dispatch arrived | Drop the dispatch and its photos; the transfer goes back to**Rejected** with the handover fields cleared; then`GET /transfers/{id}` for the reason |

Unchanged, for completeness:`409 NOT_PENDING` and`409 ALREADY_CLOSED` (someone already decided, answered or cancelled it) still mean**done**; the next`/bootstrap` shows the result.

**Still real refusals** (keep the "failed" handling and show the message):`409 ALREADY_SUBMITTED` on a**submit** (the same collection submitted earlier with different content),`ALREADY_LOGGED`,`ALREADY_DISPATCHED`,`ALREADY_RAISED`,`DUPLICATE_REQUEST`, and every`422`.

**The SQL, case by case** (`:seq` is the outbox item that was answered,`:id` its record):

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

**Items already parked as failed** with one of these answers (for example a task completion that failed before this entry): apply the same handling once when the app updates, by reading`outbox` rows with`status = 'failed'` and`last_error` starting with`409 CANCELLED`,`409 DRAFT_DISCARDED`,`409 ALREADY_SUBMITTED` (draft save or discard only) or`409 REJECTED` (handover only).

### 13 Oct 2026 — The supervisor's photo (`me.supervisor.photoUrl`)

The supervisor block now carries their photo, for the "TO :" card on Raise Request (AG-M08) and for Contact Supervisor. It is the photo the supervisor set on their own profile. Additive: nothing that reads the old shape breaks.

| Where | Change |
| --- | --- |
| `GET /bootstrap`,`me.supervisor` | New`photoUrl`: a URL, or null when they have no photo.`name` and`phone` unchanged. |
| `GET /auth/me`,`supervisor` | The same new`photoUrl`. |
| `supervisor` itself | Still null when no reporting manager is set. It is the reporting manager whatever roles the user holds, so an agent who is also a supervisor sees their own manager. |

`me` is sent whole on every`/bootstrap`, so a new photo, or a new reporting manager, arrives on the next sync. No table changes and no Scope reset: it is one more`sync_meta` key.

**1. Every`/bootstrap`: store it.** The whole`sync_meta` write in Step 2, with the one new key:

```
INSERT OR REPLACE INTO sync_meta (key, value) VALUES
  ('user_id', :user_id), ('user_name', :user_name), ('user_phone', :user_phone),
  ('user_photo_url', :user_photo_url),
  ('supervisor_name', :supervisor_name), ('supervisor_phone', :supervisor_phone),  -- null when no supervisor
  ('supervisor_photo_url', :supervisor_photo_url),  -- new: null when no supervisor or no photo
  ('session_expires_at', :expires_at);
```

**2. Reading it.** The whole query, with the new key:

```
SELECT key, value FROM sync_meta
WHERE key IN ('user_name', 'user_phone', 'user_photo_url',
              'supervisor_name', 'supervisor_phone', 'supervisor_photo_url', 'session_expires_at');
```

**3. Showing it.**

- **Raise Request (AG-M08), the "TO :" card:** the photo, then "TO : {supervisor_name}". Use the name as it comes; do not add "(Supervisor)" from the role, since for someone who is also a supervisor it is their manager.
- **Contact Supervisor:** the same photo beside the name and phone.
- **No photo, or offline before it was ever loaded:** a circle with their initials. Cache the image like other photos so it shows offline after the first load.
- **`supervisor_name`is null** (no reporting manager): "No supervisor set: ask your admin to set one." A request raised then still saves, but goes to nobody until an admin answers it from the panel.

### 12 Oct 2026 — Transfers carry the note for the agent (`dispatch_note`)

The note the supervisor types when approving ("Note" on Select Destination) now reaches the agent. Before, the server kept it only in its audit log. A sale's note from the sales team now arrives the same way.

| Where | Change |
| --- | --- |
| `POST /transfers/{id}/approve` (supervisor) | Body unchanged:`note`, up to 255 characters, null or left out for none. It is now saved on the transfer. |
| `GET /transfers`,`GET /transfers/{id}` | New`dispatch.note`: string, or null when there is none. |
| `GET /bootstrap`,`transfers` rows | New`dispatch_note`: string or null. On transfers and sales alike. |
| The agent's "Transfer approved" notification | Ends with "Note: …" when there is a note. |
| Admin changes an approved transfer on the web | A new note replaces the old one, and the agent gets "Transfer changed" ending "note: …". It arrives in the next`/bootstrap`; nothing for the app to do. |
| A sale | The sales team's note is the transfer's`dispatch_note`; a change to the sale replaces it. |

Transfers approved before 12 Oct 2026 get their note back from the server's log.

**1. Once: the column.** To get the notes of transfers already on the phone, run a**Scope reset** once after the upgrade, after the outbox has emptied: a transfer is only sent again when it changes.

```
ALTER TABLE transfers ADD COLUMN dispatch_note TEXT;
```

**2. Every`/bootstrap`: store it.** The whole`transfers` upsert, with the new column:

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

**3. Supervisor approves: save the note locally too.** The whole approve transaction, with the one new line.`:note` is the "Note" box on Select Destination, trimmed; NULL when empty. The design caps it at 150 characters; the server takes up to 255.

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

The body (`:body_json`):

```
{
  "destinationFacilityId": "ed6cf8f9…",
  "vehicleArrivalTime": "2026-10-23T04:30:00.000Z",
  "vehicle": { "transferVehicleId": "<company truck id>" },
  "note": "Load the dry bales first."
}
```

**4. Showing it.** Agent, approved transfer (AG-M06 "Scheduled"), the whole query with the new column:

```
SELECT number, destination_name, truck_expected_at, planned_vehicle_number,
       dispatch_note                                    -- new
FROM transfers WHERE id = :id;
```

Supervisor, approved and dispatched detail (SUP-M11), unchanged (`t.*` now includes`dispatch_note`):

```
SELECT t.*, ce.name AS center_name FROM transfers t JOIN centers ce ON ce.id = t.center_id
WHERE t.id = :id;
```

- **Agent:** under the truck and time, "Note from supervisor: …" (for a sale, "Note: …"). Hidden when`dispatch_note` is NULL.
- **Supervisor:** "Note for the agent: …" under "Approved by". Hidden when NULL.
- **Never on a pending or rejected transfer:** it is set only by approving or by a sale.
- **Figma:** neither screen has a place for it yet; the designer is adding one.

### 12 Oct 2026 — Requests carry a required follow-up date and time

Raise Request (AG-M08) has a required**Next Follow-up Date & Time**.`PUT /requests/{id}` now requires`followUpAt` (UTC); a body without it is refused with`400 VALIDATION_ERROR`,`details[0].field = "followUpAt"`. Every request comes back with`followUpAt`, and every`requests` row in`/bootstrap` with`follow_up_at`. Requests raised before 12 Oct 2026 have it null. The supervisor's "New request" notification ends with "Follow up by 16 Aug, 3:00 pm" (IST).

**1. Once: the column.** No Scope reset: older requests have no follow-up time on the server either.

```
ALTER TABLE requests ADD COLUMN follow_up_at TEXT;   -- UTC, e.g. 2026-08-16T09:30:00.000Z
```

**2. Every`/bootstrap`: store it.** The whole`requests` upsert, with the new column:

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

**3. Raise Request: the form and the write.**

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

The body (`:body_json`):

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

**4. Showing it.** Agent, the requests list (unchanged query; show`follow_up_at` on each card):

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

Show "Follow up by 16 Aug, 3:00 PM" on the card and on Resolve Request, and an "Overdue" chip when`overdue = 1`. A null`follow_up_at` (older requests) shows nothing. Answering is unchanged. The supervisor screens (SUP-M06) do not show this yet in Figma; the designer is adding it.

### 12 Oct 2026 — Materials carry`is_active`

Every`items` row in`/bootstrap` now has`is_active`. A material the admin switches off keeps arriving, with`0`, so old collections, transfers and stock keep its name. It has no`center_items` rows, so neither picker offers it; switching it back on brings back its rows with the place and tick it had. No endpoint changes.

**1. Once: the column.** No Scope reset: the default fills the rows already on the phone.

```
ALTER TABLE items ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1;
```

**2. Every`/bootstrap`: store it.** The`items` insert in Step 3 takes the new column:

```
DELETE FROM items;
INSERT INTO items (id, name, category_name, material_type, colour, image_url,
                   hsn_code, unit_code, unit_name, is_active)
VALUES (…);                                                -- per row
```

**3. Collection form: offer only active materials.** The whole query, with the one new line:

```
SELECT i.id, i.name, i.unit_code, i.unit_name, i.colour, i.image_url, i.material_type,
       CASE WHEN ch.show_price = 1 THEN ci.rate END AS rate
FROM center_items ci
JOIN items i            ON i.id = ci.item_id
JOIN center_channels ch ON ch.center_id = ci.center_id AND ch.channel = ci.channel
WHERE ci.center_id = :center AND ci.channel = :channel AND ci.is_selected = 1
  AND i.is_active = 1                   -- new
ORDER BY ci.sort_order;
```

**4. Configure Material List: list and save only active materials.** A switched-off material is not shown, so it is not in the saved list either:

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

**5. Naming a material on old records: no change.** Collection history and detail, transfers and stock look a material up by`item_id`; those queries stay as they are and must not filter on`is_active`.

**6. Stock of a switched-off material: no query change.** Stock in hand and Free to send join`stock` to`items`. Until now a switched-off material had no`items` row, so its stock dropped out of both lists. It now shows, and can still be sent on a transfer: intended, since material on hand still has to leave.

**Order of work.** Add the column (step 1) before, or in the same release as, anything else: if the app inserts`items` rows with every key it receives, the insert fails until the column exists. Steps 2 to 4 can follow; until they ship, the pickers still cannot show a switched-off material, because it has no`center_items` rows.

### 12 Oct 2026 — Ragpicker phones are the 10 digits, without +91

A ragpicker's phone is stored and returned as the 10 digits the person gave (`9700000009`), never`+919700000009`. MRF people's and users' phones keep`+91`. No table, column or query changes.

- **Sending:**`PUT` and`PATCH /ragpickers/{id}` still accept`9700000009` or`+919700000009`; the server drops the +91 and answers with the 10 digits. Keep the row the answer returns.
- **Numbers already on the phone:** older numbers are cleaned once on the server after the release, and arrive with the next`/bootstrap` as a`ragpickers``replace`. The usual Step 3 refreshes them:

```
DELETE FROM ragpickers WHERE sync_state = 'synced';
INSERT OR IGNORE INTO ragpickers (id, center_id, name, phone, id_number, photo_url, is_active)
VALUES (:id, :center_id, :name, :phone, :id_number, :photo_url, :is_active);          -- per row
```

- **Showing it:** show the number as stored. If a screen adds a prefix for display, add it only when the stored number has none.

### 8 Oct 2026 (part 4) — Supervisor transfer screens; the truck is arranged at approval

The supervisor now approves and rejects transfers in the app, and approving a stock transfer**requires the truck**: one from the company's Transfer Vehicles list (a hired one with its fee; a company truck is free), or a hired truck typed in with its fee. The agent sees the arranged truck, never the fee, and a different truck at dispatch is accepted and flagged.

1. **Once:** create`transfer_vehicles`, add six columns to`transfers`, then one Scope reset after the server release:

```
CREATE TABLE transfer_vehicles (
  id TEXT PRIMARY KEY, number TEXT NOT NULL, ownership TEXT NOT NULL,
  transporter_name TEXT, vehicle_type TEXT, capacity_kg REAL
);
ALTER TABLE transfers ADD COLUMN transfer_vehicle_id TEXT;
ALTER TABLE transfers ADD COLUMN planned_vehicle_number TEXT;
ALTER TABLE transfers ADD COLUMN planned_vehicle_ownership TEXT;
ALTER TABLE transfers ADD COLUMN transporter_name TEXT;
ALTER TABLE transfers ADD COLUMN transfer_fee REAL;
ALTER TABLE transfers ADD COLUMN vehicle_differs INTEGER NOT NULL DEFAULT 0;
```

1. **Every`/bootstrap`:**`transfer_vehicles` arrives as`replace` (supervisors only); the transfer upsert stores the six new columns.
2. **Supervisor:** build the screens exactly as in*Supervisor transfer screens* above. Approve sends`vehicle` (`transferVehicleId` [+`transferFee` for a hired one], or`vehicleNumber` +`transporterName` +`transferFee`); undo the local approval on`422`.
3. **Agent:** show the arranged truck on the approved card; open Vehicle Details with`planned_vehicle_number` filled in.

The exact SQL (table, upsert, approve and reject transactions, the three bodies, the answers and the undo, the agent's queries) is under*8 Oct 2026 (part 4)* in EERL Mobile — SQLite Schema & Queries.

### 8 Oct 2026 (part 3) — Category requests: who asked and the decision; slip numbers explained

A rejected category request used to reach the agent with no reason, and the supervisor's list could not name who asked. The "Reason/Description" box is unchanged: it is`reason`.

1. **Once:** add four columns, then one Scope reset after the server release:

```
ALTER TABLE category_requests ADD COLUMN requested_by_name TEXT;
ALTER TABLE category_requests ADD COLUMN decided_by_name TEXT;
ALTER TABLE category_requests ADD COLUMN decided_at TEXT;
ALTER TABLE category_requests ADD COLUMN decision_reason TEXT;
```

1. **Every`/bootstrap`:** store`requested_by_name`,`decided_by_name`,`decided_at` and`decision_reason` with the rest of the row.
2. **Asking:** the body is unchanged. The answer adds`requestedBy` and`decision` (`by`,`at`,`reason`;`null` while pending).
3. **Showing:** the agent's rejected card shows`decision_reason`, by whom and when; the supervisor's card shows`requested_by_name` and`reason`.

**Slip numbers:** no change to the rule. The new*Slip numbers* section above (under*Ids and reference numbers*) explains every part, when the number is made, reinstalls and the server's checks.

The exact SQL is under*8 Oct 2026 (part 3)* in EERL Mobile — SQLite Schema & Queries.

### 8 Oct 2026 (part 2) — Free stock, transfers changed or cancelled after approval, null for empty fields

No table, column or migration changes, and the current app keeps working. Four behaviours change once the server is deployed:

| Change | What the phone sees | What the app does |
| --- | --- | --- |
| Empty optional fields | `null` is accepted wherever a key is optional. Before, it got`400 VALIDATION_ERROR` (e.g.`note` /`INVALID_TYPE` on the dispatch). | Nothing: send`null` or leave the key out |
| Free stock | Raising is refused with`OVER_STOCK` when other open transfers already claim the stock. A supervisor's approve can answer`422 OVER_STOCK` too. | Cap the quantity at`qty_free`; show the error's message, which gives the figures |
| Changed after approval | `destination_id`,`destination_name`,`truck_expected_at` change on the next sync; notification`TRANSFER_APPROVED` "Transfer changed" | Nothing: Step 4's upsert writes them |
| Cancelled after approval | `status = 'REJECTED'`,`rejection_reason` = "Cancelled after approval: <reason>"; notification`TRANSFER_REJECTED` "Transfer cancelled". A queued dispatch gets`409 REJECTED`. | Clear its dispatch draft; drop the queued dispatch and fetch the transfer |

The optional keys that now take`null`: on the dispatch`baleCount`,`weighbridgePhotoUrls`,`items`,`note`,`gps`; on raising`estimatedExpense`,`note`;`note` on a supervisor's approve, on an expense and on completing a task.

Steps for the app:

1. **Free stock.** Show and cap at`qty_free` = stock in hand less what the center's open transfers (`REQUESTED` or`APPROVED`) ask for in`transfer_items`.
2. **After every`/bootstrap`:** delete the`dispatch_draft:<id>` keys in`sync_meta` and the not-yet-queued`vehicle` /`weighbridge` photos of transfers that are now`REJECTED`. Close Vehicle Details or Weighbridge if it is open for one.
3. **A dispatch answered`409 REJECTED`:** do not park it as failed. Delete the outbox item and its photos, set the transfer back to`REJECTED` with its handover fields cleared and`sync_state = 'synced'`, then call`GET /transfers/{id}` for the reason. The`/bootstrap` that brought the rejection while the dispatch was queued skipped the row, and will not send it again.
4. **Optional:** label a rejected card "Cancelled" when`rejection_reason` starts with "Cancelled after approval:".

The exact SQL for each step is under*8 Oct 2026 (part 2)* in EERL Mobile — SQLite Schema & Queries.

### 8 Oct 2026 — Transfer dispatch: vehicle and weighbridge photos, loaded weight

The agent fills**Vehicle Details** (vehicle number, driver, vehicle photos) and then**Weighbridge** (loaded weight, bales, weighbridge photos).*Start Loading* only moves between the screens;**Submit Transfer** queues one`POST /transfers/{id}/handover` with both. Ship the app update with this server release: the old body is refused from it.

1. **Once, on upgrade:** add the columns, then do one Scope reset after the server release is live.

```
ALTER TABLE transfers ADD COLUMN driver_name TEXT;
ALTER TABLE transfers ADD COLUMN dispatched_weight REAL;
ALTER TABLE transfers ADD COLUMN bale_count INTEGER;
ALTER TABLE transfers ADD COLUMN vehicle_photo_urls TEXT NOT NULL DEFAULT '[]';
ALTER TABLE transfers ADD COLUMN weighbridge_photo_urls TEXT NOT NULL DEFAULT '[]';
-- photo_urls is no longer sent: stop reading or writing it (leave the column).
```

1. **Vehicle Details:** no call. Keep the typed values in`sync_meta` (`dispatch_draft:<id>`) and each photo in`photos` with`owner_table = 'transfers'`,`field = 'vehicle'`, purpose`TRANSFER_HANDOVER`.
2. **Weighbridge:** each photo in`photos` with`field = 'weighbridge'`.
3. **Submit Transfer:** one transaction sets`status = 'DISPATCHED'`,`handed_over_at`,`vehicle_plate`,`driver_name`,`dispatched_weight`,`bale_count`, each line's`dispatched_qty`, queues the outbox item and ties every photo of both screens to it in`outbox_photos`.
4. **Every`/bootstrap`:** store the five new columns in Step 4's upsert;`photo_urls` is no longer in the rows.

The body, once photos are uploaded:

```
{
  "centerId": "9f1c…",
  "handedOverAt": "2026-10-08T06:30:00.000Z",
  "vehicleNumber": "GJ-05-AB-1234",
  "driverName": "Pankaj Tripathi",
  "vehiclePhotoUrls": ["https://…/transfers/….jpg", "https://…/transfers/….jpg"],
  "dispatchedWeight": 900,
  "baleCount": 12,
  "weighbridgePhotoUrls": ["https://…/transfers/….jpg"],
  "gps": { "lat": 21.1702, "lng": 72.8311 }
}
```

| Key | Rule |
| --- | --- |
| `vehicleNumber`,`driverName` | Required, typed. No driver phone |
| `vehiclePhotoUrls` | 1–10 |
| `dispatchedWeight` | Required, KG, more than 0 |
| `baleCount` | Optional, 1–9999; leave out when empty |
| `weighbridgePhotoUrls` | Optional, 0–10 |
| `items` | Leave out for a one-item transfer in KG (the weight is the quantity). Send`[{ "itemId", "quantity" }]` with the pieces for a PCS item |

The screens: "Weighbridge Slip" becomes**Weighbridge photos** (several, optional); the KG/PCS toggle goes (**Loaded weight (KG)**, plus**Pieces loaded** for a PCS item); the driver is typed; after Submit show**Dispatched**, not "Transfer Completed". The SQL for every step, the upsert and the error answers are under*8 Oct 2026* in EERL Mobile — SQLite Schema & Queries.

## 21 Oct 2026 — Requests: proof photos when the supervisor answers (Resolve Request Proof)

**Why.** The Resolve Request screen (SUP-M06) lets the supervisor attach photos as proof that the thing was fixed ("Weight scale calibrated…" with a photo of the scale). Until now the answer call took only the text, so there was nowhere to send them. It now takes them, and the agent sees them under the answer.

**What the server sends.** Each`requests` row in`/bootstrap` gains`answer_photo_urls`: a JSON array of URLs,`'[]'` when there are none. It is a separate list from`photo_urls`:

| Column | Whose photos | Shown on |
| --- | --- | --- |
| `photo_urls` | The agent's, attached when raising the request | "Attachment from Collection Agent" |
| `answer_photo_urls` (new) | The supervisor's (or an admin's from the panel), attached with the answer | "Resolve Request Proof" on an answered request, for the supervisor and the agent |

**The write.** Resolved Request queues`POST /requests/{id}/answer` with`{ "notes", "photoUrls" }`, like any write with photos: each photo is uploaded first (`POST /uploads`, purpose`REQUEST`), and the answer waits in the outbox until every photo has uploaded. The SQL is in the SQLite doc's entry of the same date.

**Rules the app follows**

- Photos are optional, and there is**no limit** on how many. Keep "Capture Photo" available after each photo is added; each one has its X to remove it before sending.
- The Description stays required. The server takes 3 to 2000 characters; the screen may cap it at 150 as designed.
- Keep proof photos apart from the agent's: they are separate in the database (`photos.field = 'answer'` on the phone,`answer_photo_urls` from the server). Never show one list as the other.
- Answered offline: the request shows Closed with the local proof photos at once, and the answer goes when there is signal.
- `409 ALREADY_CLOSED`: someone (often the admin, from the panel) answered first. Drop the write and take the server's answer.
- `422 INVALID_REQUEST` naming`photoUrls.N`: that photo did not reach storage from this phone. Upload it again, then resend.
- The agent's notification is unchanged (`REQUEST_CLOSED`, the description as its text). The agent's request detail shows the proof photos under the answer.

**Older app builds** keep working:`photoUrls` is optional, and an answer without it closes the request as before.

What stays: raising a request and its photos, and everything from the earlier entries.

## 21 Oct 2026 — Rejecting with reasons and optional remarks (collections, expenses, cash requests)

**Why.** The reject screens (Reject Collection, SUP-M02; Reject Cash Request and the expense reject, SUP-M04) have the reasons ticked and a separate, optional Remarks box. Until now the reject calls took one text,`reason`, so the remarks had nowhere of their own. They now have a field:`remarks`.

**What to send.**

| Screen part | Field | Rule |
| --- | --- | --- |
| Reasons ticked (required, one or more) | `reason` | The labels joined with ", ":`"Sufficient Existing Balance, Exceeds Advance Limit"`. With Other ticked, put the words typed for Other in its place. At least 3 characters, so at least one reason must be ticked |
| Remarks (optional) | `remarks` | As typed, trimmed. Leave it out, or send`null`, when empty |

The calls:`POST /collections/{id}/reject`,`POST /expenses/{id}/decide` and`POST /cash-requests/{id}/decide` (the last two with`"outcome": "REJECTED"`). All are queued in the outbox as before; the SQL is in the SQLite doc's entry of the same date.

**What the server sends back.** Each record keeps the two apart:`rejection_reason` and`rejection_remarks` on`collections`;`decision_reason` and`decision_remarks` on`expenses`;`decision_note` and`decision_remarks` on`cash_requests`. In the answers:`review.remarks` (collection) and`decision.remarks` (expense, cash request).

**Showing it.** Wherever a rejected collection, expense or cash request shows its reason (the agent's record and the supervisor's), show the remarks below it on their own line when there are any. The agent's rejection notification ends with "Remarks: …".

**Rules the app follows**

- Confirm Rejection stays disabled until at least one reason is ticked. Remarks never block it.
- The server takes up to 1000 characters for each; the Remarks box may cap at 150 as designed.
- Approving is unchanged: no reasons, no remarks.
- Older app builds keep working:`remarks` is optional.

What stays: approving, raising, logging, and everything from the earlier entries.

## 23 Oct 2026 — Rejecting a transfer with optional remarks (SUP-M11)

**Why.** Reject Transfer (SUP-M11, Screen 6) has the reasons ticked and a separate, optional Remarks box, but`POST /transfers/{id}/reject` took one text,`reason`, and refused anything else with`400 UNRECOGNIZED_KEYS`. It now has a field for the remarks, as collections, expenses and cash requests have had since 21 Oct.

**The call.**`POST /transfers/{id}/reject` with`{ "reason", "remarks" }`, queued in the outbox as before:

- `reason` (3–1000 characters): the ticked labels joined with ", ", e.g. "No Vehicle Available, Incorrect Material / Weight Details".
- `remarks` (new, optional, up to 1000 characters): the Remarks box, trimmed. Leave it out, or send`null`, when empty. "Other" still needs Remarks.

Older builds keep working:`remarks` is optional. An outbox item that already failed with`400 UNRECOGNIZED_KEYS` can be sent again unchanged once the server release with this change is live.

**What the server sends back.** The transfer keeps the two apart:`rejection.remarks` in the answer, and a new column`rejection_remarks` on the`transfers` row of`/bootstrap` (`null` when none). The agent's "Transfer refused" notification ends with "Remarks: …" when there are any. A transfer the admin cancelled after approval still has "Cancelled after approval: …" in`rejection_reason` and no remarks.

**Showing it.** On the rejected summary (Screen 9) and the agent's rejected transfer: "Reason :*rejection_reason* ", then "Remarks :*rejection_remarks* " on its own line when there are any.

The SQL, in full:

```
-- 1. The new column (no Scope reset: nothing rejected before today has remarks)
ALTER TABLE transfers ADD COLUMN rejection_remarks TEXT;

-- 2. Storing the row from /bootstrap, with the new column
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

-- 3. Confirm Rejection (Screen 6). :remarks is the Remarks box trimmed, or NULL when empty
--    (json_object then sends "remarks": null, which the server reads as not sent).
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

-- 4. Screen 9 and the agent's rejected transfer
SELECT rejection_reason, rejection_remarks, decided_by_name, approved_at
FROM transfers WHERE id = :id;
```

## 26 Oct 2026 — D2D vehicles: no capacity (SUP-M10)

*Later the same day the vehicle type was removed as well; the entry "D2D vehicles: no vehicle type" gives the final form and`vehicles`table.*

**Why.** D2D vehicles belong to the municipality (SMC). We record their plate, type and usual driver so the agent can pick the vehicle on a D2D collection. Nothing uses their capacity, so it is removed from the phone, the API and`/bootstrap`.

**The form.** On SUP-M10 Add Vehicle and Edit Vehicle, remove the Capacity field. The form keeps Plate number, Vehicle type and Driver name (optional).

**The calls.**

- `PUT /vehicles/{id}` (add):`{ "centerId", "plateNumber", "typeId", "driverName"? }`. Sending`capacityKg` is now refused:`400 VALIDATION_ERROR` with`UNRECOGNIZED_KEYS` on field`capacityKg`.
- `PATCH /vehicles/{id}` (edit): any of`plateNumber`,`typeId`,`driverName`. Left out or`null` keeps the value.`capacityKg` is refused the same way.
- The answers of`GET /vehicles`,`GET /vehicles/{id}`,`PUT`,`PATCH` and the status call no longer carry`capacityKg`.

**What the server sends.**`/bootstrap` rows of`vehicles` no longer carry`capacity_kg`.`transfer_vehicles` keeps its`capacity_kg` (the trucks a transfer is arranged with). No other table changes, and no Scope reset is needed.

**Showing it.** Remove capacity wherever a D2D vehicle is shown: the vehicle list, the vehicle detail and the D2D vehicle picker.

The SQL, in full:

```
-- 1. The table on a fresh install
CREATE TABLE vehicles (
  id TEXT PRIMARY KEY,
  number TEXT,                          -- SUR-VEH-0001
  center_id TEXT REFERENCES centers (id), -- null only on old shared-fleet rows
  plate_number TEXT NOT NULL,
  type_id TEXT NOT NULL REFERENCES vehicle_types (id),
  type_name TEXT NOT NULL,
  driver_name TEXT,
  is_active INTEGER NOT NULL,
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
CREATE INDEX ix_vehicles_center ON vehicles (center_id, is_active);

-- 2. An install that has the old table (a database version bump): rebuild it, keeping every row
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

-- 3. Storing the /bootstrap rows (sent whole as replace)
DELETE FROM vehicles WHERE sync_state = 'synced';
INSERT OR IGNORE INTO vehicles (id, number, center_id, plate_number, type_id, type_name, driver_name, is_active)
VALUES (:id, :number, :center_id, :plate_number, :type_id, :type_name, :driver_name, :is_active);   -- per row

-- 4. Add a vehicle (then queue PUT /vehicles/{id}:
--    {"centerId": :center, "plateNumber": :plate_number, "typeId": :type_id, "driverName": :driver_name})
INSERT INTO vehicles (id, number, center_id, plate_number, type_id, type_name, driver_name, is_active, sync_state)
VALUES (:id, NULL, :center, :plate_number, :type_id, :type_name, :driver_name, 1, 'pending');

-- 5. Edit a vehicle (then queue PATCH /vehicles/{id} with only what changed)
UPDATE vehicles
SET plate_number = :plate_number, type_id = :type_id, type_name = :type_name,
    driver_name = :driver_name, sync_state = 'pending'
WHERE id = :id;
```

## 26 Oct 2026 — D2D vehicles: no vehicle type (SUP-M10)

**Why.** The approved SUP-M10 form asks for the**collection centre, the vehicle number and the driver name**. The API also asked for a vehicle type, which nothing uses: D2D vehicles belong to the municipality (SMC), and their type was only ever shown. So the type is removed from the phone, the API and`/bootstrap`, as the capacity was earlier today.

**The form.** On SUP-M10 Add Vehicle and Edit Vehicle, remove the Vehicle type picker. The form is: Collection centre, Vehicle number, Driver name (optional). The list (Active and Deactivated tabs) shows the plate, the driver name and the status.

**The calls.**

- `PUT /vehicles/{id}` (add):`{ "centerId", "plateNumber", "driverName"? }`. Sending`typeId` (or`capacityKg`) is refused:`400 VALIDATION_ERROR` with`UNRECOGNIZED_KEYS`.
- `PATCH /vehicles/{id}` (edit):`plateNumber` and`driverName`. Left out or`null` keeps the value.
- Answers no longer carry`type`: a vehicle is`{ id, number, centerId, plateNumber, driverName, isActive }`.
- `GET /vehicle-types` is removed (it answers`404`).

**What the server sends.**`/bootstrap` sends no`vehicle_types` table, and`vehicles` rows no longer carry`type_id` or`type_name`.`transfer_vehicles` keeps its own`vehicle_type` (a transfer truck's type, as text). No Scope reset is needed.

The SQL, in full:

```
-- 1. The table on a fresh install (and no vehicle_types table)
CREATE TABLE vehicles (
  id TEXT PRIMARY KEY,
  number TEXT,                          -- SUR-VEH-0001
  center_id TEXT REFERENCES centers (id), -- null only on old shared-fleet rows
  plate_number TEXT NOT NULL,
  driver_name TEXT,
  is_active INTEGER NOT NULL,
  sync_state TEXT NOT NULL DEFAULT 'synced'
);
CREATE INDEX ix_vehicles_center ON vehicles (center_id, is_active);

-- 2. An install that has the old tables (a database version bump): rebuild vehicles,
--    keeping every row, and drop vehicle_types. Works with or without capacity_kg.
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

-- 3. Storing the /bootstrap rows (sent whole as replace)
DELETE FROM vehicles WHERE sync_state = 'synced';
INSERT OR IGNORE INTO vehicles (id, number, center_id, plate_number, driver_name, is_active)
VALUES (:id, :number, :center_id, :plate_number, :driver_name, :is_active);   -- per row

-- 4. The list (SUP-M10 tabs)
SELECT id, number, center_id, plate_number, driver_name, is_active, sync_state
FROM vehicles
WHERE (center_id = :center OR center_id IS NULL) AND is_active = :active_tab
ORDER BY center_id IS NULL, plate_number;

-- 5. Add a vehicle (then queue PUT /vehicles/{id}:
--    {"centerId": :center, "plateNumber": :plate_number, "driverName": :driver_name})
INSERT INTO vehicles (id, number, center_id, plate_number, driver_name, is_active, sync_state)
VALUES (:id, NULL, :center, :plate_number, :driver_name, 1, 'pending');

-- 6. Edit a vehicle (then queue PATCH /vehicles/{id} with only what changed)
UPDATE vehicles
SET plate_number = :plate_number, driver_name = :driver_name, sync_state = 'pending'
WHERE id = :id;

-- 7. Scope reset: the same as before, without vehicle_types
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
```

## 28 Oct 2026 — Validation rules for every write (no API change)

A new section,**Validation rules**, just above this changelog: every fixed-point write, with its field rules (required, length, range, decimal places, allowed values), the rules across fields to check before Save or Submit (collection type, prices and payment, wallet balance, free stock), and the refusals only the server can give. Use it to validate forms on the phone, so nothing goes into the outbox that the server will refuse.

No endpoint, request or response changed. Two Swagger corrections came with it:`POST /cash-requests/{id}/decide` now lists`422 MORE_THAN_ASKED` (an approval above the amount asked, which the server already refused), and the D2D vehicle APIs no longer list`INVALID_TYPE` (vehicle types were removed on 26 Oct). Swagger also shows the decimal limits now (`multipleOf`: 3 places for quantities, 2 for money).

The section is generated from the server's own schemas and is refreshed whenever a request changes.
