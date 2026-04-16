# Test Review Patterns: Usecase Layer (Node/TypeScript)

TypeScript/Vitest code examples for usecase test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## TypeScript-Specific Rules (Usecase)

1. **Prefer toEqual() for structural comparison** -- use `expect(actual).toEqual(expected)` for object comparison instead of per-field assertions
2. **No `throw new Error("Not implemented")` in Statements** -- reserved for real adapter implementations only. Statements are test infrastructure.
3. **Prefer structural deep equality** -- replace 2+ sequential per-field `expect(x.field).toEqual(...)` calls with `expect(actual).toEqual(expected)` using a constructed expected object

## Anti-Pattern Examples

### BAD: Infrastructure leaking into test class
```typescript
// Test class calls mocks, clients, or adapters directly
externalServiceMock.stubExternalService();
const response = await applicationClient.initiateCheckout(request, loginResponse);
externalServiceMock.verifyTaskCreated();
// GOOD: hide behind Statements — test reads like business DSL
const response = await taskStatements.createTask(loginResponse);
await taskStatements.verifyTaskCreated();
```

### BAD: Setup step visible in test DSL
```typescript
// Test class exposes infrastructure setup as a separate step
const login = await setupStatements.loginAndSetupData();
await setupStatements.setupTestData(login);  // infrastructure leak!
await setupStatements.executeAction();
// GOOD: merge setup into compound given-phase method
const login = await setupStatements.loginAndSetupDataWithTasks();
await setupStatements.executeAction();
```

### BAD: Scope builder/factory in test class
```typescript
// Test class constructs test data via Scope — infrastructure leak
const taskRequest = CreateTaskRequestScope.from(loginResponse.userId).toRequest();
const taskResponse = await createTask.create(taskRequest);
await taskDetailStatements.givenTasksExistInStorage(taskRequest);
// ...
taskDetailStatements.assertDetails(
    details,
    TaskDetailExpectedScope.expectedDetails(taskResponse, loginResponse, taskRequest)
);
// GOOD: hide scope construction and expected-value factory behind Statements
const taskResponse = await taskDetailStatements.givenTaskCreated(loginResponse);
await taskDetailStatements.givenTasksExistInStorage();
// ...
taskDetailStatements.assertDetails(details, taskResponse, loginResponse);
```

### BAD: Private function or inner type in test class
```typescript
describe("EditTaskValidation", () => {
    interface UserWithTask { login: LoginResponse; taskId: string; }  // belongs in Statements
    async function givenUserWithTask(): Promise<UserWithTask> {  // belongs in Statements
        const login = await userStatements.givenRegisteredUser();
        await boardStatements.waitForBoardReady(login);
        const taskId = await taskStatements.createTask(login);
        return { login, taskId };
    }
    it("should fail when name is empty", async () => {
        const setup = await givenUserWithTask();
        // ...
    });
});
// GOOD: move to Statements — test file has zero private members
describe("EditTaskValidation", () => {
    it("should fail when name is empty", async () => {
        const setup = await taskStatements.givenUserWithTask();
        // ...
    });
});
```

### BAD: Direct usecase call in test class
```typescript
const taskResponse = await createTask.create(taskRequest);  // usecase leak!
// GOOD: Statements wraps the usecase call
const taskResponse = await taskDetailStatements.givenTaskCreated(loginResponse);
```

### BAD: Any assertion in test class
```typescript
it("should reject when task not found", async () => {
    const login = await loginStatements.login();
    await setupStatements.givenUnauthorizedUser(login);
    await expect(listStatements.getTasks(login.userId, 1, 100))
        .rejects.toThrow(UnauthorizedException);
});
// GOOD: all assertions in Statements
it("should reject when task not found", async () => {
    const login = await loginStatements.login();
    await setupStatements.givenUnauthorizedUser(login);
    await listStatements.assertRejectsUnauthorized(login.userId);
});
```

### BAD: Action + assertion combined in one Statements method
```typescript
async assertTaskNotFound(login: LoginResponse) {
    await expect(this.createTask.create(this.buildRequest(login)))
        .rejects.toThrow(TaskNotFoundException);
}
// GOOD: split into action + assertion
async createTaskForNonExistentColumn(login: LoginResponse) {
    try {
        await this.createTask.create(this.buildRequest(login));
    } catch (e) {
        this.thrownError = e;
    }
}

assertTaskNotFound() {
    expect(this.thrownError).toBeInstanceOf(TaskNotFoundException);
    expect((this.thrownError as TaskNotFoundException).message).toEqual("Task not found");
}
```

### BAD: Storage port injected in Statements
```typescript
// BAD: verify through storage
async assertTaskRecorded(taskId: string, expectedStatus: string) {
    const tasks = await this.taskStorage.findByTaskId(taskId);
    expect(tasks).toHaveLength(1);
    expect(tasks[0].status).toEqual(expectedStatus);
}
// GOOD: verify through usecase
async assertTaskRecorded(taskId: string, expectedStatus: string) {
    const tasks = await this.getTaskHistory.execute(taskId);
    expect(tasks).toHaveLength(1);
    expect(tasks[0].status).toEqual(expectedStatus);
}
```

### BAD: Duplicating assertion logic from another Statements class
```typescript
// BAD: duplicates assertions from GetTaskStatusStatements
async assertTaskInBlockedState(userId: string) {
    const status = await this.getTaskStatus.getStatus(userId);
    expect(status.status).toEqual("in_progress");
    expect(status.columnId).toEqual(this.columnId);
}
// GOOD: inject existing Statements, delegate
async assertTaskInBlockedState(userId: string, taskId: string) {
    const response = await this.getTaskStatus.getStatus(userId);
    this.getTaskStatusStatements.assertBlockedTask(response, "blocked", taskId);
    this.assertFailedStatusTransition(response);  // only new, scenario-specific
}
```

### BAD: Cross-Statements data passing in test class
```typescript
const loginResponse = await authStatements.login(authStatements.loginRequest());
await authStatements.assertSessionCreated(loginResponse);
await passwordResetStatements.resetPassword(
    await passwordResetStatements.requestResetAndGetToken(
        userStatements.registerRequest()));
// GOOD: compound methods hide all coordination
await authStatements.assertTestUserCanLogin();
await passwordResetStatements.resetTestUserPassword();
await passwordResetStatements.assertCanLoginWithNewPassword();
```

### BAD: Decomposed call when compound method exists
```typescript
await authStatements.login(authStatements.loginRequest());
// GOOD: use existing compound
await authStatements.loginTestUser();
```

### BAD: Unreferenced domain classes/fields from RED phase
```typescript
// RED created Task with 4 fields and Column has tasks: Task[]
// but the test only checks empty columns by name
class Column {
    name: string;
    tasks: Task[];  // no test references tasks -> remove
}
class Task {  // no test references Task at all -> delete class
    id: number;
    title: string;
    description: string;
    position: number;
}
// GOOD: Column only has the field the test actually uses
class Column {
    readonly name: string;
}
// Task does not exist yet -- created when a test needs it
```

## Correct Patterns

### GOOD: Structural Deep Equality (Vitest)
```typescript
// Replace 2+ per-field assertions with structural comparison
expect(actual).toEqual(expected);

// For collections
expect(list).toEqual(expect.arrayContaining(expected));
// Or for exact match:
expect(list).toEqual(expected);
```
