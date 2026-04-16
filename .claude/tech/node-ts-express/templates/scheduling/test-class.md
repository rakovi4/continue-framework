# Scheduling Adapter Test Template

## Test Class Rules

- Use `node-cron` or `agenda` with test configuration for fast-firing jobs
- Override cron schedule to fire every second for fast tests
- Mock usecase dependencies — scheduling tests verify wiring, not business logic
- Use `waitFor()` polling utility to assert async scheduled invocations

## Scheduling-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Missing cron job registration | Timeout — mock never invoked |
| Wrong cron expression | Timeout — job doesn't fire in time window |
| Missing distributed lock setup | Lock table/key not found error |

## Reference (read before generating)

- Test setup: `backend/adapters/scheduling/src/__tests__/setup/SchedulingTest.ts`
- Existing test: `backend/adapters/scheduling/src/__tests__/CleanupJob.test.ts`
- Production code: `backend/adapters/scheduling/src/`

## Test Configuration

Test setup provides:
- Fast cron schedule (every second) for quick test execution
- Mock usecase dependencies via `vi.fn()` / `jest.fn()`
- Database setup for distributed lock tables (if using DB-based locking)

## Naming Convention

- Test file: `{JobName}.test.ts`
- Test case: `it("should execute cleanup on schedule")`

## Key Paths

- Tests: `backend/adapters/scheduling/src/__tests__/`
- Production: `backend/adapters/scheduling/src/`
