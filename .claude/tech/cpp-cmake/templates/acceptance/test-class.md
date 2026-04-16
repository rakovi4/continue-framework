# Acceptance Test Template -- C++/CMake

> Universal structure and rules: `.claude/templates/tdd/red-acceptance.md`

## Framework Rules

- Extend `BackendTestFixture` (backend) or `UiTestFixture` (frontend)
- `DISABLED_` prefix on test names for new tests
- Not-implemented marker in Statements: `throw std::logic_error("Not implemented")`
- Statements are plain classes constructed by the test fixture
- Use `SCOPED_TRACE("scenario description")` for context

## Test Types

| Type | Base Fixture | Filter |
|------|-------------|--------|
| Backend API | `BackendTestFixture` | `--gtest_filter="*Backend*"` |
| Frontend UI | `UiTestFixture` | `--gtest_filter="*Frontend*"` |

## Reference Paths

- Test example: `acceptance/tests/backend/create_task/create_task_acceptance_test.cpp`
- Base fixture: `acceptance/tests/backend/backend_test_fixture.h`
- Statements example: `acceptance/tests/statements/task_statements.h`
- Client: `acceptance/tests/clients/application/application_client.h`
- TestData: `acceptance/tests/statements/test_data.h`

## Key Paths

- Backend tests: `acceptance/tests/backend/`
- Statements: `acceptance/tests/statements/`
- Client: `acceptance/tests/clients/application/`
- DTOs: `acceptance/tests/clients/application/dto/`
