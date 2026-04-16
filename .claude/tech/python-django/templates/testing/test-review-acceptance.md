# Test Review Patterns: Acceptance Layer (Python/Django)

Python/pytest code examples for acceptance test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Python-Specific Rules (Acceptance)

1. **Use descriptive assertion messages** -- add a second argument to `assert` for clear failure messages
2. **Extract validation helper classes** -- parsing logic (e.g., `SetCookie` parser) belongs in helper classes
3. **Prefer dataclass equality** -- replace 2+ sequential per-field `assert` calls with `assert actual == expected` (frozen dataclasses do deep structural comparison by default)
4. **Use `truncate_to_minutes()`** -- for datetime comparisons to avoid microsecond mismatches

## Anti-Pattern Examples

### BAD: Loose String Validation
```python
assert "SESSION=" in set_cookie
assert "Max-Age=0" in set_cookie
assert '"email":' in response.json()
```

### BAD: Multiple `in` chains
```python
assert "SESSION=" in set_cookie
assert "Path=/" in set_cookie
assert "HttpOnly" in set_cookie
```

### BAD: startsWith/matches without verifying actual content
```python
assert response.masked_token.startswith("****")
# Does NOT verify if "****5678" matches expected "5678"

import re
assert re.match(r"\*{4}\w{4}", response.masked_token)
# Does NOT verify the real last 4 chars
```

### BAD: `is not None` when actual value should be checked
```python
assert response.token_type is not None
# Should verify equals "Bearer"

assert response.expires_at is not None
# Should verify actual date
```

### BAD: `is not None` for values capturable from setup
```python
task_statements.given_user_with_task(TASK_ID)
# ...
assert entry.task_id is not None  # LOOSE
assert entry.reason is not None    # LOOSE
assert entry.created_at is not None # LOOSE
# GOOD: capture from setup, assert exact values
task_id = task_statements.given_user_with_task(TASK_ID)
# ...
assert entry.task_id == task_id
assert entry.reason == "Update failed"
from datetime import datetime, timedelta
assert datetime.fromisoformat(entry.created_at) > datetime.now() - timedelta(seconds=30)
```

### BAD: Missing field assertions
```python
def assert_task_exists(response):
    assert response.exists is True
    assert response.title is not None
    assert response.created_at is not None
    # MISSING: description, column_id, status
```

### BAD: Empty collections in expected values
```python
assert response.permissions == []
# Should be: assert response.permissions == ["Read", "Write"]
```

### BAD: Timestamp assertions without actual time comparison
```python
assert response.created_at is not None
# Should verify approximately NOW

assert response.expires_at > response.created_at
# Should verify actual expected date
```

### BAD: Comparison when exact period is deterministic
```python
assert response.expires_at > datetime.now()
# Should compute exact expected expiration

assert response.expires_at > response.started_at
# Should assert the exact period: (expires - started).days == 30
```

### BAD: Truthy check instead of exact value
```python
assert response.message
# Should use assert response.message == EXPECTED_MESSAGE
```

### BAD: Range checks when exact value is deterministic
```python
assert 0 < response.days_remaining <= 7
# Should be assert response.days_remaining == 7

assert 1 <= response.retry_count <= 5
# Should be assert response.retry_count == 3
```

### BAD: `in` on collections instead of exact match
```python
assert "Edit Tasks" in response.permissions
# GOOD: verify ALL permissions
assert response.permissions == EXPECTED_PERMISSIONS
```

### BAD: Asserting only first item in a collection
```python
assert len(response.tasks) == 3
assert response.tasks[0].id == "task-001"
# MISSING: tasks[1] and tasks[2] are never checked
# GOOD: assert ALL tasks
assert_task(response.tasks[0], "task-001", "Task 1", "ACTIVE", "HIGH")
assert_task(response.tasks[1], "task-002", "Task 2", "PENDING", "MEDIUM")
assert_task(response.tasks[2], "task-003", "Task 3", "DONE", "LOW")
```

