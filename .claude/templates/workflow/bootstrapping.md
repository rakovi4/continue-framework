# Bootstrapping a progress.md

How `/continue` derives a story's `progress.md` when none exists. The file's shape
is in [`progress-format.md`](progress-format.md); this file is the derivation.
Tasks are never bootstrapped — `/task` generates everything at creation time.

## Procedure

1. **Detect spec artifacts** in the story directory:
   - `interview`: `interview.md` exists
   - `story`: `NN_StoryName.md` exists
   - `mockups`: `mockups/` has files
   - `api-spec`: `endpoints.md` exists
   - `test-spec`: `tests/01_API_Tests.md` exists
   - **Edge case**: if all spec items exist EXCEPT `interview.md`, mark
     `[S] interview (spec completed without interview)` — don't force retroactive
     interviews on old stories.
   **If `tests/` does not exist yet**, `test-spec` has not run: emit only the
   `## Spec` section (the items detected above) and stop. The scenario sections do
   not exist until `/test-spec` drafts and tiers the test files — a brand-new story
   bootstrapped before its spec is not an untiered story, it is an unspecced one, and
   the two must not be conflated (the untiered branch below is for a *specced* set
   with no markers).
2. **Read the test specs** — `tests/NN_*.md`, whichever of the six categories the
   story has. Never `tests/tier3/` (below).
3. **Scan existing test classes and production code** for steps already done.
4. **Emit the sections** in tier order (below), marking completed steps `[x]`, the
   next `[~]`, the rest `[ ]`.
5. For backend, integration, security, load and infrastructure scenarios **always
   include `design` after `red-acceptance`** — it is mandatory for every scenario
   needing new implementation, and omitted only when the entire scenario is `[S]`.
   Include `[ ] adapters-discovery` after `green-usecase`; it resolves when reached.
6. For frontend scenarios, include `demo` as the final step.

## Tier order

Each scenario's tier is read from its `Tier:` marker in the test file, which is the
source of truth (`.claude/templates/spec/tier-ladder.md`, "The marker"). Emit the
sections, and the harvest checkbox between them, in the tier-major order
`progress-format.md` defines. Within a tier, order categories by the lifecycle order
of `.claude/rules/workflow.md`: `01_API`, `06_Integration`, `02_UI`, `05_Security`,
`03_Load`, `04_Infrastructure` — the same order in each tier.

**Never read `tests/tier3/`.** Tier 3 is recorded and not built, and it now sits
under the same parent as the categories that are — so a recursive read of `tests/`
is exactly what would put it quietly back into the plan. Enumerate `tests/NN_*.md`
and nothing else.

Three marker states are off-nominal and each stops rather than guesses. Emitting a
half-tiered set flat is the one outcome to avoid at all costs: it produces a plan
whose missing scenarios are invisible rather than obviously absent.

- **A `Tier: ?` marker stops the bootstrap.** `?` means the tiering pass never
  reached that scenario (`tier-ladder.md`, "The marker"), so its position is not
  derivable. Name the scenarios carrying it and stop.
- **A scenario with no marker line at all — in an otherwise-markered set — stops it
  the same way.** A missing line is indistinguishable from a scenario nobody stamped
  (`tier-ladder.md`, "The marker"), so the safe reading is the same as `?`: name it
  and stop, never silently drop it. Confirm the whole set: every `### N.M` heading in
  the enumerated files carries exactly one marker line before emitting anything.
- **No markers *anywhere* is the untiered shape**, not an error — a *specced* story
  from before tiering existed (an unspecced one was already handled at step 1's
  `tests/`-absent case). Emit that shape verbatim (`progress-format.md`, "Untiered
  stories"); this derivation never converts one.

## Precondition inversions

The tiering pass reports every scenario whose Given needs behavior a later tier
delivers (`.claude/agents/tiering-agent.md`, "Report"). Tier-major ordering is what
creates them, so that report is not a curiosity — but it is resolved **in the test
files, before bootstrapping**, and never carried into `progress.md` as an
annotation. An annotation here would evaporate at the next re-bootstrap, exactly as
a tier recorded here would.

That resolution needs a durable trigger, because the pass runs at spec time and
bootstrapping may run sessions later: the report cannot live only in the tiering
pass's transient output. So the pass writes its inversion list to
`tests/tiering-report.md` (`tiering-agent.md`, "Report"), and **bootstrapping
refuses to run while that file lists any unresolved pair** — it names the pairs and
stops, the same as an unresolved marker. A resolved pair is struck from the file (or
the file deleted when none remain) as part of resolving it in the test files. This
is the one wired check that a reported inversion was actually acted on; without it
the resolution is a moment with no actor.

Two resolutions, both landing in `tests/`:

- **The Given is fixture setup, not product behavior.** Most reported pairs are
  this: "a board holding 10 000 rows" is seeded by the test DSL, not produced by the
  bulk-import feature that happens to be Tier 2. Nothing to fix — it was never an
  inversion.
- **The Given genuinely needs the later scenario's behavior.** Then the tier call
  was wrong, not the ordering: a scenario the primary user's feature cannot work
  without belongs in the same tier as the scenario that needs it. Promote it, in its
  marker.

Never resolve one by demoting the scenario that depends. That is re-tiering to fit
an ordering, which the ladder forbids as flatly as it forbids re-tiering to fit a
count (`tier-ladder.md`, "No targets").
