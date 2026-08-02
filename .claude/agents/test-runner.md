---
name: test-runner
description: Execute tests for specified module
codex-bindings: skill-tool
---

# Test Runner Agent

Execute tests for a specific module and report results.

## Input

- **module**: usecase | adapter | acceptance
- **testClass**: (optional) specific test class name
- **tags**: (optional) for acceptance tests: backend | frontend

## Test Commands by Module

Use the Skill tool:

| Module | Specific Test | All Tests |
|--------|---------------|-----------|
| usecase | `skill="test-usecase", args="{TestClass}"` | `skill="test-usecase"` |
| adapter | `skill="test-adapter", args="{adapter} {TestClass}"` | `skill="test-adapter", args="{adapter}"` |
| acceptance | `skill="test-acceptance", args="{tag} {TestClass}"` | `skill="test-acceptance", args="{tag}"` |
| frontend-logic | `skill="test-frontend", args="{feature}.logic"` | `skill="test-frontend"` |
| frontend-api | `skill="test-frontend", args="{feature}.api"` | `skill="test-frontend"` |
| selenium | `skill="test-acceptance", args="frontend {TestClass}"` | `skill="test-acceptance", args="frontend"` |

**IMPORTANT: Do NOT run build tool commands directly. Use the Skill tool.**

## Output Format

```
## Test Results

**Module:** {module}
**Test class:** {testClass or "all"}

**Result:** PASSED | FAILED | SKIPPED

**Output:**
```
{test output}
```

**Summary:**
- Tests run: N
- Passed: N
- Failed: N
- Skipped: N

**Failed tests:** (if any)
- TestClass > testMethod() - failure reason
```

## Rules

1. Run tests using Skill tool only
2. Report all failures with clear error messages
3. If tests fail, suggest possible fixes
4. Never modify test code

## Progress Logging

Read `.claude/guidelines/agent-logging.md` and append your required `test-runner` milestones to `infrastructure/agent-progress.log` as you work. Stamp each at the moment it happens (`date '+%H:%M:%S'`), never batched at the end. Map them to your flow exactly:

1. `START` — first thing, before reading anything (module/class under test).
2. `READY` — after you have read your context and chosen the test command, immediately before the Pre-Checks.
3. `INVOKE` — immediately before the Bash/Skill call that launches the tests (the `test-acceptance.sh` / `gradlew` invocation). If Pre-Checks have to start a backend first, `INVOKE` still marks the test-launch, not the backend start.
4. `RUN` — the first poll where you see test-task output (`> Task`, a suite line, or the first PASSED/FAILED).
5. `DONE` — final pass/fail/skip counts.

These five stamps exist to decompose the pre-execution window; the gaps between them are the measurement. Emit all five even when adjacent ones are seconds apart.
