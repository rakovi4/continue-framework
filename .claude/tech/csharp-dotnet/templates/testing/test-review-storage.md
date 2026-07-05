# Test Review Patterns: Storage Adapter Layer (C#/ASP.NET Core)

C#/FluentAssertions code examples for persistence adapter test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## C#-Specific Rules (Storage)

1. **Use `.Because("reason")`** -- always describe what you're validating with FluentAssertions' `.Because()` for clear failure messages
2. **Prefer `BeEquivalentTo`** -- replace 2+ sequential per-property `.Should().Be()` calls with `actual.Should().BeEquivalentTo(expected)`
3. **Use BeCloseTo for timestamps** -- for `DateTimeOffset`/`DateTime` comparisons use `.Should().BeCloseTo(expected, TimeSpan.FromMinutes(1))`. Never truncate to minutes -- truncation causes flaky failures at minute boundaries

## Anti-Pattern Examples

Persistence adapter tests share many patterns with usecase and acceptance tests. Common issues:

- **Loose existence checks** on returned entities -- use `.Should().Be(expected)` not `.Should().NotBeNull()`
- **Missing field assertions** on `ToDomain()` results -- assert ALL domain fields after round-trip
- **Timestamp precision mismatches** -- use `BeCloseTo(expected, TimeSpan.FromMinutes(1))`, never truncate

See `test-review-usecase.md` for Statements purity patterns and `test-review-acceptance.md` for assertion strictness patterns -- both apply to storage adapter tests.
