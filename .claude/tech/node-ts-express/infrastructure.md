# Node/TypeScript/Express Infrastructure Idioms

Tech binding for `infrastructure.md`. Load alongside the universal rules.

## Health Check

- Express health endpoint: `source infrastructure/.env && curl http://localhost:$BACKEND_PORT/health`

## Process Safety

- Never kill by executable name: `taskkill //IM node.exe` — use port-based stop scripts instead.
- Never run `npx kill-port` or `fuser -k` on unknown ports — it kills ALL Node processes on that port, breaking parallel sessions.

## Config Fallback Syntax

Each file type has its own fallback pattern:
- Node env (dotenv): `process.env.VAR || 'fallback'` or `process.env.VAR ?? 'fallback'`
- Docker Compose, shell scripts: `${VAR:-fallback}` (colon-dash)

## Acceptance Tests

- `test-acceptance.sh` exports env vars then runs the test runner: `npx vitest run acceptance/` or `npx jest --config acceptance/jest.config.ts`.
