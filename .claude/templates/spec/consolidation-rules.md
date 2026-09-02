# Scenario Consolidation — Invariant, Eligibility & Merge Arithmetic

The vocabulary for merging scenarios that share **one execution** into one scenario,
so a story spends one TDD cycle per interaction rather than one per checked fact.

Definitions only: the invariant a merge must preserve, the test a candidate must pass,
the merges forbidden outright, and what becomes of the merged marker, title and number.
*Which* pass merges is `.claude/agents/consolidation-agent.md`. Read this file whenever
you merge scenarios, review a merge, or reverse one.

## The invariant

> **Every assertion survives the merge.** Consolidation removes duplicated *setup*
> and duplicated *execution*. It never removes a checked fact.

A merge that drops a Then is a coverage cut wearing a consolidation costume, and it is
the one failure mode this pass exists to prevent. So the invariant is written as
something checkable rather than as an intention: for each merge, every absorbed
scenario's Then clauses are enumerated and each pointed at the line of the surviving
scenario that now carries it. A Then with nowhere to point is a merge to undo, not a
merge to explain.

Two corollaries follow, and both violate the invariant without deleting a line:

- **Never weaken an assertion to make it fit.** Two exact checks do not become one "the
  result is valid". Each fact keeps the strictness the scenario it came from gave it.
- **Never fold an assertion into the setup.** A fact moved into the Given is a fact
  the scenario now assumes instead of checking.

## Fewer passes, never fewer facts

The delivery ceilings in `tier-ladder.md` constrain the eventual Tier 1 and Tier 2
stack, not consolidation eligibility. Consolidation reduces the number of **passes**,
while the number of facts checked is unchanged *by construction*.

There is no consolidation target, ratio, or permission to force a merge. A count that
stays high after an honest pass is handled by tiering distinct overflow scenarios into
Tier 3. **A merge whose justification is the resulting number is forbidden**, even
where it would otherwise be eligible.

## Where the pass runs

Over the drafted set, **after** the hazard-catalogue scan and **before** tiering,
exactly once per story.

- **After the scan**, because a GAP folded in as a scenario is a scenario like any
  other. A pass running earlier would leave the newest scenarios — the ones nobody
  drafted deliberately — as the only un-consolidated ones.
- **Before tiering**, for three reasons pointing the same way. Tiering is comparative
  over the units that actually get built, so it must weigh merged units and not their
  parts. The marker protocol stays intact: consolidation writes only the `?` form, so
  the tier is still written once, by one pass (`tier-ladder.md`, "The marker").
  Provenance is unioned before the tiering pass evaluates the merged scenario, with
  nothing to re-check and no second implementation of marker handling.

Consolidation therefore never sees a resolved tier and never assigns one. The price is
that it cannot compare tiers directly — so clause 7 below asks the ladder's own
question of each pair instead, and refuses whenever the answers differ or either is
unclear.

**Scope: `tests/*.md` only.** Never `tests/tier3/`, never `tests/extended/`. Those hold
what is recorded and not built, so merging inside them saves no pass at all, and merging
one of them into a built scenario drafts a scenario back into the plan by the side door.

## Mandatory eligibility — every clause, not most of them

A group of two or more scenarios **must be merged** when all of these hold for the
whole group. Any clause you cannot positively assert is a "no".

1. **Same category file.** Category decides which layer implements the scenario and
   therefore which step block it derives; a pair split across files has no single
   place to live.
2. **Same `## N. Section`.** Sections encode the implementation ordering of
   `test-spec-format.md` — read before write, validation before happy path. A merge
   inside one section cannot violate an ordering that section already satisfies.
3. **Same actor and same entry point.** One role, one interaction: one request to one
   endpoint, one page, one run of one job.
4. **One Given, satisfied once.** Both Given clauses are met by a single setup and
   neither contradicts the other. "Similar" is not the test — *simultaneously
   satisfiable by one state* is.
5. **One When.** The same action, executed once. Not two actions in sequence.
6. **Outcomes that co-occur.** Every Then from both scenarios can be true of that one
   execution's result at the same time.
7. **Same consequence of failure.** You would give both the same answer to the
   ladder's question — does this failure break the feature, make it unsafe, or leave
   a bounded degradation (`tier-ladder.md`, "The ladder")? Unsure counts as different.
8. **Failure stays informative.** Each absorbed fact is named in the merged scenario,
   so a red says *which* fact broke without a debugging session.

Form maximal groups, not just pairs: if three scenarios all describe the same single
execution, merge all three once. Two shapes pass this test in practice: **independent
facts about one result** (several fields of one response, several elements of one
rendered view), and **several rejected
inputs to one validation surface** (each rejected the same way, distinguished by the
input it names).

## Forbidden merges

Eligibility says when a merge must happen. These say when it must not — including
cases that slip past a hurried reading of the test above.

- **A success path with a failure path of the same request.** One execution has one
  outcome; these cannot co-occur. The most tempting merge in any category file, and
  never a legal one.
