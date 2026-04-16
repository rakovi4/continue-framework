# Test Review Patterns: Usecase Layer (C#/ASP.NET Core)

C#/xUnit/FluentAssertions code examples for usecase test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## C#-Specific Rules (Usecase)

1. **Use `.Because("reason")`** -- always describe what you're validating with FluentAssertions' `.Because()` for clear failure messages
2. **No NotImplementedException in Statements** -- reserved for real adapter implementations only. Statements are test infrastructure.
3. **Prefer record equality** -- replace 2+ sequential per-property `.Should().Be()` calls with `actual.Should().BeEquivalentTo(expected)` (records do deep structural comparison by default)

## Anti-Pattern Examples

### BAD: Infrastructure leaking into test class
```csharp
// Test class calls mocks, clients, or adapters directly
externalServiceMock.StubExternalService();
var response = applicationClient.InitiateCheckout(request, loginResponse);
externalServiceMock.VerifyTaskCreated();
// GOOD: hide behind Statements -- test reads like business DSL
var response = taskStatements.CreateTask(loginResponse);
taskStatements.VerifyTaskCreated();
```

### BAD: Setup step visible in test DSL
```csharp
var login = setupStatements.LoginAndSetupData();
setupStatements.SetupTestData(login);  // infrastructure leak!
setupStatements.ExecuteAction();
// GOOD: merge setup into compound given-phase method
var login = setupStatements.LoginAndSetupDataWithTasks();
setupStatements.ExecuteAction();
```

### BAD: Scope builder/factory in test class
```csharp
var taskRequest = CreateTaskRequestScope.FromLogin(loginResponse.UserId).ToRequest();
var taskResponse = createTask.Create(taskRequest);
taskDetailStatements.GivenTasksExistInStorage(taskRequest);
// ...
taskDetailStatements.AssertDetails(
    details,
    TaskDetailExpectedScope.ExpectedDetails(taskResponse, loginResponse, taskRequest));
// GOOD: hide scope construction behind Statements
var taskResponse = taskDetailStatements.GivenTaskCreated(loginResponse);
taskDetailStatements.GivenTasksExistInStorage();
// ...
taskDetailStatements.AssertDetails(details, taskResponse, loginResponse);
```

### BAD: Private method or inner class in test class
```csharp
public class EditTaskValidationTest : AbstractBackendTest
{
    private (LoginResponse login, long taskId) GivenUserWithTask()  // belongs in Statements
    {
        var login = userStatements.GivenRegisteredUser();
        var taskId = taskStatements.CreateTask(login);
        return (login, taskId);
    }
    [Fact]
    public void Should_Fail_When_Name_Is_Empty()
    {
        var (login, taskId) = GivenUserWithTask();  // ...
    }
}
// GOOD: move to Statements -- test class has zero private members
[Fact]
public void Should_Fail_When_Name_Is_Empty()
{
    var setup = taskStatements.GivenUserWithTask();  // ...
}
```

### BAD: Direct usecase call in test class
```csharp
var taskResponse = createTask.Create(taskRequest);  // usecase leak!
// GOOD: Statements wraps the usecase call
var taskResponse = taskDetailStatements.GivenTaskCreated(loginResponse);
```

### BAD: Any assertion in test class
```csharp
[Fact]
public void Should_Reject_When_Task_Not_Found()
{
    var login = loginStatements.Login();
    setupStatements.GivenUnauthorizedUser(login);
    var act = () => listStatements.GetTasks(login.UserId, 1, 100);
    act.Should().Throw<UnauthorizedException>();
}
// GOOD: all assertions in Statements
[Fact]
public void Should_Reject_When_Task_Not_Found()
{
    var login = loginStatements.Login();
    setupStatements.GivenUnauthorizedUser(login);
    listStatements.AssertRejectsUnauthorized(login.UserId);
}
```

### BAD: Action + assertion combined in one Statements method
```csharp
public void AssertTaskNotFound(LoginResponse login)
{
    var act = () => createTask.Create(BuildRequest(login));
    act.Should().Throw<TaskNotFoundException>().WithMessage("Task not found");
}
// GOOD: split into action + assertion
public void CreateTaskForNonexistentColumn(LoginResponse login)
{
    try { createTask.Create(BuildRequest(login)); }
    catch (Exception e) { ThrownException = e; }
}

public void AssertTaskNotFound()
{
    ThrownException.Should().BeOfType<TaskNotFoundException>();
    ThrownException!.Message.Should().Be("Task not found");
}
```

### BAD: Storage port injected in Statements
```csharp
// BAD: verify through storage
public void AssertTaskRecorded(long taskId, string expectedStatus)
{
    var tasks = taskStorage.FindByTaskId(taskId);
    tasks.Should().HaveCount(1);
    tasks[0].Status.Should().Be(expectedStatus);
}
// GOOD: verify through usecase
public void AssertTaskRecorded(long taskId, string expectedStatus)
{
    var tasks = getTaskHistory.Execute(taskId);
    tasks.Should().HaveCount(1);
    tasks[0].Status.Should().Be(expectedStatus);
}
// BAD: setup writes to storage directly
_taskStorage.Save(new Task(taskId, status, DateTime.UtcNow));
// GOOD: setup through usecase
_recordTask.Execute(new RecordTaskRequest(taskId, status));
```

### BAD: Duplicating assertion logic from another Statements class
```csharp
public void AssertTaskInBlockedState(Guid userId)
{
    var status = getTaskStatus.GetStatus(userId);
    status.Status.Should().Be("in_progress");          // duplicated
    status.ColumnId.Should().Be(columnId);              // duplicated
    status.IsEditable.Should().BeTrue();                // duplicated
}
// GOOD: inject existing Statements, delegate
public void AssertTaskInBlockedState(Guid userId, string taskId)
{
    var response = getTaskStatus.GetStatus(userId);
    getTaskStatusStatements.AssertBlockedTask(response, "blocked", taskId);
    AssertFailedStatusTransition(response);  // only scenario-specific
}
```

### BAD: Cross-Statements data passing in test class
```csharp
var loginResponse = authenticationStatements.Login(authenticationStatements.LoginRequest());
authenticationStatements.AssertSessionCreated(loginResponse);
passwordResetStatements.ResetPassword(
    passwordResetStatements.RequestPasswordResetAndGetToken(
        userRegistrationStatements.RegisterRequest()));
// GOOD: compound methods hide all coordination
authenticationStatements.AssertTestUserCanLogin();
passwordResetStatements.ResetTestUserPassword();
passwordResetStatements.AssertCanLoginWithNewPassword();
```

### BAD: Decomposed call when compound method exists
```csharp
authenticationStatements.Login(authenticationStatements.LoginRequest());
// GOOD: use existing compound
authenticationStatements.LoginTestUser();
```

### BAD: Unreferenced domain classes/fields from RED phase
```csharp
// RED created Task (4 properties) and Column has Tasks: IReadOnlyList<Task>
// but the test only checks empty columns by name
public record Column(string Name, IReadOnlyList<Task> Tasks);  // no test references Tasks -> remove
public record Task(int Id, string Title, string Description, int Position);  // no test references Task -> delete
// GOOD: Column only has the property the test actually uses
public record Column(string Name);  // test asserts Column.Empty("To Do") -> needs Name only
// Task does not exist yet -- created when a test needs it
```

## Correct Patterns

### GOOD: Record Equality (recursive comparison)
```csharp
// Replace 2+ per-property assertions with record equality
actual.Should().BeEquivalentTo(expected);  // records compare all properties recursively
```
