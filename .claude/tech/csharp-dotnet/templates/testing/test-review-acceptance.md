# Test Review Patterns: Acceptance Layer (C#/ASP.NET Core)

C#/FluentAssertions code examples for acceptance test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## C#-Specific Rules (Acceptance)

1. **Use `.Because("reason")`** -- always describe what you're validating with FluentAssertions' `.Because()` for clear failure messages
2. **Extract validation helper classes** -- parsing logic (e.g., `SetCookieParser`) belongs in helper classes
3. **Prefer `BeEquivalentTo`** -- replace 2+ sequential per-property `.Should().Be()` calls with `actual.Should().BeEquivalentTo(expected)`
4. **Truncate timestamps** -- for `DateTimeOffset`/`DateTime` comparisons, truncate to minutes to avoid millisecond mismatches

## Anti-Pattern Examples

### BAD: Loose String Validation
```csharp
setCookie.Should().Contain("SESSION=");
setCookie.Should().Contain("Max-Age=0");
response.Should().Contain("\"email\":");
```

### BAD: StartsWith/Matches without verifying actual content
```csharp
response.MaskedToken.Should().StartWith("****");
// Does NOT verify if "****5678" matches expected "5678"

Regex.IsMatch(response.MaskedToken, @"\*{4}\w{4}").Should().BeTrue();
// Does NOT verify the real last 4 chars
```

### BAD: `NotBeNull` when actual value should be checked
```csharp
response.TokenType.Should().NotBeNull();
// Should verify equals "Bearer"

response.ExpiresAt.Should().NotBeNull();
// Should verify actual date
```

### BAD: `NotBeNull` for values capturable from setup
```csharp
taskStatements.GivenUserWithTask(TASK_ID);
// ...
entry.TaskId.Should().NotBeNull();  // LOOSE
entry.Reason.Should().NotBeNull();   // LOOSE
entry.CreatedAt.Should().NotBeNull(); // LOOSE
// GOOD: capture from setup, assert exact values
var taskId = taskStatements.GivenUserWithTask(TASK_ID);
// ...
entry.TaskId.Should().Be(taskId);
entry.Reason.Should().Be("Update failed");
entry.CreatedAt.Should().BeAfter(DateTime.UtcNow.AddSeconds(-30));
```

### BAD: Missing field assertions
```csharp
void AssertTaskExists(TaskResponse response)
{
    response.Exists.Should().BeTrue();
    response.Title.Should().NotBeNull();
    response.CreatedAt.Should().NotBeNull();
    // MISSING: Description, ColumnId, Status
}
```

### BAD: Empty collections in expected values
```csharp
response.Permissions.Should().BeEmpty();
// Should be: response.Permissions.Should().BeEquivalentTo(new[] { "Read", "Write" });
```

### BAD: Timestamp assertions without actual time comparison
```csharp
response.CreatedAt.Should().NotBeNull();
// Should verify approximately NOW

response.ExpiresAt.Should().BeAfter(response.CreatedAt);
// Should verify actual expected date
```

### BAD: BeAfter()/BeBefore() when exact period is deterministic
```csharp
response.ExpiresAt.Should().BeAfter(DateTimeOffset.UtcNow);
// Should compute exact expected expiration

response.ExpiresAt.Should().BeAfter(response.StartedAt);
// Should assert: (expiresAt - startedAt).Days == 30
```

### BAD: Truthy check instead of exact value
```csharp
response.Message.Should().NotBeNullOrEmpty();
// Should use response.Message.Should().Be(EXPECTED_MESSAGE);
```

### BAD: Range checks when exact value is deterministic
```csharp
response.DaysRemaining.Should().BeInRange(1, 7);
// Should be response.DaysRemaining.Should().Be(7);
```

### BAD: Contain on collections instead of exact match
```csharp
response.Permissions.Should().Contain("Edit Tasks");
// GOOD: verify ALL permissions
response.Permissions.Should().BeEquivalentTo(EXPECTED_PERMISSIONS);
```

### BAD: Asserting only first item in a collection
```csharp
response.Tasks.Should().HaveCount(3);
response.Tasks[0].Id.Should().Be("task-001");
// MISSING: Tasks[1] and Tasks[2] are never checked
// GOOD: assert ALL tasks
AssertTask(response.Tasks[0], "task-001", "Task 1", "ACTIVE", "HIGH");
AssertTask(response.Tasks[1], "task-002", "Task 2", "PENDING", "MEDIUM");
AssertTask(response.Tasks[2], "task-003", "Task 3", "DONE", "LOW");
```

