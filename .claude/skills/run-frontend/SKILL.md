---
name: run-frontend
description: Start the frontend dev server. Use when user wants to start the frontend or mentions /run-frontend command.
---

# Run Frontend Dev Server

## Prerequisite

Ensure `.env` file exists. If not, run setup first:
```bash
infrastructure/scripts/setup-ports.sh
```

## Action

Run the frontend script in background:
```bash
infrastructure/scripts/run-frontend.sh
```

Start the dev server as a persistent, pollable command so it keeps running after
the startup check. Retain its session identifier.

The script loads port configuration from `infrastructure/.env` and starts the frontend on the configured port.

## Output

Report startup status. Dev server runs at `http://localhost:{FRONTEND_PORT}` (from .env)

Stop with Ctrl+C or kill the background process.
