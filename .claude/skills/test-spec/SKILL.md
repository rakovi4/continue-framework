---
name: test-spec
description: Generate BDD test specifications for story in 6 categories (API, UI, Load, Infrastructure, Security, Integration). Use when user wants to create test cases or mentions /test-spec command.
---

# Generate Test Specifications
Generate BDD-style test specifications for a story in 6 categories — one file per
category under `tests/`. The drafted scenarios are then split by **consequence of
failure** into three tiers (`.claude/templates/spec/tier-ladder.md`): Tiers 1 and 2
are implemented in that order, Tier 3 is recorded in `tests/tier3/` and never built.

## Usage
```
/test-spec "Story name"
/test-spec 5              # By MVP story number
/test-spec                # Interactive selection
```

## Workflow
### Phase 1: Context & Story Selection

Parse input first — by name (`"Login/Logout"`), by number (`5`), or interactive (list and ask) — since the reads below are scoped to the resolved story and the areas it touches.

Read before generating: `ProductSpecification/BriefProductDescription.md`, `ProductSpecification/stories.md`, `ProductSpecification/ExpectedLoad.md`, and the **target** story's folder: `mockups/`, its spec `*.md`, `endpoints.md`, `interview.md`. Resolve that folder `stories/NN-story-name/` first, then `stories/done/NN-story-name/` (`.claude/rules/workflow.md`, "Resolving a story folder") — these reads tolerate absence, so an unresolved archived folder is indistinguishable from a story that has no interview, and generation proceeds from the spec alone.

For what the product already does in the areas this story touches — so a drafted scenario neither re-specifies shipped behavior nor contradicts it — read the **acceptance tests of those areas**: test class names, scenario descriptions, Statements. Never sweep the other story folders to reconstruct it (`.claude/rules/workflow.md`, "Where the Current State Lives"). Only **enabled** tests count as shipped — one still carrying its disable/skip marker is a pending increment, not shipped behavior. Where the suite is silent about an area, read that area's production code — silence is not evidence of absence. In a repo with no acceptance suite yet, say so explicitly and fall back to the story folders. Open an earlier story's folder only for a **named** precedent: the decision behind a rule this story extends — under `stories/` or `stories/done/`, a closed story being the usual home of a settled rule (`.claude/rules/workflow.md`, "Resolving a story folder").

If `interview.md` exists, extract:
- Business rules and constraints → map to API test scenarios
- Explicit edge cases (state transitions, ordering, concurrent edits) → map to scenarios like any other; whether one is a bounded, acceptable degradation is Phase 5's call, not a decision made while reading the interview
- External API error modes → map to integration tests
- Rate limits and performance constraints → map to load tests when they exercise the project's declared **Load Challenge Profile** (read `ExpectedLoad.md` to identify it); skip constraints that don't match the project's profile

**Prerequisite analysis** (mandatory): Read the story's Prerequisites section and Validation Rules table. For each prerequisite, generate guard scenarios in BOTH API and UI tests following the Prerequisite Guard Checklist in `test-spec-format.md` — its rules cover extraction, per-endpoint coverage, and which two sources an established blocker pattern is read from — never a sweep of the other story folders.

**Side-effect & idempotency analysis** (mandatory): Scan the story spec and `interview.md` for operations that move money, call an external system, send email, or mutate persisted state in a batch. For each one that can be re-run (scheduled job, webhook, user retry), generate re-run-safety scenarios in BOTH directions — inbound duplicate-event and outbound re-attempt-after-partial-failure — following the Side-Effect & Idempotency Guard Checklist in `test-spec-format.md`. Phase 2 stamps their `hz-02` provenance; the tier itself is Phase 5's call.

### Phase 2: Generate Test Files

Load `.claude/templates/spec/test-spec-format.md` for category formats, ordering principles, and BDD rules.

Create files in the `tests/` directory of the folder the story resolved to — `ProductSpecification/stories/NN-story-name/tests/`, or `stories/done/NN-story-name/tests/` for a story that has closed (`.claude/rules/workflow.md`, "Resolving a story folder"):
- `01_API_Tests.md`, `02_UI_Tests.md`, `03_Load_Tests.md`
- `04_Infrastructure_Tests.md`, `05_Security_Tests.md`, `06_Integration_Tests.md`

Author no `extended/` file. A nice-to-have scenario is drafted into its category
file like every other one and reaches `tests/tier3/` only if Phase 5's comparative
pass puts it there. Existing `extended/` directories are left exactly as they are.

