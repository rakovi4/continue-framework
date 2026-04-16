# Scheduling Adapter Test Template -- C#/ASP.NET Core

## Test Class Rules

- Use `WebApplicationFactory<Program>` with test configuration for fast-firing jobs
- Override schedule to fire every second for fast tests
- Mock usecase dependencies — scheduling tests verify wiring, not business logic
- Use `Polly` retry or manual polling with `Task.Delay` to assert async scheduled invocations

## Scheduling-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Missing service registration | Timeout — mock never invoked |
| Wrong schedule expression | Timeout — job doesn't fire in time window |
| Missing distributed lock setup | Lock table/key not found error |

## Reference (read before generating)

- Test setup: `backend/Adapters/Scheduling.Tests/TestFixture.cs`
- Existing test: `backend/Adapters/Scheduling.Tests/CleanupJobTest.cs`
- Production code: `backend/Adapters/Scheduling/`

## Test Configuration

Test fixture provides:
- Fast schedule (every second) for quick test execution
- Mock usecase dependencies via `Mock<T>()` / `Substitute.For<T>()`
- Database setup for distributed lock tables (if using SQL-based locking)

## Naming Convention

- Test file: `{JobName}Test.cs`
- Test method: `Should_{expected_behavior}`

## Key Paths

- Tests: `backend/Adapters/Scheduling.Tests/`
- Production: `backend/Adapters/Scheduling/`
