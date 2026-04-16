# Test Review Patterns: Usecase Layer (Java/Spring)

Java/AssertJ code examples for usecase test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Java-Specific Rules (Usecase)

1. **Use .as()** -- always describe what you're validating with AssertJ's `.as()` for clear failure messages
2. **No UnsupportedOperationException in Statements** -- reserved for real adapter implementations only. Statements are test infrastructure.
3. **Prefer usingRecursiveComparison** -- replace 2+ sequential per-field `assertThat` calls with `assertThat(actual).usingRecursiveComparison().isEqualTo(expected)`

## Anti-Pattern Examples

### BAD: Infrastructure leaking into test class
```java
// Test class calls mocks, clients, or adapters directly
externalServiceMock.stubExternalService();
var response = applicationClient.initiateCheckout(request, loginResponse);
externalServiceMock.verifyTaskCreated();
// GOOD: hide behind Statements — test reads like business DSL
var response = taskStatements.createTask(loginResponse);
taskStatements.verifyTaskCreated();
```

### BAD: Setup step visible in test DSL
```java
var login = setupStatements.loginAndSetupData();
setupStatements.setupTestData(login);  // infrastructure leak!
setupStatements.executeAction();
// GOOD: merge setup into compound given-phase method
var login = setupStatements.loginAndSetupDataWithTasks();
setupStatements.executeAction();
```

### BAD: Scope builder/factory in test class
```java
var taskRequest = CreateTaskRequestScope.from(loginResponse.userId()).toRequest();
var taskResponse = createTask.create(taskRequest);
taskDetailStatements.givenTasksExistInStorage(taskRequest);
// ...
taskDetailStatements.assertDetails(
    details,
    TaskDetailExpectedScope.expectedDetails(taskResponse, loginResponse, taskRequest)
);
// GOOD: hide scope construction behind Statements
var taskResponse = taskDetailStatements.givenTaskCreated(loginResponse);
taskDetailStatements.givenTasksExistInStorage();
// ...
taskDetailStatements.assertDetails(details, taskResponse, loginResponse);
```

### BAD: Private method or inner record in test class
```java
public class EditTaskValidationTest extends AbstractBackendTest {
    void editTaskFailsWhenNameIsEmpty() {
        var setup = givenUserWithTask();
        // ...
    }
    private record UserWithTask(LoginResponse login, UUID taskId) {}  // belongs in Statements
    private UserWithTask givenUserWithTask() {  // belongs in Statements
        var login = userStatements.givenRegisteredUser();
        boardStatements.waitForBoardReady(login);
        var taskId = taskStatements.createTask(login);
        return new UserWithTask(login, taskId);
    }
}
// GOOD: move to Statements — test class has zero private members
public class EditTaskValidationTest extends AbstractBackendTest {
    void editTaskFailsWhenNameIsEmpty() {
        var setup = taskStatements.givenUserWithTask();
        // ...
    }
}
```

### BAD: Direct usecase call in test class
```java
var taskResponse = createTask.create(taskRequest);  // usecase leak!
// GOOD: Statements wraps the usecase call
var taskResponse = taskDetailStatements.givenTaskCreated(loginResponse);
```

### BAD: Any assertion in test class
```java
void should_reject_when_task_not_found() {
    UserLoginResponse login = loginStatements.login();
    setupStatements.givenUnauthorizedUser(login);
    assertThatThrownBy(() -> listStatements.getTasks(login.userId(), 1, 100))
            .isInstanceOf(UnauthorizedException.class)
            .hasMessage("Access denied");
}
// GOOD: all assertions in Statements
void should_reject_when_task_not_found() {
    UserLoginResponse login = loginStatements.login();
    setupStatements.givenUnauthorizedUser(login);
    listStatements.assertRejectsUnauthorized(login.userId());
}
```

