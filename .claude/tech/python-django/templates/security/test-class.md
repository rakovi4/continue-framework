# Security Adapter Test Template

## Test Class Rules

- Pure unit tests -- NO Django test client context
- Mock dependencies with `unittest.mock.Mock()` / `MagicMock()`
- Construct the class under test manually in `setup_method`
- Use `FakeClock` or `unittest.mock.patch("time.time")` for deterministic time
- Use class-level docstring with Gherkin-style description

## Security-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Wrong mock interaction | Mock verification failure |

## Reference (read before generating)

- Existing test: `backend/adapters/security/tests/middleware/test_session_auth_middleware.py`
- JWT service: `backend/adapters/security/src/jwt_service.py`
- Config: `backend/adapters/security/src/jwt_config.py`
- Middleware: `backend/adapters/security/src/middleware/session_auth_middleware.py`

## Test Pattern

1. **Setup** (`setup_method`): create mocks, fixed clock, construct class under test
2. **Mock**: `mock_dependency.method.return_value = value`
3. **Execute**: call method under test
4. **Assert**: use `assert actual == expected` with descriptive messages
5. **Verify** (optional): `mock_dependency.method.assert_called_once_with(args)` for side-effect verification

## Naming Convention

- Test file: `test_{component_name}.py`
- Test method: `test_should_{expected_behavior}`

## Key Paths

- Tests: `backend/adapters/security/tests/`
- Production: `backend/adapters/security/src/`
