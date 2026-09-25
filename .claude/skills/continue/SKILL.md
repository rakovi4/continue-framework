---
name: continue
description: Continue story or task work from compact progress state, recording execution evidence separately. Use when user wants to resume work or mentions /continue.
---

# /continue - Resume Development

## Workflow

1. **Identify work item** from argument
2. **Backlog promotion** -- if the story row is in the **Backlog** table in `ProductSpecification/stories.md`, move it to **In Progress** before proceeding
3. **Read progress** file, bootstrap if missing (stories only — `.claude/templates/workflow/bootstrapping.md`). **Missing means both locations came back empty** — resolve `ProductSpecification/stories/NN-story-name/` *and* `ProductSpecification/stories/done/NN-story-name/` before the bootstrap may fire (`.claude/rules/workflow.md`, "Resolving a story folder"); a hit in either is the story, so read its `progress.md` and bootstrap nothing. What an unchecked bootstrap does to an already-shipped story is in the template's "Precondition: the story genuinely has no folder"
   For an existing task, normalize legacy `Type: bug` to `bugfix` and `Type: refactoring` to `refactor` in memory; do not rewrite its type or folder merely to migrate terminology.
4. **Select execution mode** -- for an active story with completed specification, load `.claude/templates/workflow/story-stages.md` and reconcile `story-quality-checklist.md` before deciding whether implementation remains, even when old scenario checkboxes are all complete. Preserve scenario order; add required quality entries and reopen unsupported completions. **Find next step** -- run the plan-integrity check (`.claude/templates/workflow/plan-integrity-check.md`) over `progress.md`; on a failed check report it and STOP without dispatching. Otherwise the first `[~]` or `[ ]` entry remains the physical cursor; story implementation selects eligible work by the coordinator's current pass, which may reach a later scenario before an earlier scenario's implementation. A task with none archives immediately.
5. **Read relevant context** -- for story implementation, scope summaries, referenced work logs, and ADRs to all included scenarios across both tiers as directed by `story-stages.md`. Otherwise read `carryover.md` (if present), the current scenario's summary, and only `worklog/` records matching the current heading/step or named by its compact pointer. Do not load the directory wholesale. `/continue` never writes journey files (`/handoff` is their sole writer).
6. **Load ADR context** -- check for `decisions/*-decision.md` files in the story directory. If any exist AND the current step or whole-story scope references the ADR (via "see ADR" annotation or matching scenario), read it. ADRs contain architectural decisions, schema changes, edge cases, and implementation guidance that the work unit needs.
7. **Execute** -- story implementation runs the whole-story coordinator through all remaining passes in this invocation. Tasks and specification execute one work unit: dispatch sub-skills per tables below. If no named row matches, execute the checkbox intent directly in the main agent.
8. **Discovery gates** -- when the next step is `[ ] adapters-discovery`, map usecase ports to adapters (see `.claude/guidelines/workflow-detail.md`), then insert concrete steps. A TDD task's `steps discovery` inserts its scoped TDD plan; a refactor task's `refactor (steps discovery)` reconciles direct `## Work` checkboxes, not merely a companion artifact.
9. **Update records** -- create one `worklog/` Markdown record for this invocation (maximum 200 lines) and keep routine evidence, notes, coordinator plans, checkpoints, and proposals there. Composite stages update this active record while in flight. Keep `progress.md` to headings, permitted compact tokens, and one-line checkboxes of at most 200 characters: mark completed and advance next. Completed quality entries require a compact work-log pointer; other entries need one only when a later decision consumes that exact record. New finding-driven checkboxes must pass `.claude/templates/workflow/finding-admission-test.md`; materializing prescribed quality phases is existing work, not a new finding.
10. **Update stories.md** -- for stories only, update the phase columns in `ProductSpecification/stories.md` (see below)
11. **Behavior commit** -- include `progress.md`, the invocation's work-log record, and `ProductSpecification/stories.md` for stories. Before **every** progress commit, stage it and run plan-integrity check 8 against its zero-context staged diff; only added lines are checked, so legacy prose is grandfathered. Active stories also run check 9 against staged progress and evidence. Re-home any rejected evidence in the active work-log record and re-stage. For completion, also confirm the staged advance and zero `[ ]`/`[~]` entries. Archive only after every required quality phase, including owed refactor, has completed and its evidence is committed.
12. **Refactor** -- land any owed `/refactor` separately.

