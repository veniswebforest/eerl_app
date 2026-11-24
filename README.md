# EERL Mobile

EERL Mobile is a role-aware Flutter application for field operations at recycling collection centres. The primary app serves Collection Agents and Collection Supervisors and is designed to keep working when connectivity is weak or absent. The repository also contains an embedded `pickup_supervisor` Flutter module for Driver and Pickup Supervisor experiences.

This README is the project handoff and onboarding document. It is intentionally written so a developer or coding assistant such as Claude Code can understand the product, architecture, data flow, repository layout, implementation conventions, current state, and recommended roadmap before changing code.

## Read this first

The canonical product and data contracts are local snapshots captured on **30 Oct 2026**:

1. [`docs/project-context/overall-requirements.md`](docs/project-context/overall-requirements.md) — product behaviour, offline model, roles, APIs, validation rules, screen flows, and dated changes.
2. [`docs/project-context/schema-and-queries.md`](docs/project-context/schema-and-queries.md) — authoritative SQLite schema, queries, transactions, sync application rules, outbox behaviour, and screen-level SQL.

For every task in this repository, read both files completely before analysing or editing. Later-dated changes in those documents override older entries. Do not edit either snapshot unless explicitly asked.

The implementation has continued beyond those snapshots. Current code includes additional concepts such as assignments, zones, centre prices, price requests, and the Driver/Pickup Supervisor module. Treat the snapshots as canonical for their covered Collection Agent/Supervisor contract and inspect the current code and tests for repository extensions.

## Product in one minute

The app supports field collection-centre operations:

- Collection Agents record D2D, MRF, and ramp collections; manage material configuration and ragpickers; view records and wallet activity; log expenses; request cash or categories; raise transfers; complete tasks; raise requests; and close the day.
- Collection Supervisors verify collections; review expenses, cash, and category requests; view centre stock; approve or reject transfers and arrange trucks; assign tasks; resolve requests; maintain MRF people and D2D vehicles; and review agent status.
- Users with multiple roles switch roles locally. The active role changes navigation and queries, not the downloaded dataset.
- Driver and Pickup Supervisor roles route into the separate `modules/pickup_supervisor` package, which contains pickup, stop, route, source, issue, attention, profile, and dashboard surfaces.
- English, Gujarati, and Hindi are supported.

The defining architectural rule is:

> Screens read SQLite. User actions update SQLite first. Network synchronization happens around that local state.

## Architecture

```text
Flutter screens and widgets
        |
        v
Feature repositories / EerlLocalRepository
        |
        v
EerlLocalDataSource + AppDatabase (SQLite)
        |                         |
        |                         +--> photos + outbox + outbox_photos
        |                                      |
        |                                      v
        |                              OutgoingSyncService
        |                                      |
        +<-- BootstrapApplier <--- BootstrapSyncService
                                           |
                                           v
                                  EERL Mobile REST API
```

### Application layers

- `lib/features/**/view` and `widgets` contain feature UI.
- `lib/features/local_data` is the main application-facing local repository and query/write layer.
- `lib/core/local_database` owns the SQLite database, migrations, schema, write validation, and outbox helpers.
- `lib/features/bootstrap` owns server-to-phone bootstrap application, phone-to-server outgoing synchronization, conflict reconciliation, uploads, and image caching.
- `lib/core/router` contains role-aware GoRouter routes.
- `lib/core/providers` contains app-wide Provider state such as network, locale, theme, lock, and Bluetooth weight.
- `modules/pickup_supervisor` is a local Flutter module consumed through a path dependency.

The project uses pragmatic feature folders rather than a strict Clean Architecture boundary. UI should normally call `EerlLocalRepository`; do not bypass SQLite to populate a screen directly from an HTTP response.

## Offline-first data model

### Server to phone: Bootstrap

`GET /api/v1/mobile/bootstrap` is the incremental download channel.

1. The first authenticated run calls `/bootstrap` without `since`.
2. Each page is applied in one SQLite transaction.
3. The response cursor is stored inside that same transaction.
4. While `hasMore` is true, the next page is fetched.
5. Later runs send the opaque stored cursor unchanged.
6. Reference tables use whole-set `replace` semantics; record tables use `upserts` and `deletes`.
7. A pending local row must not be overwritten or deleted by Bootstrap.
8. `me.scopeKey` changes and `INVALID_CURSOR` require a safe scope reset after the outbox is drained.

Bootstrap is triggered on login/first load, app open or resume, reconnect, pull-to-refresh, and after outgoing synchronization. Concurrent runs are coalesced rather than duplicated.

### Phone to server: Outbox

