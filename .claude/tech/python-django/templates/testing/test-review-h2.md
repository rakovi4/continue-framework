# Test Review Patterns: H2 Adapter Layer (Python/Django)

Python/pytest code examples for persistence adapter test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Python-Specific Rules (H2)

1. **Use descriptive assertion messages** -- add a second argument to `assert` for clear failure messages
2. **Prefer dataclass equality** -- replace 2+ sequential per-field `assert` calls with `assert actual == expected` (frozen dataclasses do deep structural comparison by default)
3. **Use `truncate_to_minutes()`** -- for datetime comparisons to avoid microsecond mismatches

## Anti-Pattern Examples

Persistence adapter tests share many patterns with usecase and acceptance tests. Common issues:

- **Loose existence checks** on returned entities -- use `== expected` not `is not None`
- **Missing field assertions** on `to_domain()` results -- assert ALL domain fields after round-trip
- **Timestamp precision mismatches** -- always truncate to minutes before comparing

See `test-review-usecase.md` for Statements purity patterns and `test-review-acceptance.md` for assertion strictness patterns -- both apply to H2 adapter tests.
