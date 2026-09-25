# Vue 3/TypeScript Coding Conventions

Tech binding for `frontend-rules.md`. Shared section structure: `.claude/templates/coding/coding-sections.md`.

## File Extensions (Humble Object)

- Logic files: `.logic.ts`
- API client files: `.api.ts`
- Component files: `.vue`

## Feature Structure

- Features live in `frontend/src/features/{feature}/` with subdirectories:
  - `components/` -- Vue SFCs: `{Feature}Page.vue` and extracted sub-components.
  - `logic/` -- pure logic `{feature}.logic.ts`, API client `{feature}.api.ts`, `types.ts`.
  - `__tests__/` -- Vitest tests: `{feature}.logic.test.ts`, `{feature}.api.test.ts`.

## Shared UI Components

- Reusable components live in `frontend/src/app/components/ui/`.
- Examples: `FieldError.vue`, `LoadingSpinner.vue`, `PasswordToggle.vue`, `input-styles.ts`.

## Component Conventions

- Use `<script setup lang="ts">` for all components (Composition API).
- Props via `defineProps<T>()`, emits via `defineEmits<T>()`.
- Reactive state via `ref()` and `reactive()` from `vue`.
- Template expressions use Vue directives: `v-if`, `v-for`, `v-model`, `v-bind`, `v-on` (shorthand `:` and `@`).

## Icon Library

- Vue 3 icon library: `lucide-vue-next` (not `lucide-react`).
- Import: `import { Plus, X } from 'lucide-vue-next'`.
- Usage in template: `<Plus class="w-4 h-4" />`.
- Standard sizes: `w-4 h-4` (small), `w-5 h-5` (medium), `w-6 h-6` (large).

## Conditional className Syntax

- Ternary in `:class` binding: `:class="isActive ? 'bg-blue-500' : 'bg-gray-200'"`.
- Object syntax: `:class="{ 'bg-blue-500': isActive, 'bg-gray-200': !isActive }"`.
- Array syntax for combining: `:class="[baseClass, isActive ? 'active' : '']"`.