Every offline-capable mutation follows one transaction:

1. Create or update the local domain row.
2. Set its `sync_state` to `pending`.
3. Queue the HTTP method, mobile path, JSON body, entity, entity id, operation kind, and references in `outbox`.
4. Link required photos through `outbox_photos`.
5. Commit, then refresh the UI from SQLite.

`OutgoingSyncService` uploads blocking photos, resolves local photo ids to uploaded URLs, and sends queued writes. Writes are idempotent because the phone creates UUID v4 ids and uses them in endpoint paths.

Typical result handling:

| Result | Behaviour |
| --- | --- |
| `2xx` | Apply the response, remove the outbox item, mark the entity synced when nothing else is queued. |
| Known terminal `409` such as `NOT_PENDING` or `ALREADY_CLOSED` | Reconcile with server state; do not leave a permanent failure. |
| Record-moved `409` such as `CANCELLED`, `DRAFT_DISCARDED`, selected `ALREADY_SUBMITTED`, or transfer `REJECTED` | Drop the stale action and restore/fetch authoritative state. |
| Retryable network, timeout, `408`, `429`, or `5xx` | Requeue with backoff. |
| Other `4xx`/validation failures | Park the item as failed and expose it through Sync Status. |

Failed writes block later writes for the same entity, not unrelated entities.

### Photos

Photos are durable local records, not transient widget values.

- Capture/pick and compress the image, save it outside temporary cache, then insert a `photos` row.
- Upload URLs are requested in batches of up to 20 immediately before upload.
- The binary is uploaded separately; the returned public `fileUrl` is stored as `remote_url`.
- A dependent outbox write waits until every linked photo is uploaded.
- UI prefers the local file while it exists, then falls back to the remote URL/cache.
- Item and profile images are persistently cached for offline display.

### SQLite rules that must not be broken

- The database is currently `eerl_local.db`, schema version **15**.
- `PRAGMA foreign_keys` intentionally remains **OFF**. Bootstrap pages can arrive child-first, reference sets are replaced, and some valid server references are outside the phone's scope.
- Relationships still appear in schema declarations for documentation and joins, but child cleanup is explicit.
- Money is stored as `REAL` and displayed to paise; quantities support up to three decimals.
- Server timestamps are ISO-8601 UTC text. Business days and slip-number dates use IST.
- JSON URL arrays are stored as text.
- A write that touches a domain row and outbox data must be atomic.
- Do not invent columns that `/bootstrap` does not send unless they are intentionally phone-only.

## Roles and navigation

The main dashboard supports these role keys in code:

| Role key | Home surface |
| --- | --- |
| `AGENT` / Collection Agent | Main EERL dashboard with Home, Collections, Records, and Profile tabs. |
| `SUPERVISOR` | Main EERL dashboard with Home, Verification, Stock, and Profile tabs. |
| `DRIVER` | Driver home from the `pickup_supervisor` module. |
| `PICKUP_SUPERVISOR` | Pickup Supervisor dashboard from the module. |
| Additional parsed keys | `ADMIN`, `COLLECTION_MANAGER`, and `IEC_AGENT` currently map through shared role/navigation code. |

The server returns role module keys. The app stores them in `my_roles`; role switching writes `sync_meta.active_role` and requires no network call. UI must hide actions that do not belong to the active role even if another role on the same account would authorize the API call.

Important route entry points are declared in `lib/core/router/app_routes.dart`. `MainDashboardScreen` uses an `IndexedStack` so bottom-tab state survives navigation and refreshes non-home tabs after a successful Bootstrap revision.

## Core domain flows

### Authentication and first load

```text
Phone number -> send OTP -> verify OTP -> persist token and expiry
             -> Bootstrap all pages -> store roles/centres/scope/cursor
             -> choose a role when more than one is available
```

The production API base URL is currently hard-coded in `AppConstants` as `https://api.eco-vision.in/api/v1`. Auth sessions are stored with `SharedPreferences`. Debug builds log API requests and responses; avoid sharing logs containing tokens or personal data.

### Collection lifecycle

```text
Draft -> Submitted -> Approved
                   \-> Rejected -> corrected and resubmitted with same id/slip
```

- Types: `D2D`, `MRF`, and `RAMP`.
- Drafts are local-first and periodically backed up through `PUT /collections/{id}`.
- Submit validates centre/channel rules, materials, quantities, rates/payment behaviour, required photos, and GPS when available.
- The app creates the only client-generated human reference: `CENTRE-YYMMDD-AGENT-COUNT`, for example `AAN-261008-07-012`.
- A rejected collection keeps its UUID, slip number, and original collection time.
- Supervisors approve or reject; rejection reasons and optional remarks remain separate.

