---
name: retier
description: >-
  One-shot per-repo migration that tiers existing stories and re-bootstraps plans
  that can still be reordered. Use after merging the framework tiering change, when
  the user says /retier, or after tier-ladder.md is introduced.
---

# /retier — One-Shot Tiering Migration

A scenario's tier lives in its `Tier:` marker inside the story's `tests/*.md`
(`.claude/templates/spec/tier-ladder.md`). `/retier` writes those markers for stories
drafted before tiering existed **whose implementation has not started** — why that
needs a migration at all, and why a story already under way is left alone, is in
`.claude/guidelines/workflow-detail.md`, "Bootstrapping".

**Run it once, after the merge.** `/framework-sync`'s **Next Steps** routes here when
the merge brings tiering in; the frontmatter `description` above repeats the run-once
instruction for a hand-merge that never invoked that skill. Afterwards `/test-spec`
Phase 5 tiers every new story and nothing calls this skill again.

**Run it inline in the main agent.** It fans out one `tiering-agent` per story, and
those must not nest inside a wrapper agent. It is never a `progress.md` checkbox, so
`/continue` has no dispatch row for it. **Stories only** — a task has no scenario
set and is never tiered.

## Scope by story state

Classify **every** folder under `ProductSpecification/stories/` first, then act.
**Never descend into `ProductSpecification/stories/done/`, and never classify `done/`
itself as a story folder.** This is the one deliberate exception to resolving both
locations (`.claude/rules/workflow.md`, "Resolving a story folder"): everything in the
archive is complete, which is already the **Skip** row below — reaching it by walking the
archive would only re-derive that answer, while treating `done/` as a story would put a
non-story on the classification path at all.
**Test the rows in order; the first match wins** — a Done story's `tests/` exist and
its checkboxes are `[x]`, so it matches the last two rows too, and only row order
keeps it out of them.

| State | Detected by | Action |
|---|---|---|
| Not specced | no `tests/` directory | **Nothing.** `/test-spec` tiers it when it runs. |
| Done | row in the **Done** table of `ProductSpecification/stories.md` | **Skip**, and say so in the report. |
| Already tier-major | `progress.md` has a `## Tier N — ` section | **Nothing** — specced after the merge, or migrated by an earlier run. |
| Convertible | `tests/` exist, no checkbox below the `## Spec` section is `[x]` | Tier the set, then re-bootstrap `progress.md` tier-major. |
| In flight | `tests/` exist, at least one checkbox below `## Spec` is `[x]` | **Nothing.** Left untiered permanently. |

**An existing `extended/` directory is never touched** — on any row, in any branch. It
is never renamed to `tier3/` and never re-tiered: it already behaves like Tier 3 and
its scenarios are already outside the plan.

**Convertible is decided by `[x]`, not by the `%` column.** Reordering a plan in
which nothing has been built strands nothing; one `[x]` and the reorder moves
already-committed work to a new position and churns the audit trail, which is the
reason in-flight plans are frozen at all. The `%` column is the wrong test twice
over: it is derived from `progress.md`, and it counts an all-`[S]` scenario as done,
so a story whose only "progress" is a skip decision would misclassify as in flight.

**A Done story is skipped because nothing reads its markers again.** Its
`progress.md` is complete and `/continue` never re-derives it, so tiering it
produces a diff over settled files and a report no one can act on. If a bugfix task
later reopens the story, the reopened plan is untiered and takes the in-flight
branch below, which loses nothing. Tag one only if the user asks for corpus
uniformity.

## Convertible: tier, then re-bootstrap

1. **Dispatch `tiering-agent`** for the story — its whole test set, any existing
   `tier3/`, and the story spec (`.claude/agents/tiering-agent.md`, "Input"). One
   per story, dispatched concurrently across stories: each writes only inside its
   own folder.
2. **No hazard re-scan.** Never fan out `hazard-scan-agent` here. The scan is
   `/test-spec`'s *authoring* step, and run over an already-drafted set it folds new
   GAPs in as **new scenarios** — that is drafting, not migration, and it grows
   exactly the set the user invoked this skill to order. A pre-tiering set arrives
   token-less and `tiering-agent` tiers it from the scenarios as written. **Never
   invent a token**: it would be indistinguishable downstream from one a route
   actually emitted.

   **No consolidation either**, for the same reason from the other direction. The pass
   that merges scenarios sharing one execution
   (`.claude/templates/spec/consolidation-rules.md`) rewrites scenario bodies and
   retires headings — authoring, not migration — and every `### N.M Title` it retires
   is a string journey summaries, decision records and `plan-integrity-check.md` key
   on. The user invoked this skill to *order* a set, not to redraft it. A **Convertible**
   story can be consolidated deliberately afterwards if the user asks; nothing here does
   it on their behalf, and an in-flight story is never consolidated at all.
3. **A stop is per-story.** On any `tiering-agent` stop condition, report it and
   leave that story exactly as it was — one story stopping never stops the others.
