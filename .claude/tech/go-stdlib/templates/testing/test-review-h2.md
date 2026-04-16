# Test Review Patterns: H2 Adapter Layer (Go/stdlib)

Go/testify code examples for persistence adapter test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Go-Specific Rules (H2)

1. **Use assert message parameter** -- always pass a description string as the last argument to `assert.*` / `require.*` for clear failure messages
2. **Prefer assert.Equal on structs** -- replace 2+ sequential per-field `assert.Equal` calls with a single `assert.Equal(t, expected, actual)` using a fully constructed expected struct
3. **Use assert.WithinDuration for timestamps** -- avoid `time.Equal()` which can fail on monotonic clock differences; use `assert.WithinDuration(t, expected, actual, time.Second)`

## Anti-Pattern Examples

Persistence adapter tests share many patterns with usecase and acceptance tests. Common issues:

- **Loose existence checks** on returned entities -- use `assert.Equal(t, expected, actual)` not `assert.NotNil(t, actual)`
- **Missing field assertions** on `ToDomain()` results -- assert ALL domain fields after round-trip
- **Timestamp precision mismatches** -- always use `assert.WithinDuration` instead of direct equality

See `test-review-usecase.md` for Statements purity patterns and `test-review-acceptance.md` for assertion strictness patterns -- both apply to H2 adapter tests.
