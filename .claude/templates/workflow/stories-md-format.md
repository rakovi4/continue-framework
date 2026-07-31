# stories.md Format — Phase, Tests, and % Columns

How `/continue` updates a story's row in `ProductSpecification/stories.md` after a
`progress.md` commit. `/continue` points here; this file holds the rules. **Stories
only** — tasks are never tracked in `stories.md`.

The file has three tables (**In Progress**, **Backlog**, **Done**), each with columns
`# | Story | Spec | Back | Intg | Front | Sec | Load | Infra | Tests | %`. The seven
phase columns are `Spec` plus the six test categories (`Back`, `Intg`, `Front`, `Sec`,
`Load`, `Infra`).

## Two shapes, by whether the story is tiered

A story's `progress.md` is either **tier-major** — sections carry a `## Tier N —`
prefix ([`progress-format.md`](progress-format.md)) — or **untiered**: flat category
sections, the pre-tiering shape. The two produce different cell formats, and both stay
valid indefinitely. `/continue` never migrates a story from one to the other; `/retier`
converts, and only while no checkbox below the story's `## Spec` section is `[x]`.

### Untiered stories (flat)

Today's format, unchanged and permanent:
- **Phase columns** hold a single status value (below).
- **Tests** = `done/total`, where **Total** = number of `### ` scenario headings in
  `progress.md` (not `## ` section headers) and **Done** = scenarios whose every
  checkbox is `[x]` or `[S]`.
- **%** = `round(done / total * 100)`.

### Tier-major stories (split)

- **The six test-category phase columns** (`Back`, `Intg`, `Front`, `Sec`, `Load`,
  `Infra`) split on `/` into per-tier status, `T1/T2` (e.g. `✅/🔧` = Tier 1 done, Tier 2
  in progress). **All-left-`✅` reads as shippable**: every phase's Tier 1 slot done means
  the demonstrable feature is delivered, before any Tier 2 hardening. Tier-asymmetric
  cells are legal — `n/a/🔧` is a phase with no Tier 1 scenarios but Tier 2 ones; `🔧/n/a`
  the reverse.
- **`Spec` is never split.** The `## Spec` section is untiered and holds no `### `
  scenarios in either tier (`progress-format.md`), so `Spec` always takes a single value
  derived from that section — and is never `n/a`-collapsed, since a completed spec is
  `✅`, not "not applicable". Only the six test-category columns are split.
- **A test-category phase with no scenarios in *either* tier collapses to a single
  `n/a`**, not `n/a/n/a`, so `load-test-format.md`'s "set `Load = n/a` in `stories.md`"
  instruction still reads correctly under split columns. This is the one split-eligible
  cell that renders unsplit.
- **Tests** = `T1done/T1total · T2done/T2total` — the two tiers counted separately,
  each `done`/`total` computed exactly as for untiered. The `harvest` checkbox is not a
  scenario (it carries no `### ` heading; `progress-format.md`), so it is in neither
  count.
- **%** tracks **Tier 1 until it reaches 100%, then Tier 2**: `round(T1done/T1total*100)`
  while Tier 1 is incomplete, then `round(T2done/T2total*100)`. The single number answers
  "how close to shippable", then "how close to fully hardened". When Tier 2 is empty
  (`T2total = 0`), % shows Tier 1's progress throughout and reaches `100%` when Tier 1
  completes — the story still is not Done until `harvest` is checked (see completion). A
  tiered story always has **at least one Tier 1 scenario** — Tier 1 means the feature does
  not work at all for the primary user without it (`.claude/templates/spec/tier-ladder.md`)
  — so `T1total ≥ 1` and the formula never divides by zero; `T1total = 0` is not a
  reachable state for a tiered story.

## Phase column values

The same set for both shapes; each side of a split cell takes one, derived from that
tier's section(s) for that phase:
- `✅` — every checkbox is `[x]` or `[S]`
- `🔧` — the slot is the active or up-next slot: it has a `[~]` item, or it has `[ ]`
  items and every prior slot in lifecycle order is `✅` (see below)
- `—` — the section exists, is all `[ ]`, and is *not* yet the active/up-next slot
- `n/a` — the phase has no scenarios there (test spec says "No tests", or the relevance
  filter skipped the file)
- `·` — no story folder or no progress file exists

`🔧` and `—` both describe an all-`[ ]` section; the lifecycle heuristic is the
tiebreak between them.

**Lifecycle ordering**: Spec → Backend → Integration → Frontend → Security → Load →
Infra. A slot becomes `🔧` when it is the current active phase (has `[~]` items) OR it
still has `[ ]` items and all prior slots are `✅`. For a tier-major story this ordering
runs **within a tier first**: all of Tier 1's slots resolve, then `harvest`, then Tier 2.
So a Tier 2 slot stays `—` until `harvest` completes — it is not "up next" while Tier 1
is still in flight, even though its Spec phase is `✅` — and only then becomes `🔧`.

## Story completion

A story is complete only when **every checkbox in `progress.md` is `[x]` or `[S]`** — not
when the scenario counts alone read full. The scenario counts ignore non-scenario
work-unit checkboxes such as `harvest`, which carries no `### ` heading, so a story with
an empty Tier 2 can reach `Tests = T1total/T1total · 0/0` and `% = 100%` while
`- [ ] harvest` is still open: full by count, not yet done. Gate the move on the
checkboxes, never on the count or the percentage. When complete, move the row from **In
Progress** to **Done**, keeping every column value intact.

**The row move and the folder move are one act.** The same behavior commit that lands the
row in **Done** also archives the story folder:
`ProductSpecification/stories/NN-story-name/` → `ProductSpecification/stories/done/NN-story-name/`,
under the same staged-`progress.md` gate the task archive uses (`/continue` SKILL.md step 11).
Both halves or neither: a row in **Done** whose folder still sits beside the active ones, or an
archived folder whose row still reads In Progress, is a half-closed story that no single file
reports as wrong. A mid-cycle review finding that reopens the story reverses both in its
`review-fix:` commit.

## When to update

After every `progress.md` commit for a story, in the same commit. Recount Tests and % from
the just-written `progress.md`. Do NOT add a Total row — it causes merge conflicts.
