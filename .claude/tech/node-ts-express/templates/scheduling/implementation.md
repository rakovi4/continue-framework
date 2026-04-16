# Scheduling Adapter Implementation Template

## Rules

- Jobs are classes that register cron schedules via `node-cron`, `agenda`, or similar
- Jobs delegate immediately to a usecase — no business logic in the job
- Cron expressions and lock durations come from environment config
- Use distributed locking (e.g., `pg-boss`, `agenda`, or custom DB lock) for multi-instance safety

## Reference (read before generating)

- Existing job: `backend/adapters/scheduling/src/CleanupJob.ts`
- Config: `backend/adapters/scheduling/src/SchedulingConfig.ts`
- Usecase port: `backend/usecase/src/{feature}/{Feature}UseCase.ts`

## Pattern

1. Create job class with constructor injection of the usecase
2. Register cron schedule: `cron.schedule(config.cronExpression, () => this.execute())`
3. Add distributed lock check if multi-instance
4. Delegate to usecase: `await this.usecase.execute()`

## Configuration

Add to environment config:
```
JOB_NAME_CRON="0 3 * * *"           # e.g., daily at 3 AM
JOB_NAME_LOCK_DURATION=300000       # prevent re-execution within 5 minutes (ms)
```

## Key Paths

- Jobs: `backend/adapters/scheduling/src/`
- Config: `backend/adapters/scheduling/src/SchedulingConfig.ts`
- Usecase ports: `backend/usecase/src/`
