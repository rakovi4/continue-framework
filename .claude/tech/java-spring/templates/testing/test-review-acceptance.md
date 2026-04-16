# Test Review Patterns: Acceptance Layer (Java/Spring)

Java/AssertJ code examples for acceptance test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Java-Specific Rules (Acceptance)

1. **Use .as()** -- always describe what you're validating with AssertJ's `.as()` for clear failure messages
2. **Extract validation helper classes** -- parsing logic (e.g., `SetCookie` parser) belongs in helper classes
3. **Prefer usingRecursiveComparison** -- replace 2+ sequential per-field `assertThat` calls with `assertThat(actual).usingRecursiveComparison().isEqualTo(expected)`
4. **Use truncatedTo(ChronoUnit.MINUTES)** -- for Instant/LocalDateTime comparisons to avoid millisecond mismatches

## Anti-Pattern Examples

### BAD: Loose String Validation
```java
assertThat(setCookie).contains("SESSION=");
assertThat(setCookie).contains("Max-Age=0");
assertThat(response.getBody()).contains("\"email\":");
```

### BAD: Multiple contains() chains
```java
assertThat(setCookie)
    .contains("SESSION=")
    .contains("Path=/")
    .contains("HttpOnly");
```

### BAD: startsWith/matches without verifying actual content
```java
assertThat(response.maskedToken())
    .startsWith("****");  // Does NOT verify if "****5678" matches expected "5678"

assertThat(response.maskedToken())
    .matches("\\*{4}\\w{4}");  // Does NOT verify the real last 4 chars
```

### BAD: isNotNull() when actual value should be checked
```java
assertThat(response.tokenType())
    .isNotNull();  // Should verify equals "Bearer"

assertThat(response.expiresAt())
    .isNotNull();  // Should verify actual date
```

### BAD: isNotNull() for values capturable from setup
```java
taskStatements.givenUserWithTask(TASK_ID);
// ...
assertThat(entry.getTaskId()).as("Task ID").isNotNull();  // LOOSE
assertThat(entry.getReason()).as("Reason").isNotNull();    // LOOSE
assertThat(entry.getCreatedAt()).as("Timestamp").isNotNull(); // LOOSE
// GOOD: capture from setup, assert exact values
var taskId = taskStatements.givenUserWithTask(TASK_ID);
// ...
assertThat(entry.getTaskId()).as("Task ID").isEqualTo(taskId);
assertThat(entry.getReason()).as("Reason").isEqualTo("Update failed");
assertThat(Instant.parse(entry.getCreatedAt())).as("Timestamp")
        .isAfter(Instant.now().minus(Duration.ofSeconds(30)));
```

### BAD: Missing field assertions
```java
public void assertTaskExists(GetTaskStatusResponse response) {
    assertThat(response.exists()).isTrue();
    assertThat(response.title()).isNotNull();
    assertThat(response.createdAt()).isNotNull();
    // MISSING: description, columnId, status
}
```

### BAD: Empty collections in expected values
```java
assertThat(response.permissions())
    .isEqualTo(List.of());  // Should be List.of("Read", "Write")
```

### BAD: Timestamp assertions without actual time comparison
```java
assertThat(response.createdAt())
    .as("created at timestamp")
    .isNotNull();  // Should verify approximately NOW

assertThat(response.expiresAt())
    .as("expiration date")
    .isAfter(response.createdAt());  // Should verify actual expected date
```

### BAD: isAfter()/isBefore() when exact period is deterministic
```java
assertThat(response.getExpiresAt())
    .isAfter(LocalDateTime.now());  // Should compute exact expected expiration

assertThat(response.expiresAt())
    .isAfter(response.startedAt());  // Should assert: DAYS.between(start, end) == 30
```

### BAD: isNotBlank() instead of exact value
```java
assertThat(response.getMessage())
    .isNotBlank();  // Should use isEqualTo(EXPECTED_MESSAGE)
```

### BAD: Range checks when exact value is deterministic
```java
assertThat(response.getDaysRemaining())
    .isGreaterThan(0)
    .isLessThanOrEqualTo(7);  // Should be isEqualTo(7)

assertThat(response.getRetryCount())
    .isBetween(1, 5);  // Should be isEqualTo(3)
```

### BAD: isNotEmpty() instead of exact value
```java
assertThat(response.getTokenMasked())
    .isNotNull()
    .isNotEmpty();  // Should use isEqualTo(EXPECTED_MASKED_TOKEN)

assertThat(response.getPermissions())
    .isNotNull()
    .isNotEmpty();  // Should use isEqualTo(EXPECTED_PERMISSIONS)
```

### BAD: contains() on collections instead of exact match
```java
assertThat(response.getPermissions())
    .contains("Edit Tasks");  // Should use isEqualTo() to verify ALL
```

### BAD: Asserting only first item in a collection
```java
assertThat(response.getTasks()).hasSize(3);
assertThat(response.getTasks().get(0).getId())
    .isEqualTo("task-001");
// MISSING: get(1) and get(2) are never checked
// GOOD: assert ALL tasks
assertTask(response.getTasks().get(0), "task-001", "Task 1", "ACTIVE", "HIGH");
assertTask(response.getTasks().get(1), "task-002", "Task 2", "PENDING", "MEDIUM");
assertTask(response.getTasks().get(2), "task-003", "Task 3", "DONE", "LOW");
```

### BAD: Asserting only IDs without full object contents
```java
assertThat(card.getId()).isEqualTo(11111);
// MISSING: title, status, assignee, priority, dueDate
// GOOD: assert all fields
assertThat(card.getId()).isEqualTo(11111);
assertThat(card.getTitle()).isEqualTo("Task 1");
assertThat(card.getStatus()).isEqualTo("TODO");
assertThat(card.getAssignee()).isEqualTo("user@example.com");
assertThat(card.getPriority()).isEqualTo("HIGH");
assertThat(card.getDueDate()).isEqualTo("2026-04-15");
```

