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

**Harvest — Tier 1 → Tier 2 boundary.** In a tier-major story, after the last Tier 1 scenario and before the first Tier 2 one, the `- [ ] harvest` work unit runs once: batch-write every remaining Tier 2 acceptance test concurrently, partition red (deleted) from green (kept), and baseline the green set against the pre-Tier-1 build to earn its red→green transition. Full procedure: `.claude/skills/harvest/SKILL.md`.

## Why Delivery Is Ordered by Tier

**The ratchet, and what it cost.** Before tiering, every authoring route pointed one way: a hazard GAP folded in as critical-path, a security checklist row produced a critical-path scenario, and the only place below critical path — `extended/` — was reachable by an explicit authoring decision nobody was ever instructed to make. Each route was individually right, and none could ever move a scenario down. Ratchets accumulate: the routes fire on every story, so the critical path grew monotonically until a single story carried 100 cases and nobody could say which of them had to work for the feature to work at all. The failure was not over-thoroughness — the scenarios were real — but the absence of a **destination**: with only one place to put a forced guard, "this must be tested" and "this must be tested first" collapse into the same statement. Tier 2 is that destination, and the pinned floor is what keeps the fix from becoming the opposite ratchet: the classes whose failure is catastrophic can be ordered second, never dropped to Tier 3.

**Tier outranks category, deliberately.** The ordering axis is tier first, category second — all of Tier 1 in category order, then all of Tier 2 in the same order — which means one category file feeds two sections and the plan no longer reads top-to-bottom as `01_API`, `02_UI`, `03_Load`. That is intentional and is not a bug to be tidied later. Category is a property of how a scenario is *written* (which harness, which spec file); tier is a property of what its failure *costs*. Only the second one answers "what do we build next", so only the second one can be the outer axis. Category-major with a tier column would leave the reader deriving the delivery order themselves on every resume, and a derived order is one nobody can be held to. The one thing tiering never changes is a scenario's steps: it reorders work, it does not redefine it.

**The commit-time passes do not review tier assignment, and the floor is why that is safe.** `agent-review-agent` and `premortem-agent` read one work unit's diff. A tier call is *comparative* — it only means anything against the whole set (`.claude/agents/tiering-agent.md` is a single pass over all of it, for exactly this reason) — so a pass reading one commit has no comparand and would be guessing, and a guess that fires from inside the work always runs toward the scenario in front of it being essential. That is the ratchet again, rebuilt one commit at a time. So the passes are silent on tiering, and the guard against a bad call is structural instead: the pinned floor forbids the one irreversible mistake (a catastrophic class landing in Tier 3, where nothing downstream revisits it), while a wrong 1-vs-2 call costs ordering only and self-corrects at the harvest boundary or the demo. Where a pass *does* touch tiers is the newcomer it creates, not the calls already made — `.claude/guidelines/review-passes-detail.md` "Mid-cycle findings default to Tier 2".

## Net-New Scenarios Introduced Mid-Cycle

The spec-time hazard scan (at `/test-spec`) covers the scenarios that existed when it ran. A scenario invented *during* implementation — added in a red phase, not traceable to a scanned `tests/*` scenario — never crossed that gate. Before its red phase locks, route it through `/design-preview`, whose step 2a runs the same per-group hazard fan-out over the new scenario. The design gate is the reuse point: a mid-cycle scenario is not "designed" — and not scanned-clean — until it has passed `/design-preview`. This is the story-side twin of the bug-task `steps discovery` gate; both are the seams where net-new, never-scanned behaviour enters a spec-skipping path, and both reuse the existing per-group fan-out rather than adding a new scan mechanism.

A scenario a `NEEDS_CYCLE` review finding turns into new work is one of these, whatever surfaced it — so it enters through the same gate, and in a tier-major story it is written with a **resolved `Tier: 2`** marker rather than left untiered. The reasoning and the two ways out of that default are in `.claude/guidelines/review-passes-detail.md` "Mid-cycle findings default to Tier 2".

