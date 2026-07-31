---
name: continue
description: Continue working on a story or task by reading progress.md, executing the next work unit, and updating progress. Use when user wants to resume story/task work or mentions /continue command.
---

# /continue - Resume Development

## Workflow

1. **Identify work item** from argument
2. **Backlog promotion** -- if the story row is in the **Backlog** table in `ProductSpecification/stories.md`, move it to **In Progress** before proceeding
3. **Read progress** file, bootstrap if missing (stories only — `.claude/templates/workflow/bootstrapping.md`)
4. **Find next step** -- run the plan-integrity check (`.claude/templates/workflow/plan-integrity-check.md`) over `progress.md` first; on a failed check report it and STOP without dispatching. Otherwise the next step is the first `[~]` or `[ ]` entry
5. **Read journey context** -- read `carryover.md` (story root, if it exists) and the current scenario's summary file (`summaries/{scenario-slug}.md`, if it exists). Treat both as additional context for the work unit -- they preserve predictions, decisions, surprises, and quirks from prior conversations. `/continue` only READS these files; it never writes them (the `/handoff` skill is the sole writer).
6. **Load ADR context** -- check for `decisions/*-decision.md` files in the story directory. If any exist AND the current step references the ADR (via "see ADR" annotation or matching scenario), read it. ADRs contain architectural decisions, schema changes, edge cases, and implementation guidance that the work unit needs.
7. **Execute one work unit** -- dispatch sub-skills per tables below
8. **Discovery gates** -- when the next step is `[ ] adapters-discovery`, read usecase constructor to identify ports and map to adapters (see `.claude/guidelines/workflow-detail.md`). Mark `[x] adapters-discovery`, insert concrete steps below it, commit progress.md. The bug-task `[ ] steps discovery` gate resolves the same way via its Work Unit Dispatch row -- run its hazard-catalogue fan-out, then insert the TDD steps.
9. **Update progress** -- mark completed, advance next
10. **Update stories.md** -- for stories only, update the phase columns in `ProductSpecification/stories.md` (see below)
11. **Behavior commit** -- commit the work unit's behavior change (include progress.md, and `ProductSpecification/stories.md` for stories). Then gate the `done/` archive move on the **staged file**, not on what you believe you wrote: stage progress.md, confirm the advance is in the staged content, and confirm zero `[ ]`/`[~]` entries remain (`git diff --cached` on progress.md; `grep -c '^- \[[ ~]\]'` must be 0). Only then move the **work item's folder** into its `done/` archive and include the move in this commit: a task goes `ProductSpecification/tasks/{N}-{type}-{slug}/` → `ProductSpecification/tasks/done/`, a story goes `ProductSpecification/stories/NN-story-name/` → `ProductSpecification/stories/done/NN-story-name/`. For a story the folder move rides the **same commit as the row move** from the **In Progress** table to the **Done** table in `stories.md` (step 10) -- one completion fact, two halves, both or neither. An unstaged advance is the live failure mode -- editing progress.md and then `git mv`-ing the folder commits the rename carrying the *pre-edit* content, shipping a "complete" commit whose source of truth still says in-progress.
12. **Refactor batch (+ review passes at a boundary)** -- dispatch `/refactor`; land the refactor commit (`/refactor`'s changes only; skipped if it changed nothing). If this unit is a **boundary** and triage says RUN, dispatch the two review passes (`agent-review-agent` + `premortem-agent`) concurrently in the same batch, over the **boundary range** (see "Boundary Review Passes" below); they are non-gating -- collect their verdicts for the report. Skip `/refactor` for a progress-only behavior commit.
13. **Triage & auto-fix (boundary units only)** -- partition the passes' tagged findings (SAFE / NEEDS_CYCLE / NEEDS_CLARIFICATION), quiz any NEEDS_CLARIFICATION after the passes return, apply the SAFE subset inline, and land a single trailing `review-fix:` commit (skipped when nothing is SAFE). Fold all verdicts into the stop-and-report.

The high-level lifecycle, status markers, and atomic-unit rule are in `.claude/rules/workflow.md`; the detailed scenario sequences, adapter-discovery procedure, progress mechanics, and task sequences are in `.claude/guidelines/workflow-detail.md`. Progress file format examples are in `.claude/templates/workflow/progress-format.md`.

## Resolving the Argument

| Argument | Resolution |
|----------|------------|
| `task N` | Find `ProductSpecification/tasks/N-*/progress.md` |
| Bare number or name | Resolve story via `ProductSpecification/stories.md` then `ProductSpecification/stories/NN-story-name/progress.md` |
| No argument | Scan recent git log for `Story N` or `Task N` references; most recent wins |

**File lookup:** Use `find` via Bash (not Glob) when searching for progress files or story folders. Glob is unreliable on Windows/MINGW with large `.gitignore` files. For story resolution, derive the folder name from `ProductSpecification/stories.md` — kebab-case the story name, treating punctuation as word separators (e.g., story 5 "Reset password" → `05-reset-password`; "Login/Logout" → `01-login-logout`) — and Read the progress file directly. Use `ls` or `find` via Bash only when the folder name is ambiguous.

## Work Unit Dispatch

Each progress.md checkbox maps to sub-skills. Dispatch per `.claude/guidelines/workflow-detail.md` sequences. **This table applies equally to stories AND tasks — never skip `/test-review` or `/refactor` for task steps.**

| Checkbox | Sub-skills |
|----------|-----------|
| Spec items (`interview`, `mockups`, `api-spec`, `test-spec`) | `/{item}` then commit |
| `story` (spec item) | **Run inline (no subagent)** — the template's hazard scan fans out its own `hazard-scan-agent`s, which must not nest inside a wrapper agent. Load `.claude/templates/spec/story-spec-generation.md` (internal template — NOT the `/story` skill) with the story number, name, and folder already resolved, execute its phases, then commit |
| `root cause analysis` (bug tasks) | Run inline (no subagent): `/rca` — re-verify prior assumptions, test competing hypotheses, confirm the cause with real data, record findings in `spec.md`, mark `[x]` → progress-only commit |
| `design` | `/design-preview` → user approves (optionally with ADR) or `/architecture` → commit (if ADR produced) |
| `red-*` (acceptance, usecase, adapter, selenium, frontend, frontend-api) | `red-agent.md` → `/test-review` → commit → `/refactor` → commit |
| `green-usecase`, `green-adapter X` | `green-agent.md` → `/test-coverage {module} --focus` → commit → `/refactor` → commit |
| `adapters-discovery` | Load `.claude/templates/workflow/adapter-discovery-checklist.md`, run all 3 checks (ports, exceptions, response shape), mark `[x] adapters-discovery`, insert concrete `red-adapter X` / `green-adapter X` steps (or `[S]`) → commit progress.md |
| `steps discovery` (bug tasks) | Run the hazard-catalogue fan-out per `.claude/guidelines/workflow-detail.md` "Hazard scan at steps discovery"; fold each fired-trigger GAP in as a discovered `red-*` step or dismiss it with a reason (an unresolved GAP blocks insertion); resolve the gate with its REQUIRED scan record `[x] steps discovery (scope: <layers>; scanned all _index.md groups; GAPs: <hz-NN folded as red-* / hz-NN dismissed: reason / none fired>)` — a bare `[x] steps discovery` with no `scanned`/`GAPs` clause is an unscanned gate, not a valid completion; insert the concrete TDD steps below the gate → commit progress.md |
| `green-acceptance` | Run inline (no subagent): read `green-agent.md` workflow, load acceptance implementation template, enable the disabled test (remove disable marker — only allowed test change), run acceptance tests, verify GREEN → commit |
| `green-frontend`, `green-frontend-api` | `green-agent.md` → commit → `/refactor` → commit |
| `green-selenium` | `/run-backend` → `/run-frontend` → `green-agent.md` (remove-marker-only: no production code, no Statements changes, no backend changes — if test fails, STOP and report) → commit |
| `harvest` (tier-major boundary) | **Run inline (no subagent)** — it fans out concurrent `red-agent`s, which must not nest inside a wrapper agent. Run every remaining Tier 2 acceptance scenario through `red-agent` (each self-partitions: green → `red-acceptance` `[x]` + other steps `[S]`; red → normal cycle), then baseline the green set against the pre-story build, commit. Full procedure: `.claude/skills/harvest/SKILL.md` |
| `align-design` | Build component → `/align-design` → `/design-review` (MANDATORY) → `/test-coverage frontend --focus` → commit → `/refactor` → `/align-design` verify-only → commit |
| `demo` | `/demo {scenario_test_class}` then progress-only commit |
| `refactor usecase` / `refactor (...)` | Apply change then run affected tests then commit |
| QA `## Cases` checkbox | **No dispatch.** Report the next unchecked case to the user and stop -- the tester verifies it manually against the target environment, then ticks the box (or files a separate bug task if it fails) on their own. |

## Stop and Report

A single `/continue` invocation executes exactly ONE work unit. Within that work unit, don't pause between sub-skills. A `/refactor` work unit ends in two commits — behavior commit, then a separate refactor commit; a **boundary** unit adds a third, the trailing `review-fix:` commit (skipped when no SAFE finding applies). STOP only after the last landed commit, NEVER after the behavior commit while `/refactor` or a boundary's triage is still pending. Once the last commit lands, stop and report: completed step, test results (pass/fail counts from every test run in the work unit), the review-pass verdicts (boundary units only), next step, progress fraction, how to continue. Do NOT read the next `[ ]` step and keep going.

**Re-orientation block (mandatory, last):** close the report with the re-orientation block specified in `.claude/templates/workflow/continue-report-format.md` -- work item type/number/name, scenario or step, step just done, next step, position, and a two-sentence plain-language summary. It goes below everything else and immediately above the `/plain` hint: a terminal scrolls, and a user running several parallel `/continue` sessions must recover which work item this one is without reading back up. Emit it on both stop points, including a sub-skill failure.

End the report with a one-line `/plain` hint (e.g. `Press /plain to have this report re-explained in plain words`) so the user has a button to press when the technical summary didn't land. This is only a pointer -- never invoke `/plain` yourself; it is a manual button the user presses.

**Test results:** Collect pass/fail counts from every sub-skill that runs tests (red-agent, green-agent, test-coverage, refactor). Include them in the final report as a summary line, e.g., `Tests: 15 passed, 0 failed` or `Tests: 14 passed, 1 failed`. When multiple test suites ran, report each separately.

**Red prediction (mandatory for red-* work units):** When the work unit included any red-* phase, copy the red-agent's **Predicted failure**, **Actual failure**, and **Comparison** sections verbatim into the final report — same wording as the Output Summary Format in `.claude/templates/workflow/red-phase-formats.md`. Do NOT collapse to phrases like "test passed as predicted" or "prediction matched" — the user must see both the prediction and the actual result side by side, in their own labelled sections, so the match can be audited without re-reading the agent's return.

**Review-pass findings (mandatory in a boundary unit when triage RAN the passes):** include the `agent-review` and `premortem` verdicts. PASS → one line each (`agent-review: PASS`, `premortem: PASS`). CONCERNS/BLOCK → list each finding with its place in the diff and the named missing guard. SAFE findings applied by the auto-fixer → `review-fix: applied N SAFE finding(s) [<sha>]` plus one line per fix; NEEDS_CYCLE findings → follow-ups the user can act on; NEEDS_CLARIFICATION → the quiz question and the routed outcome. When triage SKIPped, report `Review passes: SKIPPED (triage — <reason>)`. In a non-boundary unit report nothing about them. The passes and the auto-fix never revert the behavior commit.

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

**Input is committed history, not a working-tree snapshot.** Pass each pass the range plus one line on
what the completed block delivered; they read immutable commits, which is what makes overlapping
`/refactor` safe. **Non-gating:** every commit lands regardless of verdict — SAFE findings are auto-fixed
in `review-fix:`, the rest surface as follow-ups, and the only two gates that block a commit stay
`/test-review` and `/refactor`. Whether a boundary runs or skips is the triage predicate's call, below;
a boundary unit with no `/refactor` step (`green-acceptance`, `green-selenium`) produces a single commit
but still runs triage. A QA task dispatches nothing and has no boundary. Why this layer exists, and why
the cadence is per boundary: `.claude/guidelines/review-passes-detail.md`.

## Triage & Auto-Fix

**Triage SKIP/RUN predicate (before dispatching the passes).** From the boundary range's changed
paths (`git diff --name-only <range>`), SKIP both passes (no auto-fix; log the reason) iff
**every** path is under `ProductSpecification/` — progress, stories, spec artifacts, `tests/*.md`
case files. Everything else RUNs: any source file (production or test), any infrastructure file,
and every **workflow-governing doc** under `.claude/**`, so a broken edit to the dispatch loop
itself can never skip review. Deterministic, no agent — and at boundary cadence it RUNs almost
always, skipping only a genuinely inert boundary (a fully-`[S]` scenario, the `## Spec` block).

**Three-way partition.** After the passes return, partition every CONCERNS/BLOCK finding by the
fixability tag its review agent set (a PASS carries no tag — nothing to fix): **SAFE** → stage for
auto-fix; **NEEDS_CYCLE** → add to the follow-up plan (surfaced, never auto-applied);
**NEEDS_CLARIFICATION** → quiz (below). A finding that is **untagged or carries an unrecognized tag
defaults to NEEDS_CYCLE** — the auto-fixer never touches what it cannot positively read as SAFE.
Collect SAFE findings as `{ source, file, line, problem, suggested_fix }`.

**A NEEDS_CYCLE follow-up that becomes a scenario is Tier 2.** In a tier-major story it goes through
`/design-preview` step 2a like any mid-cycle scenario, which writes it into its `tests/` category file
with a **resolved** marker — never `Tier: ?`. `Tier: 2` is the default; it is **Tier 1** when the failure
mode means the feature does not work for its primary user, which every BLOCK verdict is — promotion is
expected, not a deviation owing an argument. Its `progress.md` steps go in as a `### {N}.{M} {Title}` block at the **end** of the matching
`## Tier N — {Category} Scenarios ({file})` section for its own tier, in the same `review-fix:`
commit as the test file. The passes fire only at a boundary, so no cycle is in flight to strand:
when that section precedes the cursor, mark the newcomer's first step `[~]` and return the next
block's `[~]` to `[ ]` (`workflow-detail.md`, "Net-New Scenarios Introduced Mid-Cycle"). If this
unit already archived the item, reopen it in the same `review-fix:` commit — move the folder back
out of `done/` (`stories/done/NN-story-name/` → `stories/NN-story-name/`, or `tasks/done/{N}-…/` →
`tasks/{N}-…/`) **and**, for a story, move its row back from the **Done** table to **In Progress**.
Both halves of the completion fact reverse together, exactly as step 11 landed them together;
reversing only the row leaves a folder in `done/` that the plan says is still open.
Untiered stories are unchanged. Why, and the `tier3/` exit:
`.claude/guidelines/review-passes-detail.md` "Mid-cycle findings default to Tier 2".

**Quiz (NEEDS_CLARIFICATION only) — last resort, gated.** Enforce "Consumer obligations" in
`.claude/templates/workflow/clarification-escalation-test.md`: **demote to NEEDS_CYCLE** any finding with
no recommended option or no one-plain-sentence question, batch the rest into **one** `AskUserQuestion` in
the boundary unit (after the passes, before `review-fix:`, never mid-batch), and read a declined quiz as
*you decide* — take each recommendation. Route each answer: behavior-preserving → SAFE stage;
production-behavior-change → NEEDS_CYCLE plan. **TDD guardrail:** the quiz resolves *which* fix, never
whether to bypass "no behavior change without a failing test first."

**Inline SAFE-only auto-fixer.** Apply the staged SAFE findings directly (no subagent — the orchestrator
already holds them) and run the affected tests. **If any go RED, discard that fix (it was mis-tagged) and
re-route the finding to a follow-up — a `review-fix:` commit never lands red.** Land a single trailing
`review-fix:` commit with the fixes that stayed green, **after** the quiz so directly-SAFE and
clarified-then-SAFE fixes share one commit. Commit order per boundary unit: behavior → `refactor:` →
`review-fix:`. Skip it when triage SKIPped, no finding fired, or nothing SAFE survived. Non-gating —
discarding an un-committed fix is not a revert; a landed commit is never reverted.

## Pre-Commit Checklist

Before the behavior commit, verify: (1) primary skill ran, (2) `/test-review` ran (red phases), (3) `/test-coverage` ran (`green-usecase`/`green-adapter`). `/refactor` and the two review passes are not in the behavior commit — they run after, in the `/refactor` batch. Before stopping, verify: (4) `/refactor` ran (all phases except `green-acceptance`/`green-selenium`/`demo`/spec items), (5) the boundary test was evaluated against the **staged** progress.md, and in a boundary unit the triage predicate was evaluated and — on RUN — the two passes ran over the boundary range, (6) in a boundary unit, any SAFE findings were auto-fixed and landed in a trailing `review-fix:` commit (and any NEEDS_CLARIFICATION was quizzed), (7) when the behavior commit archives the work item's folder to `done/` -- a task to `ProductSpecification/tasks/done/`, a story to `ProductSpecification/stories/done/` in the same commit as its **Done**-table row move -- verify from the **staged** progress.md that the advance is staged and no `[ ]`/`[~]` remains (step 11) -- read the file, never rely on recollection of the edit. If `/refactor` was skipped, or a boundary's triage said RUN but a pass or the auto-fix did not run -- run it before stopping.

## Sub-Skill Dispatch

ALL sub-skills dispatch via Agent tool for context isolation:

| Sub-skill | Dispatch method |
|-----------|----------------|
| `red-*` | `Agent tool` (subagent_type: `red-agent`) — pass layer, story folder path, scenario name, and ADR content (if loaded) |
| `green-*` (except `green-acceptance`) | `Agent tool` (subagent_type: `green-agent`) — pass layer, story folder path, scenario name, and ADR content (if loaded) |
| `green-acceptance` | **Inline** — no subagent. Main agent reads `green-agent.md`, loads acceptance template, enables the test, runs it. Full visibility for user. |
| `harvest` | **Inline** — no subagent. Main agent reads `.claude/skills/harvest/SKILL.md` and fans out its own writer sub-agents (`red-agent`, layer `acceptance`); it must not nest inside a wrapper agent. |
| `/refactor` | `Agent tool` (subagent_type: `refactor-agent`) |
| `/test-review` | `Agent tool` (subagent_type: `test-review-agent`) |
| `/test-coverage` | `Agent tool` (subagent_type: `coverage-agent`) |
| `agent-review` (boundary) | `Agent tool` (subagent_type: `agent-review-agent`) — pass the boundary range + one line of intent. Dispatched in a boundary unit's `/refactor` batch, concurrently with premortem. |
| `premortem` (boundary) | `Agent tool` (subagent_type: `premortem-agent`) — pass the boundary range + one line of intent. Dispatched in a boundary unit's `/refactor` batch, concurrently with agent-review. |

Derive the layer from the checkbox (e.g., `red-adapter storage` → layer `storage`, `green-usecase` → layer `usecase`). Both red-agent and green-agent receive: layer, story folder path, scenario name, and ADR content (if loaded in step 5). The agent resolves test files and templates from its own workflow. The triage predicate and the SAFE-only auto-fixer are **inline in `/continue`** — no subagent, no new dispatch row (see "Triage & Auto-Fix").

**CHAINING: After each sub-step completes (Agent tool return), echo a 1-2 line status summary (agent name, outcome, pass/fail counts) to the user, then immediately dispatch the next sub-step. Do NOT wait for user input between sub-steps — the echo is informational only. (The two review passes are the exception: they dispatch together in one message, in the same batch as `/refactor`.)**

**AGENT LOG: Before the first agent dispatch, clear the log: `> infrastructure/agent-progress.log`. In a boundary unit the two review passes log too (they run in the `/refactor` batch); after the last commit, include the log contents in the stop-and-report summary.**

**LOG REMINDER: Every time you dispatch a sub-agent (Agent tool call), output this line immediately before the call:**
```
> Dispatching {agent-name}. Live progress: tail -f infrastructure/agent-progress.log
```
**This reminds the user where to watch. The line appears in conversation output before the agent starts, so the user can open a terminal and tail the log while the agent works.**

## Rules

- Execute exactly ONE work unit per invocation — a work unit includes ALL sub-skills through the last commit, including a boundary's review passes that run in the `/refactor` batch. Never stop between sub-skills.
- A `/refactor` work unit ends in two commits: the behavior commit (carries the `progress.md` advance) and a separate refactor commit (skipped if `/refactor` changed nothing). A **boundary** unit adds a trailing `review-fix:` commit (skipped when no SAFE finding applies). STOP only after the last landed commit. Otherwise one commit carries `progress.md`.
- Task commit prefix: `task:` (e.g., `task: red-adapter storage (Task 1, Step 1)`)
- If a sub-skill fails, stop immediately -- do NOT mark the step complete
- Mandatory sub-skills per phase: see `.claude/guidelines/workflow-detail.md` sequences

## Updating stories.md

After updating `progress.md` for a **story** (not tasks), update the story's row in `ProductSpecification/stories.md` to reflect current phase status. The phase-column values, the tier-major/untiered split for the Tests and % columns, and the story-completion rule are in `.claude/templates/workflow/stories-md-format.md`. Include `ProductSpecification/stories.md` in the same commit.

## Available Templates

- `.claude/templates/workflow/progress-format.md` -- progress file format for stories, bug tasks, and refactoring tasks
- `.claude/templates/workflow/stories-md-format.md` -- stories.md phase/Tests/% column rules (tier-major and untiered)
- `.claude/templates/workflow/plan-integrity-check.md` -- the six pre-dispatch checks over `progress.md` (step 4)
- `.claude/templates/workflow/continue-report-format.md` -- the re-orientation block that closes every stop-and-report
