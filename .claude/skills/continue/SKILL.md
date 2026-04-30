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
5. **Load ADR context** -- check for `decisions/*-decision.md` files in the story directory. If any exist AND the current step references the ADR (via "see ADR" annotation or matching scenario), read it. ADRs contain architectural decisions, schema changes, edge cases, and implementation guidance that the work unit needs.
6. **Execute one work unit** -- dispatch sub-skills per tables below
7. **Adapter discovery** -- when the next step is `[ ] adapters-discovery`, read usecase constructor to identify ports and map to adapters (see `workflow.md`). Mark `[x] adapters-discovery`, insert concrete steps below it, commit progress.md.
8. **Update progress** -- mark completed, advance next, commit
9. **Update stories.md** -- for stories only, update the phase columns in `ProductSpecification/stories.md` (see below)
10. **Task completion** -- after updating progress, if ALL checkboxes are `[x]` or `[S]` (no `[ ]` or `[~]` remaining), move the task folder to `ProductSpecification/tasks/done/` and include the move in the commit

All workflow sequences, progress tracking rules, adapter discovery procedure, and task types are defined in `.claude/rules/workflow.md`. Progress file format examples are in `.claude/templates/workflow/progress-format.md`.

## Resolving the Argument

| Argument | Resolution |
|----------|------------|
| `task N` | Find `ProductSpecification/tasks/N-*/progress.md` |
| Bare number or name | Resolve story via `ProductSpecification/stories.md` then `ProductSpecification/stories/NN-story-name/progress.md` |
| No argument | Scan recent git log for `Story N` or `Task N` references; most recent wins |

**File lookup:** Use `find` via Bash (not Glob) when searching for progress files or story folders. Glob is unreliable on Windows/MINGW with large `.gitignore` files. For story resolution, derive the folder name from `ProductSpecification/stories.md` (e.g., story 5 "Create a task" → `05-create-task`) and Read the progress file directly. Use `ls` or `find` via Bash only when the folder name is ambiguous.

## Work Unit Dispatch

Each progress.md checkbox maps to sub-skills. Dispatch per `workflow.md` sequences. **This table applies equally to stories AND tasks — never skip `/test-review` or `/refactor` for task steps.**

| Checkbox | Sub-skills |
|----------|-----------|
| Spec items (`interview`, `story`, `mockups`, `api-spec`, `test-spec`) | `/{item}` then commit |
| `design` | `/design-preview` → user approves (optionally with ADR) or `/architecture` → commit (if ADR produced) |
| `red-*` (acceptance, usecase, adapter, selenium, frontend, frontend-api) | `red-agent.md` → `/test-review` → `/refactor` → commit |
| `green-usecase`, `green-adapter X` | `green-agent.md` → `/refactor` → `/test-coverage {module} --focus` → commit |
| `adapters-discovery` | Load `.claude/templates/workflow/adapter-discovery-checklist.md`, run all 3 checks (ports, exceptions, response shape), mark `[x] adapters-discovery`, insert concrete `red-adapter X` / `green-adapter X` steps (or `[S]`) → commit progress.md |
| `green-acceptance` | Run inline (no subagent): read `green-agent.md` workflow, load acceptance implementation template, enable the disabled test (remove disable marker — only allowed test change), run acceptance tests, verify GREEN → commit |
| `green-frontend`, `green-frontend-api` | `green-agent.md` → `/refactor` → commit |
| `green-selenium` | `/run-backend` → `/run-frontend` → `green-agent.md` (remove-marker-only: no production code, no Statements changes, no backend changes — if test fails, STOP and report) → commit |
| `align-design` | Build component → `/align-design` → `/design-review` (MANDATORY) → `/refactor` → `/align-design` verify-only → `/test-coverage frontend --focus` → commit |
| `demo` | `/demo {scenario_test_class}` then progress-only commit |
| `refactor usecase` / `refactor (...)` | Apply change then run affected tests then commit |

## Stop and Report

STOP after every commit. A single `/continue` invocation executes exactly ONE work unit. Within that work unit, don't pause between sub-skills. But once the commit lands, stop immediately and report: completed step, test results (pass/fail counts from every test run in the work unit), next step, progress fraction, how to continue. Do NOT read the next `[ ]` step and keep going.

**Test results:** Collect pass/fail counts from every sub-skill that runs tests (red-agent, green-agent, test-coverage, refactor). Include them in the final report as a summary line, e.g., `Tests: 15 passed, 0 failed` or `Tests: 14 passed, 1 failed`. When multiple test suites ran, report each separately.

## Pre-Commit Checklist

Before committing, verify: (1) primary skill ran, (2) `/test-review` ran (red phases), (3) `/refactor` ran (all phases except `green-acceptance`/`green-selenium`/`demo`/spec items). If `/refactor` was skipped -- run it before committing.

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

Derive the layer from the checkbox (e.g., `red-adapter h2` → layer `h2`, `green-usecase` → layer `usecase`). Both red-agent and green-agent receive: layer, story folder path, scenario name, and ADR content (if loaded in step 5). The agent resolves test files and templates from its own workflow.

**CHAINING: After each sub-step completes (Agent tool return), echo a 1-2 line status summary (agent name, outcome, pass/fail counts) to the user, then immediately dispatch the next sub-step. Do NOT wait for user input between sub-steps — the echo is informational only.**

**AGENT LOG: Before the first agent dispatch, clear the log: `> infrastructure/agent-progress.log`. After the final commit, include the log contents in the stop-and-report summary.**

**LOG REMINDER: Every time you dispatch a sub-agent (Agent tool call), output this line immediately before the call:**
```
> Dispatching {agent-name}. Live progress: tail -f infrastructure/agent-progress.log
```
**This reminds the user where to watch. The line appears in conversation output before the agent starts, so the user can open a terminal and tail the log while the agent works.**

## Rules

- Execute exactly ONE work unit per invocation — a work unit includes ALL sub-skills through the commit. Never stop between sub-skills.
- Always commit after a work unit (include progress.md in the commit)
- Task commit prefix: `task:` (e.g., `task: red-adapter h2 (Task 1, Step 1)`)
- If a sub-skill fails, stop immediately -- do NOT mark the step complete
- Mandatory sub-skills per phase: see `workflow.md` sequences

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