4. **Resolve `tests/tiering-report.md` before re-bootstrapping.** If the pass
   reported precondition inversions, bootstrapping refuses while any pair is
   unresolved (`.claude/templates/workflow/bootstrapping.md`, "Precondition
   inversions") and the resolution is a human call in the test files. Report the
   pairs and stop on that story: it is left with markers written and its old plan in
   place, which the **Convertible** row picks up again on the next run — the
   already-tier-major row keys on the plan's shape, not on the markers, precisely so
   a half-migrated story is not read as a finished one.
5. **Capture and verify before deleting anything.** Read the current `progress.md`
   and record every `[S]` with its reason. Then confirm the marker set can actually
   be derived from: every `### N.M` heading under `tests/` carries exactly one marker
   and none of them is `Tier: ?`. Both of those **stop** `bootstrapping.md`, and a
   stop discovered *after* the delete leaves the story with no plan at all — the one
   unrecoverable outcome in this migration. On an incomplete set, report it and stop
   on that story with its old plan intact.
6. **Re-bootstrap** — delete `progress.md` and re-derive it per `bootstrapping.md`,
   which emits the tier-major sections and the `harvest` checkbox from the markers.
   **Restore every captured `[S]` and its reason.** A skip is a recorded decision,
   not something derivable from the test files, so the derivation would silently
   reinstate skipped work as `[ ]`. Nothing else needs carrying: at zero `[x]` there
   is no completed work to preserve.
7. **Update the story's row** in `ProductSpecification/stories.md` to the split
   cells (`.claude/templates/workflow/stories-md-format.md`). A converted story
   leaves the flat shape for good.

## In flight: nothing at all

A story with committed work is left exactly as it is. No markers, no
`tests/tier3/`, no moves, no tier prefixes, no `harvest` checkbox, no `stories.md`
change. Its plan stays untiered **permanently**
(`.claude/templates/workflow/progress-format.md`, "Untiered stories") and its row
keeps flat cells. Report these stories by name as **left untiered** — silence reads
as migrated.

Tagging the test files without touching the plan is the obvious alternative, and it
does not survive contact with either side of that split. The pass that writes markers
also *moves* scenarios (`.claude/agents/tiering-agent.md` — "skip none", plus its
directory-matches-marker assertion in both directions), and a move under a frozen
plan orphans the moved scenario's steps or lands one with none; forbidding the moves
asks that agent to be a different agent. What is left is a marker on every scenario
above a flat plan — a combination `bootstrapping.md` and
`.claude/templates/workflow/plan-integrity-check.md` both treat as impossible — plus
a `tiering-report.md` no branch here can consume. And it buys nothing in exchange:
the ordering gain is already spent on this story, there is no shippable milestone to
recover, so the markers would purchase repo-wide grep uniformity at the price of a
state the repo says cannot exist.

## Re-running over a tier-major story

Only reachable by explicit request — the scope table skips these. When the user asks
for a genuine re-tier of one, its plan already exists and `/continue` never
re-derives it, so markers and plan can disagree:

- A scenario **promoted** into `tests/` out of `tier3/` has a marker and no steps —
  nobody will build it. **Report the pair; do not insert the steps.** The only
  position the tier-major shape allows is the end of its new tier's section, and that
  sits *above* the current `[~]` whenever the cursor has already moved past that tier
  — where a pending block steals `/continue`'s next-step pointer and strands the
  in-flight scenario. There is no legal position, so the user picks one. This is the
  same treatment the refused demotion below gets.
- A scenario **demoted** to `tier3/` that already has an `[x]` step is not demoted.
  Its work is built and committed; report the pair and leave it where it is.
- A demoted scenario with no started step takes its steps with it — remove them in
  the same commit as the marker and the move.
- Everything else keeps its position. Re-tiering an existing plan never reorders it.

The next `/continue` resume runs the plan-integrity check over the result
(`.claude/templates/workflow/plan-integrity-check.md`), whose marker↔plan agreement
check reports a promotion whose steps are still missing. That check reads tier-major
plans only — which is another reason the in-flight branch above writes nothing: on an
untiered plan there is no check to catch what a marker broke.

## Report and commit

**One commit per story, never one for the whole run**, so a bad tier call on one
story is revertible on its own. Message: `retier: story NN — Tier 1 a, Tier 2 b,
Tier 3 c`, with the branch taken in the body.

**Stage explicit paths only** — that story's `tests/`, its `progress.md`, and
`ProductSpecification/stories.md`. Never `git commit -a`: the run walks several
stories, and a catch-all stage folds a neighbour's half-written migration into the
wrong commit, which is exactly the per-story revert this section exists to preserve.
**Skip a story whose folder already holds uncommitted changes**, and say so — inside
one commit there is no way to separate the user's work in progress from the
migration's.

Report per story: its state, the action taken, the split, **every Tier 3 scenario
named** with the degradation judgment quoted from its marker, every Tier 2 admission,
every stop condition hit, and every story skipped with the reason. A skipped story
has to be visible in the report — silence reads as migrated.

## Agent logging

`tiering-agent` appends its own milestones per story
(`.claude/guidelines/agent-logging.md`, the `tiering-agent` row), and one
START/DONE pair per story is the run's progress record. `/retier` emits no
milestones of its own, so it needs no row in that file.
