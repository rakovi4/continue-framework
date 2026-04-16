# Test Review Patterns: H2 Adapter Layer (Node/TypeScript)

TypeScript/Vitest code examples for persistence adapter test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## TypeScript-Specific Rules (H2)

1. **Prefer toEqual() for structural comparison** -- use `expect(actual).toEqual(expected)` for object comparison instead of per-field assertions
2. **Use minute-truncation for timestamp comparisons** -- truncate to minutes before comparing to avoid millisecond mismatches

## Anti-Pattern Examples

Persistence adapter tests share many patterns with usecase and acceptance tests. Common issues:

- **Loose existence checks** on returned entities -- use `toEqual(expected)` not `toBeDefined()`
- **Missing field assertions** on `toDomain()` results -- assert ALL domain fields after round-trip
- **Timestamp precision mismatches** -- always truncate to minutes before comparing

See `test-review-usecase.md` for Statements purity patterns and `test-review-acceptance.md` for assertion strictness patterns -- both apply to H2 adapter tests.
