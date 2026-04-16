# Test Review Patterns: Usecase Layer (C++/Google Test)

C++/Google Test/GMock code examples for usecase test anti-patterns. For universal rules: `.claude/templates/testing/test-review-patterns.md`

## C++-Specific Rules (Usecase)

1. **Use descriptive failure messages** -- add `<< "description"` to assertions for clear failure output
2. **No std::logic_error in Statements** -- reserved for real adapter implementations only. Statements are test infrastructure.
3. **Implement operator== on structs** -- enables `EXPECT_EQ(actual, expected)` for structural comparison
4. **Prefer operator== structural comparison** -- replace 2+ sequential per-field `EXPECT_EQ` calls with `EXPECT_EQ(actual, expected)` using `operator==`

## Anti-Pattern Examples

### BAD: Infrastructure leaking into test class
```cpp
// Test class calls mocks, clients, or adapters directly
external_service_mock.stub_external_service();
auto response = application_client.initiate_checkout(request, login_response);
external_service_mock.verify_task_created();
// GOOD: hide behind Statements — test reads like business DSL
auto response = task_statements.create_task(login_response);
task_statements.verify_task_created();
```

### BAD: Setup step visible in test DSL
```cpp
auto login = setup_statements.login_and_setup_data();
setup_statements.setup_test_data(login);  // infrastructure leak!
setup_statements.execute_action();
// GOOD: merge setup into compound given-phase method
auto login = setup_statements.login_and_setup_data_with_tasks();
setup_statements.execute_action();
```

### BAD: Scope builder/factory in test class
```cpp
auto task_request = CreateTaskScope::from(login_response.user_id()).to_request();
auto task_response = create_task.create(task_request);
// GOOD: hide scope construction behind Statements
auto task_response = task_statements.given_task_created(login_response);
```

### BAD: Private method or nested struct in test class
```cpp
class EditTaskValidationTest : public BackendTestFixture {
    // belongs in Statements
    struct UserWithTask { LoginResponse login; std::string task_id; };
    UserWithTask given_user_with_task() { /* ... */ }
};
// GOOD: move to Statements — test class has zero private members
```

### BAD: Direct usecase call in test class
```cpp
auto task_response = create_task_->create(task_request);  // usecase leak!
// GOOD: Statements wraps the usecase call
auto task_response = task_statements.given_task_created(login_response);
```

### BAD: Any assertion in test class
```cpp
TEST_F(TaskTest, should_reject_when_task_not_found) {
    auto login = login_statements.login();
    setup_statements.given_unauthorized_user(login);
    EXPECT_THROW(list_statements.get_tasks(login.user_id()), UnauthorizedException);
}
// GOOD: all assertions in Statements
TEST_F(TaskTest, should_reject_when_task_not_found) {
    auto login = login_statements.login();
    setup_statements.given_unauthorized_user(login);
    list_statements.assert_rejects_unauthorized(login.user_id());
}
```

### BAD: Action + assertion combined in one Statements method
```cpp
void assert_task_not_found(const LoginResponse& login) {
    EXPECT_THROW(create_task_->create(build_request(login)), TaskNotFoundException);
}
// GOOD: split into action + assertion
void create_task_for_nonexistent_column(const LoginResponse& login) {
    thrown_exception_ = catch_exception([&]() { create_task_->create(build_request(login)); });
}

void assert_task_not_found() {
    EXPECT_NE(thrown_exception_, nullptr);
    EXPECT_NE(dynamic_cast<TaskNotFoundException*>(thrown_exception_.get()), nullptr)
        << "expected TaskNotFoundException";
}
```

### BAD: Storage port injected in Statements
```cpp
// BAD: verify through storage
void assert_task_recorded(int64_t task_id, const std::string& expected_status) {
    auto tasks = task_storage_->find_by_task_id(task_id);
    EXPECT_EQ(tasks.size(), 1);
    EXPECT_EQ(tasks[0].status(), expected_status);
}
// GOOD: verify through usecase
void assert_task_recorded(int64_t task_id, const std::string& expected_status) {
    auto tasks = get_task_history_->execute(task_id);
    EXPECT_EQ(tasks.size(), 1);
    EXPECT_EQ(tasks[0].status(), expected_status);
}
```

### BAD: Storage port injected in Statements (for setup)
```cpp
// BAD: writes to storage directly
void given_task_recorded(int64_t task_id, int status) {
    task_storage_->save(Task{task_id, status, clock_->now()});
}
// GOOD: setup through usecase
void given_task_recorded(int64_t task_id, int status) {
    record_task_->execute(RecordTaskRequest{task_id, status});
}
```

### BAD: Duplicating assertion logic from another Statements class
```cpp
void assert_task_in_blocked_state(const std::string& user_id) {
    auto status = get_task_status_->get_status(user_id);
    EXPECT_EQ(status.status(), "in_progress");       // duplicated
    EXPECT_EQ(status.column_id(), column_id_);        // duplicated
    EXPECT_TRUE(status.is_editable());                // duplicated
}
// GOOD: inject existing Statements, delegate
void assert_task_in_blocked_state(const std::string& user_id, const std::string& task_id) {
    auto response = get_task_status_->get_status(user_id);
    get_task_status_statements_.assert_blocked_task(response, "blocked", task_id);
    assert_failed_status_transition(response);  // only scenario-specific
}
```

### BAD: Cross-Statements data passing in test class
```cpp
auto login_response = authentication_statements.login(authentication_statements.login_request());
authentication_statements.assert_session_created(login_response);
password_reset_statements.reset_password(
    password_reset_statements.request_password_reset_and_get_token(
        user_registration_statements.register_request()));
// GOOD: compound methods hide all coordination
authentication_statements.assert_test_user_can_login();
password_reset_statements.reset_test_user_password();
password_reset_statements.assert_can_login_with_new_password();
```

### BAD: Decomposed call when compound method exists
```cpp
authentication_statements.login(authentication_statements.login_request());
// GOOD: use existing compound
authentication_statements.login_test_user();
```

### BAD: Unreferenced domain classes/fields from RED phase
```cpp
// RED created Task with 4 fields and Column has std::vector<Task>
// but the test only checks empty columns by name
struct Column {
    std::string name;
    std::vector<Task> tasks;  // no test references tasks -> remove
};
// Task not needed yet -> delete struct
// GOOD: Column only has the field the test actually uses
struct Column {
    std::string name;  // test asserts Column::empty("To Do") -> needs name only
};
```

## Correct Patterns

### GOOD: Structural Comparison with operator==
```cpp
// Define operator== for structural comparison
bool operator==(const TaskResponse& a, const TaskResponse& b) {
    return a.id == b.id && a.title == b.title && a.status == b.status;
}

// Single assertion replaces multiple per-field checks
EXPECT_EQ(actual, expected);
```
