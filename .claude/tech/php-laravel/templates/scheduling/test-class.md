# Scheduling Adapter Test Template

## Test Class Rules

- Use Laravel's `Queue::fake()` or test scheduler with fast-firing schedule
- Override schedule to fire every second for fast tests
- Mock usecase dependencies -- scheduling tests verify wiring, not business logic
- Use polling with assertion for async scheduled invocations

## Scheduling-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Missing command registration | Timeout -- mock never invoked |
| Wrong schedule expression | Timeout -- job doesn't fire in time window |
| Missing cache lock setup | Lock key not found error |

## Reference (read before generating)

- Test setup: `backend/adapters/scheduling/tests/TestCase.php`
- Existing test: `backend/adapters/scheduling/tests/CleanupCommandTest.php`
- Production code: `backend/adapters/scheduling/src/`

## Test Configuration

Test setup provides:
- Fast schedule (every second) for quick test execution
- Mock usecase dependencies via `Mockery::mock()`
- Cache setup for distributed lock (if using `Cache::lock()`)

## Naming Convention

- Test file: `{CommandName}Test.php`
- Test method: `test_should_{expected_behavior}`

## Key Paths

- Tests: `backend/adapters/scheduling/tests/`
- Production: `backend/adapters/scheduling/src/`
