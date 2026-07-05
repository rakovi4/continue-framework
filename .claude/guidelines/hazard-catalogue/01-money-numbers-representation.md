# Money, numbers & representation

> Apply with `_index.md`. Each entry: **Trigger** / **Mitigation** / **Forced guard**.

## Money & mixed units

- **Trigger.** A value carries a unit with more than one representation — major vs.
  minor currency units, a quantity some boundary scales and another does not, a
  percentage stored as `0.07` here and `7` there.
- **Mitigation.** Pin one canonical unit system-wide; convert only at the outermost
  boundary where the foreign unit is proven by the external contract, not by a field
  name. A name that says "minor units" is not evidence of the unit.
- **Forced guard.** Pin the on-the-wire unit of every external boundary the value
  crosses, plus a round-trip test (inbound → store → outbound) whose fixture differs
  in the two representations (not `0`, not `1`, not a self-equal value) so a dropped
  or extra conversion factor changes the asserted magnitude.

## Numeric edges & precision in transit

- **Trigger.** Arithmetic on supplied numbers (division, rounding, accumulation, type
  conversion, equality comparison) once the unit is fixed — cross-unit mismatch is
  *Money & mixed units*. Also any precision-critical value (large integer id, exact
  decimal, high-precision timestamp) crossing a serialization format with a narrower
  number model.
- **Mitigation.** Exact types (decimal) for money and any value where rounding must be
  defined; never compare floats for equality; define rounding direction explicitly;
  guard division-by-zero and overflow at the boundary. Carry large ids / exact
  decimals as strings across number-lossy formats — a format that parses every number
  as a double loses precision past 2^53 and drops decimal scale.
- **Forced guard.** Tests at zero, at a negative (or proof negatives are rejected), at
  the value that overflows the chosen type if accumulation can reach it, and at the
  exact rounding half-way point (2.5 vs 3.5 — banker's and half-up disagree there).
  A round-trip test that an id above 2^53 and a decimal like `100.00` survive
  serialize→deserialize byte-exact, scale included. "Maximum expected" is not a
  number — name the actual type/domain limit.

## Text: encoding, normalization & locale

- **Trigger.** Text is encoded/decoded, length-limited, truncated, compared,
  deduplicated, or used as a key, where bytes ≠ code points ≠ graphemes — multibyte
  content (emoji, CJK, combining accents), a charset decode, a case-fold, or a
  number/date parsed/formatted under an ambient locale.
- **Mitigation.** Pin one charset (UTF-8) explicitly at every encode/decode; normalize
  to one form (NFC) before storing, comparing, hashing, or keying; truncate by
  grapheme, never raw bytes; pin an invariant locale for all machine
  parsing/formatting/case-folding, using a display locale only at the human edge.
- **Forced guard.** A store→read round-trip of multibyte text asserting byte-exact
  equality after normalization; a truncation test where the limit falls mid-sequence
  asserting still-valid text (no replacement char, no split grapheme); a
  parse/case-fold test under a hostile non-default locale (comma-decimal, Turkish
  casing) asserting the invariant-locale result.
