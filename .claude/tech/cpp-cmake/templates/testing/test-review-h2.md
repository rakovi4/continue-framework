# Test Review Patterns: H2 Adapter Layer (C++/Google Test)

C++/Google Test code examples for persistence adapter test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## C++-Specific Rules (H2)

1. **Use descriptive failure messages** -- add `<< "description"` to assertions for clear failure output
2. **Implement operator== on structs** -- enables `EXPECT_EQ(actual, expected)` for structural comparison
3. **Use time_point truncation** -- for timestamp comparisons, truncate to seconds to avoid sub-second mismatches

## Anti-Pattern Examples

Persistence adapter tests share many patterns with usecase and acceptance tests. Common issues:

- **Loose existence checks** on returned entities -- use `EXPECT_EQ(actual, expected)` not `EXPECT_TRUE(result.has_value())`
- **Missing field assertions** on `to_domain()` results -- assert ALL domain fields after round-trip
- **Timestamp precision mismatches** -- always truncate to seconds before comparing

See `test-review-usecase.md` for Statements purity patterns and `test-review-acceptance.md` for assertion strictness patterns -- both apply to H2 adapter tests.
