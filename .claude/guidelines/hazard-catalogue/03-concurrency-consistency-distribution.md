# Concurrency, consistency & distribution

> Apply with `_index.md`. Each entry: **Trigger** / **Mitigation** / **Forced guard**.

## Concurrency & multi-instance

- **Trigger.** State is read-modify-written, or "have I done this?" is checked, while
  more than one instance or thread runs the same code. The backend runs as multiple
  instances by default.
- **Mitigation.** No correctness-bearing state in-memory (maps, statics, local caches)
  — it diverges across instances. Use the database for anything that must be
  consistent; guard read-modify-write with a transaction, lock, or conditional/atomic
  update.
- **Forced guard.** A test that forces the two operations to interleave at the
  read-modify-write window — not "run two threads and hope" (which passes flakily even
  on a broken guard). Drive both through a fixed point (latch/barrier between read and
  write), or assert at the storage layer that the update is conditional/atomic (a
  stale-version writer is rejected). A guard that passes 99% of the time is a failed
  guard, not a passing one. This is the same-instant, in-process interleave; if your
  test separates the two reads by a request boundary (read, render, user edits, save),
  you are in the wrong class — that is *Lost update / stale overwrite*.

## Lost update / stale overwrite

- **Trigger.** Code reads an entity, mutates a field based on the read value, and
  writes it back (`load → set → save`), where the two reads can be separated by user
  think-time across requests — counters, balances, status fields, edit-a-record-over-
  HTTP.
- **Mitigation.** Never blind-write a value derived from a possibly-stale read. Use an
  optimistic version/ETag check (`UPDATE … WHERE version = :seen`, fail/retry on zero
  rows), a single-statement atomic mutation (`SET x = x + :delta`), or a pessimistic
  lock held across the read-modify-write. The "rows affected = 0" outcome must be
  handled, not ignored.
- **Forced guard.** Load the same entity twice (two stale copies), apply a different
  mutation to each, save both in sequence; assert the second save is rejected (version
  conflict / 409) or both deltas land (atomic) — never "last write silently wins,
  first update lost". This is the cross-request read-render-edit-save gap an ORM
  `save()` inside a transaction still loses; if your test drives a same-instant
  in-process latch instead, you are in the wrong class — that is *Concurrency &
  multi-instance*.

## Read-after-write & cache staleness

- **Trigger.** A write is followed by a read expected to reflect it, where the read may
  hit a different source than the write — a read replica behind async replication, a
  cache over the store, a denormalized/CQRS read model, or a different connection that
  has not seen the commit.
- **Mitigation.** Define each read path's consistency requirement. Reads that must
  observe a just-committed write go to the primary (or the same transaction), not a
  replica/cache. Caches are invalidated/updated as part of the write path, not on a
  TTL the caller can race; where async propagation is unavoidable, the contract states
  the staleness window rather than implying immediacy.
- **Forced guard.** Stale the replica/cache, write, then read through the path the
  product actually uses to confirm; assert the new value. If the path is intentionally
  eventually-consistent, assert the *specific* documented window (stale for ≤ N, fresh
  after N) — not merely that "some staleness is documented", which lets any lag pass.
  Execute against the real replica/cache topology or a double that models lag, never a
  single in-memory store that hides the split.

## Async delivery: ordering, duplication & poison messages

- **Trigger.** Work flows over a queue/topic/scheduler: events for one entity assumed
  in produced order, at-least-once delivery, a message that always fails to process, a
  DB-write-plus-publish that must agree, or a periodic job whose run can outlast its
  interval.
- **Mitigation.** Don't depend on arrival order — carry a monotonic version/sequence
  and reject any event older than applied state (last-writer-by-version, not
  by-arrival). Bound retries and route permanent failures to a dead-letter
  destination, advancing past them so one bad record can't block the partition. Tie an
  event's existence to its row via a transactional outbox (never publish inside the DB
  transaction, never after commit without recovery). Make a periodic run mutually
  exclusive with itself via a DB-backed lease with expiry.
- **Forced guard.** Deliver events for one key in reverse order, assert final state
  equals the highest-version event (stale = no-op). Feed an always-failing message,
  assert it dead-letters after the attempt limit AND a valid message behind it still
  processes. Commit the row but drop the publish, assert the event is still eventually
  delivered (this class owns the outbox eventual-delivery guard; *Transaction boundary*
  asserts the narrower send-did-not-happen-before-commit, *Idempotency* the
  not-re-attempted — same setup, three different assertions). Start a second job
  activation while the first runs, assert disjoint / no double work.
