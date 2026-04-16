# HTTP Handler Test Template -- Go/stdlib

> Universal rules: `.claude/templates/tdd/red-rest.md`

## Tech-Specific Rules

- Use `httptest.NewRecorder` + `httptest.NewRequest` with chi router
- Mock use-case dependencies with hand-written fakes or `testify/mock`
- Create exactly ONE `t.Run(...)` subtest, add `t.Skip`
- Use descriptive subtest names with Gherkin-style description
- Setup: configure fake/mock to return expected values
- Execute: `handler.ServeHTTP(recorder, request)`
- Verify: `assert.Equal(t, http.StatusOK, recorder.Code)` + decode body

## Expected Response JSON

Create in `backend/adapters/http/testutil/fixtures/{feature}/` or inline as struct literals for small responses.

## Reference (read before generating)

- Test example: `backend/adapters/http/{feature}/{feature}_handler_test.go`
- Test setup: `backend/adapters/http/testutil/http_test_setup.go`
- Request DTO example: `backend/adapters/http/{feature}/dto/{feature}_request.go`
- JSON fixture example: `backend/adapters/http/testutil/fixtures/`

## Key Paths

- Tests: `backend/adapters/http/{feature}/`
- Production: `backend/adapters/http/{feature}/`
- DTOs: `backend/adapters/http/{feature}/dto/`
- Fixtures: `backend/adapters/http/testutil/fixtures/`
