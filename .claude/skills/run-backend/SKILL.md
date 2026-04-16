---
name: run-backend
description: Run the backend application. Use when user wants to start the backend server or mentions /run-backend command.
---

# Run Backend Application

## Prerequisite

Ensure `.env` file exists. If not, run setup first:
```bash
infrastructure/scripts/setup-ports.sh
```

## Action

Run the backend script in background:
```bash
infrastructure/scripts/run-backend.sh
```

Use `run_in_background: true` so the server keeps running.

The script loads port configuration from `infrastructure/.env` and starts the backend on the configured port.

## Output

Report startup status. Server runs at `http://localhost:{BACKEND_PORT}` (from .env)
