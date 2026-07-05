# Agent Progress Logging

When running as a sub-agent (spawned by `/continue` or another orchestrator), write milestone entries to `infrastructure/agent-progress.log` so the user can monitor progress in real time via `tail -f`.

## Format

Append lines using `echo "..." >> infrastructure/agent-progress.log`. One line per milestone.

```
[TIMESTAMP] [AGENT_NAME] PHASE: Brief description
```

- `TIMESTAMP`: `date '+%H:%M:%S'` (time only, same-day context)
- `AGENT_NAME`: agent name from frontmatter (e.g., `red-agent`, `green-agent`, `refactor-agent`)
- `PHASE`: `START`, `PREDICT`, `RUN`, `PASS`, `FAIL`, `DONE`, `SKIP`, `SCAN`, `FIX`

## Required Milestones by Agent

| Agent | Required milestones |
|-------|-------------------|
| red-agent | START (scenario name), PREDICT (expected failure), RUN (test execution result), DONE (files created) or SKIP (reason) |
| green-agent | START (what to implement), RUN (test result after enabling), DONE (pass count) or FAIL (what broke) |
| refactor-agent | START (target file), SCAN (violations found or clean), FIX (each refactoring applied), RUN (test result), DONE |
| test-review-agent | START (test file), SCAN (issues found or clean), FIX (each assertion tightened), RUN (test result), DONE |
| coverage-agent | START (module), RUN (coverage %), DONE (gaps found or clean) |
| test-runner | START (module/class), DONE (pass/fail counts) |

## Rules

- Log BEFORE the action (START, PREDICT) and AFTER the result (RUN, DONE, FAIL)
- Keep descriptions under 80 characters
- Never log sensitive data (tokens, passwords)
- If the log file doesn't exist, the first `echo >>` creates it — no mkdir needed
