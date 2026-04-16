# C++/CMake Infrastructure Idioms

Tech binding for `infrastructure.md`. Load alongside the universal rules.

## Health Check

- Custom health endpoint (no built-in actuator): `source infrastructure/.env && curl http://localhost:$BACKEND_PORT/health`

## Process Safety

- Never kill by executable name: `taskkill //IM backend.exe` — use port-based stop scripts instead.
- Never run `cmake --build . --target clean` on shared build directories — it removes ALL build artifacts, breaking parallel sessions.

## Config Fallback Syntax

Each file type has its own fallback pattern:
- C++ code: read environment variable with fallback — `std::getenv("VAR") ? std::getenv("VAR") : "fallback"` or a `get_env_or("VAR", "fallback")` utility
- Docker Compose, shell scripts: `${VAR:-fallback}` (colon-dash)

## Acceptance Tests

- `test-acceptance.sh` exports env vars then runs acceptance test binary: `./build/acceptance/acceptance_tests --gtest_filter="*Backend*"` or `--gtest_filter="*Frontend*"`.
