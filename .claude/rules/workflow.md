# Development Workflow

## Lifecycle

Every story follows: **interview → spec → backend scenarios → integration scenarios → frontend scenarios → security scenarios → load scenarios → infrastructure scenarios**.

**High-level progress** is tracked in `ProductSpecification/stories.md` — three tables: **In Progress**, **Backlog**, and **Done**. Phase columns (Spec, Backend, Integration, Frontend, Security, Load, Infra) per story. The `/continue` skill updates it after each work unit commit. Phase values: ✅ done, 🔧 in progress, — not started, · no story folder yet. When a story reaches 100% (all scenarios done), move its row from the **In Progress** table to the **Done** table.

**Backlog** stories have all `·` columns (no folder yet). When `/continue N` targets a Backlog story, auto-promote it: move the row from **Backlog** to **In Progress** in `ProductSpecification/stories.md` before starting work.

Spec phase: `/interview` → `/story` → `/mockups` → `/api-spec` → `/test-spec` (one at a time, review each before proceeding).

## Backend Scenario Sequence

For each scenario in `tests/01_API_Tests.md`:

1. `red-acceptance` → `/red-acceptance` → `/test-review` → `/refactor` (MANDATORY) → commit
2. `design` → `/design-preview` → user approves (optionally with ADR) or escalates to `/architecture` → commit (if ADR produced)
3. `red-usecase` → `/red-usecase` → `/test-review` → `/refactor` (MANDATORY) → commit
4. `green-usecase` → `/green-usecase` → `/refactor` (MANDATORY) → `/test-coverage usecase --focus` → commit
5. `adapters-discovery` → adapter discovery: identify ports and map to adapters, mark `[x] adapters-discovery`, insert concrete `red-adapter X` / `green-adapter X` steps below it (or `[S]` if no new adapters), commit progress.md
6. `red-adapter X` → `/red-adapter X` → `/test-review` → `/refactor` (MANDATORY) → commit (one per port)
7. `green-adapter X` → `/green-adapter X` → `/refactor` (MANDATORY) → `/test-coverage {adapter} --focus` → commit (one per port)
8. `green-acceptance` → `/green-acceptance` → commit

The `[ ] adapters-discovery` checkbox is a gate — it must be resolved before any subsequent step executes. The full procedure is in `.claude/templates/workflow/adapter-discovery-checklist.md`.

## Integration Scenario Sequence

For each scenario in `tests/06_Integration_Tests.md` (if exists): same TDD cycle as backend scenarios above. Integration scenarios cover cross-cutting concerns: scheduled jobs, webhook idempotency, resilience, and email triggers.

## Frontend Scenario Sequence

For each scenario in `tests/02_UI_Tests.md`:

1. `red-selenium` → `/red-selenium` → `/test-review` → `/refactor` (MANDATORY) → commit
2. `red-frontend` → `/red-frontend` → `/test-review` → `/refactor` (MANDATORY) → commit
3. `green-frontend` → `/green-frontend` → `/refactor` (MANDATORY) → commit
4. `red-frontend-api` → `/red-frontend-api` → `/test-review` → `/refactor` (MANDATORY) → commit
5. `green-frontend-api` → `/green-frontend-api` → `/refactor` (MANDATORY) → commit
6. `align-design` → Build component → `/align-design` → `/design-review` (MANDATORY) → `/refactor` (MANDATORY) → `/align-design` verify-only → `/test-coverage frontend --focus` → commit
7. `green-selenium` → `/run-backend` → `/run-frontend` → `/green-selenium` → commit
8. `demo` → `/demo {test_class}` → progress-only commit


## Security Scenario Sequence

For each scenario in `tests/05_Security_Tests.md` (if exists): same TDD cycle as backend scenarios above. Security scenarios cover OWASP concerns: injection, XSS, CSRF, rate limiting, mass assignment, and input validation.

## Load Scenario Sequence

For each scenario in `tests/03_Load_Tests.md` (if exists): same TDD cycle as backend scenarios above. Load scenarios cover performance and volume concerns: response time baselines, concurrent request handling, and large data set behavior.

## Infrastructure Scenario Sequence

