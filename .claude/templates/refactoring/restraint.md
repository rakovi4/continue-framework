# Restraint — when NOT to extract

A refactoring that adds net lines or indirection without adding clarity is a bad
refactoring. Both detectors (when deciding whether a candidate is a real smell)
and the fixer (before applying an extraction) apply these guardrails — a
"partial overlap / NO ACTION" verdict is often the correct one:

These guardrails govern abstraction changes, not readable formatting. Restoring
line breaks and spacing may add lines without adding indirection; never use
restraint to waive A60 or retain compressed code. Judge method size only after
formatting, and keep blank lines between coherent phases of a linear recipe.

## Evidence for retaining a candidate

Use the same standard for production, presentation, test, and helper code. For
each retained candidate, record its check ID, source range, responsibility, and
the concrete extraction considered. Explain why that extraction would obscure
one responsibility or change observable behavior, and why a smaller safe
extraction does not resolve the smell. A detector must return these decisions
alongside its fix list; the fixer must reassess them after changes.

For a function over 10 formatted lines, enumerate its phases and abstraction
levels. Distinct validation, transition, transport, mapping, and assertion phases
must be decomposed. Shared values can become parameters; an asynchronous boundary
requires preserving order, not retaining all surrounding behavior in one method.
The labels "cohesive", "lifecycle stage", "recipe", "frontend", and "test" alone
are not evidence. Neither literal formatting nor passing tests waives mixed
responsibilities. A single declarative literal or flat scenario of named steps
may remain intact only with the same per-candidate evidence.

Do not satisfy one check by making another worse: adding mutable accumulators,
nested branches, redundant snapshots, or forwarding helpers requires reassessing
complexity and ownership. Unsupported KEEP decisions block a clean result.

- **Don't over-fragment into single-use helpers.** Extracting several tiny 1–3
  line helpers each used once usually makes the file *longer* without adding
  clarity. Inline single-use helpers; extract only when the helper names a
  non-obvious computation, is called from 2+ places, or genuinely reads as a
  table-of-contents for the parent's flow.
- **Leave short, builder-style test setup methods alone.** When two
  `given*`/setup methods share most of a builder body but differ in
  name/parameters/intent, keep them as independent linear bodies. Each should
  read top-to-bottom as a complete, self-documenting recipe; consolidating into
  an overload pair with extracted helpers that thread a builder type adds
  indirection without clarifying intent. This restraint applies to *test setup*
  duplication only — NOT to production duplication, assertion-logic duplication,
  or cross-Fake duplication.
- **Don't introduce boolean-return + try/catch hybrids.** A method like
  `boolean tryDoThing(...)` that wraps a side-effecting call in try/catch and
  returns a flag hides the failure in a boolean the caller must branch on anyway.
  Instead structure it as `try { call; return success; } catch { return
  alternate; }` — return the result directly from each path so the branching
  disappears.
- **Mirror existing in-file patterns.** When a sibling method in the same file
  already has the right shape, the new/refactored method should follow it —
  don't invent a different abstraction for symmetric logic.
