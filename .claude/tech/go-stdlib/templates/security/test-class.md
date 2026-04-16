# Security Adapter Test Template -- Go/stdlib

## Test Class Rules

- Pure unit tests — NO HTTP server context
- Mock dependencies with hand-written fakes or `testify/mock`
- Construct the struct under test manually in test setup
- Use `FakeClock` for deterministic time
- Use `t.Run("scenario description", ...)` subtests with Gherkin-style description

## Security-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Wrong mock interaction | Mock verification failure |

## Reference (read before generating)

- Existing test: `backend/adapters/security/{feature}/{feature}_test.go`
- JWT service: `backend/adapters/security/jwt/jwt_service.go`
- Config: `backend/adapters/security/config/jwt_config.go`
- Middleware: `backend/adapters/security/middleware/session_auth_middleware.go`

## Test Pattern

1. **Setup**: create fakes, fixed clock, construct struct under test
2. **Mock**: configure fake to return expected values
3. **Execute**: call method under test
4. **Assert**: use `assert.Equal` / `require.NoError` with descriptive messages
5. **Verify** (optional): check fake was called with expected args

## Naming Convention

- Test file: `{component_name}_test.go`
- Test function: `Test{ComponentName}(t *testing.T)`
- Subtest: `t.Run("should {expected behavior}", ...)`

## Key Paths

- Tests: `backend/adapters/security/{feature}/`
- Production: `backend/adapters/security/{feature}/`
