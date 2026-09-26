# React/TypeScript TDD Conventions

## Testing Framework

- Model tests: Vitest, pure functions, no DOM, no React.
- Controller tests: Vitest with injected effect ports, controlled timers, and deferred promises; preserve current/stale completion and disposal behavior.
- API client tests: Vitest + MSW (Mock Service Worker).

## Shared Test Quality

Apply the common refactor checks to every test callback and fixture. Vitest's
native assertions may stay inline when the scenario remains at one abstraction
level; extract multi-step setup and repeated observation into named, typed
capability-local helpers. The absence of a Statements class does not exempt
duplication, mixed concerns, calculated expected values, or weak assertions.
Keep expected values independent of the production computation under test.

## Test Skip Marker

- `.skip` is the test skip marker. Encode the failure reason in the skipped test or suite name.

## Base URL Configuration

- Base URL resolved via `import.meta.env.VITE_API_URL`.
- Vitest sets `VITE_API_URL` dynamically from `BACKEND_PORT` via `vite.config.ts`.
- Production API clients: `const BASE_URL = import.meta.env.VITE_API_URL ?? ''`.
- MSW tests: `const BASE = import.meta.env.VITE_API_URL`.
