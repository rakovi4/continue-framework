# Recursive Comparison — Replace Manual Per-Field Assertions

## When to Apply

- Any field-by-field comparison
- `assertAllFields`/`assertEntry`-style utility classes or methods comparing two records field by field
- Test helper with 2+ sequential `assertThat(actual.fieldX()).isEqualTo(expected.fieldX())` lines
- Loops that iterate a list and compare each element's fields individually

## Before

```java
// Shared helper with 7 lines of assertions
static void assertAllFields(Task actual, Task expected) {
    assertThat(actual.id()).as("id").isEqualTo(expected.id());
    assertThat(actual.title()).as("title").isEqualTo(expected.title());
    assertThat(actual.columnId()).as("columnId").isEqualTo(expected.columnId());
    // ... 4 more fields
}
```

## After — Single Object

```java
assertThat(actual).usingRecursiveComparison().isEqualTo(expected);
```

On failure, AssertJ lists every mismatched field individually:
```
found the following 2 differences:
field/property 'reason' differ:
- actual value  : "Moved to Done"
- expected value: "Wrong reason"
field/property 'oldColumnId' differ:
- actual value  : 10001
- expected value: 99999
```

## After — List (order-independent)

```java
assertThat(actualList)
    .usingRecursiveFieldByFieldElementComparator()
    .containsExactlyInAnyOrderElementsOf(expectedList);
```

## After — List (ordered)

```java
assertThat(actualList)
    .usingRecursiveFieldByFieldElementComparator()
    .containsExactlyElementsOf(expectedList);
```

## After — Ignoring Specific Fields

```java
assertThat(actual).usingRecursiveComparison()
    .ignoringFields("id", "createdAt")
    .isEqualTo(expected);
```

## Steps

1. Find the per-field assertion helper (private method or shared utility class)
2. Replace each call site with `usingRecursiveComparison().isEqualTo(expected)`
3. For list assertions, use `usingRecursiveFieldByFieldElementComparator()`
4. Delete the helper method/class
5. Run tests — verify all pass
6. If any test needs custom comparison (e.g., ignoring auto-generated IDs), use `.ignoringFields()`

## When NOT to Use

- Comparing objects that are NOT records/VOs and lack proper field access (rare)
- When you need different comparison strategies per field (e.g., timestamp tolerance on one field, exact match on others) — see Mixed-Strategy Fallback below

## Mixed-Strategy Fallback

When fields have mixed assertion strategies (exact-match, `isNotNull`, `isNull`, timestamp truncation), recursive comparison doesn't apply. Instead, extract reusable assertion blocks as private methods:

1. **Classify each field**: exact-match, non-deterministic (`isNotNull`/`isNotEmpty`), null-check (`isNull`), or custom (timestamp truncation, range check)
2. **Extract cross-method patterns** as private helpers: HTTP status assertions, timestamp-within-tolerance checks, error structure assertions — anything duplicated across 2+ methods in the same Statements class
3. **Keep field-specific assertions** in the parent method — they document what THIS scenario verifies
4. The parent method becomes a readable sequence of named steps: `assertHttpStatus(201)`, `assertTimestampRecent(task.getCreatedAt())`, plus inline field checks
