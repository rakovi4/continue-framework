# Scenario Tiers — Ladder & Marker

The vocabulary for splitting a story's scenarios by **consequence of failure**, so
that a story has a point at which it reads "the feature works, the rest is
hardening".

Definitions only. This file names the tiers, the marker that records them, and the
provenance of generated scenarios. *Which* pass assigns a tier, and how
`progress.md` and `stories.md` track it, live elsewhere. Read this file whenever
you assign, re-assign, or read a tier.

## The ladder

Tier is decided first by what happens if the scenario's behaviour is broken in
production, then by the delivery ceilings below. Category never decides tier.

| Tier | If this scenario fails… | Destination |
|---|---|---|
| **1** | the primary user's happy path does not work | `progress.md`, before any Tier 2 |
| **2** | an important, production-realistic corner case has a severe consequence | `progress.md`, after all of Tier 1 |
| **3** | every other non-happy-path case is recorded but deferred | `tier3/` — never enters `progress.md` |

Tier 1 is "demonstrable feature"; Tier 2 is "trustworthy feature". `tier3/` holds
what `extended/` has always held — scenarios that are recorded and not built —
under a name that matches the ladder.

Tier 1 is derived only from the story's primary-user happy path. Scenarios generated
by hazard or security routes never enter it. If a finding exposes an incomplete happy
path, amend the story requirement first; only the resulting story-derived scenario
may be Tier 1.

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

### Tier 2 is a strict exception

The two boundaries do not cost the same, so they do not tie-break the same way:

- **Unsure whether a scenario is happy path → choose 2.** Tier 1 contains only the
  unambiguous minimum needed for the primary user to complete the story's promise.
- **Unsure between 2 and 3 → choose 3.** Tier 2 requires all three facts to be
  concrete: the case matters in production, it is not extraordinarily rare, and
  failure has a severe consequence. Missing or doubtful evidence for any fact
  sends the scenario to Tier 3.

Tier 3 is the default destination for non-happy-path coverage. Its marker names
the degradation or corner case being deferred and which Tier 2 condition was not
established.

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

Provenance preserves why a generated scenario exists. Keeping it on Tier 3
markers makes the deferred bucket auditable without re-running the catalogue.

### Provenance

Provenance records **which route produced the scenario** — not merely that a scan
found it. Every route stamps its token at the moment it generates the scenario.

| Token | Stamped by |
|---|---|
| `hz-NN` | the hazard-catalogue group the scenario belongs to, whether a scan GAP raised it or a checklist rule mapping to that group generated it — `hz-01` … `hz-08`, enumerated in `.claude/guidelines/hazard-catalogue/_index.md` |
| `sec:{row}` | the security-checklist row in `test-spec-format.md` that produced it — every row stamps |
| *(absent)* | derived from the story spec, matching no checklist row and no hazard group |

Multiple tokens are comma-separated: `Tier: 2 (hz-02, sec:IDOR)`.

Absent means **no route claimed it**, not that its route is unknown: a route that
fired always stamps. Silence is therefore not permission — it is the story-spec
case, and nothing more.

A scan raises a GAP only where a guard is *missing*. Checklists stamp too so
provenance describes every route that generated a scenario, not only omissions
found by the scan: the Side-Effect & Idempotency checklist stamps `hz-02`, and the
security checklist stamps `sec:{row}`.

The two producers are independent and their coverage overlaps — `hz-05` also owns
authorization/IDOR. A scenario reached through the security checklist carries
`sec:{row}`, one reached through a hazard scan carries `hz-NN`, one found by both
carries both. Record every route; never collapse two routes into one token.

## Hard delivery ceilings

The implemented stack has two mandatory story-wide ceilings, counted after
consolidation across every category:

- **Tier 1: at most 10 scenarios.** Keep only distinct
  executions needed to demonstrate the primary user's happy path.
- **Tier 1 + Tier 2: at most 25 scenarios.** Fill the
  remaining slots only with corner cases that pass Tier 2's strict three-part
  test. Capacity is a ceiling, not a target; never fill it with doubtful cases.
  Move every other eligible scenario to Tier 3.

These are hard output constraints, not diagnostic targets. Never weaken or delete
an assertion to meet them. Consolidate only genuinely shared executions, rank
distinct executions comparatively, and place overflow in Tier 3 with its explicit
deferral judgment.

If more than ten distinct executions are genuinely required for the primary
happy path, the set is infeasible: write nothing and report that the story must be
narrowed. Never hide an infeasible story by misclassifying a happy-path execution.
