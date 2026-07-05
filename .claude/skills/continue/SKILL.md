---
name: continue
description: Continue working on a story or task by reading progress.md, executing the next work unit, and updating progress. Use when user wants to resume story/task work or mentions /continue command.
---

# /continue - Resume Development

## Workflow

1. **Identify work item** from argument
2. **Backlog promotion** -- if the story row is in the **Backlog** table in `ProductSpecification/stories.md`, move it to **In Progress** before proceeding
3. **Read progress** file, bootstrap if missing (stories only)
4. **Find next step** -- first `[~]` or `[ ]` entry
5. **Read journey context** -- read `carryover.md` (story root, if it exists) and the current scenario's summary file (`summaries/{scenario-slug}.md`, if it exists). Treat both as additional context for the work unit -- they preserve predictions, decisions, surprises, and quirks from prior conversations. `/continue` only READS these files; it never writes them (the `/handoff` skill is the sole writer).
6. **Load ADR context** -- check for `decisions/*-decision.md` files in the story directory. If any exist AND the current step references the ADR (via "see ADR" annotation or matching scenario), read it. ADRs contain architectural decisions, schema changes, edge cases, and implementation guidance that the work unit needs.
7. **Execute one work unit** -- dispatch sub-skills per tables below
8. **Discovery gates** -- when the next step is `[ ] adapters-discovery`, read usecase constructor to identify ports and map to adapters (see `.claude/guidelines/workflow-detail.md`). Mark `[x] adapters-discovery`, insert concrete steps below it, commit progress.md. The bug-task `[ ] steps discovery` gate resolves the same way via its Work Unit Dispatch row -- run its hazard-catalogue fan-out, then insert the TDD steps.
9. **Update progress** -- mark completed, advance next
10. **Update stories.md** -- for stories only, update the phase columns in `ProductSpecification/stories.md` (see below)
11. **Behavior commit** -- commit the work unit's behavior change (include progress.md, and `ProductSpecification/stories.md` for stories). If ALL checkboxes are now `[x]` or `[S]` (no `[ ]` or `[~]` remaining), move the task folder to `ProductSpecification/tasks/done/` and include the move in this commit.
12. **Refactor batch + pre-commit review passes** -- dispatch `/refactor` and the two review passes (`agent-review-agent` + `premortem-agent`) concurrently over the behavior commit (see "Pre-Commit Review Passes" below); the passes are non-gating -- collect their verdicts for the report. Then the refactor commit (`/refactor`'s changes only; skipped if it changed nothing). Skip both `/refactor` and the passes for a progress-only behavior commit. Fold the review verdicts into the stop-and-report.

The high-level lifecycle, status markers, and atomic-unit rule are in `.claude/rules/workflow.md`; the detailed scenario sequences, adapter-discovery procedure, progress mechanics, and task sequences are in `.claude/guidelines/workflow-detail.md`. Progress file format examples are in `.claude/templates/workflow/progress-format.md`.

## Resolving the Argument

| Argument | Resolution |
|----------|------------|
| `task N` | Find `ProductSpecification/tasks/N-*/progress.md` |
| Bare number or name | Resolve story via `ProductSpecification/stories.md` then `ProductSpecification/stories/NN-story-name/progress.md` |
| No argument | Scan recent git log for `Story N` or `Task N` references; most recent wins |

**File lookup:** Use `find` via Bash (not Glob) when searching for progress files or story folders. Glob is unreliable on Windows/MINGW with large `.gitignore` files. For story resolution, derive the folder name from `ProductSpecification/stories.md` (e.g., story 5 "Create a task" → `05-create-task`) and Read the progress file directly. Use `ls` or `find` via Bash only when the folder name is ambiguous.

## Work Unit Dispatch

Each progress.md checkbox maps to sub-skills. Dispatch per `.claude/guidelines/workflow-detail.md` sequences. **This table applies equally to stories AND tasks — never skip `/test-review` or `/refactor` for task steps.**

| Checkbox | Sub-skills |
|----------|-----------|
| Spec items (`interview`, `story`, `mockups`, `api-spec`, `test-spec`) | `/{item}` then commit |
| `root cause analysis` (bug tasks) | Run inline (no subagent): `/rca` — re-verify prior assumptions, test competing hypotheses, confirm the cause with real data, record findings in `spec.md`, mark `[x]` → progress-only commit |
| `design` | `/design-preview` → user approves (optionally with ADR) or `/architecture` → commit (if ADR produced) |
| `red-*` (acceptance, usecase, adapter, selenium, frontend, frontend-api) | `red-agent.md` → `/test-review` → commit → `/refactor` → commit |
| `green-usecase`, `green-adapter X` | `green-agent.md` → `/test-coverage {module} --focus` → commit → `/refactor` → commit |
| `adapters-discovery` | Load `.claude/templates/workflow/adapter-discovery-checklist.md`, run all 3 checks (ports, exceptions, response shape), mark `[x] adapters-discovery`, insert concrete `red-adapter X` / `green-adapter X` steps (or `[S]`) → commit progress.md |
| `steps discovery` (bug tasks) | Run the hazard-catalogue fan-out per `.claude/guidelines/workflow-detail.md` "Hazard scan at steps discovery" (one `hazard-scan-agent` per group in `_index.md`, concurrently, then a synthesis pass over the seams); fold each fired-trigger GAP in as a discovered `red-*` step or dismiss it with a reason (an unresolved GAP blocks insertion); resolve the gate with its REQUIRED scan record `[x] steps discovery (scope: <layers>; scanned all _index.md groups; GAPs: <folded as red-* / dismissed: reason / none fired>)` — a bare `[x] steps discovery` with no `scanned`/`GAPs` clause is an unscanned gate, not a valid completion; insert the concrete TDD steps below the gate → commit progress.md |
| `green-acceptance` | Run inline (no subagent): read `green-agent.md` workflow, load acceptance implementation template, enable the disabled test (remove disable marker — only allowed test change), run acceptance tests, verify GREEN → commit |
| `green-frontend`, `green-frontend-api` | `green-agent.md` → commit → `/refactor` → commit |
| `green-selenium` | `/run-backend` → `/run-frontend` → `green-agent.md` (remove-marker-only: no production code, no Statements changes, no backend changes — if test fails, STOP and report) → commit |
| `align-design` | Build component → `/align-design` → `/design-review` (MANDATORY) → `/test-coverage frontend --focus` → commit → `/refactor` → `/align-design` verify-only → commit |
| `demo` | `/demo {scenario_test_class}` then progress-only commit |
| `refactor usecase` / `refactor (...)` | Apply change then run affected tests then commit |
| QA `## Cases` checkbox | **No dispatch.** Report the next unchecked case to the user and stop -- the tester verifies it manually against the target environment, then ticks the box (or files a separate bug task if it fails) on their own. |

## Stop and Report

A single `/continue` invocation executes exactly ONE work unit. Within that work unit, don't pause between sub-skills. A `/refactor` work unit ends in two commits — behavior commit, then separate refactor commit; STOP only after the final commit, NEVER after the behavior commit while `/refactor` is still pending. The two review passes run just **before** the work unit's final commit, in the `/refactor` batch (skipped for progress-only commits). Once the final commit lands, stop and report: completed step, test results (pass/fail counts from every test run in the work unit), the review-pass verdicts, next step, progress fraction, how to continue. Do NOT read the next `[ ]` step and keep going.

End the report with a one-line `/plain` hint (e.g. `Press /plain to have this report re-explained in plain words`) so the user has a button to press when the technical summary didn't land. This is only a pointer -- never invoke `/plain` yourself; it is a manual button the user presses.

**Test results:** Collect pass/fail counts from every sub-skill that runs tests (red-agent, green-agent, test-coverage, refactor). Include them in the final report as a summary line, e.g., `Tests: 15 passed, 0 failed` or `Tests: 14 passed, 1 failed`. When multiple test suites ran, report each separately.

**Red prediction (mandatory for red-* work units):** When the work unit included any red-* phase, copy the red-agent's **Predicted failure**, **Actual failure**, and **Comparison** sections verbatim into the final report — same wording as the Output Summary Format in `.claude/templates/workflow/red-phase-formats.md`. Do NOT collapse to phrases like "test passed as predicted" or "prediction matched" — the user must see both the prediction and the actual result side by side, in their own labelled sections, so the match can be audited without re-reading the agent's return.

**Review-pass findings (mandatory when the review passes ran):** include the `agent-review` and `premortem` verdicts. PASS → one line each (`agent-review: PASS`, `premortem: PASS`). CONCERNS/BLOCK → list each finding with its place in the diff and the named missing guard, as a follow-up the user can act on. These never revert the commit; they are surfaced, not auto-fixed.

## Pre-Commit Review Passes

After the **behavior commit** lands, and concurrently with `/refactor`, dispatch two
**fresh-context** passes over that commit, **in one message as two concurrent Agent
calls** — so they overlap `/refactor` instead of adding a serial tail to every work unit:

- `agent-review-agent` — audits what the work *contains*: any problem, unnarrowed.
- `premortem-agent` — imagines what the work is *missing*: the incident it would cause.

**Input is the behavior commit, not a working-tree snapshot.** The behavior commit is
already an immutable freeze of the reviewable work — the primary change plus the
`progress.md`/`stories.md` advances — so pass each pass the behavior commit's range (`HEAD`
after the behavior commit, or `HEAD~N..HEAD` if the behavior phase produced N commits) plus
one line of context on what the unit did. Reading a committed range is what makes the
overlap safe: `/refactor` edits the live tree concurrently, but the passes read the
immutable commit, so there is no read/write race and no snapshot file to manage. Because
they read the behavior commit, the passes do **not** see `/refactor`'s changes — an accepted
residual: `/refactor` is behavior-preserving and its own test run gates it green before the
refactor commit, so the only thing left unreviewed is a structural delta that changes no
behavior.

