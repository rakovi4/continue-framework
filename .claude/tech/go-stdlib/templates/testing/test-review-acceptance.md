# Test Review Patterns: Acceptance Layer (Go/stdlib)

Go/testify code examples for acceptance test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Go-Specific Rules (Acceptance)

1. **Use assert message parameter** -- always pass a description string as the last argument to `assert.*` / `require.*` for clear failure messages
2. **Extract validation helper types** -- parsing logic (e.g., `SetCookie` parser) belongs in helper types, not inline in Statements
3. **Prefer assert.Equal on structs** -- replace 2+ sequential per-field `assert.Equal` calls with a single struct comparison
4. **Use assert.WithinDuration for timestamps** -- for `time.Time` comparisons to avoid precision mismatches

## Anti-Pattern Examples

### BAD: Loose String Validation
```go
assert.Contains(t, setCookie, "SESSION=")
assert.Contains(t, setCookie, "Max-Age=0")
assert.Contains(t, responseBody, `"email":`)
```

### BAD: Multiple Contains() chains
```go
assert.Contains(t, setCookie, "SESSION=")
assert.Contains(t, setCookie, "Path=/")
assert.Contains(t, setCookie, "HttpOnly")
```

### BAD: strings.HasPrefix without verifying actual content
```go
assert.True(t, strings.HasPrefix(response.MaskedToken, "****"))
// Does NOT verify if "****5678" matches expected "5678"

assert.Regexp(t, `\*{4}\w{4}`, response.MaskedToken)
// Does NOT verify the real last 4 chars
```

### BAD: assert.NotNil when actual value should be checked
```go
assert.NotNil(t, response.TokenType)  // Should verify equals "Bearer"
assert.NotNil(t, response.ExpiresAt)  // Should verify actual date
```

### BAD: assert.NotNil for values capturable from setup
```go
s.GivenUserWithTask(taskID)
// ...
assert.NotNil(t, entry.TaskID, "Task ID")      // LOOSE
assert.NotNil(t, entry.Reason, "Reason")        // LOOSE
assert.NotNil(t, entry.CreatedAt, "Timestamp")  // LOOSE

// GOOD: capture from setup, assert exact values
taskID := s.GivenUserWithTask(taskID)
// ...
assert.Equal(t, taskID, entry.TaskID, "Task ID")
assert.Equal(t, "Update failed", entry.Reason, "Reason")
assert.WithinDuration(t, time.Now(), entry.CreatedAt, 30*time.Second, "Timestamp")
```

### BAD: Missing field assertions
```go
func (s *TaskStatements) AssertTaskExists(response GetTaskStatusResponse) {
    assert.True(s.t, response.Exists)
    assert.NotNil(s.t, response.Title)
    assert.NotNil(s.t, response.CreatedAt)
    // MISSING: Description, ColumnID, Status
}
```

### BAD: Empty collections in expected values
```go
assert.Equal(t, []string{}, response.Permissions)
// Should be: assert.Equal(t, []string{"Read", "Write"}, response.Permissions)
```

### BAD: Timestamp assertions without actual time comparison
```go
assert.NotNil(t, response.CreatedAt, "created at timestamp")
// Should verify approximately NOW

assert.True(t, response.ExpiresAt.After(response.CreatedAt), "expiration date")
// Should verify actual expected date
```

### BAD: .After()/.Before() when exact period is deterministic
```go
assert.True(t, response.ExpiresAt.After(time.Now()))
// Should compute exact expected expiration

assert.True(t, response.ExpiresAt.After(response.StartedAt))
// Should assert: expiresAt - startedAt == 30 days
```

### BAD: assert.NotEmpty instead of exact value
```go
assert.NotEmpty(t, response.Message)       // Should use assert.Equal
assert.NotEmpty(t, response.TokenMasked)   // Should use assert.Equal
assert.NotEmpty(t, response.Permissions)   // Should use assert.Equal
```

### BAD: Range checks when exact value is deterministic
```go
assert.Greater(t, response.DaysRemaining, 0)
assert.LessOrEqual(t, response.DaysRemaining, 7)
// Should be: assert.Equal(t, 7, response.DaysRemaining)

assert.True(t, response.RetryCount >= 1 && response.RetryCount <= 5)
// Should be: assert.Equal(t, 3, response.RetryCount)
```

### BAD: assert.Contains on collections instead of exact match
```go
assert.Contains(t, response.Permissions, "Edit Tasks")
// Should use assert.Equal to verify ALL permissions
```

