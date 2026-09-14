# Agent Progress Logging

When running as a sub-agent (spawned by `/continue` or another orchestrator), write milestone entries to `infrastructure/agent-progress.log` so the user can monitor progress in real time via `tail -f`.

## Format

Append lines using `echo "..." >> infrastructure/agent-progress.log`. One line per milestone.

```
[TIMESTAMP] [AGENT_NAME] PHASE: Brief description
```

- `TIMESTAMP`: `date '+%H:%M:%S'` (time only, same-day context)
- `AGENT_NAME`: agent name from frontmatter (e.g., `red-agent`, `green-agent`, `refactor-agent`)
- `PHASE`: `START`, `READY`, `INVOKE`, `PREDICT`, `RUN`, `PASS`, `FAIL`, `DONE`, `SKIP`, `SCAN`, `FIX`

## Required Milestones by Agent

| Agent | Required milestones |
|-------|-------------------|
| red-agent | START (scenario name), PREDICT (expected failure), RUN (test execution result), DONE (files created) or SKIP (reason) |
| green-agent | START (what to implement), RUN (test result after enabling), DONE (pass count) or FAIL (what broke) |
| refactor-agent | START (target file), SCAN (violations found or clean), FIX (each refactoring applied), RUN (test result), DONE |
| refactor detector clusters (`refactor-design-agent`, `refactor-duplication-agent`, `refactor-mechanics-agent`) | START (cluster + target scope), SCAN (candidate count or `none`), DONE |
| test-review-agent | START (test file), SCAN (issues found or clean), FIX (each assertion tightened), RUN (test result), DONE |
| test-review detector clusters (`test-review-assertions-agent`, `test-review-placement-agent`, `test-review-selenium-agent`, `test-review-statements-agent`) | START (cluster + target scope), SCAN (violation count or `none`), DONE |
| coverage-agent | START (module), RUN (coverage %), DONE (gaps found or clean) |
| consolidation-agent | START (story + scenario count), RUN (each merge: survivor + absorbed count), DONE (before/after count) or SKIP (stop condition + what triggered it) |
| tiering-agent | START (story + scenario count), RUN (Tier 2 admissions evaluated), DONE (the tier split) or SKIP (stop condition + what triggered it) |
| harvest | START (Tier 2 batch size), RUN (green/red split after the first run), PASS or SKIP (per-test baseline verdict: earned / pre-existing `[S]` / inert-deleted), DONE (kept, `[S]`, deleted counts). Its writer sub-agents log as red-agent. |
| test-runner | START (module/class), READY (context read, command chosen), INVOKE (immediately before launching the test command), RUN (first test-task output seen), DONE (pass/fail counts) |

**Why test-runner carries three extra milestones.** START→DONE alone hides the whole
pre-execution window as one opaque gap (measured at 147s in the Task 8 red-acceptance
run, with zero stamps inside it). The three inner stamps split that gap into segments a
later measurement can attribute:

- `START → READY` — subagent spin-up + context/guideline read (the round-trip cost).
- `READY → INVOKE` — pre-checks (health probe) + launching the runner.
- `INVOKE → RUN` — gradle configure + compile, before any test executes.
- `RUN → DONE` — the actual suite execution.

Emit all three even when they land close together — a near-zero segment is itself the
finding (it rules that phase out). Stamp each at the moment it happens, from
`date '+%H:%M:%S'`; never batch them at the end.

**Why the detector clusters share one row each.** The seven read-only detectors are told
to "append your **required** `<name>` milestones" and to read this file for them — so a
missing row does not merely under-document a cluster, it leaves that instruction pointing
at nothing. One row per cluster family fixes that without seven near-identical copies:
within a family the milestone set is genuinely the same, and the only per-agent difference
is which cluster letter the START line names. **Names in a family row are written in full**:
an agent looks its own literal name up here, so a suffix shorthand is both unfindable and
readable as the `AGENT_NAME` to log. Detectors emit no `FIX` and no `RUN` — they
change nothing and run no tests, so a `FIX` line from one of them is a contract violation,
not a milestone.

**An agent with no row is either a defect or deliberate — check which.** This table is the
audit surface for "did the fan-out run", so an agent that logs and is absent from it makes
the log unreadable. But absence is correct for an agent that logs nothing at all:
`prompt-refactor-agent` and `design-review-agent` carry no logging instruction, so they owe
no milestones and get no row. Add a row when you add logging to an agent, not before.

## Rules

- Log BEFORE the action (START, PREDICT) and AFTER the result (RUN, DONE, FAIL)
- Keep descriptions under 80 characters
- Never log sensitive data (tokens, passwords)
- If the log file doesn't exist, the first `echo >>` creates it — no mkdir needed
