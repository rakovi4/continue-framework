# Test Review Patterns: H2 Adapter Layer (Java/Spring)

Java/AssertJ code examples for persistence adapter test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Java-Specific Rules (H2)

1. **Use .as()** -- always describe what you're validating with AssertJ's `.as()` for clear failure messages
2. **Prefer usingRecursiveComparison** -- replace 2+ sequential per-field `assertThat` calls with `assertThat(actual).usingRecursiveComparison().isEqualTo(expected)`
3. **Use truncatedTo(ChronoUnit.MINUTES)** -- for Instant/LocalDateTime comparisons to avoid millisecond mismatches

## Anti-Pattern Examples

Persistence adapter tests share many patterns with usecase and acceptance tests. Common issues:

- **Loose existence checks** on returned entities -- use `isEqualTo(expected)` not `isNotNull()`
- **Missing field assertions** on `toDomain()` results -- assert ALL domain fields after round-trip
- **Timestamp precision mismatches** -- always truncate to minutes before comparing

See `test-review-usecase.md` for Statements purity patterns and `test-review-acceptance.md` for assertion strictness patterns -- both apply to H2 adapter tests.
