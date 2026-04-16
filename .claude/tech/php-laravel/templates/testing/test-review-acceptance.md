# Test Review Patterns: Acceptance Layer (PHP/Laravel)

PHP/PHPUnit code examples for acceptance test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## PHP-Specific Rules (Acceptance)

1. **Use descriptive assertion messages** -- add a third argument to `assertEquals` or use named assertions for clear failure messages
2. **Extract validation helper classes** -- parsing logic (e.g., `SetCookie` parser) belongs in helper classes
3. **Prefer object equality** -- replace 2+ sequential per-field `assertEquals` calls with `assertEquals($expected, $actual)` (PHPUnit does deep structural comparison on objects)
4. **Truncate timestamps before comparing** -- use `->setTime(H, i, 0)` or `->format('Y-m-d H:i')` to avoid second/millisecond mismatches

## Anti-Pattern Examples

### BAD: Loose String Validation
```php
$this->assertStringContainsString('SESSION=', $setCookie);
$this->assertStringContainsString('Max-Age=0', $setCookie);
$this->assertStringContainsString('"email":', $responseBody);
```

### BAD: startsWith/matches without verifying actual content
```php
$this->assertStringStartsWith('****', $response->maskedToken);
// Does NOT verify if "****5678" matches expected "5678"

$this->assertMatchesRegularExpression('/\*{4}\w{4}/', $response->maskedToken);
// Does NOT verify the real last 4 chars
```

### BAD: `assertNotNull` when actual value should be checked
```php
$this->assertNotNull($response->tokenType);
// Should verify equals "Bearer"

$this->assertNotNull($response->expiresAt);
// Should verify actual date
```

### BAD: `assertNotNull` for values capturable from setup
```php
$this->taskStatements->givenUserWithTask(TASK_ID);
// ...
$this->assertNotNull($entry->taskId);    // LOOSE
$this->assertNotNull($entry->reason);     // LOOSE
$this->assertNotNull($entry->createdAt);  // LOOSE
// GOOD: capture from setup, assert exact values
$taskId = $this->taskStatements->givenUserWithTask(TASK_ID);
// ...
$this->assertEquals($taskId, $entry->taskId);
$this->assertEquals('Update failed', $entry->reason);
$this->assertGreaterThan(
    (new DateTimeImmutable())->modify('-30 seconds'),
    new DateTimeImmutable($entry->createdAt)
);
```

### BAD: Missing field assertions
```php
public function assertTaskExists($response): void
{
    $this->assertTrue($response->exists);
    $this->assertNotNull($response->title);
    $this->assertNotNull($response->createdAt);
    // MISSING: description, columnId, status
}
```

### BAD: Empty collections in expected values
```php
$this->assertEquals([], $response->permissions);
// Should be: $this->assertEquals(['Read', 'Write'], $response->permissions);
```

### BAD: Timestamp assertions without actual time comparison
```php
$this->assertNotNull($response->createdAt);
// Should verify approximately NOW

$this->assertGreaterThan($response->createdAt, $response->expiresAt);
// Should verify actual expected date
```

### BAD: Truthy check instead of exact value
```php
$this->assertNotEmpty($response->message);
// Should use $this->assertEquals(EXPECTED_MESSAGE, $response->message);
```

### BAD: Range checks when exact value is deterministic
```php
$this->assertGreaterThan(0, $response->daysRemaining);
$this->assertLessThanOrEqual(7, $response->daysRemaining);
// Should be $this->assertEquals(7, $response->daysRemaining);
```

### BAD: Asserting only first item in a collection
```php
$this->assertCount(3, $response->tasks);
$this->assertEquals('task-001', $response->tasks[0]->id);
// MISSING: tasks[1] and tasks[2] are never checked
// GOOD: assert ALL tasks
$this->assertTask($response->tasks[0], 'task-001', 'Task 1', 'ACTIVE', 'HIGH');
$this->assertTask($response->tasks[1], 'task-002', 'Task 2', 'PENDING', 'MEDIUM');
$this->assertTask($response->tasks[2], 'task-003', 'Task 3', 'DONE', 'LOW');
```

