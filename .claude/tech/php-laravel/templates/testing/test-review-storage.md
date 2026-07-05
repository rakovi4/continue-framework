# Test Review Patterns: Storage Adapter Layer (PHP/Laravel)

PHP/PHPUnit code examples for persistence adapter test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## PHP-Specific Rules (Storage)

1. **Use descriptive assertion messages** -- add a third argument to `assertEquals` for clear failure messages
2. **Prefer object equality** -- replace 2+ sequential per-field `assertEquals` calls with `assertEquals($expected, $actual)` (PHPUnit does deep structural comparison on objects)
3. **Use assertEqualsWithDelta for timestamps** -- compare timestamps within a 60-second delta. Never truncate to minutes -- truncation causes flaky failures at minute boundaries

## Anti-Pattern Examples

Persistence adapter tests share many patterns with usecase and acceptance tests. Common issues:

- **Loose existence checks** on returned entities -- use `assertEquals($expected, $actual)` not `assertNotNull($actual)`
- **Missing field assertions** on `toDomain()` results -- assert ALL domain fields after round-trip
- **Timestamp precision mismatches** -- use `assertEqualsWithDelta` within 60 seconds, never truncate

See `test-review-usecase.md` for Statements purity patterns and `test-review-acceptance.md` for assertion strictness patterns -- both apply to storage adapter tests.
