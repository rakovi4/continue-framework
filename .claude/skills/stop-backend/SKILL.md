---
name: stop-backend
description: Stop the running backend application. Use when user wants to stop the backend server or mentions /stop-backend command.
---

# Stop Backend Application

## Action

Use `TaskStop` with the backend task ID (from `/run-backend` output).

If task ID unknown, use the stop script (reads port from `.env`):
```bash
infrastructure/scripts/stop-backend.sh
```

## Output

Report: backend stopped.
