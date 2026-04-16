# React/TypeScript Infrastructure Idioms

Tech binding for `infrastructure.md`. Load alongside the universal rules.

## Commands

- Dev server: `npm run dev`
- Run tests: `npx vitest run`

## Environment Variables

- `VITE_API_URL` — backend base URL, injected via `vite.config.ts` from `BACKEND_PORT`.
- Config fallback syntax: `process.env.VAR || 'fallback'` (JS syntax).

## Process Safety

- Dangerous commands for Node: `taskkill //IM node.exe`, `pkill node` -- these kill ALL instances system-wide.
