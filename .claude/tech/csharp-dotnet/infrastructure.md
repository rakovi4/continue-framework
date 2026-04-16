# C#/ASP.NET Core Infrastructure Idioms

Tech binding for `infrastructure.md`. Load alongside the universal rules.

## Health Check

- ASP.NET Core health endpoint: `source infrastructure/.env && curl http://localhost:$BACKEND_PORT/health`

## Process Safety

- Never kill by executable name: `taskkill //IM dotnet.exe` — use port-based stop scripts instead.
- Never run `dotnet build-server shutdown` — it kills ALL build servers system-wide, breaking parallel sessions.

## Config Fallback Syntax

Each file type has its own fallback pattern:
- ASP.NET Core (`appsettings.json`): environment variables override JSON config via `IConfiguration` — use `configuration["VAR"] ?? "fallback"` in code
- Docker Compose, shell scripts: `${VAR:-fallback}` (colon-dash)

## Acceptance Tests

- `test-acceptance.sh` exports env vars then runs dotnet test: `dotnet test acceptance/` with `--filter "Category=Backend"` or `--filter "Category=Frontend"`.
