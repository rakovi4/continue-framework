# Scheduling Adapter Test Template -- Go/stdlib

## Test Class Rules

- Use `robfig/cron` or custom ticker with test configuration for fast-firing jobs
- Override schedule to fire every second for fast tests
- Mock usecase dependencies — scheduling tests verify wiring, not business logic
- Use `require.Eventually` polling to assert async scheduled invocations

## Scheduling-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Missing cron job registration | Timeout — mock never invoked |
| Wrong cron expression | Timeout — job doesn't fire in time window |
| Missing distributed lock setup | Lock table/key not found error |

## Reference (read before generating)

- Test setup: `backend/adapters/scheduling/testutil/scheduling_test_setup.go`
- Existing test: `backend/adapters/scheduling/{feature}/{feature}_job_test.go`
- Production code: `backend/adapters/scheduling/{feature}/`

## Test Configuration

Test setup provides:
- Fast schedule (every second) for quick test execution
- Mock/fake usecase dependencies
- Database setup for distributed lock tables (if using DB-based locking)

## Naming Convention

- Test file: `{job_name}_test.go`
- Test function: `Test{JobName}(t *testing.T)`
- Subtest: `t.Run("should execute cleanup on schedule", ...)`

## Key Paths

- Tests: `backend/adapters/scheduling/{feature}/`
- Production: `backend/adapters/scheduling/{feature}/`
