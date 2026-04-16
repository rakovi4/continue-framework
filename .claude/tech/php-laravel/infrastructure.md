# PHP/Laravel Infrastructure Idioms

Tech binding for `infrastructure.md`. Load alongside the universal rules.

## Health Check

- Laravel health endpoint: `source infrastructure/.env && curl http://localhost:$BACKEND_PORT/health`

## Process Safety

- Never kill by executable name: `taskkill //IM php.exe` -- use port-based stop scripts instead.
- Never run `pkill php` or `killall php` -- it kills ALL PHP processes system-wide, breaking parallel sessions.

## Config Fallback Syntax

Each file type has its own fallback pattern:
- Laravel `.env` / config: `env('VAR', 'fallback')`
- Docker Compose, shell scripts: `${VAR:-fallback}` (colon-dash)

## Acceptance Tests

- `test-acceptance.sh` exports env vars then runs PHPUnit: `./vendor/bin/phpunit acceptance/` or with group filter `--group backend` / `--group frontend`.
