# Scheduling Adapter Test Template

## Test Class Rules

- Use `django-celery-beat` or `APScheduler` with test configuration for fast-firing jobs
- Override schedule to fire every second for fast tests
- Mock usecase dependencies -- scheduling tests verify wiring, not business logic
- Use `tenacity` retry with assertion to poll for async scheduled invocations

## Scheduling-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Missing task registration | Timeout -- mock never invoked |
| Wrong schedule expression | Timeout -- job doesn't fire in time window |
| Missing distributed lock setup | Lock table/key not found error |

## Reference (read before generating)

- Test setup: `backend/adapters/scheduling/tests/conftest.py`
- Existing test: `backend/adapters/scheduling/tests/test_cleanup_job.py`
- Production code: `backend/adapters/scheduling/src/`

## Test Configuration

Test conftest provides:
- Fast schedule (every second) for quick test execution
- Mock usecase dependencies via `unittest.mock.Mock()`
- Database setup for distributed lock tables (if using DB-based locking)

## Naming Convention

- Test file: `test_{job_name}.py`
- Test method: `test_should_{expected_behavior}`

## Key Paths

- Tests: `backend/adapters/scheduling/tests/`
- Production: `backend/adapters/scheduling/src/`
