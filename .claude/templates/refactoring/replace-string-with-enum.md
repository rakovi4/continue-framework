# Replace String with Enum

**When to use:** String fields/literals represent a fixed set of domain values (status, plan, type, role).

**Examples:** TaskStatus, UserRole, ColumnType, Priority

## Step 1: Create Enum in Domain

Include `value()` for lowercase serialization and `from(String)` for parsing — centralize conversion instead of repeating at each boundary.

```java
public enum TaskStatus {
    TODO,
    IN_PROGRESS,
    DONE,
    ARCHIVED;

    public String value() {
        return name().toLowerCase();
    }

    public static TaskStatus from(String value) {
        return valueOf(value.toUpperCase());
    }
}
```

Add behavior methods when the enum carries domain logic:

```java
    public boolean isTerminal() {
        return this == DONE || this == ARCHIVED;
    }
```

## Step 2: Update Domain Entity

Add a `statusName()` method for string representation at boundaries:

```java
// Before: private String status;
//         public String status() { return status; }
// After:  private TaskStatus status;
//         public TaskStatus status() { return status; }
//         public String statusName() { return status.value(); }
```

## Step 3: Replace if-else Chains with Switch Expressions

```java
// Before:
if ("done".equals(status)) { archive(taskId, now); }
if ("archived".equals(status)) { removeFromBoard(); }

// After:
switch (status) {
    case DONE -> archive(taskId, now);
    case ARCHIVED -> removeFromBoard();
    default -> {}
}
```

## Step 4: Update Adapter Boundaries

**REST DTO** — convert enum to string at the boundary:
```java
// Before: new TaskDto(task.taskId(), task.status(), ...)
// After:  new TaskDto(task.taskId(), task.statusName(), ...)
```

**API input** — parse string to enum at the boundary:
```java
// Before: new Request(object.id, object.status)
// After:  new Request(object.id, TaskStatus.from(object.status))
```

**H2 entity** — store as String in DB, convert on boundaries:
```java
// from(): entity.status = domain.statusName();
// toDomain(): TaskStatus.from(status)
```

No migration needed — stored values remain the same strings.

## Step 5: Update Tests

Use static imports for readability:
```java
import static com.example.domain.task.TaskStatus.*;

// Before: assertThat(task.status()).isEqualTo("in_progress");
// After:  assertThat(task.status()).isEqualTo(IN_PROGRESS);
```

## Checklist

1. [ ] Create enum in domain with `value()`, `from(String)`, and behavior methods
2. [ ] Update entity — store enum, add `statusName()` for string access
3. [ ] Replace if-else chains with switch expressions
4. [ ] Update usecase request/response (use enum internally)
5. [ ] Update REST DTO (serialize via `statusName()`)
6. [ ] Update API input DTO (parse via `Enum.from(string)`)
7. [ ] Update H2 entity (string <-> enum conversion via `statusName()`/`from()`)
8. [ ] Update tests (static import enum values, compare to enum not string)
9. [ ] Run `./gradlew build`

## Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| H2 entity stores enum directly | Store as String, convert at boundary |
| Test compares enum to string | Compare to enum constant with static import |
| API contract breaks | Keep JSON values as lowercase strings via `statusName()` |
| Repeated `name().toLowerCase()` at boundaries | Use `value()` on the enum, `statusName()` on the entity |
| Business logic as external if-else on status | Add behavior method on enum (e.g., `isTerminal()`) |
