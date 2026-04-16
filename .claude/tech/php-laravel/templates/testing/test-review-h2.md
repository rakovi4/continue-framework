# Test Review Patterns: H2 Adapter Layer (PHP/Laravel)

PHP/PHPUnit code examples for persistence adapter test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## PHP-Specific Rules (H2)

1. **Use descriptive assertion messages** -- add a third argument to `assertEquals` for clear failure messages
2. **Prefer object equality** -- replace 2+ sequential per-field `assertEquals` calls with `assertEquals($expected, $actual)` (PHPUnit does deep structural comparison on objects)
3. **Truncate timestamps before comparing** -- use `->setTime(H, i, 0)` or `->format('Y-m-d H:i')` to avoid second/millisecond mismatches

## Anti-Pattern Examples

Persistence adapter tests share many patterns with usecase and acceptance tests. Common issues:

- **Loose existence checks** on returned entities -- use `assertEquals($expected, $actual)` not `assertNotNull($actual)`
- **Missing field assertions** on `toDomain()` results -- assert ALL domain fields after round-trip
- **Timestamp precision mismatches** -- always truncate to minutes before comparing

See `test-review-usecase.md` for Statements purity patterns and `test-review-acceptance.md` for assertion strictness patterns -- both apply to H2 adapter tests.
