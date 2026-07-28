# Development Workflow

## Source Control

This project does **not** use pull requests or merge requests — commits land directly on the working branch. Never offer to open a PR/MR or invoke a platform's PR/MR CLI, and never reference "the PR description" as a place for context. Commit messages are the only review surface; put the *why* there.

## Lifecycle

Every story follows: **interview → spec → backend scenarios → integration scenarios → frontend scenarios → security scenarios → load scenarios → infrastructure scenarios**.

Those six scenario types are the **categories**, not the delivery order. In a tier-major story, delivery runs **tier-first**: all of Tier 1 in that category order, then the `harvest` boundary, then all of Tier 2 in the same order. The boundary is the story's **shippable milestone** — when every Tier 1 scenario is done the feature works for its primary user, which is what all-left-`✅` phase cells mean; Tier 2 hardens what already works. Why tier outranks category is in `.claude/guidelines/workflow-detail.md` ("Why Delivery Is Ordered by Tier").

**High-level progress** is tracked in `ProductSpecification/stories.md` — three tables: **In Progress**, **Backlog**, and **Done**. Phase columns (Spec, Backend, Integration, Frontend, Security, Load, Infra) per story. The `/continue` skill updates it after each work unit commit. Phase values: ✅ done, 🔧 in progress, — not started, · no story folder yet. When **every checkbox in the story's `progress.md` is `[x]` or `[S]`** — not merely when Tests/% read full, which ignore non-scenario checkboxes like `harvest` — move its row from the **In Progress** table to the **Done** table (see `.claude/templates/workflow/stories-md-format.md`).

**Backlog** stories have all `·` columns (no folder yet); rows are added by the `/story` skill. When `/continue N` targets a Backlog story, auto-promote it: move the row from **Backlog** to **In Progress** in `ProductSpecification/stories.md` before starting work.

Spec phase: `/interview` → story spec (dispatched by `/continue` via its internal template, not the `/story` skill) → `/mockups` → `/api-spec` → `/test-spec` (one at a time, review each before proceeding).

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

A work unit is indivisible: ALL sub-skills in the dispatch sequence must execute to completion before stopping. Within a work unit, never pause between sub-skills to report status or ask for confirmation — **with one sanctioned exception: the NEEDS_CLARIFICATION boundary quiz** (see below). A work unit with a `/refactor` step ends in **up to three commits**: the behavior commit (primary skill + verification + `progress.md` advance), then a separate refactor commit (`/refactor`'s changes only — skipped if it changed nothing), then a trailing `review-fix:` commit (the review passes' auto-fixed SAFE findings — skipped when none apply). The two fresh-context review passes (`agent-review` + `premortem`) run in the `/refactor` batch, before the refactor commit, and are non-gating — their verdicts are folded into the report, but the commits land regardless (how they are dispatched and triaged is owned by `/continue`). **The boundary quiz:** when a review pass tags a finding NEEDS_CLARIFICATION, `/continue` may call `AskUserQuestion` once — at the work-unit boundary, after the passes finish and before the `review-fix:` commit — to resolve the fix direction. This is the only sanctioned pause for user input inside a work unit, and it never lets the unit stop early. **A quiz is the last resort, not the neutral option:** a review pass that can name the better fix direction must name it and own the decision, and `/continue` demotes an ill-formed clarification to a follow-up rather than asking. The escalation bar is in `.claude/templates/workflow/clarification-escalation-test.md`; the *why* is in `.claude/guidelines/review-passes-detail.md`. STOP only after the work unit's last commit; NEVER stop after the behavior commit while `/refactor`, the passes, or the quiz is still pending. The only valid stop points are: (1) after the last commit, (2) on sub-skill failure. If a sub-skill fails, stop immediately and report — but a successful sub-skill must be followed by the next sub-skill in the sequence without interruption.

## Task Workflow

Tasks are standalone work items that don't need the full story lifecycle. Three types:

- **bug** — Something is broken. Discover root cause first, then fix with a targeted TDD cycle.
- **refactoring** — Structural improvement. User-defined steps with standard TDD sub-skills.
- **qa** — Manual checklist (smoke / regression) verified against an external environment. No production code change, no TDD cycle.

Tasks live in `ProductSpecification/tasks/{N}-{type}-{slug}/`. When all checkboxes in a task's `progress.md` are `[x]` (or `[S]`), the task folder is moved to `ProductSpecification/tasks/done/`. Task commits use the `task:` prefix. The discovery-first bug sequence, QA session lifecycle, and scoped-steps rules are in `.claude/guidelines/workflow-detail.md`.

**Don't offer to file a task as a substitute for action.** When analysis surfaces a genuine, concrete, fixable defect, either fix it directly, or — if it is outside the current work unit / TDD phase — state that plainly and stop. Do NOT end with "want me to file a task / capture this?": the user reads a deferral offer on a real finding as dodging the work. Let the user ask for a task if they want one.

## Resuming Across Conversations

`progress.md` captures **state**; it does not capture the *why* (predictions that missed, decisions reached in discussion, surprises, quirks a future scenario will hit). That *why* is preserved in **journey summaries** — written only by `/handoff`, read by `/continue` on resume. The triggers for writing a summary, the append-only/idempotent rules, and carryover promotion are detailed in `.claude/guidelines/workflow-detail.md` and `.claude/templates/workflow/summary-format.md`.
