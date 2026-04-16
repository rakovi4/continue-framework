# CLAUDE.md

TDD Framework Template — Clean Architecture backend (multi-module) + frontend + E2E acceptance tests.

Technology stack and commands are declared in `ProductSpecification/technology.md`. Read that file for build commands, test commands, and framework-specific conventions.

## Architecture

```
application → adapters → usecase → domain
```

All backend modules live under `backend/`. Never place them in the project root.

| Module | Description | Dependencies |
|--------|-------------|--------------|
| `backend/domain` | Entities, value objects, exceptions | None (code generation only) |
| `backend/usecase` | Application services, port interfaces | domain |
| `backend/adapters/rest` | Web controllers, auth | usecase |
| `backend/adapters/h2` | Database repositories, migrations | usecase |
| `backend/adapters/email` | Mail integration | usecase |
| `backend/application` | Entry point, wiring | all modules |
| `acceptance` | Black-box API tests (top-level) | None (HTTP + Selenium) |

Dependency flow is strictly inward. Never import from outer layers in inner layers.

## Interaction Rules

- **Never block longer than 30 seconds.** No `sleep 60`, no `TaskOutput` with 5-minute timeouts. Use `run_in_background: true` for long commands, then poll with short separate calls (≤30s each) so the user sees progress between each check.
