# Test Review Patterns: Storage Adapter Layer (Java/Spring)

Java/AssertJ code examples for persistence adapter test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Java-Specific Rules (Storage)

1. **Use .as()** -- always describe what you're validating with AssertJ's `.as()` for clear failure messages
2. **Prefer usingRecursiveComparison** -- replace 2+ sequential per-field `assertThat` calls with `assertThat(actual).usingRecursiveComparison().isEqualTo(expected)`
3. **Use isCloseTo for timestamps** -- for Instant/LocalDateTime comparisons use `isCloseTo(expected, within(1, ChronoUnit.MINUTES))`. Never truncate to minutes -- truncation causes flaky failures at minute boundaries

## Anti-Pattern Examples

Persistence adapter tests share many patterns with usecase and acceptance tests. Common issues:

- **Loose existence checks** on returned entities -- use `isEqualTo(expected)` not `isNotNull()`
- **Missing field assertions** on `toDomain()` results -- assert ALL domain fields after round-trip
- **Timestamp precision mismatches** -- use `isCloseTo(expected, within(1, MINUTES))`, never truncate

See `test-review-usecase.md` for Statements purity patterns and `test-review-acceptance.md` for assertion strictness patterns -- both apply to storage adapter tests.
