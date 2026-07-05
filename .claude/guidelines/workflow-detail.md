# Development Workflow — Detail

Deferred companion to `.claude/rules/workflow.md`. The rules file holds the always-on map (lifecycle, status markers, atomic-unit rule, task-type map); this file holds the per-phase step sequences, discovery gates, progress mechanics, resuming protocol, and task sequences. Read it when executing scenario or task work.

## Backend Scenario Sequence

For each scenario in `tests/01_API_Tests.md`:

1. `red-acceptance` → `/red-acceptance` → `/test-review` → commit → `/refactor` (MANDATORY) → commit
2. `design` → `/design-preview` → user approves (optionally with ADR) or escalates to `/architecture` → commit (if ADR produced)
3. `red-usecase` → `/red-usecase` → `/test-review` → commit → `/refactor` (MANDATORY) → commit
4. `green-usecase` → `/green-usecase` → `/test-coverage usecase --focus` → commit → `/refactor` (MANDATORY) → commit
5. `adapters-discovery` → adapter discovery: identify ports and map to adapters, mark `[x] adapters-discovery`, insert concrete `red-adapter X` / `green-adapter X` steps below it (or `[S]` if no new adapters), commit progress.md
6. `red-adapter X` → `/red-adapter X` → `/test-review` → commit → `/refactor` (MANDATORY) → commit (one per port)
7. `green-adapter X` → `/green-adapter X` → `/test-coverage {adapter} --focus` → commit → `/refactor` (MANDATORY) → commit (one per port)
8. `green-acceptance` → `/green-acceptance` → commit

The `[ ] adapters-discovery` checkbox is a gate — it must be resolved before any subsequent step executes. The full procedure is in `.claude/templates/workflow/adapter-discovery-checklist.md`.

## Frontend Scenario Sequence

For each scenario in `tests/02_UI_Tests.md`:

1. `red-selenium` → `/red-selenium` → `/test-review` → commit → `/refactor` (MANDATORY) → commit
2. `red-frontend` → `/red-frontend` → `/test-review` → commit → `/refactor` (MANDATORY) → commit
3. `green-frontend` → `/green-frontend` → commit → `/refactor` (MANDATORY) → commit
4. `red-frontend-api` → `/red-frontend-api` → `/test-review` → commit → `/refactor` (MANDATORY) → commit
5. `green-frontend-api` → `/green-frontend-api` → commit → `/refactor` (MANDATORY) → commit
6. `align-design` → Build component → `/align-design` → `/design-review` (MANDATORY) → `/test-coverage frontend --focus` → commit → `/refactor` (MANDATORY) → `/align-design` verify-only → commit
7. `green-selenium` → `/run-backend` → `/run-frontend` → `/green-selenium` → commit
8. `demo` → `/demo {test_class}` → progress-only commit

## Other Scenario Sequences

Integration, security, load, and infrastructure scenarios each run the **same TDD cycle as the backend sequence above** (`red-acceptance` → `design` → `red/green-usecase` → `adapters-discovery` → `red/green-adapter` → `green-acceptance`). They differ only in the spec file read and the concerns covered:

| Scenario type | Spec file (if exists) | Concerns covered |
|---------------|----------------------|------------------|
| Integration | `tests/06_Integration_Tests.md` | scheduled jobs, webhook idempotency, resilience, email triggers |
| Security | `tests/05_Security_Tests.md` | OWASP: injection, XSS, CSRF, rate limiting, mass assignment, input validation |
| Load | `tests/03_Load_Tests.md` | response-time baselines, concurrent request handling, large data-set behavior |
| Infrastructure | `tests/04_Infrastructure_Tests.md` | database failure handling, recovery after outages, external-service unavailability |

## Net-New Scenarios Introduced Mid-Cycle

The spec-time hazard scan (at `/test-spec`) covers the scenarios that existed when it ran. A scenario invented *during* implementation — added in a red phase, not traceable to a scanned `tests/*` scenario — never crossed that gate. Before its red phase locks, route it through `/design-preview`, whose step 2a runs the same per-group hazard fan-out over the new scenario. The design gate is the reuse point: a mid-cycle scenario is not "designed" — and not scanned-clean — until it has passed `/design-preview`. This is the story-side twin of the bug-task `steps discovery` gate; both are the seams where net-new, never-scanned behaviour enters a spec-skipping path, and both reuse the existing per-group fan-out rather than adding a new scan mechanism.