### BAD: Asserting only IDs without full object contents
```php
$this->assertEquals(11111, $card->id);
// MISSING: title, status, assignee, priority, dueDate
// GOOD: assert all fields
$this->assertEquals(11111, $card->id);
$this->assertEquals('Task 1', $card->title);
$this->assertEquals('TODO', $card->status);
$this->assertEquals('user@example.com', $card->assignee);
$this->assertEquals('HIGH', $card->priority);
$this->assertEquals('2026-04-15', $card->dueDate);
```

## Correct Patterns

### GOOD: Parse-then-Assert Pattern
```php
$cookie = new SetCookie($headers);

$this->assertEquals('SESSION', $cookie->name, 'cookie name');
$this->assertEquals('', $cookie->value, 'session value');
$this->assertEquals('0', $cookie->maxAge, 'max age');
$this->assertEquals('/', $cookie->path, 'cookie path');
$this->assertTrue($cookie->httpOnly, 'http only flag');
```

### GOOD: Timestamp Assertions with Precision
```php
$truncateToMinutes = fn(DateTimeImmutable $dt) =>
    $dt->setTime((int)$dt->format('H'), (int)$dt->format('i'), 0);

$this->assertEquals(
    $truncateToMinutes(new DateTimeImmutable()),
    $truncateToMinutes($response->createdAt)
);
$this->assertEquals(
    $truncateToMinutes((new DateTimeImmutable())->modify('+30 days')),
    $truncateToMinutes($response->expiresAt)
);
```

### GOOD: Collection Assertions with Expected Constants
```php
$this->assertEquals(
    self::EXPECTED_PERMISSIONS,
    $response->permissions,
    'token permissions'
);
```

### GOOD: Complete Response Validation
```php
public function assertTaskExists($response): void
{
    $this->assertTrue($response->exists, 'exists flag');
    $this->assertEquals(self::EXPECTED_TITLE, $response->title, 'title');
    $this->assertEquals(self::EXPECTED_DESCRIPTION, $response->description, 'description');
    $this->assertEquals(self::EXPECTED_COLUMN_ID, $response->columnId, 'column ID');
    $this->assertGreaterThan(
        (new DateTimeImmutable())->modify('-30 seconds'),
        new DateTimeImmutable($response->createdAt),
        'created at'
    );
    $this->assertEquals(self::EXPECTED_STATUS, $response->status, 'status');
}
```

### GOOD: Object Equality (recursive comparison)
```php
// Replace 2+ per-field assertions with object equality
$this->assertEquals($expected, $actual); // PHPUnit compares all properties recursively
```

## Assertion Improvements (PHP/PHPUnit Syntax)

| Before (Loose) | After (Strict) |
|----------------|----------------|
| `assertStringContainsString('email', $json)` | `assertEquals($expected, $parsed->email)` |
| `assertMatchesRegularExpression('/.*token.*/', $body)` | `assertEquals($expectedToken, $parsed->token)` |
| `assertArrayHasKey('id', $response)` | `assertEquals($id, $parsed->id)` |
| `assertStringStartsWith('Bearer', $header)` | `assertEquals('Bearer', $auth->type)` |
| `assertStringStartsWith('****', $masked)` | `assertEquals('****' . $expectedLast4, $masked)` |
| `assertNotNull($field)` | `assertEquals($expectedValue, $field)` |
| `assertNotEmpty($field)` (truthy) | `assertEquals(EXPECTED_MESSAGE, $field)` |
| `assertGreaterThan(0, $n) + assertLessThanOrEqual(7, $n)` | `assertEquals(7, $n)` (if deterministic) |
| `assertContains($item, $collection)` | `assertEquals(EXPECTED_LIST, $collection)` |
| `assertEquals([], $permissions)` | `assertEquals(EXPECTED_PERMISSIONS, $permissions)` |
| `assertNotNull($timestamp)` | Truncate to minutes, compare with `assertEquals` |
| `assertGreaterThan($created, $expires)` | Compute exact period and assert |
| `shouldHaveReceived(...)->with(..., Mockery::any())` | `shouldHaveReceived(...)->with(..., $exactArg)` |
| 2+ sequential `assertEquals($val, $obj->field)` | `assertEquals($expected, $actual)` (object eq) |
