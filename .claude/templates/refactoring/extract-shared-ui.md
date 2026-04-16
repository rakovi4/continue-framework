# Extract Shared UI Component

**When to use:** A component in a feature's `components/` directory is reusable across multiple features.

**Examples:** FieldError, LoadingSpinner, PasswordToggle, input style constants

## Step 1: Identify Candidate

Signs a component should be shared:
- Used (or will be used) by 2+ features
- No feature-specific logic or types
- Generic enough to work with any content (takes props like `message`, `text`, `onClick`)

## Step 2: Move to Shared Location

From: `frontend/src/features/{feature}/components/{Component}.tsx`
To: `frontend/src/app/components/ui/{component}.tsx`

Naming convention:
- Feature components: `PascalCase.tsx` (e.g., `PasswordStrengthBar.tsx`)
- Shared UI: `kebab-case.tsx` (e.g., `field-error.tsx`, `loading-spinner.tsx`)
- Style constants: `kebab-case.ts` (e.g., `input-styles.ts`)

## Step 3: Update All Imports

```tsx
// Before (feature-local)
import { FieldError } from './FieldError'

// After (shared)
import { FieldError } from '@/app/components/ui/field-error'
```

Find all usages: search for the old import path across `frontend/src/`.

## Step 4: Delete Old File

Remove the original file from the feature's `components/` directory.

## Step 5: Verify

1. `cd frontend && npx vitest run` — all tests pass
2. Check Vite dev server — no import errors in browser console

## Checklist

1. [ ] Component is generic (no feature-specific types)
2. [ ] Moved to `app/components/ui/` with kebab-case filename
3. [ ] All imports updated across codebase
4. [ ] Old file deleted
5. [ ] Tests pass