## Pre-Commit Review Passes

Every work-unit commit — in any sequence above (backend, frontend, integration,
security, load, infra) and in task work — is preceded by two **fresh-context**
review passes that differ *in kind* from the in-loop `/test-review` and `/refactor`.
Those read the work as it is built and within the author's framing; these read the
finished diff cold:

- `agent-review-agent` — surfaces any problem the diff *contains*, deliberately
  unnarrowed (not bound to a checklist).
- `premortem-agent` — assumes the work shipped and caused an incident, then works
  back to the *missing* guard.

They are independent reads of the same diff, so they run **concurrently with each other
and in the same batch as `/refactor`** — overlapping it rather than adding a serial tail
to every work unit. The behavior commit lands first; the passes read that **immutable
commit** while `/refactor` mutates the tree toward a separate refactor commit, so there is
no read/write race. The cost is that they do not see `/refactor`'s behavior-preserving
delta, which its own green test run already gates.

They run **before the refactor commit** but are **not a gate**: a CONCERNS or BLOCK
verdict surfaces as a follow-up and never blocks, reverts, or amends either commit — the
work always lands. This layer exists so a defect that every same-kind gate read past still
meets one reader who did not — the gap that defense-in-depth-by-kind closes. Overlapping
them with `/refactor` is a pure latency win and costs no fidelity: both passes read at the
behavior/correctness altitude, and `/refactor` preserves behavior, so a cold read of the
behavior commit is identical whether it lands a second before or a second after the
refactor commit — we take the second that overlaps `/refactor`.

`/continue` owns the dispatch mechanics — reading the behavior commit, the
surface-don't-block handling, and the skip rule — in its "Pre-Commit Review Passes" and
"Sub-Skill Dispatch" sections. This file does not restate them.

## Infrastructure & Port Configuration

See `.claude/rules/infrastructure.md` (rules) and `.claude/tech/{backend}/templates/infrastructure/infrastructure-details.md` (full details).

## Progress Tracking

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

## Resuming Across Conversations

`progress.md` is the single source of truth for **state** — a new conversation reads it to know which work unit runs next. It does not capture the *why*: predictions that did not match, decisions made in discussion, surprises in existing code, approaches that failed. That context is lost when the user runs `/clear` or `/compact`.

**Journey summaries** preserve the why. They are written by the `/handoff` skill and read by `/continue` on resume — `/handoff` is the sole writer, `/continue` only reads. Run `/handoff` the moment you observe one of these worth-noting moments during work, rather than waiting for the end of the conversation; run it again before `/clear` or `/compact` as a final sweep. Do not spam it: `/handoff` fires only on a genuine trigger — a prediction mismatch, a decision reached in discussion, a surprise, a mistake worth not repeating, a quirk a future scenario will hit (the authoritative list is in `.claude/templates/workflow/summary-format.md` — "When to Write"). Never run it for routine progress that a future session can derive from `progress.md`, the commit, or the code. It is a targeted capture, not a periodic checkpoint. Capturing noteworthy material as it happens is why `/handoff` writes and `/continue` does not — the signal lives in the discussion and debugging, not in the work-unit artifacts. Because `/handoff` may run many times per conversation, it is idempotent: before appending it checks the summary file and skips any entry already recorded.

Summary files are append-only and created lazily: if a conversation had nothing noteworthy, no file is written, and "nothing to record" is a valid, common outcome. When a scenario's last step commits, `/handoff` promotes enduring codebase quirks to `carryover.md` at the story root so later scenarios inherit them.

See the `/handoff` and `/continue` skills for the mechanics (file layout, carryover promotion, reading on resume) and `.claude/templates/workflow/summary-format.md` for when to write an entry and the strict entry format.

---

# Task Workflow Detail