### Wallet, expenses, and claims

- Wallet balance starts with `center_balances` and is adjusted for pending local expenses and paid collections.
- Agents log expenses, request cash, and request new expense categories.
- Supervisors decide expenses, cash requests, and category requests.
- Forms validate balance, category ownership, amounts, photos, and decision rules before queueing.

### Transfer lifecycle

```text
Requested -> Approved -> Dispatched -> Received
          \-> Rejected
```

- Agents raise transfers only against free stock.
- Supervisors choose destination, expected time, truck, ownership, transporter, fee, and note when approving.
- Vehicle Details and Weighbridge are staged locally; Submit Transfer queues one handover request.
- Dispatch requires truck number, driver, vehicle photos, loaded weight, and optional bale/weighbridge data; PCS items also carry pieces loaded.
- Local validation prevents dispatching more than the centre holds and supports repairing an `OVER_STOCK` failure.
- A transfer cancelled after approval is represented as rejected with a cancellation reason.

### Tasks and requests

- Supervisors assign/cancel tasks; agents complete them with optional photos.
- Agents raise requests with priority, a required follow-up time, and optional photos.
- Supervisors answer requests, optionally with separate proof photos.
- Stale offline actions have explicit conflict-reconciliation paths.

### Directories, stock, and day close

- Ragpickers are shared between agent and supervisor experiences.
- Supervisors manage MRF people and D2D vehicles. Current D2D vehicle data has centre, plate, optional driver, active status, and no vehicle type/capacity.
- Stock is raw material (`RM`) by item and centre. Never combine KG and PCS totals.
- Close Day is deliberately online-only and is disabled until the outbox is empty.

## Repository structure

```text
eerl_app/
├── android/                      Android host project
├── ios/                          iOS host project
├── assets/                       Main-app images, icons, fonts, and animations
├── docs/project-context/         Canonical product and SQLite snapshots
├── lib/
│   ├── main.dart                 App startup, providers, lifecycle sync, MaterialApp
│   ├── core/
│   │   ├── constants/            API and app constants
│   │   ├── local_database/       SQLite schema, v15 migrations, outbox, validators
│   │   ├── network/              Shared HTTP client and debug wire logging
│   │   ├── providers/            Global Provider state
│   │   ├── router/               GoRouter routes and role-home dispatch
│   │   ├── theme/                Design tokens and light/dark themes
│   │   └── utils|services|...    IST, UUID, images, Bluetooth, printing, app lock
│   ├── features/
│   │   ├── auth/                 OTP login and session handling
│   │   ├── bootstrap/            Bootstrap, outgoing sync, uploads, reconciliation
│   │   ├── local_data/           Main local data source/repository/models
│   │   ├── collection|records/   Collection entry, receipts, history, detail
│   │   ├── wallet/               Expenses, cash, wallet views
│   │   ├── transfer_requests/    Agent and supervisor transfer flows
│   │   ├── verification/         Supervisor collection verification
│   │   ├── stock/                Centre stock views
│   │   ├── tasks|requests/       Agent work and requests
│   │   ├── supervisor_*/         Supervisor-specific modules
│   │   └── ...                   Home, profile, notifications, directories, prices
│   ├── l10n/                     EN/GU/HI ARB files and generated localizations
│   └── shared/widgets/           Shared application widgets
├── modules/pickup_supervisor/    Local Driver/Pickup Supervisor Flutter module
├── test/                         Main-app unit, data, router, and widget tests
├── AGENTS.md                     Mandatory repository instructions for coding agents
└── pubspec.yaml                  Root Flutter package and dependencies
```

The current repository contains roughly 291 Dart files under `lib`, 42 in the pickup module, more than 100 root tests, and a sizeable checked-in visual asset library. Prefer extending existing shared widgets and domain repositories rather than creating parallel patterns.

## Important implementation entry points

| Concern | Start here |
| --- | --- |
| App startup | `lib/main.dart` |
| Routes and role dispatch | `lib/core/router/app_router.dart`, `app_routes.dart`, `role_home_navigation.dart` |
| SQLite lifecycle/migrations | `lib/core/local_database/app_database.dart` |
| Fresh schema and indexes | `lib/core/local_database/database_schema.dart` |
| Mobile write validation | `lib/core/local_database/mobile_write_validator.dart` |
| Outbox helper | `lib/core/local_database/outbox_queue.dart` |
| Main domain queries/writes | `lib/features/local_data/data/eerl_local_data_source.dart` |
| UI-facing repository | `lib/features/local_data/data/eerl_local_repository.dart` |
| Bootstrap orchestration | `lib/features/bootstrap/service/bootstrap_sync_service.dart` |
| Incoming page application | `lib/features/bootstrap/data/bootstrap_database_applier.dart` |
| Outgoing sync and conflicts | `lib/features/bootstrap/service/outgoing_sync_service.dart` |
| API constants | `lib/core/constants/app_constants.dart` |
| Role dashboard | `lib/features/dashboard/view/main_dashboard_screen.dart` |
| Pickup module | `modules/pickup_supervisor/lib/` |

