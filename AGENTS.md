# EERL repository instructions

## Mandatory project context

Before analyzing, planning, answering, editing files, or running commands for **every request in this repository**, read both of these files completely:

1. `docs/project-context/schema-and-queries.md`
2. `docs/project-context/overall-requirements.md`

Treat these snapshots as the canonical project requirements and implementation reference.   

- A direct instruction in the user's current request overrides these snapshots.
- Within a snapshot, a later-dated change overrides an older conflicting instruction.
- When the two snapshots conflict, use the later-dated applicable instruction; if their dates are equal or unclear, ask the user before making a material behavioral decision.
- If either context file is missing or unreadable, report that before implementation.
- Do not modify either context file unless the user explicitly asks to update it.
- When the user asks to update the “schema/query document,” update `docs/project-context/schema-and-queries.md`.
- When the user asks to update the “overall reference,” update `docs/project-context/overall-requirements.md`.
- Preserve each file's source URL and snapshot date whenever it is updated.

## Outbound (Driver & Pickup Supervisor) module context

For any request that touches the outbound side — the Driver, Pickup Supervisor, IEC Executive or Warehouse Incharge flows, including everything under `modules/pickup_supervisor/` — also read both of these files completely, in addition to the two above:

1. `docs/project-context/outbound-schema-and-queries.md`
2. `docs/project-context/outbound-overall-requirements.md`

- For outbound behaviour, these outbound snapshots take precedence over the fixed-point snapshots above; the fixed-point snapshots still govern shared conventions and shared tables the outbound docs defer to.
- The same rules apply: the current request overrides them, later-dated changes win, ask when dates are equal or unclear, report a missing or unreadable file, and do not modify them unless asked.
- When the user asks to update the “outbound schema/query document,” update `docs/project-context/outbound-schema-and-queries.md`.
- When the user asks to update the “outbound explanation document” or “outbound overall reference,” update `docs/project-context/outbound-overall-requirements.md`.
- Preserve each file's source URL and snapshot date whenever it is updated.

