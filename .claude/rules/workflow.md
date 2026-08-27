# Development Workflow

## Source Control

This project does **not** use pull requests or merge requests — commits land directly on the working branch. Never offer to open a PR/MR or invoke a platform's PR/MR CLI, and never reference "the PR description" as a place for context. Commit messages are the only review surface; put the *why* there.

## Lifecycle

Every story follows: **interview → spec → backend scenarios → integration scenarios → frontend scenarios → security scenarios → load scenarios → infrastructure scenarios**.

Those six scenario types are the **categories**, not the delivery order. In a tier-major story, delivery runs **tier-first**: all of Tier 1 in that category order, then the `harvest` boundary, then all of Tier 2 in the same order. The boundary is the story's **shippable milestone** — when every Tier 1 scenario is done the feature works for its primary user, which is what all-left-`✅` phase cells mean; Tier 2 hardens what already works. Why tier outranks category is in `.claude/guidelines/workflow-detail.md` ("Why Delivery Is Ordered by Tier").

**High-level progress** is tracked in `ProductSpecification/stories.md` — three tables: **In Progress**, **Backlog**, and **Done**. Phase columns (Spec, Backend, Integration, Frontend, Security, Load, Infra) per story. The `/continue` skill updates it after each work unit commit. Phase values: ✅ done, 🔧 in progress, — not started, · no story folder yet. When **every checkbox in the story's `progress.md` is `[x]` or `[S]`** — not merely when Tests/% read full, which ignore non-scenario checkboxes like `harvest` — move its row from the **In Progress** table to the **Done** table **and, in the same commit, move its folder** `ProductSpecification/stories/NN-story-name/` → `ProductSpecification/stories/done/NN-story-name/`, so `ls stories/` keeps telling you what is in flight (see `.claude/templates/workflow/stories-md-format.md`). The archived folder is still read — its decisions and interview are where a closed story's rationale lives — so every lookup resolves both locations.

**A repo adopting this rule backfills once.** The archive fires only on a story's completion commit, so every story already in the **Done** table when the rule lands predates it and keeps its folder under `stories/` — which makes `ls stories/` misreport shipped work as in flight, permanently, in exactly the repos that have the most of it. The one-time sweep that reconciles them is in `.claude/templates/workflow/stories-md-format.md`, "Backfilling an adopting repo"; after it runs, the completion commit keeps the invariant true on its own.

**Backlog** stories have all `·` columns (no folder yet); rows are added by the `/story` skill. When `/continue N` targets a Backlog story, auto-promote it: move the row from **Backlog** to **In Progress** in `ProductSpecification/stories.md` before starting work.

Spec phase: `/interview` → story spec (dispatched by `/continue` via its internal template, not the `/story` skill) → `/mockups` → `/api-spec` → `/test-spec` (one at a time, review each before proceeding). The interview may capture technical constraints needed to understand feasibility, but the generated main story spec uses domain language exclusively. Implementation choices, architecture, technology, and integration mechanics belong in the story's Notes file. When a technical limitation changes externally observable behavior, state that behavior in domain terms in the main spec and keep the mechanism in Notes.

**Hazard cadence has two distinct gates.** Scan the story's complete drafted scenario set against the hazard catalogue exactly once, in `/test-spec`, before consolidation and tiering; story-spec generation never runs that whole-set scan. Separately, every `/design-preview` scans that scenario's drafted design while design options are prepared. Keep the per-design scan: it validates implementation choices and does not repeat the story-wide scenario-set pass.

## Where the Current State Lives

**The acceptance suite is the current-state documentation of what the product does.** It is grouped by functionality rather than by story, each test carries its Gherkin scenario in its scenario description (a display annotation, a subtest name, or a docstring — per the tech binding), it is black-box (HTTP and browser only, so it describes externally observable behavior), and it is self-correcting: when a later increment changes a behavior, the earlier test is rewritten or the build goes red — an outdated behavior makes the build red, never a document quietly stale. So a reader asking *what does this area do today* reads the acceptance tests **of the area it is about to touch** — test class names, scenario descriptions, Statements — and never sweeps story folders to reconstruct the present.