## Development setup

### Prerequisites

- Flutter SDK compatible with Dart `^3.12.0`
- Android Studio/SDK for Android development
- Xcode and CocoaPods for iOS development
- Java 17 for the Android build
- A device or emulator with camera/location permissions for full field-flow testing
- Network access and a valid EERL user phone number for real OTP/API testing

### Install and run

```bash
flutter pub get
flutter gen-l10n
flutter run
```

The local `pickup_supervisor` dependency is resolved automatically from `modules/pickup_supervisor`.

Useful checks:

```bash
dart format --output=none --set-exit-if-changed lib test modules/pickup_supervisor/lib modules/pickup_supervisor/test
flutter analyze
flutter test
```

Run a focused test while iterating:

```bash
flutter test test/features/local_data/collection_submit_body_test.dart
flutter test test/features/bootstrap/bootstrap_outbox_order_test.dart
```

Build examples:

```bash
flutter build apk --debug
flutter build apk --release
flutter build ios --no-codesign
```

### Localization

Source translations live in:

- `lib/l10n/app_en.arb`
- `lib/l10n/app_gu.arb`
- `lib/l10n/app_hi.arb`

After changing ARB files, run `flutter gen-l10n`. Generated files under `lib/l10n/generated` should remain consistent with the ARB sources. The pickup module has its own driver localization files under `modules/pickup_supervisor/lib/l10n`.

### Native configuration status

- Android currently uses the placeholder namespace/application id `com.example.eerl_app`.
- Release builds currently use the debug signing configuration.
- The API endpoint is compiled as a constant; there is no flavour or `--dart-define` environment selection yet.
- Firebase Messaging dependencies/configuration are not currently present even though the canonical roadmap specifies push notifications.

Do not treat the current native identifiers/signing as production-ready.

## Testing strategy

Tests are grouped by behaviour rather than only by class:

- SQLite/schema/bootstrap contract tests
- Outbox ordering, conflict handling, and diagnostic tests
- Local write/body/validation tests for collections, wallet, transfers, tasks, requests, directories, notifications, and stock
- Router and dashboard role tests
- Feature widget and empty-state tests
- Camera, shared widget, and formatting utility tests
- Driver/Pickup Supervisor module tests

For a database change, add or update tests for:

1. A fresh schema.
2. The migration from the previous database version.
3. Bootstrap mapping/apply semantics.
4. The local transaction and queued request body.
5. Query output consumed by the affected UI.
6. Conflict or failure recovery when relevant.

For UI work, test the real local repository path when practical; avoid tests that only validate duplicated fixture logic.

## Change method

Use this sequence for repository work:

1. Read both canonical context snapshots completely.
2. Identify the latest dated rule for the feature.
3. Inspect the existing route, UI, repository, local data source, schema/migration, Bootstrap mapping, outgoing sync, localization, and related tests.
4. Decide whether the change is UI-only, local-query-only, a local write, a Bootstrap contract change, or a full schema/API change.
5. Keep all local row + outbox + photo-link writes in one transaction.
6. Validate before queueing so predictable server refusals never enter the outbox.
7. Preserve pending/failed local state during incoming Bootstrap application.
8. Add focused tests, then run formatting, analysis, and the relevant test set.
9. Update this README only when project-level architecture, setup, or roadmap changes; update canonical context files only when explicitly requested.

## Current state and known gaps

### Implemented or substantially represented

- OTP auth and session persistence
- Role-aware routing and local role switching
- SQLite schema/migrations and screen-oriented query layer
- Incremental paginated Bootstrap with cursor and scope handling
- Outbox, photo upload dependencies, retries, failed state, and several conflict reconciliations
- Agent collection, records, wallet, transfer, task, request, directory, and profile flows
- Supervisor verification, stock, approval, task/request, people, vehicle, transfer, price, and agent-status surfaces
- GPS capture, image compression/cache, thermal printing, and Bluetooth-scale support
- English, Gujarati, and Hindi localization
- Driver/Pickup Supervisor presentation module and test coverage

### Incomplete, provisional, or production-hardening work

