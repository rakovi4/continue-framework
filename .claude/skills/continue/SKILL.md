---
name: continue
description: Continue story or task work from compact progress state, recording execution evidence separately. Use when user wants to resume work or mentions /continue.
---

# /continue - Resume Development

## Workflow

1. **Identify work item** from argument
2. **Backlog promotion** -- if the story row is in the **Backlog** table in `ProductSpecification/stories.md`, move it to **In Progress** before proceeding
3. **Read progress** file, bootstrap if missing (stories only — `.claude/templates/workflow/bootstrapping.md`). **Missing means both locations came back empty** — resolve `ProductSpecification/stories/NN-story-name/` *and* `ProductSpecification/stories/done/NN-story-name/` before the bootstrap may fire (`.claude/rules/workflow.md`, "Resolving a story folder"); a hit in either is the story, so read its `progress.md` and bootstrap nothing. What an unchecked bootstrap does to an already-shipped story is in the template's "Precondition: the story genuinely has no folder"
4. **Find next step** -- run the plan-integrity check (`.claude/templates/workflow/plan-integrity-check.md`) over `progress.md` first; on a failed check report it and STOP without dispatching. Otherwise the next step is the first `[~]` or `[ ]` entry
5. **Read relevant context** -- read `carryover.md` (if present), the current scenario's summary, and only `worklog/` records matching the current heading/step or named by its compact pointer. Do not load the directory wholesale. `/continue` never writes journey files (`/handoff` is their sole writer).
6. **Load ADR context** -- check for `decisions/*-decision.md` files in the story directory. If any exist AND the current step references the ADR (via "see ADR" annotation or matching scenario), read it. ADRs contain architectural decisions, schema changes, edge cases, and implementation guidance that the work unit needs.
7. **Execute one work unit** -- dispatch sub-skills per tables below. If no named row matches, execute the checkbox intent directly in the main agent.
8. **Discovery gates** -- when the next step is `[ ] adapters-discovery`, map usecase ports to adapters (see `.claude/guidelines/workflow-detail.md`), then insert concrete steps. Bug-task `steps discovery` runs its hazard fan-out, stores the full scan in the active work-log record, and resolves as `[x] steps discovery (scan: worklog; GAPs: N)`. A refactoring task's `refactor (steps discovery)` reconciles the concrete `## Fix` checkboxes, not merely a companion artifact.
9. **Update records** -- create one `worklog/` Markdown record for this invocation (maximum 200 lines) and keep routine evidence, notes, coordinator plans, checkpoints, and proposals there. Composite stages update this active record while in flight. Keep `progress.md` to headings, permitted compact tokens, and one-line checkboxes of at most 200 characters: mark completed and advance next. Add a work-log pointer only when a later decision must consume that exact record. **Any new checkbox must pass `.claude/templates/workflow/finding-admission-test.md`**; a failing finding is reported and stored nowhere.
10. **Update stories.md** -- for stories only, update the phase columns in `ProductSpecification/stories.md` (see below)
11. **Behavior commit** -- include `progress.md`, the invocation's work-log record, and `ProductSpecification/stories.md` for stories. Before **every** progress commit, stage it and run plan-integrity check 8 against its zero-context staged diff; only added lines are checked, so legacy prose is grandfathered. Re-home any rejected evidence in the active work-log record and re-stage. For completion, also confirm the staged advance and zero `[ ]`/`[~]` entries before archiving; a story's folder move and **In Progress** → **Done** move land together. See `stories-md-format.md` for archive mechanics.
12. **Refactor batch (+ review passes at a boundary)** -- dispatch `/refactor`; land the refactor commit (`/refactor`'s changes only; skipped if it changed nothing). If this unit is a **boundary** and triage says RUN, dispatch `agent-review-agent` and `premortem-agent` concurrently over the boundary range; collect both non-gating verdicts. Skip `/refactor` for a progress-only behavior commit.
13. **Triage & auto-fix (boundary units only)** -- when triage RUNS the passes, partition findings per `triage-and-auto-fix.md`, resolve any permitted quiz, and append every verdict/disposition to the active work-log record. Land it with SAFE fixes in `review-fix:`; if none survives, land the record alone in `worklog:`. Triage SKIP owes no trailing commit. Fold every verdict into the report.

The high-level lifecycle, status markers, and atomic-unit rule are in `.claude/rules/workflow.md`; the detailed scenario sequences, adapter-discovery procedure, progress mechanics, and task sequences are in `.claude/guidelines/workflow-detail.md`. Progress file format examples are in `.claude/templates/workflow/progress-format.md`.

## Resolving the Argument

| Argument | Resolution |
|----------|------------|
| `task N` | Find `ProductSpecification/tasks/N-*/progress.md`, then `ProductSpecification/tasks/done/N-*/progress.md`. A **QA** task resolved from the archive is a *revival*, not a resume: move its folder back out of `tasks/done/` and reset its checkboxes before dispatching (`.claude/guidelines/workflow-detail.md`, "QA Task Sequence"). Any other work item that resolves with no `[ ]`/`[~]` left is complete -- report that and STOP without dispatching |
| Bare number or name | Resolve story via `ProductSpecification/stories.md`, then `ProductSpecification/stories/NN-story-name/progress.md`, then `ProductSpecification/stories/done/NN-story-name/progress.md` |
| No argument | Scan recent git log for `Story N` or `Task N` references; most recent wins |

Both work-item rows resolve the active location first and the `done/` archive second, per `.claude/rules/workflow.md`, "Resolving a story folder" — an argument that names a completed item resolves to its archived folder rather than to nothing.

**File lookup:** Use shell `find` (not pattern expansion) when searching for progress files or story folders. For story resolution, derive the folder name from `stories.md` by kebab-casing punctuation as separators, read the known active path, then fall back to `stories/done/`; use `ls` or `find` only when the folder name is ambiguous.

## Work Unit Dispatch

Each progress.md checkbox maps to sub-skills. Dispatch per `.claude/guidelines/workflow-detail.md` sequences. **This table applies equally to stories AND tasks — never skip `/test-review` or `/refactor` for task steps.**

| Checkbox | Sub-skills |
|----------|-----------|
| `red-acceptance` | `red-agent.md` → `/test-review` → commit → `/refactor` → commit |
| `stage-1 acceptance RED + contract design` | **Inline coordinator.** Load `parallel-backend-stages.md`; dispatch the disjoint RED/design lanes, validate the Stage 2 lane plan gates, record the durable plan in the active work-log record, advance to approval, and commit both records before stopping for review |
| `approve stage-1 contracts` | **User decision.** Never dispatch Stage 2 from this checkbox. Explicit approval completes it and advances Stage 2 in a coordinator commit; rejection resets Stage 1 to `[~]` and keeps approval and Stage 2 pending |
| `stage-2 implementation lanes` | **Inline coordinator.** Load `parallel-backend-stages.md`; validate approval and the work-log lane plan, dispatch independent complete lanes, serialize publication, and preserve every lane checkpoint in the active record. Advance to Stage 3 only after the joined checks and commit the record with the transition |
| `stage-3 acceptance GREEN + review` | **Inline coordinator.** Load `parallel-backend-stages.md`; require committed Stage 2 lanes, run acceptance GREEN and both reviews concurrently, then triage. On GREEN failure reopen the implicated lane. Store admitted cycle proposals in the active work-log record and append only a compact decision checkpoint to progress |
| `stage-1 frontend acceptance RED + interface design` | **Inline coordinator.** Load `parallel-frontend-stages.md`; declare disjoint manifests, dispatch Selenium RED and `/design-preview` frontend concurrent mode, reject worker staging/commits, join once, run combined checks, then stage and commit explicit paths |
| `stage-2 frontend implementation lanes` | **Inline coordinator.** Load `parallel-frontend-stages.md`; validate separate frozen Stage 1 interface files, dispatch complete `frontend-logic`, `frontend-api`, and design-alignment lanes concurrently, preserve RED-before-GREEN within each lane, gather coverage report-only findings, join each once, run combined checks, then stage and commit explicit paths |
| `stage-3 frontend acceptance GREEN + review` | **Inline coordinator.** Load `parallel-frontend-stages.md`; require the committed Stage 2 join, run remove-marker-only Selenium GREEN and both reviews over the immutable range, then demo and triage. Store proposals in the active work-log record; progress gets only their consent checkpoint |
| `resolve stage-3 cycle proposals` | **User decision.** Read the proposal record named by the compact work-log pointer. Agreement inserts admitted cycle blocks; rejection inserts none; either completes the checkbox in one coordinator plan commit, while silence never advances it |
| Spec items (`interview`, `mockups`, `api-spec`, `test-spec`) | `/{item}` then commit |
| `story` (spec item) | **Inline** — no subagent. The template's hazard scan fans out its own `hazard-scan-agent`s, which must not nest inside a wrapper agent. Load `.claude/templates/spec/story-spec-generation.md` (internal template — NOT the `/story` skill) with the story number, name, and folder already resolved, execute its phases, then commit |
| `root cause analysis` (bug tasks) | **Inline** — no subagent. Run `/rca`, record confirmed findings in `spec.md`, routine evidence in the active work-log record, and mark `[x]` → commit records |
| `design` | `/design-preview` → user approves (optionally with ADR) or `/architecture` → commit (if ADR produced) |
| `red-*` (usecase, adapter, selenium, frontend, frontend-api) | `red-agent.md` → `/test-review` → commit → `/refactor` → commit |
| `green-usecase`, `green-adapter X` | `green-agent.md` → `/test-coverage {module} --focus` → commit → `/refactor` → commit |
| `red-workflow` | `red-agent.md` (layer `workflow`) → `/test-review` → commit → `/refactor` → commit |
| `green-workflow` | `green-agent.md` (layer `workflow`) → commit → `/refactor` → commit |
| `adapters-discovery` | Run all 3 checks in `adapter-discovery-checklist.md`, log evidence, mark `[x]`, insert concrete adapter steps (or `[S]`) → commit records |
| `steps discovery` (bug tasks) | **Inline** — no subagent. Run the hazard fan-out per `workflow-detail.md`; resolve every GAP, put the full required scan record in the active work-log record, render `[x] steps discovery (scan: worklog; GAPs: N)`, insert concrete TDD steps, then commit both records |
| `refactor (steps discovery)` (refactoring tasks) | Reconcile the approved design and discovered evidence against the committed pre-unit `progress.md`; update the concrete `## Fix` headings and checkboxes; append `(plan: +N/-N/~N)` to the completed gate. Refuse completion when all counts are zero or only a companion artifact changed → run affected checks → commit |
| `green-acceptance` | **Inline** — no subagent. Read `green-agent.md` workflow, load acceptance implementation template, enable the disabled test (remove disable marker — only allowed test change), run acceptance tests, verify GREEN → commit |
| `green-frontend`, `green-frontend-api` | `green-agent.md` → commit → `/refactor` → commit |
| `green-selenium` | `/run-backend` → `/run-frontend` → `green-agent.md` (remove-marker-only: no production code, no Statements changes, no backend changes — if test fails, STOP and report) → commit |
| `harvest` (tier-major boundary) | **Inline** — no subagent. It fans out concurrent `red-agent`s, which must not nest inside a wrapper agent. Run every remaining Tier 2 acceptance scenario through `red-agent` (each self-partitions: green → `red-acceptance` `[x]` + other steps `[S]`; red → normal cycle), then baseline the green set against the pre-story build, commit. Full procedure: `.claude/skills/harvest/SKILL.md` |
| `align-design` | Build component → `/align-design` → `/design-review` (MANDATORY) → `/test-coverage frontend --focus` → commit → `/refactor` → `/align-design` verify-only → commit |
| `demo` | `/demo {scenario_test_class}`, record evidence, then commit records |
| `refactor usecase` / other `refactor (...)` | Apply change then run affected tests then commit |
| QA `## Cases` checkbox | **No dispatch.** Report the next unchecked case to the user and stop -- the tester verifies it manually against the target environment, then ticks the box (or files a separate bug task if it fails) on their own. |
| Any other checkbox | **Direct inline fallback.** Treat the full checkbox text as the work-unit intent. Execute it in the main agent, inspect the relevant scope, make the requested changes, run affected tests, advance progress, and commit. Do not infer a red/green, review, coverage, or refactor sequence that the checkbox did not name. |

The `stage-*` routes are composite scenario work units. Load the matching
`parallel-backend-stages.md` or `parallel-frontend-stages.md` template for lane
ownership, publication, failure, and review semantics. Never expand them back into
serial progress checkboxes.

## Stop and Report

A single `/continue` invocation executes exactly ONE work unit. Do not pause between sub-skills. A `/refactor` work unit ends with behavior then optional refactor commits. When boundary passes RUN, finish with `review-fix:` if SAFE fixes survive or `worklog:` otherwise; triage SKIP owes neither. STOP only after the last owed commit. Then report the completed step, tests, boundary verdicts, next step, fraction, and how to continue; do not execute the next step.

**Re-orientation block (mandatory, last):** close the report with the re-orientation block specified in `.claude/templates/workflow/continue-report-format.md` -- work item type/number/name, scenario or step, step just done, next step, position, and a two-sentence plain-language summary. It goes below everything else and immediately above the `/plain` hint: a terminal scrolls, and a user running several parallel `/continue` sessions must recover which work item this one is without reading back up. Emit it on both stop points, including a sub-skill failure.

End the report with a one-line `/plain` hint (e.g. `Press /plain to have this report re-explained in plain words`) so the user has a button to press when the technical summary didn't land. This is only a pointer -- never invoke `/plain` yourself; it is a manual button the user presses.

**Test results:** Collect pass/fail counts from every sub-skill that runs tests (red-agent, green-agent, test-coverage, refactor). Include them in the final report as a summary line, e.g., `Tests: 15 passed, 0 failed` or `Tests: 14 passed, 1 failed`. When multiple test suites ran, report each separately.

**Red prediction (mandatory for red-* work units):** When the work unit included any red-* phase, copy the red-agent's **Predicted failure**, **Actual failure**, and **Comparison** sections verbatim into the final report — same wording as the Output Summary Format in `.claude/templates/workflow/red-phase-formats.md`. Do NOT collapse to phrases like "test passed as predicted" or "prediction matched" — the user must see both the prediction and the actual result side by side, in their own labelled sections, so the match can be audited without re-reading the agent's return.

**Review-pass findings (mandatory in a boundary unit when triage RAN the passes):** include the `agent-review` and `premortem` verdicts. PASS → one line each (`agent-review: PASS`, `premortem: PASS`). CONCERNS/BLOCK → list each finding with its place in the diff and the named missing guard. SAFE findings applied by the auto-fixer → `review-fix: applied N SAFE finding(s) [<sha>]` plus one line per fix; NEEDS_CYCLE findings → follow-ups the user can act on; NEEDS_CLARIFICATION → the quiz question and the routed outcome. When triage SKIPped, report `Review passes: SKIPPED (triage — <reason>)`. **Report every dropped finding** -- NO_FIX-tagged, or admission-test-failed -- as one line naming what it was and why it was let go. Drops are the point of the filter, not an embarrassment: a silent drop is indistinguishable from not looking, and this line is the user's only chance to overrule one. In a non-boundary unit report nothing about them. The passes and the auto-fix never revert the behavior commit.

## Boundary Review Passes

The two **fresh-context** passes — `agent-review-agent` (audits what the work *contains*) and
`premortem-agent` (imagines what it is *missing*) — run **once per boundary**, not once per unit.

**Is this unit a boundary, and what range do the passes read?** Both are computed off the
**staged** `progress.md` (`git show :<path>` — the blob step 11 committed, never your
recollection of the edit) by `.claude/templates/workflow/progress-format.md`, "Blocks and
boundaries": slice out the **block** holding the step just completed; the unit is a **boundary**
iff that slice has zero `- [ ]` and zero `- [~]` lines; the **boundary range** is the block's first
commit `~1..HEAD`, found by walking `git log --follow` over `progress.md` for the oldest blob whose
slice already carries an `[x]`/`[S]` step — so no commit needs tagging and `progress.md` needs no new
syntax. If the walk cannot resolve it, review `HEAD` alone and report `range unresolved — reviewed HEAD
only`: it degrades to the old single-commit read, loudly, never to nothing. A **mid-block** unit runs
`/refactor`, skips the passes, and ends at two commits.

Before dispatch, inspect that same block for `<!-- review-origin: boundary -->`. If present, skip
both passes with `review-depth guard — review-origin block`: the complete TDD and `/refactor`
sequence still runs, but work commissioned by a boundary review cannot recursively commission a
fresh review generation. Whether marked or not, a boundary batch is consumed once; its trailing
`review-fix:` or `worklog:` commit never triggers another batch in the same work unit.

**Input is committed history, not a working-tree snapshot.** Pass both review agents the range,
changed paths, and one line of intent; dispatch them concurrently and await both. Consume every
finding per "Triage & Auto-Fix" below. The passes stay non-gating; a QA task dispatches nothing and
has no boundary. Why this layer exists and why the cadence is per boundary:
`.claude/guidelines/review-passes-detail.md`.

## Triage & Auto-Fix

What `/continue` does with the review passes' findings in a **boundary** unit — the SKIP/RUN
predicate, the four-way partition of tagged findings, the NEEDS_CLARIFICATION quiz, and the
inline SAFE-only auto-fixer and trailing `review-fix:`/`worklog:` record commit — is
`.claude/templates/workflow/triage-and-auto-fix.md`.

## Pre-Commit Checklist

Before behavior commit verify: (1) the primary route ran, (2) `/test-review` ran for red, (3) `/test-coverage` ran for green usecase/adapter, (4) fallback tests ran, (5) the active work-log record is staged, and (6) plan-integrity check 8 passes the staged progress additions. Before stopping verify: (7) owed refactor ran, (8) the staged boundary test and reviews ran when owed, (9) every verdict is in the trailing `review-fix:` or `worklog:` commit, and (10) completion was proven from staged progress before archive. Run any omitted action before stopping.


## Sub-Skill Dispatch

Sub-skills use named agent dispatch for context isolation, following `.claude/guidelines/platform-capabilities.md`, EXCEPT the rows marked **Inline** — those run in the main agent, which fans out their detectors itself so that no dispatched agent nests a fan-out of its own:

| Sub-skill | Dispatch method |
|-----------|----------------|
| `red-*` | Dispatch named agent `red-agent` — pass layer, story folder path, scenario name, and ADR content (if loaded) |
| `green-*` (except `green-acceptance`) | Dispatch named agent `green-agent` — pass layer, story folder path, scenario name, and ADR content (if loaded) |
| `green-acceptance` | **Inline** — no subagent. Main agent reads `green-agent.md`, loads acceptance template, enables the test, runs it. Full visibility for user. |
| `harvest` | **Inline** — no subagent. Main agent reads `.claude/skills/harvest/SKILL.md` and fans out its own writer sub-agents (`red-agent`, layer `acceptance`); it must not nest inside a wrapper agent. |
| backend or frontend `stage-*` | **Inline coordinator** — fan out lanes directly, gather results, and remain sole writer of `progress.md`, the active work-log record, staging, and commits; lane plans/checkpoints/proposals never go in progress |
| `/refactor` | **Inline** — no wrapper subagent. Main agent concurrently fans out `refactor-mechanics-agent`, `refactor-design-agent` and `refactor-duplication-agent`, awaits every result, merges duplicate locations while preserving check ids and impact order, then dispatches `refactor-agent` as the serial fixer with the detector roster. |
| `/test-review` | **Inline** — no wrapper subagent. Main agent concurrently fans out `test-review-assertions-agent`, `test-review-placement-agent`, `test-review-statements-agent` and, for browser tests, `test-review-selenium-agent`; awaits every result; merges duplicate `file:line` findings while preserving check ids; then dispatches `test-review-agent` as the serial fixer with the detector roster. The fixer runs the suite itself. |
| `/test-coverage` | Dispatch named agent `coverage-agent` and await its result. |
| `agent-review` (boundary) | Dispatch `agent-review-agent` concurrently with `premortem-agent`, then await both. |
| `premortem` (boundary) | Dispatch `premortem-agent` concurrently with `agent-review-agent`, then await both. |

Derive the layer from the checkbox (e.g., `red-adapter storage` → layer `storage`, `green-usecase` → layer `usecase`, any `red-workflow (...)` → layer `workflow`). Both red-agent and green-agent receive: layer, work-item folder path, scenario name, and ADR content (if loaded in step 5). The agent resolves test files and templates from its own workflow. The triage predicate and the SAFE-only auto-fixer are **inline in `/continue`** — no subagent, no new dispatch row (see "Triage & Auto-Fix").

**CHAINING: After each sub-step's awaited result returns, echo a 1-2 line status summary (agent name, outcome, pass/fail counts) to the user, then immediately dispatch the next sub-step. Do NOT wait for user input between sub-steps — the echo is informational only. Dispatch the two boundary review agents in one concurrent wave and await both.**

**AGENT LOG: Before the first agent dispatch, clear the log: `> infrastructure/agent-progress.log`. In a boundary unit the two review passes log too (they run in the `/refactor` batch); after the last commit, include the log contents in the stop-and-report summary.**

**LOG REMINDER: Every time you dispatch a sub-agent, output this line immediately before dispatch:**
```
> Dispatching {agent-name}. Live progress: tail -f infrastructure/agent-progress.log
```
**This reminds the user where to watch. The line appears in conversation output before the agent starts, so the user can open a terminal and tail the log while the agent works.**

## Rules

- Execute exactly ONE work unit per invocation through its last commit. A `/refactor` unit ends with behavior then optional refactor commits. A boundary whose passes RUN adds `review-fix:` when SAFE fixes survive or `worklog:` otherwise; triage SKIP adds neither. STOP only after the last owed commit.
- Task commit prefix: `task:` (e.g., `task: red-adapter storage (Task 1, Step 1)`)
- If a sub-skill fails, stop immediately -- do NOT mark the step complete
- Mandatory sub-skills per phase: see `.claude/guidelines/workflow-detail.md` sequences

## Updating stories.md

After updating `progress.md` for a **story** (not tasks), update the story's row in `ProductSpecification/stories.md` to reflect current phase status. The phase-column values, the tier-major/untiered split for the Tests and % columns, and the story-completion rule are in `.claude/templates/workflow/stories-md-format.md`. Include `ProductSpecification/stories.md` in the same commit.

## Available Templates

- `.claude/templates/workflow/progress-format.md` -- progress file format for stories, bug tasks, and refactoring tasks
- `.claude/templates/workflow/worklog-format.md` -- per-invocation execution record format
- `.claude/templates/workflow/stories-md-format.md` -- stories.md phase/Tests/% column rules (tier-major and untiered)
- `.claude/templates/workflow/plan-integrity-check.md` -- seven pre-dispatch checks plus staged-write check 8
- `.claude/templates/workflow/continue-report-format.md` -- the re-orientation block that closes every stop-and-report
- `.claude/templates/workflow/triage-and-auto-fix.md` -- the boundary-unit triage predicate, four-way partition, quiz and SAFE-only auto-fixer (step 13)
