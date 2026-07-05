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

## On-Demand Guidelines

The always-on rules (`.claude/rules/*.md`) hold only the high-level map, invariants, and safety guardrails. The per-topic detail is deferred to `.claude/guidelines/` and is **not** auto-loaded — read the matching file **before** doing that kind of work.

| When you are about to… | Read first |
|------------------------|-----------|
| Write or refactor backend code (any layer) | `.claude/guidelines/coding-detail.md` |
| Write or refactor frontend code or browser (Selenium/Cypress/Playwright) tests | `.claude/guidelines/frontend-rules.md` |
| Write or run TDD tests (red/green cycles, assertions, stop-on-failure) | `.claude/guidelines/tdd-rules.md` |
| Execute a scenario/task work unit (sequences, adapter-discovery, progress, resuming) | `.claude/guidelines/workflow-detail.md` |
| Start/stop services, touch CI runners, or run load tests | `.claude/guidelines/infrastructure-detail.md` |
| Edit prompt-library docs (agents/skills classification, structure) | `.claude/guidelines/prompt-rules.md` |
| Load or wire a technology binding (two-layer tech structure) | `.claude/guidelines/technology-loading.md` |
| Emit sub-agent progress to the live log | `.claude/guidelines/agent-logging.md` |

## Interaction Rules

- **Never block longer than 30 seconds.** No `sleep 60`, no `TaskOutput` with 5-minute timeouts. Use `run_in_background: true` for long commands, then poll with short separate calls (≤30s each) so the user sees progress between each check.
