# Development Workflow — Detail

Deferred companion to `.claude/rules/workflow.md`. The rules file holds the always-on map (lifecycle, status markers, atomic-unit rule, task-type map); this file holds the per-phase step sequences, discovery gates, progress mechanics, resuming protocol, and task sequences. Read it when executing scenario or task work.

## Whole-Story Coordination

For story implementation, load `.claude/templates/workflow/story-stages.md` before
selecting a scenario step. It coordinates all remaining work across both tiers in
three passes while preserving the existing plan. Its interview, selection, harvest,
publication, and continuation rules supersede the scenario sequencing below.
The sequences below supply lane mechanics; tasks retain their existing execution.

## Backend Scenario Sequence

For each scenario in `tests/01_API_Tests.md`, use the three-stage concurrent
sequence in `.claude/templates/workflow/parallel-backend-stages.md`. Stage 1 runs
acceptance RED beside contract design and adapter discovery, then freezes the
interfaces at a user-review boundary. Stage 2 runs complete use-case and adapter
RED-to-GREEN lanes concurrently, then concurrent gap-driven coverage follow-ups.
The final stage closes acceptance with GREEN verification.

Scenarios whose serial sequence is already in progress keep the legacy
`red-acceptance` through `green-acceptance` shape. Its `adapters-discovery` remains
a gate and follows `.claude/templates/workflow/adapter-discovery-checklist.md`.
`/framework-sync` upgrades a legacy scenario only while every step in that scenario
is still pending; the first completed, skipped, or current step freezes the whole block.

## Frontend Scenario Sequence

For each scenario in `tests/02_UI_Tests.md`, use this shared-worktree contract:

1. `stage-1 frontend acceptance RED + interface design` runs Selenium RED beside
   non-interactive design. It fixes the component, logic, API-client, and test
   interfaces before implementation starts.
2. `stage-2 frontend implementation lanes` runs complete frontend-logic,
   API-client, and design-alignment lanes concurrently. Each lane preserves its own
   RED-before-GREEN and refactor sequence and owns a disjoint file set; Stage 1
   interfaces are read-only.
3. `stage-3 frontend acceptance GREEN + demo` starts only after every Stage 2 lane
   joins successfully. It runs remove-marker-only Selenium GREEN, then performs
   the headed demo after GREEN.

Workers share the worktree but never stage, commit, or edit `progress.md`. The
orchestrator alone declares ownership, rejects overlapping paths, joins every lane
exactly once, runs combined verification, stages explicit paths, commits, and
advances stages. A failed lane leaves its stage current while successful disjoint
results remain available for resume. Late or duplicate completion cannot advance a
stage or launch its successor twice.

Legacy frontend scenarios already started with `red-selenium` through `demo` keep
that serial shape permanently. Do not rewrite an in-flight scenario beneath its
cursor.

## Other Scenario Sequences

Integration, security, load, and infrastructure scenarios use the **same
three-stage sequence as backend scenarios**. They differ only in the spec file read
and the concerns covered:

| Scenario type | Spec file (if exists) | Concerns covered |
|---------------|----------------------|------------------|
| Integration | `tests/06_Integration_Tests.md` | scheduled jobs, webhook idempotency, resilience, email triggers |
| Security | `tests/05_Security_Tests.md` | OWASP: injection, XSS, CSRF, rate limiting, mass assignment, input validation |
| Load | `tests/03_Load_Tests.md` | response-time baselines, concurrent request handling, large data-set behavior |
| Infrastructure | `tests/04_Infrastructure_Tests.md` | database failure handling, recovery after outages, external-service unavailability |

**Harvest — Tier 1 → Tier 2 boundary.** In a tier-major story, after the last Tier 1 scenario and before the first Tier 2 one, the `- [ ] harvest` work unit runs once: batch-write every remaining Tier 2 acceptance test concurrently, partition red (deleted) from green (kept), and baseline the green set against the pre-Tier-1 build to earn its red→green transition. Full procedure: `.claude/skills/harvest/SKILL.md`.

## Why Delivery Is Ordered by Tier

**The ratchet, and what it cost.** Before tiering, generated edge-case scenarios and security checklist rows defaulted to the critical path, and the only place below it — `extended/` — was reachable by an explicit authoring decision nobody was ever instructed to make. Each route was individually right, and none could ever move a scenario down. Ratchets accumulate: the routes fire on every story, so the critical path grew monotonically until a single story carried 100 cases and nobody could say which of them had to work for the feature to work at all. The failure was not over-thoroughness — the scenarios were real — but the absence of a **default destination**. Tier 3 is that destination for generated non-happy-path coverage; Tier 2 admits only the exceptions defined by `tier-ladder.md`.

**Tier outranks category, deliberately.** The ordering axis is tier first, category second — all of Tier 1 in category order, then all of Tier 2 in the same order — which means one category file feeds two sections and the plan no longer reads top-to-bottom as `01_API`, `02_UI`, `03_Load`. That is intentional and is not a bug to be tidied later. Category is a property of how a scenario is *written* (which harness, which spec file); tier is a property of what its failure *costs*. Only the second one answers "what do we build next", so only the second one can be the outer axis. Category-major with a tier column would leave the reader deriving the delivery order themselves on every resume, and a derived order is one nobody can be held to. The one thing tiering never changes is a scenario's steps: it reorders work, it does not redefine it.

## Net-New Scenarios Introduced Mid-Cycle

A scenario invented *during* implementation — added in a red phase and not traceable
to an existing `tests/*` scenario — must pass through `/design-preview` before its red
phase locks. Classify it immediately with `.claude/templates/spec/tier-ladder.md` and
write a resolved marker; the story-wide comparative tiering pass has already run.