- **Across category files, across stories, or into `tier3/` / `extended/`.**
- **Anything needing the Given rebuilt mid-scenario.** Reconstructing state between
  the halves *is* the second pass — moved inside one heading, saving nothing and
  making the failure harder to read.
- **A sequence of interactions is not consolidation.** After consolidation, stack it
  only for consecutive steps of one real user journey to value and any value capture
  in scope. That creates one delivery cycle, not one execution: preserve every
  assertion and allow separate RED cases. Touching the same code is not eligibility.
- **Anything that makes a failure ambiguous.** A merged scenario whose red does not
  say which fact broke has traded one pass for a diagnosis on every future failure,
  forever.
- **Across the ladder's answer.** A merged unit is built at the position of its most
  critical part, so absorbing a hardening fact into a demonstrable-feature scenario
  drags hardening into the shippable milestone and stops that milestone meaning what
  it says — a tiering violation dressed as an efficiency. It is also an
  *anti*-efficiency: a Tier 2 acceptance fact left standing alone is often already
  green at the tier boundary and free to collect there, while merged upward it is
  paid for in full.
- **A mandate for N distinct executions.** Where a checklist requires a scenario per
  endpoint, per direction or per destination — the Prerequisite Guard Checklist, the two
  directions of the Side-Effect & Idempotency Guard Checklist, the navigation
  click-and-verify rule — one merged scenario does not discharge it: the mandate is
  about the executions, and each is a different entry point anyway.
- **To reach a count.** See "Fewer passes, never fewer facts".

Then apply `.claude/templates/spec/journey-stacking-rules.md` to join separate
executions that are checkpoints in one delivery cycle before tiering.

## Marker arithmetic

The merged scenario is one heading with **exactly one** marker line — the shape
`bootstrapping.md` and plan-integrity check 6 both assert.

- **Provenance unions.** The survivor carries every token from every absorbed scenario,
  comma-separated and de-duplicated: a `sec:SQLi` scenario plus a bare one yields
  `Tier: ? (sec:SQLi)`; `(hz-02)` plus `(sec:IDOR)` yields `Tier: ? (hz-02, sec:IDOR)`.
  Never replace, never elect a primary, and never drop a token. One lost in a merge
  destroys provenance — downstream nothing can tell a merged scenario
  that shed its token from one no route ever claimed (`tier-ladder.md`, "Provenance").
- **The tier stays `?`.** Consolidation runs before tiering and resolves nothing.
- **If a resolved tier is ever merged** — reachable only by a deliberate hand-merge on
  an already-tiered set, never by this pass — **the lower number wins**, because the
  unit is built at the position its most critical part demands. A merged unit is
  `Tier: 3` only when every part was.
- **Title.** Name the interaction, not the list of facts. A concatenation ("…A and B
  and C") is rewritten the first time someone tidies it, and every downstream key —
  `progress.md` headings, journey summaries, decision records, plan-integrity check 4 —
  is that exact string.
- **Number.** The survivor keeps the **lowest** `### N.M` among the merged scenarios,
  under that scenario's section. Absorbed numbers are retired: never reused, never
  backfilled, nothing below them renumbered — gaps are the expected shape, for the
  reason `tiering-agent` refuses to renumber around a Tier 3 move.

## Worked merges

Independent facts about one result — eligible under every clause. `2.1 Creating an
{Entity} returns its identifier` + `2.2 … returns its creation time` + `2.3 A created
{Entity} starts in the default state` (`hz-04`) become one scenario at the lowest
number, carrying all three Thens:

```markdown
### 2.1 A created {Entity} is returned in full

Tier: ? (hz-04)

Given {Actor} is authenticated
When {Actor} submits a valid {Entity}
Then the response carries the new {Entity}'s identifier
And the response carries its creation time
And its state is the default state
```

One validation surface, several rejected inputs — eligible; the examples table is what
keeps failure informative, because a red names the row. `3.1 A blank {field} is
rejected` + `3.2 An over-long {field} is rejected` (`sec:InputLength`) + `3.3 A {field}
with disallowed characters is rejected` become `### 3.1 An invalid {field} is
rejected`, `Tier: ? (sec:InputLength)`, one Scenario Outline over the three inputs.

**Not** merges. `4.1 A valid submission creates the {Entity}` + `4.2 A submission
naming a missing {Prerequisite} is rejected` is forbidden three times over: the
outcomes cannot co-occur (one request, one result), the Given states differ
({Prerequisite} exists in one and not the other), and the consequences of failure
differ. `5.1 An {Entity} can be created` + `5.2 … renamed` + `5.3 … removed` is
forbidden for three When clauses — chaining them still costs three implementations and
destroys the read-before-write ordering that let each be built on the last.

## Reporting

The pass **reports and stops**: it never re-runs itself, never runs a second merge pass
over its own output, and never adjusts a merge because of the resulting number. The
report carries, at minimum: the
before/after scenario count per file; one entry per merge naming the surviving
`### N.M Title` and every absorbed `### N.M Title`; per absorbed scenario, each Then it
contributed and where it now lives; and the merged marker beside the union it was built
from. That is what makes a merge auditable and, where a human disagrees, reversible
from the report alone.
