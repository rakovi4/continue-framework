# Scheduling Adapter Test Template -- C++/CMake

## Test Class Rules

- Use Google Test fixture with a fast-firing timer (100ms interval instead of cron schedule)
- Mock usecase dependencies with GMock — scheduling tests verify wiring, not business logic
- Use polling with `std::this_thread::sleep_for` and assertion to verify async scheduled invocations

## Scheduling-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Job not registered with scheduler | Polling timeout — mock never invoked |
| Wrong interval configured | Polling timeout — job doesn't fire in time window |
| Missing thread/timer setup | Polling timeout — scheduler not started |

## Reference (read before generating)

- Test fixture: `backend/adapters/scheduling/tests/scheduling_test_fixture.h`
- Existing test: `backend/adapters/scheduling/tests/cleanup_job_test.cpp`
- Production code: `backend/adapters/scheduling/src/`

## Test Pattern

1. **Setup**: construct scheduler with mock usecases and fast interval
2. **Start**: start the scheduler thread
3. **Wait**: poll with timeout until mock is invoked
4. **Assert**: verify mock was called at least once
5. **Teardown**: stop scheduler thread, join

## Naming Convention

- Test class: `{JobName}Test`
- Test method: `should_{expected_behavior}`

## Key Paths

- Tests: `backend/adapters/scheduling/tests/`
- Production: `backend/adapters/scheduling/src/`
