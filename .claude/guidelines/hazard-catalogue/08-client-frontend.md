# Client / frontend

> Apply with `_index.md`. Each entry: **Trigger** / **Mitigation** / **Forced guard**.

## Client-side action safety

- **Trigger.** A UI control fires a server-effecting action and can be activated more
  than once before the response returns (double-click, Enter-repeat,
  back-then-resubmit); or the UI issues overlapping requests for one target (type-ahead,
  toggled filter) whose responses can resolve out of order; or the UI renders a
  mutation locally before the server confirms it.
- **Mitigation.** Disable/lock the control while in flight and carry a client-generated
  idempotency key so duplicates collapse to one effect; bind each render to the
  currently-authoritative request (cancel superseded calls, or drop responses that
  aren't for the latest); treat optimistic renders as provisional and reconcile against
  the server response, rolling back on rejection.
- **Forced guard.** Double-click submit with no wait and assert exactly one server
  effect (one POST, one record). Issue request A then B for one view, resolve B before
  A, assert the UI shows B's result and still does after A's late response. Perform an
  optimistic action whose server call then fails and assert the UI reverts to the
  pre-action state.

## Client as untrusted; non-happy-path UI & unsaved state

- **Trigger.** A rule (validation, permission, a disabled/hidden control, a price /
  quantity constraint) is enforced in the browser and the same request can be replayed
  against the server; OR an async view specifies only the populated case (loading /
  empty / error / partial unstated); OR the user holds un-persisted input that a
  navigation / refresh / session-expiry can discard.
- **Mitigation.** Treat every client check as UX only — the server independently
  re-validates and re-authorizes every request as if the UI did not exist (hiding a
  button is not authorization; a client regex is not validation). Make loading, empty,
  error, and partial first-class states each with defined UI. Detect dirty unsaved
  state and guard the exit (confirm / route-block) or persist drafts.
- **Forced guard.** Bypass the UI — craft the request the client would have blocked (or
  invoke a hidden action for this principal) — and assert the server rejects it (422 /
  403). Stub the data source into each state and assert the matching UI (error →
  message + retry, distinct from a perpetual spinner; empty → empty state, distinct
  from loading). Enter form data, navigate / refresh without saving, assert a
  confirm-guard fires or the data is restored.