### BAD: Asserting only IDs without full object contents
```csharp
card.Id.Should().Be(11111);
// MISSING: Title, Status, Assignee, Priority, DueDate
// GOOD: assert all fields
card.Id.Should().Be(11111);
card.Title.Should().Be("Task 1");
card.Status.Should().Be("TODO");
card.Assignee.Should().Be("user@example.com");
card.Priority.Should().Be("HIGH");
card.DueDate.Should().Be("2026-04-15");
```

## Correct Patterns

### GOOD: Parse-then-Assert Pattern
```csharp
var cookie = new SetCookie(headers);

cookie.Name.Should().Be("SESSION", "cookie name");
cookie.Value.Should().Be("", "session value");
cookie.MaxAge.Should().Be("0", "max age");
cookie.Path.Should().Be("/", "cookie path");
cookie.HttpOnly.Should().BeTrue("http only flag");
```

### GOOD: Timestamp Assertions with Precision
```csharp
static DateTimeOffset TruncateToMinutes(DateTimeOffset dt) =>
    new(dt.Year, dt.Month, dt.Day, dt.Hour, dt.Minute, 0, dt.Offset);

TruncateToMinutes(response.CreatedAt).Should().Be(TruncateToMinutes(DateTimeOffset.UtcNow));
TruncateToMinutes(response.ExpiresAt).Should().Be(
    TruncateToMinutes(DateTimeOffset.UtcNow.AddDays(30)));
```

### GOOD: Collection Assertions with Expected Constants
```csharp
var expectedPermissions = new[] { "Read", "Write" };
response.Permissions.Should().BeEquivalentTo(expectedPermissions, "token permissions");
```

### GOOD: Complete Response Validation
```csharp
void AssertTaskExists(TaskResponse response)
{
    response.Exists.Should().BeTrue("exists flag");
    response.Title.Should().Be(EXPECTED_TITLE, "title");
    response.Description.Should().Be(EXPECTED_DESCRIPTION, "description");
    response.ColumnId.Should().Be(EXPECTED_COLUMN_ID, "column ID");
    response.CreatedAt.Should().BeAfter(DateTime.UtcNow.AddSeconds(-30), "created at");
    response.Status.Should().Be(EXPECTED_STATUS, "status");
}
```

### GOOD: Record Equality (recursive comparison)
```csharp
// Replace 2+ per-property assertions with record equality
actual.Should().BeEquivalentTo(expected);  // records compare all properties recursively
```

## Assertion Improvements (C#/FluentAssertions Syntax)

| Before (Loose) | After (Strict) |
|----------------|----------------|
| `body.Should().Contain("email")` | `parsed.Email.Should().Be(expected)` |
| `Regex.IsMatch(body, ".*token.*")` | `parsed.Token.Should().Be(expectedToken)` |
| `response.Should().Contain(id)` | `parsed.Id.Should().Be(id)` |
| `header.Should().StartWith("Bearer")` | `auth.Type.Should().Be("Bearer")` |
| `masked.Should().StartWith("****")` | `masked.Should().Be("****" + expectedLast4)` |
| `field.Should().NotBeNull()` | `field.Should().Be(expectedValue)` |
| `field.Should().NotBeNullOrEmpty()` | `field.Should().Be(EXPECTED_MESSAGE)` |
| `n.Should().BeInRange(1, 7)` | `n.Should().Be(7)` (if deterministic) |
| `collection.Should().Contain(item)` | `collection.Should().BeEquivalentTo(EXPECTED_LIST)` |
| `permissions.Should().BeEmpty()` | `permissions.Should().BeEquivalentTo(EXPECTED_PERMISSIONS)` |
| `timestamp.Should().NotBeNull()` | Truncate to minutes, compare with `.Be()` |
| `expiresAt.Should().BeAfter(createdAt)` | Compute exact period and assert |
| `Verify(x => ..., It.IsAny<T>())` | `Verify(x => ..., exactArg)` |
| 2+ sequential `.Should().Be()` calls | `actual.Should().BeEquivalentTo(expected)` (record eq) |
