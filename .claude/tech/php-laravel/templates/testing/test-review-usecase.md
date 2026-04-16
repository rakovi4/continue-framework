# Test Review Patterns: Usecase Layer (PHP/Laravel)

PHP/PHPUnit code examples for usecase test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## PHP-Specific Rules (Usecase)

1. **Use descriptive assertion messages** -- add a third argument to `assertEquals` or use named assertions for clear failure messages
2. **No RuntimeException in Statements** -- reserved for real adapter implementations only. Statements are test infrastructure.
3. **Prefer object equality** -- replace 2+ sequential per-field `assertEquals` calls with `assertEquals($expected, $actual)` (PHPUnit does deep structural comparison on objects)

## Anti-Pattern Examples

### BAD: Infrastructure leaking into test class
```php
// Test class calls mocks, clients, or adapters directly
$externalServiceMock->stubExternalService();
$response = $applicationClient->initiateCheckout($request, $loginResponse);
$externalServiceMock->verifyTaskCreated();
// GOOD: hide behind Statements -- test reads like business DSL
$response = $taskStatements->createTask($loginResponse);
$taskStatements->verifyTaskCreated();
```

### BAD: Setup step visible in test DSL
```php
$login = $setupStatements->loginAndSetupData();
$setupStatements->setupTestData($login);  // infrastructure leak!
$setupStatements->executeAction();
// GOOD: merge setup into compound given-phase method
$login = $setupStatements->loginAndSetupDataWithTasks();
$setupStatements->executeAction();
```

### BAD: Scope builder/factory in test class
```php
$taskRequest = CreateTaskRequestScope::fromLogin($loginResponse->userId)->toRequest();
$taskResponse = $createTask->create($taskRequest);
$taskDetailStatements->givenTasksExistInStorage($taskRequest);
// ...
$taskDetailStatements->assertDetails(
    $details,
    TaskDetailExpectedScope::expectedDetails($taskResponse, $loginResponse, $taskRequest)
);
// GOOD: hide scope construction behind Statements
$taskResponse = $taskDetailStatements->givenTaskCreated($loginResponse);
$taskDetailStatements->givenTasksExistInStorage();
// ...
$taskDetailStatements->assertDetails($details, $taskResponse, $loginResponse);
```

### BAD: Private method or inner class in test class
```php
class EditTaskValidationTest extends AbstractBackendTest
{
    private function givenUserWithTask(): array  // belongs in Statements
    {
        $login = $this->userStatements->givenRegisteredUser();
        $this->boardStatements->waitForBoardReady($login);
        $taskId = $this->taskStatements->createTask($login);
        return [$login, $taskId];
    }

    public function test_should_fail_when_name_is_empty(): void
    {
        [$login, $taskId] = $this->givenUserWithTask();
        // ...
    }
}
// GOOD: move to Statements -- test class has zero private members
class EditTaskValidationTest extends AbstractBackendTest
{
    public function test_should_fail_when_name_is_empty(): void
    {
        $setup = $this->taskStatements->givenUserWithTask();
        // ...
    }
}
```

### BAD: Direct usecase call in test class
```php
$taskResponse = $this->createTask->create($taskRequest);  // usecase leak!
// GOOD: Statements wraps the usecase call
$taskResponse = $this->taskDetailStatements->givenTaskCreated($loginResponse);
```

### BAD: Any assertion in test class
```php
public function test_should_reject_when_task_not_found(): void
{
    $login = $this->loginStatements->login();
    $this->setupStatements->givenUnauthorizedUser($login);
    $this->expectException(UnauthorizedException::class);
    $this->listStatements->getTasks($login->userId, 1, 100);
}
// GOOD: all assertions in Statements
public function test_should_reject_when_task_not_found(): void
{
    $login = $this->loginStatements->login();
    $this->setupStatements->givenUnauthorizedUser($login);
    $this->listStatements->assertRejectsUnauthorized($login->userId);
}
```

