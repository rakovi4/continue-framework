# Data lifecycle & schema

> Apply with `_index.md`. Each entry: **Trigger** / **Mitigation** / **Forced guard**.

## State-machine & lifecycle correctness

- **Trigger.** An entity has a status lifecycle with legal transitions narrower than
  any→any, terminal states (cancelled / expired / closed), transient states (pending /
  reserved) whose exit depends on an event that may never arrive, or a status set
  directly via a raw setter.
- **Mitigation.** Encode the transition graph explicitly and reject edges not in it;
  gate every command on the current status read in the same transaction; model
  terminal states as absorbing; give every transient state a clock-driven
  expiry/exit; pin the initial state at construction so an entity cannot be built into
  a mid-lifecycle or terminal status.
- **Forced guard.** From each terminal state, invoke every state-changing op and assert
  rejection (no mutation, no side effect). Enumerate the transition matrix: every
  illegal (skip / reverse) edge rejected, every legal edge accepted. Advance the clock
  past a transient state's deadline and assert it auto-exits (released / expired).
  Assert a fresh entity starts in exactly the intended state.

## Schema & contract evolution

- **Trigger.** A boundary's two sides evolve independently: a DB migration (add / drop
  / rename column, change type, add constraint) deployed to a fleet where old and new
  code run simultaneously; or a serialized payload / event / stored record read by a
  different code version — an unknown enum value, a newly-added field, a now-absent
  field.
- **Mitigation.** Every change backward- AND forward-compatible across one deploy step:
  additive first (nullable column / new field), backfill, switch reads, drop old in a
  later release — never rename-in-place. Old code tolerates columns/fields it doesn't
  know; new code tolerates rows/payloads written before the change. Define the
  unknown-enum policy explicitly (reject, or map to a preserved UNKNOWN), never
  silently coerce to the first constant or crash the whole message.
- **Forced guard.** Run the previous code version's read/write paths against the new
  schema (N-1 code on N schema) and assert no failure; pin a row written with only old
  columns and assert the new reader returns a valid object with a defined default for
  the new field. Feed a payload with an enum constant the code doesn't define and
  assert the defined policy fires; feed an extra unknown field and assert it's ignored,
  not rejected.

## Destructive & data-loss operations

- **Trigger.** An operation deletes, overwrites, truncates, bulk-updates, or
  irreversibly mutates persisted data — including deleting a parent that owns child
  rows in another table.
- **Mitigation.** Scope the blast radius — filter is mandatory, never optional; a
  missing filter fails closed (affect nothing), not open. Confirm intent for bulk /
  irreversible actions; prefer soft-delete or an audit trail where recovery may be
  needed. Decide per relationship what happens to children on parent delete (cascade /
  nullify FK / restrict), and keep the ORM cascade and the DB `ON DELETE` in agreement.
- **Forced guard.** An absent/empty scope affects zero rows (not all); the operation
  touches only the intended set and leaves neighbours intact. Deleting a parent with
  children yields the exact intended outcome and leaves zero orphaned rows and zero
  dangling references.