**Placement.** A Tier 3 newcomer is recorded under `tests/tier3/` and never enters
`progress.md`. For Tier 1 or Tier 2, `/continue` appends the block to the matching
tier/category section in the same commit that writes the test file, creating the
section in `bootstrapping.md` order if needed.

**The cursor still moves onto an implemented newcomer.** Check 3 of the plan-integrity check is purely syntactic — no `[ ]` above the file's first `[~]` — so a `[ ]` block dropped into an earlier section fails it. Insert the block, mark its first step `[~]`, and return the previously-`[~]` step to `[ ]`.

Appending below the cursor instead can file the scenario under the wrong category and falsify the `stories.md` per-category cells.

## Infrastructure & Port Configuration

See `.claude/rules/infrastructure.md` (rules) and `.claude/tech/{backend}/templates/infrastructure/infrastructure-details.md` (full details).

## Progress Tracking

### Free-form work units

Named checkbox kinds select their specialized routes. Any other checkbox text is a
free-form work-unit intent: `/continue` executes it inline in the main agent without
inventing red, green, coverage, or extra gates.
The direct route still runs affected tests, advances progress, and follows the normal
commit and stop rules. The fallback is an explicit `/continue` route.

### Reading Progress

When the user says "continue working on story X" or runs `/continue X`:
1. Read `ProductSpecification/stories/NN-story-name/progress.md` — or `ProductSpecification/stories/done/NN-story-name/progress.md` if the story is archived (`.claude/rules/workflow.md`, "Resolving a story folder")
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

`worklog/`, beside the progress file, holds `/continue`'s routine execution records
(`.claude/templates/workflow/worklog-format.md`). Evidence, notes, and
composite checkpoints go there, never on a progress continuation line; checkbox state still comes only from `progress.md`.

**Journey summaries** preserve the why. They are written by the `/handoff` skill and read by `/continue` on resume — `/handoff` is the sole writer, `/continue` only reads. Run `/handoff` the moment you observe one of these worth-noting moments during work, rather than waiting for the end of the conversation; run it again before `/clear` or `/compact` as a final sweep. Do not spam it: `/handoff` fires only on a genuine trigger — a prediction mismatch, a decision reached in discussion, a surprise, a mistake worth not repeating, a quirk a future scenario will hit (the authoritative list is in `.claude/templates/workflow/summary-format.md` — "When to Write"). Never run it for routine progress that a future session can derive from `progress.md`, the commit, or the code. It is a targeted capture, not a periodic checkpoint. Capturing noteworthy material as it happens is why `/handoff` writes and `/continue` does not — the signal lives in the discussion and debugging, not in the work-unit artifacts. Because `/handoff` may run many times per conversation, it is idempotent: before appending it checks the summary file and skips any entry already recorded.

Summary files are append-only and created lazily: if a conversation had nothing noteworthy, no file is written, and "nothing to record" is a valid, common outcome. When a scenario's last step commits, `/handoff` promotes enduring codebase quirks to `carryover.md` at the story root so later scenarios inherit them.

See the `/handoff` and `/continue` skills for the mechanics (file layout, carryover promotion, reading on resume) and `.claude/templates/workflow/summary-format.md` for when to write an entry and the strict entry format.

---

# Task Workflow Detail

All task commits use `task:`. Task type selects the execution discipline; the
affected layer only selects concrete checks. The authoritative shape table is
`.claude/templates/workflow/steps-discovery-shapes.md`.
For existing tasks only, read legacy `bug` as `bugfix` and `refactoring` as
`refactor`; `/task` never emits those legacy values.

## TDD Tasks

Only `behavior-change` and `bugfix` use TDD. Both run `/test-review` after RED and
`/refactor` after RED/GREEN phases where the atomic-unit rule requires it.

**Behavior change (design-first):** `spec` → `design` → `steps discovery`. The spec
states current and expected observable behavior. Discovery scopes affected layers
and inserts named RED-to-GREEN pairs.

**Bugfix (discovery-first):** optional `reproduce in prod-copy` → `root cause
analysis` → `design` → `steps discovery`. Creation records symptoms and reproduction,
never an assumed cause or solution. RCA writes evidence-backed cause and key files;
design settles the fix; discovery inserts the TDD plan.

For both types, `steps discovery` is a blocking plan-expansion gate. If behavior is
externally observable, include acceptance RED/GREEN. All RED steps precede the
production change that resolves them.

## No-TDD Tasks

`refactor`, `infra`, `general`, and `qa` never contain RED/GREEN work units.

**Refactor (design-first):** `spec` → `design` → `refactor (steps discovery)`.
Discovery reconciles the approved design and current repository into direct,
behavior-preserving `## Work` steps. Record `plan: +N/-N/~N`; at least one count must
be non-zero. Existing focused and affected suites verify behavior preservation.

**Infra and general:** `spec` → `design` → direct `### Step N` work units from the spec.
Each step runs relevant tests, structural checks, or validators. Infra work changes
only repository-managed infrastructure-as-code; never mutate remote state manually.

If any no-TDD task reveals a required executable behavior change, stop before that
change and reclassify the task or split it into `behavior-change` or `bugfix`.

**QA:** `spec` → `design` → serial reusable manual checklist items.
`/continue` reports the next unchecked case; `/qa-run` drives it in a watched browser.
For a new session, revive the archived task and reset progress without changing the
spec. A failed case stays unchecked and produces a separate `bugfix` task. Multiple
passed cases may land in one `task:` commit.

For every task type, `design` is one atomic work unit: draft the design from the
task's frozen input, then request one approval.

Operational details live in `/task`, `/continue`, and `/qa-run`.
