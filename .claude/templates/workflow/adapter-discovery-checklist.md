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

Then insert the concrete `red-adapter X` / `green-adapter X` steps into progress.md below `adapters-discovery`.
