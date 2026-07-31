# Task 2: Archive done stories and add feature docs

Type: refactoring

Throwaway task: delete this folder after completion (do not move to `tasks/done/`).

## Problem

Two related gaps, both rooted in the framework treating a story as a folder that
never closes.

**1. A completed story is never archived.** `/continue` moves a finished *task*
folder to `ProductSpecification/tasks/done/` (SKILL.md step 11, gated on the
staged `progress.md`), but a finished *story* only gets its row moved from the
**In Progress** table to the **Done** table in `ProductSpecification/stories.md`
(`.claude/templates/workflow/stories-md-format.md`, "Story completion"). The
folder `ProductSpecification/stories/NN-story-name/` stays alongside the active
ones forever, so `ls stories/` stops telling you what is in flight.

**2. A story is a delta, and nothing folds the deltas together.** Story folders
hold `interview.md`, `NN_StoryName.md`, `mockups/`, `endpoints.md`, `tests/` —
all describing *one increment*. When the same functionality is extended by a
later story (e.g. "save document: pdf, doc, docx" then "…also odt, rtf, size
limit"), the current state of that functionality exists nowhere: story 3
describes what it added, story 7 describes what it added, and a reader must
diff two spec folders in their head to answer "what does this feature do
today?". `/interview` re-derives that context by reading sibling story folders,
which is exactly the re-discovery the framework tries to avoid elsewhere.

The two gaps share one fix boundary: **story completion**. That is the moment
the delta is final and can be folded into a consolidated document, and the
moment the folder can be archived.

## Solution

Introduce a consolidated documentation layer and close the story lifecycle.

**Feature docs.** `ProductSpecification/features/{feature-slug}.md` is the
living, current-state description of one functional area: what it does today,
supported inputs and limits, business rules, endpoints, UI entry points, and a
chronological *Delivered by* list of the stories that shaped it. Story folders
stay what they are — deltas — and gain a `Feature: {slug}` declaration. A story
either extends an existing feature doc or creates a new one.

**A `feature-doc` work unit closes every story.** A new final checkbox in a
story's `progress.md`, dispatched inline by `/continue`: read the story spec,
its test files and the existing feature doc, fold the delta into current-state
prose, append the Delivered-by row, commit. It is a non-scenario checkbox — like
`harvest`, it carries no `### ` heading and is counted in neither Tests nor %.
Placing it last means the doc is written while the delta is still fresh, and it
is the checkbox that keeps a story open until the fold happens.

**Archive on completion.** The trigger is the completion fact the framework
already records: the moment a story's row moves to the **Done** table in
`stories.md`, the same behavior commit moves
`ProductSpecification/stories/NN-story-name/` →
`ProductSpecification/stories/done/NN-story-name/`. Row and folder move
together, under the same staged-`progress.md` gate the task move already uses
(verify from `git show :`, never from recollection of the edit). The mid-cycle
reopen path in `/continue`'s Triage section, which already handles "flipped the
item to `done/` or the Done table", moves the folder back out in the
`review-fix:` commit. Nothing else about completion changes.

Because the archive move relocates story folders, every consumer that resolves
`ProductSpecification/stories/NN-*/` — `/continue`'s argument resolution, and
the glob readers in `/interview`, `/api-spec`, `/screenshot`, `/handoff`,
`/retier`, `/mockups`, `/align-design`, `/design-review`, `/test-spec`,
`red-agent` and the spec templates — must look in `stories/done/` too, or
explicitly exclude it (`/retier`, which must not classify archived stories).

**Backfill is a task, not a framework mechanism.** A project adopting the
framework after years of development carries three kinds of debt: completed
stories still sitting in `stories/`, stories with no feature doc, and
functionality that never had a story at all. None of it gets a dedicated skill
or a one-shot migration here — it is ordinary work with an ordinary
`progress.md`: the adopting repo creates a refactoring task (`/task refactoring
"backfill feature docs"`) with one step per feature area and runs it through
`/continue`. The framework's job is to make the steady state correct; catching a
legacy repo up to that steady state is that repo's task. Stories specced before
this change carry no `feature-doc` checkbox and close without one — that is the
same backfill debt, handled the same way.

Out of scope: a backfill/migration skill of any shape; retroactively writing
feature docs in this repo (it has no stories); changing how tasks archive; any
change to the six test categories or the tier ladder.

## Key Files

- `.claude/skills/continue/SKILL.md` — step 11 (`done/` move gate), Work Unit
  Dispatch (new `feature-doc` row), Resolving the Argument, Triage reopen
  clause, Pre-Commit Checklist item 7
- `.claude/rules/workflow.md` — Lifecycle, Progress Tracking (story folder
  path), story-completion sentence; stories-as-deltas + `features/` layer
- `.claude/templates/workflow/stories-md-format.md` — "Story completion"
- `.claude/templates/workflow/progress-format.md` — `feature-doc` checkbox,
  Tests/% exclusion, "Blocks and boundaries"
- `.claude/templates/workflow/bootstrapping.md` — emit `feature-doc` last
- `.claude/templates/workflow/feature-doc-format.md` — **new**, the feature
  document shape
- `.claude/templates/spec/story-spec-generation.md`, `interview-format.md` —
  `Feature: {slug}` declaration and reading the feature doc as input
- `.claude/skills/interview/SKILL.md`, `story/SKILL.md` — feature identity
- `.claude/skills/retier/SKILL.md` — exclude `stories/done/`
- `.claude/skills/{handoff,screenshot,api-spec,mockups,align-design,design-review,test-spec}/SKILL.md`,
  `.claude/agents/red-agent.md`, `.claude/guidelines/workflow-detail.md`,
  `.claude/templates/{ui/mockup-generation-rules.md,spec/adr-format.md,spec/test-spec-format.md}` —
  story-folder path resolution
- `.claude/skills/doc/SKILL.md` — point research docs at `features/` instead of
  duplicating current-state description
- `CLAUDE.md` — document the `features/` layer
