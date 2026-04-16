# Test Review Patterns: Usecase Layer (Go/stdlib)

Go/testify code examples for usecase test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Go-Specific Rules (Usecase)

1. **Use assert message parameter** -- always pass a description string as the last argument to `assert.*` / `require.*` for clear failure messages
2. **No panic("not implemented") in Statements** -- reserved for real adapter implementations only. Statements are test infrastructure.
3. **Prefer assert.Equal on structs** -- replace 2+ sequential per-field `assert.Equal` calls with a single `assert.Equal(t, expected, actual)` using a fully constructed expected struct

## Anti-Pattern Examples

### BAD: Infrastructure leaking into test class
```go
// Test function creates fakes and usecases directly
func TestCreateTask(t *testing.T) {
    fakeStorage := fake.NewFakeTaskStorage()
    usecase := task.NewCreateTaskUseCase(fakeStorage)
    result, err := usecase.Execute(request)
    require.NoError(t, err)
}

// GOOD: Statements hide infrastructure
func TestCreateTask(t *testing.T) {
    s := statements.NewCreateTaskStatements(t)
    s.GivenEmptyBoard()
    result := s.WhenCreateTask()
    s.ThenTaskIsCreated(result)
}
```

### BAD: Setup step visible in test DSL
```go
func TestCreateTask(t *testing.T) {
    s := statements.NewCreateTaskStatements(t)
    login := s.GivenRegisteredUser()
    s.SetupTestData(login) // infrastructure leak!
    s.WhenCreateTask(login)
}

// GOOD: merge setup into compound given-phase method
func TestCreateTask(t *testing.T) {
    s := statements.NewCreateTaskStatements(t)
    login := s.GivenRegisteredUserWithTasks()
    s.WhenCreateTask(login)
}
```

### BAD: Scope builder/factory in test class
```go
func TestTaskDetail(t *testing.T) {
    s := statements.NewTaskDetailStatements(t)
    scope := scope.NewCreateTaskScope(loginResponse.UserID)
    request := scope.ToRequest()
    taskResponse := s.CreateTask(request)
    s.GivenTasksExistInStorage(request)
    s.AssertDetails(details, scope.ExpectedDetails(taskResponse, loginResponse))
}

// GOOD: hide scope construction behind Statements
func TestTaskDetail(t *testing.T) {
    s := statements.NewTaskDetailStatements(t)
    taskResponse := s.GivenTaskCreated(loginResponse)
    s.GivenTasksExistInStorage()
    s.AssertDetails(details, taskResponse, loginResponse)
}
```

### BAD: Private helper function in test file
```go
func TestEditTaskValidation(t *testing.T) {
    setup := givenUserWithTask(t) // unexported helper in _test.go
    // ...
}

type userWithTask struct { // belongs in Statements
    login LoginResponse
    taskID string
}

func givenUserWithTask(t *testing.T) userWithTask { // belongs in Statements
    // ...
}

// GOOD: move to Statements -- test file has zero unexported helpers
func TestEditTaskValidation(t *testing.T) {
    s := statements.NewEditTaskStatements(t)
    setup := s.GivenUserWithTask()
    // ...
}
```

### BAD: Direct usecase call in test class
```go
func TestCreateTask(t *testing.T) {
    s := statements.NewCreateTaskStatements(t)
    result, err := s.createTaskUseCase.Execute(request) // usecase leak!
}

// GOOD: Statements wraps the usecase call
func TestCreateTask(t *testing.T) {
    s := statements.NewCreateTaskStatements(t)
    result := s.GivenTaskCreated(loginResponse)
}
```

### BAD: Any assertion in test class
```go
func TestRejectUnauthorized(t *testing.T) {
    s := statements.NewListStatements(t)
    login := s.GivenLogin()
    s.GivenUnauthorizedUser(login)
    _, err := s.GetTasks(login.UserID)
    assert.ErrorIs(t, err, domain.ErrUnauthorized) // belongs in Statements
}

// GOOD: all assertions in Statements
func TestRejectUnauthorized(t *testing.T) {
    s := statements.NewListStatements(t)
    login := s.GivenLogin()
    s.GivenUnauthorizedUser(login)
    s.AssertRejectsUnauthorized(login.UserID)
}
```