Bug and refactoring tasks follow the same TDD discipline as stories: `/test-review` after red phases, `/refactor` after every phase (except `green-acceptance`, `green-selenium`, `demo`), with `/refactor` in its own commit separate from the behavior commit (see Atomic Work Units in `.claude/rules/workflow.md`). Task commits use the `task:` prefix — both the behavior commit and the refactor commit. Tasks don't need bootstrapping -- `/task` generates everything at creation time.

## Bug Task Sequence (Discovery-First)

Bug tasks do NOT pre-plan TDD steps at creation time. The cause is usually unknown when the task is filed -- planning a full red/green/refactor sequence up front commits to assumptions that turn out wrong. For the same reason, the bug **spec** at creation captures only the observable problem and how to reproduce it — describe the problem as thoroughly as possible (symptoms, observed vs. expected, environment, frequency, any captured response/error), but do NOT state a root cause, a proposed solution, affected layers, or key files. Those are produced by the discovery sequence below: `root cause analysis` records the cause and key files in `spec.md`, `design` settles the fix approach, and `steps discovery` scopes the layers. Every claim about the fix is deferred until something has been investigated. Instead, every bug starts with discovery:

1. `reproduce in prod-copy` (prod-copy bugs only) — manually reproduce the bug in the prod-copy environment, confirm symptoms match the report, capture any unexpected behavior; progress-only commit
2. `root cause analysis` — run `/rca`: re-verify every prior assumption, test competing hypotheses, and confirm the cause with real data (logs, test runs, measurements) before accepting it. Locate the defect and document evidence-backed findings in `spec.md`, separating measured fact from reasoned attribution — a carried-over hypothesis is not a root cause; progress-only commit
3. `design` — with the root cause known, design the fix approach via `/design-preview`; the user approves (optionally producing an ADR for an architectural fix) or escalates to `/architecture`; commit (if an ADR is produced). This runs **before** `steps discovery` so the steps are planned against an approved approach rather than an assumed one. Mark `[S]` only when the fix approach is mechanically unambiguous from the root cause (a one-line guard, a corrected constant) and there is no design decision to make.
4. `steps discovery` — based on the root cause and the approved design, determine which layers the fix touches and insert concrete TDD steps below this gate (`red-*`, `green-*`, `align-design`, `demo`, etc.); record scope + hazard-scan outcome in the gate marker (see "Hazard scan at steps discovery"); commit progress.md

The `[ ] steps-discovery` checkbox is a gate -- it must be resolved before any subsequent TDD step executes. It is the bug-task analog of `[ ] adapters-discovery` in story scenarios. The `design` step precedes it: the approach is approved first, then decomposed into steps.

**Acceptance red when application behavior changes:** at steps discovery, ask: does the fix change externally observable application behavior — a response body, a status code, an error surface, an end-to-end flow — or invalidate acceptance-level test infrastructure (e.g., an external-service mock that must be tightened to mirror the real service)? If yes, the discovered steps MUST include a `red-acceptance` + `green-acceptance` pair surrounding the layer-level steps — a single-layer red/green is only sufficient when the change is invisible at the black-box level (pure internal restructuring, logging, performance). Ordering: all `red-*` steps (layer + acceptance) land before the first `green-*` step when one production fix resolves every red surface. In that shape `green-acceptance` is verification-only — there is no disabled test to enable because `red-acceptance` made existing tests fail via tightened infrastructure rather than adding a disabled test; state "verification only; no production or test changes" in the step description so the remove-marker-only rule is visibly satisfied. See the bug example in `.claude/templates/workflow/progress-format.md`.

