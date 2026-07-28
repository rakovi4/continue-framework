# Hazard Catalogue

A reference of recurring failure classes that slip same-kind gates — a reviewer
reads an artifact, decides it "looks fine", and misses the same blind spot every
time, because the failure is invisible in the happy-path artifact. Consumed by an
agent, not skimmed by a human: long is fine, completeness beats brevity.

The catalogue is split into one file per group (listed below). Each group is a
self-contained unit of review: a focused pass reads this index plus one group
file and applies only that group's classes. The group is the dispatch unit; this
index is the authoritative enumeration of groups.

## How to apply it

- **Apply every group file, from scratch, at every step that references the
  catalogue.** "The whole catalogue" means every group in the list below — a group
  not dispatched is a group not checked. Do not trust an upstream pass to have
  "already handled" a class. A hazard missed at story must still be catchable at
  test-spec and at design-preview. There is no register that marks a class
  resolved — redundant application across steps is the point. Same-kind gates (read
  the artifact, decide it looks fine) are exactly what let these classes through;
  re-deriving each class independently is the defense.
- **One focused pass per group.** Splitting into groups concentrates attention:
  each pass carries only its group's classes, so no class is starved by the length
  of the others. The cost is that completeness is now *enumerated, not visual* —
  dispatch one pass per group in the list below; skip none. Adding a future group
  means a new file **and** a line here, or it goes un-dispatched silently.
- **The dispatch shape, identical at every call site.** One `hazard-scan-agent` per
  group in the **Groups** list — iterate that list, never a hand-copied set, or a
  newly-added group goes unchecked — dispatched **concurrently**, each carrying three
  inputs and no others: the artifact under scan, this index, and its one group file.
  Then one synthesis pass over the seams ("Reason across the seams", below). A call
  site supplies only the artifact — a drafted spec, drafted test files, a drafted
  design, a bug fix's intended change — and points here for the rest rather than
  restating it; four copies of a dispatch shape are four things to drift apart.
- **It is a lens, not a checklist to clear.** For each class, ask "does the work in
  front of me touch this trigger?" — not "can I tick this box?". A class that does
  not apply costs one sentence to dismiss. A class that applies but is awkward to
  test is the one that ships the incident.
- **A dead group is dismissed as a block, not skipped silently.** When the artifact's
  altitude means an entire group's triggers cannot fire — a usecase-level design
  against `hz-08` (client / frontend), say — dismiss that whole group with one explicit
  "out of altitude here" line, exactly as a single non-applying class is dismissed. A
  group that was genuinely checked and returned nothing and a group that was never
  dispatched look identical in the result; the explicit block dismissal is the only
  thing that tells them apart, so a dead group never quietly becomes a habit of
  skipping.
- **The forced guard is the deliverable.** A class is "handled" only when a specific
  test exists that would FAIL on the hazard. Vague mitigations ("validate input",
  "handle errors") are not guards. If you cannot name a test that goes red on the
  bad behaviour, the class is not covered.
- **Triggers are deliberately broad.** When unsure whether a trigger fires, treat it
  as firing and check the forced guard. False positives cost a scenario; false
  negatives cost an incident.
- **A fired GAP is tiered, not automatically critical-path.** The forced guard stays
  mandatory — a named test that would go red. *When* it is delivered is then decided
  by the ladder in `.claude/templates/spec/tier-ladder.md`, which can place a guard
  in Tier 2, or in Tier 3 when the impact is a bounded, acceptable degradation.
  Some groups are pinned above Tier 3 by that file's floor and can never take the
  Tier 3 exit; `tier-ladder.md` holds the authoritative list. This is a **destination** rule, never a *strictness*
  rule: a group pass does not soften a verdict, drop a class, or pre-assign a tier
  because a lower tier now exists — it reports the GAP, the fired trigger, and the
  guard, tagged with its group id, and tiering happens afterwards in a separate pass
  that reads the whole scenario set at once. A pass that starts triaging its own
  findings by importance is re-introducing the blind spot the catalogue exists to
  close.
- **Reason across the seams.** A few classes share a setup and differ only in the
  assertion — Concurrency vs. Lost update (same group), and Transaction boundary
  vs. Idempotency vs. Async delivery (the last spanning groups 2 and 3). Where group
  passes run independently, a synthesis step must reconcile their verdicts so a seam
  hazard isn't dropped between two passes each assuming the other owned it. The
  synthesis step takes two inputs: the seams named here, **and** every seam an
  individual group pass flagged (a pass that meets a seam stays in its own group and
  flags it rather than resolving it — so its flags must be collected, not discarded).
  For each seam it names the single guard that must cover the cross-group hazard and
  confirms one side actually carries it. A seam is closed only when a named guard would
  go red on that hazard — never by each group assuming the other owned it.
- **The catalogue grows by hand.** When a new scar appears, abstract it to a generic
  class and add it to the right group file (or a new group file plus a line in the
  list below), via `/prompt-update` — never an automated loop.
- **A new group obligates a re-scan of frozen specs.** Each scan records the group set
  it covered (the **Groups** list at scan time) in its scan report. Later steps re-scan
  the whole catalogue from scratch only while a spec is still being worked — so a spec
  scanned against groups 1–7 and then frozen (its whole spec phase done) is never
  re-checked against a group 8 added afterward. Adding a group is therefore the trigger
  to re-scan the specs that were frozen under the old set against the new group; the
  growth step (`/prompt-update`, above) owns that re-scan. A spec whose recorded group
  set is a strict subset of the current **Groups** list is stale until re-scanned.

Each entry in a group file: **Trigger** (when the work touches this class),
**Mitigation** (what the design must do), **Forced guard** (the test/check that
must exist and would fail on the hazard before the work is considered covered).

## Groups

Every group has a stable **id** matching its file prefix. The id is the group's
name in prose *and* the provenance token a scan carries onto whatever its GAP
becomes (`.claude/templates/spec/tier-ladder.md`). Ids are permanent: a retired
group's id is never reused, or tokens already written into frozen test files would
silently change meaning.

| Id | Group | Classes |
|---|---|---|
| `hz-01` | [Money, numbers & representation](01-money-numbers-representation.md) | mixed units, numeric edges & precision in transit, text encoding/normalization/locale |
| `hz-02` | [Re-run safety, ordering & atomicity](02-rerun-safety-ordering-atomicity.md) | idempotency (both directions), compute-then-commit, transaction boundary, external-call failure, deadline budgets |
| `hz-03` | [Concurrency, consistency & distribution](03-concurrency-consistency-distribution.md) | multi-instance races, lost update, read-after-write, async delivery |
| `hz-04` | [Data lifecycle & schema](04-data-lifecycle-schema.md) | state-machine correctness, schema/contract evolution, destructive ops |
| `hz-05` | [Request boundary & input](05-request-boundary-input.md) | authorization/IDOR, mass assignment, absent-vs-null, output encoding/injection, fail-open defaults |
| `hz-06` | [Scale & resource limits](06-scale-resource-limits.md) | unbounded size, work amplification, resource exhaustion, retry storms, pagination stability |
| `hz-07` | [Time, operability & disclosure](07-time-operability-disclosure.md) | time/timezone/expiry, partial-failure visibility, config drift, secret/PII disclosure |
| `hz-08` | [Client / frontend](08-client-frontend.md) | client-side action safety, client-as-untrusted & unsaved state |
