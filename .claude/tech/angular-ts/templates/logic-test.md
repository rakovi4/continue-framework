# Frontend Logic Test Template

## Test File

Location: `frontend/src/app/features/{feature}/__tests__/{feature}.logic.spec.ts`

```typescript
import { validateEmail, validatePassword, isFormValid, buildRegistrationRequest } from '../logic/registration.logic'

describe('Registration Logic', () => {
  describe('validateEmail', () => {
    it('should return valid for correct email format', () => {
      const result = validateEmail('user@example.com')

      expect(result.valid).toBe(true)
      expect(result.error).toBeUndefined()
    })

    it('should return error for empty email', () => {
      const result = validateEmail('')

      expect(result.valid).toBe(false)
      expect(result.error).toBe('Email is required')
    })
  })
})
```

## Stub

Create minimal stub in `logic/{feature}.logic.ts`:

```typescript
import type { ValidationResult } from './types'

export function validateEmail(email: string): ValidationResult {
  throw new Error('Not implemented')
}
```

## Types

Create `logic/types.ts` if not present:

```typescript
export interface ValidationResult {
  valid: boolean
  error?: string
}
```

## Expected Failure Patterns

| Stub | Expected Failure |
|------|-----------------|
| `throw new Error('Not implemented')` | Error: Not implemented |
| `return undefined` | expect(undefined).toBe(true) fails |
| No function exported | Import error |

## .skip Convention

After verified failure, add .skip with comment:

```typescript
// TDD Red Phase - validateEmail not implemented
it.skip('should return valid for correct email format', () => {
  // ... test unchanged ...
})
```

## Test Verification

```
Skill tool: skill="test-frontend", args="--testPathPattern={feature}.logic"
```
