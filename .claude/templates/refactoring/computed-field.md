# Remove Persisted Field, Replace with Computed Method

**When to use:** A stored field is fully derivable from other fields. Persisting it creates contradictions.

**Examples:** `isOverdue` derived from `dueDate`, `age` derived from `birthDate`, `isExpired` derived from `expiresAt`

## Smell Detection

```java
// Red flag: field AND method that overrides it
public record Column(UUID id, String name, List<Task> tasks, int taskCount) {
    public int effectiveTaskCount() {     // <-- "effective" means stored count lies
        if (tasks.isEmpty()) return 0;
        return tasks.size();
    }
}
```

## Step 1: Remove Field from Domain Entity

```java
// Before
public record Column(UUID id, UUID boardId, String name,
                            List<Task> tasks, int taskCount) {
    public int effectiveTaskCount() { ... }
}

// After — taskCount is computed, not stored
public record Column(UUID id, UUID boardId, String name,
                            List<Task> tasks) {
    public int taskCount() {
        return tasks.size();
    }

    public boolean isEmpty() {
        return tasks.isEmpty();
    }
}
```

## Step 2: Update Factory Methods

Remove `taskCount` parameter from all constructors/factories.

## Step 3: Update H2 Entity + Migration

```sql
ALTER TABLE columns DROP COLUMN task_count;
```

Update entity: remove taskCount field, update `from()` and `toDomain()`.

## Step 4: Update Usecase Response

```java
// Before: column.effectiveTaskCount()
// After:  column.taskCount()
```

## Step 5: Update Tests

Remove `taskCount` from test data construction — it's computed automatically.

## Checklist

1. [ ] Remove field from domain record
2. [ ] Rename `effectiveX()` -> `x()` (computed method)
3. [ ] Update factory methods (remove parameter)
4. [ ] Add DB migration to drop column
5. [ ] Update H2 entity
6. [ ] Update usecase response mapping
7. [ ] Update all test data construction
8. [ ] Run `./gradlew build`

## Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Record auto-generates accessor | Removing field from record lets you define method |
| Old migration creates column | Add new migration to drop, don't edit old one |
| Tests pass wrong number of args | Find all `new Column(...)` calls |
