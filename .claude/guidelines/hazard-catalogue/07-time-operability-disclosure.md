# Time, operability & disclosure

> Apply with `_index.md`. Each entry: **Trigger** / **Mitigation** / **Forced guard**.

## Time, timezone & expiry

- **Trigger.** Logic depends on the current time, a deadline, an expiry, a duration, or
  a date crossing a boundary (day, month, DST, timezone).
- **Mitigation.** Use an injectable clock, never a direct system-time read, so time is
  controllable in tests; store and compute in one canonical zone (UTC), convert only
  for display; define behaviour exactly at the boundary (expired-now vs expires-now).
- **Forced guard.** Tests pinning behaviour at the instant of expiry, just before, and
  just after, with the clock fixed. When the logic buckets by date, fix the clock at
  (say) 23:30 in a non-UTC zone and assert the event lands in the intended local-day
  bucket — red if the code buckets on raw UTC and drops it into the wrong day.

## Partial-failure visibility & observability

- **Trigger.** An operation does N things where some can succeed and others fail
  independently (a fan-out, a best-effort loop), OR a path can fail / degrade silently
  — a swallowed exception, a retry that gives up, a fallback that looks identical to
  success, a skipped item, a job that simply doesn't run.
- **Mitigation.** The result carries per-item outcome, not a scalar — "8 done, 2
  failed: [ids]", re-runnable to completion, never a bare success that hides the failed
  two. Every failure and silent fallback emits a distinguishable, attributable signal
  (log with the identifying key, metric, or a persisted error row); degraded mode is
  detectably different from healthy.
- **Forced guard.** Fail item *k* mid-fan-out: assert the response names the failed item
  (not just a count) and a re-run retries only it. Trigger each caught / fallback / skip
  branch and assert it emits its signal (the error counter increments, the log carries
  the entity id) — and that the happy path does NOT emit it.

## Environment & config drift

- **Trigger.** Behaviour depends on a value that differs across environments or is
  supplied out-of-band — an env var, a feature-flag / rollout state, a connection
  string, a limit (pool size, timeout, page size) implicit locally, or anything true in
  dev / test / CI by accident rather than by contract.
- **Mitigation.** Every environment-varying input is named, explicitly defaulted, and
  validated at startup — missing / blank fails fast and loud at boot, never lazily at
  first prod use. Behaviour must not depend on an unstated ambient (a flag default, DB
  case-sensitivity, locale, row order without `ORDER BY`).
- **Forced guard.** A config test that runs with the variable unset and asserts a fast
  explicit boot failure, not a deep null-deref or a silent fallback to a dev value. For
  flagged behaviour, a test of each flag state including the partial-rollout
  combination (on for the write path, off for the read path).

## Secrets, PII & internal-detail disclosure

- **Trigger.** The work touches a credential, token, key, or personal / sensitive data
  — or an error path assembles a response or log from an underlying failure (stack
  trace, SQL fragment, internal id, file path, upstream error).
- **Mitigation.** Never log or echo secrets/PII; never return more than the caller
  needs; keep them out of committed fixtures and out of exception messages that reach a
  client; redact at the boundary. Map every failure to a stable client-safe error
  contract (code + generic message); raw stack traces, SQL, framework defaults, and
  internal identifiers go to the server log keyed by a correlation id, never to the
  caller.
- **Forced guard.** Seed a known sentinel secret/PII value, trigger the failure path,
  and assert that exact sentinel is absent from the response body, the serialized error
  payload, AND captured log output (capture the appender, assert redaction to a fixed
  token — not "doesn't contain the raw string", which passes on any encoding change).
  For each failure family assert the body matches the sanctioned error schema and
  contains no stack-trace markers, SQL keywords, internal class names, or paths.