- Push notification/Firebase implementation described by the canonical requirements
- WebSocket/live-update nudge; current refresh is lifecycle/reconnect/outbox/pull based
- Production app ids, signing, secrets/environment strategy, and release pipeline
- iOS push/APNs work
- Task completion note persistence on the task itself; canonical guidance currently relies on notification text
- Clear documentation/contract snapshots for repository extensions added after 30 Oct 2026, especially assignments, zones, centre pricing, price requests, and pickup operations
- Security hardening of debug logging: startup code currently prints whether and what access token is stored, and the HTTP debug logger can emit headers/bodies

## Roadmap

### Phase 1 — Contract and reliability baseline

- Keep schema v15 migrations and fresh-install schema aligned.
- Add golden/fixture coverage for every table and latest Bootstrap key.
- Finish validation coverage for every fixed-point write.
- Audit all local mutations for atomic domain-row/outbox/photo transactions.
- Audit conflict reconciliation so no terminal `409` remains permanently failed.
- Remove sensitive token/body logging or guarantee robust redaction.

### Phase 2 — Complete canonical offline behaviour

- Close remaining gaps between screens and canonical SQLite queries.
- Verify scope reset, user reset, ageing deletes, child cleanup, and photo cleanup on real devices.
- Finish Sync Status retry/discard experiences for every entity.
- Exercise long offline sessions, reinstall recovery, duplicate sends, and multi-role/multi-centre cases.

### Phase 3 — Notifications and background freshness

- Add Firebase Core, Messaging, and local notification integration.
- Register/refresh/remove device tokens and implement role-aware deep-link handling.
- Add the three required Android notification channels and permission/settings UX.
- Later add the live socket nudge while retaining Bootstrap as the durable source of truth.

### Phase 4 — Pickup module integration

- Define and document the API/local-data contract for Driver and Pickup Supervisor flows.
- Replace any presentation fixtures with repository-backed state.
- Align module authentication, localization, theme, error handling, and offline sync with the host app.
- Remove the circular package coupling if the module is intended to become independently reusable.

### Phase 5 — Production readiness

- Introduce dev/staging/production configuration rather than a hard-coded endpoint.
- Set final Android/iOS identifiers, icons, entitlements, signing, and store metadata.
- Add CI for formatting, analysis, tests, migration checks, and release builds.
- Add crash/error monitoring, privacy review, log redaction, performance checks, and field-network observability.
- Run accessibility, localization, camera/location permission, low-storage, and low-connectivity acceptance tests.

## Guidance for Claude Code and other coding assistants

Use the following as the working contract:

```text
1. Read AGENTS.md.
2. Read docs/project-context/schema-and-queries.md completely.
3. Read docs/project-context/overall-requirements.md completely.
4. Later-dated canonical changes override older entries.
5. Inspect current implementation and tests before proposing a change.
6. Distinguish canonical EERL behaviour from post-snapshot repository extensions.
7. Screens read SQLite; do not bind application screens directly to API responses.
8. Local mutations and their outbox/photo dependencies are atomic.
9. Never overwrite pending local rows during Bootstrap.
10. Keep foreign-key enforcement off unless the canonical sync design is intentionally replaced.
11. Preserve unrelated working-tree changes; this repository may be actively edited.
12. Add focused tests and run format/analyze/tests in proportion to the change.
```

When unsure about business behaviour, cite the relevant dated requirement and ask before making a material conflicting decision. When code and the snapshot differ, first determine whether the code is a deliberate post-snapshot extension, a partial implementation, or a defect.

## Glossary

| Term | Meaning |
| --- | --- |
| Bootstrap | Incremental server-to-phone synchronization through `GET /mobile/bootstrap`. |
| Outbox | Durable queue of phone-to-server writes. |
| Scope key | Server fingerprint of the user's roles and centres; a change requires scope reset. |
| Active role | Local UI/query role; it is not sent as an API header. |
| Active centre | Locally selected centre used to scope centre-specific screens. |
| Reference table | Small server-owned table delivered as a whole replacement. |
| Record table | Mutable table delivered as incremental upserts/deletes. |
| `sync_state` | Local state such as `synced`, `pending`, or `failed`. |
| Free stock | Stock in hand minus quantities promised to open transfers. |
| D2D | Door-to-door collection channel. |
| MRF | Material Recovery Facility collection channel. |
| Ramp | Ragpicker/ramp collection channel. |

## Source-of-truth summary

Use sources in this order:

1. The user's current instruction.
2. The latest dated applicable rule in the two canonical context snapshots.
3. Current repository implementation and tests for details and post-snapshot extensions.
4. This README as an orientation map, not as a replacement for the full contracts.