The high-level lifecycle, status markers, and atomic-unit rule are in `.claude/rules/workflow.md`; the detailed scenario sequences, adapter-discovery procedure, progress mechanics, and task sequences are in `.claude/guidelines/workflow-detail.md`. Progress file format examples are in `.claude/templates/workflow/progress-format.md`.

## Resolving the Argument

| Argument | Resolution |
|----------|------------|
| `task N` | Find `ProductSpecification/tasks/N-*/progress.md`, then `ProductSpecification/tasks/done/N-*/progress.md`. A **QA** task resolved from the archive is a *revival*, not a resume: move its folder back out of `tasks/done/` and reset its checkboxes before dispatching (`.claude/guidelines/workflow-detail.md`, "QA Task Sequence"). An active task with no `[ ]`/`[~]` archives immediately |
| Bare number or name | Resolve story via `ProductSpecification/stories.md`, then `ProductSpecification/stories/NN-story-name/progress.md`, then `ProductSpecification/stories/done/NN-story-name/progress.md` |
| No argument | Scan recent git log for `Story N` or `Task N` references; most recent wins |

Both work-item rows resolve the active location first and the `done/` archive second, per `.claude/rules/workflow.md`, "Resolving a story folder" — an argument that names a completed item resolves to its archived folder rather than to nothing.

**File lookup:** Use shell `find` (not pattern expansion) when searching for progress files or story folders. For story resolution, derive the folder name from `stories.md` by kebab-casing punctuation as separators, read the known active path, then fall back to `stories/done/`; use `ls` or `find` only when the folder name is ambiguous.

## Whole-Story Implementation

After specification review, run `.claude/templates/workflow/story-stages.md` inline:
Stage 1 covers all acceptance RED, the design interview, adapter discovery, and agreed
frozen contracts; Stage 2 completes all implementation; Stage 3 verifies all acceptance
GREEN before showing demos one by one. Use existing scenario checkboxes and metrics.
The coordinator overrides the dispatch table's per-scenario approval/stop and
no-next-stage rules: record agreed choices in existing approval steps and continue
without another invocation once the whole-story design is settled. Await required
interview answers; no routine stops after freeze. An existing harvest checkbox is
marked `[S]` with a work-log reason once its Tier 2 RED/baseline work is covered in
Stage 1; do not dispatch harvest again. Tasks and specification retain their routes.

## Work Unit Dispatch

Each progress.md checkbox maps to sub-skills. Dispatch per `.claude/guidelines/workflow-detail.md` sequences. **Named routes apply equally to stories and TDD tasks.** No-TDD task types use only direct routes; never infer RED/GREEN or `/refactor` for them.

