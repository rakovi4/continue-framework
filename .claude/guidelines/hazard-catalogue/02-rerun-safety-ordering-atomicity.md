# Re-run safety, ordering & atomicity

> Apply with `_index.md`. Each entry: **Trigger** / **Mitigation** / **Forced guard**.

## Idempotency & re-run safety (both directions)

- **Trigger.** An operation can run more than once for the same logical event: a
  scheduled job re-ticks, a webhook redelivers, a user retries, a batch re-runs after
  a partial failure. Applies **inbound** (we receive the same event twice) and
  **outbound** (we re-attempt an external side effect after a partial failure).
- **Mitigation.** Key the effect by a stable identity so the second run is a no-op,
  not a second effect. Persist the "done" marker in shared storage (not in-memory) so
  it holds across instances and restarts.
- **Forced guard.** Two tests, never one. Inbound: deliver the same event twice,
  assert exactly one effect. Outbound: succeed effect A, fail effect B in the same
  batch, assert A is not re-attempted on the next run. Testing only the inbound
  direction is the canonical miss.

## Compute-then-commit ordering

- **Trigger.** A method interleaves pure computation with a side effect inside a loop
  or sequence — an external call, a write, a send — where the effects are independent
  of one another and only the final result is persisted at the end.
- **Mitigation.** Compute all results upfront as an immutable list, then perform side
  effects; persist each irreversible effect immediately after it succeeds, so a later
  failure cannot discard or duplicate an earlier committed effect.
- **Forced guard.** A test where an item mid-sequence fails: assert every effect before
  it stayed committed and is not retried, and every effect after it is still attempted
  (one failure neither rolls back successes nor blocks the rest). Distinct from
  *Transaction boundary & atomicity*, where the effects must be all-or-nothing.

## Transaction boundary & atomicity

- **Trigger.** A unit of work persists more than one row, or persists and then emits a
  non-DB effect (publish, send, external call), and the design assumes "all of it
  commits or none". Also fires when the transaction boundary is implicit /
  framework-managed, or a side effect is emitted from inside an open transaction.
- **Mitigation.** Make the boundary explicit and align it to the atomic effect:
  everything that must succeed-or-fail together is in one transaction; nothing that
  must survive a rollback (an external send, an emitted event) runs before commit —
  route it through an after-commit hook or outbox. A write outside the boundary (lazy
  flush after close, a second repository in a new transaction) is a partial-commit bug.
- **Forced guard.** Force a failure on the last write in the unit; assert every earlier
  write is absent (full rollback, no orphan rows). Plus: fail the commit after an
  external send was attempted and assert the send did NOT happen (proving send is
  after-commit, not in-transaction).

## External-call failure modes

- **Trigger.** A call leaves the process — third-party API, payment gateway, mail,
  another service. It can time out, return 4xx/5xx, return a malformed body, or
  succeed-but-slow.
- **Mitigation.** Treat every outcome as expected input with defined handling; never
  assume the happy path; never let one failing call abort an independent batch. Every
  blocking wait carries an explicit finite timeout (connect and read) — a missing
  timeout turns a slow dependency into a hung thread that exhausts the pool.
- **Forced guard.** One stub + assertion per failure mode the dependency can produce:
  timeout, error status (4xx "stop" vs 5xx "retry" differ), and malformed/empty body
  — each asserting a defined response (retry / skip / surface), not merely "doesn't
  500". For irreversible calls, the duplicate-effect case is covered by *Idempotency*
  (outbound) — apply it here too.

## Timeout & deadline budget propagation

- **Trigger.** A request fans out through a chain of hops, each with its own timeout —
  *External-call* forces that each hop *has* a timeout, but this fires when the sum of
  the inner per-hop timeouts (× retries) can exceed the caller's own deadline, so the
  caller times out first and the inner work is left orphaned mid-flight.
- **Mitigation.** Propagate a deadline/budget inward: each hop gets the *remaining*
  time, not a fixed local timeout, and cancels when the outer budget is spent. Size
  inner timeouts (and retry counts) so their worst-case total fits inside the outer
  deadline; on caller abort, cancel the in-flight inner work rather than letting it run
  detached.
- **Forced guard.** Set the outer deadline below the worst-case sum of inner
  timeouts × retries and assert the operation aborts cleanly within the outer budget
  with the inner work cancelled (no orphaned in-flight call, no effect committed after
  the caller gave up) — red if the inner hop keeps running past the caller's deadline.