**Stamp a `Tier: ?` marker on every scenario as you write it.** The tier is
comparative — it cannot be settled until the whole set exists — so authoring writes
the pre-tier form and Phase 5 substitutes the tier. Placement and token vocabulary
are in `tier-ladder.md` ("The marker", "Provenance"); *which* token you stamp is
decided here:

| Scenario produced by | Marker |
|---|---|
| the Side-Effect & Idempotency Guard Checklist | `Tier: ? (hz-02)` |
| any row of the security checklist | `Tier: ? (sec:{row})` — `sec:IDOR`, `sec:JWT`, `sec:SQLi`, `sec:RateLimit`, … |
| any other route — the story spec, the Prerequisite Guard Checklist | `Tier: ?` |

Every security row stamps. Provenance records which generation route produced a
scenario; it does not force implementation or encode importance.

The bare `Tier: ?` of the last row is not optional — it is what makes the Phase 5
sweep able to catch a scenario the pass never reached (`tier-ladder.md`, "The
marker").

Stamp `sec:` tokens **in `05_Security_Tests.md`**, where the security checklist's
output belongs.

### Phase 3: Hazard Catalogue Scan

After the test files are drafted, scan them against the hazard catalogue — the spec-time,
closed-list complement to the open-ended commit-time review passes, and the
generalization of the Phase 1 side-effect/idempotency analysis to every hazard class.
Dispatch it exactly as `.claude/guidelines/hazard-catalogue/_index.md` prescribes (read
its "How to apply it", "The dispatch shape"); the artifact under scan is the **drafted
test files**.

Fold every GAP back into the matching category file as the forced-guard scenario it
names, carrying the GAP's own id in its marker: `Tier: ? (hz-02)`. An unresolved GAP blocks
Phase 4 and everything after it — a folded GAP is a merge candidate, so it must exist
before consolidation runs. Fold or dismiss every fired trigger, with a reason, first.

Then stamp the pass's **COVERED** lines too. Each one names a scenario already in the
files that is the forced guard for its class; add that group's id to that scenario's
marker. A scan raises a GAP only where a guard is missing, so GAP-only stamping would tag
the scenarios nobody thought of and leave the well-drafted ones bare — the inversion
`tier-ladder.md` ("Provenance") names, and the reason `hz-01` and `hz-05` have no
authoring-time checklist to stamp them.

A folded GAP is tiered in Phase 5 like every other scenario, and is never pre-assigned a
tier here (`_index.md`, "A fired GAP is tiered, not automatically critical-path"). Two
rules on the token:

- **Union, never replace.** A GAP folded into a scenario Phase 2 already stamped adds its
  id: `Tier: ? (hz-02, sec:IDOR)`. A guard the synthesis pass reconciled across a seam
  carries both groups' ids, exactly as that pass reported them.
- **Stamp only what fired.** The id comes from the scan that raised the GAP. Never guess a
  group id onto a scenario, and never stamp one on a scenario no route produced.

### Phase 4: Consolidate the Set

Two scenarios that need the same actor, the same entry point and the same Given state,
and whose outcomes can all be true of one execution, are one execution wearing two
headings — and each heading costs a full TDD cycle. Merging them buys one delivery
cycle while keeping every assertion; RED may split its executable form into several test methods without creating more cycles.

Dispatch `consolidation-agent` (`.claude/agents/consolidation-agent.md`) **once**, for
the whole story, over every `tests/*.md`. It merges only what
`.claude/templates/spec/consolidation-rules.md` makes eligible; every eligible maximal
group must merge. It unions the absorbed provenance tokens onto the survivor, leaves
every `Tier: ?` unresolved for Phase 5, and
reports each merge with what it absorbed. It runs after the scan so a folded GAP is a
merge candidate, and before tiering so the comparative pass sorts the units that are
actually built and provenance remains on the merged token union — the argument is in
`consolidation-rules.md`, "Where the pass runs".

On a stop condition, report it and do **not** fall through to Phase 5: a half-merged set
holds one assertion under two headings. Do not re-dispatch or force extra merges to hit
the delivery ceilings; Phase 5 places distinct overflow scenarios in Tier 3.

### Phase 5: Tier the Set

Dispatch `tiering-agent` (`.claude/agents/tiering-agent.md`) **once**, for the whole
story. Hand it every `tests/*.md` file, any `tests/tier3/` that already exists, and the
story spec — it stops rather than tier a partial set, and the spec is the only place the
primary user is named. It substitutes each `Tier: ?`, moves Tier 3 scenarios into
`tests/tier3/` under the same category filename (`tests/tier3/05_Security_Tests.md`), and
reports the split.

Sweep the markers around the dispatch with `grep -rF 'Tier: ?' tests/`: it returns every
scenario drafted in this run before the dispatch — `tests/tier3/` holds resolved `Tier: 3`
markers and is outside that count — and nothing after it. A leftover `?` is a scenario the
pass did not reach: report it, do not resolve it yourself.

**The pre-dispatch half needs a comparand — a per-heading one.** A `?` count cannot see a
scenario carrying **no marker line at all**, the one state the stamping rule names as
undetectable by grep. Assert what `bootstrapping.md` and plan-integrity check 6 both
assert: every `^### [0-9]` heading is followed by **exactly one** `^Tier: ` line before the
next heading. A heading with none is stamped before the dispatch; a heading with two is
unioned into one line per Phase 3's "Union, never replace". Do *not* settle for equal counts per
file — one bare scenario and one doubled marker net to equality and pass, and that pair is
not exotic: the same Phase 2 pass that emits a second `Tier:` line while folding a GAP into
an already-stamped scenario is the one that leaves a route-less scenario unstamped. Without
this the sweep proves only that the markers which existed got substituted, and says nothing
about the ones that never did.

**When the pass reports something other than a split.** Two different outcomes arrive here,
and they leave the tree in opposite states — read the report, never the `?` count:

- A **stop condition** is evaluated at `tiering-agent`'s workflow step 3, before anything is
  written, so every marker still reads `Tier: ?` (`.claude/agents/tiering-agent.md`, "Stop
  conditions").
- A **failed move** is detected *after* step 5 wrote every marker and step 6 moved the
  files, so there the markers are all resolved and the tree is partially moved. The
  post-dispatch `grep -rF 'Tier: ?' tests/` is **clean** for it — the mechanical sweep
  cannot see this one at all.

Either way, do not fall through to Phase 6: it summarizes a split that does not exist, and
after a stop the story would read spec-complete while `bootstrapping.md` refuses to derive
any plan from an unresolved `?`. Report what happened and stop. The resolutions are the
caller's and they differ: a partial dispatch is re-dispatched whole. A **failed move has no re-dispatch resolution** —
re-dispatching re-tiers an already-tiered set and silently replaces a split whose only
record was the failed report. Restore the story's `tests/` tree from the last commit and
re-dispatch from that state; never hand-repair the duplicate or the loss. Never tier by
hand, and never fill in a `?` to get past a stop — that produces exactly the
unreviewed-but-tiered set the stop exists to prevent.

Count resolved `Tier: 1` and `Tier: 2` markers in `tests/*.md` after the dispatch;
require Tier 1 <= 10 and Tier 1 + Tier 2 <= 25. Do not trust the report alone. A
violation or an infeasible-stack report blocks Phase 6; never hand-demote scenarios.
Every remaining eligible scenario belongs in Tier 3.

### Phase 6: Summary

Report: folder path, files created, test counts per file, and the hazard-scan result —
the group set scanned (the `_index.md` **Groups** list at scan time), each group's verdict,
and every GAP's disposition (folded → named scenario, or dismissed with reason).

Then Phase 4's consolidation result — the before/after count per file and every merge with
what it absorbed — and Phase 5's: the Tier 1 / Tier 2 / Tier 3 split, every Tier 3 scenario
named with the degradation judgment that put it there, and every Tier 2 admission with
the evidence that passed its strict threshold. Tier 3 never
enters `progress.md` and a merged-away scenario is never re-drafted, so this is the last
point at which a human sees what was folded or dropped while disagreeing is still cheap.

## Rules
- English, Gherkin in Markdown, DSL only (no technical details in steps)
- One file per category under `tests/`, every scenario carrying the `Tier: ?` marker Phase 5 resolves. After consolidation, the story-wide implemented stack is capped at 10 Tier 1 scenarios and 25 Tier 1 + Tier 2 scenarios; every other eligible scenario goes to Tier 3. Phase 4 merges shared executions without dropping checked facts (`.claude/templates/spec/consolidation-rules.md`).
- **Load tests**: profile-driven against the **Load Challenge Profile** the project declares in `ExpectedLoad.md`. The profile catalog, the relevance filter (including when to skip the file and set `Load = n/a`), the authoring rules and the file layout are all in `.claude/templates/spec/load-test-format.md`
- **Security**: generate stack-aware scenarios only. The relevance filter, checklist rows, merge rule and per-story count are all in `test-spec-format.md` ("05_Security_Tests.md")
