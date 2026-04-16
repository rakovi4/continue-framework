# Vue 3/TypeScript TDD Conventions

## Testing Framework

- Logic tests: Vitest, pure functions, no DOM, no Vue.
- API client tests: Vitest + MSW (Mock Service Worker).

## Test Skip Marker

- `.skip` is the test skip marker. Comment above `.skip` documents failure reason.

## Base URL Configuration

- Base URL resolved via `import.meta.env.VITE_API_URL`.
- Vitest sets `VITE_API_URL` dynamically from `BACKEND_PORT` via `vite.config.ts`.
- Production API clients: `const BASE_URL = import.meta.env.VITE_API_URL ?? ''`.
- MSW tests: `const BASE = import.meta.env.VITE_API_URL`.
