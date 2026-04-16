---
name: test-acceptance
description: Run acceptance tests (backend API or frontend UI). Use when user wants to run E2E acceptance tests or mentions /test-acceptance command.
---

# Run Acceptance Tests

## Pre-Checks

Read ports from `infrastructure/.env` and verify required services are up **before** running tests.

### Backend (always required)

Check the health endpoint (see `technology.md` Conventions table for path):
```bash
source infrastructure/.env && curl -s -o /dev/null -w "%{http_code}" http://localhost:$BACKEND_PORT{health_endpoint} 2>/dev/null || echo "UNAVAILABLE"
```

- `200` → OK.
- `UNAVAILABLE` or non-200 → start backend first: `Skill tool: skill="run-backend"`. Wait for startup.

### Frontend (required when argument is `frontend` or a frontend test class)

```bash
source infrastructure/.env && curl -s -o /dev/null -w "%{http_code}" http://localhost:$FRONTEND_PORT 2>/dev/null || echo "UNAVAILABLE"
```

- `200` → OK.
- `UNAVAILABLE` or non-200 → start frontend first: `Skill tool: skill="run-frontend"`. Wait for startup.

## Action

Run via script (loads ports from `.env`).

```bash
infrastructure/scripts/test-acceptance.sh
```

With arguments:
- `backend` → runs all `backendTest`
- `backend {ClassName}` → runs only `backendTest --tests "*{ClassName}*"`
- `frontend` → runs all `frontendTest`
- `frontend {ClassName}` → runs only `frontendTest --tests "*{ClassName}*"`
- `{ClassName}` → runs `test --tests "*{ClassName}*"`
- (no args) → runs all tests

**Always pass the test class name** when running a specific test — never run the full suite just to check one test. The full suite takes ~14 minutes.

## Execution Strategy

Follow `tdd-rules.md` "Stop on first failure" protocol:

1. **Launch in background:** `run_in_background: true` — note the output file path from the result. Store `SEEN=0` to track lines already shown.
2. **Poll with separate Bash calls:** Make repeated **individual** Bash calls (NOT a loop inside one call — that hides output until the loop finishes). Each call checks for new lines and the terminal signal:
   ```bash
   TOTAL=$(wc -l < "$OUTPUT" 2>/dev/null || echo 0) && sed -n "$((SEEN+1)),${TOTAL}p" "$OUTPUT" | grep -E "PASSED|FAILED|> Task|tests completed|BUILD|Results:|Tests run:" ; grep -c -E "BUILD SUCCESSFUL|BUILD FAILED" "$OUTPUT" 2>/dev/null && echo "DONE" || echo "RUNNING"
   ```
   After each call: update SEEN, check if DONE, if still RUNNING wait ~5s then call again. Repeat until DONE or task completes.
   **CRITICAL:** Each check must be a separate tool call so the user sees output immediately.
3. **If BUILD SUCCESSFUL** → read output file, report pass counts. Done.
4. **If FAILED** → stop suite (`TaskStop`), read stack trace from the output file, investigate root cause. Do NOT collect further failures.
   - **Compilation error** (compile task FAILED) → read error lines, report immediately. No need to check infrastructure.
   - **Infrastructure error** (`WebDriverException`, `Connection reset`) → re-check backend/frontend health.
   - **Application error** (assertion failure, wrong status) → investigate and fix.

## Output

Report the test results from output. Always include pass/fail counts.