| Checkbox | Sub-skills |
|----------|-----------|
| `quality stage-N {scope} {phase}` | **Inline coordinator.** Load `story-quality-checklist.md`; resolve scope and phase prerequisites, dispatch the named skill, record its completed result, then update only that entry. This route takes precedence over the free-form fallback and executes inside the parent stage. |
| `red-acceptance` | `red-agent.md` → `/test-review` → commit → `/refactor` → commit |
| `stage-1 acceptance RED + contract design` | **Inline coordinator.** Load `parallel-backend-stages.md`; dispatch the disjoint RED/design lanes, validate the Stage 2 lane plan gates, record the durable plan in the active work-log record, advance to approval, and commit both records before stopping for review |
| `approve stage-1 contracts` | **User decision.** Never dispatch Stage 2 from this checkbox. Explicit approval completes it and advances Stage 2 in a coordinator commit; rejection resets Stage 1 to `[~]` and keeps approval and Stage 2 pending |
| `stage-2 implementation lanes` | **Inline coordinator.** Load `parallel-backend-stages.md`; validate approval and lane ownership; after raw RED, run test review and GREEN implementation concurrently on disjoint paths; join, verify, and publish each phase from explicit paths; enforce `stage-2-quality-gates.md` before lane completion and stage advancement |
| `stage-3 acceptance GREEN` (legacy: `+ review`) | **Inline coordinator.** Load `parallel-backend-stages.md`; require committed Stage 2 lanes and run acceptance GREEN. On GREEN failure reopen the implicated lane. |
| `stage-1 frontend acceptance RED + interface design` | **Inline coordinator.** Load `parallel-frontend-stages.md`; declare disjoint manifests, dispatch Selenium RED and `/design-preview` frontend concurrent mode, reject worker staging/commits, join once, run combined checks, then stage and commit explicit paths |
| `stage-2 frontend implementation lanes` | **Inline coordinator.** Load `parallel-frontend-stages.md`; validate separate frozen Stage 1 interface files, dispatch complete `frontend-logic`, `frontend-api`, and design-alignment lanes concurrently, preserve RED-before-GREEN within each lane, enforce `stage-2-quality-gates.md`, publish behavior and refactoring separately, then join and run combined checks |
| `stage-3 frontend acceptance GREEN + demo` (legacy: `+ review`) | **Inline coordinator.** Load `parallel-frontend-stages.md`; require the committed Stage 2 join, run remove-marker-only Selenium GREEN, then demo. |
| Spec items (`interview`, `mockups`, `api-spec`, `test-spec`) | `/{item}` then commit |
| `story` (spec item) | **Inline** — no subagent. Load `.claude/templates/spec/story-spec-generation.md` (internal template — NOT the `/story` skill) with the story number, name, and folder already resolved, execute its phases, then commit |
| `root cause analysis` (bugfix tasks) | **Inline** — no subagent. Run `/rca`, record confirmed findings in `spec.md`, routine evidence in the active work-log record, and mark `[x]` → commit records |
| task `design` | **Inline.** Freeze the task input, draft the design, ask for one approval, and commit. |
| story `design` | `/design-preview` → user approves (optionally with ADR) or `/architecture` → commit (if ADR produced) |
| `red-*` (usecase, adapter, selenium, frontend, frontend-api) | `red-agent.md` → `/test-review` → commit → `/refactor` → commit |
| `green-usecase`, `green-adapter X` | `green-agent.md` → `/test-coverage {module} --focus` → commit → `/refactor` → commit |
| `red-workflow` | `red-agent.md` (layer `workflow`) → `/test-review` → commit → `/refactor` → commit |
| `green-workflow` | `green-agent.md` (layer `workflow`) → commit → `/refactor` → commit |
| `adapters-discovery` | Run all 3 checks in `adapter-discovery-checklist.md`, log evidence, mark `[x]`, insert concrete adapter steps (or `[S]`) → commit records |
| `steps discovery` (`behavior-change`, `bugfix`) | **Inline** — no subagent. Insert scoped TDD steps from the approved design, then commit |
| `refactor (steps discovery)` (`refactor`) | Reconcile approved design and discovered evidence against committed `progress.md`; update direct behavior-preserving `## Work` steps and append `(plan: +N/-N/~N)`. Refuse zero-change completion or any RED/GREEN step → run affected checks → commit |
| `green-acceptance` | **Inline** — no subagent. Read `green-agent.md` workflow, load acceptance implementation template, enable the disabled test (remove disable marker — only allowed test change), run acceptance tests, verify GREEN → commit |
| `green-frontend`, `green-frontend-api` | `green-agent.md` → commit → `/refactor` → commit |
| `green-selenium` | `/run-backend` → `/run-frontend` → `green-agent.md` (remove-marker-only: no production code, no Statements changes, no backend changes — if test fails, STOP and report) → commit |
| `harvest` (tier-major boundary) | **Inline** — no subagent. It fans out concurrent `red-agent`s, which must not nest inside a wrapper agent. Run every remaining Tier 2 acceptance scenario through `red-agent` (each self-partitions: green → `red-acceptance` `[x]` + other steps `[S]`; red → normal cycle), then baseline the green set against the pre-story build, commit. Full procedure: `.claude/skills/harvest/SKILL.md` |
| `align-design` | Build component → `/align-design` → `/design-review` (MANDATORY) → `/test-coverage frontend --focus` → commit → `/refactor` → `/align-design` verify-only → commit |
| `demo` | `/demo {scenario_test_class}`, record evidence, then commit records |
| `refactor usecase` / other `refactor (...)` | Apply change then run affected tests then commit |
| QA `## Cases` checkbox | **No dispatch.** Report the next unchecked case to the user and stop -- the tester verifies it manually against the target environment, then ticks the box (or files a separate bugfix task if it fails) on their own. |
| Any other checkbox | **Direct inline fallback.** Treat the full checkbox text as the work-unit intent. Execute it in the main agent, inspect the relevant scope, make the requested changes, run affected checks, advance progress, and commit. In `refactor`, `infra`, `general`, or `qa`, stop and reclassify/split if this would change executable behavior. Do not infer RED/GREEN, coverage, or `/refactor`. |