**Non-gating.** The refactor commit lands regardless of verdict: a CONCERNS or BLOCK
surfaces in the stop-and-report as a follow-up — it does NOT block, revert, or amend either
commit. PASS is silent. Running them in the `/refactor` batch changes *when* they read,
never their authority — they stay a surfacing layer, not a gate. The only two gates that
block a commit remain `/test-review` and `/refactor`.

Skip the passes only for a progress-only commit — a checkbox flip has nothing to audit.
Run them on any unit that ships reviewable content: code, tests, specs, or prompt
artifacts. When a unit has no `/refactor` step (e.g. `green-acceptance`, `green-selenium`),
it produces a single commit; dispatch the two passes over that commit right after it lands.

Why these run as a separate layer — defense-in-depth that differs *in kind* from the
in-loop `/test-review` and `/refactor` — is in
`.claude/guidelines/workflow-detail.md` "Pre-Commit Review Passes".

## Pre-Commit Checklist

Before the behavior commit, verify: (1) primary skill ran, (2) `/test-review` ran (red phases), (3) `/test-coverage` ran (`green-usecase`/`green-adapter`). `/refactor` and the two review passes are not in the behavior commit — they run after, in the `/refactor` batch, before the final commit. Before the final commit, verify: (4) `/refactor` ran (all phases except `green-acceptance`/`green-selenium`/`demo`/spec items), (5) the two review passes ran over the behavior commit (every reviewable-content unit; skip only progress-only commits). If `/refactor` or a review pass was skipped -- run it before the final commit.