### BAD: Action + assertion combined in one Statements method
```go
func (s *TaskStatements) AssertTaskNotFound(login LoginResponse) {
    _, err := s.createTask.Execute(s.buildRequest(login))
    require.ErrorIs(s.t, err, domain.ErrTaskNotFound)
}

// GOOD: split into action + assertion
func (s *TaskStatements) CreateTaskForNonExistentColumn(login LoginResponse) {
    _, s.thrownErr = s.createTask.Execute(s.buildRequest(login))
}

func (s *TaskStatements) AssertTaskNotFound() {
    require.ErrorIs(s.t, s.thrownErr, domain.ErrTaskNotFound)
}
```

### BAD: Storage port injected in Statements
```go
// BAD: verify through storage
func (s *TaskStatements) AssertTaskRecorded(taskID string, expectedStatus string) {
    tasks, _ := s.taskStorage.FindByTaskID(taskID)
    assert.Len(s.t, tasks, 1)
    assert.Equal(s.t, expectedStatus, tasks[0].Status())
}

// GOOD: verify through usecase
func (s *TaskStatements) AssertTaskRecorded(taskID string, expectedStatus string) {
    tasks, err := s.getTaskHistory.Execute(taskID)
    require.NoError(s.t, err)
    assert.Len(s.t, tasks, 1)
    assert.Equal(s.t, expectedStatus, tasks[0].Status())
}
```

### BAD: Storage port injected in Statements (for setup)
```go
// BAD: writes to storage directly
func (s *TaskStatements) GivenTaskRecorded(taskID string, status int) {
    s.taskStorage.Save(domain.NewTask(taskID, status, time.Now()))
}

// GOOD: setup through usecase
func (s *TaskStatements) GivenTaskRecorded(taskID string, status int) {
    s.recordTask.Execute(usecase.RecordTaskRequest{TaskID: taskID, Status: status})
}
```

### BAD: Duplicating assertion logic from another Statements class
```go
func (s *TaskStatements) AssertTaskInBlockedState(userID string) {
    status, _ := s.getTaskStatus.Execute(userID)
    assert.Equal(s.t, "in_progress", status.Status)  // duplicated
    assert.Equal(s.t, s.columnID, status.ColumnID)    // duplicated
    assert.True(s.t, status.IsEditable)                // duplicated
}

// GOOD: inject existing Statements, delegate
func (s *TaskStatements) AssertTaskInBlockedState(userID string, taskID string) {
    response, _ := s.getTaskStatus.Execute(userID)
    s.getTaskStatusStatements.AssertBlockedTask(response, "blocked", taskID)
    s.assertFailedStatusTransition(response) // only scenario-specific
}
```

### BAD: Cross-Statements data passing in test class
```go
func TestPasswordReset(t *testing.T) {
    authS := statements.NewAuthStatements(t)
    pwS := statements.NewPasswordResetStatements(t)
    login := authS.Login(authS.LoginRequest())
    authS.AssertSessionCreated(login)
    pwS.ResetPassword(pwS.RequestPasswordResetAndGetToken(regS.RegisterRequest()))
}

// GOOD: compound methods hide all coordination
func TestPasswordReset(t *testing.T) {
    authS := statements.NewAuthStatements(t)
    pwS := statements.NewPasswordResetStatements(t)
    authS.AssertTestUserCanLogin()
    pwS.ResetTestUserPassword()
    pwS.AssertCanLoginWithNewPassword()
}
```

### BAD: Decomposed call when compound method exists
```go
authS.Login(authS.LoginRequest())

// GOOD: use existing compound
authS.LoginTestUser()
```

### BAD: Unreferenced domain classes/fields from RED phase
```go
// RED created Task (4 fields) and Column has []Task
// but the test only checks empty columns by name
type Column struct {
    Name  string
    Tasks []Task // no test references tasks -> remove
}

type Task struct { // no test references Task at all -> delete
    ID          int64
    Title       string
    Description string
    Position    int
}

// GOOD: Column only has the field the test actually uses
type Column struct {
    Name string // test asserts NewColumn("To Do") -> needs name only
}
// Task type does not exist yet -- created when a test needs it
```

## Correct Patterns

### GOOD: Struct Equality (testify)
```go
// Replace 2+ per-field assertions with struct comparison
assert.Equal(t, expected, actual)

// For collections
assert.ElementsMatch(t, expected, actual)
```