The `stage-*` routes are composite scenario work units. Load the matching
`parallel-backend-stages.md` or `parallel-frontend-stages.md` template for lane
ownership, publication, and failure semantics. Never expand them back into
serial progress checkboxes. Their separate quality entries track required phases
without changing lane concurrency or creating additional invocation boundaries.

## Stop and Report

Story implementation follows `story-stages.md` through all remaining passes and reports once at completion or a genuine blocker. The rest of this paragraph applies to tasks and specification: a single invocation executes exactly ONE work unit. Do not pause between sub-skills except for task-design approval. A `/refactor` work unit ends with behavior then separate refactor commits (omit only an empty refactor commit, never the skill execution). STOP only after the last owed commit. Then report the completed step, tests, next step, fraction, and how to continue; do not execute the next step.

**Re-orientation block (mandatory, last):** close the report with the re-orientation block specified in `.claude/templates/workflow/continue-report-format.md` -- work item type/number/name, scenario or step, step just done, next step, position, and a two-sentence plain-language summary. It goes below everything else and immediately above the `/plain` hint: a terminal scrolls, and a user running several parallel `/continue` sessions must recover which work item this one is without reading back up. Emit it on both stop points, including a sub-skill failure.

End the report with a one-line `/plain` hint (e.g. `Press /plain to have this report re-explained in plain words`) so the user has a button to press when the technical summary didn't land. This is only a pointer -- never invoke `/plain` yourself; it is a manual button the user presses.

**Test results:** Collect pass/fail counts from every sub-skill that runs tests (red-agent, green-agent, test-coverage, refactor). Include them in the final report as a summary line, e.g., `Tests: 15 passed, 0 failed` or `Tests: 14 passed, 1 failed`. When multiple test suites ran, report each separately.

**Red prediction (mandatory for red-* work units):** When the work unit included any red-* phase, copy the red-agent's **Predicted failure**, **Actual failure**, and **Comparison** sections verbatim into the final report — same wording as the Output Summary Format in `.claude/templates/workflow/red-phase-formats.md`. Do NOT collapse to phrases like "test passed as predicted" or "prediction matched" — the user must see both the prediction and the actual result side by side, in their own labelled sections, so the match can be audited without re-reading the agent's return.

## Pre-Commit Checklist

Before behavior commit verify: (1) the primary route ran, (2) `/test-review` ran for red, (3) `/test-coverage` ran for green usecase/adapter, (4) fallback tests ran, (5) the active work-log record is staged, and (6) plan-integrity check 8 passes the staged progress additions. Before story stage advancement or archive, require check 9 and valid quality entries for every scope; Stage 2 also requires every named result in `stage-2-quality-gates.md`. Before stopping verify: (7) owed refactor ran and (8) completion was proven from staged progress before archive. Run any omitted action before stopping.


## Sub-Skill Dispatch

Sub-skills use named agent dispatch for context isolation, following `.claude/guidelines/platform-capabilities.md`, EXCEPT the rows marked **Inline** — those run in the main agent, which fans out their detectors itself so that no dispatched agent nests a fan-out of its own:

