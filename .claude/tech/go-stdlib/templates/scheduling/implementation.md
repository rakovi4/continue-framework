# Scheduling Adapter Implementation Template -- Go/stdlib

## Rules

- Jobs are structs that register cron schedules via `robfig/cron` or `time.Ticker`
- Jobs delegate immediately to a usecase — no business logic in the job
- Cron expressions and lock durations come from environment config
- Use distributed locking (e.g., `pglock`, advisory locks, or custom DB lock) for multi-instance safety

## Reference (read before generating)

- Existing job: `backend/adapters/scheduling/{feature}/{feature}_job.go`
- Config: `backend/adapters/scheduling/config/scheduling_config.go`
- Usecase port: `backend/usecase/{feature}/{feature}_usecase.go`

## Pattern

1. Create job struct with constructor injection of the usecase
2. Register cron schedule: `c.AddFunc(config.CronExpression, job.Execute)`
3. Add distributed lock check if multi-instance
4. Delegate to usecase: `job.usecase.Execute(ctx)`

## Configuration

Add to environment config:
```
JOB_NAME_CRON="0 3 * * *"           # e.g., daily at 3 AM
JOB_NAME_LOCK_DURATION=300          # prevent re-execution within 5 minutes (seconds)
```

## Key Paths

- Jobs: `backend/adapters/scheduling/{feature}/`
- Config: `backend/adapters/scheduling/config/`
- Usecase ports: `backend/usecase/port/`
