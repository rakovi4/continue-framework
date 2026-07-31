# Development Workflow

## Source Control

This project does **not** use pull requests or merge requests — commits land directly on the working branch. Never offer to open a PR/MR or invoke a platform's PR/MR CLI, and never reference "the PR description" as a place for context. Commit messages are the only review surface; put the *why* there.

## Lifecycle

Every story follows: **interview → spec → backend scenarios → integration scenarios → frontend scenarios → security scenarios → load scenarios → infrastructure scenarios**.

Those six scenario types are the **categories**, not the delivery order. In a tier-major story, delivery runs **tier-first**: all of Tier 1 in that category order, then the `harvest` boundary, then all of Tier 2 in the same order. The boundary is the story's **shippable milestone** — when every Tier 1 scenario is done the feature works for its primary user, which is what all-left-`✅` phase cells mean; Tier 2 hardens what already works. Why tier outranks category is in `.claude/guidelines/workflow-detail.md` ("Why Delivery Is Ordered by Tier").

**High-level progress** is tracked in `ProductSpecification/stories.md` — three tables: **In Progress**, **Backlog**, and **Done**. Phase columns (Spec, Backend, Integration, Frontend, Security, Load, Infra) per story. The `/continue` skill updates it after each work unit commit. Phase values: ✅ done, 🔧 in progress, — not started, · no story folder yet. When **every checkbox in the story's `progress.md` is `[x]` or `[S]`** — not merely when Tests/% read full, which ignore non-scenario checkboxes like `harvest` — move its row from the **In Progress** table to the **Done** table (see `.claude/templates/workflow/stories-md-format.md`).

**Backlog** stories have all `·` columns (no folder yet); rows are added by the `/story` skill. When `/continue N` targets a Backlog story, auto-promote it: move the row from **Backlog** to **In Progress** in `ProductSpecification/stories.md` before starting work.

Spec phase: `/interview` → story spec (dispatched by `/continue` via its internal template, not the `/story` skill) → `/mockups` → `/api-spec` → `/test-spec` (one at a time, review each before proceeding).

## Where the Current State Lives

**The acceptance suite is the current-state documentation of what the product does.** It is grouped by functionality rather than by story, each test carries its Gherkin scenario in its scenario description (a display annotation, a subtest name, or a docstring — per the tech binding), it is black-box (HTTP and browser only, so it describes externally observable behavior), and it is self-correcting: when a later increment changes a behavior, the earlier test is rewritten or the build goes red — an outdated behavior makes the build red, never a document quietly stale. So a reader asking *what does this area do today* reads the acceptance tests **of the area it is about to touch** — test class names, scenario descriptions, Statements — and never sweeps story folders to reconstruct the present.

**Read only the enabled tests.** A test still carrying its disable/skip marker is a pending increment — a `red-acceptance` awaiting its green, or an unharvested Tier 2 scenario — not shipped behavior. It is the one part of the suite that *can* go quietly stale, because a disabled test never makes the build red. And in a repo with no acceptance suite yet, say so explicitly and fall back to the story folders — never degrade to a silent sweep.

**Suite silence about an area is not evidence of absence.** An area can be shipped and still leave no black-box trace: behavior asserted only at the usecase or adapter level, or a bug fix that legitimately took the single-layer path. So no acceptance test for the area you are about to touch means *unknown*, not *unbuilt* — and the next read is the **production code of that area** (the usecase that owns the operation, then its adapters), never a sweep of story folders. Say what you found and where, so the gap stays visible instead of being silently filled in.

**A story folder is a delta plus its rationale**, not a description of the present. It holds one increment: the story spec, `interview.md`, `mockups/`, `endpoints.md`, `decisions/*-decision.md`, and `tests/` (including `tier3/`). When the same functionality is extended by a later story, no single folder answers "what does this do now" — the later delta supersedes the earlier one and neither says so. Read a story folder for a **named** precedent (the decision behind a specific rule, the interview behind a specific constraint), never as a sweep. The one artifact in there that is *not* frozen at story close is `mockups/`, which later work backports into — see the table below.

What the suite genuinely cannot hold, each with an existing home:

| Not in the suite | Why | Where it lives |
|---|---|---|
| Deliberate non-goals ("we do not do X") | No test asserts the absence of something unbuilt | The story spec — correctly historical, a decision of that moment |
| Rationale (why a limit is *that* number) | A test states the rule, not the argument for it | `decisions/*-decision.md` and `interview.md` in the story folder |
| Tier 3 scenarios | Recorded and never built, so absent from the code by definition | `tests/tier3/` |
| The UI's visual design (layout, spacing, color) | A browser test asserts behavior and content, never pixels | `ProductSpecification/ui/ui-conventions.md`, the cross-story design authority, plus the owning story's `mockups/` — read as the current design reference, kept current by backporting |

**Rejected, on purpose:** a consolidated `ProductSpecification/features/{slug}.md` layer, folded in by a `feature-doc` work unit at story close — dropped because prose duplicating executable behavior is a second, unchecked surface that drifts the moment someone edits a test and not the doc.

## Scenario Sequences

