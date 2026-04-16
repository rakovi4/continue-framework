# Security Adapter Test Template -- C++/CMake

## Test Class Rules

- Use Google Test fixture with GMock — NO framework context
- Mock dependencies with GMock `NiceMock<MockType>` or `StrictMock<MockType>`
- Construct the class under test manually in `SetUp()`
- Use `FakeClock` for deterministic time
- Use descriptive test names with `DISABLED_` prefix

## Security-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Wrong mock interaction | GMock verification failure |

## Reference (read before generating)

- Existing test: `backend/adapters/security/tests/filter/session_auth_filter_test.cpp`
- JWT service: `backend/adapters/security/src/jwt_service.cpp`
- Properties: `backend/adapters/security/src/jwt_properties.h`
- Filter: `backend/adapters/security/src/filter/session_auth_filter.cpp`

## Test Pattern

1. **Setup** (`SetUp()`): create mocks, FakeClock, construct class under test
2. **Mock**: `EXPECT_CALL(mock, method(_)).WillOnce(Return(value))`
3. **Execute**: call method under test
4. **Assert**: use `EXPECT_EQ`, `EXPECT_THROW` with descriptive messages
5. **Verify** (optional): GMock auto-verifies expectations on destruction

## Naming Convention

- Test class: `{ComponentName}Test`
- Test method: `should_{expected_behavior}`

## Key Paths

- Tests: `backend/adapters/security/tests/`
- Production: `backend/adapters/security/src/`
- Headers: `backend/adapters/security/include/security/`
