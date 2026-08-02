# Boundary Review Findings — Detail

Companion to `review-passes-detail.md`. It owns the lifecycle of a `NEEDS_CYCLE`
finding after the boundary passes have returned.

An admitted finding remains a proposal until the user explicitly agrees. Do not
write its scenario, marker, or progress block before consent; silence and a declined
proposal leave the plan unchanged.

## Mid-cycle findings default to Tier 2

A `NEEDS_CYCLE` follow-up that becomes a **net-new scenario** enters a story whose
scenarios were already sorted by consequence of failure at spec time. `tiering-agent`
runs once, at `/test-spec`, so the resolved default is **Tier 2**, never `Tier: ?`.
That is also the usual consequence: review reads green work and normally finds a
production-condition gap, not a feature that fails its primary user.

**Usually, not always — re-read the ladder.** A BLOCK verdict means data loss, double
effect, leak, corruption, or another broken core invariant. That is Tier 1: the feature
does not work for its primary user. Promotion is expected. Demotion to `tier3/` requires
the ladder's positive judgment naming why the degradation is acceptable, and is forbidden
when a mid-cycle hazard scan stamped a floor-pinned provenance token.

The default substitutes for a mechanical floor: review findings are deliberately
open-ended and carry no hazard provenance token unless `/design-preview` step 2a fires a
catalogue group. A wrong Tier 1-vs-2 call costs ordering and can self-correct; an unguarded
Tier 3 scenario is never built.

**A marker alone changes no ordering.** After consent, write the test and its progress
block together in one commit. Put the steps at the end of the matching tier/category
section. The boundary cadence guarantees no cycle is in flight; the plan-integrity
check then guards marker-to-plan agreement.

**A finding can land after its item was flipped to Done.** If consent after the final
boundary creates new work, the plan commit reopens the task folder or story row and
makes the newcomer's first step the plan's only `[~]`. Leaving new steps in a
completed item makes them unreachable.

Scope: a tier-major story. An untiered story keeps its existing untiered behavior.
