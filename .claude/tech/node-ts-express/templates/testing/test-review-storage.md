# Test Review Patterns: Storage Adapter Layer (Node/TypeScript)

TypeScript/Vitest code examples for persistence adapter test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## TypeScript-Specific Rules (Storage)

1. **Prefer toEqual() for structural comparison** -- use `expect(actual).toEqual(expected)` for object comparison instead of per-field assertions
2. **Use closeTo for timestamp comparisons** -- assert that the difference between actual and expected is within 60 seconds. Never truncate to minutes -- truncation causes flaky failures at minute boundaries

## Anti-Pattern Examples

Persistence adapter tests share many patterns with usecase and acceptance tests. Common issues:

- **Loose existence checks** on returned entities -- use `toEqual(expected)` not `toBeDefined()`
- **Missing field assertions** on `toDomain()` results -- assert ALL domain fields after round-trip
- **Timestamp precision mismatches** -- use closeTo within 60 seconds, never truncate

See `test-review-usecase.md` for Statements purity patterns and `test-review-acceptance.md` for assertion strictness patterns -- both apply to storage adapter tests.
