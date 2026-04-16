# Angular/TypeScript TDD Conventions

## Testing Framework

- Logic tests: Jest, pure functions, no DOM, no Angular.
- API client tests: Jest + MSW (Mock Service Worker).

## Test Skip Marker

- `xit` / `xdescribe` is the test skip marker. Comment above the skip documents failure reason.
- Alternative: `.skip` (`it.skip`, `describe.skip`).

## Base URL Configuration

- Base URL resolved via `environment.ts` (`environment.apiUrl`).
- Test environment sets `apiUrl` dynamically from `BACKEND_PORT` via `jest.config.ts` (globalSetup or moduleNameMapper).
- Production API clients: `const BASE_URL = environment.apiUrl`.
- MSW tests: `const BASE = environment.apiUrl`.