## Sub-Skill Dispatch

ALL sub-skills dispatch via Agent tool for context isolation:

| Sub-skill | Dispatch method |
|-----------|----------------|
| `red-*` | `Agent tool` (subagent_type: `red-agent`) — pass layer, story folder path, scenario name, and ADR content (if loaded) |
| `green-*` (except `green-acceptance`) | `Agent tool` (subagent_type: `green-agent`) — pass layer, story folder path, scenario name, and ADR content (if loaded) |
| `green-acceptance` | **Inline** — no subagent. Main agent reads `green-agent.md`, loads acceptance template, enables the test, runs it. Full visibility for user. |
| `/refactor` | `Agent tool` (subagent_type: `refactor-agent`) |
| `/test-review` | `Agent tool` (subagent_type: `test-review-agent`) |
| `/test-coverage` | `Agent tool` (subagent_type: `coverage-agent`) |
| `agent-review` (pre-commit) | `Agent tool` (subagent_type: `agent-review-agent`) — pass the behavior commit's range (`HEAD`, or `HEAD~N..HEAD`) + one line of intent. Dispatched in the `/refactor` batch, concurrently with premortem. |
| `premortem` (pre-commit) | `Agent tool` (subagent_type: `premortem-agent`) — pass the behavior commit's range (`HEAD`, or `HEAD~N..HEAD`) + one line of intent. Dispatched in the `/refactor` batch, concurrently with agent-review. |