| Sub-skill | Dispatch method |
|-----------|----------------|
| `red-*` | Dispatch named agent `red-agent` — pass layer, story folder path, scenario name, and ADR content (if loaded) |
| `green-*` (except `green-acceptance`) | Dispatch named agent `green-agent` — pass layer, story folder path, scenario name, and ADR content (if loaded) |
| `green-acceptance` | **Inline** — no subagent. Main agent reads `green-agent.md`, loads acceptance template, enables the test, runs it. Full visibility for user. |
| `harvest` | **Inline** — no subagent. Main agent reads `.claude/skills/harvest/SKILL.md` and fans out its own writer sub-agents (`red-agent`, layer `acceptance`); it must not nest inside a wrapper agent. |
| backend or frontend `stage-*` | **Inline coordinator** — fan out lane phases directly, including sibling test-review/GREEN work where the stage template permits it; gather results and remain sole writer of tracking state, staging, and commits; workers never nest detector fan-outs |
| `/refactor` | **Inline** — no wrapper subagent. Main agent concurrently fans out `refactor-mechanics-agent`, `refactor-design-agent` and `refactor-duplication-agent`, awaits every result, merges duplicate locations while preserving check ids and impact order, then dispatches `refactor-agent` as the serial fixer with the detector roster. |
| `/test-review` | **Inline** — no wrapper subagent. Main agent fans out the detector roster, merges findings, then dispatches `test-review-agent`. The fixer runs the suite unless Stage 2 production work is concurrent; then the coordinator owns joined verification. |
| `/test-coverage` | Dispatch named agent `coverage-agent` and await its result. |

Derive the layer from the checkbox (e.g., `red-adapter storage` → layer `storage`, `green-usecase` → layer `usecase`, any `red-workflow (...)` → layer `workflow`). Both red-agent and green-agent receive: layer, work-item folder path, scenario name, and ADR content (if loaded in step 5). The agent resolves test files and templates from its own workflow.

**CHAINING: After each sub-step's awaited result returns, echo a 1-2 line status summary (agent name, outcome, pass/fail counts) to the user, then immediately dispatch the next sub-step. Required story Stage 1 interview/contract decisions and task-design approval may pause dependent work.**

**AGENT LOG: Before the first agent dispatch, clear the log: `> infrastructure/agent-progress.log`. After the last commit, include the log contents in the stop-and-report summary.**

**LOG REMINDER: Every time you dispatch a sub-agent, output this line immediately before dispatch:**
```
> Dispatching {agent-name}. Live progress: tail -f infrastructure/agent-progress.log
```
**This reminds the user where to watch. The line appears in conversation output before the agent starts, so the user can open a terminal and tail the log while the agent works.**

## Rules

- Story implementation runs all remaining passes under `story-stages.md`; tasks and specification execute exactly ONE work unit per invocation through its last commit. A `/refactor` unit ends with behavior then separate refactor commits (omit only an empty refactor commit, never the skill execution). STOP only after the last owed commit.
- Task commit prefix: `task:` (e.g., `task: red-adapter storage (Task 1, Step 1)`)
- If a sub-skill fails, stop immediately -- do NOT mark the step complete
- Mandatory sub-skills per phase: see `.claude/guidelines/workflow-detail.md` sequences

## Updating stories.md

After updating `progress.md` for a **story** (not tasks), update the story's row in `ProductSpecification/stories.md` to reflect current phase status. The phase-column values, the tier-major/untiered split for the Tests and % columns, and the story-completion rule are in `.claude/templates/workflow/stories-md-format.md`. Include `ProductSpecification/stories.md` in the same commit.

## Available Templates

- `.claude/templates/workflow/story-stages.md` -- whole-story three-pass coordination over existing scenario plans

- `.claude/templates/workflow/progress-format.md` -- progress file format for stories and all six task types
- `.claude/templates/workflow/worklog-format.md` -- per-invocation execution record format
- `.claude/templates/workflow/stories-md-format.md` -- stories.md phase/Tests/% column rules (tier-major and untiered)
- `.claude/templates/workflow/plan-integrity-check.md` -- plan checks, staged-write check 8, and quality-evidence check 9
- `.claude/templates/workflow/story-quality-checklist.md` -- required quality entries, dispatch, evidence, and resume reconciliation
- `.claude/templates/workflow/continue-report-format.md` -- the re-orientation block that closes every stop-and-report
