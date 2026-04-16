---
name: test-all
description: Run all tests - unit tests in parallel, then acceptance tests with backend. Use when user wants to run the full test suite or mentions /test-all command.
---

# Run All Tests

Runs the complete test suite: unit tests in parallel, then acceptance tests.

## Setup

Read `ProductSpecification/technology.md` Conventions table for:
- **Backend test command** pattern (with module substitution)
- **Frontend test command**
- **Acceptance test command**

Discover backend adapter modules by listing directories under `backend/adapters/`.

## Workflow

### Phase 1: Run Unit Tests in Parallel

Run ALL of these commands in parallel using multiple Bash tool calls in a single message:
- Backend usecase tests: `{Backend test command}` with module = usecase
- Backend adapter tests: one `{Backend test command}` per adapter module discovered
- Frontend tests: `{Frontend test command}`

Wait for all to complete. If any fail, report failures and STOP.

### Phase 2: Start Backend

Use the Skill tool to invoke `/run-backend`:
```
Skill tool: skill="run-backend"
```

Wait for backend to start.

### Phase 3: Run Acceptance Tests

```
{Acceptance test command} for backend tests
```

### Phase 4: Stop Backend

Use the Skill tool to invoke `/stop-backend`:
```
Skill tool: skill="stop-backend"
```

## Output

Report summary:
- Backend unit tests: PASS/FAIL (usecase + each adapter)
- Frontend unit tests: PASS/FAIL
- Acceptance tests: PASS/FAIL (with details if failed)
- Overall: PASS/FAIL
