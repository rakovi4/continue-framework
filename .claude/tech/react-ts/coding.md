# React/TypeScript Coding Conventions

Tech binding for `frontend-rules.md`. Shared section structure: `.claude/templates/coding/coding-sections.md`.

## File Extensions (Humble Object)

- Logic files: `.logic.ts`
- API client files: `.api.ts`
- Component files: `.tsx`

## Feature Structure

- Features live in `frontend/src/features/{feature}/` with subdirectories:
  - `components/` -- React components: `{Feature}Page.tsx` and extracted sub-components.
  - `logic/` -- pure logic `{feature}.logic.ts`, API client `{feature}.api.ts`, `types.ts`.
  - `__tests__/` -- Vitest tests: `{feature}.logic.test.ts`, `{feature}.api.test.ts`.

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
