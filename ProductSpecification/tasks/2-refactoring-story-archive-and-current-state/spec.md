# Task 2: Archive done stories; the acceptance suite is the current state

Type: refactoring

Throwaway task: delete this folder after completion (do not move to `tasks/done/`).

## Problem

Two gaps, both rooted in the framework treating a story folder as something that
never closes.

**1. A completed story is never archived.** `/continue` moves a finished *task*
folder to `ProductSpecification/tasks/done/` (SKILL.md step 11, gated on the
staged `progress.md`), but a finished *story* only gets its row moved from the
**In Progress** table to the **Done** table in `ProductSpecification/stories.md`
(`.claude/templates/workflow/stories-md-format.md`, "Story completion"). The
folder stays alongside the active ones forever, so `ls stories/` stops telling
you what is in flight.

**2. Nothing declares where the current state of a functionality lives, so four
readers reconstruct it by scanning every story folder.** A story folder is a
*delta*: it describes one increment. When the same functionality is extended by a
later story ("save document: pdf, doc, docx" → "…also odt, limit raised to
25 MB"), no story folder answers "what does this do today". The framework's
answer today is a brute sweep:

| Reader | What it scans |
|---|---|
| `.claude/skills/interview/SKILL.md:28` | **ALL** `stories/*/interview.md` |
| `.claude/templates/spec/story-spec-generation.md:24` | all `stories/*/NN_StoryName.md` |
| `.claude/skills/api-spec/SKILL.md:34,35` | all `stories/*/mockups/`, all `stories/*/interview.md` |
| `.claude/skills/test-spec/SKILL.md:24` | the story folders |

The cost grows with every story, and the result is approximate by construction:
a later delta silently supersedes an earlier one and neither document says so.
The reader has to diff two spec folders in their head to get an answer that is
already written down, exactly and executably, somewhere else.

## Solution

**The acceptance suite is the current-state documentation. Story folders are
deltas and their rationale.** Write that down as a rule, then make the readers
follow it.

The suite already has every property a consolidated document would be trying to
fake:

- **Grouped by functionality, not by story** — `acceptance/…/tests/backend/createTask/CreateTaskAcceptanceTest.java`
  (`.claude/tech/java-spring/templates/acceptance/test-class.md`).
- **Readable as specification** — every test carries a `@Description` with its
  Gherkin scenario, and `/test-review` has already forced strict assertions.
- **Black-box** — HTTP and Selenium only, so it describes externally observable
  behavior, which is what "what does this feature do" means.
- **Self-correcting** — when a later story raises the limit from 10 MB to 25 MB,
  the earlier story's test is rewritten or the build goes red. A prose document
  would go stale silently, and nothing would notice.

So the four sweeps above stop reconstructing the present from a pile of deltas
and read the suite for the area they are about to touch. Story folders are still
read — for a specific precedent, a decision record, an interview — but pointedly,
not swept.

**Three things the suite genuinely cannot hold**, and none of them needs a
consolidated document:

1. **Deliberate non-goals** ("we do not version documents") — no test asserts the
   absence of something unbuilt. This lives in the story spec, where it is a
   decision of that moment, correctly historical.
2. **Rationale** — why the limit is 25 MB. Lives in `decisions/*-decision.md` and
   `interview.md` inside the story folder. Also correctly historical; it needs to
   stay *findable*, not to be merged.
3. **Tier 3** — recorded and never built, in `tests/tier3/`. Absent from the code
   by definition.

Since (1)–(3) live in story folders and story folders now move to
`stories/done/`, every lookup that reaches for a decision record, an interview or
a past spec must span both locations, or the rationale disappears from view at
exactly the moment the story closes.

**Archive on completion.** The trigger is the completion fact already recorded:
the behavior commit that moves a story's row to the **Done** table in
`stories.md` also moves `ProductSpecification/stories/NN-story-name/` →
`ProductSpecification/stories/done/NN-story-name/`, under the same
staged-`progress.md` gate the task move uses. The reopen path in `/continue`'s
Triage section ("flipped the item to `done/` or the Done table") moves it back
out in the `review-fix:` commit.

**Rejected, on purpose: a `ProductSpecification/features/{slug}.md` layer** with
a `feature-doc` work unit folding each story's delta into it at story close. It
was the first shape of this task. It is prose duplicating executable behavior —
a second surface for the same facts, unchecked by any build, drifting the moment
someone edits a test and not the doc. Record the rejection in
`.claude/rules/workflow.md` so the next person who notices gap 2 does not
reinvent it.

**Backfill is a task, not a framework mechanism.** A project adopting the
framework after years of development carries completed stories still sitting in
`stories/` and functionality whose behavior is under-tested. Neither gets a
migration skill here: the adopting repo files a refactoring task with one step
per area and runs it through `/continue`. The framework's job is to make the
steady state correct.

Out of scope: any consolidated-documentation layer; a backfill or migration
skill; changing how acceptance tests are organized; changing how tasks archive;
any change to the six test categories or the tier ladder.

## Key Files

- `.claude/rules/workflow.md` — the current-state rule, the recorded rejection,
  the story folder path
- `.claude/skills/continue/SKILL.md` — step 11 (`done/` move), Resolving the
  Argument, Triage reopen clause, Pre-Commit Checklist item 7
- `.claude/templates/workflow/stories-md-format.md` — "Story completion"
- `.claude/skills/interview/SKILL.md`, `.claude/skills/api-spec/SKILL.md`,
  `.claude/skills/test-spec/SKILL.md`,
  `.claude/templates/spec/story-spec-generation.md` — the four sweeps
- `.claude/skills/retier/SKILL.md` — must exclude `stories/done/`
- `.claude/skills/{handoff,screenshot,mockups,align-design,design-review}/SKILL.md`,
  `.claude/agents/red-agent.md`, `.claude/guidelines/workflow-detail.md`,
  `.claude/templates/{ui/mockup-generation-rules.md,spec/adr-format.md,spec/interview-format.md,spec/test-spec-format.md}` —
  story-folder path resolution