**Read only the enabled tests.** A test still carrying its disable/skip marker is a pending increment — a `red-acceptance` awaiting its green, or an unharvested Tier 2 scenario — not shipped behavior. It is the one part of the suite that *can* go quietly stale, because a disabled test never makes the build red. And in a repo with no acceptance suite yet, say so explicitly and fall back to the story folders — never degrade to a silent sweep.

**Suite silence about an area is not evidence of absence.** An area can be shipped and still leave no black-box trace: behavior asserted only at the usecase or adapter level, or a bug fix that legitimately took the single-layer path. So no acceptance test for the area you are about to touch means *unknown*, not *unbuilt* — and the next read is the **production code of that area** (the usecase that owns the operation, then its adapters — or, for a UI-only behavior, the frontend source that renders it), never a sweep of story folders. Say what you found and where, so the gap stays visible instead of being silently filled in.

**A story folder is a delta plus its rationale**, not a description of the present. It holds one increment: the story spec, `interview.md`, `mockups/`, `endpoints.md`, `decisions/*-decision.md`, and `tests/` (including `tier3/`). When the same functionality is extended by a later story, no single folder answers "what does this do now" — the later delta supersedes the earlier one and neither says so. Read a story folder for a **named** precedent (the decision behind a specific rule, the interview behind a specific constraint), never as a sweep. The one artifact in there that is *not* frozen at story close is `mockups/`, which later work backports into — see the table below.

**Resolving a story folder: `stories/` first, then `stories/done/`.** A story is archived the moment it completes, but the behavior it shipped stays live and its rationale stays the answer to "why is this rule *that* rule". So every reader that resolves one story — `/continue`, `red-agent`, `/handoff`, `/mockups`, `/align-design`, `/design-review`, `/screenshot`, and the spec skills and templates that open an earlier story — checks `ProductSpecification/stories/NN-story-name/` and then `ProductSpecification/stories/done/NN-story-name/`, and treats a hit in either as the story. **Not-found means both came back empty** — never one; anything that fires on absence (most sharply `/continue`'s bootstrap, which would re-create a shipped story's folder and re-run its spec phase) must check both before it fires. Writing is the one asymmetry: a story is archived only once complete, so its own spec phase always writes under `stories/`, while work that reaches back into a closed story — backporting a mockup, appending a journey summary about it — writes where that story resolved. A review finding that reopens a story is not that case: the reopen moves the folder back out of `done/` first, so its writes land under `stories/` (`.claude/skills/continue/SKILL.md`, "Triage & Auto-Fix"). `/retier` is the single deliberate exclusion: it classifies folders under `stories/` and must not descend into `stories/done/` or treat `done/` itself as a story folder.

What the suite genuinely cannot hold, each with an existing home:

| Not in the suite | Why | Where it lives |
|---|---|---|
| Deliberate non-goals ("we do not do X") | No test asserts the absence of something unbuilt | The story spec — correctly historical, a decision of that moment |
| Rationale (why a limit is *that* number) | A test states the rule, not the argument for it | `decisions/*-decision.md` and `interview.md` in the story folder |
| Tier 3 scenarios | Recorded and never built, so absent from the code by definition | `tests/tier3/` |
| The UI's visual design (layout, spacing, color) | A browser test asserts behavior and content, never pixels | `ProductSpecification/ui/ui-conventions.md`, the cross-story design authority, plus the owning story's `mockups/` — read as the current design reference, kept current by backporting |

**Asking *whether* a non-goal or a rationale exists is not the banned sweep.** The first two rows above — deliberate non-goals and rationale — are also the two lookups that cannot start from a name: a reader asking "did we already decide *not* to do this" or "is there an argument on record for this limit" has no story to name until it finds one. So a **keyword-scoped search across `stories/**` including `done/`** — grepping the term, opening only what matches — is permitted and expected. What stays banned is the sweep: opening every story folder and reading it whole to reconstruct present behavior, which the suite already answers. Do not resolve this with an index of non-goals: an index is the same unchecked prose surface rejected below, and it goes wrong the first time a story lands without updating it.

