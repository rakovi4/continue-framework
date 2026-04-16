# Scheduling Adapter Implementation Template -- C#/ASP.NET Core

## Rules

- Jobs are `IHostedService` / `BackgroundService` implementations or Hangfire/Quartz.NET jobs
- Jobs delegate immediately to a usecase — no business logic in the job
- Schedule expressions and lock durations come from `IConfiguration` / `appsettings.json`
- Use `DistributedLock` (via Redis or SQL) for multi-instance safety

## Reference (read before generating)

- Existing job: `backend/Adapters/Scheduling/CleanupJob.cs`
- Config: `backend/Adapters/Scheduling/SchedulingConfig.cs`
- Usecase port: `backend/Usecase/{Feature}/{Feature}Usecase.cs`

## Pattern (BackgroundService)

1. Create class extending `BackgroundService`
2. Inject usecase and `IConfiguration` via constructor
3. Override `ExecuteAsync` with a loop: delay by interval, then call usecase
4. Add distributed lock acquisition before usecase call
5. Register in `Program.cs`: `builder.Services.AddHostedService<CleanupJob>()`

## Pattern (Quartz.NET)

1. Create class implementing `IJob`
2. Inject usecase via constructor (Quartz.NET supports DI)
3. Implement `Execute(IJobExecutionContext)` — delegate to usecase
4. Configure schedule in `Program.cs` via `AddQuartz()` and `AddQuartzHostedService()`
5. Add distributed lock via `AdoJobStore` for multi-instance safety

## Configuration

Add to `appsettings.json`:
```json
{
  "Scheduling": {
    "CleanupCron": "0 3 * * *",
    "CleanupLockDurationSeconds": 300
  }
}
```

Override via environment: `Scheduling__CleanupCron`, `Scheduling__CleanupLockDurationSeconds`

## Key Paths

- Jobs: `backend/Adapters/Scheduling/`
- Config: `backend/Adapters/Scheduling/SchedulingConfig.cs`
- Usecase ports: `backend/Usecase/`
