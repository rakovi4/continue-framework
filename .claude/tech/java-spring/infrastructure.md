# Java/Spring Infrastructure Idioms

Tech binding for `infrastructure.md`. Load alongside the universal rules.

## Health Check

- Spring Actuator endpoint: `source infrastructure/.env && curl http://localhost:$BACKEND_PORT/actuator/health`

## Process Safety

- Never kill by executable name: `taskkill //IM java.exe` — use port-based stop scripts instead.
- Never run `./gradlew --stop` — it kills ALL Gradle daemons system-wide, breaking parallel sessions.

## Config Fallback Syntax

Each file type has its own fallback pattern:
- Spring YAML: `${VAR:fallback}` (colon only)
- Docker Compose, shell scripts: `${VAR:-fallback}` (colon-dash)

## Acceptance Tests

- `test-acceptance.sh` exports env vars then runs Gradle: `./gradlew backendTest` or `./gradlew frontendTest`.