### BAD: Asserting only first item in a collection
```go
assert.Len(t, response.Tasks, 3)
assert.Equal(t, "task-001", response.Tasks[0].ID)
// MISSING: Tasks[1] and Tasks[2] are never checked

// GOOD: assert ALL tasks
assert.Equal(t, expectedTasks, response.Tasks)
```

### BAD: Asserting only IDs without full object contents
```go
assert.Equal(t, 11111, card.ID)
// MISSING: Title, Status, Assignee, Priority, DueDate

// GOOD: assert all fields via struct comparison
assert.Equal(t, expectedCard, card)
```

## Correct Patterns

### GOOD: Parse-then-Assert Pattern
```go
cookie := parseCookie(recorder.Header().Get("Set-Cookie"))

assert.Equal(t, "SESSION", cookie.Name, "cookie name")
assert.Equal(t, "", cookie.Value, "session value")
assert.Equal(t, "0", cookie.MaxAge, "max age")
assert.Equal(t, "/", cookie.Path, "cookie path")
assert.True(t, cookie.HttpOnly, "http only flag")
```

### GOOD: Extract Validation Helper Type
```go
type SetCookie struct {
    Name     string
    Value    string
    MaxAge   string
    Path     string
    HttpOnly bool
}

func parseCookie(raw string) SetCookie {
    // parse "SESSION=; Path=/; Max-Age=0; HttpOnly" into struct
    // ...
}
```

### GOOD: Timestamp Assertions with Precision
```go
assert.WithinDuration(t, time.Now(), response.CreatedAt, 30*time.Second, "created at timestamp")
assert.WithinDuration(t, time.Now().Add(30*24*time.Hour), response.ExpiresAt, 30*time.Second, "expiration date")
```

### GOOD: Collection Assertions with Expected Constants
```go
var expectedPermissions = []string{"Read", "Write"}

assert.Equal(t, expectedPermissions, response.Permissions, "token permissions")
```

### GOOD: Complete Response Validation
```go
func (s *TaskStatements) AssertTaskExists(response GetTaskStatusResponse) {
    assert.True(s.t, response.Exists, "exists flag")
    assert.Equal(s.t, expectedTitle, response.Title, "title")
    assert.Equal(s.t, expectedDescription, response.Description, "description")
    assert.Equal(s.t, expectedColumnID, response.ColumnID, "column ID")
    assert.WithinDuration(s.t, time.Now(), response.CreatedAt, 30*time.Second, "created at")
    assert.Equal(s.t, expectedStatus, response.Status, "status")
}
```

### GOOD: Struct Equality
```go
assert.Equal(t, expected, actual)

// Unordered collections
assert.ElementsMatch(t, expected, actual)
```

### GOOD: Error Assertions
```go
// Sentinel error
assert.ErrorIs(t, err, domain.ErrTaskNotFound)

// Typed error
var validationErr *domain.ValidationError
require.ErrorAs(t, err, &validationErr)
assert.Equal(t, "email", validationErr.Field)
```

## Assertion Improvements (Go/testify Syntax)

| Before (Loose) | After (Strict) |
|----------------|----------------|
| `assert.Contains(t, body, "email")` | `assert.Equal(t, expected, parsed.Email)` |
| `assert.Regexp(t, ".*token.*", body)` | `assert.Equal(t, expectedToken, parsed.Token)` |
| `assert.True(t, strings.Contains(resp, id))` | `assert.Equal(t, id, parsed.ID)` |
| `assert.True(t, strings.HasPrefix(h, "Bearer"))` | `assert.Equal(t, "Bearer", auth.Type)` |
| `assert.True(t, strings.HasPrefix(m, "****"))` | `assert.Equal(t, "****"+expectedLast4, masked)` |
| `assert.NotNil(t, field)` | `assert.Equal(t, expectedValue, field)` |
| `assert.NotEmpty(t, field)` | `assert.Equal(t, expectedValue, field)` |
| `assert.Greater(t, n, 0); assert.LessOrEqual(t, n, 7)` | `assert.Equal(t, 7, n)` (if deterministic) |
| `assert.Contains(t, list, item)` | `assert.Equal(t, expectedList, list)` |
| `assert.Equal(t, []string{}, perms)` | `assert.Equal(t, expectedPermissions, perms)` |
| `assert.NotNil(t, timestamp)` | `assert.WithinDuration(t, expected, ts, 30*time.Second)` |
| `assert.True(t, expiresAt.After(createdAt))` | Compute exact expected duration and assert |
| 2+ sequential `assert.Equal(t, ...)` on fields | `assert.Equal(t, expectedStruct, actualStruct)` |
| `mock.Anything` | Exact expected value |
| `assert.True(t, ok)` | `require.NoError(t, err)` + assert result |
