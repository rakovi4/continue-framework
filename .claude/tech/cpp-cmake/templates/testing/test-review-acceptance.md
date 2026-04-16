# Test Review Patterns: Acceptance Layer (C++/Google Test)

C++/Google Test code examples for acceptance test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## C++-Specific Rules (Acceptance)

1. **Use descriptive failure messages** -- add `<< "description"` to assertions for clear failure output
2. **Implement operator== on structs** -- enables `EXPECT_EQ(actual, expected)` for structural comparison
3. **Use time_point truncation** -- for timestamp comparisons, truncate to seconds to avoid sub-second mismatches

## Anti-Pattern Examples

### BAD: Loose String Validation
```cpp
EXPECT_NE(set_cookie.find("SESSION="), std::string::npos);
EXPECT_NE(set_cookie.find("Max-Age=0"), std::string::npos);
EXPECT_TRUE(response_body.find("\"email\":") != std::string::npos);
```

### BAD: EXPECT_NE(npos) instead of exact value
```cpp
EXPECT_NE(response.masked_token().find("****"), std::string::npos);
// GOOD: exact match
EXPECT_EQ(response.masked_token(), "****5678");
```

### BAD: EXPECT_TRUE(has_value()) when actual value should be checked
```cpp
EXPECT_TRUE(response.token_type().has_value());  // Should verify equals "Bearer"
EXPECT_TRUE(response.expires_at().has_value());   // Should verify actual date
// GOOD:
EXPECT_EQ(response.token_type(), "Bearer");
```

### BAD: !empty() for values capturable from setup
```cpp
task_statements.given_user_with_task(TASK_ID);
// ...
EXPECT_FALSE(entry.task_id().empty()) << "Task ID";   // LOOSE
EXPECT_FALSE(entry.reason().empty()) << "Reason";     // LOOSE
// GOOD: capture from setup, assert exact values
auto task_id = task_statements.given_user_with_task(TASK_ID);
EXPECT_EQ(entry.task_id(), task_id) << "Task ID";
EXPECT_EQ(entry.reason(), "Update failed") << "Reason";
```

### BAD: Missing field assertions
```cpp
void assert_task_exists(const GetTaskStatusResponse& response) {
    EXPECT_TRUE(response.exists());
    EXPECT_FALSE(response.title().empty());
    // MISSING: description, column_id, status
}
```

### BAD: Timestamp assertions without actual time comparison
```cpp
EXPECT_TRUE(response.created_at().has_value()) << "created at timestamp";
// GOOD:
auto now = std::chrono::system_clock::now();
EXPECT_GE(response.created_at(), now - std::chrono::seconds(30));
EXPECT_LE(response.created_at(), now + std::chrono::seconds(1));
```

### BAD: EXPECT_GT/LT when exact value is deterministic
```cpp
EXPECT_GT(response.days_remaining(), 0);
EXPECT_LE(response.days_remaining(), 7);
// GOOD:
EXPECT_EQ(response.days_remaining(), 7);
```

### BAD: Asserting only first element in collection
```cpp
EXPECT_EQ(response.tasks().size(), 3);
EXPECT_EQ(response.tasks()[0].id(), "task-001");
// MISSING: [1] and [2] never checked
// GOOD: use ElementsAre for all elements
EXPECT_THAT(response.tasks(), ElementsAre(
    TaskMatcher("task-001", "Task 1", "ACTIVE"),
    TaskMatcher("task-002", "Task 2", "PENDING"),
    TaskMatcher("task-003", "Task 3", "DONE")
));
```

### BAD: Asserting only IDs without full object contents
```cpp
EXPECT_EQ(card.id(), 11111);
// MISSING: title, status, assignee, priority, due_date
// GOOD: assert all fields
EXPECT_EQ(card.id(), 11111) << "card ID";
EXPECT_EQ(card.title(), "Task 1") << "title";
EXPECT_EQ(card.status(), "TODO") << "status";
EXPECT_EQ(card.assignee(), "user@example.com") << "assignee";
EXPECT_EQ(card.priority(), "HIGH") << "priority";
EXPECT_EQ(card.due_date(), "2026-04-15") << "due date";
```

## Correct Patterns

### GOOD: Descriptive Assertions
```cpp
EXPECT_EQ(cookie.name(), "SESSION") << "session cookie name";
EXPECT_EQ(cookie.max_age(), "0") << "cookie expiration for logout";
```

### GOOD: Collection Assertions with Matchers
```cpp
EXPECT_THAT(response.permissions(), ElementsAre("Read", "Write"));
EXPECT_THAT(response.tasks(), UnorderedElementsAre(
    TaskMatcher("task-001", "Active"),
    TaskMatcher("task-002", "Pending")
));
```

### GOOD: Complete Response Validation
```cpp
void assert_task_exists(const GetTaskStatusResponse& response) {
    EXPECT_TRUE(response.exists()) << "exists flag";
    EXPECT_EQ(response.title(), EXPECTED_TITLE) << "title";
    EXPECT_EQ(response.description(), EXPECTED_DESCRIPTION) << "description";
    EXPECT_EQ(response.column_id(), EXPECTED_COLUMN_ID) << "column ID";
    EXPECT_EQ(response.status(), EXPECTED_STATUS) << "status";
    auto now = std::chrono::system_clock::now();
    EXPECT_GE(response.created_at(), now - std::chrono::seconds(30)) << "created at lower bound";
    EXPECT_LE(response.created_at(), now + std::chrono::seconds(1)) << "created at upper bound";
}
```

### GOOD: Timestamp Assertions with Truncation
```cpp
auto now = std::chrono::time_point_cast<std::chrono::seconds>(std::chrono::system_clock::now());
auto actual = std::chrono::time_point_cast<std::chrono::seconds>(response.created_at());
EXPECT_EQ(actual, now) << "created at timestamp (truncated to seconds)";
```

## Assertion Improvements (C++/Google Test Syntax)

| Before (Loose) | After (Strict) |
|----------------|----------------|
| `EXPECT_NE(json.find("email"), npos)` | `EXPECT_EQ(parsed.email(), expected)` |
| `EXPECT_TRUE(response.find(id) != npos)` | `EXPECT_EQ(parsed.id(), id)` |
| `EXPECT_NE(header.find("Bearer"), npos)` | `EXPECT_EQ(auth.type(), "Bearer")` |
| `EXPECT_NE(masked.find("****"), npos)` | `EXPECT_EQ(masked, "****" + expected_last4)` |
| `EXPECT_TRUE(field.has_value())` | `EXPECT_EQ(field.value(), expected_value)` |
| `EXPECT_FALSE(field.empty())` | `EXPECT_EQ(field, expected_value)` |
| `EXPECT_GT(n, 0); EXPECT_LE(n, 7)` | `EXPECT_EQ(n, 7)` (if deterministic) |
| `EXPECT_THAT(list, Contains(item))` | `EXPECT_THAT(list, ElementsAre(...))` |
| `EXPECT_TRUE(ts.has_value())` | `EXPECT_GE(ts, now - 30s); EXPECT_LE(ts, now)` |
| 2+ sequential `EXPECT_EQ(a.x, b.x)` | `EXPECT_EQ(a, b)` with `operator==` |
