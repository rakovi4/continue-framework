# Scheduling Adapter Implementation Template -- C++/CMake

## Rules

- Jobs are classes that own a `std::thread` running a timer loop
- Jobs are first-layer adapters — see adapter interaction rules in `.claude/rules/coding-rules.md`
- Scheduler configuration (intervals, enable/disable) comes from environment variables or config file
- Use `std::condition_variable` for cancellable sleep (graceful shutdown)

## Reference (read before generating)

- Existing job: `backend/adapters/scheduling/src/cleanup_job.cpp`
- Job header: `backend/adapters/scheduling/include/scheduling/cleanup_job.h`
- Usecase port: `backend/usecase/include/usecase/cleanup/process_cleanup.h`

## Pattern

1. Create class with constructor accepting usecase reference and interval duration
2. `start()` method launches `std::thread` with timer loop
3. Timer loop: sleep for interval (using `condition_variable::wait_for` for cancellability), then call `usecase.execute()`
4. `stop()` method sets atomic flag and notifies condition variable
5. Destructor calls `stop()` and joins thread

## Configuration

Read from environment or config:
```cpp
auto interval = std::chrono::seconds(
    get_env_or("CLEANUP_INTERVAL_SECONDS", "3600"));
```

## Key Paths

- Jobs: `backend/adapters/scheduling/src/`
- Headers: `backend/adapters/scheduling/include/scheduling/`
- Usecase ports: `backend/usecase/include/usecase/`
