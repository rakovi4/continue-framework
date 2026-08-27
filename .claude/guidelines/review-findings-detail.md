# Boundary Review Findings — Detail

Companion to `review-passes-detail.md`. It owns the lifecycle of a `NEEDS_CYCLE`
finding after the boundary passes have returned.

An admitted finding remains a proposal until the user explicitly agrees. Do not
write its scenario, marker, or progress block before consent; silence and a declined
proposal leave the plan unchanged.

## Mid-cycle findings default to Tier 2

A `NEEDS_CYCLE` follow-up that becomes a **net-new scenario** enters a story whose
scenarios were already sorted by consequence of failure at spec time. `tiering-agent`
runs once, at `/test-spec`, so resolve the marker here, never as `Tier: ?`.

A net-new review scenario defaults to Tier 2. Re-read the ladder before writing it:
use Tier 1 when the finding means the feature does not work for its primary user,
and Tier 3 only with an explicit deferral judgment. Provenance added by
`/design-preview` records the hazard route and does not replace this review policy.

**A marker alone changes no ordering.** After consent, write a Tier 1 or Tier 2 test
and its progress block together in one commit, with the steps at the end of the
matching tier/category section. Write a Tier 3 test only under `tests/tier3/`, with
no progress block. The boundary cadence guarantees no cycle is in flight.

**An implemented finding can land after its item was flipped to Done.** If consent
after the final boundary creates Tier 1 or Tier 2 work, the plan commit reopens the
task folder or story row and makes the newcomer's first step the plan's only `[~]`.
A Tier 3 record does not reopen an item because it creates no steps.

Scope: a tier-major story. An untiered story keeps its existing untiered behavior.
