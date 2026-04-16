# Python/Django Infrastructure Idioms

Tech binding for `infrastructure.md`. Load alongside the universal rules.

## Health Check

- Django health endpoint: `source infrastructure/.env && curl http://localhost:$BACKEND_PORT/health/`

## Process Safety

- Never kill by executable name: `taskkill //IM python.exe` — use port-based stop scripts instead.
- Never run `pkill python` or `killall python` — it kills ALL Python processes system-wide, breaking parallel sessions.

## Config Fallback Syntax

Each file type has its own fallback pattern:
- Django settings: `os.environ.get('VAR', 'fallback')`
- Docker Compose, shell scripts: `${VAR:-fallback}` (colon-dash)

## Acceptance Tests

- `test-acceptance.sh` exports env vars then runs pytest: `pytest acceptance/` or `pytest acceptance/ -m backend` / `pytest acceptance/ -m frontend`.