### BAD: Action + assertion combined in one Statements method
```java
public void assertTaskNotFound(UserLoginResponse login) {
    assertThatThrownBy(() -> createTask.create(buildRequest(login)))
            .isInstanceOf(TaskNotFoundException.class)
            .hasMessage("Task not found");
}
// GOOD: split into action + assertion
public void createTaskForNonExistentColumn(UserLoginResponse login) {
    thrownException = catchThrowable(() -> createTask.create(buildRequest(login)));
}

public void assertTaskNotFound() {
    assertThat(thrownException)
            .isInstanceOf(TaskNotFoundException.class)
            .hasMessage("Task not found");
}
```

### BAD: Storage port injected in Statements
```java
// BAD: verify through storage
public void assertTaskRecorded(long taskId, String expectedStatus) {
    var tasks = taskStorage.findByTaskId(taskId);
    assertThat(tasks).hasSize(1);
    assertThat(tasks.get(0).getStatus()).isEqualTo(expectedStatus);
}
// GOOD: verify through usecase
public void assertTaskRecorded(long taskId, String expectedStatus) {
    var tasks = getTaskHistory.execute(taskId);
    assertThat(tasks).hasSize(1);
    assertThat(tasks.get(0).getStatus()).isEqualTo(expectedStatus);
}
```

### BAD: Storage port injected in Statements (for setup)
```java
// BAD: writes to storage directly
private final TaskStorage taskStorage;
public void givenTaskRecorded(long taskId, int status) {
    taskStorage.save(new Task(taskId, status, clock.instant()));
}
// GOOD: setup through usecase
private final RecordTask recordTask;
public void givenTaskRecorded(long taskId, int status) {
    recordTask.execute(new RecordTaskRequest(taskId, status));
}
```

### BAD: Duplicating assertion logic from another Statements class
```java
public void assertTaskInBlockedState(UUID userId) {
    var status = getTaskStatus.getStatus(userId);
    assertThat(status.status()).isEqualTo("in_progress");          // duplicated
    assertThat(status.columnId()).isEqualTo(columnId);             // duplicated
    assertThat(status.isEditable()).isTrue();                      // duplicated
}
// GOOD: inject existing Statements, delegate
public void assertTaskInBlockedState(UUID userId, String taskId) {
    var response = getTaskStatus.getStatus(userId);
    getTaskStatusStatements.assertBlockedTask(response, "blocked", taskId);
    assertFailedStatusTransition(response);  // only scenario-specific
}
```

### BAD: Cross-Statements data passing in test class
```java
var loginResponse = authenticationStatements.login(authenticationStatements.loginRequest());
authenticationStatements.assertSessionCreated(loginResponse);
passwordResetStatements.resetPassword(
    passwordResetStatements.requestPasswordResetAndGetToken(
        userRegistrationStatements.registerRequest()));
// GOOD: compound methods hide all coordination
authenticationStatements.assertTestUserCanLogin();
passwordResetStatements.resetTestUserPassword();
passwordResetStatements.assertCanLoginWithNewPassword();
```

### BAD: Decomposed call when compound method exists
```java
authenticationStatements.login(authenticationStatements.loginRequest());
// GOOD: use existing compound
authenticationStatements.loginTestUser();
```

### BAD: Unreferenced domain classes/fields from RED phase
```java
// RED created Task.java (4 fields) and Column has List<Task>
// but the test only checks empty columns by name
public class Column {
    String name;
    List<Task> tasks;  // no test references tasks -> remove
}
public class Task {  // no test references Task at all -> delete class
    Long id;
    String title;
    String description;
    int position;
}
// GOOD: Column only has the field the test actually uses
public class Column {
    String name;  // test asserts Column.empty("To Do") -> needs name only
}
// Task.java does not exist yet -- created when a test needs it
```

## Correct Patterns

### GOOD: Recursive Comparison (AssertJ)
```java
// Replace 2+ per-field assertions with recursive comparison
assertThat(actual).usingRecursiveComparison().isEqualTo(expected);

// For collections
assertThat(list).usingRecursiveFieldByFieldElementComparator()
    .containsExactlyInAnyOrderElementsOf(expected);
```
