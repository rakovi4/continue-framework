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
and 5 apply to every plan, tiered or not; check 7 applies to refactor tasks. The
write-time check 8 applies to every staged progress edit. Checks 1–7 are greps over `progress.md` and
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

   **No sub-case is exempt.** A mid-cycle newcomer's `progress.md` block always lands in
   the same `review-fix:` commit as its test file, because the review passes fire only at a
   block boundary, where nothing is in flight to strand
   (`.claude/guidelines/workflow-detail.md`, "Net-New Scenarios Introduced Mid-Cycle"). So
   a heading in the tests with no steps in the plan is never a legitimate transient state —
   every form of it stops.

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
   including `tier3/`, because provenance is the only durable record of the route that
   generated a deferred scenario. `bootstrapping.md` never reads that directory and nothing
   downstream revisits it; this check is the only thing that looks again.

   `extended/` is the one genuine exemption: it is a pre-tiering directory `/retier` leaves
   untouched permanently, so its headings carry no markers and never will. Recursing into it
   would fail this check on every resume in a migrated repo, forever.

7. **Refactor discovery changed the plan.** A completed `refactor (steps discovery)`
   checkbox must end with `(plan: +N/-N/~N)` and at least one count must be non-zero.
   Otherwise stop: a discovery artifact beside an unchanged `## Work` plan is not a
   completed plan-reconciliation gate.

8. **New progress content is structural.** Before every commit containing
   `progress.md`, inspect its zero-context staged diff. Every added non-blank line
   must be an H1/H2/H3 heading, `Type:` line, checkbox line, or the exact
   `<!-- review-origin: boundary -->` marker. A checkbox must occupy one physical
   line; compact dispatch/audit tokens are allowed, but an indented continuation,
   prose paragraph, test output, verdict, lane checkpoint, or other HTML comment
   fails. Any added checkbox over 200 characters also fails. Put the rejected content
   in the invocation's `worklog/` record and re-stage.
   Checking additions rather than the whole file grandfathers legacy narrative
   while preventing any new bloat.

## On a failed check

Report the check, the file, and the offending lines, then **stop**. Do not repair the
plan: a plan out of step with its markers means either the marker or the plan is wrong,
and guessing wrong silently reorders or deletes committed work. The resolution is a
human call — or, for a story still at 0%, a re-bootstrap, which derives the whole plan
from the markers again.

An untiered plan is not a failure. It has no tier sections and no markers, so checks 1,
2, 4 and 6 have nothing to read and are skipped — the permanent untiered branch, never a
set awaiting migration.
