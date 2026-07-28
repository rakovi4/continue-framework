# Plan Integrity Check

`/continue` runs this over the work item's `progress.md` at step 4, before it selects
the next work unit. It is a **detector, not a repair**: a failed check stops dispatch
and reports.

Why a detector and not an owner: a `progress.md` is written by many actors —
bootstrapping, the `adapters-discovery` and `steps discovery` gates, a mid-cycle
scenario insertion, a human resolving a precondition inversion. Naming one owner per
edit does not stop the other actors from getting it wrong. A check at the one point
every work unit passes through does, and it catches breakage introduced by an actor
nobody anticipated.

## Checks

Checks 1, 2, 4 and 6 need a **tier-major** plan (any `## Tier N — ` heading). Checks 3
and 5 apply to every plan, tiered or not. All six are greps over `progress.md` and
`tests/*.md` — no agent, no build.

1. **Heading shape.** Every scenario section heading matches
   `## Tier {N} — {Category} Scenarios ({file})`
   (`.claude/templates/workflow/progress-format.md`). A heading missing the `({file})`
   part is the signature of a section written by hand rather than derived — and the
   `stories.md` `Tests`/`%` math counts `### ` headings *per tier section*, so a
   malformed heading hides its scenarios from the counts.

2. **Tier-major order.** No `## Tier 1 — ` section appears after any `## Tier 2 — `
   section, and exactly one `## Harvest — Tier 1 → Tier 2` sits between the last Tier 1
   section and the first Tier 2 one. A Tier 2 section above the boundary puts unstarted
   Tier 2 work ahead of the check that confirms Tier 1 delivered the feature.

3. **Nothing pending above the cursor.** No `- [ ]` line appears above the file's first
   `- [~]` line. `/continue` selects the first `[~]` or `[ ]`, so a `[ ]` block inserted
   above the in-flight step steals the next-step pointer and abandons the in-flight
   scenario mid-cycle, leaving its red test in the tree.

4. **Marker ↔ plan agreement.** For each `tests/*.md`: every `### {N}.{M} {Title}` whose
   marker reads `Tier: 1` or `Tier: 2` has exactly one identical `### {N}.{M} {Title}`
   heading in `progress.md`, and every scenario heading in `progress.md` exists in a test
   file. Present in the tests but absent from the plan is a scenario **nobody will
   build** — the shape a mid-cycle insertion leaves when it writes the test file and
   stops. Present in the plan but absent from the tests is a renamed or deleted scenario
   whose steps are now orphaned. `tests/tier3/` is never counted: Tier 3 never enters the
   plan.

   **One sanctioned sub-case, and it does not stop dispatch.** A `tests/*.md` heading
   absent from the plan whose tier+category section **precedes the current `[~]`** is a
   *pending deferred placement*: a mid-cycle newcomer whose position collides with the
   cursor waits for the next scenario boundary
   (`.claude/guidelines/workflow-detail.md`, "Net-New Scenarios Introduced Mid-Cycle").
   Report it by name and **keep dispatching** — it becomes blocking again once no `[~]`
   remains inside a scenario block, which is the boundary where the block is placed and
   the cursor moves onto it. Blocking here instead would stop the very first resume after
   the deferral, so the in-flight scenario could never finish and the boundary the block
   waits for would never arrive. Every other form of this shape still stops.

5. **Every scenario heading carries steps.** Inside a scenario section, each `### `
   heading is followed by at least one `- [ ]`/`[~]`/`[x]`/`[S]` line before the next
   heading. Non-scenario checkboxes (`## Spec`, `## Harvest — …`, a task's `## Fix:`
   section) legitimately carry no `### ` heading and are not checked. A step block
   written *without* its heading is attributed to the preceding scenario, which then
   reads incomplete while the newcomer is invisible to the counts.

6. **Marker completeness, test-file side.** Over `tests/*.md` **and** `tests/tier3/*.md` —
   not recursively, and never `tests/extended/`: `grep -F 'Tier: ?'` returns nothing in
   either, and every `### {N}.{M}` heading in both carries exactly one marker line. This is
   the same stop `.claude/templates/workflow/bootstrapping.md` applies at derivation time,
   re-applied on every resume — a marker written *after* bootstrapping is never re-derived,
   so this is the only place it is ever looked at again.

   `tier3/` is in scope even though check 4 exempts it, because the two exemptions are
   different quantifiers: check 4 exempts Tier 3 from **plan membership**, which says
   nothing about **marker completeness**. `tier-ladder.md` requires a marker in every tier
   including `tier3/`, precisely because a scenario that shed its token on the way in is one
   the pinned floor can never be checked against again — and `tier3/` is where an unchecked
   mis-tier does its damage, since `bootstrapping.md` never reads it and nothing downstream
   revisits it. This check is the only thing that ever looks again.

   `extended/` is the one genuine exemption: it is a pre-tiering directory `/retier` leaves
   untouched permanently, so its headings carry no markers and never will. Recursing into it
   would fail this check on every resume in a migrated repo, forever.

## On a failed check

Report the check, the file, and the offending lines, then **stop**. Do not repair the
plan: a plan out of step with its markers means either the marker or the plan is wrong,
and guessing wrong silently reorders or deletes committed work. The resolution is a
human call — or, for a story still at 0%, a re-bootstrap, which derives the whole plan
from the markers again.

An untiered plan is not a failure. It has no tier sections and no markers, so checks 1,
2, 4 and 6 have nothing to read and are skipped — the permanent untiered branch, never a
set awaiting migration.