**Rejected, on purpose:** a consolidated `ProductSpecification/features/{slug}.md` layer, folded in by a `feature-doc` work unit at story close — dropped because prose duplicating executable behavior is a second, unchecked surface that drifts the moment someone edits a test and not the doc.

## Scenario Sequences

Backend, integration, security, load, and infrastructure scenarios use three
human-reviewed stages: acceptance RED beside contract design; concurrent complete
RED-to-GREEN use-case and adapter lanes; then acceptance GREEN beside independent
review. Frontend scenarios also use three stages: Selenium RED beside interface
design; concurrent complete frontend-logic, API-client, and design-alignment lanes;
then Selenium GREEN beside independent review. `/refactor` lands separately inside
every lane that requires it. Exact mechanics and legacy in-flight behavior live in
**`.claude/guidelines/workflow-detail.md`**.

## Progress Tracking

Each story has a progress file at `ProductSpecification/stories/NN-story-name/progress.md` — or `ProductSpecification/stories/done/NN-story-name/progress.md` once the story is archived; each task at `ProductSpecification/tasks/{N}-{type}-{slug}/progress.md`, likewise under `tasks/done/` once archived. It is the single source of truth for **state** — which work unit runs next.

**Progress files are plans, not journals.** They contain headings, status checkboxes,
and only compact tokens required to dispatch or audit the plan; each checkbox is one
physical line and at most 200 characters. Never append work
summaries, test evidence, review verdicts, implementation discoveries, approval
history, lane manifests, or multi-line commentary to a checkbox. `/continue` writes
one bounded record per invocation under `worklog/` beside the progress file, following
`.claude/templates/workflow/worklog-format.md`. Journey summaries remain the separate
home for noteworthy cross-conversation context and are still written only by
`/handoff`.

Status markers:

- `[x]` — done
- `[~]` — in-progress (current step)
- `[ ]` — pending
- `[S]` — skipped

The next work unit is the first `[~]` or `[ ]` entry. After a work unit completes, mark it `[x]`, advance the next to `[~]`, and commit progress.md with the work. Reading and updating mechanics are in `.claude/guidelines/workflow-detail.md`; deriving a `progress.md` from the spec is in `.claude/templates/workflow/bootstrapping.md`.

Story sections are **tier-major** — they mirror the tier-first delivery order above; Tier 3 is recorded in `tests/tier3/` and never enters `progress.md`. The ladder is in `.claude/templates/spec/tier-ladder.md`, the section shape in `.claude/templates/workflow/progress-format.md`. Stories specced before tiering keep the flat, untiered shape permanently.

## Atomic Work Units

A work unit is indivisible: ALL sub-skills in the dispatch sequence must execute to completion before stopping. Its only sanctioned pauses are the task design's joined approval and the NEEDS_CLARIFICATION review quiz. A work unit with a `/refactor` step ends in **two commits**: the behavior commit (primary skill + verification + `progress.md` advance), then a separate refactor commit (`/refactor`'s changes only — skipped if it changed nothing). `/refactor` only runs when a red or green agent ran before it in the same work unit — no red/green agent, no `/refactor`.

**Stories review at block boundaries; tasks review once at completion.** The two fresh-context passes (`agent-review` + `premortem`) run concurrently and remain non-gating. Story mechanics keep the block boundary defined in `progress-format.md`; task steps never dispatch reviews, and the terminal batch reads the whole task before archive. Verdicts land in the active work log, with SAFE fixes in `review-fix:` and records without fixes in `worklog:` (mechanics: `/continue`; rationale: `.claude/guidelines/review-passes-detail.md`).

