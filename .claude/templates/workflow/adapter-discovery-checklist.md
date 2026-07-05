# Adapter Discovery Checklist

Run this checklist when the `[ ] adapters-discovery` step is reached. Walk all three checks — each can independently produce `red-adapter X` / `green-adapter X` steps.

## Input

- Usecase class for the current scenario
- The scenario's disabled acceptance test (from the `red-acceptance` step)

## Check 1: Outbound Adapters (Storage, Clients, etc.)

Read the usecase constructor. For each injected port:

1. Find the adapter module that implements it (e.g., `BoardStorage` → `h2`)
2. Check the adapter implementation against what this scenario needs:
   - **Missing**: no implementation exists → add `red-adapter {module}` / `green-adapter {module}`
   - **Stubbed**: method throws the not-implemented marker → add steps
   - **Insufficient**: implementation exists from a prior scenario but doesn't support the current one (e.g., returns hardcoded data instead of reading from storage, persists a subset of fields, ignores a new parameter). Read the acceptance test to understand what end-to-end behavior is expected — if the adapter can't support it, add steps.
   - **Sufficient**: implementation already handles this scenario's needs → `[S]` with reason
3. Check each method the usecase calls on the port, not just the port as a whole — one method may be sufficient while another is stubbed or insufficient
4. **Derive each adapter test from the real usecase flow — reproduce it, don't shortcut it.** Look at how the scenario's data actually moves through the usecases: it is written by one usecase and read by another — a writer usecase persists it through one storage port, and a separate reader usecase queries it back through a different storage port. The adapter test must reproduce that flow at the persistence layer — **write through the writer usecase's port, read through the reader usecase's port** (save through the first storage, then assert through the second storage's finder/selection method). That write-here-read-there shape is the convention, not a collapse to avoid: it proves the data actually crosses between the two real code paths. A same-port round-trip (save → read-back on one storage) only pins that one storage's own mapping — it does NOT exercise the cross-usecase flow. So when the write and the read live in different usecases through different ports, emit a `red-adapter` / `green-adapter` pair that runs the actual write-port → read-port flow. The anti-pattern is testing only the round-trip and deferring the real cross-usecase selection/query to `green-acceptance` — a coarse black-box net, not a substitute for a focused adapter test on the riskiest query logic.

## Check 2: Domain Exceptions → Inbound Adapter Error Handling

List domain exceptions thrown by the usecase or its domain objects.

1. Identify which inbound adapter invokes this usecase (REST controller, message listener, CLI handler, etc.)
2. For each exception, check if that adapter's error handler already maps it to an appropriate error response
3. If unmapped → add `red-adapter {module}` / `green-adapter {module}`
4. If already mapped → `[S]` with reason

## Check 3: Inbound Adapter Response Shape

**This is the most commonly missed check.** The inbound adapter may already invoke the usecase but return the wrong shape to the caller (e.g., no body when the acceptance test expects a response).

1. Read the scenario's disabled acceptance test — note:
   - What response status/code it expects
   - What response fields it asserts (id, title, timestamp, etc.)
   - The test disable marker's reason text — it often states exactly what's missing
2. Read the current inbound adapter method that invokes this usecase — note:
   - Return type (no body vs response DTO)
   - Which fields the response includes (if any)
3. Compare:
   - Adapter returns no body but test expects one → needs adapter steps
   - Response exists but is missing fields the test asserts → needs adapter steps
   - Response matches test expectations → `[S]`

### Example: missed happy-path

**Scenario:** "Create task with title only" — acceptance test expects `{ id, title, position, createdAt }`.
**Inbound adapter:** endpoint returns no body, only a 201 status.
**Gap:** No response body. Acceptance test will fail on response parsing.
**Fix:** Add `red-adapter {module}` / `green-adapter {module}` for the inbound adapter.

## Output

For each check, produce one line:

```
Check 1 (ports): {adapter} — {reason}
Check 2 (exceptions): {inbound adapter} — {reason} OR [S] — {reason}
Check 3 (response shape): {inbound adapter} — {reason} OR [S] — {reason}
```

Check 1 produces **one line per usecase data-flow**, not per port. When the scenario's data is written by one usecase and read by another, that write→read flow is a single adapter test (write via the writer's port, read via the reader's port) — one line, one pair. List each such flow on its own line with its own `red-adapter X` / `green-adapter X` steps. Never reduce a write-here-read-there flow to a same-port round-trip and defer the real cross-usecase read to `green-acceptance`.

Then insert the concrete `red-adapter X` / `green-adapter X` steps into progress.md below `adapters-discovery`.
