# Scheduling Adapter Implementation Template

## Rules

- Jobs are Celery tasks (with `django-celery-beat`) or APScheduler jobs
- Jobs delegate immediately to a usecase -- no business logic in the job
- Schedule expressions and lock durations come from Django settings
- Use `django-db-mutex` or `pottery` (Redis-based) for distributed locking in multi-instance deployments

## Reference (read before generating)

- Existing job: `backend/adapters/scheduling/src/cleanup_job.py`
- Config: `backend/adapters/scheduling/src/scheduling_config.py`
- Usecase port: `backend/usecase/src/{feature}/{feature}_usecase.py`

## Pattern (Celery)

1. Create `@shared_task` function or class-based task
2. Inject usecase via manual wiring (task receives usecase as argument or resolves from app config)
3. Add `django-celery-beat` schedule in Django settings or database
4. Add distributed lock via `django-db-mutex` or `pottery`
5. Delegate to usecase: `usecase.execute()`

## Pattern (APScheduler)

1. Create job class with constructor injection of the usecase
2. Register schedule: `scheduler.add_job(self.execute, CronTrigger.from_crontab(config.cron))`
3. Add distributed lock for multi-instance safety
4. Delegate to usecase: `self.usecase.execute()`

## Configuration

Add to Django settings:
```python
CLEANUP_CRON = os.environ.get("CLEANUP_CRON", "0 3 * * *")  # daily at 3 AM
CLEANUP_LOCK_DURATION = int(os.environ.get("CLEANUP_LOCK_DURATION", "300"))  # 5 minutes
```

## Key Paths

- Jobs: `backend/adapters/scheduling/src/`
- Config: `backend/adapters/scheduling/src/scheduling_config.py`
- Usecase ports: `backend/usecase/src/`