Derive the layer from the checkbox (e.g., `red-adapter h2` → layer `h2`, `green-usecase` → layer `usecase`). Both red-agent and green-agent receive: layer, story folder path, scenario name, and ADR content (if loaded in step 5). The agent resolves test files and templates from its own workflow.

**CHAINING: After each sub-step completes (Agent tool return), echo a 1-2 line status summary (agent name, outcome, pass/fail counts) to the user, then immediately dispatch the next sub-step. Do NOT wait for user input between sub-steps — the echo is informational only. (The two review passes are the exception: they dispatch together in one message, in the same batch as `/refactor`.)**

**AGENT LOG: Before the first agent dispatch, clear the log: `> infrastructure/agent-progress.log`. The two review passes log too (they run in the `/refactor` batch, just before the final commit); after the final commit, include the log contents in the stop-and-report summary.**

**LOG REMINDER: Every time you dispatch a sub-agent (Agent tool call), output this line immediately before the call:**
```
> Dispatching {agent-name}. Live progress: tail -f infrastructure/agent-progress.log
```
**This reminds the user where to watch. The line appears in conversation output before the agent starts, so the user can open a terminal and tail the log while the agent works.**

## Rules

- Execute exactly ONE work unit per invocation — a work unit includes ALL sub-skills through the final commit, including the two review passes that run just before it (in the `/refactor` batch). Never stop between sub-skills.
- A `/refactor` work unit ends in two commits: the behavior commit (carries the `progress.md` advance), then a separate refactor commit (skipped if `/refactor` changed nothing). Otherwise one commit carries `progress.md`.
- Task commit prefix: `task:` (e.g., `task: red-adapter h2 (Task 1, Step 1)`)
- If a sub-skill fails, stop immediately -- do NOT mark the step complete
- Mandatory sub-skills per phase: see `.claude/guidelines/workflow-detail.md` sequences

## Updating stories.md

After updating `progress.md` for a **story** (not tasks), update the story's row in `ProductSpecification/stories.md` to reflect current phase status. The file has columns: `Spec | Backend | Integration | Frontend | Security | Load | Infra | Status`.

**Phase column values** — derive from `progress.md` sections:
- `✅` — all checkboxes in that section are `[x]` or `[S]`
- `🔧` — section has at least one `[~]` or `[ ]` checkbox (work in progress or next up within the current active lifecycle phase)
- `—` — section exists but no work started yet (all `[ ]`)
- `n/a` — phase not applicable (test spec file says "No tests" or story has no scenarios for that phase)
- `·` — no story folder or no progress file exists

**Tests and % columns** — recount after every progress.md update:
- **Total** = number of `### ` scenario headings in progress.md (not `## ` section headers)
- **Done** = scenarios where ALL checkboxes are `[x]` or `[S]` (no `[ ]` or `[~]` remaining)
- **%** = `round(done / total * 100)`
- Format: `done/total` in Tests column, `N%` in % column
- Do NOT add a Total row — it causes merge conflicts

**Story completion** — when all scenarios reach 100% (Tests column = `total/total`, % = `100%`), move the story row from the **In Progress** table to the **Done** table in `ProductSpecification/stories.md`. Keep all column values intact.

**When to update**: after every progress.md commit for a story. Include `ProductSpecification/stories.md` in the same commit.

**Lifecycle ordering**: Spec → Backend → Integration → Frontend → Security → Load → Infra. A phase becomes `🔧` when it is the current active phase (has `[~]` items) OR when it still has `[ ]` items and all prior phases are `✅`.

## Available Templates

- `.claude/templates/workflow/progress-format.md` -- progress file format for stories, bug tasks, and refactoring tasks