The staged backend and frontend sequences have one explicit range exception: their
Stage 3 review runs concurrently with acceptance GREEN and reads the immutable Stage
1+2 range. Stage 1 already reviewed the acceptance-test content; Stage 3 suite
execution guards the remove-marker-only delta. That batch is consumed once and
scenario closure does not dispatch a duplicate review.

**Boundary review is depth-limited to one generation.** A block created from a boundary review's `NEEDS_CYCLE` finding carries the durable `<!-- review-origin: boundary -->` marker defined by `progress-format.md`. It still runs its complete TDD work unit and `/refactor`, but its closing boundary skips `agent-review` and `premortem`; findings from review must not recursively commission another review generation. The original boundary's required review is unchanged, and its trailing `review-fix:` or `worklog:` commit is terminal — validating it never starts another review batch.

**The boundary quiz:** when a review pass tags a finding NEEDS_CLARIFICATION, `/continue` may call `AskUserQuestion` once — in that boundary unit, after the passes finish and before the trailing record commit — to resolve the fix direction. This is the only sanctioned pause for user input inside a work unit, and it never lets the unit stop early. **A quiz is the last resort, not the neutral option:** a review pass that can name the better fix direction must name it and own the decision, and `/continue` demotes an ill-formed clarification to a follow-up rather than asking. The escalation bar is in `.claude/templates/workflow/clarification-escalation-test.md`.

STOP only after the work unit's last commit; NEVER stop after the behavior commit while `/refactor`, a boundary's passes, or the quiz is still pending. The only valid stop points are: (1) after the last commit, (2) on sub-skill failure. If a sub-skill fails, stop immediately and report — but a successful sub-skill must be followed by the next sub-skill in the sequence without interruption.

## Task Workflow

Tasks are standalone work items that don't need the full story lifecycle. Six types, split by execution discipline:

- **behavior-change** — Intentionally changes observable behavior. Design first, then implement through a targeted TDD cycle.
- **bugfix** — Corrects behavior that is broken. Confirm the root cause first, then fix it through a targeted TDD cycle.
- **refactor** — Restructures executable code without changing behavior. No TDD cycle; existing tests verify preservation.
- **infra** — Changes infrastructure through repository-managed infrastructure-as-code. No TDD cycle; run relevant validation.
- **general** — Bounded work that fits no specialized type. No TDD cycle; execute direct work units with affected checks.
- **qa** — Manual checklist verified against an external environment. No production code change and no TDD cycle.

Only `behavior-change` and `bugfix` tasks may contain RED-to-GREEN work units. If a no-TDD task reveals a required behavior change, reclassify it or split out a TDD task before implementing that change.

Every task runs one `design` work unit before implementation. It drafts the design and scans task-level hazards concurrently from the same input, reconciles them, then asks for one approval. `steps discovery` remains the separate plan-expansion step for TDD tasks; refactors keep `refactor (steps discovery)`.

Tasks live in `ProductSpecification/tasks/{N}-{type}-{slug}/`. When all checkboxes are complete, run the task's one terminal review batch, then move the folder to `ProductSpecification/tasks/done/`. Task commits use the `task:` prefix. The type-specific sequences, QA session lifecycle, and scoped-steps rules are in `.claude/guidelines/workflow-detail.md`.

**Don't offer to file a task as a substitute for action.** When analysis surfaces a genuine, concrete, fixable defect, either fix it directly, or — if it is outside the current work unit / TDD phase — state that plainly and stop. Do NOT end with "want me to file a task / capture this?": the user reads a deferral offer on a real finding as dodging the work. Let the user ask for a task if they want one.

## Resuming Across Conversations

`progress.md` captures **state**; it does not capture the *why* (predictions that missed, decisions reached in discussion, surprises, quirks a future scenario will hit). That *why* is preserved in **journey summaries** — written only by `/handoff`, read by `/continue` on resume. The triggers for writing a summary, the append-only/idempotent rules, and carryover promotion are detailed in `.claude/guidelines/workflow-detail.md` and `.claude/templates/workflow/summary-format.md`.