### BAD: Action + assertion combined in one Statements method
```php
public function assertTaskNotFound(object $login): void
{
    try {
        $this->createTask->create($this->buildRequest($login));
        $this->fail('Expected TaskNotFoundException');
    } catch (TaskNotFoundException $e) {
        $this->assertEquals('Task not found', $e->getMessage());
    }
}
// GOOD: split into action + assertion
public function createTaskForNonExistentColumn(object $login): void
{
    try {
        $this->createTask->create($this->buildRequest($login));
    } catch (\Throwable $e) {
        $this->thrownException = $e;
    }
}

public function assertTaskNotFound(): void
{
    $this->assertInstanceOf(TaskNotFoundException::class, $this->thrownException);
    $this->assertEquals('Task not found', $this->thrownException->getMessage());
}
```

### BAD: Storage port injected in Statements
```php
// BAD: verify through storage
public function assertTaskRecorded(string $taskId, string $expectedStatus): void
{
    $tasks = $this->taskStorage->findByTaskId($taskId);
    $this->assertCount(1, $tasks);
    $this->assertEquals($expectedStatus, $tasks[0]->status);
}
// GOOD: verify through usecase
public function assertTaskRecorded(string $taskId, string $expectedStatus): void
{
    $tasks = $this->getTaskHistory->execute($taskId);
    $this->assertCount(1, $tasks);
    $this->assertEquals($expectedStatus, $tasks[0]->status);
}
```

### BAD: Storage port injected in Statements (for setup)
```php
// BAD: writes to storage directly
public function givenTaskRecorded(string $taskId, int $status): void
{
    $this->taskStorage->save(new Task($taskId, $status, new DateTimeImmutable()));
}
// GOOD: setup through usecase
public function givenTaskRecorded(string $taskId, int $status): void
{
    $this->recordTask->execute(new RecordTaskRequest($taskId, $status));
}
```

### BAD: Duplicating assertion logic from another Statements class
```php
public function assertTaskInBlockedState(string $userId): void
{
    $status = $this->getTaskStatus->execute($userId);
    $this->assertEquals('in_progress', $status->status);       // duplicated
    $this->assertEquals($this->columnId, $status->columnId);   // duplicated
    $this->assertTrue($status->isEditable);                     // duplicated
}
// GOOD: inject existing Statements, delegate
public function assertTaskInBlockedState(string $userId, string $taskId): void
{
    $response = $this->getTaskStatus->execute($userId);
    $this->getTaskStatusStatements->assertBlockedTask($response, 'blocked', $taskId);
    $this->assertFailedStatusTransition($response);  // only scenario-specific
}
```

### BAD: Cross-Statements data passing in test class
```php
$loginResponse = $this->authStatements->login($this->authStatements->loginRequest());
$this->authStatements->assertSessionCreated($loginResponse);
$this->passwordResetStatements->resetPassword(
    $this->passwordResetStatements->requestPasswordResetAndGetToken(
        $this->userRegistrationStatements->registerRequest()));
// GOOD: compound methods hide all coordination
$this->authStatements->assertTestUserCanLogin();
$this->passwordResetStatements->resetTestUserPassword();
$this->passwordResetStatements->assertCanLoginWithNewPassword();
```

### BAD: Decomposed call when compound method exists
```php
$this->authStatements->login($this->authStatements->loginRequest());
// GOOD: use existing compound
$this->authStatements->loginTestUser();
```

### BAD: Unreferenced domain classes/fields from RED phase
```php
// RED created Task (4 fields) and Column has tasks: array
// but the test only checks empty columns by name
readonly class Column
{
    public function __construct(
        public string $name,
        /** @var Task[] */
        public array $tasks,  // no test references tasks -> remove
    ) {}
}

readonly class Task  // no test references Task at all -> delete class
{
    public function __construct(
        public int $id,
        public string $title,
        public string $description,
        public int $position,
    ) {}
}
// GOOD: Column only has the field the test actually uses
readonly class Column
{
    public function __construct(
        public string $name,  // test asserts Column::empty("To Do") -> needs name only
    ) {}
}
// Task does not exist yet -- created when a test needs it
```

## Correct Patterns

### GOOD: Object Equality (recursive comparison)
```php
// Replace 2+ per-field assertions with object equality
$this->assertEquals($expected, $actual); // PHPUnit compares all properties recursively
```
