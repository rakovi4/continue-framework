# Scheduling Adapter Test Template

## Test Class Rules

- Use `@SpringBootTest(classes = SchedulingTestConfiguration.class, properties = {...})` to boot a full context with ShedLock + Liquibase
- Override `cleanup.cron` to fire every second (`* * * * * *`) for fast tests
- Override `cleanup.lock-at-least-for` to `PT1S` to avoid lock contention
- Set `spring.liquibase.change-log=classpath:liquibase/changelog.xml` — real migrations from h2 adapter (`testRuntimeOnly project(':adapters:h2')`)
- Mock usecase dependencies (e.g., `ProcessCleanup`) — scheduling tests verify wiring, not business logic
- Use Awaitility (`await().atMost(3, SECONDS).untilAsserted(...)`) to assert async scheduled invocations

## Scheduling-Specific Failure Patterns

| Current Implementation | Expected Test Failure |
|----------------------|----------------------|
| Missing `@Scheduled` annotation | Awaitility timeout — mock never invoked |
| Missing `@EnableScheduling` on config | Awaitility timeout — scheduler not started |
| Wrong cron expression | Awaitility timeout — job doesn't fire in time window |
| Missing `LockProvider` bean | `NoSuchBeanDefinitionException` — context fails to start |
| ShedLock table missing from Liquibase | `CommandExecutionException` — lock table not found |

## Reference (read before generating)

- Test configuration: `backend/adapters/scheduling/src/test/java/com/example/scheduling/SchedulingTestConfiguration.java`
- Existing test: `backend/adapters/scheduling/src/test/java/com/example/scheduling/CleanupJobTest.java`
- Production code: `backend/adapters/scheduling/src/main/java/com/example/scheduling/`
- Liquibase migrations: `backend/adapters/h2/src/main/resources/liquibase/` (provided via `testRuntimeOnly`)

## Test Configuration

`SchedulingTestConfiguration` provides:
- `@EnableAutoConfiguration` — boots H2 datasource, Liquibase, Spring Scheduling
- `@ComponentScan` — picks up `SchedulingConfiguration` (ShedLock `LockProvider` + `@EnableSchedulerLock`) and `CleanupJob`
- Mock `ProcessCleanup` bean — verifiable via Mockito

Liquibase runs the real migrations from the h2 adapter — no duplicated schema files.

## Naming Convention

- Test class: `{JobName}Test.java` (e.g., `CleanupJobTest`)
- Test method: `should_{expected_behavior}` (e.g., `should_execute_cleanup_on_schedule`)

## Key Paths

- Tests: `backend/adapters/scheduling/src/test/java/com/example/scheduling/`
- Production: `backend/adapters/scheduling/src/main/java/com/example/scheduling/`
