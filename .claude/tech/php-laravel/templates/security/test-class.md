# Security Adapter Test Template

## Test Class Rules

- Pure unit tests -- NO Laravel application context
- Mock dependencies with `Mockery::mock()`
- Construct the class under test manually in `setUp()`
- Use `FakeClock` or `Carbon::setTestNow()` for deterministic time
- Add `#[TestDox('...')]` with Gherkin-style description

## Security-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Wrong mock interaction | Mock verification failure |

## Reference (read before generating)

- Existing test: `backend/adapters/security/tests/Middleware/SessionAuthMiddlewareTest.php`
- JWT service: `backend/adapters/security/src/JwtService.php`
- Config: `backend/adapters/security/src/JwtConfig.php`
- Middleware: `backend/adapters/security/src/Middleware/SessionAuthMiddleware.php`

## Test Pattern

1. **Setup** (`setUp`): create mocks, fixed clock, construct class under test
2. **Mock**: `$mockDependency->shouldReceive('method')->andReturn($value)`
3. **Execute**: call method under test
4. **Assert**: use `$this->assertEquals($expected, $actual)` with descriptive messages
5. **Verify** (optional): `$mockDependency->shouldHaveReceived('method')->with($args)->once()` for side-effect verification

## Naming Convention

- Test file: `{ComponentName}Test.php`
- Test method: `test_should_{expected_behavior}`

## Key Paths

- Tests: `backend/adapters/security/tests/`
- Production: `backend/adapters/security/src/`
