# SQLite query coverage

## Table coverage

No table from the latest offline-sync specification is missing. The database
contains all 31 required tables and 22 supporting indexes. Bootstrap applies
every reference, record, child, metadata, photo, and queue table covered by the
specification.

## Implemented in this update

- Database v3 migration normalizes legacy outbox and photo states and removes
  the old `/api/v1/mobile` prefix from stored relative write paths.
- Scope reset clears the latest specified table set and only removes uploaded
  photo rows. Bootstrap will not perform a destructive scope reset while an
  outgoing item remains.
- Outbox sending is registered before Bootstrap and supports ordered sending,
  photo gating, bearer authentication, retry delays, permanent 4xx failures,
  successful 2xx responses, accepted idempotent 409 responses, record sync
  state updates, and same-record failure blocking.
- Photo upload state handling uses `local`, `uploading`, `uploaded`, and
  `failed`, with batches of at most 20.
- Collection draft merge, submit, resubmit, discard, slip allocation, item and
  handover photo references, `SUBMITTED` state, and current write paths are
  implemented atomically.
- Material configuration, vehicle, ragpicker, notification, home, records,
  wallet, stock list, task list, request list, sync-status, and agent-status
  reads were aligned with the latest filters and state names where the current
  repository exposes those operations.

## Query/action flows still missing from the repository or screen wiring

The schema and Bootstrap support these tables, but the application does not yet
expose all of the following local write/query operations:

1. Expense create and supervisor decide actions, including the pre-write
   balance guard and receipt-photo queueing.
2. Cash-request create/decide and expense-category request/create/decide
   actions.
3. Transfer raise, approve, reject, and handover actions, plus the agent stock
   calculation that adds pending submitted collections.
4. Collection supervisor approve/reject writes and the complete joined
   verification-detail query.
5. Task assign, complete, and cancel writes; request raise and answer writes.
6. MRF-person create/edit/status writes and the one-active-supervisor check.
7. Wallet top-up confirmation and the unconfirmed-top-up query.
8. Online-only day-close summary/close calls, lock-time query, and open-draft
   guard query.
9. Notification unread-count, read-all write, and deep-link routing helpers.
10. Role-module lookup, explicit active-role setter, and menu permission query.
11. Ragpicker duplicate-name/deactivation guards and vehicle normalized-plate
    duplicate guard.
12. Supervisor dashboard's complete approvals, transfer, transport, and open
    request counters; verified-history 30-day bound; optional center filters.
13. Failed-outbox discard action and uploaded local-file cleanup.

## API contract verification still required

The upload sender accepts common `uploads/files`, `uploadUrl/upload_url`, and
`fileUrl/file_url` response keys. Its exact batch request/response shape should
be confirmed against an authenticated `/mobile/uploads/batch` response before
photo uploads are considered production-verified.