**When its position is above the cursor, the plan write waits for a scenario boundary.** `/continue`'s two placement rules — append at the end of the matching `## Tier N — {Category} Scenarios ({file})` section for the newcomer's own tier, and never above the current `[~]` — are jointly unsatisfiable exactly when that section precedes the cursor. Two shapes reach it: a `BLOCK`-promoted **Tier 1** scenario found during Tier 2 work (the whole Tier 1 region is above the cursor), and a Tier 2 newcomer whose category sorts earlier than the cursor's. If the matching section does not exist, create it in `bootstrapping.md`'s category order (`01_API`, `06_Integration`, `02_UI`, `05_Security`, `03_Load`, `04_Infrastructure`), a new Tier 2 section after `## Harvest — Tier 1 → Tier 2` — and judge "precedes the cursor" by where that order puts it. In these shapes the `review-fix:` commit still writes the **test file** with its resolved marker; only the `progress.md` block waits, for the next **scenario boundary** — the moment the in-flight scenario's last step is `[x]` and no red or disabled test of its is left in the tree. Below the cursor, the common case (a Tier 2 newcomer found during Tier 1 work), nothing waits and the block lands in the `review-fix:` commit as before.

**Three clauses make the wait reachable; without them it deadlocks.** Deferring is only coherent if work can continue *to* the boundary and the block can be placed *at* it, and neither is free:

1. **Deferral requires an in-flight cycle.** It is sanctioned only while some `[~]` sits inside a scenario block. With no in-flight cycle there is nothing to strand, so the block goes in immediately, in the same `review-fix:` commit — and the `stories.md` recount happens there too. This is what keeps a story from reading `100%` with all-left-`✅` while an unbuilt `Tier: 1` scenario sits in `tests/`: the counts derive from `progress.md`, so a deferred block is invisible to them, and a story on its *last* work unit has no later boundary to wait for.
2. **Check 4 must not stop dispatch on this state.** A `tests/*.md` heading absent from the plan whose section precedes the current `[~]` is reported as a **pending deferred placement** and does not block; it becomes blocking again once no `[~]` remains inside a scenario block. Otherwise the very first resume after the `review-fix:` commit stops at step 4, the in-flight scenario can never finish, and the boundary the block is waiting for is never reached — waiting unreachable, placing illegal.
3. **At the boundary the cursor moves onto the newcomer.** Insert the block, mark its first step `[~]`, and return the previously-`[~]` step to `[ ]`. Check 3 is purely syntactic — no `[ ]` above the file's first `[~]` — so a `[ ]` block dropped into an earlier section fails it even at a boundary, where the *harm* is gone but the check cannot tell. Moving the cursor satisfies the check as written, needs no exemption, and is the right sequencing anyway: a promoted Tier 1 scenario genuinely is the next work unit, and everything above it is already `[x]`/`[S]`.

No separate record of the deferral is written into `progress.md`. Clause 2's predicate is computed from the files themselves, and the treatment is the same whether the gap was deliberate or an actor wrote a test file and stopped — place the block at the boundary — so a bespoke marker would add a syntax every reader must learn to distinguish two states that resolve identically.

The remaining cost is one report, not a stop, and it is the right price. The alternatives fail in kind, not degree: appending above the cursor abandons an in-flight cycle with its red test committed, and appending below it either files a scenario under a category section it does not belong to (falsifying the `stories.md` per-category cells) or puts a Tier 1 section under the harvest boundary (falsifying tier-major order for every later resume, which then fails check 2 forever).

## Pre-Commit Review Passes

Every work-unit commit — in any sequence above and in task work — is preceded by two
**fresh-context** passes over the behavior commit (`agent-review-agent`, `premortem-agent`),
a deterministic triage predicate that may SKIP them, and a three-way partition of their
findings into SAFE / NEEDS_CYCLE / NEEDS_CLARIFICATION. The *why* — why this layer differs
*in kind* from the in-loop `/test-review` and `/refactor`, why the passes overlap
`/refactor` and are non-gating, why triage exists, and why a scenario introduced by a
`NEEDS_CYCLE` finding defaults to Tier 2 — is in
`.claude/guidelines/review-passes-detail.md`. `/continue` owns the dispatch mechanics.

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

