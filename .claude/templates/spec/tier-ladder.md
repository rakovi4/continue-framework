# Scenario Tiers — Ladder, Marker & Floor

The vocabulary for splitting a story's scenarios by **consequence of failure**, so
that a story has a point at which it reads "the feature works, the rest is
hardening".

Definitions only. This file names the tiers, the marker that records them, and the
classes pinned above the bottom tier. *Which* pass assigns a tier, and how
`progress.md` and `stories.md` track it, live elsewhere. Read this file whenever
you assign, re-assign, or read a tier.

## The ladder

Tier is decided first by what happens if the scenario's behaviour is broken in
production, then by the delivery ceilings below. Category never decides tier.

| Tier | If this scenario fails… | Destination |
|---|---|---|
| **1** | the primary user's happy path does not work | `progress.md`, before any Tier 2 |
| **2** | the happy path works, but a selected production corner case is unsafe or incorrect | `progress.md`, after all of Tier 1 |
| **3** | lower-priority coverage is recorded but deferred | `tier3/` — never enters `progress.md` |

Tier 1 is "demonstrable feature"; Tier 2 is "trustworthy feature". `tier3/` holds
what `extended/` has always held — scenarios that are recorded and not built —
under a name that matches the ladder.

`extended/` directories that already exist are **not migrated** — they keep their
name, their `_Extended` filenames, and their standing, and `tier3/` applies to
stories tiered from here on. Renaming in-flight artifacts churns the audit trail
for nothing: neither directory is ever implemented, so both denote one standing.

Two readings that are **not** the ladder:

- **Not by category.** Category says which file a scenario lives in, never which
  tier. A security scenario is Tier 1 only where the guarantee *is* the promise —
  in a sharing story, "user A cannot open user B's board" is the feature itself.
  On a login story it is not: login demonstrably works without rate limiting,
  password hashing, or injection guards, and safety-rather-than-function is Tier
  2's definition. Load reaches Tier 1 only when the scale is the promise — a bulk
  import, an export over a large corpus. A backend scenario can be Tier 2.
- **Not by difficulty.** Awkward to test is the reason a hazard ships, not a
  reason to demote it.

### Ambiguity resolves toward implementation

The two boundaries do not cost the same, so they do not tie-break the same way:

- **Unsure between 1 and 2 → choose 2.** Both tiers get implemented; a wrong call
  costs ordering only, and it is self-correcting the moment someone tries to demo
  the feature.
- **Unsure between 2 and 3 → prefer 2 while capacity remains.** Once the combined
  ceiling is reached, compare the candidates and keep the higher-consequence one
  in Tier 2. Pinned scenarios always outrank unpinned candidates.

Tier 3 therefore requires a judgment: name the degradation or corner case being
deferred and why it ranks below the Tier 2 scenarios selected for this story.

## The marker

`progress.md` is derived, not authored: bootstrapping regenerates it from the test
files. A tier recorded only in `progress.md` would evaporate at the next
re-bootstrap and the ordering would silently flatten. So the **test files are the
source of truth.**

Each scenario in `tests/*.md` carries its marker on its own line, immediately
after the `### N.M Title` heading and separated from it by one blank line:

```markdown
### 3.2 A duplicate webhook delivery charges once

Tier: 2 (hz-02)
```

The marker is written in two moves by two different passes, because the two halves
are known at different times. Authoring knows the **route** the moment it generates
the scenario; the tier is comparative and cannot be settled until the whole set
exists. So authoring stamps its tokens against a literal `?`:

```markdown
### 3.2 A duplicate webhook delivery charges once

Tier: ? (hz-02)
```

and the tiering pass substitutes the tier, keeping every token verbatim. Every
drafted scenario gets this line, including the route-less ones the provenance
table's *(absent)* row covers — those carry a bare `Tier: ?`. That is what makes
`?` a real value rather than a placeholder convention: `grep -F 'Tier: ?'` over a
tiered story returns exactly the scenarios the pass never reached, which a missing
marker line cannot distinguish from a scenario nobody stamped. Use `-F`: in ERE
and in `rg`, a bare `?` quantifies the preceding space and matches every marker.

**Every scenario carries a marker, in every tier — including the ones in
`tier3/`.** The directory is not the marker. A Tier 3 marker additionally carries
the judgment that put it there:

