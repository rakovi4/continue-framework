# Scheduling Adapter Implementation Template

## Rules

- Jobs are `@Component` classes with `@Scheduled` + `@SchedulerLock` methods
- Jobs delegate immediately to a usecase — no business logic in the job
- `SchedulingConfiguration` owns `@EnableScheduling`, `@EnableSchedulerLock`, and the `LockProvider` bean
- Cron expressions and lock durations come from `application.yml` properties

## Reference (read before generating)

- Configuration: `backend/adapters/scheduling/src/main/java/com/example/scheduling/SchedulingConfiguration.java`
- Existing job: `backend/adapters/scheduling/src/main/java/com/example/scheduling/CleanupJob.java`
- Usecase port: `backend/usecase/src/main/java/com/example/usecase/cleanup/ProcessCleanup.java`

## Pattern

1. Create `@Component` class with `@RequiredArgsConstructor`
2. Inject the usecase service
3. Add `@Scheduled(cron = "${property.cron}")` on the execute method
4. Add `@SchedulerLock(name = "lock-name", lockAtLeastFor = "${property.lock-at-least-for}")` for distributed lock
5. Delegate to usecase: `usecase.execute()`

## Application Properties

Add to `application.yml`:
```yaml
job-name:
  cron: "0 0 3 * * *"           # e.g., daily at 3 AM
  lock-at-least-for: PT5M       # prevent re-execution within 5 minutes
```

## Key Paths

- Jobs: `backend/adapters/scheduling/src/main/java/com/example/scheduling/`
- Config: `backend/adapters/scheduling/src/main/java/com/example/scheduling/SchedulingConfiguration.java`
- Usecase ports: `backend/usecase/src/main/java/com/example/usecase/`