For each scenario in `tests/04_Infrastructure_Tests.md` (if exists): same TDD cycle as backend scenarios above. Infrastructure scenarios cover resilience concerns: database failure handling, recovery after outages, and external service unavailability.

## Infrastructure & Port Configuration

Moved to `.claude/rules/infrastructure.md` (rules) and `.claude/tech/{backend}/templates/infrastructure/infrastructure-details.md` (full details).

## Progress Tracking

Each story has a progress file: `ProductSpecification/stories/NN-story-name/progress.md`.

### Status Markers

- `[x]` — done
- `[~]` — in-progress (current step)
- `[ ]` — pending
- `[S]` — skipped

### Reading Progress

When the user says "continue working on story X" or runs `/continue X`:
1. Read `ProductSpecification/stories/NN-story-name/progress.md`
2. Find the first `[ ]` or `[~]` entry — that is the next work unit
3. Report current status and what step will execute next

### Updating Progress

After completing a work unit:
1. Change `[~]` to `[x]` for the completed step
2. Change the next `[ ]` to `[~]` if continuing
3. Commit the progress file with the work unit commit

### Bootstrapping

If no `progress.md` exists, create one by:
1. Detecting spec artifacts in the story directory:
   - `interview`: check if `interview.md` exists
   - `story`: check if `NN_StoryName.md` exists
   - `mockups`: check if `mockups/` has files
   - `api-spec`: check if `endpoints.md` exists
   - `test-spec`: check if `tests/01_API_Tests.md` exists
   - **Edge case**: if all spec items exist EXCEPT `interview.md`, mark `[S] interview (spec completed without interview)` — don't force retroactive interviews on old stories
2. Reading the story's test specs (`tests/01_API_Tests.md`, `tests/06_Integration_Tests.md` if exists, `tests/02_UI_Tests.md`, `tests/05_Security_Tests.md` if exists, `tests/03_Load_Tests.md` if exists, `tests/04_Infrastructure_Tests.md` if exists)
3. Scanning existing test classes and production code for completed steps
4. Marking completed steps as `[x]`, next step as `[~]`, rest as `[ ]`
5. For backend/integration/security scenarios, **always include `design` after `red-acceptance`** — it is mandatory for every scenario that needs new implementation. Only omit it when the entire scenario is `[S]` (existing implementation covers everything). Include `[ ] adapters-discovery` after `green-usecase` — adapter discovery runs when this step is reached.
6. For frontend scenarios, include `demo` as the final step per scenario

## Atomic Work Units

A work unit is indivisible: ALL sub-skills in the dispatch sequence (primary skill → test-review → test-coverage → refactor → commit) must execute to completion before stopping. Within a work unit, never pause between sub-skills to report status or ask for confirmation. But after the commit that concludes the work unit, STOP — do not continue to the next work unit. The only valid stop points are: (1) after the commit, (2) on sub-skill failure. If a sub-skill fails, stop immediately and report — but a successful sub-skill must be followed by the next sub-skill in the sequence without interruption.

## Resuming Across Conversations

The `progress.md` file is the single source of truth. New conversations should read it to pick up exactly where the previous conversation left off. No other state is needed.

---

# Task Workflow

Tasks are standalone work items that don't need the full story lifecycle. Two types:

- **bug** — Something is broken. Fix it with a targeted TDD cycle.
- **refactoring** — Structural improvement. User-defined steps with standard TDD sub-skills.

Tasks live in `ProductSpecification/tasks/{N}-{type}-{slug}/`. Each task has a progress file at that path. When all checkboxes in a task's `progress.md` are `[x]` (or `[S]`), the task folder is moved to `ProductSpecification/tasks/done/`.

Tasks follow the same TDD discipline as stories: `/test-review` after red phases, `/refactor` after every phase (except `green-acceptance`, `green-selenium`, `demo`). Task commits use `task:` prefix. Tasks don't need bootstrapping -- `/task` generates everything at creation time.

**Scoped steps:** Progress should only include TDD steps for layers the fix actually touches — applies to tasks, and to individual story scenarios. If the fix is pure CSS, don't generate logic/API/align-design steps. If the fix is backend-only, don't generate frontend steps. Affected layers are determined from the spec at creation time.

Operational details: `/task` skill (creation, sections, progress format), `/continue` skill (execution, dispatch, adapter discovery).
