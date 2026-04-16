# Test Review Patterns: Acceptance Layer (Node/TypeScript)

TypeScript/Vitest code examples for acceptance test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## TypeScript-Specific Rules (Acceptance)

1. **Extract validation helper classes** -- parsing logic (e.g., `SetCookie` parser) belongs in helper classes
2. **Prefer toEqual() for structural comparison** -- replace 2+ sequential per-field assertions with `expect(actual).toEqual(expected)` using a constructed expected object
3. **Use minute-truncation for timestamp comparisons** -- truncate to minutes before comparing to avoid millisecond mismatches

## Anti-Pattern Examples

### BAD: Loose String Validation
```typescript
expect(setCookie).toContain("SESSION=");
expect(setCookie).toContain("Max-Age=0");
expect(response.body).toContain('"email":');
```

### BAD: Multiple toContain() chains
```typescript
expect(setCookie).toContain("SESSION=");
expect(setCookie).toContain("Path=/");
expect(setCookie).toContain("HttpOnly");
```

### BAD: startsWith/toMatch without verifying actual content
```typescript
expect(response.maskedToken).toMatch(/^\*{4}/);
// Does NOT verify if "****5678" matches expected "5678"

expect(response.maskedToken).toMatch(/^\*{4}\w{4}$/);
// Does NOT verify the real last 4 chars
```

### BAD: toBeDefined() when actual value should be checked
```typescript
expect(response.tokenType).toBeDefined();
// Should verify equals "Bearer" or expected type

expect(response.expiresAt).toBeDefined();
// Should verify actual date/relationship to other dates
```

### BAD: toBeDefined() for values capturable from setup
```typescript
await taskStatements.givenUserWithTask(TASK_ID);
// ...
expect(entry.taskId).toBeDefined();  // LOOSE — taskId IS known
expect(entry.reason).toBeDefined();   // LOOSE — we define the message
expect(entry.createdAt).toBeDefined(); // LOOSE — can bound tightly
// GOOD: capture taskId from setup, define exact reason, bound timestamp
const taskId = await taskStatements.givenUserWithTask(TASK_ID);
// ...
expect(entry.taskId).toEqual(taskId);
expect(entry.reason).toEqual("Update failed");
expect(new Date(entry.createdAt).getTime())
    .toBeGreaterThan(Date.now() - 30_000);
```

### BAD: Missing field assertions
```typescript
function assertTaskExists(response: GetTaskStatusResponse) {
    expect(response.exists).toBe(true);
    expect(response.title).toBeDefined();
    expect(response.createdAt).toBeDefined();
    // MISSING: description, columnId, status
}
```

### BAD: Empty collections in expected values
```typescript
expect(response.permissions).toEqual([]);
// Should be: expect(response.permissions).toEqual(["Read", "Write"])
```

### BAD: Timestamp assertions without actual time comparison
```typescript
expect(response.createdAt).toBeDefined();
// Should verify it's approximately NOW

expect(response.expiresAt > response.createdAt).toBe(true);
// Should verify actual expected date (e.g., 30 days from now)
```

### BAD: Comparison when exact period is deterministic
```typescript
expect(new Date(response.expiresAt).getTime())
    .toBeGreaterThan(Date.now());
// Should compute and assert exact expected expiration

expect(response.expiresAt > response.startedAt).toBe(true);
// Should assert the exact period
```

### BAD: toBeTruthy()/toBeFalsy() instead of exact value
```typescript
expect(response.message).toBeTruthy();
// Should use toEqual(EXPECTED_MESSAGE)
```

### BAD: Range checks when exact value is deterministic
```typescript
expect(response.daysRemaining).toBeGreaterThan(0);
expect(response.daysRemaining).toBeLessThanOrEqual(7);
// Should be toEqual(7) if test setup makes value deterministic

expect(response.retryCount).toBeGreaterThanOrEqual(1);
expect(response.retryCount).toBeLessThanOrEqual(5);
// Should be toEqual(3) if value is known from setup
```

### BAD: toContain() on collections instead of exact match
```typescript
expect(response.permissions).toContain("Edit Tasks");
// GOOD: verify ALL permissions
expect(response.permissions).toEqual(EXPECTED_PERMISSIONS);
```

