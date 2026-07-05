# Scale & resource limits

> Apply with `_index.md`. Each entry: **Trigger** / **Mitigation** / **Forced guard**.

## Unbounded size — input & result sets

- **Trigger.** A client-controlled magnitude has no cap — an array/list field, a
  free-text string, an upload body, a batch of ids, a `pageSize` — or a query / list /
  export returns rows whose count grows with accumulated data (`findAll`, "all rows
  for this account").
- **Mitigation.** Bound every magnitude at the boundary: max array length, string
  length, body size, page size (a server cap overriding an over-large client value).
  Cap result sets in the query itself (mandatory pagination / hard `LIMIT`), not after
  fetching; stream when the full set legitimately must be processed — never `toList()`
  an unbounded query.
- **Forced guard.** Send input one past the limit (array of N+1, string of max+1,
  `pageSize=1000000`) and assert a 4xx / clamp, not a 500 or a slow success. Seed far
  more rows than any page size and assert the endpoint returns at most the cap, never
  all of them.

## Work amplification — N+1, fan-out, super-linear

- **Trigger.** One request triggers work scaling with input or data size — a list whose
  every element spawns its own DB/API call (N+1), a batch endpoint, a nested loop /
  join over two growable sets, or a regex / parser / recursion whose cost is
  super-linear in input length (ReDoS, deep nesting).
- **Mitigation.** Bound the input before the work; collapse N+1 into a single bulk
  fetch (`WHERE id IN (...)` / join) rather than per-item calls; avoid super-linear
  algorithms on untrusted input; bound regex backtracking and recursion depth. One
  request's cost must have a ceiling the caller cannot push past.
- **Forced guard.** With a large valid input (N in the thousands), assert the storage
  port is queried a constant number of times regardless of N (proving no N+1), or a
  hard rejection above the cap. For super-linear paths, a pathological-input test
  asserting completion within a wall-clock bound.

## Resource exhaustion, leaks & backpressure

- **Trigger.** Code acquires a finite / pooled / OS-limited resource in a repeated path
  — DB connection, thread, file descriptor, socket, temp file — or grows an in-memory
  structure over time (cache, accumulator, retry list, buffered upload) without a bound.
- **Mitigation.** Acquire in a scope that guarantees release on every exit including the
  error path (try-with-resources / context manager), never a bare acquire whose release
  an exception can skip; bound the pool and define empty-pool behaviour
  (block-with-timeout or reject). Bound every long-lived structure (cache max size +
  eviction; flush/checkpoint a large stream incrementally; stream large payloads in
  fixed chunks). Reuse long-lived clients, don't create per-call.
- **Forced guard.** Drive the acquiring path many times *including the failure branch*
  and assert the live resource count (open connections, handles, pool checked-out)
  returns to baseline — a leak makes it climb monotonically. Drive a cache with many
  distinct keys and assert it evicts past its cap rather than growing to input
  cardinality.

## Retry storms & thundering herd

- **Trigger.** Many clients (or many in-flight requests) hit the same dependency and
  react to a transient failure or a synchronized event in lockstep — fixed-interval
  retries with no jitter, a cache entry that expires for everyone at once (stampede), a
  cold-start fan-out, or every instance polling on the same tick.
- **Mitigation.** Spread the load: exponential backoff with randomized jitter and a
  capped attempt count on retries; stagger or single-flight a cache refill so one miss
  doesn't launch N identical recomputes; jitter scheduled polls. A recovered dependency
  must not be re-killed by every client retrying at the same instant.
- **Forced guard.** Drive M concurrent callers through one transient dependency failure
  and assert their retries are spread, not synchronized (backoff + jitter observed,
  attempts capped) — red if all M re-issue on the same tick. For a cache stampede,
  expire a hot key and assert only one recompute fires while the rest wait or serve
  stale, not M simultaneous recomputes.

## Pagination & cursor stability

- **Trigger.** A list endpoint or batch reader pages across multiple round-trips
  (offset/limit, page number, cursor) while rows can be inserted / deleted / reordered
  between fetches, or sorts by a non-unique key.
- **Mitigation.** Page by a stable, unique, immutable key (keyset / seek), not offset —
  offset shifts when rows change mid-iteration, silently skipping or duplicating rows;
  make ordering total via a unique tiebreaker; a process-every-row batch needs a
  snapshot or monotonic cursor, not `LIMIT/OFFSET` over live data.
- **Forced guard.** Read page 1, insert (or delete) a row sorting into an
  already-fetched window, read page 2; assert the union of pages covers each element
  exactly once — none duplicated, none skipped. Two rows with equal sort keys return in
  a stable total order across repeated reads.