### BAD: Asserting only IDs without full object contents
```python
assert card.id == 11111
# MISSING: title, status, assignee, priority, due_date
# GOOD: assert all fields
assert card.id == 11111
assert card.title == "Task 1"
assert card.status == "TODO"
assert card.assignee == "user@example.com"
assert card.priority == "HIGH"
assert card.due_date == "2026-04-15"
```

## Correct Patterns

### GOOD: Parse-then-Assert Pattern
```python
cookie = SetCookie(headers)

assert cookie.name == "SESSION", "cookie name"
assert cookie.value == "", "session value"
assert cookie.max_age == "0", "max age"
assert cookie.path == "/", "cookie path"
assert cookie.http_only is True, "http only flag"
```

### GOOD: Extract Validation Helper Class
```python
class SetCookie:
    def __init__(self, headers):
        self._set_cookie = headers.get("Set-Cookie", "")
        self._attributes = self._parse_attributes()

    @property
    def name(self) -> str:
        return self._parts()[0].split("=")[0]

    @property
    def value(self) -> str:
        return self._parts()[0].split("=", 1)[1]

    @property
    def max_age(self) -> str:
        return self._attributes.get("Max-Age", "")

    @property
    def path(self) -> str:
        return self._attributes.get("Path", "")

    @property
    def http_only(self) -> bool:
        return "HttpOnly" in self._attributes

    def _parts(self) -> list[str]:
        return self._set_cookie.split(";")

    def _parse_attributes(self) -> dict[str, str]:
        # ...
        pass
```

### GOOD: Timestamp Assertions with Precision
```python
from datetime import datetime, timedelta

def truncate_to_minutes(dt: datetime) -> datetime:
    return dt.replace(second=0, microsecond=0)

assert truncate_to_minutes(response.created_at) == truncate_to_minutes(datetime.now())
assert truncate_to_minutes(response.expires_at) == truncate_to_minutes(
    datetime.now() + timedelta(days=30)
)
```

### GOOD: Collection Assertions with Expected Constants
```python
EXPECTED_PERMISSIONS = ["Read", "Write"]
assert response.permissions == EXPECTED_PERMISSIONS, "token permissions"
```

### GOOD: Complete Response Validation
```python
def assert_task_exists(response):
    assert response.exists is True, "exists flag"
    assert response.title == EXPECTED_TITLE, "title"
    assert response.description == EXPECTED_DESCRIPTION, "description"
    assert response.column_id == EXPECTED_COLUMN_ID, "column ID"
    assert response.created_at > datetime.now() - timedelta(seconds=30), "created at"
    assert response.status == EXPECTED_STATUS, "status"
```

### GOOD: Dataclass Equality (recursive comparison)
```python
# Replace 2+ per-field assertions with dataclass equality
assert actual == expected  # frozen dataclasses compare all fields recursively
```

## Assertion Improvements (Python/pytest Syntax)

| Before (Loose) | After (Strict) |
|----------------|----------------|
| `assert "email" in json_str` | `assert parsed.email == expected` |
| `assert re.match(r".*token.*", body)` | `assert parsed.token == expected_token` |
| `assert id in response` | `assert parsed.id == id` |
| `assert header.startswith("Bearer")` | `assert auth.type == "Bearer"` |
| `assert masked.startswith("****")` | `assert masked == "****" + expected_last4` |
| `assert field is not None` | `assert field == expected_value` |
| `assert field` (truthy) | `assert field == EXPECTED_MESSAGE` |
| `assert n > 0 and n <= 7` | `assert n == 7` (if deterministic) |
| `assert item in collection` | `assert collection == EXPECTED_LIST` |
| `assert permissions == []` | `assert permissions == EXPECTED_PERMISSIONS` |
| `assert timestamp is not None` | Truncate to minutes, compare with `==` |
| `assert expires_at > created_at` | Compute exact period and assert |
| `mock.assert_called_once_with(..., ANY)` | `mock.assert_called_once_with(..., exact_arg)` |
| 2+ sequential `assert x.field == val` | `assert actual == expected` (dataclass eq) |
