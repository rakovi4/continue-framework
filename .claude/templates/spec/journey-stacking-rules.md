# Journey Stacking Rules

Consolidation answers whether facts share one execution. Journey stacking answers
whether separate executions are checkpoints in the same user's path to the story's
value. Run this pass after consolidation and before tiering.

## Build the delivery unit

1. Trace the primary journey from the earliest in-scope entry through first value,
   the story's limiting or blocking state, value capture when it is in scope, and the
   value restored or continued afterward.
2. In each category file, map every primary-journey checkpoint to one surviving
   scenario heading. Cross numbered sections to do it. A later `Given` that advances
   the same user to the next journey state is a transition, not a new delivery cycle.
3. Preserve every step, assertion, and provenance token. RED may implement the stacked
   heading as several focused executable cases; those cases do not create more progress
   blocks.
4. Split hardening branches before stacking when they would change the core journey's
   tier. Duplicate actions, retries, races, partial failures, abuse, precision edges,
   and recovery variants stay separate unless the primary promise requires them.

Do not split a journey because checkpoints concern different topics, sections,
endpoints, components, states, or implementation work. Split only for a different
actor's journey, an alternative branch, or independently valuable behavior rather than
a later checkpoint on the same path.

## Gate before tiering

Produce a journey ledger containing each primary checkpoint and, for every category
that observes it, the one surviving heading that owns it. Stop when either condition is
true:

- one category maps consecutive primary checkpoints to multiple headings;
- a core heading still contains hardening that would move it out of Tier 1.

After tiering, read Tier 1 in journey order. It must demonstrate the complete primary
promise, not merely isolated pieces of it.