## Correct Patterns

### GOOD: Parse-then-Assert Pattern
```java
SetCookie cookie = new SetCookie(headers);

assertThat(cookie.getName()).as("cookie name").isEqualTo("SESSION");
assertThat(cookie.getValue()).as("session value").isEmpty();
assertThat(cookie.getMaxAge()).as("max age").isEqualTo("0");
assertThat(cookie.getPath()).as("cookie path").isEqualTo("/");
assertThat(cookie.isHttpOnly()).as("http only flag").isTrue();
```

### GOOD: Extract Validation Helper Class
```java
public class SetCookie {
    private final String setCookie;
    private final Map<String, String> attributes;

    public SetCookie(HttpHeaders headers) {
        this.setCookie = headers.getFirst("Set-Cookie");
        this.attributes = parseAttributes();
    }

    public String getName() { return parts()[0].split("=")[0]; }
    public String getValue() { return parts()[0].split("=", 2)[1]; }
    public String getMaxAge() { return attributes.get("Max-Age"); }
    public String getPath() { return attributes.get("Path"); }
    public boolean isHttpOnly() { return attributes.containsKey("HttpOnly"); }

    private String[] parts() { return setCookie.split(";"); }
    private Map<String, String> parseAttributes() { /* ... */ }
}
```

### GOOD: Descriptive Assertions
```java
assertThat(cookie.getName())
    .as("session cookie name")
    .isEqualTo("SESSION");

assertThat(cookie.getMaxAge())
    .as("cookie expiration for logout")
    .isEqualTo("0");
```

### GOOD: Timestamp Assertions with Precision
```java
assertThat(response.createdAt().truncatedTo(ChronoUnit.MINUTES))
    .as("created at timestamp")
    .isEqualTo(Instant.now().truncatedTo(ChronoUnit.MINUTES));

assertThat(response.expiresAt().truncatedTo(ChronoUnit.MINUTES))
    .as("expiration date")
    .isEqualTo(Instant.now().plus(30, ChronoUnit.DAYS).truncatedTo(ChronoUnit.MINUTES));
```

### GOOD: Collection Assertions with Expected Constants
```java
public static final List<String> EXPECTED_PERMISSIONS = List.of("Read", "Write");

assertThat(response.permissions())
    .as("token permissions")
    .isEqualTo(EXPECTED_PERMISSIONS);
```

### GOOD: Complete Response Validation
```java
public void assertTaskExists(GetTaskStatusResponse response) {
    assertThat(response.exists()).as("exists flag").isTrue();
    assertThat(response.title()).as("title").isEqualTo(EXPECTED_TITLE);
    assertThat(response.description()).as("description").isEqualTo(EXPECTED_DESCRIPTION);
    assertThat(response.columnId()).as("column ID").isEqualTo(EXPECTED_COLUMN_ID);
    assertThat(response.createdAt().truncatedTo(MINUTES)).as("created at").isEqualTo(Instant.now().truncatedTo(MINUTES));
    assertThat(response.status()).as("status").isEqualTo(EXPECTED_STATUS);
}
```

### GOOD: Recursive Comparison (AssertJ)
```java
assertThat(actual).usingRecursiveComparison().isEqualTo(expected);

assertThat(list).usingRecursiveFieldByFieldElementComparator()
    .containsExactlyInAnyOrderElementsOf(expected);
```

## Assertion Improvements (Java/AssertJ Syntax)

| Before (Loose) | After (Strict) |
|----------------|----------------|
| `assertThat(json).contains("email")` | `assertThat(parsed.getEmail()).isEqualTo(expected)` |
| `assertThat(body).matches(".*token.*")` | `assertThat(parsed.getToken()).isEqualTo(expectedToken)` |
| `assertTrue(response.contains(id))` | `assertThat(parsed.getId()).isEqualTo(id)` |
| `assertThat(header).startsWith("Bearer")` | `assertThat(auth.getType()).isEqualTo("Bearer")` |
| `assertThat(masked).startsWith("****")` | `assertThat(masked).isEqualTo("****" + expectedLast4)` |
| `assertThat(field).isNotNull()` | `assertThat(field).isEqualTo(expectedValue)` |
| `assertThat(field).isNotEmpty()` | `assertThat(field).isEqualTo(expectedValue)` |
| `assertThat(field).isNotBlank()` | `assertThat(field).isEqualTo(EXPECTED_MESSAGE)` |
| `assertThat(n).isGreaterThan(0).isLessThanOrEqualTo(7)` | `assertThat(n).isEqualTo(7)` (if deterministic) |
| `assertThat(n).isBetween(a, b)` | `assertThat(n).isEqualTo(exact)` (if deterministic) |
| `assertThat(list).contains(item)` | `assertThat(list).isEqualTo(EXPECTED_LIST)` |
| `assertThat(permissions).isEqualTo(List.of())` | `assertThat(permissions).isEqualTo(EXPECTED_PERMISSIONS)` |
| `assertThat(timestamp).isNotNull()` | `assertThat(timestamp.truncatedTo(MINUTES)).isEqualTo(expected)` |
| `assertThat(expiresAt).isAfter(createdAt)` | `assertThat(DAYS.between(startedAt, expiresAt)).isEqualTo(30)` |
| 2+ sequential `assertThat(field).isEqualTo(expected)` | `assertThat(actual).usingRecursiveComparison().isEqualTo(expected)` |
