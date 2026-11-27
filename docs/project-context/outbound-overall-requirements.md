# EERL Outbound — Offline Data Guide

> Local context snapshot from [the Outbound explanation artifact](https://claude.ai/artifact/K1WFqnaaAuULY786jWCuoE#5a529cb4-c448), captured on 27 Nov 2026. Covers the Driver and Pickup Supervisor (outbound) module. Update only when the user explicitly requests it.

Oct 14, 2026 · @Chintan Adhvaryu

Outbound collection runs in the same EERL app as fixed-point collection, on the same sync model. This guide is for the Flutter developer: who does what, what the phone downloads, how its changes reach the server, the rules the screens follow, the notifications, every screen and every field rule. It covers only outbound; the fixed-point docs (Offline Data Guide, SQLite Schema & Queries) still apply to the agent and supervisor screens. Every table and SQL statement is in **EERL Outbound — SQLite Schema & Queries**; this guide names the section there to read.

## How outbound fits together

Four phone roles take a source from first visit to the warehouse's approval. The admin approves sources and answers requests in the web panel.

| Role | Works at | What they do on the phone |
| --- | --- | --- |
| IEC Executive | Their areas; no centre or warehouse | Finds places (leads and visits), registers sources with their schedule and payment terms, changes schedules, pauses pickups, asks for extra pickups, records a pickup the source called off, asks the supervisor or Collection Head for approvals |
| Pickup Supervisor | The areas they cover; no centre or warehouse | Gets the approved sources of their areas, sets up routes once (the server makes the trips), changes a trip for its day or cancels it, decides extra pickups and drivers' corrections, skips and moves pickups, handles issues and flags, adds drivers and labour, pays sources from their cash, reads the collection report and trips plan |
| Driver | A warehouse | Drives the trips they are given: starts the trip, records each stop, raises issues, asks for a correction, hands over at the warehouse |
| Warehouse Incharge | One or more warehouses | Sees the trips coming to their warehouses, completes stops left at the gate, records the weighbridge, approves a trip into stock or sends it back |

Nothing about how the app talks to the server changes for outbound:

- **Sign-in** is the same phone + login code, sent to the person's reporting manager.
- **`GET /bootstrap`** is still the one read: reference tables are replaced, records come as upserts and deletes, and `me` comes on every call.
- **Writes** still go through the outbox as `PUT` to an id the app makes; actions are `POST`s that are safe to repeat.
- **`null`** on an optional field still means "not sent" and never clears anything.
- **One account may hold several roles**, fixed-point and outbound alike. The app switches between them on screen, as it does today for agent and supervisor; the server judges every request on all the roles held.

**Menus.** Each role in `me.roles` carries its `modules`: the menu entries it may open. Draw each outbound role's menu from them, exactly as for the agent and supervisor, and hide an entry whose key is missing. A user with an outbound role and a fixed-point role switches between them in the same role switcher.

| Role | `role_key` | Menu entries (`modules`) besides the shared ones |
| --- | --- | --- |
| Pickup Supervisor | `PICKUP_SUPERVISOR` | `OB_TODAY` Today, `OB_ROUTES` Routes, `OB_FLAGS` Flags, `OB_SOURCES` Sources, `OB_PICKUP_REQUESTS` Extra Pickup Requests, `OB_ISSUES` Issues |
| Driver | `DRIVER` | `OB_TRIP` Today's Trip, `OB_ISSUES` Issues |
| IEC Executive | `IEC` | `OB_LEADS` Leads, `OB_SOURCES` Sources |
| Warehouse Incharge | `WAREHOUSE` | `OB_ARRIVING` Arriving Today, `OB_APPROVED_TRIPS` Approved Trips |
| Every outbound role (shared) |  | `HOME` Home, `PROFILE` Profile, `SYNC_STATUS` Sync Status, `NOTIFICATIONS` Notifications, `HELP` Help & Support |

**Offline or online.** Every screen reads SQLite, and every record write is queued, so a role can work all day without signal. A few things need the network:

| Needs the network | Offline instead |
| --- | --- |
| Sign-in, `/bootstrap`, photo and voice uploads | Keep working; the outbox waits |
| The agreement file at registration (three calls) | Upload it once the source save is answered |
| Adding, editing, deactivating and reactivating drivers and labour | The buttons say "Needs a connection" |
| Who is free for a trip (`GET /pickup-trips/{id}/free-staff`) | Work it out from `pickup_trips` (SQLite doc, Pickup Supervisor screens) |
| The trips plan beyond tomorrow (`GET /trips-plan`) | Today and Tomorrow come from `pickup_trips` |
| The collection report and its PDF (`GET /collection-report`) | The Home collection summary comes from `pickup_trips` and `trip_stops` |
| A schedule's next visits (`POST /schedules/preview`) | Work them out with the rules in "Pickups from schedules" below |

## Login and the first download

Sign-in is the fixed-point flow: the phone number, a login code sent to the person's reporting manager, then `POST /auth/verify-otp`, whose answer already carries `me` so the app can pick the role's screens before `/bootstrap` loads. Then the first `/bootstrap`, page after page until `hasMore` is false. What is different for outbound:

| What | Meaning | The app does |
| --- | --- | --- |
| `me.roles[].key` | `PICKUP_SUPERVISOR`, `DRIVER`, `IEC` or `WAREHOUSE`, alone or beside fixed-point roles | Draw each role's menu from its `modules` |
| `me.centers` | Empty for someone who holds only outbound roles | Do not block: a Pickup Supervisor or IEC Executive has no centre and no warehouse, they work by area |
| `me.warehouses[]` (`id`, `isPrimary`) | The warehouses a Driver or Warehouse Incharge is placed at, primary first. Empty for every other role | Store them on every call (`my_warehouses`, SQLite doc "The schema"); the names come from the `warehouses` table |
| `409 NO_WAREHOUSE_ASSIGNED` on any call | A Driver or Warehouse Incharge placed at no warehouse | As `NO_CENTER_ASSIGNED`: show `error.message`; nothing else works until an admin places them. `/auth/me` still answers `200`, with `setup.complete: false` and the same message in `setup.issue` |
| `me.scopeKey` | Also covers the user's warehouses, and an outbound part that moves when records leave the user (below) | A new value means the usual scope reset: send the outbox, empty the server tables except `pending` and `failed` rows, drop the cursor, download again |
| `me.outbound` | The settings the phone works with offline, and a Pickup Supervisor's cash (next section) | Keep it in `sync_meta` on every call; remove the keys when it is `null` |

**When the scope key changes for outbound.** A delta cannot say "this is no longer yours", so the server changes the key and the phone downloads again:

- a Driver or Warehouse Incharge is placed at another warehouse, or taken off one;
- an area (or a whole city) a Pickup Supervisor covered moves to another supervisor, or the admin moves a source to another supervisor: its sources, pickups and route stops leave them;
- the admin hands a source to another IEC Executive: the former one, if they did not register it, loses it;
- a driver is taken off a trip (Change for today, or a route edit that gives its trips another driver);
- a role is added or removed, as for fixed-point.

**The daily roll.** The first sync of an IST day by anyone in the company with an outbound role makes the day's work before it answers: visits 14 days ahead from every schedule, sources Paused or Active again as pauses begin and end, event points ended the day after their schedule's end date, and today's and tomorrow's trips made from the routes. It runs once a day per company, so that first sync of the morning can take a few seconds longer. The phone does nothing: the changes come in the same answer.

**Every app open** is as for fixed-point: `GET /bootstrap?since=<cursor>` on opening, on reconnecting, after the outbox empties, on pull-to-refresh, and when a push arrives.

## What /bootstrap sends

Outbound tables reach only someone who holds an outbound role, so a fixed-point phone's answer is unchanged. Reference tables come whole, as `replace`, whenever any row in them changes. Records come as `upserts` and `deletes`, each with all its children: replace the children every time the parent arrives. How to apply each table: SQLite doc, "Sync: applying /bootstrap".

### Reference tables

The admin keeps all of these in the panel; the phone only reads them.

| Table | Pickup Supervisor | IEC Executive | Driver | Warehouse Incharge |
| --- | --- | --- | --- | --- |
| `warehouses` (name, code, address, pin, in-charge name and phone) | Every active warehouse with a code | Every active warehouse with a code | Their own | Their own |
| `warehouse_shifts` (e.g. Morning 06:00–14:00; a night shift ends the next day) | Every warehouse's | — | Their warehouses' | Their warehouses' |
| `outbound_vehicles`, `warehouse_drivers`, `warehouse_labour` | Every warehouse's | — | — | — |
| `cities` | Active ones | Active ones | — | — |
| `areas` (PIN codes, the supervisor who covers each) | The ones they cover | Every active one | — | — |
| `source_categories` (Shop, Society, Office…) | — | Active ones | — | — |
| `items` | As for every role | As for every role | As for every role | As for every role |

- A warehouse appears only once the admin has given it a code: its trip, driver and labour numbers start with it.
- A rented truck is never in `outbound_vehicles`; the supervisor types it on the route. The D2D `vehicles` table never holds a pickup van.
- An area can share a PIN code with another, so the PIN lookup can return several.
- The Mixed waste item (`me.outbound.mixedItemId`) is in `items` so its name shows, but never in an agent's material lists.

**`warehouse_drivers.is_active`**: 1 = placed at that warehouse. 0 = a driver taken off one of the supervisor's warehouses (Deactivate) and placed nowhere since, listed under the warehouse they left. Offer only `is_active = 1` drivers in route and trip pickers; the 0 rows feed the Deactivated Driver Directory and Reactivate.

### Records

| Table (children) | Pickup Supervisor | IEC Executive | Driver | Warehouse Incharge | Kept however old |
| --- | --- | --- | --- | --- | --- |
| `outbound_sources` (`outbound_source_items`, `pickup_schedules`, `source_payment_terms`, `source_item_rates`, `source_pauses`) | The approved sources assigned to them: Active, Paused, Ended | The sources they registered or look after, every status | — | — | Waiting for approval, Active, Paused, Rejected |
| `source_leads` (`lead_visits`) | — | Their own | — | — | New, Follow-up, Interested |
| `due_pickups` | Pickups of the sources assigned to them | Pickups of the sources they registered or look after | — | — | Due in the window or later |
| `pickup_routes` (`pickup_route_stops`) | Their routes, on and off | — | — | — | Always |
| `pickup_trips` (`trip_stops`) | The trips of their routes | — | The trips they drive | The trips to their warehouses | Trip day in the window or later |
| `trip_issues` | The issues they handle | — | The issues they raised | — | Open and escalated |
| `supervisor_flags` | Their own | — | — | — | Open |
| `supervisor_cash_book` | Their own | — | — | — | Only lines inside the window |
| `supervisor_cash_requests` | Their own | — | — | — | Pending |
| `source_payments` | Their own | — | — | — | Only payments dated inside the window |
| `outbound_requests` | Raised by them or sent to them | Raised by them or sent to them | Raised by them | — | Waiting |
| `notifications` | Their own | Their own | Their own | Their own | Unread |

- **History window:** 7 days for a Driver, 30 for every other outbound role; the longest window of the roles held wins. Closed rows that age out arrive as `deletes`; the phone never trims by date itself, and never overwrites a `pending` or `failed` row.
- **A trip carries its names.** A trip row has the route, warehouse, shift, van or rented truck, driver and labourer by name, and each stop carries the pickup's copy of the source (name, address, pin, the person there, Sorted or Mixed with its items). A Driver's and an Incharge's phone has no sources, routes, vans or labour, so never join to them on those phones.
- **A stop carries its record.** Once recorded, a stop holds what was entered (outcome, items, weight, photos, note, voice note, GPS, who and when, driver or gate), and the trip holds the start, the hand-over, the weighbridge, the difference and the approval. The columns are in the SQLite doc, "The schema".
- A trip's stops never include pickups the system cancelled; a pickup the source called off stays on its trip only when the driver recorded it at the stop.

### me.outbound

Sent on every call to anyone with an outbound role, `null` for everyone else. Keep each field in `sync_meta` (key names in the SQLite doc, "Conventions").

| Field | Default | Meaning | Used on |
| --- | --- | --- | --- |
| `gpsRadiusM` | 100 | A stop matches when the phone is within this many metres of its pin (admin range 20–1000) | Driver: finding the stop |
| `tolerancePct` | 3 | How far, in percent, the weighbridge may differ from the entries before a trip is flagged (0–50) | Incharge: Check and approve |
| `speedKmh` | 20 | Straight-line speed between stops (5–80) | Route estimates |
| `minutesPerStop` | 10 | Time spent at each stop (1–120) | Route estimates |
| `offRouteKm` | 2 | A stop that adds more than this to the route is off the route (0.5–50) | Route estimates |
| `supportPhone`, `supportWhatsapp` | `null` | Help & Support's "Call the EERL office" and "Message the office on WhatsApp" | Help & Support: hide a button whose number is `null` |
| `mixedItemId` | `null` | The item a Mixed source's pickup is weighed as. While `null`, a Mixed stop is refused (`409 MIXED_ITEM_NOT_SET`) | Mixed forms |
| `driverCode` | `null` | The caller's own driver code, e.g. `SUR-DRV-0007`; `null` for anyone who is not a driver | Driver: Profile |
| `collectionHead` | `null` | `{userId, name, phone}`: the caller's reporting manager when they have an active one, else the Collection Head of their city, else the company's first. Requests sent to the Collection Head go to this same person | Call the Collection Head; hide it when `null` |
| `cash` | `null` | Pickup Supervisor only, worked out on every call: `balance` (rupees in hand) and `dues[]`, one per source with payment terms: `sourceId`, `earned`, `paid`, `balance` (owed now, carried over), `nextDueOn` (the next payment day, today or later), `lastPaidOn` | Cash & Payments, Pickup Point Detail |

### me.supervisor

`{name, phone, photoUrl}`: the person's reporting manager, or `null` when none is set. For a Driver it is the supervisor who added them: Call and Message on Home, and where an issue not about a trip goes. For a Pickup Supervisor and an IEC Executive, name and call the Collection Head from `me.outbound.collectionHead` instead: that is the person their requests to the Collection Head go to. `photoUrl` `null`: show their initials.

## Sending your changes

The outbox works as for fixed-point (Offline Data Guide, "Sync — sending your changes"): every write goes to SQLite first with `sync_state = 'pending'`, then into the outbox, which sends one item at a time, oldest first, whenever the phone is online. Request bodies use the API's camelCase fields, never the SQLite row; `null` on an optional field means "not sent" and never clears anything. The queued statements are in the SQLite doc, "Outbox and uploads".

### Ids, numbers and replays

- **The app makes every id**: a uuid v4 the moment a record is created, sent in the path (`PUT /…/{id}`). Leads, visits, sources, schedule and payment terms versions (their ids go inside the source body), agreements, pauses, extra pickups, routes, entries, issues, requests, cash requests, payments, drivers and labour. Use the id at once for every link on the phone.
- **Numbers come from the server**: sources `SUR-SRC-0001`, trips `{warehouse code}-TRP-YYMMDD-NNN`, drivers `SUR-DRV-0001`, labour `{warehouse code}-LAB-0001`. Show them once they arrive; never build one on the phone.
- **Every write is safe to send twice.** The same id again answers the saved record (an entry is never changed by a replay); an action already done (accept, skip, start, hand over, approve) answers the record as it stands.
- **`409 ID_IN_USE`**: the id belongs to another record (another source's schedule, another person's request). Refused; with fresh uuids it never happens.

### Reading the answer

| Answer | Means | Do |
| --- | --- | --- |
| `2xx` | It landed | Write the answer over the row, set `synced`, delete the outbox item |
| `409 WRONG_STATE` or `409 DATE_PASSED` on a pickup decision or a trip change | Someone acted first, or the day passed | Not a failure to fix: drop the write, sync, show the record as it is now and say why |
| `409 NOT_READY` on approve | The server has not reached Checking (a stop or a weight it has not got yet) | Drop the write, sync, show the trip as it is |
| `422` with `details` | A field is refused | Mark the row and the item `failed`; show each `details[].message` on its field (`details[].field`, e.g. `schedule.weekdays`, `sourceIds.3`, `lines.0.quantity`) |
| Any other `4xx` | Refused; retrying will not help | `failed`, shown in Sync Status with Retry and Discard |
| `401`, `5xx`, no signal | As for fixed-point | Sign in again; retry later |

### Order and merging

- **An item waits for what it refers to.** A visit waits for its lead; a schedule change, payment terms, a pause, an extra pickup or a cancellation waits for its source; an entry waits for its photos and voice note; a gate entry or weighbridge save waits for its photos.
- **One trip's writes go in the order they were made**: Start trip, the entries, the hand-over. An approve goes after that trip's gate entries and weighbridge saves.
- **A trip stays `pending`** while any of its entries is queued; set it back to `synced` only when none is left.
- **The agreement file** is uploaded once the source save has been answered (it needs the network).
- **Merging:** a whole-record `PUT` still queued for the same id (source, lead, route, payment terms) is replaced by the newer body; so is a queued Change for today for the same trip and a gate entry for the same stop. Two queued weighbridge saves for one trip merge into one body, the later fields winning. Entries are never merged: one per stop, read-only once sent.
- **Answers that carry more than the record:** a route save returns `warnings`, Change for today its own `warnings`, an extra pickup a `warning`, Move stops `{from, to}` (write both trips). Show warnings after saving; they are never errors.

### The writes, by role

IEC Executive.

| Screen action | Call | Queued | What the server does | Who is told |
| --- | --- | --- | --- | --- |
| Add or edit a lead | `PUT /source-leads/{id}` | Yes | Saves the lead. It becomes Converted when a source is submitted with its `leadId` | — |
| Log a visit | `PUT /source-leads/{id}/visits/{visitId}` | Yes | The latest visit sets the lead's status and next follow-up; answers the lead with its visits | — |
| Register, edit or resubmit a source | `PUT /outbound-sources/{id}` | Yes | New: Waiting for approval, numbered. Waiting: the content is replaced. Rejected: resubmitted. Approved: the details change; the pin, area, warehouse, Sorted/Mixed and event flag are the admin's. `agreement` opens a draft agreement | On the admin's decision: the IEC (Source approved / Source not approved) and the supervisor (New source in your area) |
| Attach the agreement file | `POST /source-agreements/{id}/upload-url`, `PUT` the file, `POST /source-agreements/{id}/files` | No | The agreement goes to the office for approval | — |
| New payment terms from a date | `PUT /outbound-sources/{id}/payment-terms/{termsId}` | Yes | A new version from `effectiveFrom`; a version starting that day is replaced | — |
| Change the schedule | `PUT /outbound-sources/{id}/schedules/{scheduleId}` | Yes | From `startsOn`; replaces versions starting that day or later; open pickups are made again | The supervisor gets a Schedule changed flag |
| Pause, or end a pause | `PUT /source-pauses/{id}`, `POST /source-pauses/{id}/cancel` | Yes | Pickups inside the pause are cancelled; the source is Paused while a pause covers today; ending one under way ends it yesterday | The supervisor gets a Paused flag |
| Ask for an extra pickup | `PUT /due-pickups/{id}` | Yes | Requested, waiting for the supervisor | Supervisor: Extra pickup requested |
| Cancel a pickup for the source | `POST /due-pickups/{id}/cancel-by-source` | Yes | Cancelled by source; it leaves its trip | — |
| Ask for approval | `PUT /outbound-requests/{id}` | Yes | Waiting, with the supervisor or the Collection Head | The one it goes to: New request |
| Follow up, escalate | `POST /outbound-requests/{id}/follow-up`, `/escalate` | Yes | A follow-up once a day; after 3, a request to a supervisor can go to your reporting manager | Whoever has it: Follow-up on a request; on escalation: Request escalated to you |
| Preview a schedule | `POST /schedules/preview` | No | Saves nothing; answers the next visits | — |

Pickup Supervisor.

| Screen action | Call | Queued | What the server does | Who is told |
| --- | --- | --- | --- | --- |
| Add an extra pickup | `PUT /due-pickups/{id}` | Yes | Due at once; a source on no route raises an Unassigned extra pickup flag | — |
| Accept or decline an extra pickup | `POST /due-pickups/{id}/accept`, `/decline` | Yes | Requested → Due, or Declined with the reason | IEC: Extra pickup accepted / declined |
| Skip, undo skip, move | `POST /due-pickups/{id}/skip`, `/unskip`, `/move` | Yes | Skipped (it leaves its trip), Due again, or due another day | — |
| Cancelled by source | `POST /due-pickups/{id}/cancel-by-source` | Yes | Cancelled by source; it leaves its trip | — |
| Save a route | `PUT /pickup-routes/{id}` | Yes | Today's and tomorrow's trips not changed for today follow at once; answers `warnings`; raises or closes Time clash and Off the route flags | — |
| Switch a route off or on | `POST /pickup-routes/{id}/deactivate`, `/activate` | Yes | Off: its trips not started are cancelled ("Route switched off"), their pickups go back to Unassigned. On: the team is checked again, trips come back | — |
| Change for today | `POST /pickup-trips/{id}/change-for-today` | Yes | The trip keeps this team and these stops for its day; stops left out go back to Unassigned | Driver: Trip changed; a new driver: New trip for you; a driver taken off: Taken off a trip |
| Move stops | `POST /pickup-trips/{id}/move-stops` | Yes | The stops go to the end of the other trip; both are changed for today; moving every stop cancels this trip | The other trip's driver: Stops added; this trip's driver, when different: Trip changed (Trip cancelled when all moved) |
| Cancel a trip | `POST /pickup-trips/{id}/cancel` | Yes | Cancelled for its day, pickups back to Unassigned; the server never brings it back | Driver: Trip cancelled |
| Complete for the driver | `POST /pickup-trips/{id}/complete-for-driver` | Yes | Stops not visited go back to Unassigned, the rest wait for the gate; the trip is At the warehouse | Incharges: Trip at the warehouse |
| Mark a flag done | `POST /supervisor-flags/{id}/done` | Yes | The flag closes | — |
| Resolve or escalate an issue | `POST /trip-issues/{id}/resolve`, `/escalate` | Yes | Resolved with a note, or Escalated (the office sees it in the panel) | Resolve: the driver (Issue resolved). Escalate: the pickup point's IEC (Issue escalated) |
| Ask the Collection Head | `PUT /outbound-requests/{id}` | Yes | Waiting, with the Collection Head in `me.outbound.collectionHead` (none at all: the office) | They get New request |
| Approve or decline a request | `POST /outbound-requests/{id}/decide` | Yes | An approved pause is added to the pickup point; an approved correction changes the stop's record; other kinds are answered only | The asker: Request approved / declined |
| Follow up a request | `POST /outbound-requests/{id}/follow-up` | Yes | Counted, once a day | Whoever has it |
| Ask for cash | `PUT /supervisor-cash-requests/{id}` | Yes | Pending; the office approves (possibly for less) or rejects | Later: Cash approved / Cash request rejected |
| Pay a source | `PUT /source-payments/{id}` | Yes | Cash in hand goes down by the amount; a line in the cash book | — |
| Add, edit, deactivate, reactivate a driver or labourer | `PUT /warehouse-drivers/{id}`, `PUT /warehouse-labour/{id}`, `POST …/deactivate`, `/activate` | No | A new driver is a new login with you as reporting manager; the lists come back as reference tables | — |

Driver.

| Screen action | Call | Queued | What the server does | Who is told |
| --- | --- | --- | --- | --- |
| Start trip | `POST /pickup-trips/{id}/start` | Yes | Planned → On route with `started_at` (today's trips only) | Incharges: Trip started |
| Record a stop | `PUT /pickup-entries/{id}` | Yes | The stop becomes Collected, 0 kg, At the gate or Cancelled by source. The first entry starts a Planned trip of today | Incharges, when it starts the trip: Trip started |
| Raise an issue | `PUT /trip-issues/{id}` | Yes | Open, with the trip's supervisor (no trip: your reporting manager) | Supervisor: Issue raised |
| Ask supervisor to correct | `PUT /outbound-requests/{id}` (`ENTRY_CORRECTION`) | Yes | Waiting with the trip's supervisor; the stop shows Correction requested | Supervisor: New request |
| Follow up a correction | `POST /outbound-requests/{id}/follow-up` | Yes | Counted, once a day | The supervisor |
| Hand over at the warehouse | `POST /pickup-trips/{id}/hand-over` | Yes | On route → At the warehouse; stops not recorded go to the gate team; the trip is read-only for the driver after it | Incharges: Trip at the warehouse |

Warehouse Incharge.

| Screen action | Call | Queued | What the server does | Who is told |
| --- | --- | --- | --- | --- |
| Complete a stop at the gate | `PUT /pickup-trips/{id}/gate-entries/{duePickupId}` | Yes | The stop becomes Collected or 0 kg, entered at the gate (sending again changes it). A Checking trip goes back to At the warehouse first | — |
| Save the weighbridge | `PUT /pickup-trips/{id}/weighbridge` | Yes | The fields sent replace; the difference is worked out once both weights are in | The first time both weights are in: the driver and supervisor (Received at the warehouse) |
| Approve | `POST /pickup-trips/{id}/approve` | Yes | Approved and final: the entries' weights go into the warehouse's stock and count towards what sources are owed | Driver and supervisor: Trip approved |
| Send back | `POST /pickup-trips/{id}/send-back` | Yes | Back to At the warehouse with the note; checked again after the next gate entry or weighbridge save | Driver and supervisor: Trip sent back |

## Photos, files and voice notes

Photos and voice notes work as for fixed-point (Offline Data Guide, "Photos"): ask `POST /uploads/batch` for upload links (1–20 per call), `PUT` each file to its `uploadUrl` with the same Content-Type within 15 minutes of asking, then put its `fileUrl` in the record. Every file is at most 5 MB (`422 FILE_TOO_LARGE` on `photos.N.sizeBytes`, the whole batch refused). A record may carry only files its own author was issued and has uploaded: otherwise `422 INVALID_PHOTO` (on a source or lead: `INVALID_SOURCE` / `INVALID_LEAD` with `PHOTO_NOT_ISSUED` on the field). Files already on a record are kept without a check.

| Purpose | Who | Goes in | Types |
| --- | --- | --- | --- |
| `LEAD_PHOTO` | IEC Executive | A lead's `photoUrls` (up to 10) | `image/jpeg`, `image/png` |
| `SOURCE_PHOTO` | IEC Executive | A source's `photoUrls` (up to 10) | `image/jpeg`, `image/png` |
| `WAREHOUSE_PERSON` | Pickup Supervisor | A driver's or labourer's `photoUrl` (profile) and `idProofUrl` (ID proof), two separate photos | `image/jpeg`, `image/png` |
| `PICKUP_PHOTO` | Driver; Warehouse Incharge at the gate | An entry's `photoUrls` (up to 10; at least one when the driver records Collected) and a line's `photoUrl`; a gate entry's photos (optional) | `image/jpeg`, `image/png` |
| `PICKUP_VOICE` | Driver | An entry's `voiceUrl`: a voice note of up to a minute | `audio/mp4` (m4a), `audio/aac`, `audio/mpeg` only. A photo type for it, or audio for any other purpose, is refused (`422 WRONG_TYPE`) |
| `WEIGHBRIDGE_SLIP` | Warehouse Incharge | The weighbridge's `slipPhotoUrls` (up to 10) | `image/jpeg`, `image/png` |
| `PAYMENT_RECEIPT` | Pickup Supervisor | A source payment's `photoUrl` (the receipt, or the UPI screen) | `image/jpeg`, `image/png` |

**The agreement file** (IEC Executive, optional at registration) is private and goes another way, online only, after the source save carrying `agreement {id, endsOn}` has been answered:

1. `POST /source-agreements/{id}/upload-url` with `fileName` and `contentType` (`application/pdf`, `image/jpeg` or `image/png`). The answer: `uploadUrl`, `key`, `expiresAt`, `maxBytes` (10 MB).
2. `PUT` the file to `uploadUrl` with the same Content-Type, within 15 minutes.
3. `POST /source-agreements/{id}/files` with the `key`, the same `fileName` and `contentType`. A draft or sent-back agreement goes to the office for approval; the same key again adds nothing.

Only the office opens the file, and every opening is logged. The source then shows `agreement_status` and `agreement_ends_on` ("Rules the app follows", below).

## Rules the app follows

The server is the judge of every rule below. The phone applies the same rules so that screens show the right thing offline and forms are refused before they are queued; the server's answer always wins.

### Sources and leads

| Source `status` | Show it as | How it gets there |
| --- | --- | --- |
| `PENDING_APPROVAL` | Waiting for approval | The IEC submits it (a resubmission too) |
| `ACTIVE` | Active | The admin approves it; a pause ends |
| `PAUSED` | Paused till … (or until resumed) | A pause covers today |
| `REJECTED` | Not approved, with `rejection_reason` | The admin rejects it. The IEC edits and resubmits it with the same id |
| `ENDED` | Ended | The admin ends it; an event point ends by itself the day after its schedule's end date |

| Lead `status` | Show it as |
| --- | --- |
| `NEW`, `FOLLOW_UP`, `INTERESTED`, `NOT_INTERESTED` | New, Follow-up, Interested, Not interested. Set by the IEC; the latest visit's outcome sets it |
| `CONVERTED` | Converted: set by the server when a source is submitted with the lead's id. Never sent by the phone |

- **The pin** is what the driver's GPS is matched against: it must sit at the pickup spot (the gate, not the main road). Ask for it on the spot, with the map.
- **Area from the pin**: turn the pin into a PIN code with the phone's own reverse geocoder (no extra service or key), then look it up in `areas.pin_codes`. One area: fill it in. None, several, or no PIN code (no signal, geocoder unavailable): let the IEC pick from the list. The IEC can always change it; the server keeps what is sent. On approval the source goes to the supervisor who covers that area (none: the admin assigns one).
- **After approval** the IEC may still change the person at the pickup point, photos, items and notes, and add payment terms from a date. The pin, area, warehouse, Sorted/Mixed and event flag are the admin's: show them read-only (`FIELD_LOCKED` otherwise). The schedule then changes only through the schedule screen (`SCHEDULE_LOCKED` if a new schedule id is sent in the source body).
- **The IEC owner** (`iec_owner_id`, `iec_owner_name`, `iec_owner_phone`) is the IEC who looks after the source: the one who registered it, until the admin hands it to another. An IEC sees and edits the sources they registered or look after; "My pickup points" lists the ones they look after.
- **Pickup category** (`pickup_category`) is worked out by the server from the schedule in force today: `DAILY` (five or more days a week, and alternate days), `WEEKLY`, `BI_WEEKLY` (a fortnight), `MONTHLY` (longer, and month dates), `ON_CALL` (on demand), `ONE_TIME`. Show it, never edit it. The phone's schedule presets map to patterns: Weekdays = Weekly Monday to Saturday, Alternate days = every 2 days.
- **Summaries**: every schedule and payment terms version carries a `summary` in words ("Every Mon and Thu, 08:00–10:00", "Paid ₹12 per kg, every Monday, in cash"). Show it as it is; while a version waits in the outbox, build a similar line on the phone.
- **The agreement** (`agreement_status`, `agreement_ends_on`: the latest one not ended): `DRAFT` opened, no file yet (upload it); `PENDING_APPROVAL` with the office; `SENT_BACK` the office wants another file (upload again); `ACTIVE` show "Agreement till {date}"; `EXPIRED` past its end date. `null`: none.

### Pickups from schedules

The server turns every approved source's schedule into **pickups** (`due_pickups`): one per visit, on a date, in a time window, 14 days ahead, kept right as schedules, pauses and warehouse holidays change. The phone never makes scheduled pickups itself; it receives them. Each pickup carries a copy of the source (name, address, pin, the person there, Sorted or Mixed and its items) that the server keeps up to date.

| Pickup `status` | Show it as | Who moves it there |
| --- | --- | --- |
| `DUE` | Due; **Missed** by the rule below | The server, from the schedule; the supervisor (an extra pickup, accepting a request, undoing a skip, taking it off a trip) |
| `REQUESTED` | Requested, waiting for the supervisor | The IEC asks for an extra pickup |
| `DECLINED` | Declined, with `decline_reason` | The supervisor |
| `PLANNED` | On a trip (`trip_id`, `stop_order`); off the trip it is Due again | The server, from the route; the supervisor's trip changes |
| `AT_GATE` | At the gate | The driver's "Gate team will enter", the hand-over (stops not recorded), Complete for the driver |
| `COLLECTED` | Collected | The driver's entry, or the gate's |
| `NOT_COLLECTED` | 0 kg | The driver's entry, or the gate's |
| `SKIPPED` | Skipped, with the reasons joined ("Source closed, Holiday"), then `skip_note` | The supervisor |
| `CANCELLED` | Hide it, or show `cancel_reason` greyed (Schedule changed, Paused, Warehouse holiday, Source ended, Event over). Never "Skipped" | The server |
| `SOURCE_CANCELLED` | Cancelled by source, with the reason, note, who and when (`source_cancel_*`) | The IEC or supervisor ahead of time; the driver at the stop |

**How pickups are made** (for an offline preview of a schedule being entered):

- The schedule version in force on a day is the latest one whose `effective_from` is on or before it.
- Each time window is its own pickup (`slot_index` 0, 1, …); no window means one pickup, any time.
- A monthly date missing from a month (the 31st in a 30-day month) falls on the month's last day.
- "Every N days" and "every N weeks" count from the schedule's start date.
- On a warehouse holiday: **Skip** drops the pickup; **Next working day** moves it to the next day that is not a holiday, and if that day already has the pickup, there is still only one.
- Inside a pause there are no pickups.
- When online, `POST /schedules/preview` answers the next dates exactly; offline, work them out with these rules.

* **Next working day** looks at most 14 days ahead. A visit someone acted on (skipped, moved, requested, accepted, on a trip) is never changed by a schedule change; past visits are never touched.

**Missed** is worked out on the phone, never sent: a pickup that is `DUE` or `PLANNED` and either its `due_date` is before today, or its trip is `AT_WAREHOUSE`, `CHECKING` or `APPROVED` (neither the driver nor the gate recorded it). It is never carried forward by itself: the supervisor moves or skips it.

**Extra pickups**

- Today or later, at most 60 days ahead. Not on a warehouse holiday (`422 WAREHOUSE_CLOSED` on `date`) or inside a pause (`422 SOURCE_PAUSED`); show the message on the date field.
- A time window has both ends or neither (any time). The expected kg is optional.
- From the IEC it is Requested; from the supervisor it is Due at once.
- The source already has a pickup that day: the answer carries `warning` ("Already has a pickup on Thu 22 Oct, 08:00–10:00."). Show it; it is not an error.
- When the schedule in force says no extra pickups (`pickup_schedules.allows_extra = 0`), hide the IEC's button for that source (`409 EXTRA_NOT_ALLOWED` otherwise). The supervisor can still add one.
- Accepting after the day passed: `409 DATE_PASSED`; decline it instead.

**Skip, undo skip, move** (the source's Pickup Supervisor only)

- Skip asks one or more reasons as tick boxes: Source closed, Holiday, Source asked, Vehicle unavailable, Capacity full at warehouse, Not enough time in shift, Other (needs a note). A missed pickup may be skipped too.
- Undo skip only while its day has not passed.
- Move: a new day (today or later) and, optionally, a new window; left out, the window stays. Not onto a holiday or a paused day. Show "Moved from Wed 21 Oct" from `moved_from`; the schedule never makes it again on the old day.
- Skip and move also work on a Planned pickup of a trip not started: it leaves the trip. On a started trip the driver records what happens at the stop.

**Schedule changes and pauses** (the IEC who registered or looks after the source)

- A schedule change starts on its start date (today or later) and replaces every version starting that day or later. Pickups already skipped, moved, requested or accepted stay: say so on the screen. Only on an approved source (`409 NOT_APPROVED` before: edit the source instead).
- A pause: from today or later, to a date or "until resumed", with a reason. While it covers today the source shows **Paused**. Pauses cannot overlap (`422 PAUSE_OVERLAP`); a pause under way keeps its start (`422 PAUSE_STARTED`).
- Ending a pause: not begun, it never applies; under way, it ends yesterday, so pickups start again today; over, it stays in the history (`409 PAUSE_OVER`). A supervisor cannot end a pause: they ask through a request.

**Cancelled by source** (the IEC who registered or looks after the source, or its supervisor; the driver records it at the stop instead)

- Reasons: Closed that day (`CLOSED`), No material (`NO_MATERIAL`), Holiday (`HOLIDAY`), Moved to another day (`SHIFTED`), Other (`OTHER`, with a note).
- From Requested, Due, or Planned on a trip not started; today or later (`409 DATE_PASSED`; otherwise `409 WRONG_STATE`).
- It leaves its trip and cannot be undone. It is not a skip, and later pickups stay as planned.

### Routes and trips

The Pickup Supervisor sets up **routes** once; every day the server makes a **trip** from each active route for today and tomorrow, holding that day's pickups of the route's sources in the route's order. The phone never makes trips; it receives them.

- **A route** is a warehouse (active, with a code), one of its shifts, our van with an app driver placed at that warehouse **or** a rented truck (number, transporter, driver name and phone, capacity in kg optional; no driver app, so its stops are entered at the gate), one labourer (optional), and its sources in pickup order. A source is on one route at a time: putting it on a route takes it off the other. There are no running days: a route runs on any day its sources have pickups; two visits of one source that day go in window order.
- **Own or contract**: `vehicle_kind` on routes and trips is `OWN` (our van) or `CONTRACT` (a rented truck). Show it as a chip; set it on a route row the phone saves, before the answer comes.
- **A route save never refuses for a clash.** Its answer carries `warnings`, each with `code`, `sourceId` (or null) and a `message` ready to show:

| Warning | Means |
| --- | --- |
| `OUTSIDE_SHIFT` | A source's time window is outside the shift's hours |
| `VAN_CLASH`, `DRIVER_CLASH`, `LABOUR_CLASH` | The same van, driver or labourer is on another active route in this shift |
| `OTHER_WAREHOUSE` | A source normally sends to another warehouse |
| `MOVED_FROM_ROUTE` | A source was moved here from another route |
| `TIME_CLASH`, `OFF_ROUTE` | The route reaches a source after its windows close, or the source is far off the route ("Route estimates", below) |

**How trips follow** (the rules behind what arrives):

- A trip is one active route on one day, made only when it has a stop. Its pickups are `PLANNED`; off the trip they are `DUE` again.
- A route edit (team, van, sources, order) reaches today's and tomorrow's trips at once, unless the trip was changed for today. A source taken off a route goes back to Unassigned.
- A trip changed for today (`changed_for_today` = 1) keeps its team and stops; a pickup that becomes due later (an extra accepted, a schedule change) joins at the end.
- A stop the supervisor removed, or a trip they cancelled, stays that way: the server does not bring it back.
- A trip left with no stops (a pickup skipped, a pause) is cancelled by the server with "No pickups"; switching a route off cancels its trips not started with "Route switched off". Those two come back by themselves when pickups return or the route is switched on.
- **Unassigned** (worked out on the phone): the supervisor's Active and Paused sources with no stop on an active route, and Due pickups of today or tomorrow with no `trip_id`.

| Trip `status` | Show it as | Who moves it there |
| --- | --- | --- |
| `PLANNED` | Planned | The server makes it |
| `ON_ROUTE` | On route; "Started 8:05 am" from `started_at` | The driver's Start trip, or their first entry |
| `AT_WAREHOUSE` | At the warehouse; the stops at the gate counted | The driver's hand-over; the supervisor's Complete for the driver; the incharge's send back |
| `CHECKING` | Being checked | The server, once every stop is recorded and both weights are in |
| `APPROVED` | Approved: final, nothing changes after | The incharge |
| `CANCELLED` | Cancelled, with `cancel_reason` (the supervisor's reason, "No pickups", "Route switched off", "Stops moved to …") | The supervisor or the server |

**How a stop shows** on a trip (worked out on the phone from `trip_stops`, `due_pickups` and `outbound_sources`; the server's trip answers carry the same as `displayState`, `cancelledBySource`, `inactive` and `counts`):

| State | When |
| --- | --- |
| Pending | Not visited yet. The first pending stop after the last recorded one is the **Next stop** |
| At the gate | Left for the gate team (`AT_GATE`) |
| Collected | `COLLECTED`; tagged **Entered at gate** when `entry_method` is `GATE` |
| 0 kg | `NOT_COLLECTED`: visited, nothing taken |
| Cancelled by source | The driver recorded it at the stop, or (listed under the stops) the route's pickups that day the source called off ahead of time; those have left the trip |
| Missed | By the Missed rule above |
| Inactive | Listed under the stops: the route's sources that are paused ("Paused till …") or ended |

The filter chips carry the counts of each state.

**Changing one trip** (the trip's supervisor, a Planned trip of today or tomorrow):

- **Change for today** sends the team and `stopIds`, the due pickups in order. The picker offers the Due pickups of that day (Unassigned ones too) and stops on the supervisor's other Planned trips that day (taking one moves it). At least one stop: removing the last one is not allowed, offer Cancel trip instead. A stop left out goes back to Unassigned.
- **Why the team changed**: when the van, rented truck, driver or labourer differs from the trip's, ask a reason before queuing: Absent, Breakdown, Vehicle not available, Other (with a note). A reorder or a stop change alone needs none. Without it: `422 REASON_REQUIRED` on `reason`. The trip keeps it (`change_reason`, `change_note`): show it under "Changed for today". The answer carries its own `warnings` (`VAN_CLASH`, `DRIVER_CLASH`, `LABOUR_CLASH`: the same one on another trip in this shift that day).
- **Move stops**: tick stops of the trip and choose another of your Planned trips of the same day and warehouse, with a reason (always). They go to the end of that trip in the order ticked; both trips show "Changed for today". Moving every stop cancels the first trip ("Stops moved to …"). The answer is `{from, to}`: write both trips.
- **Who is free**: the driver and labour pickers list the warehouse's active vans, drivers and labour, marking (greyed) those on another trip that is not cancelled in the same shift that day; the trip's own team is listed too. Online, `GET /pickup-trips/{id}/free-staff` (it sees other supervisors' trips too); offline, the query in the SQLite doc.
- **Cancel this trip** (that day only, a reason required): its pickups go back to Unassigned for the day and the trip stays cancelled. **Switch off the route** is different: no trips until it is switched on, and its sources stay on it but count as Unassigned.
- `409 WRONG_STATE` (the trip started or was cancelled) or `409 DATE_PASSED` (its day passed): drop the write and sync.

### Route estimates

**Time clash and off the route** (Add to a route; Flags). Saving a route answers with warnings `TIME_CLASH` and `OFF_ROUTE`, and raises (or closes) the matching flags. Before saving, the phone shows the same warnings by running these steps on the route's stops with the new pickup point last:

1. Start at the warehouse's pin at the shift's start time.
2. For each stop in order: add the straight-line distance from where you are, at `outbound_speed_kmh` (20); that is the arrival.
3. Early at the stop: wait until its next pickup window opens. Past every window of the day: **Time clash** ("Adajan Morning reaches ABC Textile Mills at about 1:30 pm, after its 8–10 am window."). No windows: any time.
4. Add `outbound_minutes_per_stop` (10) for the stop; move on.
5. **Off the route**: going via a stop adds more than `outbound_off_route_km` (2) against going straight from the stop before (or the warehouse) to the stop after (or the warehouse). Say it as "4.2 km off the route: about 13 min more on each trip" (the extra km at the same speed).
6. A stop without a pin gets no estimate and does not move the clock.

Round times to 5 minutes when shown ("about 1:30 pm"). The Flags screens for Time clash and Off the route show the route, the pickup window and the arrival from these same steps; the flag's `message` is the server's sentence.

The server runs the same steps when the route is saved, with the schedule in force today, and keeps the Time clash and Off the route flags in line: raised on an active route, rewritten on each save, closed when the clash or detour is gone or the source leaves the route.

### Flags

Flags are the supervisor's to-do list (`supervisor_flags`). Show them open first, newest first, each with Mark done, and their count in "Needs your attention". `message` is ready to show. There is one open flag per type and source (or pickup): a new event rewrites it.

| `type` | Show it as | Raised when | Closes by itself when |
| --- | --- | --- | --- |
| `SCHEDULE_CHANGED` | Schedule changed | The IEC changes a source's schedule | — (Mark done after checking the route) |
| `SOURCE_PAUSED` | Paused | The IEC pauses a source | — |
| `UNASSIGNED_SOURCE` | Unassigned source | A source is approved for you, or comes off a route | It is put on an active route |
| `UNASSIGNED_EXTRA` | Unassigned extra pickup | An extra pickup is added or accepted for a source on no route | Its source is put on an active route |
| `SOURCE_REASSIGNED` | Source moved to you | An area or source moves to you from another supervisor | — |
| `TIME_CLASH` | Time clash | A route is saved and reaches the source after its windows close | The route is saved without the clash, or the source leaves it |
| `OFF_ROUTE` | Off the route | A route is saved and the source adds more than `offRouteKm` | The route is saved without the detour, or the source leaves it |

A source that moves to another supervisor closes the old supervisor's flags about it.

### The driver at a stop

- **Finding the stop.** Compare the phone's location with the pin of each stop on the trip (`trip_stops.lat`, `lng`) within `gpsRadiusM`. Exactly one: open that stop's form. Several: let the driver pick among them. None, or location off or no fix: "You're not at a stop on this trip" with Try again, pick the stop by hand from this trip's stops (send `pickedByHand: true`), or Gate team will enter. GPS is slow on a cold start: show "Finding your location" while waiting.
- **Stops open in turn.** A later stop's Enter collection opens only when the stop before it is done, or GPS shows the driver at that stop. A stop recorded when not there (from the trip list) sends `recordedLater: true`. Always send `lat` and `lng` when the phone has them.
- **The server never refuses for location or order.** It works out `distance_m` from the pin, `gps_matched` (within the radius) and `out_of_order` (an earlier stop still Planned), and shows them to the supervisor and the incharge.
- **Outcomes:**

| Outcome | Screen | The driver gives |
| --- | --- | --- |
| `COLLECTED` | Sorted form or Mixed form, then Pickup successful | Sorted: each item of the source (the stop's `items`, in the order the IEC set) with a quantity in its unit and an optional photo per item. Mixed: one weight (`totalKg`), weighed as the Mixed waste item. At least one material and scale photo |
| `ZERO_KG` | Nothing to collect | A reason: Closed, No material today, Refused to give, Not reachable, Vehicle full, Other (with a note) |
| `GATE` | Gate team will enter | An optional rough weight (`totalKg`). The stop waits for the gate |
| `SOURCE_CANCELLED` | Cancelled by source | A reason: Closed that day, No material, Holiday, Moved to another day, Other (with a note) |

- A note (up to 150 characters) and a voice note (up to a minute) are optional on every outcome.
- **Once sent, read-only.** An entry is never changed afterwards; a second entry for the same stop is refused (`409 ALREADY_RECORDED`: reload). A mistake goes through **Ask supervisor to correct** ("Requests", below).
- **Start trip** shows on the trip card until the trip is started. The driver taps it when leaving the warehouse; it sends the phone's `lat`/`lng` and is queued offline like entries. Today's trips only (`409 NOT_TODAY`). If the driver forgets, the first entry starts the trip.
- After the hand-over the driver records nothing more (`409 WRONG_STATE`). A stop moved off the trip, or a cancelled trip, answers the same: sync.

### Driver not using app

**"Driver not using app"** (Pickup Supervisor, trip card and trip page). Worked out on the phone; the server sends no flag. Show it when all of these hold:

- `pickup_trips.trip_date` is today and `vehicle_kind = 'OWN'` (a contract truck has no driver app);
- the shift started at least 30 minutes ago (`shift_start`);
- the trip is not started: `status = 'PLANNED'` and `started_at` is null.

The banner offers **Call the driver** and **Complete trip for the driver** (`POST /pickup-trips/:id/complete-for-driver`, allowed on a Planned or On route trip). After completion the visited stops show **At gate** and the ones in `notVisited` leave the trip. Once the trip is started (Start trip, or a first stop), the supervisor's trip page shows **Started** with `started_at`.

### At the warehouse

- **Hand over** (the driver; On route only, `409 NOT_STARTED` while Planned): the count by item from the stops (KG items, then pieces), the warehouse, and the **number of bags** (required). After it the trip is read-only for the driver; stops not recorded go to the gate team.
- **Waiting for the warehouse** shows while `weighed_at` is empty; **Received** once it is set: gross, empty and net weight, bags received, "Your count vs the weighbridge" (`driver_kg`, `net_kg`, `variance_kg`, `variance_pct`) and who received it (`weighed_by_name`).
- **A stop at the gate** (the incharge): a stop `AT_GATE` (the driver chose "Gate team will enter", or did not record it), or one the gate already recorded (`entry_method = 'GATE'`, changeable until the trip is approved). Collected: the stop's items and quantities (Sorted) or one weight (Mixed), photos optional; or 0 kg with a reason. Show the driver's rough figure (`driver_estimate_kg`, or `total_kg` before the gate records it). A stop the driver recorded is not editable here (`409 RECORDED_BY_DRIVER`): a change comes as the driver's correction.
- **The weighbridge**: the loaded weight first, the empty weight after unloading, bags received, slip photos, unloading start and end. Each save sends only what was entered; a weight sent without its time takes the server's now. Empty must be less than loaded (`422 EMPTY_NOT_LESS` on `emptyKg`).
- **The difference**: `driver_kg` is the KG lines of the collected entries (pieces never count). Once both weights are in, `variance_kg` = net − `driver_kg` and `variance_pct` is that as a percentage of `driver_kg` (`null` when `driver_kg` is 0). The trip is **flagged** (`variance_flagged`) when the percentage is more than `tolerancePct` either way, or, with `driver_kg` 0, when there is any difference.
- **Being checked**: the server moves the trip to `CHECKING` once every stop is recorded and both weights are in; a gate entry on a Checking trip moves it back to At the warehouse first.
- **Approve** (Checking only, else `409 NOT_READY`): a note is required when flagged (`422 NOTE_REQUIRED`). The entries' weights go into the warehouse's stock (a Mixed entry as the Mixed waste item), the trip is final, and what its sources are owed now counts it.
- **Send back** (Checking only): always with a note. The trip shows the note and is checked again after the next gate entry or weighbridge save (a weighbridge save with nothing changed is enough).

### Issues

- The driver raises one at any time: one or more types (Vehicle breakdown, Accident, Source problem, Other with remarks), remarks up to 150 characters, optionally the trip (one they drive) and the pickup point.
- It goes to the trip's Pickup Supervisor, or to the driver's reporting manager when it is about no trip.

| Issue `status` | Show it as | Next |
| --- | --- | --- |
| `OPEN` | Open | The supervisor resolves it (with a note) or escalates it |
| `ESCALATED` | Escalated: with the pickup point's IEC and the office | The supervisor can still resolve it |
| `RESOLVED` | Resolved, with `resolution_note` | — |

Open and escalated issues count in the supervisor's "Needs your attention". A decision already taken answers `409 WRONG_STATE`: sync.

### Requests

One `outbound_requests` table for everything that needs a yes.

**Who asks whom.**

| Who asks | What | Goes to | Answered |
| --- | --- | --- | --- |
| Pickup Supervisor (Ask the Collection Head) | Vehicle, Labour (a route or trip, dates); Pickup point change, Start, Stop or Pause pickups (a pickup point, dates) | The Collection Head in `me.outbound.collectionHead`: your reporting manager, else your city's Collection Head; none at all: the office | In the web panel |
| IEC (Ask for approval) | Start pickups, Schedule change, Pause pickups, Route or vehicle, Other (a pickup point, a date) | The pickup point's Pickup Supervisor, or the Collection Head (you choose) | The supervisor in the app; the Collection Head in the panel |
| Driver (correction) | A collected stop's items or weight, as they should read, and why | The trip's supervisor | In the app (Approval requests) |

| Request `status` | Show it as |
| --- | --- |
| `WAITING` | Waiting, with who has it (`assignee_*`; `null` = the office), the follow-ups and the last one |
| `APPROVED` | Approved, with `reply`, who decided and when |
| `DECLINED` | Declined, with `reply` (always given) |

- **What each kind needs.** Pickup Supervisor: Vehicle or Labour need their route or trip and a from date (to date optional); Pickup point change, Start, Stop or Pause pickups need one of their pickup points, and a from date except for a pickup point change. IEC Executive: whom to send it to, the pickup point (registered or looked after by them) and a from date. Driver: the entry and the correction. Every request has details (up to 500 characters). Missing: `422 REQUIRED` naming the field.
- **What approval does.** An approved pause is added to the pickup point by the server. An approved correction replaces the stop's record (the old figures kept as `previous`) and a trip being checked at the warehouse is checked again. Every other kind is only answered: the approver makes the change (routes, vans, labour, starting or stopping a pickup point). The reply shows on the request.
- **Corrections** (driver): only a collected stop the driver recorded (`422 NOT_CORRECTABLE`), only one waiting per stop (`409 ALREADY_ASKED`), and only until the warehouse approves the trip (`409 TRIP_APPROVED`, also when the supervisor decides after it). A Sorted stop sends every item as it should read; a Mixed stop the weight. Show before → after per item (`previous`, `proposed`). While it waits the stop shows "Correction requested".
- **A pause asked for** starts today or later (`422 DATE_PASSED`). An IEC asking its supervisor about a pickup point that has none: `422 NO_SUPERVISOR` (ask the Collection Head).
- **Follow up** once a day on a waiting request (`409 TOO_SOON` otherwise). An IEC's request to a supervisor shows **Escalate** after 3 follow-ups (`409 NOT_YET` before; `409 NOT_ALLOWED` for a request to the Collection Head); it goes to the IEC's reporting manager.
- **Decline** needs a reply. A request already decided answers `409 WRONG_STATE`: sync.
- The supervisor's **Approval requests** list holds the corrections and IEC requests sent to them, together with the extra pickups waiting for them (those are answered with the pickup's accept or decline). Requests from sources come with the Source app later; nothing of the kind arrives yet.

### Cash and what sources are owed

- **Cash in hand** is `me.outbound.cash.balance`; it is never below zero. The book (`supervisor_cash_book`) holds signed lines: + cash received on an approved request, − a payment, each with `balance_after`.
- **Cash requests**: an amount and one reason. `PENDING` (Waiting), then `APPROVED` (with `approved_amount`, which may be less than asked; that amount is added to the cash) or `REJECTED` (with `rejection_reason`). The answer comes as a notification.
- **What a source is owed** (`dues`, one per source) is worked out by the server on every sync, never stored. Per kg: every collected stop of a trip the warehouse approved, valued at the payment terms in force on the stop's day (one rate × kg, or each item's rate × its kg). Fixed: the fixed amount on each payment day (the weekday, or the month date, -1 = the last day) from the version's start to today or the next version. No payment: nothing. `balance` = earned − paid, all time, so an unpaid amount carries over. Sources whose terms were never more than No payment are left out. It moves only after the warehouse approves a trip.
- **Next payment day** is `nextDueOn` (today or later). "Pickup points to pay" filters All and Due today (`nextDueOn` is today); there is no Overdue filter, because the server does not send what is overdue.
- **Paying a source**: one of the supervisor's own pickup points, never more than the cash in hand or what it is owed: check both before queuing (the server refuses the same: `422 NOT_ENOUGH_CASH`, `422 MORE_THAN_DUE`). Cash, UPI or Bank; a reference for UPI and bank (hide it for cash); paid on today or earlier; a receipt photo and a note optional. Until it lands, take a queued payment off the cash in hand and the owed amount shown.

### Help & Support and calls

| Button | Number from | When it shows |
| --- | --- | --- |
| Call the EERL office | `me.outbound.supportPhone` | Only when set |
| Message the office on WhatsApp | `me.outbound.supportWhatsapp` | Only when set |
| Call / Message the supervisor (Driver Home) | `me.supervisor.phone` | When `me.supervisor` is set |
| Call the Collection Head | `me.outbound.collectionHead.phone` | When set |
| Call warehouse (Driver) | `warehouses.in_charge_phone` of the trip's warehouse | When set |
| Call the IEC (Pickup Point Detail) | `outbound_sources.iec_owner_phone` | When set |
| Call the driver (supervisor's trip) | `pickup_trips.driver_phone`, or `rented_driver_phone` for a rented truck | When set |
| Call the person at the pickup point | `contact_phone` on the source, pickup or stop | When set |

Calls open the phone's dialer, and Message opens WhatsApp or SMS: there is no chat in the app.

## Notifications

Outbound notifications work like the fixed-point ones (Offline Data Guide, "Push notifications"): the row arrives in `notifications` through `/bootstrap`, and a push only says "something new, sync now". Each carries `type`, `title`, `body` (ready to show), `deep_link` and `role`. Nobody is told about their own action.

- **Tapped:** sync, mark it read, open `deep_link`. When the record it points at is not on this phone (an IEC's escalated issue: issues are not sent to the IEC), show the notification's words in the list instead.
- **Role:** when `role` is not the active role, offer to switch first. Each notification carries the role of the person it was sent to (Received, Approved and Sent back go to the driver as DRIVER and to the supervisor as PICKUP\_SUPERVISOR).
- **Push channel:** every outbound type below uses `tasks_requests` (high priority, kept for a day for an offline phone), except the three source decisions and the cash decision, which use `approvals_money` (normal, kept 3 days).
- **No notification** when a route edit, a switched-off route or the server's own rules change a driver's trip: the change arrives with the next sync.

| `type` | Title (body) | Who gets it | Opens |
| --- | --- | --- | --- |
| `SOURCE_APPROVED` | Source approved ("Shree Sai Dairy is approved.") | The IEC who registered it | `eerl://outbound-sources/<id>` |
| `SOURCE_REJECTED` | Source not approved ("{source}: {reason}") | The IEC who registered it | `eerl://outbound-sources/<id>` |
| `SOURCE_ASSIGNED` | New source in your area ("{source} ({area}) is yours. Put it on a route."); Source assigned to you, when the admin assigns it later | The Pickup Supervisor | `eerl://outbound-sources/<id>` |
| `PICKUP_REQUESTED` | Extra pickup requested ("{source}, {day}, {window}.") | The source's Pickup Supervisor | `eerl://due-pickups/<id>` |
| `PICKUP_REQUEST_DECIDED` | Extra pickup accepted ("{source}, {day}.") / Extra pickup declined ("{source}, {day}: {reason}") | The IEC who asked | `eerl://due-pickups/<id>` |
| `TRIP_CHANGED` | Trip changed ("{route}, {day}: stops or team changed."); New trip for you ("{route}, {day}."); Stops added ("{route}, {day}: stops moved from {route}."); Trip changed ("…: stops moved to {route}.") | The trip's driver | `eerl://pickup-trips/<id>` |
| `TRIP_CANCELLED` | Trip cancelled ("{route}, {day}: {reason}"); Taken off a trip ("{route}, {day}: someone else drives it.") | The trip's driver; a driver taken off | `eerl://pickup-trips/<id>` |
| `TRIP_STARTED` | Trip started ("{route}, {driver} is on the way.") | The warehouse's incharges | `eerl://pickup-trips/<id>` |
| `TRIP_HANDED_OVER` | Trip at the warehouse ("{route} has handed over with {n} bags.") | The warehouse's incharges; also after Complete for the driver | `eerl://pickup-trips/<id>` |
| `TRIP_RECEIVED` | Received at the warehouse ("{route}: weighbridge net {n} kg.") | The driver and the supervisor | `eerl://pickup-trips/<id>` |
| `TRIP_APPROVED` | Trip approved ("{route} was approved at the warehouse.") | The driver and the supervisor | `eerl://pickup-trips/<id>` |
| `TRIP_SENT_BACK` | Trip sent back ("{route}: {note}") | The driver and the supervisor | `eerl://pickup-trips/<id>` |
| `ISSUE_RAISED` | Issue raised ("{driver}: {types} ({route}).") | The supervisor who handles it | `eerl://trip-issues/<id>` |
| `ISSUE_RESOLVED` | Issue resolved ("{note}") | The driver who raised it | `eerl://trip-issues/<id>` |
| `ISSUE_ESCALATED` | Issue escalated ("{source}: {types}.") | The pickup point's IEC | `eerl://trip-issues/<id>` (not on the IEC's phone) |
| `OUTBOUND_REQUEST_RAISED` | New request ("{name} asks for {kind}."); Request escalated to you ("A request for {kind} had no answer after {n} follow-ups.") | Whoever it goes to | `eerl://outbound-requests/<id>` |
| `OUTBOUND_REQUEST_DECIDED` | Request approved / Request declined ("Your request for {kind} was approved: {reply}") | The asker | `eerl://outbound-requests/<id>` |
| `OUTBOUND_REQUEST_FOLLOWED_UP` | Follow-up on a request ("Still waiting for your answer on {kind} (follow-up {n}).") | Whoever has it | `eerl://outbound-requests/<id>` |
| `CASH_REQUEST_DECIDED` | Cash approved ("₹5,000 added to your cash.") / Cash request rejected ("₹5,000: {reason}") | The Pickup Supervisor | `eerl://supervisor-cash-requests/<id>` |

`{route}` is the route's name (the trip number when there is none); `{kind}` reads "a vehicle", "labour", "a pickup point change", "starting pickups", "stopping pickups", "a pause", "a schedule change", "a route or vehicle change", "an approval" or "a correction".

## Pickup Supervisor screens

Screen names are the Figma frame names. The table is the summary; each module below says what its screens show and from where, what each action sends, and the empty and error states. The SQL behind each screen is in the SQLite doc, "Pickup Supervisor screens".

Pickup Supervisor. "Tables" are SQLite tables; calls marked online need the network, every other write is queued.

| Module | Screens | Reads | Writes and calls |
| --- | --- | --- | --- |
| Home Dashboard | Home (Today, Yesterday), Side drawer | `pickup_trips`, `trip_stops`, `outbound_requests`, `trip_issues`, `supervisor_flags`, `outbound_sources`, `areas` | — |
| Home Dashboard | Collection Report, Pick Dates, Stops to Look At, PDF Preview | — | `GET /collection-report` (online), `&format=pdf` |
| Home Dashboard | Approval Requests, Decline a Request, Request Approved | `outbound_requests` (to me), `due_pickups` (`REQUESTED`) | `POST /outbound-requests/{id}/decide`, `POST /due-pickups/{id}/accept` \| `/decline` |
| Home Dashboard | My Requests to the Collection Head, Ask the Collection Head | `outbound_requests` (mine) | `PUT /outbound-requests/{id}`, `/follow-up`, `/escalate` |
| Home Dashboard | My Pickup Points, Pickup Point Detail | `outbound_sources`, `pickup_schedules`, `source_payment_terms`, `due_pickups`, `trip_stops`, `outbound_requests`, `me.outbound.cash` | — |
| Unassigned sources | Sources, Extra Pickups, Detail (Sorted, Mixed, Extra), Empty | `outbound_sources` on no active route, `due_pickups` (`EXTRA`, `DUE`, no trip) | — |
| Unassigned sources | Add to a route, Assigned | `pickup_routes`, the route estimate | `PUT /pickup-routes/{id}` (warnings back) |
| Issues | Issues, Overview (Open, Resolved, Escalated), Mark Resolved, Escalate | `trip_issues`, `outbound_sources.iec_owner_name` | `POST /trip-issues/{id}/resolve` (note ≤ 150) \| `/escalate` |
| Routes 1–2 | Your routes, Add a new route (steps 1–2, vehicle sheet, summary) | `pickup_routes`, `warehouses`, `warehouse_shifts`, `outbound_vehicles`, `warehouse_drivers`, `warehouse_labour` | `PUT /pickup-routes/{id}`; a hired truck sends `rented` (number, transporter, driver name and phone, capacity), no `driverId` |
| Routes 1–2 | Add New Driver, Add New Labour, Deactivate | — | `PUT /warehouse-drivers/{id}` \| `/warehouse-labour/{id}`, `/deactivate` (online) |
| Route 3 | Trips plan: Today, Tomorrow | `pickup_trips`, `trip_stops` | — |
| Route 3 | This week, Expected day, Pick dates, Chosen dates, No trips | — | `GET /trips-plan` (online) |
| Route 4 | Trip lists (On route, Planned, Approved), Map, Next 7 Days, Actions sheet | `pickup_trips`, `trip_stops`, `due_pickups`, `source_pauses` | — |
| Route 6 | Stop details (Collected, at the gate, 0 kg, Missed, Cancelled, Inactive), Add an Extra Pickup | `trip_stops`, `due_pickups`, `outbound_sources` | `PUT /due-pickups/{id}` (extra) |
| Route 7 | Pending stop, Next stop, Skip | `trip_stops` | `POST /due-pickups/{id}/skip` |
| Route 8 | Change Driver or Labour, Move Stops, Stops Moved | `pickup_trips`, `GET /pickup-trips/{id}/free-staff` (online; offline from `pickup_trips`) | `POST /pickup-trips/{id}/change-for-today` \| `/move-stops` |
| Route 9 | Driver not using app, Complete Trip for the Driver | `pickup_trips` (`started_at` NULL 30 min after the shift starts) | `POST /pickup-trips/{id}/complete-for-driver` |
| Route 10 | Cancel trip, Switch off, Switch on | `pickup_trips`, `pickup_routes` | `POST /pickup-trips/{id}/cancel`, `POST /pickup-routes/{id}/deactivate` \| `/activate` |
| Drivers & labour | Directory, Information, Add, Edit, Deactivate, Reactivate | `warehouse_drivers`, `warehouse_labour` | `PUT /warehouse-drivers/{id}` \| `/warehouse-labour/{id}`, `/deactivate` \| `/activate` (online) |
| Flags | Flags, each flag's detail, Flag marked done, Empty | `supervisor_flags`, `outbound_sources`, `pickup_schedules`, `source_pauses`, `due_pickups`, the route estimate | `POST /supervisor-flags/{id}/done` |
| Profile | Profile, Sync, Logout, Notifications, Help & Support | `notifications`, the outbox, `sync_meta` | — |
| Cash & Payments | Cash & Payments (both tabs), Request cash, Pickup points to pay, Pay (Cash, UPI), Payment recorded | `me.outbound.cash`, `supervisor_cash_book`, `supervisor_cash_requests`, `source_payments`, `source_payment_terms` | `PUT /supervisor-cash-requests/{id}`, `PUT /source-payments/{id}` |

### Home Dashboard

- **Home (Today, Yesterday).** *Needs your attention*: Approvals (waiting requests sent to me plus extra pickups `REQUESTED`), Issues (open and escalated), Flags (open), My requests (my waiting ones); each opens its list. *Collection summary* with Today, Yesterday, Week and Month chips: kg and pieces collected and the stops by outcome, worked out offline from `pickup_trips` and `trip_stops`; it can be hidden. Today's trips, each with Call driver. Pickup points by category (`pickup_category`). **View full report** opens the Collection Report; **Call the Collection Head** uses `me.outbound.collectionHead` (hidden when null).
- **Side drawer**: the menu from `modules`, plus Cash & payments; "Extra pickup requests" opens the Extra pickups tab of Unassigned sources.
- **Collection Report, Pick Dates, Stops to Look At, Collection Report · PDF Preview.** Online only: `GET /collection-report?from=&to=` (IST days, at most 366). It counts the supervisor's visits due in the period, except skipped, declined, requested and system-cancelled ones: `totals` (`kg`, `pcs`, `stopsDue` = collected + 0 kg + missed + cancelled by source + at the gate + pending, and `trips`), `byRoute` (heaviest first: vehicle kind and vehicle, trips, stops, collected, kg), `byCategory` and `stopsToLookAt` (tabs Missed, Cancelled, 0 kg; each card opens its stop detail). Show a missed stop's `reason` in these words: `NOT_RECORDED` "Not recorded by the driver or the gate", `TRIP_CANCELLED` "Its trip was cancelled", `TAKEN_OFF` "Taken off the trip and not put on another", `NO_TRIP` "No route that day"; a cancelled or 0 kg one shows its reason from `detail`. **Share**: the same call with `&format=pdf` answers a one-page A4 PDF (not JSON): save it to a temporary file, show it in a PDF viewer (PDF Preview), and share the file through the share sheet. Offline: "Needs a connection"; the Home summary still shows. `422 INVALID_PERIOD`: the first day is after the last, or more than 366 days.
- **Approval Requests, Decline a Request, Request Approved.** Corrections (before → after per item, from `previous` and `proposed`) and IEC requests sent to me (`outbound_requests`), together with extra pickups waiting (`due_pickups` `REQUESTED`). Approve: `POST /outbound-requests/{id}/decide` (`APPROVE`), or `POST /due-pickups/{id}/accept` for an extra pickup, which then opens "Assign source to a route" when its source is on no route. Decline: a reply is required (`DECLINE` with `reply`, or `/decline` with `reason`). The Done tab shows decided ones with their reply. Empty when nothing waits.
- **My Requests to the Collection Head, Ask the Collection Head.** Tabs All, Waiting, Approved, Declined; each card shows who has it, the follow-ups and the reply, and **Follow up** once a day on a waiting one. The form groups the kinds (for a trip: Vehicle, Labour; for a pickup point: change, start, stop, pause), a For list (the route or trip, or the pickup point), the dates (Pick dates) and details; `PUT /outbound-requests/{id}`. The form says who gets it ("Goes to Arvind Desai (Collection Head)") from `me.outbound.collectionHead`. Also opened from a trip's actions.
- **My Pickup Points, Pickup Point Detail.** The supervisor's sources (`outbound_sources`) grouped by area, with the schedule summary in force today, category, route (or "Not on a route"), the last pickup and the missed count. Detail: the pickup point card, the schedule and payment terms in force, the next pickups (`due_pickups`), recent stops with their outcome (`trip_stops`), waiting requests, a Payment card (owed, next payment day, Pay, from `me.outbound.cash.dues`), Call the person, and Call the IEC (`iec_owner_phone`).

### Unassigned sources

- **Sources, Extra Pickups, Detail (Sorted, Mixed, Extra), Empty.** Sources tab: the supervisor's Active and Paused sources on no active route. Extra Pickups tab: Due pickups of today and tomorrow on no trip (an extra one shows "Extra"). The detail shows the pickup point, schedule, Sorted items or Mixed, and the person there. Empty: every pickup point is on a route (the Empty frame).
- **Add to a route, Assigned.** The supervisor's routes of that warehouse (`pickup_routes`). Before saving, run the route estimate with the new pickup point last and show Time clash or Off the route on the route's card. Save sends the whole route with the source added at the end (`PUT /pickup-routes/{id}`); show the answer's `warnings`, then the Assigned popup. An unassigned extra pickup goes on a trip with **Add to today's trip** (Change for today with the pickup added at the end).

### Issues

- **Issues, Issue Overview (Open, Resolved, Escalated), Mark Resolved, Escalate.** `trip_issues` the supervisor handles, by status tab. The overview shows the types and the driver's note, the driver and their phone, the trip (route, vehicle) and the pickup point, when it was raised, and the pickup point's IEC (`outbound_sources.iec_owner_name`). **Mark resolved** (Open or Escalated) asks what was done, up to 150 characters: `POST /trip-issues/{id}/resolve`; only the driver is told. **Escalate** (Open only): `POST /trip-issues/{id}/escalate`; the IEC is told and the office sees it. Toasts "Issue Resolved!" and "Issue Escalated!". A tab with no issues shows its empty state.

### Routes 1–10

- **Your routes (Routes 1–2).** One card per route (`pickup_routes`): name; warehouse · shift; our van or the rented truck with the Own or Contract chip; driver; labourer; how many sources; Off when switched off. With no routes, only Add a new route shows.
- **Add a new route (steps 1–2, vehicle sheet, summary).** Step 1: name, warehouse (`warehouses`), shift (`warehouse_shifts` of that warehouse). Step 2: the vehicle sheet offers our vans (`outbound_vehicles`) with a driver (`warehouse_drivers`) of that warehouse, or a hired truck typed in (number, transporter, driver name and phone, capacity in kg) with no app driver; a labourer (optional, `warehouse_labour`); the sources in order (drag to reorder). Summary, then **Save route**: `PUT /pickup-routes/{id}` with the whole route; show the `warnings`. Add New Driver and Add New Labour open from the sheet (online).
- **Trips plan (Route 3).** Today and Tomorrow from `pickup_trips` (offline). This week, an Expected day, Pick dates and Chosen dates call `GET /trips-plan?from=&to=` (today or later, up to 14 days ahead, at most 31 days; online). Each day: `totals` (trips, stops, own, contract, extra pickups, paused sources), `holidays` and `trips`. A day after tomorrow has no trips yet: each active route with pickups that day comes back as `status: EXPECTED` with no `tripId` ("Trips are made the day before"). A warehouse holiday: "No trips · warehouse holiday". A card opens the Planned trip's details, or the route's next 7 days for an expected one. `422 INVALID_PERIOD`: a past day, beyond the horizon, or more than 31 days.
- **Trip lists (On route, Planned, Approved), Trip details, Next 7 Days, Actions sheet (Route 4).** Trip details: the team, the status with "Started 8:05 am", "Changed for today" with its reason, the stops with their states and filter chips, and on a trip at or past the warehouse an "At the warehouse" card (weighbridge, difference, bags, approved by). Next 7 days: the route's pickup points with their next visits (`due_pickups`). The "⋮" sheet: on a Planned trip, Change driver or labour, Move stops, Cancel this trip, Switch off the route, Ask the Collection Head; on an On route trip, Complete trip for the driver and Ask the Collection Head; none on an approved trip. Add sources only on Planned and Next 7 days. A List / Map switch opens the map:

**The trip map** (Pickup Supervisor, the trip's *Map* tab). Everything it needs is already on the phone; nothing new comes from the server.

- **Map:** `google_maps_flutter` (a Maps API key for Android and iOS) or `flutter_map` with a paid tile provider. Without the internet the tiles are blank, but the pins and lines still draw.
- **Pins:** one per stop from `trip_stops.lat` / `lng` (the pickup point's pin), numbered by `stop_order`, coloured by the state the list already shows (Collected, 0 kg, Cancelled by source, Pending, Paused or ended, Next stop). The warehouse pin comes from `warehouses.lat` / `lng`. Tapping a pin opens the same stop screen as the list.
- **Lines:** straight lines between the pins in stop order, not roads (road routes would need Google's paid Directions API). Solid from the warehouse through the stops already recorded; dashed from the next stop through the rest and back to the warehouse.
- **"1.2 km from the last stop":** the straight-line distance from the pin of the last recorded stop (the warehouse before the first) to the next stop's pin, worked out on the phone. The driver's live position is not tracked, so never say "away".

* **Stop details: Collected, At the gate, 0 kg, Missed, Cancelled, Inactive; Add an Extra Pickup (Route 6).** Every stop screen is the pickup point card (name and category tag, address, schedule, route, the person there, the IEC), an outcome card coloured by result, then actions. Collected shows the record: items and quantities or the Mixed weight, photos, note, voice note, "GPS location · 18 m from the pickup point" with View on map (`entry_lat`, `entry_lng`, `distance_m`), "Location not matched" when picked by hand, Recorded later, Out of order, "Data entry … · 2:08 pm" from `entered_at` (`recorded_at` is the phone's or the slip's time), and the tag Entered in the app or Entered at gate. Missed shows why. **Add an Extra Pickup** (from 0 kg, Missed and Cancelled): date, window, expected kg, note; `PUT /due-pickups/{id}`.
* **Pending stop, Next stop, Skip (Route 7).** On a Planned trip, **Skip this pickup** offers the seven reasons as tick boxes: `POST /due-pickups/{id}/skip`; the toast shows on the trip without the stop. On a started trip there is no Skip: "The trip has started. The driver records what happens at this stop."
* **Change Driver or Labour, Move Stops, Stops Moved (Route 8).** Two dropdowns (free first, busy greyed: "Who is free" above) and the reason when the team changes; Save sends Change for today and returns to the trip with a "changed for today" toast. Move stops: tick the stops, choose another Planned trip of the day, a reason (Absent, Breakdown, Vehicle not available, Other); `POST /pickup-trips/{id}/move-stops`; the Stops moved popup.
* **Driver not using app, Complete Trip for the Driver (Route 9).** The banner by the rule above, with Call the driver. Complete: confirm the call, tick the stops the vehicle visited (the others are sent as `notVisited`), a note (up to 500 characters); `POST /pickup-trips/{id}/complete-for-driver`. The trip then shows "Completed by supervisor · gate entry pending".
* **Cancel trip, Switch off, Switch on (Route 10).** Cancel this trip (that day only, a reason required): `POST /pickup-trips/{id}/cancel`, then the cancelled trip. Switch off the route: `POST /pickup-routes/{id}/deactivate` and its popup; the switched-off route shows that its pickup points stay on it. Switch on: `/activate`.

### Drivers & labour

- **Directory, Information, Add, Edit, Deactivate, Reactivate.** Drivers (`warehouse_drivers`) and Labour (`warehouse_labour`) tabs, each person with their photo (initials when none), name, code under it (`number`, e.g. SUR-DRV-0012) and phone. The form: warehouse, name, phone (a driver's is their login), ID number (Aadhaar or Voter ID), and two separate photo fields, profile photo and ID proof (upload first, purpose `WAREHOUSE_PERSON`). Every write here is online: `PUT /warehouse-drivers/{id}` or `/warehouse-labour/{id}`, `POST …/deactivate` or `/activate` with `warehouseId`. A new driver gets a login with the supervisor as reporting manager, so their login code comes to the supervisor.
- Errors: `409 PHONE_IN_USE` ("Someone already has this mobile. Ask the admin."), `409 NOT_A_DRIVER` (the person has other roles), `409 NO_DRIVER_ROLE`, `409 DUPLICATE_NAME` (labour), `422 OTHER_WAREHOUSE`, `WAREHOUSE_CODE_MISSING`. Deactivate is refused while the person is on an active route or a coming trip there: `409 IN_USE`, whose `details` name the routes; show "Can't deactivate yet" with them. Deactivating takes a driver off that warehouse; with no warehouse left their app stops signing in.
  - **Deactivated Driver Directory, Deactivated Driver Information, Reactivate.** Drivers with `is_active = 0`, under the warehouse they left. Reactivate sends `POST /warehouse-drivers/{id}/activate` with that `warehouseId` (online); the row comes back with `is_active = 1` on the next sync.

### Flags

- **Flags, each flag's detail, Flag marked done, Empty.** The list (`supervisor_flags`, open first, newest first) names the pickup point, with an icon per type. Each detail has the type as its title, the pickup point, "What happened" (the `message`), "What to do", a main action and **Mark done** (`POST /supervisor-flags/{id}/done`). Time clash and Off the route show the route, the pickup window and the arrival from the route estimate steps. Main actions: Unassigned source, Add to a route; Unassigned extra pickup, Add to today's trip; Schedule changed, Paused and Source moved to you, open the route. No open flags: the Empty frame.

### Profile

- **Profile, Sync, Logout, Notifications, Help & Support.** Profile from `me.user`. Sync shows the outbox and the last sync (`sync_meta`). Logout warns when the outbox is not empty ("3 changes not sent yet: sync first"). Notifications: the supervisor's list. Help & Support: the buttons in "Help & Support and calls". There is no End My Day for outbound roles.

### Cash & Payments

- **Cash & Payments (Cash and Payments tabs).** Cash in hand (`me.outbound.cash.balance`), the pickup points to pay (dues with a balance), and the cash requests (`supervisor_cash_requests`): Waiting, Approved (an approval for less shows the approved amount), Rejected (with the office's reason). The Payments tab lists `source_payments`.
- **Request cash** (amount, one reason up to 300 characters): `PUT /supervisor-cash-requests/{id}`, then its popup.
- **Pickup points to pay** (All, Due today): each with the amount owed and the next payment day. **Pay (Cash, UPI)**: amount, method, reference (hidden for cash), paid on (a date field with a calendar, today or earlier), receipt photo, note: `PUT /source-payments/{id}`, then the Payment recorded popup and the list after the payment.

## Driver screens

The driver's phone holds only their trips (`pickup_trips`, `trip_stops`), their issues and correction requests, the reference tables of their warehouse, `me.supervisor` and `me.outbound`. The SQL is in the SQLite doc, "Driver screens".

Driver.

| Module | Screens | Reads | Writes and calls |
| --- | --- | --- | --- |
| Home | Home (trip not started, later in the day, no trip, offline) | `pickup_trips`, `trip_stops`, `me.supervisor`, the outbox | `POST /pickup-trips/{id}/start` (Start trip) |
| Trip | Trip stops, Finding your location, Nearby, Several stops nearby, Not at a stop, Location is off | `trip_stops`, `outbound_gps_radius_m` | — |
| Trip | Stop detail, Sorted and Mixed forms, Nothing collected, Gate team will enter, Pickup successful | `trip_stops`, `items` | `PUT /pickup-entries/{id}` |
| Trip | Collection record, Ask supervisor to correct, Correction sent | `trip_stops` | `PUT /outbound-requests/{id}` (`ENTRY_CORRECTION`) |
| Trip | Raise an issue | — | `PUT /trip-issues/{id}` |
| Warehouse | Trip summary, Hand over, Waiting, Received | `pickup_trips`, `trip_stops`, `warehouses` (Call warehouse) | `POST /pickup-trips/{id}/hand-over` |
| Profile | Profile, Sync, Logout | `sync_meta` (`outbound_driver_code`), the outbox | — |

### Home

- **Home (trip not started, later in the day, no trip, offline).** Today's trips, the day's totals above them. Each trip card: shift time, stops, vehicle, destination warehouse, counts (collected, pending, 0 kg, cancelled) and the kg so far. The current trip shows in full with its next stop (**Enter collection**) and the stops after it; earlier trips shrink to one line (delivered, with the net weight), later ones too (starts at). A trip not started shows **Start trip** (`POST /pickup-trips/{id}/start` with `lat`/`lng`, queued). Call and Message the supervisor from `me.supervisor`. No trip today: the no-trip state (tomorrow's trips arrive a day ahead). Offline: a banner and the outbox count; everything still works.
- A trip changed or cancelled by the supervisor updates on the next sync (a push says so). A trip given to another driver leaves this phone through the scope reset.

### Trip

- **Trip stops.** The stops in order: name, address, window, the person there with Call, the state. Opening the trip or tapping Enter collection starts the stop search ("The driver at a stop").
- **Finding your location, Nearby, Several stops nearby, Not at a stop, Location is off.** Finding: while the phone gets a fix. Nearby: one stop matched, its form opens. Several: pick one. Not at a stop: Try again, pick the stop by hand (`pickedByHand`), or Gate team will enter. Location is off: open the settings, or pick by hand.
- **Stop detail, Sorted and Mixed forms, Nothing collected, Gate team will enter, Pickup successful.** Sorted lists the stop's items (`items`, in the IEC's order) with their unit; Mixed takes one weight (blocked with "Ask the office" while `mixedItemId` is null). At least one material and scale photo for Collected; a note (150 characters) and a voice note (a minute) optional everywhere. Save sends `PUT /pickup-entries/{id}` (queued, app-made id). Pickup successful shows the next stop with **Go to next stop**; after the last stop it points to the trip's warehouse and the trip summary.
- **Collection record, Ask supervisor to correct, Correction sent.** A saved stop is read-only: items, weights, time, photos. Until the warehouse approves the trip, **Ask supervisor to correct** sends what it should read (every item, or the weight) with a note: `PUT /outbound-requests/{id}` (`ENTRY_CORRECTION`). The stop then shows "Correction requested"; only one can wait per stop.
- **Raise an issue.** One or more types, remarks (150 characters, required with Other), the trip and the pickup point when it is about one: `PUT /trip-issues/{id}`. The Issues menu lists the driver's issues with their status and the supervisor's resolution note.

### Warehouse

- **Trip summary.** Collected, 0 kg, cancelled and to enter at the gate; totals by item (KG items, then pieces); **Reached warehouse**.
- **Hand over.** The count by item, the warehouse, **Number of bags** (required): `POST /pickup-trips/{id}/hand-over`. **Waiting** while `weighed_at` is empty; **Received** after it ("At the warehouse" rules). **Call warehouse** dials `warehouses.in_charge_phone` (hidden when null).
- Errors: `409 NOT_STARTED` (nothing recorded yet: the trip is still Planned), `409 WRONG_STATE` (cancelled or already handed over: sync).

### Profile

- **Profile, Sync, Logout.** Name, phone and photo from `me.user`, the driver code (`me.outbound.driverCode`), the warehouse (`my_warehouses` with `warehouses`). Sync and Logout as for every role.

## IEC Executive screens

The IEC's phone holds their leads, the sources they registered or look after (with their schedules, payment terms and pauses), those sources' pickups, their requests, and the reference tables (warehouses, cities, every active area, source categories). It holds no routes or trips. The SQL is in the SQLite doc, "IEC Executive screens".

| Module | Screens | Reads | Writes and calls |
| --- | --- | --- | --- |
| Home | IEC-M01 Home, Side drawer, Inbox | `source_leads`, `outbound_sources`, `due_pickups`, `outbound_requests`, `me.outbound.collectionHead` | — |
| Log Visit | Leads list, lead form, visit log | `source_leads`, `lead_visits`, `source_categories`, `areas` | `PUT /source-leads/{id}`, `PUT /source-leads/{id}/visits/{visitId}` |
| Registration | Registration forms (regular, one-time, event), Registrations list, Registration details | `outbound_sources` and children, `items`, `warehouses`, `areas`, `source_categories` | `PUT /outbound-sources/{id}`; agreement upload (online); `POST /schedules/preview` (online) |
| Registration | Source detail, Cancel a pickup, Pickup cancelled; schedule change, pause, payment terms, extra pickup | `outbound_sources`, `pickup_schedules`, `source_pauses`, `source_payment_terms`, `due_pickups`, `outbound_requests` | `PUT …/schedules/{scheduleId}`, `PUT /source-pauses/{id}`, `POST /source-pauses/{id}/cancel`, `PUT …/payment-terms/{termsId}`, `PUT /due-pickups/{id}`, `POST /due-pickups/{id}/cancel-by-source` |
| My pickup points | My pickup points | `outbound_sources` (`iec_owner_id` = me), `due_pickups` | — |
| Requests | Ask for approval, My requests | `outbound_requests`, `outbound_sources` | `PUT /outbound-requests/{id}`, `/follow-up`, `/escalate` |
| Profile | Profile, Sync, Logout, Notifications, Help & Support | `notifications`, the outbox, `sync_meta` | — |

### Home

- **IEC-M01 Home.** The day's visits and leads, registrations waiting and rejected, the Inbox card, the Collection Head with Call (`me.outbound.collectionHead`), and Add lead (opens the lead form).
- **Inbox** (To approve, Complaints, Escalations, Done) holds the source's own requests (changes to the person there, the address and pin, the schedule, pauses), complaints and escalations. They come from the Source app, which is not built yet: the server sends nothing for them, so these tabs show their empty states. The Inbox card's "missed pickups at your sources" count works now: Missed pickups (`due_pickups`) of the IEC's sources.

### Log Visit

- **Lead form**: name (required), type (`source_categories`), the person and phone, pin, address, area, notes, photos (`LEAD_PHOTO`), status: `PUT /source-leads/{id}`, saved offline.
- **Visit log**: when, where the lead stands now (New, Follow-up, Interested, Not interested), a note, the next follow-up date: `PUT /source-leads/{id}/visits/{visitId}`. **Register as source** carries the lead's id (`leadId`).

### Registration

- **Registration forms**, in steps: details and type; **Person at the pickup point** (name, role, mobile, email: they will log in to the Source app with either); **Location** (the pin on the gate, Use current location, the area from the pin with Change); **Material**: Sorted (pick the items, KG items only, in the order the driver's form will list them) or Mixed; the default warehouse; the **schedule** (Daily, Weekdays, Alternate days, Weekly, Bi-weekly, Monthly, On call, One time, with "Category: … (from the schedule)", up to 4 time windows, the holiday rule, extra pickups allowed); an **event point** needs an end date at most 60 days after the start; **payment terms** with their read-back sentence at the bottom ("Paid ₹12 per kg, every Monday, in cash"); an optional **agreement** (end date, then the file); the phone of the person who will use the Source app. Submit sends `PUT /outbound-sources/{id}` and the source shows Waiting for approval.
- Presets to patterns: Daily `DAILY`; Weekdays `WEEKLY` Monday to Saturday; Alternate days `EVERY_N_DAYS` 2; Weekly `WEEKLY` with the days; Bi-weekly `EVERY_N_WEEKS` 2 with the days; Monthly `MONTHLY_DATES` (or `MONTHLY_NTH_WEEKDAY` for "2nd Saturday"); On call `ON_DEMAND` (no windows); One time `ONE_TIME`.
- **Registrations list, Registration details**: each source with its status; a rejected one shows the reason and Edit and resubmit (the same id).
- **Source detail**: status, category, material, area, schedule summary, agreement till, the person there and the Pickup Supervisor with Call (`pickup_supervisor_name`, `pickup_supervisor_phone`), recent pickups with their outcome (collected, 0 kg, missed, cancelled, from `due_pickups`), waiting requests. The IEC's phone has no trips, so route, vehicle and kg collected are not on it: leave those lines out until the server sends them. Actions: change the schedule, pause or end a pause, new payment terms, ask for an extra pickup (hidden when the schedule takes none), cancel a pickup.
- **Cancel a pickup, Pickup cancelled**: which pickup (the source's Requested, Due or Planned ones, today or later), the reason, a note: `POST /due-pickups/{id}/cancel-by-source`; the popup. The supervisor and the driver see it as Cancelled by source.
- Errors show on their fields (`422 INVALID_SOURCE` with `details`); an approved source's locked fields are read-only.

### My pickup points

- The sources the IEC looks after, each with status, category, material, area, the last pickup and what needs attention (a waiting request, a missed pickup); each opens the Source detail. Call the person there and its Pickup Supervisor from each card.

### Requests

- **Ask for approval**: to the Pickup Supervisor or the Collection Head; what for (Start pickups, Schedule change, Pause pickups, Route or vehicle, Other), the pickup point, from when, details: `PUT /outbound-requests/{id}`.
- **My requests**: tabs All, Waiting, Approved, Declined; follow-ups and the reply on each. Follow up once a day; **Escalate** after 3 follow-ups on a request to a supervisor.

### Profile

- **Profile, Sync, Logout, Notifications, Help & Support**, as for every role. The server has no End My Day for outbound roles.

## Warehouse Incharge screens

The incharge's screens are not drawn in Figma yet. The server and the phone data are ready; this is what they support, by menu entry. The incharge's phone holds the trips to their warehouses (`pickup_trips`, `trip_stops`) and their warehouses' reference rows. The SQL is in the SQLite doc, "Warehouse Incharge screens".

| Menu entry | Screen | Reads | Writes |
| --- | --- | --- | --- |
| `OB_ARRIVING` Arriving Today | Trips: Arriving (today's, Planned or On route), At the warehouse (At the warehouse or Being checked, with the stops at the gate counted) | `pickup_trips`, `trip_stops`, `my_warehouses` | — |
| `OB_ARRIVING` | Trip at the warehouse: the driver's count by item, bags, every stop with its state, location and order notes | `pickup_trips`, `trip_stops` | — |
| `OB_ARRIVING` | A stop at the gate | `trip_stops` (items, `driver_estimate_kg`) | `PUT /pickup-trips/{id}/gate-entries/{duePickupId}` |
| `OB_ARRIVING` | Weighbridge | `pickup_trips` | `PUT /pickup-trips/{id}/weighbridge` |
| `OB_ARRIVING` | Check and approve (at Being checked): the driver's count against the net, the difference in kg and %, flagged above `me.outbound.tolerancePct` | `pickup_trips`, `trip_stops`, `me.outbound` | `POST /pickup-trips/{id}/approve`, `/send-back` |
| `OB_APPROVED_TRIPS` Approved Trips | Approved trips: net, difference, approved by and when, the note | `pickup_trips` | — |

- Pushes: Trip started (a trip to their warehouse is on the way) and Trip at the warehouse (handed over, or completed by the supervisor).
- A sent-back trip shows its note until it is checked again; an approved trip is read-only.

## Validation rules

Every field of every outbound write, as the server checks it. Check the same on the phone before queuing, and show a refusal's `details[].message` on the field `details[].field` names.

**Shared rules.** Bodies are strict: an unknown key is `400 VALIDATION_ERROR`. `null` on an optional field means "not sent". Ids are uuids. A **day** is `YYYY-MM-DD`, an IST calendar day; "today" is today in IST. A **clock** time is 24-hour `HH:MM`. A **time** is ISO 8601 (`2026-11-24T09:12:00Z` or with an offset). A **phone** is 10 to 15 digits, an optional leading +, spaces allowed (a driver's login phone is an Indian mobile: `9876543210` or `+919876543210`). **Money** and **weights** take at most 2 decimals. Text is trimmed; "1–255" counts characters after trimming. Any call can also answer `401`, `403 FORBIDDEN` (the role may not do this), `409 NO_WAREHOUSE_ASSIGNED` and `500` (safe to retry).

### IEC Executive

#### `PUT /source-leads/{id}`

| Field | Required | Rule |
| --- | --- | --- |
| `name` | Yes | Text, 1–255 |
| `categoryId` | No | A row of `source_categories` (`UNKNOWN_CATEGORY`) |
| `contactName` | No | Text, 1–255 |
| `contactPhone` | No | Phone |
| `lat`, `lng` | No | Both or neither; −90 to 90, −180 to 180 |
| `address` | No | Text, 1–500 |
| `areaId` | No | A row of `areas` (`UNKNOWN_AREA`) |
| `notes` | No | Text, up to 2000 |
| `photoUrls` | No | Up to 10 URLs, your `LEAD_PHOTO` uploads |
| `status` | No | `NEW`, `FOLLOW_UP`, `INTERESTED`, `NOT_INTERESTED` |
| `nextFollowUpOn` | No | Day |

Refused: `422 INVALID_LEAD` (`details`: `UNKNOWN_CATEGORY`, `UNKNOWN_AREA`, `LEAD_CONVERTED`, `PHOTO_NOT_ISSUED`), `404` another IEC's lead.

#### `PUT /source-leads/{id}/visits/{visitId}`

| Field | Required | Rule |
| --- | --- | --- |
| `visitedAt` | Yes | Time (the phone's) |
| `outcome` | Yes | `NEW`, `FOLLOW_UP`, `INTERESTED`, `NOT_INTERESTED` |
| `note` | No | Text, up to 2000 |
| `nextFollowUpOn` | No | Day |

Refused: `404` another IEC's lead, `409 ID_IN_USE` (the visit id is another lead's).

#### `PUT /outbound-sources/{id}`

| Field | Required | Rule |
| --- | --- | --- |
| `name` | Yes | Text, 1–255 |
| `categoryId` | Yes | A type for pickup points (`UNKNOWN_CATEGORY`) |
| `contactName` | No | Text, 1–255: the person at the pickup point |
| `contactPhone` | No | Phone |
| `contactRole` | No | Text, 1–100 (Owner, Manager, Watchman…) |
| `contactEmail` | No | An email, up to 255; stored lower-case |
| `address` | No | Text, 1–500 |
| `lat`, `lng` | Yes | −90 to 90, −180 to 180 |
| `areaId` | Yes | An active area (`UNKNOWN_AREA`) |
| `warehouseId` | Yes | An active warehouse with a code (`WAREHOUSE_INACTIVE`, `WAREHOUSE_CODE_MISSING`) |
| `materialMode` | Yes | `SORTED` or `MIXED` |
| `itemIds` | Sorted: yes. Mixed: leave out | 1–50, each once, active items weighed in KG, in the pickup form's order (`REQUIRED`, `DUPLICATE`, `UNKNOWN_ITEM`, `ITEM_INACTIVE`, `NOT_WEIGHED`; on a Mixed source `NOT_FOR_MIXED`) |
| `isEvent` | No | true for a temporary event point |
| `notes` | No | Text, up to 2000 |
| `photoUrls` | No | Up to 10 URLs, your `SOURCE_PHOTO` uploads |
| `sourceUserPhone` | No | Phone: who will use the Source app |
| `schedule` | Yes | The schedule below |
| `paymentTerms` | Yes | The payment terms below |
| `leadId` | No | One of your leads, not yet converted (`UNKNOWN_LEAD`, `LEAD_CONVERTED`) |
| `agreement` | No | `{id, endsOn}`: an app-made id and a day, today or later (`ENDS_IN_PAST`) |

**The schedule** (also the body of `PUT /outbound-sources/{id}/schedules/{scheduleId}` without `id`, and of the preview):

| Field | Required | Rule |
| --- | --- | --- |
| `id` | Yes | App-made; a new id is a new version |
| `pattern` | Yes | `ONE_TIME`, `DAILY`, `WEEKLY`, `EVERY_N_DAYS`, `EVERY_N_WEEKS`, `MONTHLY_DATES`, `MONTHLY_NTH_WEEKDAY`, `ON_DEMAND` |
| `intervalN` | Every N days or weeks | 2–60 days; 2–12 weeks (`TOO_LARGE`) |
| `weekdays` | Weekly, every N weeks | 1–7 (1 = Monday), each once, at least one |
| `exceptWeekdays` | No (Daily only) | Up to 6 days; at least one day must be left (`NO_DAYS_LEFT`) |
| `monthDays` | Monthly dates | 1–31 or −1 (the last day), each once, at least one; a date missing from a month falls on its last day |
| `nthWeekdays` | Monthly nth weekday | Up to 10 `{n, weekday}`, `n` 1–4 or −1 (the last), at least one |
| `slots` | No | Up to 4 `{start, end}` clock times, end after start, not overlapping (`OVERLAP`); empty = any time; none for On demand |
| `startsOn` | Yes | Day, today or later (`DATE_IN_PAST`) |
| `endsOn` | No | Day after `startsOn` (`BEFORE_START`); none for One time. An event point needs one, at most 60 days after the start (`EVENT_TOO_LONG`), and cannot be On demand (`NOT_FOR_EVENT`) |
| `holidayRule` | No | `SKIP` (left out) or `NEXT_WORKING_DAY` |
| `allowsExtra` | No | Left out: true |

A field the pattern does not use: `NOT_FOR_PATTERN`; one it needs: `REQUIRED`.

**The payment terms** (also the body of `PUT /outbound-sources/{id}/payment-terms/{termsId}`, without `id` and with `effectiveFrom`, a day today or later):

| Field | Required | Rule |
| --- | --- | --- |
| `id` | Yes | App-made; a new id is a new version |
| `type` | Yes | `NONE`, `PER_KG`, `FIXED` |
| `perKgMode` | Per kg | `ONE_RATE`, or `PER_ITEM` (Sorted only: `SORTED_ONLY`) |
| `ratePerKg` | One rate | Rupees, more than 0, up to 10,000 |
| `itemRates` | Per item | Up to 100 `{itemId, ratePerKg}`: one for every item the source gives, each once (`MISSING_RATE`, `NOT_AN_ITEM`, `DUPLICATE`) |
| `fixedAmount` | Fixed | Rupees, more than 0, up to 1,00,00,000 |
| `period` | Not for No payment | `WEEKLY` or `MONTHLY` |
| `dueWeekday` | Weekly | 1–7 |
| `dueMonthDay` | Monthly | 1–28, or −1 for the last day |
| `method` | Not for No payment | `CASH`, `UPI`, `BANK` |
| `upiId` | UPI | `name@bank` |
| `accountName`, `accountNumber`, `ifsc` | Bank | 1–255; 6–20 digits; like `SBIN0001234` |
| `bankName` | No | 1–100 |

A field the type does not use: `NOT_FOR_TYPE`. Items changed on an approved per-item source: `RATES_FOR_ITEMS` (send new terms with a rate per item).

Refused: `422 INVALID_SOURCE` with one `details` entry per field (the codes above, and `FIELD_LOCKED`, `SCHEDULE_LOCKED`, `PHOTO_NOT_ISSUED`), `422 NO_AGREEMENT_TYPE` (the office has no agreement type for this kind of source), `404` (another IEC's source), `409 SOURCE_ENDED`, `409 ID_IN_USE` (a schedule, terms or agreement id of another record). The schedule change also: `409 NOT_APPROVED` (before approval: edit the source).

#### `PUT /source-pauses/{id}`, `POST /source-pauses/{id}/cancel`

| Field | Required | Rule |
| --- | --- | --- |
| `sourceId` | Yes | One of your approved sources |
| `from` | Yes | Day, today or later for a new pause (`DATE_IN_PAST`); a pause under way keeps its start (`PAUSE_STARTED`) |
| `to` | No | Day, on or after `from`; left out: until resumed |
| `reason` | Yes | Text, 3–500 |

Refused: `422 PAUSE_OVERLAP`, `409 PAUSE_CANCELLED`, `409 NOT_APPROVED`, `404`. Cancel has no body; `409 PAUSE_OVER` once the pause is over.

#### `POST /schedules/preview` (online)

`schedule` (as above, without `id`), `warehouseId` (optional: its holidays apply), `count` (1–30, left out: 5). Saves nothing; answers `summary` and `visits[]` (`dueDate`, `scheduledFor`, `windowStart`, `windowEnd`).

#### The agreement file (online)

`POST /source-agreements/{id}/upload-url`: `fileName` (1–255), `contentType` (`application/pdf`, `image/jpeg`, `image/png`). `POST /source-agreements/{id}/files`: the same two and `key` (1–500). Refused: `404` (not an agreement of your sources), `409 DOCUMENT_ENDED`, `422 NOT_ISSUED` (the key is not this agreement's), `422 FILE_NOT_UPLOADED`, `422 FILE_TOO_LARGE` (over 10 MB), `422 WRONG_FILE_TYPE`.

### IEC Executive and Pickup Supervisor

#### `PUT /due-pickups/{id}` (an extra pickup)

| Field | Required | Rule |
| --- | --- | --- |
| `sourceId` | Yes | One of your sources, active or paused |
| `date` | Yes | Day, today to 60 days ahead (`DATE_IN_PAST`, `TOO_FAR`); not a warehouse holiday (`WAREHOUSE_CLOSED`) or a paused day (`SOURCE_PAUSED`) |
| `windowStart`, `windowEnd` | No | Clock times, both or neither, end after start |
| `expectedQtyKg` | No | More than 0, up to 100,000 |
| `note` | No | Text, 1–1000 |

Refused: those `422`s on `date`, `409 EXTRA_NOT_ALLOWED` (the IEC, when the schedule takes no extras), `409 SOURCE_NOT_ACTIVE`, `409 ID_IN_USE`, `404`.

#### `POST /due-pickups/{id}/cancel-by-source`

| Field | Required | Rule |
| --- | --- | --- |
| `reason` | Yes | `CLOSED`, `NO_MATERIAL`, `HOLIDAY`, `SHIFTED`, `OTHER` |
| `note` | With `OTHER` | Text, 1–500 |

Refused: `409 DATE_PASSED`, `409 WRONG_STATE` (not Requested, Due, or Planned on a trip not started), `404`.

#### `PUT /outbound-requests/{id}` (also the Driver)

| Field | Required | Rule |
| --- | --- | --- |
| `kind` | Yes | Supervisor: `VEHICLE`, `LABOUR`, `PICKUP_POINT_CHANGE`, `START_PICKUPS`, `STOP_PICKUPS`, `PAUSE_PICKUPS`. IEC: `START_PICKUPS`, `SCHEDULE_CHANGE`, `PAUSE_PICKUPS`, `ROUTE_OR_VEHICLE`, `OTHER`. Driver: `ENTRY_CORRECTION` (another kind: `403`) |
| `sendTo` | IEC | `SUPERVISOR` or `COLLECTION_HEAD` |
| `sourceId` | Pickup point kinds; IEC | One of your pickup points (`NOT_YOUR_SOURCE`) |
| `routeId` or `tripId` | Vehicle, Labour | Your route or trip |
| `entryId` | Correction | Your entry |
| `fromDate` | Every kind but Pickup point change and Correction | Day; for a pause today or later (`DATE_PASSED`) |
| `toDate` | No | Day, on or after `fromDate` |
| `details` | Yes | Text, 1–500 |
| `correction` | Correction | `lines` (Sorted: 1–50 `{itemId, quantity}`, every item as it should read, more than 0, up to 100,000) or `totalKg` (Mixed) |
| `raisedAt` | Yes | Time |

Refused: `422 REQUIRED` (names the missing field), `422 NOT_YOUR_SOURCE`, `422 NO_SUPERVISOR`, `422 NOT_CORRECTABLE`, `422 INVALID_ENTRY`, `422 DATE_PASSED`, `409 ALREADY_ASKED`, `409 TRIP_APPROVED`, `409 ID_IN_USE`, `403`.

#### `POST /outbound-requests/{id}/follow-up`, `/escalate`

Follow-up has no body: `404`, `409 WRONG_STATE` (decided), `409 TOO_SOON` (you followed up today). Escalate (IEC): `details` optional, 1–500: `404`, `409 NOT_YET` (fewer than 3 follow-ups), `409 NOT_ALLOWED` (not a request to a Pickup Supervisor).

### Pickup Supervisor

#### `POST /due-pickups/{id}/accept | decline | skip | unskip | move`

| Call | Field | Required | Rule |
| --- | --- | --- | --- |
| `accept` | — | — | No body. The day passed: `409 DATE_PASSED` |
| `decline` | `reason` | Yes | Text, 3–500 |
| `skip` | `reasons` | Yes | 1–7 of `SOURCE_CLOSED`, `HOLIDAY`, `SOURCE_ASKED`, `VEHICLE_UNAVAILABLE`, `CAPACITY_FULL`, `NOT_ENOUGH_TIME`, `OTHER`, each once |
| `skip` | `note` | With `OTHER` | Text, 1–500 |
| `unskip` | — | — | No body. The day passed: `409 DATE_PASSED` |
| `move` | `date` | Yes | Day, today or later (`DATE_IN_PAST`); not a holiday (`WAREHOUSE_CLOSED`) or a paused day (`SOURCE_PAUSED`) |
| `move` | `windowStart`, `windowEnd` | No | Both or neither, end after start; left out, the window stays |

All: `404` (not a pickup of your sources), `409 WRONG_STATE` (not in a state this applies to).

#### `PUT /pickup-routes/{id}`

| Field | Required | Rule |
| --- | --- | --- |
| `name` | Yes | Text, 1–100 |
| `warehouseId` | Yes | An active warehouse with a code |
| `shiftId` | Yes | A shift of that warehouse, active (`NOT_FOUND`, `SHIFT_INACTIVE`) |
| `vehicleId` | Our van | A van of that warehouse, switched on (`NOT_FOUND`, `VEHICLE_INACTIVE`). Exactly one of `vehicleId` and `rented` ("Choose our van or a rented truck") |
| `driverId` | With our van; never with a rented truck | A driver placed at that warehouse, active (`NOT_A_DRIVER_HERE`, `USER_SUSPENDED`) |
| `rented.vehicleNumber` | With a rented truck | 4–20 characters, stored upper-case |
| `rented.transporterName`, `rented.driverName` | No | Text, 1–255 |
| `rented.driverPhone` | No | Phone |
| `rented.capacityKg` | No | More than 0, up to 100,000 |
| `labourId` | No | A labourer of that warehouse, active (`NOT_FOUND`, `LABOUR_INACTIVE`) |
| `sourceIds` | Yes | Up to 200, each once, in pickup order: your Active or Paused sources (`NOT_YOUR_SOURCE` on `sourceIds.N`) |

Refused: those `422`s on their fields, `409 ID_IN_USE`, `404` (another supervisor's route). `/deactivate` and `/activate` take no body; activate checks the team again (the same `422`s).

#### `POST /pickup-trips/{id}/change-for-today`

| Field | Required | Rule |
| --- | --- | --- |
| `vehicleId`, `rented`, `driverId`, `labourId` | As for a route | As for a route |
| `stopIds` | Yes | 1–200 due pickup ids in order, each once: Due pickups of yours that day or stops of your other Planned trips that day (`NOT_AVAILABLE` on `stopIds.N`) |
| `reason` | When the van, truck, driver or labourer changes | `ABSENT`, `BREAKDOWN`, `VEHICLE_UNAVAILABLE`, `OTHER` (`REASON_REQUIRED`) |
| `note` | With `OTHER` | Text, 1–500 |

Refused: `409 WRONG_STATE` (cancelled or started), `409 DATE_PASSED`, the team's `422`s, `404`.

#### `POST /pickup-trips/{id}/move-stops`

| Field | Required | Rule |
| --- | --- | --- |
| `toTripId` | Yes | Another of your Planned trips, the same day and warehouse (`SAME_TRIP`, `NOT_FOUND`, `NOT_AVAILABLE`, `OTHER_WAREHOUSE`) |
| `duePickupIds` | Yes | 1–200, each once: stops of this trip (`NOT_AVAILABLE` on `duePickupIds.N`) |
| `reason` | Yes | `ABSENT`, `BREAKDOWN`, `VEHICLE_UNAVAILABLE`, `OTHER` |
| `note` | With `OTHER` | Text, 1–500 |

Refused: those `422`s, `409 WRONG_STATE`, `409 DATE_PASSED`, `404`.

#### `POST /pickup-trips/{id}/cancel`, `/complete-for-driver`

| Call | Field | Required | Rule |
| --- | --- | --- | --- |
| `cancel` | `reason` | Yes | Text, 1–500. A Planned trip of today or later (`409 WRONG_STATE`, `409 DATE_PASSED`) |
| `complete-for-driver` | `notVisited` | No | Up to 200 due pickup ids: open stops of this trip (`NOT_AVAILABLE` on `notVisited.N`); left out: none |
| `complete-for-driver` | `note` | No | Text, 1–500 |

Complete for the driver: a Planned or On route trip, not of a later day (`409 WRONG_STATE`, `409 NOT_TODAY`). Both: `404` (not your trip).

#### Reads: `GET /pickup-trips/{id}/free-staff`, `GET /trips-plan`, `GET /collection-report`

| Call | Query | Rule |
| --- | --- | --- |
| `free-staff` | — | `404` when not your trip |
| `trips-plan` | `from`, `to` | Days: `from` today or later, `to` at most 14 days ahead, at most 31 days (`422 INVALID_PERIOD`) |
| `collection-report` | `from`, `to`, `format` | Days, `from` not after `to`, at most 366 days (`422 INVALID_PERIOD`); `format` `json` (left out) or `pdf` (`400 VALIDATION_ERROR` otherwise) |

Both reports: `403` for anyone but a Pickup Supervisor.

#### `POST /supervisor-flags/{id}/done`, `POST /trip-issues/{id}/resolve | escalate`

Mark done and escalate take no body. Resolve: `note` required, 1–150. Refused: `404` (not yours), `409 WRONG_STATE` (an issue already resolved; escalate only from Open).

#### `POST /outbound-requests/{id}/decide`

| Field | Required | Rule |
| --- | --- | --- |
| `decision` | Yes | `APPROVE` or `DECLINE` |
| `reply` | To decline | Text, 1–500; the asker sees it |

Refused: `404` (not sent to you), `409 WRONG_STATE` (decided), `409 TRIP_APPROVED` (a correction whose trip was approved since).

#### `PUT /supervisor-cash-requests/{id}`, `PUT /source-payments/{id}`

| Call | Field | Required | Rule |
| --- | --- | --- | --- |
| Cash request | `amount` | Yes | Rupees, more than 0, up to 1,00,00,000 |
| Cash request | `reason` | Yes | Text, 1–300 |
| Payment | `sourceId` | Yes | One of your pickup points now (`NOT_YOUR_SOURCE`) |
| Payment | `amount` | Yes | Rupees, more than 0; not more than your cash (`NOT_ENOUGH_CASH`) or what the source is owed (`MORE_THAN_DUE`) |
| Payment | `method` | Yes | `CASH`, `UPI`, `BANK` |
| Payment | `reference` | No | Text, 1–100: the UPI or bank reference |
| Payment | `photoUrl` | No | Your `PAYMENT_RECEIPT` upload: the receipt or UPI screen (`INVALID_PHOTO`) |
| Payment | `note` | No | Text, 1–300 |
| Payment | `paidOn` | Yes | Day, today or earlier (`DATE_IN_FUTURE`) |

Both: `403` for anyone but a Pickup Supervisor, `409 ID_IN_USE`.

#### Drivers and labour (online)

| Call | Field | Required | Rule |
| --- | --- | --- | --- |
| `PUT /warehouse-drivers/{id}` | `warehouseId` | Yes | A warehouse of the company with a code (`WAREHOUSE_CODE_MISSING`) |
|  | `name` | Yes | Text, 2–100 |
|  | `phone` | Yes | Indian mobile, their login, belonging to nobody else (`409 PHONE_IN_USE`) |
| `PUT /warehouse-labour/{id}` | `warehouseId` | Yes | A labourer stays at the warehouse they were added to (`422 OTHER_WAREHOUSE`; `WAREHOUSE_CODE_MISSING`) |
|  | `name` | Yes | Text, 1–255; not a name already at that warehouse (`409 DUPLICATE_NAME`) |
|  | `phone` | No | Phone |
| Both | `idNumber` | No | Text, 1–100: Aadhaar or Voter ID |
| Both | `photoUrl`, `idProofUrl` | No | Your `WAREHOUSE_PERSON` uploads (`INVALID_PHOTO`) |
| `POST …/deactivate`, `/activate` | `warehouseId` | Yes | The warehouse to take them off or put them back on |

Refused: `409 NOT_A_DRIVER` (the person has other roles), `409 NO_DRIVER_ROLE` (no Driver role set up), `409 IN_USE` on deactivate (on an active route or a coming trip there; `details` name the routes), `409 ID_IN_USE`, `404`.

### Driver

#### `PUT /pickup-entries/{id}`

| Field | Required | Rule |
| --- | --- | --- |
| `duePickupId` | Yes | A stop of a trip you drive (`404 NOT_FOUND`) |
| `outcome` | Yes | `COLLECTED`, `ZERO_KG`, `GATE`, `SOURCE_CANCELLED` |
| `lines` | Collected, Sorted | 1–50 `{itemId, quantity, photoUrl}`: the stop's items each once (`NOT_AN_ITEM_HERE`, `DUPLICATE_ITEM`), quantity in the item's unit, more than 0, up to 100,000; `photoUrl` optional. Only for Collected; never for Mixed (`NOT_FOR_MIXED`) |
| `totalKg` | Collected, Mixed | More than 0, up to 100,000. For Gate team will enter: the optional rough weight. Not for a Sorted collection (`NOT_FOR_SORTED`) |
| `photoUrls` | At least one for Collected | Up to 10, your `PICKUP_PHOTO` uploads (`PHOTO_REQUIRED`) |
| `zeroKgReason` | 0 kg | `CLOSED`, `NO_MATERIAL`, `REFUSED`, `NOT_REACHABLE`, `VEHICLE_FULL`, `OTHER`; only for 0 kg |
| `sourceCancelReason` | Cancelled by source | `CLOSED`, `NO_MATERIAL`, `HOLIDAY`, `SHIFTED`, `OTHER`; only for that outcome |
| `note` | With an `OTHER` reason | Text, 1–150 |
| `voiceUrl` | No | Your `PICKUP_VOICE` upload |
| `lat`, `lng` | No | Both or neither |
| `pickedByHand`, `recordedLater` | No | true or false |
| `recordedAt` | Yes | Time (the phone's) |

Refused: `422 INVALID_ENTRY` (`details`: `PHOTO_REQUIRED`, `REQUIRED`, `NOT_AN_ITEM_HERE`, `DUPLICATE_ITEM`, `NOT_FOR_MIXED`, `NOT_FOR_SORTED`), `422 INVALID_PHOTO`, `409 ALREADY_RECORDED`, `409 WRONG_STATE` (the trip cancelled or handed over, or the stop left it), `409 NOT_TODAY` (the first entry of a trip not of today), `409 MIXED_ITEM_NOT_SET`, `409 ID_IN_USE`, `404`.

#### `POST /pickup-trips/{id}/start`, `/hand-over`

| Call | Field | Required | Rule |
| --- | --- | --- | --- |
| `start` | `lat`, `lng` | No | Where the phone is |
| `hand-over` | `bags` | Yes | Whole number, 0–10,000 |

Start: today's trips only (`409 NOT_TODAY`), not a cancelled one (`409 WRONG_STATE`). Hand over: `409 NOT_STARTED` (still Planned), `409 WRONG_STATE` (cancelled). Both: `404` (not a trip you drive).

#### `PUT /trip-issues/{id}`

| Field | Required | Rule |
| --- | --- | --- |
| `types` | Yes | 1–4 of `VEHICLE_BREAKDOWN`, `ACCIDENT`, `SOURCE_PROBLEM`, `OTHER`, each once |
| `note` | With `OTHER` | Text, 1–150: the remarks |
| `tripId` | No | A trip you drive |
| `sourceId` | No | A pickup point |
| `raisedAt` | Yes | Time |

Refused: `422 NOT_FOUND` (on `tripId` or `sourceId`), `409 ID_IN_USE`.

A correction request is `PUT /outbound-requests/{id}` with `kind: ENTRY_CORRECTION`, `entryId` and `correction` (above).

### Warehouse Incharge

#### `PUT /pickup-trips/{id}/gate-entries/{duePickupId}`

| Field | Required | Rule |
| --- | --- | --- |
| `outcome` | Yes | `COLLECTED` or `ZERO_KG` |
| `lines` | Collected, Sorted | As for the driver's entry |
| `totalKg` | Collected, Mixed | More than 0, up to 100,000 |
| `photoUrls` | No | Up to 10, your uploads |
| `zeroKgReason` | 0 kg | As for the driver's entry |
| `note` | With `OTHER` | Text, 1–300 |

Refused: `409 RECORDED_BY_DRIVER`, `409 WRONG_STATE` (not at the warehouse, approved or cancelled), `409 MIXED_ITEM_NOT_SET`, `422 INVALID_ENTRY`, `422 INVALID_PHOTO`, `404` (not a trip of your warehouses).

#### `PUT /pickup-trips/{id}/weighbridge`

Every field optional; the ones sent replace.

| Field | Rule |
| --- | --- |
| `grossKg`, `emptyKg` | More than 0, up to 100,000; empty less than gross (`422 EMPTY_NOT_LESS`) |
| `grossAt`, `emptyAt`, `unloadingStartedAt`, `unloadingDoneAt` | Times; a weight sent without its time takes the server's now |
| `bagsReceived` | Whole number, 0–10,000 |
| `slipPhotoUrls` | Up to 10, your `WEIGHBRIDGE_SLIP` uploads (`INVALID_PHOTO`) |

Refused also: `409 WRONG_STATE`, `404`.

#### `POST /pickup-trips/{id}/approve`, `/send-back`

| Call | Field | Required | Rule |
| --- | --- | --- | --- |
| `approve` | `note` | When the difference is flagged | Text, 1–500 (`422 NOTE_REQUIRED`) |
| `send-back` | `note` | Yes | Text, 1–500 |

Both need a trip Being checked (`409 NOT_READY`); an approved trip: `409 WRONG_STATE`. `404` for a trip not of your warehouses.

### Uploads

`POST /uploads/batch`: `photos[]` 1–20, each `{purpose, contentType, sizeBytes}`; the purposes and types are in "Photos, files and voice notes". Refused: `422 FILE_TOO_LARGE` (over 5 MB, on `photos.N.sizeBytes`), `422 WRONG_TYPE` (audio for a photo purpose, or a photo for `PICKUP_VOICE`).

## Edge cases

The fixed-point edge cases still apply (Offline Data Guide, "Edge cases": session expiry, app killed while sending, upload links expiring, logout, another user on the phone). These are the outbound ones, as the server handles them.

| Case | What happens | The app does |
| --- | --- | --- |
| A driver works all day offline | Today's and tomorrow's trips are already on the phone; Start trip, entries and the hand-over queue in order | Keep working; show the outbox count. Missed and "next stop" are worked out on the phone |
| The phone's clock is wrong | The server judges every date in IST (`NOT_TODAY`, `DATE_PASSED`, today or later); `recorded_at` keeps the phone's time, `entered_at` the server's | Compare with `serverTime` and warn when they differ by more than a few minutes; use the IST date for "today" everywhere |
| A started trip runs past midnight | Entries and the hand-over are still accepted (only starting a Planned trip must be today) | Nothing special |
| A trip never started and its day passed | It stays Planned; its stops show Missed. The supervisor can still Complete it for the driver so the gate can enter what was collected | Show Missed; offer Complete trip for the driver on the supervisor's trip |
| A rented-truck trip | It has no driver app, so nobody starts it; the Driver not using app banner is for our vans only | The supervisor uses Complete trip for the driver from the trip's sheet; the gate enters every stop |
| The supervisor cancels a trip while the driver is offline | Only a Planned trip can be cancelled; the driver's queued Start trip or entries answer `409 WRONG_STATE` | Drop them, sync, show the trip as cancelled with its reason. Tell the driver to call the supervisor if they collected anything |
| A trip is changed for today while the driver is offline | The new team and stops arrive with the next sync | A stop moved off the trip answers `409 WRONG_STATE` on its entry: drop it and sync |
| The driver is taken off a trip | Their scope key changes; queued writes for that trip answer `404` | After the scope reset, mark those items failed with "This trip is no longer yours: call your supervisor" |
| A source moves to another supervisor (its area moved, or the admin moved it) | It leaves the old supervisor's routes and trips; their scope key changes; the new supervisor gets a Source moved to you flag | Reset as usual; the old supervisor's queued writes on it answer `404`: show them as failed |
| An IEC edits a source the admin approved meanwhile | A locked field answers `422 INVALID_SOURCE` with `FIELD_LOCKED`; a new schedule id `SCHEDULE_LOCKED` | Show the fields read-only; send the schedule change through its own screen |
| A source is rejected while the IEC is offline | The row arrives `REJECTED` with the reason | Show Not approved; Edit and resubmit with the same id |
| The IEC changes a schedule or pauses a source | The server remakes the pickups and today's and tomorrow's trips, and flags the supervisor | Nothing: both phones get the changes on their next sync |
| A pickup's day passes before the supervisor accepts it | `409 DATE_PASSED` | Drop the write; offer Decline |
| Two people act on the same pickup, request or issue | The second gets `409 WRONG_STATE` | Treat it as done: drop the write, sync, show who decided |
| The warehouse sends a trip back | The trip is At the warehouse again with `sent_back_note`; the driver and supervisor are told | The incharge fixes a gate entry or saves the weighbridge again (nothing changed is enough); the driver's figures change only through a correction, until approval |
| A correction is approved while the trip is being checked | The stop's record changes and the trip is checked again | Nothing: the new figures and status arrive on sync |
| A payment queued offline no longer fits | The cash or the owed amount changed on the server: `422 NOT_ENOUGH_CASH` or `MORE_THAN_DUE` | Mark it failed with the message; the next sync brings the real figures |
| The Mixed waste item is not set | A Mixed stop's entry answers `409 MIXED_ITEM_NOT_SET` | Block the Mixed form while `mixedItemId` is null; say "Ask the office" |
| A driver or incharge loses their last warehouse | Every call answers `409 NO_WAREHOUSE_ASSIGNED` | Show the setup message; keep the outbox, do not discard it |
| A notification points at something not on the phone | An IEC is told of an escalated issue, but issues reach only the driver and supervisor | Show the notification's words; do not open an empty screen |
| The first sync of the day is slow | It runs the day's pickup and trip roll before answering | Keep the sync spinner; nothing else |

## Changelog

Newest first. The tables and statements behind each change are in the SQLite doc.

| Date | Change | Phone work |
| --- | --- | --- |
| 26 Nov 2026 | Matched to the 26 Nov Figma: collection report with a PDF, trips plan, time-clash and off-route warnings and flags, Missed once a trip reaches the warehouse, Help & Support numbers, Call warehouse, the driver's code, where and when a stop was entered | Two online calls, a route estimate run on the phone, seven new columns and six sync\_meta keys (in the SQLite doc), and the screen map. |
| 20 Oct 2026 | Routes set up once; the server makes trips from them for today and tomorrow; Unassigned; change a trip for its day or cancel it; flags; the supervisor adds, edits and deactivates drivers and labour; the Driver sees their own trips (read-only) | Five tables, two new pickup columns, five queued writes, two online-only screens (drivers, labour), the supervisor's Routes, Today and Flags lists, the driver's Today. |
| 20 Oct 2026 | Pickups made from schedules (14 days ahead); extra pickups (the IEC asks, the Pickup Supervisor accepts or declines, or adds one); skip, undo skip and move one pickup; pauses; schedule changes from a date; warehouse holidays applied | Two tables, seven writes, the supervisor's request, day and missed lists, the IEC's pause and schedule screens. |
| 15 Oct 2026 | IEC leads and visits, registering sources (with schedule and payment terms), approval by the admin, sources reaching their Pickup Supervisor | Eight tables, four writes, the area-from-pin step in registration, IEC Home and source screens. |
| 14 Oct 2026 | Warehouses, shifts, vans, drivers, labour, cities and areas arrive as reference tables; me.outbound carries the GPS radius, tolerance and Mixed waste item | Seven tables, three sync\_meta keys, area-from-PIN lookup. |
| 14 Oct 2026 | Outbound roles can sign in; `me.warehouses`; `409 NO_WAREHOUSE_ASSIGNED` | One table (`my_warehouses`), role menus, one error message. |