```markdown
### 4.1 Board export truncates past 10 000 rows

Tier: 3 (hz-06) — export is an admin convenience; truncation is visible in the UI
and the full data stays reachable through the API.
```

Provenance is what the floor below is read from, so a scenario that shed its
token on the way into `tier3/` is one the floor can never be checked against
again — and `tier3/` is exactly where an unchecked mis-tier does its damage,
because nothing there is ever built. Keeping the marker makes auditing the bucket
a grep instead of a re-reading.

### Provenance

Provenance records **which route produced the scenario** — not merely that a scan
found it. Every route stamps its token at the moment it generates the scenario.

| Token | Stamped by |
|---|---|
| `hz-NN` | the hazard-catalogue group the scenario belongs to, whether a scan GAP raised it or a checklist rule mapping to that group generated it — `hz-01` … `hz-08`, enumerated in `.claude/guidelines/hazard-catalogue/_index.md` |
| `sec:{row}` | the security-checklist row in `test-spec-format.md` that produced it — every row stamps; `sec:IDOR` and `sec:JWT` are the two the floor pins |
| *(absent)* | derived from the story spec, matching no checklist row and no hazard group |

Multiple tokens are comma-separated: `Tier: 1 (hz-02, sec:IDOR)`.

Absent means **no route claimed it**, not that its route is unknown: a route that
fired always stamps. Silence is therefore not permission — it is the story-spec
case, and nothing more.

A scan raises a GAP only where a guard is *missing*. If scan GAPs were the only
emitter, provenance would tag the scenarios nobody thought of and leave the
well-drafted ones bare — inverting exactly what the floor needs. This is why
checklists stamp too: the Side-Effect & Idempotency checklist stamps `hz-02`, the
security checklist stamps `sec:{row}`.

The two producers are independent and their coverage overlaps — `hz-05` also owns
authorization/IDOR. A scenario reached through the security checklist carries
`sec:{row}`, one reached through a hazard scan carries `hz-NN`, one found by both
carries both. Record every route; never collapse two routes into one token.

## The pinned floor

A tier assignment is a judgment call, and the reviewers who would catch a bad one
are correlated — they read this same ladder under the same "keep Tier 1 small"
pressure. So the classes where a mis-tier is catastrophic *and* mechanically
identifiable are not left to judgment at all:

> **Cannot be Tier 3:** any scenario whose provenance includes `hz-01` (money,
> numbers & representation), `hz-02` (re-run safety, ordering & atomicity),
> `hz-05` (request boundary & input — authorization/IDOR, mass assignment,
> fail-open defaults), `sec:IDOR`, or `sec:JWT`.

Two properties make this worth having:

- **It is mechanical.** The check reads a token that is already on the scenario.
  It never asks whether *this particular* money bug would be bad.
- **It forbids Tier 3 only.** Tier 1 versus Tier 2 stays a free choice for these
  scenarios. The floor guarantees the guard gets *built*, not that it is built
  first.

**What the floor does not cover.** It is a backstop over the classes a token can
identify, not a complete guard over everything irreversible. `hz-03` (lost update)
and `hz-04` (destructive ops, schema evolution) can fail unrecoverably and are
deliberately *not* pinned — a destructive-op guard on an admin-only path is a
plausible Tier 3, and pinning the whole group would swallow the exit. Those rest
on the ladder itself, where comparative consequence determines which scenarios
fit in Tier 2 before the combined ceiling is reached.

## Hard delivery ceilings

The implemented stack has two mandatory story-wide ceilings, counted after
consolidation across every category:

- **Tier 1: at most 10 scenarios.** Keep only distinct
  executions needed to demonstrate the primary user's happy path.
- **Tier 1 + Tier 2: at most 25 scenarios.** Fill the
  remaining slots with the highest-consequence happy-path variants and corner
  cases. Move every other eligible scenario to Tier 3.

These are hard output constraints, not diagnostic targets. Never weaken or delete
an assertion to meet them. Consolidate only genuinely shared executions, rank
distinct executions comparatively, and place overflow in Tier 3 with its explicit
deferral judgment.

The pinned floor still wins over the Tier 3 exit. If more than ten distinct
executions are genuinely required for the primary happy path, or Tier 1 plus all
pinned scenarios exceeds 25, the set is infeasible: write nothing and report that
the story must be narrowed. Never hide an infeasible story by misclassifying a
happy-path execution or a pinned guard.
