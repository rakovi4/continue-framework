# React/TypeScript Coding Conventions

Tech binding for `frontend-rules.md`. Shared section structure: `.claude/templates/coding/coding-sections.md`.

## File Extensions (Humble Object)

- Pure model and transition functions: `.logic.ts`
- Effectful operation and lifecycle orchestration: `.controller.ts`; React lifecycle bindings may use capability-local hooks. Neither belongs in pure logic files.
- API client files: `.api.ts`
- Component files: `.tsx`

## Shared Principles in TypeScript

Apply `coding-detail.md` to functions, closures, hooks, classes, and modules alike.
Use these representations when running the shared refactor checklist:

| Shared concern | TypeScript representation |
|----------------|---------------------------|
| Model invariants and transitions | Validated value constructors, cohesive pure functions, reducers, or encapsulated classes; callers request named transitions |
| Fixed states and absence | Discriminated unions with exhaustive handling; internal model absence is a named variant, not a raw nullable field. Nullable transport/view fields are boundary representations and must be checked before model construction |
| Data ownership | A type and its behavior may share a module; do not force classes merely to attach methods to transport DTOs |
| Effects | Network, browser navigation/storage, timers, subscriptions, clock reads, and observable state commits; inspect behavior rather than whether the collaborator is injected |
| Error handling | Narrow caught `unknown` at the boundary; translate expected failures, preserve unexpected failures and cancellation semantics |
| Duplication | Compare exported functions, closure factories, hooks, object literals, and modules as well as classes |
| Control flow | Guard returns and exhaustive switches are valid in components and controllers; avoid nested ternaries or mutable JSX accumulators introduced solely to reduce return count |

Simple local names, hook-returned snapshots, and exhaustive union narrowing are
idioms, not waivers for mixed responsibilities. Apply common extraction evidence
to every function body, including callbacks and hook effects.

## Feature Structure

- Features live in `frontend/src/features/{feature}/`. Choose capability directories within each feature using File Organization in `.claude/rules/coding-rules.md`.
- Keep component, logic, API, type, and style files with their owning capability.
- Co-locate Vitest tests (`{feature}.logic.test.ts`, `{feature}.controller.test.ts`, `{feature}.api.test.ts`) or use a capability-local `__tests__/` directory. Shared code needs a named responsibility and explicit owner.
- Template-relative `components/`, `logic/`, and test paths are illustrative within one capability, not required feature-wide buckets. Resolve them against the agreed capability map and adjust imports.

## Shared UI Components

- Reusable components live in `frontend/src/app/components/ui/`.
- Examples: `field-error.tsx`, `loading-spinner.tsx`, `password-toggle.tsx`, `input-styles.ts`.

## Icon Library

- React icon library: `lucide-react`.
- Import: `import { Plus, X } from 'lucide-react'`.
- Usage in JSX: `<Plus className="w-4 h-4" />`.
- Standard sizes: `w-4 h-4` (small), `w-5 h-5` (medium), `w-6 h-6` (large).

## Conditional className Syntax

- Ternary: `isActive ? 'bg-blue-500' : 'bg-gray-200'`.
- Logical AND chains and switch-based class selection in JSX.