If no `progress.md` exists, `/continue` derives one from the story's spec artifacts and test files. The full procedure — artifact detection, tier-major emission from the `Tier:` markers, the `tests/tier3/` exclusion, and how a precondition inversion is resolved before bootstrapping rather than annotated in it — is in `.claude/templates/workflow/bootstrapping.md`.

**Migrating a pre-tiering repo.** The prompt changes that introduced tiering ride a framework merge; the per-repo data they read — `Tier:` markers on existing `tests/*.md`, and a tier-major re-derivation — cannot, because those files are content-dependent and no diff can author them. That ships as `/retier` (`.claude/skills/retier/SKILL.md`), routed from `/framework-sync`'s Next Steps and run **once** after the merge: it converts only the stories where implementation has not started, and leaves every other story — in flight, or already delivered — untiered, permanently. Tagging an in-flight story was considered and rejected: the tiering pass writes markers *and* moves scenarios between `tests/` and `tier3/`, so under a plan that is frozen against reordering a move orphans steps, while markers-without-moves produces a markered-but-flat story that `bootstrapping.md` and the plan-integrity check both treat as impossible. The ordering gain a tier split buys is already spent once delivery has begun, so there is nothing on the other side of the trade.

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

**Hazard scan at steps discovery:** bug tasks skip the story-spec step and `/test-spec`, so the fix's guard set is decided *here* — never at a spec-time catalogue gate. Before locking the TDD steps, dispatch the scan exactly as `.claude/guidelines/hazard-catalogue/_index.md` prescribes (read its "How to apply it", "The dispatch shape"); the artifact under scan is the **root cause plus the fix's intended behaviour**, not the whole codebase. Fold every fired-trigger GAP in as a discovered red step (its forced guard is a test that goes red on the hazard), or dismiss it with a reason — an unresolved GAP blocks step insertion the way it blocks a spec-time Phase. This is the gate that catches the one-directional fix: a change that guards one side of a hazard (the inbound duplicate) while leaving its twin (the outbound re-attempt) open. It is wired here and **not** at the `red-usecase`/`red-acceptance` entry: story scenarios already crossed the `/test-spec` gate, so scanning every red phase would re-scan scanned work — the spec-skipping production path that introduces a net-new, never-scanned hazard surface is the bug-task fix, which this gate covers.

**Record the scan in the gate marker, group id included.** The resolved gate must read `[x] steps discovery (scope: <layers>; scanned all _index.md groups; GAPs: <hz-NN folded as red-* / hz-NN dismissed: reason / none fired>)`. The `scanned`/`GAPs` clause is the proof the fan-out ran: it is the bug-task analog of `adapters-discovery (storage, rest)`, which records which adapters that gate found. A bare `[x] steps discovery` — or a marker carrying only the scope, no scan record — is indistinguishable from a skipped scan and is not a valid resolution. The marker is the audit trail; without it, "scan ran" and "scan silently skipped" produce identical progress diffs, which is exactly the hole this gate exists to close.

**Why the id and not just the disposition.** A bug task never reaches `/test-spec`, so it has no `tests/*.md` scenario and no `Tier:` marker — the two places a story's provenance token lives. The gate marker is therefore the *only* place a bug task can record which hazard class a discovered red step was forced by, and `hazard-scan-agent` stamps that id on every GAP precisely so whatever the caller turns the finding into carries it onward. Dropped here, it is unrecoverable: a `red-usecase` step forced by an idempotency GAP becomes indistinguishable from one the root-cause analysis produced, and a later reader asking "was this class ever guarded, or merely never scanned" has nothing to read. Tasks are not tiered, so no pinned floor consumes the token — the audit trail is the whole return, and it costs four characters per GAP.

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
