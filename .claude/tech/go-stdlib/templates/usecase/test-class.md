# Usecase Test Template -- Go/stdlib

> Universal rules: `.claude/templates/tdd/red-usecase.md`

## 3-Tier Locations

| Layer | Location |
|-------|----------|
| Test Class | `{feature}/{feature}_test.go` |
| Statements | `statements/{feature}_statements.go` |
| Scope | `scope/{feature}_scope.go` |

## Tech-Specific Rules

- `t.Skip("TDD Red Phase - Not yet implemented")` in RED
- Use `t.Run("scenario description", ...)` subtests with Gherkin-style text
- Not-implemented marker: `panic("not implemented")`
- Empty values: zero values for optional fields, `nil` for slices

## Reference (read before generating)

- Test class: `backend/usecase/{feature}/{feature}_test.go`
- Statements: `backend/usecase/testutil/statements/{feature}_statements.go`
- Scope: `backend/usecase/testutil/scope/{feature}_scope.go`
- Base setup: `backend/usecase/testutil/setup/application_test_setup.go`
- TestData: `backend/usecase/testutil/scope/testdata.go`
- Fake example: `backend/usecase/testutil/fake/{feature}/fake_{feature}_storage.go`

## Update Application Setup

Add new use-case and statements to `application_test_setup.go` if needed (follow the existing setup sections).

## Key Paths

- Tests: `backend/usecase/{feature}/`
- Production: `backend/usecase/{feature}/`
- Base setup: `backend/usecase/testutil/setup/`
- Statements: `backend/usecase/testutil/statements/`
- Scopes: `backend/usecase/testutil/scope/`
- Fakes: `backend/usecase/testutil/fake/`
