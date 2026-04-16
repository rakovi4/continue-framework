# Scheduling Adapter Implementation Template

## Rules

- Jobs are Laravel Artisan commands registered in the scheduler (`Console/Kernel.php`) or queued jobs
- Schedule expressions and lock durations come from Laravel config files or `.env`
- Use `Cache::lock()` or `withoutOverlapping()` for distributed locking in multi-instance deployments

## Reference (read before generating)

- Existing command: `backend/adapters/scheduling/src/Commands/CleanupCommand.php`
- Config: `backend/adapters/scheduling/src/config/scheduling.php`
- Usecase port: `backend/usecase/src/{Feature}/{Feature}Usecase.php`

## Pattern (Artisan Command)

1. Create Artisan command extending `Command`
2. Inject usecase via constructor (Laravel auto-resolves)
3. Register schedule in `Console/Kernel.php`: `$schedule->command(CleanupCommand::class)->dailyAt('03:00')`
4. Add distributed lock via `->withoutOverlapping($lockMinutes)` or `Cache::lock()`
5. Delegate to usecase: `$this->usecase->execute()`

## Pattern (Queued Job)

1. Create job class implementing `ShouldQueue`
2. Inject usecase via constructor
3. Dispatch from scheduler: `$schedule->job(new CleanupJob())->dailyAt('03:00')`
4. Add `ShouldBeUnique` interface for distributed locking
5. Delegate to usecase: `$this->usecase->execute()`

## Configuration

Add to config file or `.env`:
```php
// config/scheduling.php
return [
    'cleanup_cron' => env('CLEANUP_CRON', '0 3 * * *'),
    'cleanup_lock_duration' => env('CLEANUP_LOCK_DURATION', 300),
];
```

## Key Paths

- Commands: `backend/adapters/scheduling/src/Commands/`
- Jobs: `backend/adapters/scheduling/src/Jobs/`
- Config: `backend/adapters/scheduling/src/config/`
- Usecase ports: `backend/usecase/src/`