**Hazard scan at steps discovery:** bug tasks skip `/story` and `/test-spec`, so the fix's guard set is decided *here* — never at a spec-time catalogue gate. Before locking the TDD steps, scan the planned fix against the hazard catalogue exactly as the spec-time skills do: per `.claude/guidelines/hazard-catalogue/_index.md` ("How to apply it"), fan out one `hazard-scan-agent` per group in its **Groups** list — iterate that list, never a hand-copied set — each carrying the root cause plus the intended change, `_index.md`, and its one group file; dispatch them concurrently, then run one synthesis pass over the seams. The artifact under scan is the fix's intended behaviour, not the whole codebase. Fold every fired-trigger GAP in as a discovered red step (its forced guard is a test that goes red on the hazard), or dismiss it with a reason — an unresolved GAP blocks step insertion the way it blocks a spec-time Phase. This is the gate that catches the bug-89 shape: a fix that guards one direction of a hazard (inbound duplicate) while leaving its twin (outbound re-attempt) open. It is wired here and **not** at the `red-usecase`/`red-acceptance` entry: story scenarios already crossed the `/test-spec` gate, so scanning every red phase would re-scan scanned work — the spec-skipping production path that introduces a net-new, never-scanned hazard surface is the bug-task fix, which this gate covers.

**Record the scan in the gate marker.** The resolved gate must read `[x] steps discovery (scope: <layers>; scanned all _index.md groups; GAPs: <folded as red-* / dismissed: reason / none fired>)`. The `scanned`/`GAPs` clause is the proof the fan-out ran: it is the bug-task analog of `adapters-discovery (h2, rest)`, which records which adapters that gate found. A bare `[x] steps discovery` — or a marker carrying only the scope, no scan record — is indistinguishable from a skipped scan and is not a valid resolution. The marker is the audit trail; without it, "scan ran" and "scan silently skipped" produce identical progress diffs, which is exactly the hole this gate exists to close.

**Why `reproduce in prod-copy` is a separate step:** prod-copy reproduction often surfaces details the original reporter omitted (exact field length, browser, sequence of actions, network response). Doing it before root-cause analysis prevents wasted investigation on the wrong code path.

**Refactoring tasks are unaffected** by the discovery sequence — their steps are user-defined from the spec interview, since the scope is structural and known up front.

**Scoped steps (refactoring + story scenarios only):** Progress should only include TDD steps for layers the fix actually touches. If the fix is pure CSS, don't generate logic/API/align-design steps. If the fix is backend-only, don't generate frontend steps. Affected layers are determined from the spec at creation time. For bug tasks, layer scoping happens at `steps discovery`, not at creation.

## QA Task Sequence

QA tasks define a reusable manual checklist verified against an external environment (prod-copy, staging). Their lifecycle differs from bug/refactoring tasks in three ways:

- **No TDD, no dispatch.** `progress.md` checkboxes are not work units — each is a manual verification step performed by a human in a browser. `/continue` does NOT auto-dispatch QA cases; on a QA task it reports the next unchecked case and reminds the tester to run it by hand.
- **Session lifecycle.** `spec.md` is the immutable checklist definition (Cases section). `progress.md` mirrors those cases as `[ ]` checkboxes for the active test session. The tester ticks them as cases pass. To re-run for a new deploy, revive the task from `done/` and reset checkboxes — never edit `spec.md` to track sessions.
- **Failures file separate bug tasks.** When a case fails during a session, the checkbox stays `[ ]` and the tester creates a separate `/task bug` (prod-copy variant if reproduced there) for the failure. Never overload the checkbox with a fail marker — `[x]` means verified, `[ ]` means not yet verified or under investigation.
- **Watched execution via `/qa-run`.** A session is driven with `/qa-run`: a headed browser the tester watches, one action at a time, a screenshot per action. Navigation is **UI-only** — reach every page by clicking buttons/links, never by typing a direct in-app URL (the same constraint Selenium tests follow; see `.claude/guidelines/frontend-rules.md` "FORBIDDEN in-app navigation via URL", whose two exceptions — app-root entry and genuine external-arrival links such as an emailed verify/reset link — apply to manual QA too). Executing the list also validates the list: a case that cannot be verified through the UI, or whose intent is ambiguous, is a defect in the **test model** (fix `spec.md`), distinct from a **product** defect (file `/task bug`).

Commits use the `task:` prefix like other task types. Multiple cases may be ticked in a single commit (a smoke session is not work-unit-atomic the way TDD is).

Operational details: `/task` skill (creation, sections, progress format), `/continue` skill (execution, dispatch, adapter discovery, steps discovery), `/qa-run` skill (watched prod-copy execution, UI-only navigation, harness).