### BAD: Asserting only first item in a collection
```typescript
expect(response.tasks).toHaveLength(3);
expect(response.tasks[0].id).toEqual("task-001");
// MISSING: tasks[1] and tasks[2] are never checked
// GOOD: assert ALL tasks
assertTask(response.tasks[0], "task-001", "Task 1", "ACTIVE", "HIGH");
assertTask(response.tasks[1], "task-002", "Task 2", "PENDING", "MEDIUM");
assertTask(response.tasks[2], "task-003", "Task 3", "DONE", "LOW");
```

### BAD: Asserting only IDs without full object contents
```typescript
expect(card.id).toEqual(11111);
// MISSING: title, status, assignee, priority, dueDate
// GOOD: assert all fields
expect(card.id).toEqual(11111);
expect(card.title).toEqual("Task 1");
expect(card.status).toEqual("TODO");
expect(card.assignee).toEqual("user@example.com");
expect(card.priority).toEqual("HIGH");
expect(card.dueDate).toEqual("2026-04-15");
```

## Correct Patterns

### GOOD: Parse-then-Assert Pattern
```typescript
const cookie = new SetCookie(headers);

expect(cookie.name).toEqual("SESSION");
expect(cookie.value).toEqual("");
expect(cookie.maxAge).toEqual("0");
expect(cookie.path).toEqual("/");
expect(cookie.httpOnly).toBe(true);
```

### GOOD: Timestamp Assertions with Precision
```typescript
const truncateToMinutes = (d: Date) => new Date(Math.floor(d.getTime() / 60000) * 60000);

expect(truncateToMinutes(new Date(response.createdAt)))
    .toEqual(truncateToMinutes(new Date()));

expect(truncateToMinutes(new Date(response.expiresAt)))
    .toEqual(truncateToMinutes(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)));
```

### GOOD: Collection Assertions with Expected Constants
```typescript
const EXPECTED_PERMISSIONS = ["Read", "Write"];
expect(response.permissions).toEqual(EXPECTED_PERMISSIONS);
```

### GOOD: Complete Response Validation
```typescript
function assertTaskExists(response: GetTaskStatusResponse) {
    expect(response.exists).toBe(true);
    expect(response.title).toEqual(EXPECTED_TITLE);
    expect(response.description).toEqual(EXPECTED_DESCRIPTION);
    expect(response.columnId).toEqual(EXPECTED_COLUMN_ID);
    expect(new Date(response.createdAt).getTime())
        .toBeGreaterThan(Date.now() - 30_000);
    expect(response.status).toEqual(EXPECTED_STATUS);
}
```

## Assertion Improvements (TypeScript/Vitest Syntax)

| Before (Loose) | After (Strict) |
|----------------|----------------|
| `expect(json).toContain("email")` | `expect(parsed.email).toEqual(expected)` |
| `expect(body).toMatch(/.*token.*/)` | `expect(parsed.token).toEqual(expectedToken)` |
| `expect(response).toContain(id)` | `expect(parsed.id).toEqual(id)` |
| `expect(header).toMatch(/^Bearer/)` | `expect(auth.type).toEqual("Bearer")` |
| `expect(masked).toMatch(/^\*{4}/)` | `expect(masked).toEqual("****" + expectedLast4)` |
| `expect(field).toBeDefined()` | `expect(field).toEqual(expectedValue)` |
| `expect(field).toBeTruthy()` | `expect(field).toEqual(EXPECTED_MESSAGE)` |
| `expect(n).toBeGreaterThan(0)` | `expect(n).toEqual(7)` (if deterministic) |
| `expect(list).toContain(item)` | `expect(list).toEqual(EXPECTED_LIST)` |
| `expect(permissions).toEqual([])` | `expect(permissions).toEqual(EXPECTED_PERMISSIONS)` |
| `expect(timestamp).toBeDefined()` | Truncate to minutes, compare with `toEqual` |
| `expect(expiresAt > createdAt).toBe(true)` | Compute exact period and assert |
| `expect.any(...)` in mock setup | `toHaveBeenCalledWith(exact, args)` |
