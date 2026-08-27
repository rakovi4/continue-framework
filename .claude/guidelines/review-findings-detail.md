# Boundary Review Findings — Detail

Companion to `review-passes-detail.md`. It owns the lifecycle of a `NEEDS_CYCLE`
finding after the boundary passes have returned.

An admitted finding remains a proposal until the user explicitly agrees. Do not
write its scenario, marker, or progress block before consent; silence and a declined
proposal leave the plan unchanged.

## Mid-cycle findings use the Tier 2 threshold

A `NEEDS_CYCLE` follow-up that becomes a **net-new scenario** enters a story whose
scenarios were already sorted by consequence of failure at spec time. `tiering-agent`
runs once, at `/test-spec`, so resolve the marker here, never as `Tier: ?`.

A net-new review scenario never enters Tier 1. Admit it to Tier 2 only when the case
is concretely important in production, not extraordinarily rare, and severe in
consequence. Otherwise — including doubt — put it in `tier3/` with the missing Tier 2
evidence named. A BLOCK verdict establishes severity only; it does not establish the
other two conditions. Provenance from `/design-preview` records the hazard route and
does not force a tier.

**A marker alone changes no ordering.** After consent, write a Tier 2 test and its
progress block together in one commit, with the steps at the end of the matching
tier/category section. Write a Tier 3 test only under `tests/tier3/`, with no progress
block. The boundary cadence guarantees no cycle is in flight.

**A Tier 2 finding can land after its item was flipped to Done.** If consent after the
final boundary creates implemented work, the plan commit reopens the task folder or
story row and makes the newcomer's first step the plan's only `[~]`. A Tier 3 record
does not reopen an item because it creates no steps.

Scope: a tier-major story. An untiered story keeps its existing untiered behavior.
