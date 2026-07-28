# Scenario Tiers — Ladder, Marker & Floor

The vocabulary for splitting a story's scenarios by **consequence of failure**, so
that a story has a point at which it reads "the feature works, the rest is
hardening".

Definitions only. This file names the tiers, the marker that records them, and the
classes pinned above the bottom tier. *Which* pass assigns a tier, and how
`progress.md` and `stories.md` track it, live elsewhere. Read this file whenever
you assign, re-assign, or read a tier.

## The ladder

Tier is decided by what happens if the scenario's behaviour is broken in
production — never by category, never by count.

| Tier | If this scenario fails… | Destination |
|---|---|---|
| **1** | the feature does not work at all for its primary user | `progress.md`, before any Tier 2 |
| **2** | the feature works, but the product is unsafe or incorrect under conditions that *will* occur in production | `progress.md`, after all of Tier 1 |
| **3** | the impact is a known, bounded, acceptable degradation | `tier3/` — never enters `progress.md` |

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
- **Unsure between 2 and 3 → choose 2.** Tier 3 is never implemented. A wrong call
  there is not a delay, it is a scenario silently deleted from the plan.

Tier 3 therefore requires a *positive* judgment — you must be able to name the
degradation and say why it is acceptable. "Probably fine" is a Tier 2.

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
on the ladder itself, where the 2-vs-3 tie-break above is what protects them:
"probably fine" is a Tier 2.

## No targets — not a count, not a percentage

Tier 1 has **no budget of any kind.**

A target count makes a genuine must-have get dropped to hit it. A percentage does
the same and additionally breaks at small N — "20% of Tier 1" is not an
instruction anyone can follow on a nine-scenario story. Tier 1 is exactly what the
ladder selects, however many that turns out to be.

The resulting size is still information — and it is **reported, never acted on.**
The tiering pass states the split it produced and stops. It does not split a
story, does not re-run itself, and does not demote a scenario: all three are
calls made with the whole story in view, by a human, after the pass has finished.

Two readings are worth naming in that report, and the number alone cannot tell
them apart:

- the **story** may be too big to deliver in one piece;
- the **ladder** may not have been applied — everything got swept into Tier 1.

Both can be true at once, which is why neither is wired to an automatic fix.
Neither is ever a licence to move a scenario down a tier: an oversized Tier 1
that was sorted correctly is a fact about the story, and shrinking it by
re-tiering only hides that fact.

On splitting specifically: a split is a real fix only when the story contains two
separable user-visible features. Scenario count does not tell you whether it
does. Splitting one indivisible feature into two stories yields two stories
neither of which is demonstrable on its own — the exact outcome the ladder exists
to prevent.

This is the lesson the category counts in `test-spec-format.md` already carry —
they describe expected output, they are not budgets — applied to the new
boundary.
