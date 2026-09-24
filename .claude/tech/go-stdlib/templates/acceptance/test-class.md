# Acceptance Test Template -- Go/stdlib

> Universal structure and rules: `.claude/templates/tdd/red-acceptance.md`

## Framework Rules

- Test file uses build tag or directory convention for acceptance tests
- `t.Skip("TDD Red Phase - Not yet implemented")` for new tests
- Not-implemented marker in Statements: `panic("not implemented")`

## Test Types

| Type | Base Setup | File Pattern |
|------|------------|--------------|
| Backend API | `AbstractBackendTest` helpers | `tests/backend/` |
| Frontend UI | `AbstractUiTest` helpers | `tests/frontend/` |

## Reference Paths

- Test example: `acceptance/{feature}/{feature}_test.go`
- Base setup: `acceptance/testutil/backend_test_setup.go`
- Statements example: `acceptance/statements/{feature}_statements.go`
- Client: `acceptance/clients/application/application_client.go`
- TestData: `acceptance/statements/testdata.go`

## Key Paths

- Backend tests: `acceptance/{feature}/`
- Statements: `acceptance/statements/`
- Client: `acceptance/clients/application/`
- DTOs: `acceptance/clients/application/dto/`
