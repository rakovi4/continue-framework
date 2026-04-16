# Test Review Patterns: H2 Adapter Layer (C#/ASP.NET Core)

C#/FluentAssertions code examples for persistence adapter test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## C#-Specific Rules (H2)

1. **Use `.Because("reason")`** -- always describe what you're validating with FluentAssertions' `.Because()` for clear failure messages
2. **Prefer `BeEquivalentTo`** -- replace 2+ sequential per-property `.Should().Be()` calls with `actual.Should().BeEquivalentTo(expected)`
3. **Truncate timestamps** -- for `DateTimeOffset`/`DateTime` comparisons, truncate to minutes to avoid millisecond mismatches from database round-trips

## Anti-Pattern Examples

Persistence adapter tests share many patterns with usecase and acceptance tests. Common issues:

- **Loose existence checks** on returned entities -- use `.Should().Be(expected)` not `.Should().NotBeNull()`
- **Missing field assertions** on `ToDomain()` results -- assert ALL domain fields after round-trip
- **Timestamp precision mismatches** -- always truncate to minutes before comparing

See `test-review-usecase.md` for Statements purity patterns and `test-review-acceptance.md` for assertion strictness patterns -- both apply to H2 adapter tests.
