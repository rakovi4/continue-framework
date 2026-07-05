# Development Workflow

## Source Control

This project does **not** use pull requests or merge requests — commits land directly on the working branch. Never offer to open a PR/MR or invoke a platform's PR/MR CLI, and never reference "the PR description" as a place for context. Commit messages are the only review surface; put the *why* there.

## Lifecycle

Every story follows: **interview → spec → backend scenarios → integration scenarios → frontend scenarios → security scenarios → load scenarios → infrastructure scenarios**.

**High-level progress** is tracked in `ProductSpecification/stories.md` — three tables: **In Progress**, **Backlog**, and **Done**. Phase columns (Spec, Backend, Integration, Frontend, Security, Load, Infra) per story. The `/continue` skill updates it after each work unit commit. Phase values: ✅ done, 🔧 in progress, — not started, · no story folder yet. When a story reaches 100% (all scenarios done), move its row from the **In Progress** table to the **Done** table.

**Backlog** stories have all `·` columns (no folder yet). When `/continue N` targets a Backlog story, auto-promote it: move the row from **Backlog** to **In Progress** in `ProductSpecification/stories.md` before starting work.

Spec phase: `/interview` → `/story` → `/mockups` → `/api-spec` → `/test-spec` (one at a time, review each before proceeding).

## Scenario Sequences

Each scenario type (backend, integration, frontend, security, load, infrastructure) runs a TDD cycle: a `red-* → /test-review → commit → /refactor → commit` work unit, then a `green-* → /test-coverage → commit → /refactor → commit` work unit, one scenario at a time. `/refactor` always lands in its own commit, separate from the behavior commit (see Atomic Work Units below and the Commit Discipline section of `.claude/guidelines/tdd-rules.md`). The exact per-phase step list for each scenario type, the `adapters-discovery` gate, and the bug-task discovery-first sequence live in **`.claude/guidelines/workflow-detail.md`** — read it before executing scenario or task work.

## Progress Tracking

Each story has a progress file at `ProductSpecification/stories/NN-story-name/progress.md`; each task at `ProductSpecification/tasks/{N}-{type}-{slug}/progress.md`. It is the single source of truth for **state** — which work unit runs next.

Status markers:

- `[x]` — done
- `[~]` — in-progress (current step)
- `[ ]` — pending
- `[S]` — skipped

The next work unit is the first `[~]` or `[ ]` entry. After a work unit completes, mark it `[x]`, advance the next to `[~]`, and commit progress.md with the work. Reading, updating, and bootstrapping-from-spec mechanics are in `.claude/guidelines/workflow-detail.md`.

## Atomic Work Units

A work unit is indivisible: ALL sub-skills in the dispatch sequence must execute to completion before stopping. Within a work unit, never pause between sub-skills to report status or ask for confirmation. A work unit with a `/refactor` step ends in **two commits**: the behavior commit (primary skill + verification + `progress.md` advance), then a separate refactor commit (`/refactor`'s changes only — skipped if it changed nothing). The two fresh-context review passes (`agent-review` + `premortem`) run **just before** the work unit's final commit, in the `/refactor` batch, and are non-gating — their verdicts are folded into the report, but the commit lands regardless (how they are dispatched is owned by `/continue`). STOP only after the work unit's final commit; NEVER stop after the behavior commit while `/refactor` is still pending. The only valid stop points are: (1) after the final commit, (2) on sub-skill failure. If a sub-skill fails, stop immediately and report — but a successful sub-skill must be followed by the next sub-skill in the sequence without interruption.

## Task Workflow

Tasks are standalone work items that don't need the full story lifecycle. Three types:

- **bug** — Something is broken. Discover root cause first, then fix with a targeted TDD cycle.
- **refactoring** — Structural improvement. User-defined steps with standard TDD sub-skills.
- **qa** — Manual checklist (smoke / regression) verified against an external environment. No production code change, no TDD cycle.

Tasks live in `ProductSpecification/tasks/{N}-{type}-{slug}/`. When all checkboxes in a task's `progress.md` are `[x]` (or `[S]`), the task folder is moved to `ProductSpecification/tasks/done/`. Task commits use the `task:` prefix. The discovery-first bug sequence, QA session lifecycle, and scoped-steps rules are in `.claude/guidelines/workflow-detail.md`.

**Don't offer to file a task as a substitute for action.** When analysis surfaces a genuine, concrete, fixable defect, either fix it directly, or — if it is outside the current work unit / TDD phase — state that plainly and stop. Do NOT end with "want me to file a task / capture this?": the user reads a deferral offer on a real finding as dodging the work. Let the user ask for a task if they want one.

## Resuming Across Conversations

`progress.md` captures **state**; it does not capture the *why* (predictions that missed, decisions reached in discussion, surprises, quirks a future scenario will hit). That *why* is preserved in **journey summaries** — written only by `/handoff`, read by `/continue` on resume. The triggers for writing a summary, the append-only/idempotent rules, and carryover promotion are detailed in `.claude/guidelines/workflow-detail.md` and `.claude/templates/workflow/summary-format.md`.
