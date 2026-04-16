# Angular/TypeScript Infrastructure Idioms

Tech binding for `infrastructure.md`. Load alongside the universal rules.

## Commands

- Dev server: `npx ng serve`
- Run tests: `npx jest`

## Environment Variables

- `environment.apiUrl` -- backend base URL, configured in `src/environments/environment.ts`.
- Development environment: `src/environments/environment.development.ts`.
- Config fallback syntax: `process.env['VAR'] || 'fallback'` (JS syntax).

## Process Safety

- Dangerous commands for Node: `taskkill //IM node.exe`, `pkill node` -- these kill ALL instances system-wide.
