# Usecase Test Template -- C++/CMake

> Universal rules: `.claude/templates/tdd/red-usecase.md`

## 3-Tier Locations

| Layer | Location |
|-------|----------|
| Test Class | `backend/usecase/tests/{feature}/{feature}_test.cpp` |
| Statements | `backend/usecase/tests/statements/{feature}_statements.h` / `.cpp` |
| Scope | `backend/usecase/tests/scope/{feature}_scope.h` |

## Tech-Specific Rules

- Extend `ApplicationTest` fixture (provides fake wiring, usecase instances)
- Add `DISABLED_` prefix to test name
- Use descriptive `snake_case` test names documenting the scenario
- Scope: `struct` with `Builder` nested class, fluent `with_*()` setters, `build()` method
- Not-implemented marker: `throw std::logic_error("Not implemented")`
- Empty values: `std::nullopt` for optional fields, `{}` for vectors

## Reference (read before generating)

- Test class: `backend/usecase/tests/task/create/create_task_test.cpp`
- Statements: `backend/usecase/tests/statements/task_statements.h`
- Scope: `backend/usecase/tests/scope/create_task_scope.h`
- Base fixture: `backend/usecase/tests/application_test.h`
- TestData: `backend/usecase/tests/scope/test_data.h`
- Fake example: `backend/usecase/tests/fake/task/fake_task_storage.h`

## Update ApplicationTest

Add new use-case and statements to `application_test.h` if needed (follow the existing usecase and statements sections).

## Key Paths

- Tests: `backend/usecase/tests/{feature}/`
- Production: `backend/usecase/src/{feature}/`
- Headers: `backend/usecase/include/usecase/{feature}/`
- Base fixture: `backend/usecase/tests/application_test.h`
- Statements: `backend/usecase/tests/statements/`
- Scopes: `backend/usecase/tests/scope/`
- Fakes: `backend/usecase/tests/fake/`