Each scenario type (backend, integration, frontend, security, load, infrastructure) runs a TDD cycle: a `red-* → /test-review → commit → /refactor → commit` work unit, then a `green-* → /test-coverage → commit → /refactor → commit` work unit, one scenario at a time. `/refactor` always lands in its own commit, separate from the behavior commit (see Atomic Work Units below and the Commit Discipline section of `.claude/guidelines/tdd-rules.md`). The exact per-phase step list for each scenario type, the `adapters-discovery` gate, and the bug-task discovery-first sequence live in **`.claude/guidelines/workflow-detail.md`** — read it before executing scenario or task work.

## Progress Tracking

Each story has a progress file at `ProductSpecification/stories/NN-story-name/progress.md`; each task at `ProductSpecification/tasks/{N}-{type}-{slug}/progress.md`. It is the single source of truth for **state** — which work unit runs next.

Status markers:

- `[x]` — done
- `[~]` — in-progress (current step)
- `[ ]` — pending
- `[S]` — skipped

The next work unit is the first `[~]` or `[ ]` entry. After a work unit completes, mark it `[x]`, advance the next to `[~]`, and commit progress.md with the work. Reading and updating mechanics are in `.claude/guidelines/workflow-detail.md`; deriving a `progress.md` from the spec is in `.claude/templates/workflow/bootstrapping.md`.

Story sections are **tier-major** — they mirror the tier-first delivery order above; Tier 3 is recorded in `tests/tier3/` and never enters `progress.md`. The ladder is in `.claude/templates/spec/tier-ladder.md`, the section shape in `.claude/templates/workflow/progress-format.md`. Stories specced before tiering keep the flat, untiered shape permanently.

## Atomic Work Units

A work unit is indivisible: ALL sub-skills in the dispatch sequence must execute to completion before stopping. Within a work unit, never pause between sub-skills to report status or ask for confirmation — **with one sanctioned exception: the NEEDS_CLARIFICATION boundary quiz** (see below). A work unit with a `/refactor` step ends in **two commits**: the behavior commit (primary skill + verification + `progress.md` advance), then a separate refactor commit (`/refactor`'s changes only — skipped if it changed nothing).

**Boundary work units add a third commit and the review passes.** A work unit is a **boundary** when its behavior commit closes the block it belongs to — a story scenario, a task step, a bug task's whole fix, the spec section, the harvest checkbox — i.e. no step of that block is left `[ ]` or `[~]` (the block shapes are in `.claude/templates/workflow/progress-format.md`, "Blocks and boundaries"). Only then do the two fresh-context review passes (`agent-review` + `premortem`) run, in the `/refactor` batch, reading **every commit of the completed block** rather than one behavior commit; their auto-fixed SAFE findings land in a trailing `review-fix:` commit (skipped when none apply). They stay non-gating — verdicts are folded into the report, the commits land regardless (how the boundary is detected, dispatched, and triaged is owned by `/continue`; why the cadence is per block is in `.claude/guidelines/review-passes-detail.md`). A mid-block unit runs `/refactor` and stops at two commits.

**The boundary quiz:** when a review pass tags a finding NEEDS_CLARIFICATION, `/continue` may call `AskUserQuestion` once — in that boundary unit, after the passes finish and before the `review-fix:` commit — to resolve the fix direction. This is the only sanctioned pause for user input inside a work unit, and it never lets the unit stop early. **A quiz is the last resort, not the neutral option:** a review pass that can name the better fix direction must name it and own the decision, and `/continue` demotes an ill-formed clarification to a follow-up rather than asking. The escalation bar is in `.claude/templates/workflow/clarification-escalation-test.md`.

STOP only after the work unit's last commit; NEVER stop after the behavior commit while `/refactor`, a boundary's passes, or the quiz is still pending. The only valid stop points are: (1) after the last commit, (2) on sub-skill failure. If a sub-skill fails, stop immediately and report — but a successful sub-skill must be followed by the next sub-skill in the sequence without interruption.

## Task Workflow

Tasks are standalone work items that don't need the full story lifecycle. Three types:

- **bug** — Something is broken. Discover root cause first, then fix with a targeted TDD cycle.
- **refactoring** — Structural improvement. User-defined steps with standard TDD sub-skills.
- **qa** — Manual checklist (smoke / regression) verified against an external environment. No production code change, no TDD cycle.

Tasks live in `ProductSpecification/tasks/{N}-{type}-{slug}/`. When all checkboxes in a task's `progress.md` are `[x]` (or `[S]`), the task folder is moved to `ProductSpecification/tasks/done/`. Task commits use the `task:` prefix. The discovery-first bug sequence, QA session lifecycle, and scoped-steps rules are in `.claude/guidelines/workflow-detail.md`.

**Don't offer to file a task as a substitute for action.** When analysis surfaces a genuine, concrete, fixable defect, either fix it directly, or — if it is outside the current work unit / TDD phase — state that plainly and stop. Do NOT end with "want me to file a task / capture this?": the user reads a deferral offer on a real finding as dodging the work. Let the user ask for a task if they want one.

## Resuming Across Conversations

`progress.md` captures **state**; it does not capture the *why* (predictions that missed, decisions reached in discussion, surprises, quirks a future scenario will hit). That *why* is preserved in **journey summaries** — written only by `/handoff`, read by `/continue` on resume. The triggers for writing a summary, the append-only/idempotent rules, and carryover promotion are detailed in `.claude/guidelines/workflow-detail.md` and `.claude/templates/workflow/summary-format.md`.
