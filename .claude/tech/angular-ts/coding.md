# Angular/TypeScript Coding Conventions

Tech binding for `frontend-rules.md`. Shared section structure: `.claude/templates/coding/coding-sections.md`.

## File Extensions (Humble Object)

- Logic files: `.logic.ts`
- API client files: `.api.ts`
- Component files: `.component.ts` + `.component.html`

## Feature Structure

- Features live in `frontend/src/app/features/{feature}/`. Choose capability directories within each feature using File Organization in `.claude/rules/coding-rules.md`.
- Keep Angular component source, template, and styles together.
- Co-locate Jest tests (`{feature}.logic.spec.ts`, `{feature}.api.spec.ts`) or use a capability-local `__tests__/` directory. Shared code needs a named responsibility and explicit owner.
- Template-relative `components/`, `logic/`, and test paths are illustrative within one capability, not required feature-wide buckets. Resolve them against the agreed capability map and adjust imports.

## Shared UI Components

- Reusable components live in `frontend/src/app/shared/components/`.
- Examples: `field-error/`, `loading-spinner/`, `password-toggle/`, `input-styles.ts`.

## Component Pattern

- Components use standalone API (`standalone: true`).
- Use signals for reactive state (`signal()`, `computed()`).
- Use `inject()` for dependency injection instead of constructor injection.
- Template syntax: `@if`, `@for`, `@switch` (Angular 17+ control flow).

## Icon Library

- Angular icon library: `lucide-angular`.
- Import: `import { LucideAngularModule, Plus, X } from 'lucide-angular'`.
- Usage in template: `<lucide-icon [img]="Plus" class="w-4 h-4"></lucide-icon>`.
- Standard sizes: `w-4 h-4` (small), `w-5 h-5` (medium), `w-6 h-6` (large).

## Conditional Class Syntax

- Use `[class.active]="isActive"` for single-class toggles.
- Use `[ngClass]` for multi-class conditional logic.
- Extract helper functions in `.logic.ts` when the same condition appears in 2+ elements.
