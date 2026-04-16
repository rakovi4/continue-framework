# Test Review Patterns: Usecase Layer (Python/Django)

Python/pytest code examples for usecase test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## Python-Specific Rules (Usecase)

1. **Use descriptive assertion messages** -- add a second argument to `assert` or use pytest's built-in introspection for clear failure messages
2. **No `NotImplementedError` in Statements** -- Python marker for the universal rule (see `tdd-rules.md`: Statements must be fully functional in RED)
3. **Prefer dataclass equality** -- replace 2+ sequential per-field `assert` calls with `assert actual == expected` (frozen dataclasses do deep structural comparison by default)

## Anti-Pattern Examples

### BAD: Infrastructure leaking into test class
```python
# Test class calls mocks, clients, or adapters directly
external_service_mock.stub_external_service()
response = application_client.initiate_checkout(request, login_response)
external_service_mock.verify_task_created()
# GOOD: hide behind Statements -- test reads like business DSL
response = task_statements.create_task(login_response)
task_statements.verify_task_created()
```

### BAD: Setup step visible in test DSL
```python
login = setup_statements.login_and_setup_data()
setup_statements.setup_test_data(login)  # infrastructure leak!
setup_statements.execute_action()
# GOOD: merge setup into compound given-phase method
login = setup_statements.login_and_setup_data_with_tasks()
setup_statements.execute_action()
```

### BAD: Scope builder/factory in test class
```python
task_request = CreateTaskRequestScope.from_login(login_response.user_id).to_request()
task_response = create_task.create(task_request)
task_detail_statements.given_tasks_exist_in_storage(task_request)
# ...
task_detail_statements.assert_details(
    details,
    TaskDetailExpectedScope.expected_details(task_response, login_response, task_request)
)
# GOOD: hide scope construction behind Statements
task_response = task_detail_statements.given_task_created(login_response)
task_detail_statements.given_tasks_exist_in_storage()
# ...
task_detail_statements.assert_details(details, task_response, login_response)
```

### BAD: Private function or inner class in test class
```python
class TestEditTaskValidation(AbstractBackendTest):
    def _given_user_with_task(self):  # belongs in Statements
        login = user_statements.given_registered_user()
        board_statements.wait_for_board_ready(login)
        task_id = task_statements.create_task(login)
        return login, task_id

    def test_should_fail_when_name_is_empty(self):
        login, task_id = self._given_user_with_task()
        # ...
# GOOD: move to Statements -- test class has zero private members
class TestEditTaskValidation(AbstractBackendTest):
    def test_should_fail_when_name_is_empty(self):
        setup = task_statements.given_user_with_task()
        # ...
```

### BAD: Direct usecase call in test class
```python
task_response = create_task.create(task_request)  # usecase leak!
# GOOD: Statements wraps the usecase call
task_response = task_detail_statements.given_task_created(login_response)
```

### BAD: Any assertion in test class
```python
def test_should_reject_when_task_not_found(self):
    login = login_statements.login()
    setup_statements.given_unauthorized_user(login)
    with pytest.raises(UnauthorizedException):
        list_statements.get_tasks(login.user_id, 1, 100)
# GOOD: all assertions in Statements
def test_should_reject_when_task_not_found(self):
    login = login_statements.login()
    setup_statements.given_unauthorized_user(login)
    list_statements.assert_rejects_unauthorized(login.user_id)
```

### BAD: Action + assertion combined in one Statements method
```python
def assert_task_not_found(self, login):
    with pytest.raises(TaskNotFoundException, match="Task not found"):
        self.create_task.create(self._build_request(login))
# GOOD: split into action + assertion
def create_task_for_nonexistent_column(self, login):
    try:
        self.create_task.create(self._build_request(login))
    except Exception as e:
        self.thrown_exception = e

def assert_task_not_found(self):
    assert isinstance(self.thrown_exception, TaskNotFoundException)
    assert str(self.thrown_exception) == "Task not found"
```

### BAD: Storage port injected in Statements
```python
# BAD: verify through storage
def assert_task_recorded(self, task_id, expected_status):
    tasks = self.task_storage.find_by_task_id(task_id)
    assert len(tasks) == 1
    assert tasks[0].status == expected_status
# GOOD: verify through usecase
def assert_task_recorded(self, task_id, expected_status):
    tasks = self.get_task_history.execute(task_id)
    assert len(tasks) == 1
    assert tasks[0].status == expected_status
```

### BAD: Storage port injected in Statements (for setup)
```python
# BAD: writes to storage directly
def given_task_recorded(self, task_id, status):
    self.task_storage.save(Task(task_id=task_id, status=status, created_at=clock.now()))
# GOOD: setup through usecase
def given_task_recorded(self, task_id, status):
    self.record_task.execute(RecordTaskRequest(task_id=task_id, status=status))
```

### BAD: Duplicating assertion logic from another Statements class
```python
# BAD: duplicates assertions from GetTaskStatusStatements
def assert_task_in_blocked_state(self, user_id):
    status = self.get_task_status.get_status(user_id)
    assert status.status == "in_progress"
    assert status.column_id == self.column_id
# GOOD: inject existing Statements, delegate
def assert_task_in_blocked_state(self, user_id, task_id):
    response = self.get_task_status.get_status(user_id)
    self.get_task_status_statements.assert_blocked_task(response, "blocked", task_id)
    self._assert_failed_status_transition(response)  # only scenario-specific
```

### BAD: Cross-Statements data passing in test class
```python
login_response = auth_statements.login(auth_statements.login_request())
auth_statements.assert_session_created(login_response)
password_reset_statements.reset_password(
    password_reset_statements.request_reset_and_get_token(
        user_statements.register_request()))
# GOOD: compound methods hide all coordination
auth_statements.assert_test_user_can_login()
password_reset_statements.reset_test_user_password()
password_reset_statements.assert_can_login_with_new_password()
```

### BAD: Decomposed call when compound method exists
```python
auth_statements.login(auth_statements.login_request())
# GOOD: use existing compound
auth_statements.login_test_user()
```

### BAD: Unreferenced domain classes/fields from RED phase
```python
# RED created Task (4 fields) and Column has tasks: list[Task]
# but the test only checks empty columns by name
@dataclass(frozen=True)
class Column:
    name: str
    tasks: list[Task]  # no test references tasks -> remove

@dataclass(frozen=True)
class Task:  # no test references Task at all -> delete class
    id: int
    title: str
    description: str
    position: int
# GOOD: Column only has the field the test actually uses
@dataclass(frozen=True)
class Column:
    name: str  # test asserts Column.empty("To Do") -> needs name only
# Task does not exist yet -- created when a test needs it
```

## Correct Patterns

### GOOD: Dataclass Equality (recursive comparison)
```python
# Replace 2+ per-field assertions with dataclass equality
assert actual == expected  # frozen dataclasses compare all fields recursively
```
