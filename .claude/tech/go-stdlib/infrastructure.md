# Go/stdlib Infrastructure Idioms

Tech binding for `infrastructure.md`. Load alongside the universal rules.

## Health Check

- HTTP health endpoint: `source infrastructure/.env && curl http://localhost:$BACKEND_PORT/health`

## Process Safety

- Never kill by executable name: `taskkill //IM app.exe` — use port-based stop scripts instead.
- Never run `killall` on the Go binary name — it kills ALL instances system-wide, breaking parallel sessions.

## Config Fallback Syntax

Each file type has its own fallback pattern:
- Go env (os.Getenv): `os.Getenv("VAR")` with manual fallback: `if v := os.Getenv("VAR"); v != "" { return v } return "fallback"`
- Or use a helper: `envOr("VAR", "fallback")`
- Docker Compose, shell scripts: `${VAR:-fallback}` (colon-dash)

## Acceptance Tests

- `test-acceptance.sh` exports env vars then runs: `go test ./acceptance/... -v -count=1` or `go test ./acceptance/... -tags=acceptance`.
